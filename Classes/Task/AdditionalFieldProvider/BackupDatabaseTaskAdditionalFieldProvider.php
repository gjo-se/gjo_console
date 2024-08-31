<?php

declare(strict_types=1);

namespace GjoSe\GjoConsole\Task\AdditionalFieldProvider;

use GjoSe\GjoApi\Service\Database\DatabaseBackupService;
use GjoSe\GjoApi\Service\Site\SiteSettingsService;
use GjoSe\GjoConsole\Task\BackupDatabaseTask;
use TYPO3\CMS\Core\Utility\GeneralUtility;
use TYPO3\CMS\Scheduler\AbstractAdditionalFieldProvider;
use TYPO3\CMS\Scheduler\Controller\SchedulerModuleController;
use TYPO3\CMS\Scheduler\Task\AbstractTask;
use TYPO3\CMS\Scheduler\Task\Enumeration\Action;

class BackupDatabaseTaskAdditionalFieldProvider extends AbstractAdditionalFieldProvider
{
    private const string EXTENSION_KEY = 'gjo_console';

    private const string FIELD_DB_SOURCE = 'dbSource';

    private const string FIELD_DB_TARGET = 'dbTarget';

    public function getAdditionalFields(array &$taskInfo, $task, SchedulerModuleController $schedulerModule): array
    {
        if (!$task instanceof BackupDatabaseTask) {
            return [];
        }

        return [
            $this->getHtmlTagDbSourceField($taskInfo, $task, $schedulerModule),
            $this->getHtmlTagDbTargetField($taskInfo, $task, $schedulerModule),
        ];
    }

    private function getHtmlTagDbSourceField(array &$taskInfo, BackupDatabaseTask $task, SchedulerModuleController $schedulerModule): array
    {
        $taskInfo[self::EXTENSION_KEY][self::FIELD_DB_SOURCE] = $taskInfo[self::EXTENSION_KEY][self::FIELD_DB_SOURCE] ?? ($schedulerModule->getCurrentAction()->equals(Action::EDIT) ? $task->getDbSource() : '');
        $fieldID = self::EXTENSION_KEY . '_' . self::FIELD_DB_SOURCE;
        $fieldCode = '<select class="form-control" name="tx_scheduler[' . self::EXTENSION_KEY . '][' . self::FIELD_DB_SOURCE . ']" id="' . $fieldID . '">' . $this->getHtmlTagDbSourceOptions($taskInfo) . '</select>';

        return [
            'label' => 'LLLx: Source: ',
            'code' => $fieldCode,
        ];
    }

    private function getHtmlTagDbTargetField(array &$taskInfo, BackupDatabaseTask $task, SchedulerModuleController $schedulerModule): array
    {
        $taskInfo[self::EXTENSION_KEY][self::FIELD_DB_TARGET] = $taskInfo[self::EXTENSION_KEY][self::FIELD_DB_TARGET] ?? ($schedulerModule->getCurrentAction()->equals(Action::EDIT) ? $task->getDbTarget() : '');
        $fieldID = self::EXTENSION_KEY . '_' . self::FIELD_DB_TARGET;
        $fieldCode = '<select class="form-control" name="tx_scheduler[' . self::EXTENSION_KEY . '][' . self::FIELD_DB_TARGET . ']" id="' . $fieldID . '">' . $this->getHtmlTagDbTargetOptions($taskInfo) . '</select>';

        return [
            'label' => 'LLLx: Target: ',
            'code' => $fieldCode,
        ];
    }

    private function getHtmlTagDbSourceOptions(array $taskInfo): string
    {
        /** @var DatabaseBackupService $dataBaseBackupService */
        $dataBaseBackupService = GeneralUtility::makeInstance(DatabaseBackupService::class);

        $options = '';
        foreach (array_keys($dataBaseBackupService->getConnections()) as $connectionName) {
            $convertedConnectionName = $dataBaseBackupService->convertDefaultConnectionNameToContext($connectionName);
            $options .= '<option value="' . $convertedConnectionName . '" ' . ($convertedConnectionName === $taskInfo[self::EXTENSION_KEY][self::FIELD_DB_SOURCE] ? 'selected' : '') . ' >' . $convertedConnectionName . '</option>';
        }

        return $options;
    }

    private function getHtmlTagDbTargetOptions(array $taskInfo): string
    {
        /** @var SiteSettingsService $siteSettingsService */
        $siteSettingsService = GeneralUtility::makeInstance(SiteSettingsService::class);

        $options = '';
        foreach ($siteSettingsService->getBackupTargets() as $backupTarget) {
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
