<?php

namespace GjoSe\GjoScheduler\Task;

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

use GjoSe\GjoBoilerplate\Service\SendMailService;
use GjoSe\GjoShop\Service\ProductService;
use TYPO3\CMS\Core\Utility\GeneralUtility;

/**
 * Database Deployment
 */
class DeploymentDatabaseTask extends BoilerplateAbstractTask
{

    const EMAIL_TEMPLATE_DEPLOYMENT_DATABASE_TASK = 'DeploymentDatabaseTask';
    const EMAIL_SUBJECT_DEPLOYMENT_DATABASE_TASK = 'DeploymentDatabaseTask';

    /**
     * @return bool
     */
    public function execute()
    {
        $this->objectManager = GeneralUtility::makeInstance('TYPO3\CMS\Extbase\Object\ObjectManager');
        $backupDatabaseTask  = $this->objectManager->get(BackupDatabaseTask::class);
        $restoreDatabaseTask = $this->objectManager->get(RestoreDatabaseTask::class);

        // backup Source for Target
        if (!$backupDatabaseTask->execute($this->dbSource, $this->dbTarget, false, $this->email)) {
            $this->sendMail($this->getEmailTemplate(), self::EMAIL_SUBJECT_DEPLOYMENT_DATABASE_TASK, parent::ERROR,
                'Can NOT backup Source DB: ' . $this->dbSource . ' - ' . 1575646227);
            // log
            return false;
        }

        // backup Target for Backup
        $backupDate = $backupDatabaseTask->execute($this->dbTarget, parent::TARGET_BACKUP, false, $this->email);
        if (!$backupDate) {
            $this->sendMail($this->getEmailTemplate(), self::EMAIL_SUBJECT_DEPLOYMENT_DATABASE_TASK, parent::ERROR,
                'Can NOT backup Source DB: ' . $this->dbTarget . ' - ' . 1575646235);
            // log
            return false;
        }

        // restore Target
        if (!$restoreDatabaseTask->execute($this->dbSource, $this->dbTarget, $backupDate, false, $this->email)) {
            $this->sendMail($this->getEmailTemplate(), self::EMAIL_SUBJECT_DEPLOYMENT_DATABASE_TASK, parent::ERROR,
                'Can NOT restore Target DB: ' . $this->dbTarget . ' - ' . 1575646275);
            // log
            return false;
        }

        $this->sendMail($this->getEmailTemplate(), self::EMAIL_SUBJECT_DEPLOYMENT_DATABASE_TASK, parent::SUCCESS,
            'Deployment successful: ' . $this->dbSource . ' in ' . $this->dbTarget);

        // log succsees deploy
        return true;
    }

    /**
     * Output the selected tables
     *
     * @return string
     */
    public function getAdditionalInformation()
    {
        return $this->dbSource . ' in ' . $this->dbTarget;
    }

    public function getEmailTemplate()
    {
        $emailTemplate = array(
            'extensionKey' => $this->getExtensionKey(),
            'fileName'     => self::EMAIL_TEMPLATE_DEPLOYMENT_DATABASE_TASK
        );

        return $emailTemplate;
    }
}
