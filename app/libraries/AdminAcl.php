<?php
use \Phalcon\Acl\Role;
use \Phalcon\Acl\Resource;
use \Phalcon\Mvc\User\Component;

class AdminAcl extends Component
{
    public static $convert = [
        1 => 'superuser',
        2 => 'admin',
        3 => 'operator',
        4 => 'no_kernel',
        99 => 'undefined',
    ];

    public static $convert_view = [
        1 => '超级管理员',
        2 => '管理员',
        3 => '运维人员',
        4 => '非核心人员',
        99 => '无权限',

    ];

    private static $apc_acl = 'acl_list';

    private static $roles = [
        'undefined', 'superuser', 'admin', 'operator', 'no_kernel'
    ];
    private static $resources = [
        'admin' => ['add', 'modpwd', 'manage'],
        'announce' => ['add', 'manage', 'edit', 'del'],
        'mail' => ['send', 'log'],
        'info' => ['overview'],
        'kpi' => [
            'level', 'newbie', 'newuser', 'stayuser', 'dau', 'item',
            'mission', 'sysjoin', 'pay', 'paymap', 'retrate'
        ],
        'order' => ['query', 'budan'],
        'server' => ['manage', 'write'],
        'exchange' => ['typeList', 'manageNew', 'export', 'addType', 'editType', 'delType'],
    ];

    private $acl;

    public function __construct()
    {
        $acl = apc_fetch(self::$apc_acl, $success);
        if (! $success) {
            $acl = new \Phalcon\Acl\Adapter\Memory();
            $acl->setDefaultAction(\Phalcon\Acl::DENY);

            foreach (self::$roles as $item) {
                $role = new Role($item);
                $acl->addRole($role);
            }

            foreach (self::$resources as $resource => $actions) {
                $r = new Resource($resource);
                $acl->addResource($r, $actions);
            }

            $acl->allow("superuser", '*', '*');
            $acl->allow("admin", '*', '*');
            $acl->allow("operator", '*', '*');
            $acl->allow("no_kernel", 'kpi', ['newbie', 'pay', 'paymap', 'newuser', 'dau', 'retrate']);
            $acl->allow("no_kernel", 'announce', '*');
            $acl->allow("no_kernel", 'mail', ['send', 'log']);
            $acl->allow("no_kernel", 'info', 'overview');
            $acl->allow("no_kernel", 'order', ['query', 'budan']);
            $acl->allow("no_kernel", 'server', ['manage', 'write']);
            $acl->allow("no_kernel", 'exchange', ['typeList', 'manageNew', 'export', 'addType', 'editType', 'delType']);
            apc_store(self::$apc_acl, $acl);
        }
        $this->acl = $acl;
    }

    public function isAllowed($role, $controller, $action)
    {
        return $this->acl->isAllowed($role, $controller, $action);
    }

    public static function roleToString($role)
    {
        if (array_key_exists($role, self::$convert)) {
            return self::$convert[$role];
        }
        return 'undefined';
    }
}