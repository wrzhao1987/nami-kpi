<?php

class ExchangeController extends ControllerBase {

    private $channel_conv = [
        1 => '安卓区',
        2 => '苹果区',
        3 => '越狱区',
        4 => '测试区',
    ];
    public function manageNewAction()
    {
        if (!$this->isAllowed()) {
            $this->setNotice('你没有权限这样做.', 403);
            return false;
        }
        $type_list = [];
        $types = ExchangeType::find();
        foreach ($types as $val) {
            $type_list[$val->id] = $val->name;
        }
        $this->view->setVar('type_list', $type_list);
        if ($this->request->isPost()) {
            $code = $this->request->getPost('code');
            $type = $this->request->getPost('type');
            if ($code) {
                $condition = "code = '$code'";
            } else {
                $condition = "type = $type";
            }
            $ret = Exchangecode::find($condition);
            $this->view->setVar('code_ret', $ret);
        }
    }

    public function exportAction()
    {
        $export_type = $this->request->getPost('type_id');
        $num = $this->request->getPost('code_count');
        $e_lib = new Exchange();
        $new_codes = $e_lib->generateCode($num, $export_type);
        $resultPHPExcel = new PHPExcel();
        //设置参数
        $i = 1;
        foreach ($new_codes['ncodes'] as $val) {
            $resultPHPExcel->getActiveSheet()->setCellValueExplicit('A' . $i, $val['code'], PHPExcel_Cell_DataType::TYPE_STRING);
            $i++;
        }
        $resultPHPExcel->getActiveSheet()->getStyle("A1:A{$i}")->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_TEXT);
        //设置导出文件名
        $t_model = new ExchangeType();
        $type_info = $t_model->findFirst("id = $export_type");
        $type_name = $type_info->name;
        $date = date('Ymd');
        $outputFileName = "$type_name-$date.xls";
        $xlsWriter = new PHPExcel_Writer_Excel5($resultPHPExcel);
        //ob_start(); ob_flush();
        header("Content-Type: application/force-download");
        header("Content-Type: application/octet-stream");
        header("Content-Type: application/download");
        header('Content-Disposition:inline;filename="'.$outputFileName.'"');
        header("Content-Transfer-Encoding: binary");
        header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
        header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
        header("Cache-Control: must-revalidate, post-check=0, pre-check=0");
        header("Pragma: no-cache");
        $xlsWriter->save( "php://output" );
        exit(0);
    }

    public function addTypeAction()
    {
        $item_list = Item::$ITEM_ID_LIST;
        $this->view->setVar('item_list', $item_list);
        if ($this->request->isPost()) {
            $name = $this->request->getPost('name');
            $items = $this->request->getPost('items');
            $start_date = $this->request->getPost('start_date');
            $end_date = $this->request->getPost('end_date');
            $reuse = $this->request->getPost('reuse'); // 使用后失效或者可多次使用
            $channel_id = $this->request->getPost('channel_id');
            foreach ($items as & $val) {
                if (! isset ($val['sub_id'])) {
                    $val['sub_id'] = 1;
                }
            }
            $items = json_encode(array_values($items), JSON_NUMERIC_CHECK);
            $etype = new ExchangeType();
            $etype->name = strval($name);
            $etype->items = $items;
            $etype->start_date = $start_date;
            $etype->end_date = $end_date;
            $etype->reuse = $reuse;
            $etype->channel_id = $channel_id;
            $ret = $etype->create();
            if ($ret) {
                $this->response->redirect('/exchange/typeList');
            } else {
                $notice = '';
                foreach ($etype->getMessages() as $message) {
                    $notice .=  $message . "<br />";
                }
                $this->setNotice($notice, 500);
                return false;
            }
        }
    }

    public function editTypeAction()
    {
        $item_list = Item::$ITEM_ID_LIST;
        $this->view->setVar('item_list', $item_list);
        $type_id = $this->request->getQuery('type_id');
        $e_type = new ExchangeType();
        $ret = $e_type->findFirst("id = $type_id");
        $this->view->setVar('curr_type', $ret);
        $this->view->setVar('type_id', $type_id);
        if ($this->request->isPost()) {
            $name = $this->request->getPost('name');
            $items = $this->request->getPost('items');
            $start_date = $this->request->getPost('start_date');
            $end_date = $this->request->getPost('end_date');
            $reuse = $this->request->getPost('reuse'); // 使用后失效或者可多次使用
            $channel_id = $this->request->getPost('channel_id');
            foreach ($items as & $val) {
                if (! isset ($val['sub_id'])) {
                    $val['sub_id'] = 1;
                }
            }
            $items = json_encode(array_values($items), JSON_NUMERIC_CHECK);
            $e_type->id = $type_id;
            $e_type->name = strval($name);
            $e_type->items = $items;
            $e_type->start_date = $start_date;
            $e_type->end_date = $end_date;
            $e_type->reuse = $reuse;
            $e_type->channel_id = $channel_id;
            $ret = $e_type->save();
            if ($ret) {
                $this->response->redirect('/exchange/typeList');
            } else {
                $notice = '';
                foreach ($e_type->getMessages() as $message) {
                    $notice .=  $message . "<br />";
                }
                $this->setNotice($notice, 500);
                return false;
            }
        }
    }

    public function delTypeAction()
    {

    }

    public function typeListAction()
    {
        $e_types = ExchangeType::find()->toArray();
        foreach ($e_types as & $val) {
            $val['items'] = json_decode($val['items'], true);
        }
        $this->view->setVar('e_types', $e_types);
        $this->view->setVar('channel_conv', $this->channel_conv);
        $this->view->setVar('item_names', Item::$ITEM_ID_LIST);
        $this->view->setVar('sub_names', Item::$SUB_ID_LIST);
    }
}
