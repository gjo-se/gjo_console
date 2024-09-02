<?php

declare(strict_types=1);

namespace GjoSe\GjoConsole\Task\BackupDatabase;

use GjoSe\GjoApi\Service\Database\DatabaseBackupService;
use GjoSe\GjoApi\Service\Site\SiteSettingsService;
use TYPO3\CMS\Core\Utility\GeneralUtility;
use TYPO3\CMS\Scheduler\AbstractAdditionalFieldProvider;
use TYPO3\CMS\Scheduler\Controller\SchedulerModuleController;
use TYPO3\CMS\Scheduler\Task\AbstractTask;
use TYPO3\CMS\Scheduler\Task\Enumeration\Action;

class BackupDatabaseAdditionalFieldProvider extends AbstractAdditionalFieldProvider
{
    private const string EXTENSION_KEY = 'gjo_console';

    private const string FIELD_DB_SOURCE = 'dbSource';

    private const string FIELD_DB_TARGET = 'dbTarget';

    private DatabaseBackupService $databaseBackupService;
    private SiteSettingsService $siteSettingsService;

    public function __construct()
    {
        $this->databaseBackupService = GeneralUtility::makeInstance(DatabaseBackupService::class);
        $this->siteSettingsService = GeneralUtility::makeInstance(SiteSettingsService::class);
    }

    public function getAdditionalFields(array &$taskInfo, $task, SchedulerModuleController $schedulerModule): array
    {
        $this->initializeFields($taskInfo, $task, $schedulerModule);

        return [
            $this->getHtmlTagDbSourceField($taskInfo),
            $this->getHtmlTagDbTargetField($taskInfo),
        ];
    }

    private function initializeFields(array &$taskInfo, ?AbstractTask $task, SchedulerModuleController $schedulerModule): void
    {
        $this->initializeDbSourceField($taskInfo);
        $this->initializeDbTargetField($taskInfo);

        if ($task instanceof BackupDatabaseTask && $schedulerModule->getCurrentAction()->equals(Action::EDIT)) {
            $this->hydrateDbSourceField($taskInfo, $task);
            $this->hydrateDbTargetField($taskInfo, $task);
        }
    }

    private function initializeDbSourceField(array &$taskInfo): void
    {
        $taskInfo[self::EXTENSION_KEY][self::FIELD_DB_SOURCE] = $taskInfo[self::EXTENSION_KEY][self::FIELD_DB_SOURCE] ?? '';
    }

    private function initializeDbTargetField(array &$taskInfo): void
    {
        $taskInfo[self::EXTENSION_KEY][self::FIELD_DB_TARGET] = $taskInfo[self::EXTENSION_KEY][self::FIELD_DB_TARGET] ?? '';
    }

    private function hydrateDbSourceField(array &$taskInfo, BackupDatabaseTask $task): void
    {
        $taskInfo[self::EXTENSION_KEY][self::FIELD_DB_SOURCE] = $task->getDbSource();
    }

    private function hydrateDbTargetField(array &$taskInfo, BackupDatabaseTask $task): void
    {
        $taskInfo[self::EXTENSION_KEY][self::FIELD_DB_TARGET] = $task->getDbTarget();
    }

    private function getHtmlTagDbSourceField(array $taskInfo): array
    {
        $fieldID = self::EXTENSION_KEY . '_' . self::FIELD_DB_SOURCE;
        $fieldCode = '<select class="form-control" name="tx_scheduler[' . self::EXTENSION_KEY . '][' . self::FIELD_DB_SOURCE . ']" id="' . $fieldID . '">' . $this->getHtmlTagDbSourceOptions($taskInfo) . '</select>';

        return [
            'label' => 'LLLx: Source: ',
            'code' => $fieldCode,
        ];
    }

    private function getHtmlTagDbTargetField(array $taskInfo): array
    {
        $fieldID = self::EXTENSION_KEY . '_' . self::FIELD_DB_TARGET;
        $fieldCode = '<select class="form-control" name="tx_scheduler[' . self::EXTENSION_KEY . '][' . self::FIELD_DB_TARGET . ']" id="' . $fieldID . '">' . $this->getHtmlTagDbTargetOptions($taskInfo) . '</select>';

        return [
            'label' => 'LLLx: Target: ',
            'code' => $fieldCode,
        ];
    }

    private function getHtmlTagDbSourceOptions(array $taskInfo): string
    {
        $options = '';
        foreach (array_keys($this->databaseBackupService->getConnections()) as $connectionName) {
            $convertedConnectionName = $this->databaseBackupService->convertDefaultConnectionNameToContext($connectionName);
            $options .= '<option value="' . $convertedConnectionName . '" ' . ($convertedConnectionName === $taskInfo[self::EXTENSION_KEY][self::FIELD_DB_SOURCE] ? 'selected' : '') . ' >' . $convertedConnectionName . '</option>';
        }

        return $options;
    }

    private function getHtmlTagDbTargetOptions(array $taskInfo): string
    {
        $options = '';
        foreach ($this->siteSettingsService->getBackupTargets() as $backupTarget) {
            $selected = $backupTarget === $taskInfo[self::EXTENSION_KEY][self::FIELD_DB_TARGET] ? 'selected' : '';
            $options .= '<option value="' . $backupTarget . '" ' . $selected . ' >' . $backupTarget . '</option>';
        }

        return $options;
    }

    /**
     * @param array<array<string>> $submittedData
     */
    public function validateAdditionalFields(array &$submittedData, SchedulerModuleController $schedulerModule): bool
    {
        return true;
    }

    /**
     * @param array<array<string>> $submittedData
     */
    public function saveAdditionalFields(array $submittedData, AbstractTask $task): void
    {
        if ($task instanceof BackupDatabaseTask) {
            $task->setDbSource($submittedData[self::EXTENSION_KEY][self::FIELD_DB_SOURCE]);
            $task->setDbTarget($submittedData[self::EXTENSION_KEY][self::FIELD_DB_TARGET]);
        }
    }
}
