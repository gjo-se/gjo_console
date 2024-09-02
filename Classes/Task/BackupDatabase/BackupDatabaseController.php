<?php

declare(strict_types=1);

namespace GjoSe\GjoConsole\Task\BackupDatabase;

use GjoSe\GjoApi\Service\Database\BackupDatabaseService;
use TYPO3\CMS\Core\Utility\GeneralUtility;

class BackupDatabaseController
{
    public function execute(BackupDatabaseTask $backupDatabaseTask): bool
    {
        /** @var BackupDatabaseService $backupDatabaseService */
        $backupDatabaseService = GeneralUtility::makeInstance(BackupDatabaseService::class);
        $backupDatabaseService
            ->setDbSource($backupDatabaseTask->getDbSource())
            ->setDbTarget($backupDatabaseTask->getDbTarget());
        return $backupDatabaseService->backup();
    }
}
