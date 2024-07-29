<?php

declare(strict_types=1);

namespace GjoSe\GjoConsole\Task\AdditionalFieldProvider;

/***************************************************************
 *  created: 05.12.19 - 10:06
 *  Copyright notice
 *  (c) 2019 Gregory Jo Erdmann <gregory.jo@gjo-se.com>
 *  All rights reserved
 *  This script is part of the TYPO3 project. The TYPO3 project is
 *  free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 3 of the License, or
 *  (at your option) any later version.
 *  The GNU General Public License can be found at
 *  http://www.gnu.org/copyleft/gpl.html.
 *  This script is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *  This copyright notice MUST APPEAR in all copies of the script!
 ***************************************************************/

use GjoSe\GjoConsole\Task\BackupDatabaseTask;
use TYPO3\CMS\Core\Core\Environment;
use TYPO3\CMS\Core\Type\ContextualFeedbackSeverity;
use TYPO3\CMS\Scheduler\AbstractAdditionalFieldProvider;
use TYPO3\CMS\Scheduler\Controller\SchedulerModuleController;
use TYPO3\CMS\Scheduler\Task\AbstractTask;
use TYPO3\CMS\Scheduler\Task\Enumeration\Action;

class BackupDatabaseTaskAdditionalFieldProvider extends AbstractAdditionalFieldProvider
{
    /**
     * Gets additional fields to render in the form to add/edit a task
     *
     * @param array<array<string>> $taskInfo
     * @param AbstractTask|null $task
     *
     * @return array<array<string>> array('fieldId' => array('code' => '', 'label' => '', 'cshKey' => '', 'cshLabel' => ''))
     */
    #[\Override] // todo-b:  must be compatible with AdditionalFieldProviderInterface::getAdditionalFields
    // (AbstractTask $task, SchedulerModuleController $schedulerModule): array
    public function getAdditionalFields(array &$taskInfo, $task, SchedulerModuleController $schedulerModule): array
    {
        $additionalFields = [];
        $currentSchedulerModuleAction = $schedulerModule->getCurrentAction();

        // Field: dbSource todo-c: Fields auslagern
        if (!isset($taskInfo['gjo_console']['dbSource']) && $task instanceof BackupDatabaseTask) {
            $taskInfo['gjo_console']['dbSource'] = '';
            if ($currentSchedulerModuleAction->equals(Action::EDIT)) {
                $taskInfo['gjo_console']['dbSource'] = $task->dbSource;
            }
        }

        $options = '';
        foreach ($GLOBALS['TYPO3_CONF_VARS']['DB']['Connections'] as $value => $dbConnectionOption) {

            $option = $value;
            if ($option == 'Default') {
                $option = Environment::getContext();
            }
            $options .= '<option value="' . $value . '" ' . ($value ==  $taskInfo['gjo_console']['dbSource'] ? 'selected' : '') . ' >' . $option . '</option>';
        }

        $fieldID = 'gjo_console_dbSource';
        $fieldCode = '<select class="form-control" name="tx_scheduler[gjo_console][dbSource]" id="' . $fieldID . '">' . $options . '</select>';

        $additionalFields[$fieldID] = ['code'     => $fieldCode, 'label'    => 'Source: '];

        // Field: dbTarget
        if (!isset($taskInfo['gjo_console']['dbTarget']) && $task instanceof BackupDatabaseTask) {
            $taskInfo['gjo_console']['dbTarget'] = '';
            if ($currentSchedulerModuleAction->equals(Action::EDIT)) {
                $taskInfo['gjo_console']['dbTarget'] = $task->dbTarget;
            }
        }
        $selected = ($taskInfo['gjo_console']['dbTarget'] == 'Backup') ? 'selected' : '';
        $options = '<option value="Backup" ' . $selected . ' > Backup </option>';
        foreach ($GLOBALS['TYPO3_CONF_VARS']['DB']['Connections'] as $value => $dbConnectionOption) {
            $option = $value;
            if ($option == 'Default') {
                $option = Environment::getContext();
            }
            $selected = ($taskInfo['gjo_console']['dbTarget'] == $value) ? 'selected' : '';
            $options .= '<option value="' . $value . '" ' . $selected . ' >' . $option . '</option>';
        }

        $fieldID = 'gjo_console_dbTarget';
        $fieldCode = '<select class="form-control" name="tx_scheduler[gjo_console][dbTarget]" id="' . $fieldID . '">' . $options . '</select>';

        $additionalFields[$fieldID] = ['code'     => $fieldCode, 'label'    => 'Target: '];

        // Field: email
        if (!isset($taskInfo['gjo_console']['email']) && $task instanceof BackupDatabaseTask) {
            $taskInfo['gjo_console']['email'] = '';
            if ($currentSchedulerModuleAction->equals(Action::ADD)) {
                $taskInfo['gjo_console']['email'] = $GLOBALS['BE_USER']->user['email'];
            }
            if ($currentSchedulerModuleAction->equals(Action::EDIT)) {
                $taskInfo['gjo_console']['email'] = $task->email;
            }
        }

        $fieldID = 'gjo_console_email';
        $fieldCode = '<input type="text" class="form-control" name="tx_scheduler[gjo_console][email]" id="' . $fieldID . '" value="' . htmlspecialchars((string)$taskInfo['gjo_console']['email']) . '" size="30">';

        $additionalFields[$fieldID] = [
            'code' => $fieldCode,
            'label' => 'Email: ',
        ];

        return $additionalFields;
    }

    /**
     * @param array<array<string>> $submittedData
     *
     * @return bool
     */
    #[\Override]
    public function validateAdditionalFields(array &$submittedData, SchedulerModuleController $schedulerModule): bool
    {
        $result = true;

        $submittedData['gjo_console']['email'] = trim((string)$submittedData['gjo_console']['email']);
        if (empty($submittedData['gjo_console']['email'])) {
            $this->addMessage('Please enter a Email', ContextualFeedbackSeverity::ERROR);
            $result = false;
        }

        return $result;
    }

    /**
     * @param array<array<string>> $submittedData
     */
    #[\Override]
    public function saveAdditionalFields(array $submittedData, AbstractTask $task): void
    {
        if ($task instanceof BackupDatabaseTask) {
            $task->dbSource = $submittedData['gjo_console']['dbSource'];
            $task->dbTarget = $submittedData['gjo_console']['dbTarget'];
            $task->email = $submittedData['gjo_console']['email'];
        }
    }
}
