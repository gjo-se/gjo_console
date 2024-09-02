<?php

declare(strict_types=1);

namespace GjoSe\GjoConsole\Task\RestoreDatabase;

use GjoSe\GjoApi\Service\Database\BackupDatabaseService;
use GjoSe\GjoApi\Service\Database\RestoreDatabaseService;
use TYPO3\CMS\Core\Utility\GeneralUtility;

class RestoreDatabaseController
{
    public function execute(RestoreDatabaseTask $restoreDatabaseTask): bool
    {
        if (!$this->setupBackupDatabaseService($restoreDatabaseTask)) {
            return false;
        }
        if (!$this->setupRestoreDatabaseService($restoreDatabaseTask)) {
            return false;
        }

        return true;
    }

    private function setupBackupDatabaseService(RestoreDatabaseTask $restoreDatabaseTask): bool
    {
        /** @var BackupDatabaseService $backupDatabaseService */
        $backupDatabaseService = GeneralUtility::makeInstance(BackupDatabaseService::class);
        $backupDatabaseService
            ->setDbSource($backupDatabaseService->getDbSourceByBackupFile($restoreDatabaseTask->getBackupFile()))
            ->setDbTarget($backupDatabaseService->getDbTargetByBackupFile($restoreDatabaseTask->getBackupFile()));
        return $backupDatabaseService->backup();
    }

    private function setupRestoreDatabaseService(RestoreDatabaseTask $restoreDatabaseTask): bool
    {
        /** @var RestoreDatabaseService $restoreDatabaseService */
        $restoreDatabaseService = GeneralUtility::makeInstance(RestoreDatabaseService::class);
        $restoreDatabaseService
            ->setBackupFile($restoreDatabaseTask->getBackupFile())
            ->setDbSource($restoreDatabaseService->getDbSourceByBackupFile($restoreDatabaseTask->getBackupFile()))
            ->setDbTarget($restoreDatabaseService->getDbTargetByBackupFile($restoreDatabaseTask->getBackupFile()));
        return $restoreDatabaseService->restore();
    }

}
