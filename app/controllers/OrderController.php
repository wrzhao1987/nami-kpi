<?php
/**
 * Created by PhpStorm.
 * User: martin
 * Date: 14-7-8
 * Time: 下午4:26
 */
class OrderController extends ControllerBase
{
    public static $BUDAN_QUEUE_KEY = 'nami:admin:budan:queue';
    //
    public function queryAction()
    {
        if (! $this->isAllowed()) {
            $this->setNotice('你没有权限这样做.', 403);
            return false;
        }
        $srv_lib  = new Server();
        $srv_list = $srv_lib->getServerList();
        $this->view->setVar('srv_list', $srv_list);
        // 添加source字段
        $src_list = $this->getSourceList();
        $this->view->setVar('src_list', $src_list);
        if ($this->request->isPost()) {
            $srv_id = $this->request->getPost('srv_id');
            $redis = $this->getDI()->get(Server::getDIName($srv_id, Server::$CONF_FIELD_REDIS));
            $order_id = $this->request->getPost('order_id');
            $user_id = $this->request->getPost('user_id');
            $source = $this->request->getPost('src_id');
            $thr_order_id = $this->request->getPost('thr_order');
            $start_date = $this->request->getPost('start_date');
            $end_date = $this->request->getPost('end_date');
            $tmp = [
                'order_id' => $order_id,
                'user_id' => $user_id,
                'source' => $source == -1 ? 0 : $source,
                'thr_order' => $thr_order_id,
            ];
            $cdt = [];
            foreach ($tmp as $field => $val) {
                if ($val) {
                   $cdt[] = "$field = '$val'";
                }
            }
            $cdt = implode(' AND ', $cdt);
            if ($start_date) {
                $cdt .= empty($cdt) ? "create_time >= '$start_date'" : " AND create_time >= '$start_date'";
            }
            if ($end_date) {
                $cdt .= empty($cdt) ? "create_time <= '$end_date'" : " AND create_time <= '$end_date'";
            }
            $o_model = $this->getModel('pay_order', $srv_id);
            $ret = $o_model->find($cdt)->toArray();
            foreach ($ret as &$dtl) {
				if (isset ($src_list[$dtl['source']])) {
					$dtl['src_name'] = $src_list[$dtl['source']];	
				} else {
					$dtl['src_name'] = '未知来源';
				}
                $dtl['user_name'] = $redis->hGet("role:{$dtl['user_id']}", 'name');
                $dtl['status_str'] = $this->convOrderStatusToString($dtl['status']);
            }
            $this->view->setVar('orders', $ret);
            $this->view->setVar('srv_id', $srv_id);
        }
    }

    // 补单方法
    public function budanAction()
    {
        if ($this->isAllowed()) {
            if ($this->request->isAjax()) {
                $srv_id = $this->request->getPost('srv_id');
                $order_id = $this->request->getPost('order_id');
                if ($srv_id && $order_id) {
                    $redis = $this->getDI()->get(Server::getDIName($srv_id, Server::$CONF_FIELD_REDIS));
                    $key = self::$BUDAN_QUEUE_KEY;
                    $redis->sAdd($key, $order_id);
                    echo json_encode(['code' => 0, 'msg' => '']);
                } else {
                    echo json_encode(['code' => 407, 'msg' => '参数不全']);
                }
            } else {
                echo json_encode(['code' => 400, 'msg' => '错误的请求方式.']);
            }
        } else {
            echo json_encode(['code' => 403, 'msg' => '你没有权限这样做.']);
        }
        $this->view->disable();
    }

    private function convOrderStatusToString($status) {
        switch ($status) {
            case 1:
                $val = '已创建';
                break;
            case 2:
                $val = '已回调';
                break;
            case 3:
                $val = '已完成';
                break;
            case 4:
                $val = '已取消';
                break;
            default:
                $val = '';
        }
        return $val;
    }
}
