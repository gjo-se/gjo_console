<?php

namespace GjoSe\GjoConsole\Task;

/***************************************************************
 *  created: 29.11.19 - 06:12
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
use TYPO3\CMS\Core\Utility\GeneralUtility;

/**
 * Database Deployment selected Tables from TEST-DB to PROD-DB
 */
class BackupDatabaseTask extends AbstractTask
{

    const EMAIL_SUBJECT_BACKUP_DATABASE_TASK = 'BackupDatabaseTask';
    const EMAIL_TEMPLATE_BACKUP_DATABASE_TASK = 'BackupDatabaseTask';

    /**
     * @return bool
     */
    public function execute($source = '', $target = '', $withEmail = true, $email = '')
    {
        if ($source) {
            $this->dbSource = $source;
        }
        $this->setConnection($this->dbSource);

        if ($target) {
            $this->dbTarget = $target;
        }

        if ($email) {
            $this->email = $email;
        }

        $currentApplicationContext = Environment::getContext();

        $backupDir = Environment::getPublicPath() . parent::BACKUP_DIR;
        if ($this->dbSource == 'Default') {
            $backupDir .= (string)$currentApplicationContext;
            $filename = 'dump_' . (string)$currentApplicationContext . '_for_' . $this->dbTarget . parent::DUMP_COMPLETE_FILE;
        } else {
            $backupDir .= $this->dbSource;
            $filename = 'dump_' . $this->dbSource . '_for_' . $this->dbTarget . parent::DUMP_COMPLETE_FILE;
        }

        if (!is_dir($backupDir . '/' . $this->getBackupDate())) {
            $cmd = 'mkdir ' . $backupDir . '/' . $this->getBackupDate();
            if (!shell_exec($cmd . parent::NECESSARY_LINE_BREAK)) {
                $this->sendMail($this->getEmailTemplate(), self::EMAIL_SUBJECT_BACKUP_DATABASE_TASK, parent::ERROR,
                    "Can NOT make DIR - cmd:  $cmd");

                // Log Error
                return false;
            }
        }

        $ignoredTablesMethodName = 'getIgnoredTablesOn';
        if ($this->dbSource == 'Default') {
            $ignoredTablesMethodName .= (string)$currentApplicationContext;
        } else {
            $ignoredTablesMethodName .= $this->dbSource;
        }
        $ignoredTablesMethodName .= 'For';
        if ($this->dbTarget == 'Default') {
            $ignoredTablesMethodName .= (string)$currentApplicationContext;
        } else {
            $ignoredTablesMethodName .= $this->dbTarget;
        }

        $ignoredTablesString = '';
        if (method_exists($this, $ignoredTablesMethodName)) {
            if ($this->$ignoredTablesMethodName()) {
                $ignoredTablesArr = array();
                foreach ($this->$ignoredTablesMethodName() as $ignoredTable) {
                    $ignoredTablesArr[] = '--ignore-table=' . $this->getDbName() . '.' . $ignoredTable;
                }
                $ignoredTablesString = implode(' ', $ignoredTablesArr);
            }
        } else {
            $this->sendMail($this->getEmailTemplate(), self::EMAIL_SUBJECT_BACKUP_DATABASE_TASK, parent::ERROR,
                "ignoredTablesMethodName not exists:  $ignoredTablesMethodName" . ' - ' . 1575646335);
            // Log Error
            return false;
        }


        $cmd = $this->getPathToMySqlDump() . ' -u' . $this->getDbUser() . ' -p' . $this->getDbPassword() . ' -h' . $this->getDbHost() . ' ' . $this->getDbName() . self::DUMP_PARAMS_COMPLETE . ' ' . $ignoredTablesString . ' > ' . $backupDir . '/' . $this->getBackupDate() . '/' . $filename;

        //        TODO: aktuell drauf verzeichten, wenn dann mit Flag (Field), als entweder Structur / Complete
        //        $cmd = $this->getPathToMySqlDump() . ' -u' . $this->getDbUser() . ' -p' . $this->getDbPassword() . ' -h' . $this->getDbHost() . ' ' . $this->getDbName() . parent::DUMP_PARAMS_ONLY_STRUCTURE . ' >  ' . $backupDir . '/' . $this->getBackupDate() . '/' . self::DUMP_STRUCTURE_FILE;

        if (!shell_exec($cmd . parent::NECESSARY_LINE_BREAK)) {
            $this->sendMail($this->getEmailTemplate(), self::EMAIL_SUBJECT_BACKUP_DATABASE_TASK, parent::ERROR,
                "Can NOT mysqldump - cmd:  $cmd");

            // Log Error
            return false;
        }

        if ($withEmail) {
            $this->sendMail($this->getEmailTemplate(), self::EMAIL_SUBJECT_BACKUP_DATABASE_TASK, parent::SUCCESS,
                "Build mysqldump for:  $filename");
        }

        // log succsees deploy
        return $this->getBackupDate();
    }

    public function getEmailTemplate()
    {
        $emailTemplate = array(
            'extensionKey' => $this->getExtensionKey(),
            'fileName'     => self::EMAIL_TEMPLATE_BACKUP_DATABASE_TASK
        );

        return $emailTemplate;
    }

    /**
     * Output the selected tables
     *
     * @return string
     */
    public function getAdditionalInformation()
    {
        return 'Source: ' . $this->dbSource . ' - Target: ' . $this->dbTarget;
    }
}
