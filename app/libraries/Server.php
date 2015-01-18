<?php
/**
 * Created by PhpStorm.
 * User: martin
 * Date: 14-7-2
 * Time: 下午5:38
 */
use \Phalcon\Mvc\User\Component;

class Server extends Component
{
    public  static $CONF_FIELD_NAME      = 'name';
    public  static $CONF_FIELD_MYSQL     = 'mysql';
    public  static $CONF_FIELD_REDIS     = 'redis';
    public  static $CONF_FIELD_HOST      = 'host';
    public  static $CONF_FIELD_PORT      = 'port';
    public  static $CONF_FIELD_USERNAME  = 'username';
    public  static $CONF_FIELD_PASSWORD  = 'password';
    public  static $CONF_FIELD_DBNAME    = 'dbname';
    public  static $CONF_FIELD_CHARSET   = 'charset';
    private static $SERVER_DI_PREFIX     = 'server';

    public $server_conf;

    public function __construct()
    {
        $this->server_conf = require __DIR__ . '/../config/servers.php';
        $this->server_conf = $this->server_conf[CHANNEL_ID];
    }

    public function getServerConf($server_id = null)
    {
        if (isset ($server_id) && ! isset ($this->server_conf[$server_id])) {
            throw new \Phalcon\Exception('Server Conf Not Found for ServerID:' . $server_id, 500);
        }
        return $server_id ? $this->server_conf[$server_id] : $this->server_conf;
    }

    public static function getDIName($server_id, $field)
    {
        if (! ($server_id && $field)) {
            throw new \Phalcon\Exception("ServerID or Field cannot be empty.", 500);
        }
        return implode(':', [self::$SERVER_DI_PREFIX, $server_id, $field]);
    }

    public function getServerList()
    {
        $ret = [];
        foreach ($this->server_conf as $server_id => $conf) {
            $ret[$server_id] = $conf[self::$CONF_FIELD_NAME];
        }
        return $ret;
    }

    public function isValidServerID($server_id)
    {
        return array_key_exists($server_id, $this->server_conf);
    }

    public function getNumericServerID($server_id)
    {
        if ($this->isValidServerID($server_id)) {
            return $this->server_conf[$server_id]['id'];
        }
        return false;
    }
}
