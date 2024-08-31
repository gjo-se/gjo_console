<?php

declare(strict_types=1);

namespace GjoSe\GjoConsole\Task;

use TYPO3\CMS\Scheduler\Task\AbstractTask as CoreAbstractTask;

abstract class AbstractTask extends CoreAbstractTask
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
}
