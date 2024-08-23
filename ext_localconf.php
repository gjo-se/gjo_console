<?php

declare(strict_types=1);

use GjoSe\GjoConsole\Task\AdditionalFieldProvider\BackupDatabaseTaskAdditionalFieldProvider;
use GjoSe\GjoConsole\Task\AdditionalFieldProvider\RestoreDatabaseTaskAdditionalFieldProvider;
use GjoSe\GjoConsole\Task\BackupDatabaseTask;
use GjoSe\GjoConsole\Task\RestoreDatabaseTask;

defined('TYPO3') || die('Access denied.');

call_user_func(
    static function (): void {

        $extensionKey = 'gjo_console';

        $GLOBALS['TYPO3_CONF_VARS']['SC_OPTIONS']['scheduler']['tasks'][BackupDatabaseTask::class] = [
            'extension' => $extensionKey,
            'title' => 'LLL:EXT:' . $extensionKey . '/Resources/Private/Language/locallang.xlf:backupDatabaseTask.name',
            'description' => 'LLL:EXT:' . $extensionKey . '/Resources/Private/Language/locallang.xlf:backupDatabaseTask.description',
            'additionalFields' => BackupDatabaseTaskAdditionalFieldProvider::class,
        ];

        $GLOBALS['TYPO3_CONF_VARS']['SC_OPTIONS']['scheduler']['tasks'][RestoreDatabaseTask::class] = [
            'extension' => $extensionKey,
            'title' => 'LLL:EXT:' . $extensionKey . '/Resources/Private/Language/locallang.xlf:restoreDatabaseTask.name',
            'description' => 'LLL:EXT:' . $extensionKey . '/Resources/Private/Language/locallang.xlf:restoreDatabaseTask.description',
            'additionalFields' => RestoreDatabaseTaskAdditionalFieldProvider::class,
        ];
    }
);
