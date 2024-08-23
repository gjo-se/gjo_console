<?php

declare(strict_types=1);

$EM_CONF[$_EXTKEY] = [
    'title' => 'Gjo Console',
    'description' => 'Gjo Console',
    'version' => '12.0.0',
    'category' => 'plugin',
    'constraints' => [
        'depends' => [
            'php' => '8.3.0-8.3.99',
            'typo3' => '12.0-12.4.99',
        ],
        'conflicts' => [
        ],
        'suggests' => [
        ],
    ],
    'state' => 'stable',
    'author' => 'Gregory Jo Erdmann',
    'author_email' => 'gregory.jo@gjo-se.com',
    'author_company' => 'GjoSe',
    'autoload' => [
        'psr-4' => [
            'GjoSe\\GjoConsole\\' => 'Classes/',
        ],
    ],
];
