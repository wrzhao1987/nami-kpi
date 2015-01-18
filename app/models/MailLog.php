<?php
use Phalcon\Mvc\Model;

class MailLog extends Model
{
    public $id;
    public $username;
    public $title;
    public $content;
    public $server_id;
    public $to_users;
    public $attachment;
    public $added_at;

    public function getSource()
    {
        return 'mail_log';
    }
}