<?php
/**
 * Created by PhpStorm.
 * User: martin
 * Date: 14-9-30
 * Time: 下午4:06
 */
class KpiController extends ControllerBase
{
    public function levelAction()
    {
        if (! $this->isAllowed()) {
            $this->setNotice('你没有权限这样做.', 403);
            return false;
        }
        $server_list = (new Server())->getServerList();
        $this->view->setVar('srv_list', $server_list);
        // 添加source字段
        $src_list = $this->getSourceList();
        $this->view->setVar('src_list', $src_list);
        if ($this->request->isPost()) {
            $server_id = $this->request->getPost('srv_id');
            $date = $this->request->getPost('date');
            if (empty ($date)) {
                $date = date('Ymd');
            }
            $src_id = $this->request->getPost('src_id');
            $pie_data = [];
            $pie_data_new = [];
            $kpi_model = $this->getModel('kpi', $server_id);
            $map = $kpi_model->findFirst("date = $date and type = 101");
            if ($map->count() > 0) {
                $map = $map->toArray();
                $data = json_decode($map['data'], true);
                $total_data = $data['total'];
                $today_data = $data['today'];
                if ($src_id == -1) {
                    $total_data = $total_data[0];
                    $today_data = $today_data[0];
                } else {
                    $total_data = $total_data[$src_id];
                    $today_data = $today_data[$src_id];
                }
                // 全体饼图
                $total_user_num = array_sum($total_data);
                foreach ($total_data as $level => $user_num) {
                    $ratio = $user_num / $total_user_num * 100;
                    $pie_data[] = [strval($level), $ratio];
                }
                $pie_data = json_encode($pie_data);
                $this->view->setVar('pie_data', $pie_data);

                // 今日饼图
                $total_user_num = array_sum($today_data);
                foreach ($today_data as $level => $user_num) {
                    $ratio = $user_num / $total_user_num * 100;
                    $pie_data_new[] = [strval($level), $ratio];
                }
                $pie_data_new = json_encode($pie_data_new);
                $this->view->setVar('pie_data_new', $pie_data_new);

                // 全体柱状图
                $column_values = [
                    [
                        'name' => '用户人数',
                        'data' => array_values($total_data),
                    ],
                ];
                $this->view->setVar('column_keys', json_encode(array_keys($total_data)));
                $this->view->setVar('column_values', json_encode($column_values));
                // 今日柱状图
                $column_values = [
                    [
                        'name' => '用户人数',
                        'data' => array_values($today_data),
                    ],
                ];
                $this->view->setVar('column_keys_new', json_encode(array_keys($today_data)));
                $this->view->setVar('column_values_new', json_encode($column_values));
            }
        }
    }

