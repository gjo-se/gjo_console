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

use TYPO3\CMS\Core\Core\Environment;
use TYPO3\CMS\Core\Type\ContextualFeedbackSeverity;
use TYPO3\CMS\Core\Utility\GeneralUtility;
use TYPO3\CMS\Scheduler\AbstractAdditionalFieldProvider;
use TYPO3\CMS\Scheduler\Controller\SchedulerModuleController;
use TYPO3\CMS\Scheduler\Task\AbstractTask;
use TYPO3\CMS\Scheduler\Task\Enumeration\Action;

class RestoreDatabaseTaskAdditionalFieldProvider extends AbstractAdditionalFieldProvider
{
    public const BACKUP_DIR = '/fileadmin/_temp_/Backup/';

    #[\Override]
    public function getAdditionalFields(array &$taskInfo, $task, SchedulerModuleController $schedulerModule)
    {
        $additionalFields = [];
        $currentSchedulerModuleAction = $schedulerModule->getCurrentAction();

        // Field: Available dumps
        if (!isset($taskInfo['gjo_console']['dbDump'])) {
            $taskInfo['gjo_console']['dbDump'] = '';
            if ($currentSchedulerModuleAction->equals(Action::EDIT)) {
                $taskInfo['gjo_console']['dbDump'] = $task->dbDump;
            }
        }

        $fileArrHelper = [];
        $fileArr = GeneralUtility::getAllFilesAndFoldersInPath($fileArrHelper, Environment::getPublicPath() . self::BACKUP_DIR);

        $options = '';
        foreach ($fileArr as $file) {
            $value = substr($file, strlen(Environment::getPublicPath() . self::BACKUP_DIR));
            $options .= '<option value="' . $value . '" ' . ($value ==  $taskInfo['gjo_console']['dbDump'] ? 'selected' : '') . ' >' . $value . '</option>';

        }

        $fieldID = 'gjo_console_dbDumps';
        $fieldCode = '<select class="form-control" name="tx_scheduler[gjo_console][dbDump]" id="' . $fieldID . '">' . $options . '</select>';

        $additionalFields[$fieldID] = ['code'     => $fieldCode, 'label'    => 'Verfügbare Dumps'];

//        // Field: dbTarget
        if (!isset($taskInfo['gjo_console']['dbTarget'])) {
            $taskInfo['gjo_console']['dbTarget'] = '';
            if ($currentSchedulerModuleAction->equals(Action::EDIT)) {
                $taskInfo['gjo_console']['dbTarget'] = $task->dbTarget;
            }
        }

        $options = '';
        foreach ($GLOBALS['TYPO3_CONF_VARS']['DB']['Connections'] as $value => $dbTargetOption) {
            // Prevent Testing-DB for Restore
            if(Environment::getContext() != 'Testing'){
                $option = $value;
                if($option == 'Default'){
                    $option = Environment::getContext();
                }
                $options .= '<option value="' . $value . '" ' . ($value ==  $taskInfo['gjo_console']['dbTarget'] ? 'selected' : '') . ' >' . $option . '</option>';
            }
        }

        $fieldID = 'gjo_console_dbTarget';
        $fieldCode = '<select class="form-control" name="tx_scheduler[gjo_console][dbTarget]" id="' . $fieldID . '">' . $options . '</select>';

        $additionalFields[$fieldID] = ['code'     => $fieldCode, 'label'    => 'Ziel Datenbank'];

        // Field: email
        if (!isset($taskInfo['gjo_console']['email'])) {
            $taskInfo['gjo_console']['email'] = '';
            if ($currentSchedulerModuleAction->equals(Action::ADD)) {
                $taskInfo['gjo_console']['email'] = $GLOBALS['BE_USER']->user['email'];
            }
            if ($currentSchedulerModuleAction->equals(Action::EDIT)) {
                $taskInfo['gjo_console']['email'] = $task->email;
            }
        }

        $fieldID = 'gjo_console_email';
        $fieldCode = '<input type="text" class="form-control" name="tx_scheduler[gjo_console][email]" id="' . $fieldID . '" value="' . htmlspecialchars((string) $taskInfo['gjo_console']['email']) . '" size="30">';

        $additionalFields[$fieldID] = [
            'code' => $fieldCode,
            'label' => 'Email: '
        ];

        return $additionalFields;
    }

    #[\Override]
    public function validateAdditionalFields(array &$submittedData, SchedulerModuleController $schedulerModule)
    {
        $result = true;

        $submittedData['gjo_console']['email'] = trim((string) $submittedData['gjo_console']['email']);
        if (empty($submittedData['gjo_console']['email'])) {
            $this->addMessage('Please enter a Email', ContextualFeedbackSeverity::ERROR);
            $result = false;
        }

        return $result;
    }

    /**
     * @param array $submittedData, AbstractTask $task
     *
     * @return void
     */
    #[\Override]
    public function saveAdditionalFields(array $submittedData, AbstractTask $task): void
    {
        $task->dbDump = $submittedData['gjo_console']['dbDump'];
        $task->dbTarget = $submittedData['gjo_console']['dbTarget'];
        $task->email = $submittedData['gjo_console']['email'];
    }
}
