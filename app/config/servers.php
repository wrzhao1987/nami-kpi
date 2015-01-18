<?php
/**
 * Created by PhpStorm.
 * User: martin
 * Date: 14-7-2
 * Time: 下午4:53
 */
return [
    -1 => [
        'adroid-del-01' => [
            'id'    => 2001,
            'name'  => '安卓封测一区',
            'mysql' => [
                'host'     => '10.10.24.195',
                'port'     => '3306',
                'username' => 'root',
                'password' => 'namisan',
                'dbname'   => 'nami',
                'charset'  => 'utf8',
            ],
            'redis' => [
                'host' => '10.10.24.195',
                'port' => '6379',
            ],
        ],
        'master' => [
            'id'    => 4,
            'name'  => 'master',
            'mysql' => [
                'host'     => '192.168.1.200',
                'port'     => '3306',
                'username' => 'root',
                'password' => 'namisan',
                'dbname'   => 'nami',
                'charset'  => 'utf8',
            ],
            'redis' => [
                'host' => '192.168.1.200',
                'port' => '6379',
            ],
        ],
        'ceping' => [
            'id'    => 9,
            'name'  => '测评区',
            'mysql' => [
                'host'     => '10.10.12.163',
                'port'     => '3306',
                'username' => 'root',
                'password' => 'namisan',
                'dbname'   => 'nami',
                'charset'  => 'utf8',
            ],
            'redis' => [
                'host' => '10.10.12.163',
                'port' => '6379',
            ],
        ],
        'jb-alpha' => [
            'id'    => 10,
            'name'  => '越狱开放测试区',
            'mysql' => [
                'host'     => '10.10.57.135',
                'port'     => '3306',
                'username' => 'root',
                'password' => 'namisan',
                'dbname'   => 'nami',
                'charset'  => 'utf8',
            ],
            'redis' => [
                'host' => '10.10.57.135',
                'port' => '6379',
            ],
        ],
        'apple-01' => [
            'id'    => 1001,
            'name'  => '苹果正版一区',
            'mysql' => [
                'host'     => '10.10.40.126',
                'port'     => '3306',
                'username' => 'root',
                'password' => 'namisan',
                'dbname'   => 'nami',
                'charset'  => 'utf8',
            ],
            'redis' => [
                'host' => '10.10.40.126',
                'port' => '6379',
            ],
        ],
    ],
];
