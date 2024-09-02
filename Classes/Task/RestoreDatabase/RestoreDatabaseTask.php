<?php

declare(strict_types=1);

namespace GjoSe\GjoConsole\Task\RestoreDatabase;

use TYPO3\CMS\Scheduler\Task\AbstractTask;
use TYPO3\CMS\Core\Utility\GeneralUtility;

final class RestoreDatabaseTask extends AbstractTask
{
    private string $backupFile = '';

    public function getBackupFile(): string
    {
        return $this->backupFile;
    }

    public function setBackupFile(string $backupFile): void
    {
        $this->backupFile = $backupFile;
    }

    public function execute(): bool
    {
        /** @var RestoreDatabaseController $restoreDatabaseController */
        $restoreDatabaseController = GeneralUtility::makeInstance(RestoreDatabaseController::class);
        return $restoreDatabaseController->execute($this);
    }
}
