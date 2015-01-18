<?php
use Phalcon\Mvc\Model;

class Exchangecode extends Model
{
    public $id;
    public $title;
    public $content;
    public $weight;
    public $start;
    public $end;

    public function onConstruct()
    {
        $this->setSource('exchange');
    }

    public function batchInsert($rows) {
        syslog(LOG_INFO, "batch insert ".count($rows));
        $di = \Phalcon\DI::getDefault();
        $db = $di->getShared('db');
        $tblname = $this->getSource();
        $sql_pre = "insert into $tblname (code, type, get_by, get_at, server_id, tag, items) values ";
        $sql_values = array();
        foreach ($rows as $row) {
            $ecode = $db->escapeString($row['code']);
            $sql_values []= "($ecode, $row[type], $row[get_by], $row[get_at], $row[server_id], $row[tag], $row[items])";
        }
        $sql_values_str = implode(",", $sql_values);
        $sql = $sql_pre.$sql_values_str;
        //syslog(LOG_INFO, $sql);
        $r = $db->execute($sql);
        $affected_rows = $db->affectedRows();
        return $affected_rows;
    }
}
