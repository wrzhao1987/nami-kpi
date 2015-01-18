<?php
use Phalcon\Mvc\Controller;

class ControllerBase extends Controller
{
    protected function onConstruct()
    {
        $this->view->uid    = $this->session->get('uid');
        $this->view->name   = $this->session->get('name');
        $this->view->role   = $this->session->get('role');
        $this->view->active = $this->session->get('active');
        $this->view->notice = ['code' => 0, 'msg' => ''];
    }

    protected function isAllowed()
    {
        if (! $this->session->get('active')) {
            return \Phalcon\Acl::DENY;
        }
        $acl        = new AdminAcl();
        $controller = strtolower($this->dispatcher->getControllerName());
        $action     = strtolower($this->dispatcher->getActionName());
        $role       = $acl::roleToString($this->session->get('role'));
        $allowed    = $acl->isAllowed($role, $controller, $action);
        return $allowed;
    }

    protected function setNotice($msg, $code = 0)
    {
        $this->view->setVar('notice', [
            'code' => intval($code),
            'msg'  => strval($msg),
        ]);
    }

    protected function getModel($model_name, $server_id = null) {
        $instance = null;
        $this->getDI()->set('server_id', function () use ($server_id) {
            return $server_id;
        });
        switch ($model_name) {
            case 'announce':
                $instance = new Announce();
                break;
            case 'server_user':
                $instance = new ServerUser();
                break;
            case 'kpi':
                $instance = new Kpi();
                break;
            case 'pay_order':
                $instance = new PayOrder();
                break;
            default:
        }
        return $instance;
    }

    protected function getSourceList($grp_id = null)
    {
        $ret = [];
        $source_list = require_once __DIR__ . '/../config/sdk_source.php';
        $ret[-1] = '全部';
        if (isset ($grp_id)) {
            $source_list = $source_list[$grp_id];
        }
        foreach ($source_list as $src_id => $dtl) {
            $ret[$src_id] = $dtl['name'];
        }
        return $ret;
    }
}
