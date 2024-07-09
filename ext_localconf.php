<?php

use GjoSe\GjoScheduler\Task\BackupDatabaseTask;
use GjoSe\GjoScheduler\Task\BackupDatabaseTaskAdditionalFieldProvider;
//use GjoSe\GjoScheduler\Task\CleanupDumpsTask;
//use GjoSe\GjoScheduler\Task\CleanupDumpsTaskAdditionalFieldProvider;
//use GjoSe\GjoScheduler\Task\DeploymentDatabaseTask;
//use GjoSe\GjoScheduler\Task\DeploymentDatabaseTaskAdditionalFieldProvider;
//use GjoSe\GjoScheduler\Task\RestoreDatabaseTask;
//use GjoSe\GjoScheduler\Task\RestoreDatabaseTaskAdditionalFieldProvider;

defined('TYPO3') or die('Access denied.');

call_user_func(
    static function (): void {

        $extensionKey = 'gjo_site_package';

        $GLOBALS['TYPO3_CONF_VARS']['SC_OPTIONS']['scheduler']['tasks'][BackupDatabaseTask::class] = array(
            'extension' => $extensionKey,
            'title' => 'LLL:EXT:' . $extensionKey . '/Resources/Private/Language/locallang.xlf:backupDatabaseTask.name',
            'description' => 'LLL:EXT:' . $extensionKey . '/Resources/Private/Language/locallang.xlf:backupDatabaseTask.description',
            'additionalFields' => BackupDatabaseTaskAdditionalFieldProvider::class
        );

//        $GLOBALS['TYPO3_CONF_VARS']['SC_OPTIONS']['scheduler']['tasks'][RestoreDatabaseTask::class] = array(
//            'extension' => $extensionKey,
//            'title' => 'LLL:EXT:' . $extensionKey . '/Resources/Private/Language/locallang.xlf:restoreDatabaseTask.name',
//            'description' => 'LLL:EXT:' . $extensionKey . '/Resources/Private/Language/locallang.xlf:restoreDatabaseTask.description',
//            'additionalFields' => RestoreDatabaseTaskAdditionalFieldProvider::class
//        );
//
//        $GLOBALS['TYPO3_CONF_VARS']['SC_OPTIONS']['scheduler']['tasks'][CleanupDumpsTask::class] = array(
//            'extension' => $extensionKey,
//            'title' => 'LLL:EXT:' . $extensionKey . '/Resources/Private/Language/locallang.xlf:cleanupDumpsTask.name',
//            'description' => 'LLL:EXT:' . $extensionKey . '/Resources/Private/Language/locallang.xlf:cleanupDumpsTask.description',
//            'additionalFields' => CleanupDumpsTaskAdditionalFieldProvider::class
//        );
//
//        $GLOBALS['TYPO3_CONF_VARS']['SC_OPTIONS']['scheduler']['tasks'][DeploymentDatabaseTask::class] = array(
//            'extension' => $extensionKey,
//            'title' => 'LLL:EXT:' . $extensionKey . '/Resources/Private/Language/locallang.xlf:deploymentDatabaseTask.name',
//            'description' => 'LLL:EXT:' . $extensionKey . '/Resources/Private/Language/locallang.xlf:deploymentDatabaseTask.description',
//            'additionalFields' => DeploymentDatabaseTaskAdditionalFieldProvider::class
//        );
    }
);