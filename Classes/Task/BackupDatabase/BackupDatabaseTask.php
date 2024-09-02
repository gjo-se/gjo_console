<?php

declare(strict_types=1);

namespace GjoSe\GjoConsole\Task\BackupDatabase;

use TYPO3\CMS\Scheduler\Task\AbstractTask;
use TYPO3\CMS\Core\Utility\GeneralUtility;

final class BackupDatabaseTask extends AbstractTask
{
    private string $dbSource = '';

    private string $dbTarget = '';

    public function getDbSource(): string
    {
        return $this->dbSource;
    }

    public function getDbTarget(): string
    {
        return $this->dbTarget;
    }

    public function setDbSource(string $dbSource): void
    {
        $this->dbSource = $dbSource;
    }

    public function setDbTarget(string $dbTarget): void
    {
        $this->dbTarget = $dbTarget;
    }

    public function execute(): bool
    {
        /** @var BackupDatabaseController $backupDatabaseController */
        $backupDatabaseController = GeneralUtility::makeInstance(BackupDatabaseController::class);
        return $backupDatabaseController->execute($this);
    }
}
