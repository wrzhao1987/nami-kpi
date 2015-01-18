<?php
/**
 * Created by PhpStorm.
 * User: martin
 * Date: 14-7-15
 * Time: 下午8:11
 */
class InfoController extends ControllerBase
{
    public static $CACHE_KEY_USER         = 'role:%s';
    public static $CACHE_KEY_CARDS        = 'nami:cards:%s';
    public static $CACHE_KEY_SOULS        = 'nami:souls:%s';
    public static $CACHE_KEY_DECK         = 'nami:deck:%s';
    public static $CACHE_KEY_EQUIPS       = 'nami:equips:%s';
    public static $CACHE_KEY_BALLS        = 'nami:balls:%s';
    public static $CACHE_KEY_EQUIP_PIECES = 'nami:epieces:%s';
    public static $CACHE_KEY_DBALL_PIECES = 'nami:ballfrags:%s';
    public static $CACHE_KEY_BLACKLIST    = 'nami:%s:blklst';


    public function overviewAction()
    {
        if (! $this->isAllowed()) {
            $this->setNotice('你没有权限这样做.', 403);
            return false;
        }
        $srv_lib   = new Server();
        $srv_list  = $srv_lib->getServerList();
        $this->view->setVar('srv_list', $srv_list);
        $this->view->setVar('items', Item::$SUB_ID_LIST);
        if ($this->request->isPost()) {
            if ($this->security->checkToken()) {
                $srv_id = $this->request->getPost('srv_id');
                $username = $this->request->getPost('user');
                $user_model = $this->getModel('server_user', $srv_id);
                $user = $user_model::findFirst("name='{$username}'");
                if ($user) {
                    $uid = $user->id;
                    $redis = $this->getDI()->get(Server::getDIName($srv_id, Server::$CONF_FIELD_REDIS));
                    $user_cache_key = sprintf(self::$CACHE_KEY_USER,  $uid);
                    $card_cache_key = sprintf(self::$CACHE_KEY_CARDS, $uid);
                    $soul_cache_key = sprintf(self::$CACHE_KEY_SOULS, $uid);
                    $deck_cache_key = sprintf(self::$CACHE_KEY_DECK,  $uid);
                    $equip_cache_key = sprintf(self::$CACHE_KEY_EQUIPS, $uid);
                    $dball_cache_key = sprintf(self::$CACHE_KEY_BALLS, $uid);
                    $epieces_cache_key = sprintf(self::$CACHE_KEY_EQUIP_PIECES, $uid);
                    $dpieces_cache_key = sprintf(self::$CACHE_KEY_DBALL_PIECES, $uid);

                    $user_info = $redis->hGetAll($user_cache_key);
                    $cards     = $redis->hGetAll($card_cache_key);
                    $souls     = $redis->hGetAll($soul_cache_key);
                    $equips    = $redis->hGetAll($equip_cache_key);
                    $dballs    = $redis->hGetAll($dball_cache_key);
                    $epieces   = $redis->hGetAll($epieces_cache_key);
                    $dpieces   = $redis->hGetAll($dpieces_cache_key);
                    $deck      = $redis->hGetAll($deck_cache_key);

                    $this->view->setVar('uid', $uid);
                    $this->view->setVar('srv_id', $srv_id);
                    $this->view->setVar('user_info', $user_info);
                    $this->view->setVar('cards', $cards);
                    $deck = $this->formatDeckInfo($deck);
                    // 装配卡组信息
                    unset ($deck[7]);
                    foreach ($deck as & $detail) {
                        if ($detail['card'] != 0) {
                            $detail['card'] = json_decode($cards[$detail['card']], true);
                        }
                        foreach ($detail['dball'] as $ball_pos => $uball_id) {
                            if ($uball_id != 0) {
                                $detail['dball'][$ball_pos] = json_decode($dballs[$uball_id], true);
                            }
                        }
                        foreach ($detail['equip'] as $equip_pos => $uequip_id) {
                            if ($uequip_id != 0) {
                                $detail['equip'][$equip_pos] = json_decode($equips[$uequip_id], true);
                            }
                        }
                    }
                    $decode = function (& $v) {
                      $v = json_decode($v, true);
                    };
                    // 装配龙珠、装备信息
                    array_walk($dballs, $decode);
                    array_walk($equips, $decode);
                    $this->view->setVar('uid', $uid);
                    $this->view->setVar('srv_id', $srv_id);
                    $this->view->setVar('deck', $deck);
                    $this->view->setVar('dballs', $dballs);
                    $this->view->setVar('equips', $equips);
                    $this->view->setVar('souls', $souls);
                    $this->view->setVar('dpieces', $dpieces);
                    $this->view->setVar('epieces', $epieces);

                    // 判断用户是否在服务器登录黑名单中
                    $key_blacklist = sprintf(self::$CACHE_KEY_BLACKLIST, 'user');
                    $is_black = $redis->sIsMember($key_blacklist, $uid);
                    $this->view->setVar('is_black', $is_black);
                } else {
                    $this->setNotice('没有找到该用户', 500);
                }
            }
        }
    }

    public function forbidAction()
    {
        if (! $this->isAllowed()) {
            $this->setNotice('你没有权限这样做.', 403);
            return false;
        }
        if ($this->isAllowed()) {
            if ($this->request->isAjax()) {
                $uid = $this->request->getPost('id');
                $srv_id = $this->request->getPost('srv_id');
                $type = $this->request->getPost('forbidden_type');
                syslog(LOG_INFO, "forbid uid:$uid, $type in server $srv_id");
                if ($srv_id && (new Server())->isValidServerID($srv_id)) {
                    $redis = $this->getDI()->get(Server::getDIName($srv_id, Server::$CONF_FIELD_REDIS));
                    $key_blacklist = sprintf(self::$CACHE_KEY_BLACKLIST, $type);
                    syslog(LOG_INFO, "forbid uid key $key_blacklist");
                    $redis->sAdd($key_blacklist, $uid);
                    echo json_encode(['code' => 0, 'msg' => '']);
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

    public function unforbidAction()
    {
        if (! $this->isAllowed()) {
            $this->setNotice('你没有权限这样做.', 403);
            return false;
        }
        if ($this->isAllowed()) {
            if ($this->request->isAjax()) {
                $uid = $this->request->getPost('id');
                $srv_id = $this->request->getPost('srv_id');
                $type = $this->request->getPost('forbidden_type');
                if ($srv_id && (new Server())->isValidServerID($srv_id)) {
                    $redis = $this->getDI()->get(Server::getDIName($srv_id, Server::$CONF_FIELD_REDIS));
                    $key_blacklist = sprintf(self::$CACHE_KEY_BLACKLIST, $type);
                    $redis->sRem($key_blacklist, $uid);
                    echo json_encode(['code' => 0, 'msg' => '']);
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

    private function formatDeckInfo($deck)
    {
        $deck_info = [];
        foreach ($deck as $key => $value) {
            $tmp = explode(':', $key);
            switch ($tmp[0]) {
                case 'card':
                    $deck_info[$tmp[1]]['card'] = $value;
                    break;
                case 'dball':
                    $deck_info[$tmp[1]]['dball'][$tmp[2]] = $value;
                    break;
                case 'equip':
                    $deck_info[$tmp[1]]['equip'][$tmp[2]] = $value;
                    break;
                case 'pvepos':
                    $deck_info[$tmp[1]]['pvepos'] = $value;
                    break;
                case 'pvppos':
                    $deck_info[$tmp[1]]['pvppos'] = $value;
                    break;
                default:
            }
        }
        return $deck_info;
    }
}
