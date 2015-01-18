<?php
/**
 * Created by PhpStorm.
 * User: martin
 * Date: 14-7-2
 * Time: 下午9:33
 */
use Phalcon\Mvc\Model;

class ServerUser extends Model
{
    public function onConstruct()
    {
        $server_id = $this->getDI()->get('server_id');
        $this->setConnectionService(Server::getDIName($server_id, Server::$CONF_FIELD_MYSQL));
        $this->setSource('user');
    }
}