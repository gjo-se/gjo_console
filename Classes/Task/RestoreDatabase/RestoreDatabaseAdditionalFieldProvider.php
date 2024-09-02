<?php

declare(strict_types=1);

namespace GjoSe\GjoConsole\Task\RestoreDatabase;

use GjoSe\GjoApi\Service\File\FileService;
use GjoSe\GjoApi\Service\Site\SiteSettingsService;
use GjoSe\GjoApi\Utility\EnvironmentUtility;
use TYPO3\CMS\Core\Utility\GeneralUtility;
use TYPO3\CMS\Scheduler\AbstractAdditionalFieldProvider;
use TYPO3\CMS\Scheduler\Controller\SchedulerModuleController;
use TYPO3\CMS\Scheduler\Task\AbstractTask;
use TYPO3\CMS\Scheduler\Task\Enumeration\Action;

class RestoreDatabaseAdditionalFieldProvider extends AbstractAdditionalFieldProvider
{
    private const string EXTENSION_KEY = 'gjo_console';

    private const string FIELD_BACKUP_FILE = 'backupFile';

    private SiteSettingsService $siteSettingsService;

    public function __construct()
    {
        $this->siteSettingsService = GeneralUtility::makeInstance(SiteSettingsService::class);
    }

    public function getAdditionalFields(array &$taskInfo, $task, SchedulerModuleController $schedulerModule): array
    {
        $this->initializeFields($taskInfo, $task, $schedulerModule);

        return [
            $this->getHtmlTagBackupFileField($taskInfo),
        ];
    }

    private function initializeFields(array &$taskInfo, ?AbstractTask $task, SchedulerModuleController $schedulerModule): void
    {
        $this->initializeBackupFileField($taskInfo);

        if ($task instanceof RestoreDatabaseTask && $schedulerModule->getCurrentAction()->equals(Action::EDIT)) {
            $this->hydrateBackupFileField($taskInfo, $task);
        }
    }

    private function initializeBackupFileField(array &$taskInfo): void
    {
        $taskInfo[self::EXTENSION_KEY][self::FIELD_BACKUP_FILE] = $taskInfo[self::EXTENSION_KEY][self::FIELD_BACKUP_FILE] ?? '';
    }

    private function hydrateBackupFileField(array &$taskInfo, RestoreDatabaseTask $task): void
    {
        $taskInfo[self::EXTENSION_KEY][self::FIELD_BACKUP_FILE] = $task->getBackupFile();
    }

    private function getHtmlTagBackupFileField(array $taskInfo): array
    {
        $fieldID = self::EXTENSION_KEY . '_' . self::FIELD_BACKUP_FILE;
        $fieldCode = '<select class="form-control" name="tx_scheduler[' . self::EXTENSION_KEY . '][' . self::FIELD_BACKUP_FILE . ']" id="' . $fieldID . '">' . $this->getHtmlTagBackupFileOptions($taskInfo) . '</select>';

        return [
            'label' => 'LLLx: Source: ',
            'code' => $fieldCode,
        ];
    }

    private function getHtmlTagBackupFileOptions(array $taskInfo): string
    {
        $options = '';
        foreach ($this->getBackupFiles() as $file) {
            $value = FileService::getFileBaseName($file);
            $options .= '<option value="' . $file . '" ' . ($file == $taskInfo[self::EXTENSION_KEY][self::FIELD_BACKUP_FILE] ? 'selected' : '') . ' >' . $value . '</option>';

        }

        return $options;
    }

    private function getBackupFiles(): array
    {
        return GeneralUtility::getAllFilesAndFoldersInPath([], EnvironmentUtility::getProjectPath() . '/' . $this->siteSettingsService->getBackupPath() . '/');
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
        if ($task instanceof RestoreDatabaseTask) {
            $task->setBackupFile($submittedData[self::EXTENSION_KEY][self::FIELD_BACKUP_FILE]);
        }
    }
}
