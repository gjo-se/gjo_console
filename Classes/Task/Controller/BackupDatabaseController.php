<?php

declare(strict_types=1);

namespace GjoSe\GjoConsole\Task\Controller;

use GjoSe\GjoApi\Service\Database\DatabaseBackupService;
use GjoSe\GjoConsole\Task\BackupDatabaseTask;
use TYPO3\CMS\Core\Utility\GeneralUtility;

class BackupDatabaseController
{
    public function execute(BackupDatabaseTask $backupDatabaseTask): bool
    {
        /** @var DatabaseBackupService $dataBaseBackupService */
        $dataBaseBackupService = GeneralUtility::makeInstance(DatabaseBackupService::class);
        return $dataBaseBackupService
            ->setDbSource($backupDatabaseTask->getDbSource())
            ->setDbTarget($backupDatabaseTask->getDbTarget())
            ->backup();
    }
}