    public function newbieAction()
    {
        if (! $this->isAllowed()) {
            $this->setNotice('你没有权限这样做.', 403);
            return false;
        }
        $server_list = (new Server())->getServerList();
        $this->view->setVar('srv_list', $server_list);
        // 添加source字段
        $src_list = $this->getSourceList();
        $this->view->setVar('src_list', $src_list);
        if ($this->request->isPost()) {
            $total_rate = []; // 总体通过率，按照日期划分
            $step_rate = []; // 分步骤通过率，先按日期，再按步骤
            $step_num = []; // 分步骤人数统计，先按日期，再按步骤
            $srv_id = $this->request->getPost('srv_id');
            $src_id = $this->request->getPost('src_id');
            $start_date = $this->request->getPost('start_date');
            $end_date = $this->request->getPost('end_date');
            $kpi_model = $this->getModel('kpi', $srv_id);
            $map = $kpi_model->find("date >= $start_date and date <= $end_date and type = 102")->toArray();
            $map = array_column($map, 'data', 'date');
            $cplt_step = 21;
            foreach ($map as $date => $data) {
                $data = json_decode($data, true);
                if ($src_id == -1) {
                    $data = $data[0];
                } else {
                    $data = $data[$src_id];
                }
                $total_num = array_sum($data);
                $steps = array_keys($data);
                // $cplt_step = max($steps);
                // 计算完成开放式引导之前的总人数
                $cplt_num = 0;
                for ($i = $cplt_step; $i >= 11; $i--) {
                    if (isset ($data[$i])) {
                        $cplt_num += $data[$i];
                    }
                }
                // 计算当天的新手引导通过率
                $total_rate[$date] = number_format($cplt_num / $total_num * 100, 2);
                // 计算每一步的通过人数和通过率
                for ($i = 1; $i <= $cplt_step; $i++) {
                    $this_step = 0; // 完成本步的人数
                    for ($j = $i; $j <= $cplt_step; $j++) {
                        $this_step += isset($data[$j]) ? $data[$j] : 0;
                    }
                    // 完成上一步的人
                    $last_step = $this_step;
                    $last_step += isset ($data[$i - 1]) ? $data[$i - 1] : 0;
                    // 本步的通过率写入
                    if (0 == $last_step) {
                        $rate = 0;
                    } else {
                        $rate = number_format($this_step / $last_step * 100, 2);
                    }
                    $step_rate[$date][$i] = $rate;
                    // 本步的通过人数写入
                    $step_num[$date][$i] = $this_step;
                }
            }
            // 展示数据装载
            $total_rate_keys = array_keys($total_rate);
            $total_rate_values = [
                [
                    'name' => '封闭引导总通过率',
                    'data' => array_values($total_rate),
                ]
            ];
            $this->view->setVar('total_rate_keys', json_encode($total_rate_keys));
            $this->view->setVar('total_rate_values', json_encode($total_rate_values, JSON_NUMERIC_CHECK));

            $step_rate_keys = range(1, $cplt_step);
            $step_rate_values = [];
            foreach ($step_rate as $date => $detail) {
                $step_rate_values[] = [
                    'name' => strval($date),
                    'data' => array_values($detail),
                ];
            }
            $this->view->setVar('step_rate_keys', json_encode($step_rate_keys));
            $this->view->setVar('step_rate_values', json_encode($step_rate_values, JSON_NUMERIC_CHECK));

            $step_num_keys = range(1, $cplt_step);
            $step_num_values = [];
            foreach ($step_num as $date => $detail) {
                $step_num_values[] = [
                    'name' => strval($date),
                    'data' => array_values($detail),
                ];
            }
            $this->view->setVar('step_num_keys', json_encode($step_num_keys));
            $this->view->setVar('step_num_values', json_encode($step_num_values, JSON_NUMERIC_CHECK));
        }
    }

    public function newUserAction()
    {
        if (! $this->isAllowed()) {
            $this->setNotice('你没有权限这样做.', 403);
            return false;
        }
        $server_list = (new Server())->getServerList();
        $this->view->setVar('srv_list', $server_list);
        // 添加source字段
        $src_list = $this->getSourceList();
        $this->view->setVar('src_list', $src_list);
        if ($this->request->isPost()) {
            $srv_id = $this->request->getPost('srv_id');
            $src_id = $this->request->getPost('src_id');
            $start_date = $this->request->getPost('start_date');
            $end_date = $this->request->getPost('end_date');
            $kpi_model = $this->getModel('kpi', $srv_id);
            $counts = $kpi_model->find("type = 103 and date >= $start_date and date <= $end_date")->toArray();
            $counts = array_column($counts, 'data', 'date');
            ksort($counts);
            $idx = $src_id == -1 ? 0 : $src_id;
            foreach ($counts as $date => & $val) {
				$val = substr($val, 1, -1);
				$val = stripslashes($val);
                $val = json_decode($val, true);
                $val = $val[$idx];
            }
            $column_values = [
                [
                    'name' => '日增新用户数',
                    'data' => array_values($counts),
                ]
            ];
            $this->view->setVar('column_keys', json_encode(array_keys($counts)));
            $this->view->setVar('column_values', json_encode($column_values, JSON_NUMERIC_CHECK));
        }
    }

