<?php
/**
 * Created by PhpStorm.
 * User: martin
 * Date: 14-7-2
 * Time: 下午9:33
 */
use Phalcon\Mvc\Model;

class Kpi extends Model
{
    public $id;
    public $date;
    public $type;
    public $data;

    public function onConstruct()
    {
        $server_id = $this->getDI()->get('server_id');
        $this->setConnectionService(Server::getDIName($server_id, Server::$CONF_FIELD_MYSQL));
        $this->setSource('kpi');
    }
}