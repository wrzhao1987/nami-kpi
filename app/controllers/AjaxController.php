<?php
/**
 * Created by PhpStorm.
 * User: martin
 * Date: 14-7-10
 * Time: 下午5:46
 */
class AjaxController extends ControllerBase
{
    public function itemSubAction()
    {
        $result = [];
        $item_id = $this->request->get('item_id');
        if (isset (Item::$SUB_ID_LIST[$item_id])) {
            foreach (Item::$SUB_ID_LIST[$item_id] as $sub_id => $name) {
                $result[$sub_id] = '[' . $sub_id . ']' . $name;
            }
            echo json_encode($result, JSON_NUMERIC_CHECK);
        }
        $this->view->disable();
    }

    public function usernameAction()
    {
        $srv_id = $this->request->get('srv_id');
        $srv_user_model = $this->getModel('server_user', $srv_id);
        $users = $srv_user_model::find()->toArray();
        $names = array_column($users, 'name');
        echo json_encode($names, JSON_NUMERIC_CHECK);
        $this->view->disable();
    }
}