    public function stayUserAction()
    {
        if (! $this->isAllowed()) {
            $this->setNotice('你没有权限这样做.', 403);
            return false;
        }
        $server_list = (new Server())->getServerList();
        $this->view->setVar('srv_list', $server_list);
        if ($this->request->isPost()) {
            $srv_id = $this->request->getPost('srv_id');
            $start_date = $this->request->getPost('start_date');
            $end_date = $this->request->getPost('end_date');
            $kpi_model = $this->getModel('kpi', $srv_id);
            $data = $kpi_model->find("type = 4 and date >= $start_date and date <= $end_date")->toArray();
            $data = array_column($data, 'data', 'date');
            foreach ($data as & $info) {
                $info = substr($info, 1, -1);
                $info = stripslashes($info);
                $info = json_decode($info, true);
            }
            $keys = array_keys($data);
            $this->view->setVar('line_keys', json_encode($keys));
            $index = ['d1', 'd3', 'd7', 'd15', 'd30'];
            foreach ($index as $num) {
                $var_name = "line_values_{$num}";
                $$var_name = array_column($data, strval($num));
                foreach ($$var_name as & $item) {
                    $item = floatval(number_format($item['active'] / $item['total'] * 100, 2));
                }
                $$var_name = [
                    [
                        'name' => substr($num, 1) . "日留存率",
                        'data' => array_values($$var_name),
                    ]
                ];
                $this->view->setVar($var_name, json_encode($$var_name));
            }
        }

    }

    public function retRateAction()
    {
        if (! $this->isAllowed()) {
            $this->setNotice('你没有权限这样做.', 403);
            return false;
        }
        $server_list = (new Server())->getServerList();
        $this->view->setVar('srv_list', $server_list);
        // 添加source字段
        $src_list = $this->getSourceList();
        $this->view->setVar('src_list', $src_list);
        if ($this->request->isPost()) {
            $srv_id = $this->request->getPost('srv_id');
            $src_id = $this->request->getPost('src_id');
            $start_date = $this->request->getPost('start_date');
            $end_date = $this->request->getPost('end_date');
            $kpi_model = $this->getModel('kpi', $srv_id);
            $data = $kpi_model->find("type = 110 and date >= $start_date and date <= $end_date")->toArray();
            $data = array_column($data, 'data', 'date');
            $idx = $src_id == -1 ? 0 : $src_id;
            foreach ($data as & $info) {
                $info = substr($info, 1, -1);
                $info = stripslashes($info);
                $info = json_decode($info, true);
                $info = $info[$idx];
            }
            $keys = array_keys($data);
            $this->view->setVar('keys', json_encode($keys));
            $values = [];
            $index = ['d1', 'd3', 'd7', 'd15', 'd30'];
            foreach ($index as $num) {
                $var_name = "line_values_{$num}";
                $$var_name = array_column($data, strval($num));
                foreach ($$var_name as & $item) {
                    $item = number_format($item['active'] / $item['regist'] * 100, 2);
                }
                $values[] = [
                    'name' => substr($num, 1) . "日留存率",
                    'data' => array_values($$var_name),
                ];
            }
            $this->view->setVar('values', json_encode($values, JSON_NUMERIC_CHECK));
        }
    }

    public function dauAction()
    {
        if (! $this->isAllowed()) {
            $this->setNotice('你没有权限这样做.', 403);
            return false;
        }
        $server_list = (new Server())->getServerList();
        $this->view->setVar('srv_list', $server_list);
        // 添加source字段
        $src_list = $this->getSourceList();
        $this->view->setVar('src_list', $src_list);
        if ($this->request->isPost()) {
            $srv_id = $this->request->getPost('srv_id');
            $src_id = $this->request->getPost('src_id');
            $start_date = $this->request->getPost('start_date');
            $end_date = $this->request->getPost('end_date');
            $kpi_model = $this->getModel('kpi', $srv_id);
            $data = $kpi_model->find("type = 105 and date >= $start_date and date <= $end_date")->toArray();
            $data = array_column($data, 'data', 'date');
            $idx = $src_id == -1 ? 0 : $src_id;
            foreach ($data as & $info) {
                $info = substr($info, 1, -1);
                $info = stripslashes($info);
                $info = json_decode($info, true);
                $info = $info[$idx];
            }
            $new = array_column($data, 'new');
            $old = array_column($data, 'old');
            $col_keys = array_keys($data);
            $col_values = [
                [
                    'name' => '老用户',
                    'data' => array_values($old),
                ],
                [
                    'name' => '新用户',
                    'data' => array_values($new),
                ]
            ];
            $this->view->setVar('column_keys', json_encode($col_keys));
            $this->view->setVar('column_values', json_encode($col_values));
        }
    }

