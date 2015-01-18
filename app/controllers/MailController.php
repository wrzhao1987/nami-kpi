<?php
/**
 * Created by PhpStorm.
 * User: martin
 * Date: 14-7-8
 * Time: 下午4:26
 */
class MailController extends ControllerBase
{
    public static $MAIL_QUEUE_KEY = 'nami:admin:mail:queue';

    public function sendAction()
    {
        if (! $this->isAllowed()) {
            $this->setNotice('你没有权限这样做.', 403);
            return false;
        }
        $srv_lib   = new Server();
        $srv_list  = $srv_lib->getServerList();
        $item_list = Item::$ITEM_ID_LIST;
        $this->view->setVar('srv_list', $srv_list);
        $this->view->setVar('item_list', $item_list);

        if ($this->request->isPost()) {
            if ($this->security->checkToken()) {
                $mail = [];
                $srv_id = $this->request->getPost('srv_id');
                $to_all_user = $this->request->getPost('to-all-user');
                if (! $to_all_user) {
                    $users = $this->request->getPost('users');
                    $users = array_map('trim', explode(',', trim($users)));
                    $users = array_filter($users);
                } else {
                    $users = -1;
                }
                $mail['users'] = $users;
                $mail['title'] = $this->request->getPost('title');
                $mail['content'] = $this->request->getPost('content');

                $attach = $this->request->getPost('attach');
                if (is_array($attach)) {
                    foreach ($attach as $item) {
                        if ($item['item_id'] && $item['count']) {
                            $item['sub_id'] = isset ($item['sub_id']) ? $item['sub_id'] : 1;
                            $mail['attach'][] = $item;
                        }
                    }
                }
                $redis = $this->getDI()->get(Server::getDIName($srv_id, Server::$CONF_FIELD_REDIS));
                $ret = $redis->rPush(self::$MAIL_QUEUE_KEY, json_encode($mail));
                if ($ret) {
                    ((new MailLog())->create([
                        'username' => $this->session->get('name'),
                        'title' => $mail['title'],
                        'content' => $mail['content'],
                        'server_id' => $srv_id,
                        'to_users' => $mail['users'] == -1 ? 'NAMI-ALL' : json_encode($mail['users']),
                        'attachment' => isset ($mail['attach']) ? json_encode($mail['attach']) : new \Phalcon\Db\RawValue('default') ,
                        'added_at' => date('Y-m-d H:i:s'),
                    ]));
                    $this->setNotice('邮件发送成功，根据系统状况可能会有5分钟左右延迟，请知晓.');
                }
            } else {
                $this->setNotice('表单来源验证失败', 400);
                return false;
            }
        }
        return true;
    }

    public function logAction()
    {
        if (! $this->isAllowed()) {
            $this->setNotice('你没有权限这样做.', 403);
            return false;
        }
        $logs = MailLog::find();
        if ($logs->count()) {
            $logs = $logs->toArray();
            foreach ($logs as & $item) {
                $item['to_users'] = $item['to_users'] != 'NAMI-ALL' ? json_decode($item['to_users'], true) : 'NAMI-ALL';
                $item['attachment'] = empty($item['attachment']) ? [] : json_decode($item['attachment'], true);
            }
            $this->view->setVar('logs', $logs);
        }
        $this->view->setVar('item_names', Item::$ITEM_ID_LIST);
        $this->view->setVar('sub_names', Item::$SUB_ID_LIST);
        return true;
    }
}