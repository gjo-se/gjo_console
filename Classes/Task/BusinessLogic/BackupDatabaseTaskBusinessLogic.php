<?php

declare(strict_types=1);

namespace GjoSe\GjoConsole\Task\BusinessLogic;

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

use GjoSe\GjoConsole\Task\BackupDatabaseTask;
use TYPO3\CMS\Core\Core\Environment;

class BackupDatabaseTaskBusinessLogic extends AbstractTaskBusinessLogic
{
    public const string EMAIL_SUBJECT_BACKUP_DATABASE_TASK = 'BackupDatabaseTask';

    public const string EMAIL_TEMPLATE_BACKUP_DATABASE_TASK = 'BackupDatabaseTask';


    public function run(BackupDatabaseTask $backupDatabaseTask, string $dbSource, string $dbTarget, string $email): bool
    {
        $currentApplicationContext = '';
        $this->task = $backupDatabaseTask;
        $this->setConnection($dbSource);
        (getenv('IS_DDEV_PROJECT') == 'true') ? $currentApplicationContext = 'Development' : Environment::getContext();

        $backupDir = Environment::getPublicPath() . parent::BACKUP_DIR;
        if ($dbSource === 'Default') {
            $backupDir .= $currentApplicationContext;
            $filename = 'dump_' . $currentApplicationContext . '_for_' . $dbTarget . parent::DUMP_COMPLETE_FILE;
        } else {
            $backupDir .= $dbSource;
            $filename = 'dump_' . $dbSource . '_for_' . $dbTarget . parent::DUMP_COMPLETE_FILE;
        }

        if (!is_dir($backupDir . '/' . $this->getBackupDate())) {
            $cmd = 'mkdir ' . $backupDir . '/' . $this->getBackupDate();

            if (shell_exec($cmd . parent::NECESSARY_LINE_BREAK) === '' || shell_exec($cmd . parent::NECESSARY_LINE_BREAK) === '0' || shell_exec($cmd . parent::NECESSARY_LINE_BREAK) === false || shell_exec($cmd . parent::NECESSARY_LINE_BREAK) === null) {
                $this->sendMailTask(
                    $email,
                    self::EMAIL_TEMPLATE_BACKUP_DATABASE_TASK,
                    self::EMAIL_SUBJECT_BACKUP_DATABASE_TASK,
                    parent::ERROR,
                    'Can NOT make DIR - cmd:  ' . $cmd
                );
                // Log Error
                return false;
            }
        }

        $ignoredTablesMethodName = 'getIgnoredTablesOn';
        if ($dbSource === 'Default') {
            $ignoredTablesMethodName .= $currentApplicationContext;
        } else {
            $ignoredTablesMethodName .= $dbSource;
        }

        $ignoredTablesMethodName .= 'For';
        if ($dbTarget === 'Default') {
            $ignoredTablesMethodName .= $currentApplicationContext;
        } else {
            $ignoredTablesMethodName .= $dbTarget;
        }

        $ignoredTablesString = '';
        if (method_exists($this, $ignoredTablesMethodName)) {
            if ($this->$ignoredTablesMethodName()) {
                $ignoredTablesArr = [];
                foreach ($this->$ignoredTablesMethodName() as $ignoredTable) {
                    $ignoredTablesArr[] = '--ignore-table=' . $this->getDbName() . '.' . $ignoredTable;
                }

                $ignoredTablesString = implode(' ', $ignoredTablesArr);
            }
        } else {
            $this->sendMailTask(
                $email,
                self::EMAIL_TEMPLATE_BACKUP_DATABASE_TASK,
                self::EMAIL_SUBJECT_BACKUP_DATABASE_TASK,
                parent::ERROR,
                'ignoredTablesMethodName not exists:  ' . $ignoredTablesMethodName . ' - ' . 1575646335
            );

            // Log Error
            return false;
        }

        $cmd = $this->getPathToMySqlDump() . ' -u' . $this->getDbUser() . ' -p' . $this->getDbPassword() . ' -h' . $this->getDbHost() . ' ' . $this->getDbName() . self::DUMP_PARAMS_COMPLETE . ' ' . $ignoredTablesString . ' > ' . $backupDir . '/' . $this->getBackupDate() . '/' . $filename;

        // @todo-next-iteration:
        //  aktuell drauf verzichten, wenn dann mit Flag (Field), als entweder Struktur / Complete
        //        $cmd = $this->getPathToMySqlDump() . ' -u' . $this->getDbUser() . ' -p' . $this->getDbPassword() . ' -h' . $this->getDbHost() . ' ' . $this->getDbName() . parent::DUMP_PARAMS_ONLY_STRUCTURE . ' >  ' . $backupDir . '/' . $this->getBackupDate() . '/' . self::DUMP_STRUCTURE_FILE;

        if (shell_exec($cmd . parent::NECESSARY_LINE_BREAK) === '' || shell_exec($cmd . parent::NECESSARY_LINE_BREAK) === '0' || shell_exec($cmd . parent::NECESSARY_LINE_BREAK) === false || shell_exec($cmd . parent::NECESSARY_LINE_BREAK) === null) {
            $this->sendMailTask(
                $email,
                self::EMAIL_TEMPLATE_BACKUP_DATABASE_TASK,
                self::EMAIL_SUBJECT_BACKUP_DATABASE_TASK,
                parent::ERROR,
                'Can NOT mysqldump - cmd:  ' . $cmd
            );

            // Log Error
            return false;
        }

        // :
        // // :
        // // :
        // // :
        // // :

        $this->sendMailTask(
            $email,
            self::EMAIL_TEMPLATE_BACKUP_DATABASE_TASK,
            self::EMAIL_SUBJECT_BACKUP_DATABASE_TASK,
            parent::SUCCESS,
            'Build mysqldump for:  ' . $filename
        );

        // log success deploy
        return true;
    }
}