    public function itemAction()
    {
        if (! $this->isAllowed()) {
            $this->setNotice('你没有权限这样做.', 403);
            return false;
        }
        $server_list = (new Server())->getServerList();
        $this->view->setVar('srv_list', $server_list);
        if ($this->request->isPost()) {
            $srv_id = $this->request->getPost('srv_id');
            $start_date = $this->request->getPost('start_date');
            $end_date = $this->request->getPost('end_date');
            $kpi_model = $this->getModel('kpi', $srv_id);
            $data = $kpi_model->find("type = 6 and date >= $start_date and date <= $end_date")->toArray();
            $data = array_column($data, 'data', 'date');
            $p_info = [];
            $c_info = [];
            foreach ($data as $date => & $info) {
                $info = substr($info, 1, -1);
                $info = stripslashes($info);
                $info = json_decode($info, true);
                $produce = $info['produce'];
                $consume  = $info['consume'];
                // test snippet
                if (empty ($consume)) {
                    $consume = $info['comsume'];
                }
                ///////////////
                foreach ($produce as $item_id => $sub_info) {
                    foreach ($sub_info as $sub_id => $count) {
                        $item_name = Item::$ITEM_ID_LIST[$item_id];
                        if (isset (Item::$SUB_ID_LIST[$item_id][$sub_id])) {
                            $item_name .= '|' . Item::$SUB_ID_LIST[$item_id][$sub_id];
                        }
                        $p_info[$date][$item_name] = $count;
                    }
                }
                foreach ($consume as $item_id => $sub_info) {
                    foreach ($sub_info as $sub_id => $count) {
                        $item_name = Item::$ITEM_ID_LIST[$item_id];
                        if (isset (Item::$SUB_ID_LIST[$item_id][$sub_id])) {
                            $item_name .= '|' . Item::$SUB_ID_LIST[$item_id][$sub_id];
                        }
                        $c_info[$date][$item_name] = $count;
                    }
                }
            }
            $p_keys = [];
            foreach ($p_info as $date => $info) {
                $p_keys = array_merge($p_keys, array_keys($info));
            }
            $c_keys = [];
            foreach ($c_info as $date => $info) {
                $c_keys = array_merge($c_keys, array_keys($info));
            }

            foreach ($p_info as $date => & $info) {
                $diff_item_names = array_diff($p_keys, array_keys($info));
                foreach ($diff_item_names as $name) {
                    $info[$name] = 0;
                }
            }

            foreach ($c_info as $date => & $info) {
                $diff_item_names = array_diff($c_keys, array_keys($info));
                foreach ($diff_item_names as $name) {
                    $info[$name] = 0;
                }
            }
            $this->view->setVar('keys', json_encode(array_keys($data)));
            $p_data = [];
            foreach ($p_info as $key => $_) {
                $item_names = array_keys($p_info[$key]);
                foreach ($item_names as $name) {
                    $p_data[] = [
                        'name' => $name,
                        'data' => array_column($p_info, $name),
                    ];
                }
                $this->view->setVar('p_data', json_encode($p_data));
                break;
            }

            $c_data = [];
            foreach ($c_info as $key => $_) {
                $item_names = array_keys($c_info[$key]);
                foreach ($item_names as $name) {
                    $c_data[] = [
                        'name' => $name,
                        'data' => array_column($c_info, $name),
                    ];
                }
                $this->view->setVar('c_data', json_encode($c_data, JSON_NUMERIC_CHECK));
                break;
            }
        }

    }

