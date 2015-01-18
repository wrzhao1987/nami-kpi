<?php
/**
 * Created by PhpStorm.
 * User: martin
 * Date: 14-6-21
 * Time: 下午6:48
 */
use Phalcon\Mvc\Model;

class User extends Model
{
    public $id;
    public $name;
    public $pwd;
    public $role;
    public $active;
    public $note;
    public $added_at;
    public $last_login;

    public function getSource()
    {
        return 'user';
    }
}