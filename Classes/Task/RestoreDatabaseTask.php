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
 * Restore Database with Dump
 */
class RestoreDatabaseTask extends BoilerplateAbstractTask
{
    const EMAIL_SUBJECT_RESTORE_DATABASE_TASK = 'RestoreDatabaseTask';
    const EMAIL_TEMPLATE_RESTORE_DATABASE_TASK = 'RestoreDatabaseTask';

    /**
     * @return bool
     */
    public function execute($source = '', $target = '', $backupDate = '', $withEmail = true, $email = '')
    {
        if($source){
            if($source == 'Default'){
                $dump = (string)GeneralUtility::getApplicationContext();
            }else{
                $dump = $source;
            }
            $this->dump = $dump . '/' . $backupDate . '/' . 'dump_' . $dump . '_for_' . $target . parent::DUMP_COMPLETE_FILE;
        }

        if($target){
            $this->dbTarget = $target;
        }

        if ($email) {
            $this->email = $email;
        }

        $this->setConnection($this->dbTarget);
        $backupFile = Environment::getPublicPath() . parent::BACKUP_DIR. $this->dump;

        // TODO: Filename stimmt nicht
        if (!is_file($backupFile)) {
            $this->sendMail($this->getEmailTemplate(), self::EMAIL_SUBJECT_RESTORE_DATABASE_TASK, parent::ERROR, "Dump NOT exists - cmd: " . $backupFile);
//            log Error, $logMessage = 'No dump exists: ' . $backupDir; $this->scheduler->log($logMessage, 2, 'gjo_console');
            return false;
        }

        $cmd = $this->getPathToMySql() . ' -u' . $this->getDbUser() . ' -p' . $this->getDbPassword() . ' -h' . $this->getDbHost() . parent::MYSQL_PARAMS . $this->getDbName() . ' < ' . $backupFile;

        if (!shell_exec($cmd . parent::NECESSARY_LINE_BREAK)) {
            $this->sendMail($this->getEmailTemplate(), self::EMAIL_SUBJECT_RESTORE_DATABASE_TASK, parent::ERROR, "Can NOT restore DataBase - cmd:  $cmd");
            // Log Error
            return false;
        }

        if($withEmail){
            $this->sendMail($this->getEmailTemplate(), self::EMAIL_SUBJECT_RESTORE_DATABASE_TASK, parent::SUCCESS, "Restore Database:  $this->dbTarget with $this->dump");
        }
        // log succsees restore
        return true;
    }

    public function getEmailTemplate()
    {
        $emailTemplate = array(
            'extensionKey' => $this->getExtensionKey(),
            'fileName'     => self::EMAIL_TEMPLATE_RESTORE_DATABASE_TASK
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
        $output = 'Dump: ' . $this->dump;
        $output .= ' in DataBase: ' . $this->dbTarget;

        return $output;
    }
}
