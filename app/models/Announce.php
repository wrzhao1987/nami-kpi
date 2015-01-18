<?php
/**
 * Created by PhpStorm.
 * User: martin
 * Date: 14-7-2
 * Time: 下午9:33
 */
use Phalcon\Mvc\Model;

class Announce extends Model
{
    public $id;
    public $title;
    public $content;
    public $weight;
    public $start;
    public $end;

    public function onConstruct()
    {
        $server_id = $this->getDI()->get('server_id');
        $this->setConnectionService(Server::getDIName($server_id, Server::$CONF_FIELD_MYSQL));
        $this->setSource('announce');
    }
}