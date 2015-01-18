<?php

class AdminController extends ControllerBase
{
    public function addAction()
    {
        if (! $this->isAllowed()) {
            $this->setNotice('你没有权限这样做.', 403);
            return false;
        }
        $this->view->setVar('roles', AdminAcl::$convert_view);
        if ($this->request->isPost()) {
            if ($this->security->checkToken()) {
                $name  = $this->request->getPost('name');
                $pwd_1 = $this->request->getPost('pwd_1');
                $pwd_2 = $this->request->getPost('pwd_2');
                $role  = $this->request->getPost('role');
                $note  = strval($this->request->getPost('note'));

                if (empty ($name) || empty($pwd_1) || empty($pwd_2)) {
                    $this->setNotice('信息输入不全，亲.', 400);
                    return false;
                }
                if ($pwd_1 != $pwd_2) {
                    $this->setNotice('两次输入密码不一致.', 400);
                    return false;
                }
                $user_model = new User();

                if ($user_model::findFirstByName($name)) {
                    $this->setNotice('用户名已经存在.', 400);
                    return false;
                }
                $date = date('Y-m-d H:i:s');
                $new_admin = [
                    'name'       => $name,
                    'pwd'        => $this->security->hash($pwd_1),
                    'role'       => intval($role),
                    'note'       => empty($note) ? new \Phalcon\Db\RawValue('default') : strval($note),
                    'active'     => 1,
                    'added_at'   => $date,
                ];
                $id = $user_model->create($new_admin);
                if ($id) {
                    $this->setNotice('添加管理员成功.');
                }
            } else {
                $this->setNotice('表单来源验证失败', 400);
                return false;
            }
        }
        return true;
    }

    public function modPwdAction()
    {
        if (! $this->isAllowed()) {
            $this->setNotice('你没有权限这样做.', 403);
            return false;
        }

        if ($this->request->isPost()) {
            $old_pwd = $this->request->getPost('old_pwd');
            $new_pwd_1 = $this->request->getPost('new_pwd_1');
            $new_pwd_2 = $this->request->getPost('new_pwd_2');
            if (empty ($old_pwd)) {
                $this->setNotice('你需要输入旧密码.', 400);
                return false;
            }
            if (empty ($new_pwd_1) || empty ($new_pwd_2)) {
                $this->setNotice('你需要输入新密码.', 400);
                return false;
            }
            if ($new_pwd_1 != $new_pwd_2) {
                $this->setNotice('新密码两次输入不一致.', 400);
                return false;
            }
            $user_model = new User();
            $user = $user_model::findFirstByName($this->session->get('name'));
            if ($user) {
                if ($this->security->checkHash($old_pwd, $user->pwd)) {
                    $new_pwd = $this->security->hash($new_pwd_1);
                    $user->pwd = $new_pwd;
                    $user->note = new \Phalcon\Db\RawValue('default');
                    $ret = $user->save();
                    if ($ret) {
                        $this->setNotice('修改密码成功，请牢记.');
                        return true;
                    } else {
                        $this->setNotice('出错啦.', 500);
                        return false;
                    }
                } else {
                    $this->setNotice('原密码验证失败.', 400);
                    return false;
                }
            } else {
                $this->setNotice('用户不存在或者尚未登录.', 500);
                return false;
            }
        }
        return true;
    }

    public function manageAction()
    {
        if (! $this->isAllowed()) {
            $this->setNotice('你没有权限这样做', 403);
            return false;
        }
        $admins = User::find();
        $this->view->setVar('admins', $admins);
        $this->view->setVar('roles_view', AdminAcl::$convert_view);
        return true;
    }

    public function editAction()
    {
        if (! $this->isAllowed()) {
            $this->setNotice('你没有权限这样做', 403);
            return false;
        }

        if ($this->request->isPost()) {
            if ($this->security->checkToken()) {
                $uid = $this->request->getPost('uid');
                $role = $this->request->getPost('role');
                $active = $this->request->getPost('active');
                $note = $this->request->getPost('note');
                if (! $uid) {
                    $this->setNotice('UID没有传.', 400);
                    return false;
                }
                $user = User::findFirstById($uid);
                if (! $user) {
                    $this->setNotice('用户不存在', 500);
                    return false;
                }
                $user->role = $role;
                $user->active = $active;
                $user->note = $note;
                $ret = $user->update();
                if ($ret) {
                    $this->response->redirect('/admin/manage');
                } else {
                    var_dump($user->getMessages());
                    return false;
                }
            } else {
                $this->setNotice('表单来源验证失败', 400);
            }
        } else {
            $uid = $this->request->getQuery('uid');
            $user = User::findFirstById($uid);
            if (! $user) {
                $this->setNotice('用户不存在', 500);
                return false;
            } else if ($user->role <= $this->session->get('role')) {
                $this->setNotice('你没有权力更改此用户的信息.');
                return false;
            }
            $roles = AdminAcl::$convert_view;
            foreach ($roles as $role_id => $role_name) {
                if ($role_id <= $this->session->get('role')) {
                    unset ($roles[$role_id]);
                }
            }
            $this->view->setVar('roles', $roles);
            $this->view->setVar('edit_user', $user);
        }
        return true;
    }
}