    public function missionAction()
    {
        if (! $this->isAllowed()) {
            $this->setNotice('你没有权限这样做.', 403);
            return false;
        }
        $server_list = (new Server())->getServerList();
        $this->view->setVar('srv_list', $server_list);
        if ($this->request->isPost()) {
            $srv_id = $this->request->getPost('srv_id');
            $date = $this->request->getPost('date');
            $kpi_model = $this->getModel('kpi', $srv_id);
            $map = $kpi_model->findFirst("type = 7 and date = $date");
            if ($map->count() > 0) {
                $data = substr($map->data, 1, -1);
                $data = stripslashes($data);
                $data = json_decode($data, true);
                $normal = $data['total']['normal'];
                $elite  = $data['total']['elite'];

                $normal_new = $data['today']['normal'];
                $elite_new  = $data['today']['elite'];
                if ($normal) {
                    $max_normal_sec = max(array_keys($normal));
                    for ($i = 1; $i <= $max_normal_sec; $i++) {
                        if (! isset($normal[$i])) {
                            $normal[$i] = 0;
                        }
                    }
                    ksort($normal);
                    $normal_data = [
                        [
                            'name' => '普通副本章节分布(总体)',
                            'data' => array_values($normal),
                        ],
                    ];
                    $this->view->setVar('normal_col_keys', json_encode(range(1, $max_normal_sec)));
                    $this->view->setVar('normal_col_values', json_encode($normal_data));
                }
                if ($normal_new) {
                    $max_normal_sec_new = max(array_keys($normal_new));
                    for ($i = 1; $i <= $max_normal_sec_new; $i++) {
                        if (! isset($normal_new[$i])) {
                            $normal_new[$i] = 0;
                        }
                    }
                    ksort($normal_new);
                    $normal_data_new = [
                        [
                            'name' => '普通副本章节分布(新增)',
                            'data' => array_values($normal_new),
                        ],
                    ];
                    $this->view->setVar('normal_col_keys_new', json_encode(range(1, $max_normal_sec_new)));
                    $this->view->setVar('normal_col_values_new', json_encode($normal_data_new));
                }
                if ($elite) {
                    $max_elite_sec = max(array_keys($elite));
                    for ($i = 1; $i <= $max_elite_sec; $i++) {
                        if (! isset($elite[$i])) {
                            $elite[$i] = 0;
                        }
                    }
                    ksort($elite);
                    $elite_data = [
                        [
                            'name' => '普通副本章节分布',
                            'data' => array_values($elite),
                        ]

                    ];
                    $this->view->setVar('elite_col_keys', json_encode(range(1, $max_elite_sec)));
                    $this->view->setVar('elite_col_values', json_encode($elite_data));
                }
                if ($elite_new) {
                    $max_elite_sec_new = max(array_keys($elite_new));
                    for ($i = 1; $i <= $max_elite_sec_new; $i++) {
                        if (! isset($elite_new[$i])) {
                            $elite_new[$i] = 0;
                        }
                    }
                    ksort($elite_new);
                    $elite_data_new = [
                        [
                            'name' => '普通副本章节分布',
                            'data' => array_values($elite_new),
                        ]

                    ];
                    $this->view->setVar('elite_col_keys_new', json_encode(range(1, $max_elite_sec_new)));
                    $this->view->setVar('elite_col_values_new', json_encode($elite_data_new));
                }
            }
        }
    }

