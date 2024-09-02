<?php

declare(strict_types=1);

use GjoSe\GjoConsole\Task\BackupDatabase\BackupDatabaseTask;
use GjoSe\GjoConsole\Task\BackupDatabase\BackupDatabaseAdditionalFieldProvider;
use GjoSe\GjoConsole\Task\RestoreDatabase\RestoreDatabaseTask;
use GjoSe\GjoConsole\Task\RestoreDatabase\RestoreDatabaseTaskAdditionalFieldProvider;

defined('TYPO3') || die('Access denied.');

(function (): void {

    $extensionKey = 'gjo_console';

    $GLOBALS['TYPO3_CONF_VARS']['SC_OPTIONS']['scheduler']['tasks'][BackupDatabaseTask::class] = [
        'extension' => $extensionKey,
        'title' => 'LLL:EXT:' . $extensionKey . '/Resources/Private/Language/locallang.xlf:backupDatabaseTask.name',
        'description' => 'LLL:EXT:' . $extensionKey . '/Resources/Private/Language/locallang.xlf:backupDatabaseTask.description',
        'additionalFields' => BackupDatabaseAdditionalFieldProvider::class,
    ];

    //    $GLOBALS['TYPO3_CONF_VARS']['SC_OPTIONS']['scheduler']['tasks'][RestoreDatabaseTask::class] = [
    //        'extension' => $extensionKey,
    //        'title' => 'LLL:EXT:' . $extensionKey . '/Resources/Private/Language/locallang.xlf:restoreDatabaseTask.name',
    //        'description' => 'LLL:EXT:' . $extensionKey . '/Resources/Private/Language/locallang.xlf:restoreDatabaseTask.description',
    //        'additionalFields' => RestoreDatabaseTaskAdditionalFieldProvider::class,
    //    ];
})();
