<?php

declare(strict_types=1);

namespace GjoSe\GjoConsole\Task\BackupDatabase;

use GjoSe\GjoApi\Service\Database\DatabaseBackupService;
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
