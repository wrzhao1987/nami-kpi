<?php

use \Phalcon\Mvc\User\Component;

class Exchange extends Component {

    public function __construct() {
        syslog(LOG_DEBUG, "constructing ....");
    }

    public function generateCode($num, $type) {
        syslog(LOG_INFO, "generateCode($num)");
        $alpha = 'abcdefghijklmnopqrstuvwxyz0123456789';
        $len = strlen($alpha);
        // check items
        $exchange_model = new Exchangecode();
        $count = 0;
        $rows = array();
        for ($i = 0; $i < $num; $i++) {
            $code = "";
            $count++;
            for ($j = 0; $j < 8; $j++) {
                $pos = mt_rand(0, $len - 1); 
                $code .= $alpha[$pos];
            }
            $new_code = [
                'code' => $code,
                'type' => $type,
                'get_by' => 0,
                'get_at' => 0,
                'server_id'=> 0,
                'expire' => 0,
                'tag' => 0,
                'items' => '',
            ];
            $rows []= $new_code;
            if (count($rows) >= 1000) {
                $exchange_model->batchInsert($rows);
                $rows = array();
            }
            //$codes []= $code;
        }
        if (count($rows)) {
            $exchange_model->batchInsert($rows);
        }
        return array('ncodes'=>$rows);
    }
}
