<?php

class ServerController extends ControllerBase {

    private $remote_config_path = "/root/servers.ini";
    private $remote_host = "120.132.61.34";
    private $remote_ssh_user = "root";
    private $remote_ssh_passwd = "F0ll0w@opq%%";
    private $local_path = "/tmp/servers.ini";

    public static function write_ini_file($assoc_arr, $path, $has_sections=FALSE) {
        $content = "";
        if ($has_sections) {
            foreach ($assoc_arr as $key=>$elem) {
                $content .= "[".$key."]\n";
                foreach ($elem as $key2=>$elem2) {
                    if(is_array($elem2)) {
                        for($i=0;$i<count($elem2);$i++) {
                            $content .= $key2."[]=".$elem2[$i]."\n";
                        }
                    }
                    else if($elem2=="") $content .= $key2."=\n";
                    else if(is_int($elem2)){
                        $content .= $key2."=".$elem2."\n";
                    }
                    else $content .= $key2."=".$elem2."\n";
                }
            }
        } else {
            foreach ($assoc_arr as $key2=>$elem) {
                if(is_array($elem)) {
                    for($i=0;$i<count($elem);$i++) {
                        $content .= $key2."[]=\"".$elem[$i]."\"\n";
                    }
                }
                else if($elem=="") $content .= $key2."=\n";
                else $content .= $key2."=\"".$elem."\"\n";
            }
        }
        if (!$handle = fopen($path, 'w')) {
            return false;
        }
        if (!fwrite($handle, $content)) {
            return false;
        }
        fclose($handle);
        return true;
    }

    public function manageAction() {
        //$cfg = new \Phalcon\Config\Adapter\Ini('/home/zcc/nami/config/servers.ini');
        if (($r=$this->getRemoteConfig())!==true) {
            syslog(LOG_INFO, "server config manage: fail to get remote config:$r");
            $this->view->disable();
            echo "远程服务器配置读取失败";
            return false;
        }

        $cfg = new \Phalcon\Config\Adapter\Ini($this->local_path);
        $servers_str = $cfg['global']['game_servers'];
        $server_keys = explode(",", $servers_str);
        $this->view->setVar('servers', $cfg);
        $this->view->setVar('server_keys', $server_keys);
    }

    public function writeAction() {
        if (($r=$this->getRemoteConfig())!==true) {
            syslog(LOG_INFO, "server config manage: fail to get remote config:$r");
            $this->view->disable();
            echo "远程服务器配置读取失败";
            return false;
        }
        $old_cfg = new \Phalcon\Config\Adapter\Ini($this->local_path);
        $new_cfg = $this->request->get('config');
        syslog(LOG_INFO, "write new cfg:".json_encode($new_cfg));
        // merge new_cfg to old_cfg
        $cfg = $old_cfg;
        foreach ($new_cfg as $k=>$v) {
           foreach ($v as $kk=>$vv) {
               if (!$vv) {
                   unset($cfg[$k][$kk]); // remove empty
               } else {
                   $cfg[$k][$kk] = $vv; // modify the old cfg
               }
           }
        }
        /*
        $tmp = json_encode($cfg, JSON_NUMERIC_CHECK);
        $cfg = json_decode($tmp, true);
         */
        self::write_ini_file($cfg, $this->local_path, true);
        // push to remote server
        if (($r=$this->pushRemoteConfig())!==true) {
            syslog(LOG_INFO, "server config manage: fail to push remote config:$r");
            echo json_encode(array('code'=>200, 'msg'=>'服务器配置保存失败'));
        } else {
            syslog(LOG_INFO, "server config manage: push remote config success:$r");
            echo json_encode(array('code'=>200, 'msg'=>'服务器配置已保存'));
        }
    }

    function getRemoteConfig() {
        $sess = ssh2_connect($this->remote_host);
        if (!$sess) {
            return "fail to connect server";
        }
        if (ssh2_auth_password($sess, $this->remote_ssh_user, $this->remote_ssh_passwd)) {
            $fr = ssh2_scp_recv($sess, $this->remote_config_path, $this->local_path);
            if ($fr) {
                return true;
            } else {
                return "fail to get remote file";
            }
        } else {
            return "authenticated failed";
        }
    }

    function pushRemoteConfig() {
        $sess = ssh2_connect($this->remote_host);
        if (!$sess) {
            return "fail to connect server";
        }
        if (ssh2_auth_password($sess, $this->remote_ssh_user, $this->remote_ssh_passwd)) {
            $fr = ssh2_scp_send($sess, $this->local_path, $this->remote_config_path);
            if ($fr) {
                return true;
            } else {
                return "fail to get remote file";
            }
        } else {
            return "authenticated failed";
        }
    }
}
