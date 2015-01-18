<?php

class SessionController extends ControllerBase
{
    public function loginAction()
    {
        if ($this->request->isPost()) {
            $name = $this->request->getPost('name');
            $password  = $this->request->getPost('password');
            $user = User::findFirstByName($name);
            if ($user) {
                if ($this->security->checkHash($password, $user->pwd)) {
                    $this->session->set('uid',  $user->id);
                    $this->session->set('name', $user->name);
                    $this->session->set('role', $user->role);
                    $this->session->set('active', $user->active);
                    // TODO 记登录日志
                    echo json_encode(['code' => 0, 'msg' => 'OK'], JSON_NUMERIC_CHECK);
                } else {
                    echo json_encode(['code' => 402, 'msg' => '密码检查失败.']);
                }
            } else {
                echo json_encode(['code' => 402, 'msg' => '用户不存在.']);
            }
        }
        $this->view->disable();
    }

    public function logoutAction()
    {
        $destroyed = $this->session->destroy();
        $code = $destroyed ? 0 : 500;
        echo json_encode(['code' => $code, 'msg' => '']);
        $this->view->disable();
    }
}