<?php

declare(strict_types=1);

namespace GjoSe\GjoConsole\Task\BackupDatabase;

use GjoSe\GjoConsole\Task\AbstractTask;
use TYPO3\CMS\Core\Utility\GeneralUtility;

final class BackupDatabaseTask extends AbstractTask
{
    public function execute(): bool
    {
        /** @var BackupDatabaseController $backupDatabaseController */
        $backupDatabaseController = GeneralUtility::makeInstance(BackupDatabaseController::class);
        return $backupDatabaseController->execute($this);
    }
}
