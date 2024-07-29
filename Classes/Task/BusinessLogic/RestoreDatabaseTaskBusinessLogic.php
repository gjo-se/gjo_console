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

use GjoSe\GjoConsole\Task\RestoreDatabaseTask;
use Psr\Log\LoggerAwareInterface;
use TYPO3\CMS\Core\Core\Environment;

//use TYPO3\CMS\Core\Utility\GeneralUtility;

/**
 * Restore Database with Dump
 */
class RestoreDatabaseTaskBusinessLogic extends AbstractTaskBusinessLogic
{
    public const string EMAIL_SUBJECT_RESTORE_DATABASE_TASK = 'RestoreDatabaseTask';
    public const string EMAIL_TEMPLATE_RESTORE_DATABASE_TASK = 'RestoreDatabaseTask';

    
    public function run(RestoreDatabaseTask $task, string $dbDump, string $dbTarget, string $email): bool
    {
        $this->task = $task;
        $this->setConnection($dbTarget);
        $backupFile = Environment::getPublicPath() . parent::BACKUP_DIR . $dbDump;

        if (!is_file($backupFile)) {
            $this->sendMailTask($email, self::EMAIL_TEMPLATE_RESTORE_DATABASE_TASK, self::EMAIL_SUBJECT_RESTORE_DATABASE_TASK, parent::ERROR, 'Dump NOT exists - cmd: ' . $backupFile);
            //            log Error, $logMessage = 'No dump exists: ' . $backupDir; $this->scheduler->log($logMessage, 2, 'gjo_console');
            return false;
        }

        $cmd = $this->getPathToMySql() . ' -u' . $this->getDbUser() . ' -p' . $this->getDbPassword() . ' -h' . $this->getDbHost() . parent::MYSQL_PARAMS . $this->getDbName() . ' < ' . $backupFile;

        if (!shell_exec($cmd . parent::NECESSARY_LINE_BREAK)) {
            $this->sendMailTask($email, self::EMAIL_TEMPLATE_RESTORE_DATABASE_TASK, self::EMAIL_SUBJECT_RESTORE_DATABASE_TASK, parent::ERROR, "Can NOT restore DataBase - cmd:  $cmd");
            // Log Error
            return false;
        }

        $this->sendMailTask($email, self::EMAIL_TEMPLATE_RESTORE_DATABASE_TASK, self::EMAIL_SUBJECT_RESTORE_DATABASE_TASK, parent::SUCCESS, "Restore Database:  $dbTarget with $dbDump");
        // log succsees restore
        return true;
    }
}
