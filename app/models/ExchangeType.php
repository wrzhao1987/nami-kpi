<?php
use Phalcon\Mvc\Model;

class ExchangeType extends Model
{
    public $id;
    public $name;
    public $items;
    public $start_date;
    public $end_date;
    public $reuse;
    public $channel_id;

    public function onConstruct()
    {
        $this->setSource('ex_type');
    }
}