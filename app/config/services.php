<?php

use Phalcon\DI\FactoryDefault;
use Phalcon\Mvc\View;
use Phalcon\Mvc\Url as UrlResolver;
use Phalcon\Db\Adapter\Pdo\Mysql as DbAdapter;
use Phalcon\Mvc\View\Engine\Volt as VoltEngine;
use Phalcon\Mvc\Model\Metadata\Memory as MetaDataAdapter;
use Phalcon\Session\Adapter\Files as SessionAdapter;

/**
 * The FactoryDefault Dependency Injector automatically register the right services providing a full stack framework
 */
$di = new FactoryDefault();

/**
 * The URL component is used to generate all kind of urls in the application
 */
$di->set('url', function () use ($config) {
    $url = new UrlResolver();
    $url->setBaseUri($config->application->baseUri);

    return $url;
}, true);

function parse_time($str) {
    return explode(" ", $str)[1];
}
function parse_date($str) {
    return explode(" ", $str)[0];
}

/**
 * Setting up the view component
 */
$di->set('view', function () use ($config) {

    $view = new View();

    $view->setViewsDir($config->application->viewsDir);

    $view->registerEngines(array(
        '.volt' => function ($view, $di) use ($config) {

            $volt = new VoltEngine($view, $di);

            $volt->setOptions(array(
                'compiledPath' => $config->application->cacheDir,
                'compiledSeparator' => '_',
                'compileAlways' => true,
            ));
            $compiler = $volt->getCompiler();
            $compiler->addFilter('parse_date', 'parse_date');
            $compiler->addFilter('parse_time', 'parse_time');

            return $volt;
        },
        '.phtml' => 'Phalcon\Mvc\View\Engine\Php'
    ));

    return $view;
}, true);

/**
 * Database connection is created based in the parameters defined in the configuration file
 */
$di->set('db', function () use ($config) {
    return new DbAdapter(array(
        'host' => $config->database->host,
        'username' => $config->database->username,
        'password' => $config->database->password,
        'dbname' => $config->database->dbname
    ));
});

// 根据Server List注册所有服务器的MySQL和Redis相关服务
$server_lib = new Server();
foreach ($server_lib->server_conf as $server_id => $conf) {
    foreach ($conf as $field => $detail) {
        $di_name = Server::getDIName($server_id, $field);
        switch ($field) {
            case Server::$CONF_FIELD_MYSQL:
                $di->set($di_name, function () use ($detail){
                    return new DbAdapter([
                        Server::$CONF_FIELD_HOST     => $detail[Server::$CONF_FIELD_HOST],
                        Server::$CONF_FIELD_USERNAME => $detail[Server::$CONF_FIELD_USERNAME],
                        Server::$CONF_FIELD_PASSWORD => $detail[Server::$CONF_FIELD_PASSWORD],
                        Server::$CONF_FIELD_DBNAME   => $detail[Server::$CONF_FIELD_DBNAME],
                        Server::$CONF_FIELD_CHARSET  => $detail[Server::$CONF_FIELD_CHARSET],
                    ]);
                });
                break;
            case Server::$CONF_FIELD_REDIS:
                $di->set($di_name, function () use ($detail) {
                    $redis = new \Redis();
                    $redis->connect($detail[Server::$CONF_FIELD_HOST], $detail[Server::$CONF_FIELD_PORT]);
                    return $redis;
                });
                break;
            default:
        }
    }
}

/**
 * If the configuration specify the use of metadata adapter use it or use memory otherwise
 */
$di->set('modelsMetadata', function () {
    return new MetaDataAdapter();
});

/**
 * Start the session the first time some component request the session service
 */
$di->set('session', function () {
    $session = new SessionAdapter();
    $session->start();

    return $session;
});