    public function sysJoinAction()
    {
        if (! $this->isAllowed()) {
            $this->setNotice('你没有权限这样做.', 403);
            return false;
        }
        $server_list = (new Server())->getServerList();
        $this->view->setVar('srv_list', $server_list);
        $name_convert = [
            'e1' => '夺龙珠',
            'e2' => '悬赏',
            'e3' => '英雄副本',
            'e4' => '排位赛',
            'e5' => '挑战',
            'e6' => '科技',
            'e7' => '神殿',
            'e8' => '卡林神塔',
            'e9' => '蛇道',
            'e10' => '公会BOSS',
        ];
        if ($this->request->isPost()) {
            $srv_id = $this->request->getPost('srv_id');
            $start_date = $this->request->getPost('start_date');
            $end_date = $this->request->getPost('end_date');
            $kpi_model = $this->getModel('kpi', $srv_id);
            $data = $kpi_model->find("type = 8 and date >= $start_date and date <= $end_date")->toArray();
            $data = array_column($data, 'data', 'date');
            foreach ($data as & $info) {
                $info = substr($info, 1, -1);
                $info = stripslashes($info);
                $info = json_decode($info, true);
            }
            $keys = array_keys($data);
            $this->view->setVar('keys', json_encode($keys));
            $values = [];
            $index = ['e1', 'e2', 'e3', 'e4', 'e5', 'e6', 'e7', 'e8', 'e9', 'e10'];
            foreach ($index as $num) {
                $var_name = "line_values_{$num}";
                $$var_name = array_column($data, strval($num));
                foreach ($$var_name as & $item) {
                    $item = floatval(number_format($item['join'] / $item['total'] * 100, 2));
                }
                $values[] = [
                        'name' => $name_convert[$num],
                        'data' => array_values($$var_name),
                ];
            }
            $this->view->setVar('values', json_encode($values, JSON_NUMERIC_CHECK));
        }
    }

    public function payAction()
    {
        if (! $this->isAllowed()) {
            $this->setNotice('你没有权限这样做.', 403);
            return false;
        }
        $server_list = (new Server())->getServerList();
        $this->view->setVar('srv_list', $server_list);
        if ($this->request->isPost()) {
            $srv_id = $this->request->getPost('srv_id');
            $start_date = $this->request->getPost('start_date');
            $end_date = $this->request->getPost('end_date');
            $kpi_model = $this->getModel('kpi', $srv_id);
            $data = $kpi_model->find("type = 9 and date >= $start_date and date <= $end_date")->toArray();
            if ($data) {
                $data = array_column($data, 'data', 'date');
                foreach ($data as & $info) {
                    $info = substr($info, 1, -1);
                    $info = stripslashes($info);
                    $info = json_decode($info, true);
                    if (! ($info['new_pay'] && $info['new_regist'])) {
                        $info['new_pay_rate'] = 0;
                    } else {
                        $info['new_pay_rate'] = floatval(number_format($info['new_pay'] / $info['new_regist'] * 100, 2));
                    }
                    if (! ($info['total_pay'] && $info['total_regist'])) {
                        $info['total_pay_rate'] = 0;
                    } else {
                        $info['total_pay_rate'] = floatval(number_format($info['total_pay'] / $info['total_regist'] * 100, 2));
                    }
                }
                $keys = array_keys($data);
                $this->view->setVar('line_keys', json_encode($keys));

                $new_pay_rates = [
                    [
                        'name' => '新增付费率',
                        'data' => array_column($data, 'new_pay_rate'),
                    ]
                ];
                $this->view->setVar('new_line_values', json_encode($new_pay_rates));
                $total_pay_rates = [
                    [
                        'name' => '总付费率',
                        'data' => array_column($data, 'total_pay_rate'),
                    ]
                ];
                $this->view->setVar('total_line_values', json_encode($total_pay_rates));
            }
        }
    }

