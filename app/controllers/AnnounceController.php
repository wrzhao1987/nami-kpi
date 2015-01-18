<?php

class AnnounceController extends ControllerBase
{
    public function addAction()
    {
        if (! $this->isAllowed()) {
            $this->setNotice('你没有权限这样做.', 403);
            return false;
        }
        $server_list = (new Server())->getServerList();
        $this->view->setVar('server_list', $server_list);
        if ($this->request->isPost()) {
            if ($this->security->checkToken()) {
                $server     = $this->request->getPost('server');
                $title      = $this->request->getPost('title');
                $content    = $this->request->getPost('content');
                $weight     = $this->request->getPost('weight');
                $start_date = $this->request->getPost('start_date');
                $start_time = $this->request->getPost('start_time');
                $end_date   = $this->request->getPost('end_date');
                $end_time   = $this->request->getPost('end_time');

                if (! ($server && $title && $content && $start_date && $start_time && $end_date && $end_time)) {
                    $this->setNotice('输入信息不完全.', 400);
                    return false;
                }
                $start = $start_date . ' ' . $start_time;
                $end   = $end_date   . ' ' . $end_time;
                $ret = [];
                foreach ($server as $server_id) {
                    $anc_model = $this->getModel('announce', $server_id);
                    $suc = $anc_model->create([
                        'title'   => $title,
                        'content' => $content,
                        'weight'  => $weight,
                        'start'   => $start,
                        'end'     => $end,
                    ]);
                    $ret[$server_list[$server_id]] = $suc ? "成功" : "失败";
                    unset ($anc_model);
                }
                $this->setNotice(json_encode($ret, JSON_UNESCAPED_UNICODE));
            } else {
                $this->setNotice('表单来源验证失败', 400);
                return false;
            }
        }
        return true;
    }

    public function editAction()
    {
        if (! $this->isAllowed()) {
            $this->setNotice('你没有权限这样做.', 403);
            return false;
        }
        if ($this->request->isGet()) {
            $id = $this->request->getQuery('id');
            $srv_id = $this->request->getQuery('srv_id');
            $anc_model = $this->getModel('announce', $srv_id);
            $post = $anc_model::findFirstById($id);
            if ($post) {
                list($post->start_date, $post->start_time) = explode(' ', $post->start);
                list($post->end_date, $post->end_time) = explode(' ', $post->end);
                $this->view->setVar('post', $post);
                $this->view->setVar('server_id', $srv_id);
            } else {
                $this->setNotice('没有找到此条公告记录', 500);
                return false;
            }
        } else if ($this->request->isPost()) {
            if ($this->security->checkToken()) {
                $id = $this->request->getPost('id');
                $srv_id = $this->request->getPost('srv_id');
                $title = $this->request->getPost('title');
                $content = $this->request->getPost('content');
                $weight = $this->request->getPost('weight');
                $start_date = $this->request->getPost('start_date');
                $start_time = $this->request->getPost('start_time');
                $end_date = $this->request->getPost('end_date');
                $end_time = $this->request->getPost('end_time');

                $start = $start_date . ' ' . $start_time;
                $end   = $end_date . ' ' . $end_time;

                $anc_model = $this->getModel('announce', $srv_id);
                $post = $anc_model::findFirstById($id);
                $post->title = $title;
                $post->content = $content;
                $post->weight = $weight;
                $post->start = $start;
                $post->end = $end;
                $ret = $post->update();
                if ($ret) {
                    $this->response->redirect('/announce/manage?srv_id=' . $srv_id);
                } else {
                    $this->setNotice('更新失败.', 500);
                }
            } else {
                $this->setNotice('表单来源验证失败.', 400);
                return false;
            }
        }
        return true;
    }

    public function manageAction()
    {
        if (! $this->isAllowed()) {
            $this->setNotice('你没有权限这样做.', 403);
            return false;
        }
        $server_list = (new Server())->getServerList();
        $this->view->setVar('server_list', $server_list);

        $server_id = 0;
        if ($this->request->isPost()) {
            if ($this->security->checkToken()) {
                $server_id = $this->request->getPost('server');
            } else {
                $this->setNotice('表单来源验证失败', 400);
                return false;
            }
        } else if ($this->request->isGet()) {
            $server_id = $this->request->getQuery('srv_id');
        }
        if ($server_id && (new Server())->isValidServerID($server_id)) {
            $anc_model = $this->getModel('announce', $server_id);
            $posts = $anc_model::find();
            $this->view->setVar('posts', $posts);
            $this->view->setVar('srv_id', $server_id);
        }
        return true;
    }

    public function delAction()
    {
        if ($this->isAllowed()) {
            if ($this->request->isAjax()) {
                $post_id = $this->request->getPost('id');
                $srv_id = $this->request->getPost('srv_id');
                if ($srv_id && (new Server())->isValidServerID($srv_id)) {
                    $anc_model = $this->getModel('announce', $srv_id);
                    $post = $anc_model::findFirst("id=$post_id");
                    if ($post) {
                        $ret = $post->delete();
                        if ($ret) {
                            echo json_encode(['code' => 0, 'msg' => '']);
                        } else {
                            echo json_encode(['code' => 500, 'msg' => '服务器错误.']);
                        }
                    } else {
                        echo json_encode(['code' => 500, 'msg' => '没有找到该条公告记录.']);
                    }
                } else {
                    echo json_encode(['code' => 400, 'msg' => 'ServerID无效.']);
                }
            } else {
                echo json_encode(['code' => 400, 'msg' => '错误的请求方式.']);
            }
        } else {
            echo json_encode(['code' => 403, 'msg' => '你没有权限这样做.']);
        }
        $this->view->disable();
    }
}