    public function payMapAction()
    {
        if (! $this->isAllowed()) {
            $this->setNotice('你没有权限这样做.', 403);
            return false;
        }
        $server_list = (new Server())->getServerList();
        $this->view->setVar('srv_list', $server_list);
        if ($this->request->isPost()) {
            $srv_id = $this->request->getPost('srv_id');
            $date = $this->request->getPost('date');
            $kpi_model = $this->getModel('kpi', $srv_id);
            $map = $kpi_model->findFirst("type = 9 and date = $date");
            if ($map) {
                $data = $map->data;
                $data = substr($data, 1, -1);
                $data = stripslashes($data);
                $data = json_decode($data, true);
                // 首次付费等级分布
                $level_map = $data['first_level_map'];
                if (! empty($level_map)) {
                    $max_level = max(array_keys($level_map));
                    for ($i = 1; $i <= $max_level; $i++) {
                        if (! isset($level_map[$i])) {
                            $level_map[$i] = 0;
                        }
                    }
                    ksort($level_map);
                    $level_data = [
                        [
                            'name' => '付费人数',
                            'data' => array_values($level_map),
                        ]
                    ];
                    $this->view->setVar('level_keys', json_encode(range(1, $max_level)));
                    $this->view->setVar('level_values', json_encode($level_data, JSON_NUMERIC_CHECK));
                }
                // 首次付费时间间隔分布
                $period_map = $data['first_time_map'];
                if (! empty($period_map)) {
                    $max_period = max(array_keys($period_map));
                    for ($i = 1; $i <= $max_period; $i++) {
                        if (! isset($period_map[$i])) {
                            $period_map[$i] = 0;
                        }
                    }
                    ksort($period_map);
                    $period_data = [
                        [
                            'name' => '付费人数',
                            'data' => array_values($period_map),
                        ]
                    ];
                    $this->view->setVar('period_keys', json_encode(range(1, $max_period)));
                    $this->view->setVar('period_values', json_encode($period_data));
                }
            }
        }
    }

    public function arpuAction()
    {
        if (! $this->isAllowed()) {
            $this->setNotice('你没有权限这样做.', 403);
            return false;
        }
        $server_list = (new Server())->getServerList();
        $this->view->setVar('srv_list', $server_list);
        // 添加source字段
        $src_list = $this->getSourceList();
        $this->view->setVar('src_list', $src_list);
        if ($this->request->isPost()) {
            $srv_id = $this->request->getPost('srv_id');
            $src_id = $this->request->getPost('src_id');
            $start_date = $this->request->getPost('start_date');
            $end_date = $this->request->getPost('end_date');
            $kpi_model = $this->getModel('kpi', $srv_id);
            $counts = $kpi_model->find("type = 11 and date >= $start_date and date <= $end_date")->toArray();
            $counts = array_column($counts, 'data', 'date');
            ksort($counts);
            $idx = $src_id == -1 ? 0 : $src_id;
            foreach ($counts as $date => & $val) {
                $val = substr($val, 1, -1);
                $val = stripslashes($val);
                $val = json_decode($val, true);
                $val = $val[$idx];
            }
            $total_arpu = [];
            $new_arpu = [];
            $total_income = [];
            $new_income = [];
            foreach ($counts as $date => $val) {
                $total_arpu[$date] = number_format($val['total_charge'] / $val['total_regist'], 2);
                $new_arpu[$date] = number_format($val['today_charge'] / $val['today_regist'], 2);
                $total_income[$date] = $val['total_charge'];
                $new_income[$date] = $val['today_charge'];
            }
            $keys = array_keys($counts);
            $this->view->setVar('keys', json_encode($keys));
            $this->view->setVar('t_arpu', json_encode([
                [
                    'name' => '总ARPU值变化',
                    'data' => array_values($total_arpu),
                ]
            ], JSON_NUMERIC_CHECK));
            $this->view->setVar('n_arpu', json_encode([
                [
                    'name' => '每日新增ARPU值变化',
                    'data' => array_values($new_arpu),
                ]
            ], JSON_NUMERIC_CHECK));
            $this->view->setVar('t_income', json_encode([
                [
                    'name' => '总收入变化',
                    'data' => array_values($total_income),
                ]
            ], JSON_NUMERIC_CHECK));
            $this->view->setVar('n_income', json_encode([
                [
                    'name' => '每日新增收入',
                    'data' => array_values($new_income),
                ]
            ], JSON_NUMERIC_CHECK));
        }
    }
}
