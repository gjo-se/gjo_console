<?php

namespace GjoSe\GjoConsole\Task\BusinessLogic;

/***************************************************************
 *  created: 03.12.19 - 05:15
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
use GjoSe\GjoMail\Service\SendMailService;

abstract class AbstractTaskBusinessLogic
{

    public const NECESSARY_LINE_BREAK = ' && echo ok 2>&1';
    public const BACKUP_DIR = '/fileadmin/_temp_/Backup/';
    public const DUMP_PARAMS_ONLY_STRUCTURE = ' --single-transaction --no-data ';
    public const DUMP_PARAMS_COMPLETE = ' --opt --single-transaction ';
    public const DUMP_STRUCTURE_FILE = '_structure.sql';
    public const DUMP_COMPLETE_FILE = '_complete.sql';
    public const MYSQL_PARAMS = ' --default-character-set=utf8 ';
    public const KEEP_DUMPS = 5;
    public const DATE_FORMAT = "YmdHi";
    public const SUCCESS = 'success';
    public const ERROR = 'error';
    public const SMALLEST_TIMESTAMP = 201912051004;
    public const TARGET_BACKUP = 'Backup';

    protected $ignoredTablesBasic = ['be_sessions', 'fe_sessions', 'cache_md5params', 'cache_treelist', 'cf_cache_hash', 'cf_cache_hash_tags', 'cf_cache_imagesizes', 'cf_cache_imagesizes_tags', 'cf_cache_news_category', 'cf_cache_news_category_tags', 'cf_cache_pages', 'cf_cache_pages_tags', 'cf_cache_pagesection', 'cf_cache_pagesection_tags', 'cf_cache_rootline', 'cf_cache_rootline_tags', 'cf_extbase_datamapfactory_datamap', 'cf_extbase_datamapfactory_datamap_tags', 'cf_extbase_object', 'cf_extbase_object_tags', 'cf_extbase_reflection', 'cf_extbase_reflection_tags', 'cf_fluidcontent', 'cf_fluidcontent_tags', 'cf_flux', 'cf_flux_tags', 'cf_vhs_main', 'cf_vhs_main_tags', 'cf_vhs_markdown', 'cf_vhs_markdown_tags', 'tx_extensionmanager_domain_model_extension', 'tx_extensionmanager_domain_model_repository', 'tx_scheduler_task', 'tx_scheduler_task_group', 'sys_lockedrecords'];

    // TEST-DB ist der Master
    protected $ignoredTablesOnTestingForBackup = [];

    protected $ignoredTablesOnTestingForDevelopment = [
        // unnötig für DEV
        'sys_history',
        'sys_log',
    ];

    protected $ignoredTablesOnTestingForProduction = [
        // werden auf Production von Testing gezogen (sind auf Prod leer)
        'fe_groups',
        'fe_users',
        'tx_femanager_domain_model_log',
        'tx_gjoshop_domain_model_billing_address',
        'tx_gjoshop_domain_model_delivery_address',
        'tx_gjoshop_domain_model_order',
        'tx_gjoshop_domain_model_orderproducts',
        'tx_gjoshop_domain_model_payment_paypal',
        // sollen nicht im Production-Betrieb auftauchen
        'be_groups',
        'be_users',
        'tx_scheduler_task',
        'tx_scheduler_task_group',
        // unnötig für DB-Deployment
        'sys_history',
        'sys_log',
    ];

    // nur zu Testzwecken
    protected $ignoredTablesOnDevelopmentForRestoretest = ['sys-log'];

    protected $ignoredTablesOnDevelopmentForBackup = [];

    protected $ignoredTablesOnRestoretestForBackup = [];

    protected $ignoredTablesOnProductionForBackup = [];

    public $task = null;

    protected $connection = [];

    protected $dbUser = '';

    protected $dbPassword = '';

    protected $dbHost = '';

    protected $dbName = '';

    protected $backupDate = '';

    protected $pathToMySql = '';

    protected $pathToMySqlDump = '';

    /**
     * @return array
     */
    public function getIgnoredTablesOnTestingForBackup(): array
    {
        $ignoredTables = array_merge($this->ignoredTablesBasic, $this->ignoredTablesOnTestingForBackup);

        return $ignoredTables;
    }

    /**
     * @return array
     */
    public function getIgnoredTablesOnTestingForDevelopment(): array
    {
        $ignoredTables = array_merge($this->ignoredTablesBasic, $this->ignoredTablesOnTestingForDevelopment);

        return $ignoredTables;
    }

    /**
     * @return array
     */
    public function getIgnoredTablesOnTestingForProduction(): array
    {
        $ignoredTables = array_merge($this->ignoredTablesBasic, $this->ignoredTablesOnTestingForProduction);

        return $ignoredTables;
    }


    /**
     * @return array
     */
    public function getIgnoredTablesOnDevelopmentForRestoretest(): array
    {
        $ignoredTables = array_merge($this->ignoredTablesBasic, $this->ignoredTablesOnDevelopmentForRestoretest);

        return $ignoredTables;
    }

    /**
     * @return array
     */
    public function getIgnoredTablesOnDevelopmentForBackup(): array
    {
        $ignoredTables = array_merge($this->ignoredTablesBasic, $this->ignoredTablesOnDevelopmentForBackup);

        return $ignoredTables;
    }

    /**
     * @return array
     */
    public function getIgnoredTablesOnRestoretestForBackup(): array
    {
        $ignoredTables = array_merge($this->ignoredTablesBasic, $this->ignoredTablesOnRestoretestForBackup);

        return $ignoredTables;
    }

    /**
     * @return array
     */
    public function getIgnoredTablesOnProductionForBackup(): array
    {
        $ignoredTables = array_merge($this->ignoredTablesBasic, $this->ignoredTablesOnProductionForBackup);

        return $ignoredTables;
    }

    /**
     * @return array
     */
    public function getConnection()
    {
        return $this->connection;
    }

    /**
     * @param array $database
     *
     * @return void
     */
    public function setConnection($database): void
    {
        $this->connection = $GLOBALS['TYPO3_CONF_VARS']['DB']['Connections'][$database];
    }

    /**
     * @return string
     */
    public function getDbUser(): string
    {
        $this->dbUser = $this->getConnection()['user'];

        return $this->dbUser;
    }

    /**
     * @return string
     */
    public function getDbPassword(): string
    {
        $this->dbPassword = $this->getConnection()['password'];

        return $this->dbPassword;
    }

    /**
     * @return string
     */
    public function getDbHost(): string
    {
        $this->dbHost = $this->getConnection()['host'];

        return $this->dbHost;
    }

    /**
     * @return string
     */
    public function getDbName(): string
    {
        $this->dbName = $this->getConnection()['dbname'];

        return $this->dbName;
    }

    /**
     * @return false|string
     */
    public function getBackupDate()
    {
        if ($this->backupDate) {
            return $this->backupDate;
        } else {
            $this->backupDate = date(self::DATE_FORMAT);

            return $this->backupDate;
        }
    }

    protected function sendMailTask($email, $emailTemplate, $subject, $success = 'success', $message = '')
    {
        if (filter_var($email, FILTER_VALIDATE_EMAIL)) {

            $emailAddresses = ['toMail' => $email, 'toName' => $email];

            $subject = $subject . ' (' . $success . ')';

            if (Environment::isCli()) {
                $calledBy = 'CLI module dispatcher';
                $site = '-';
            } else {
                $calledBy = 'TYPO3 backend';
                $site = GeneralUtility::getIndpEnv('TYPO3_SITE_URL');
            }

            $assignMultiple = ['uid' => $this->task->getTaskUid(), 'success' => $success, 'calledBy' => $calledBy, 'site' => $site, 'siteName' => $GLOBALS['TYPO3_CONF_VARS']['SYS']['sitename'], 'tstamp' => date('Y-m-d H:i:s') . ' [' . time() . ']', 'start' => date('Y-m-d H:i:s', $this->task->getExecution()->getStart()) . ' [' . $this->task->getExecution()->getStart() . ']', 'end' => (empty($this->task->getExecution()->getEnd()) ? '-' : date('Y-m-d H:i:s',
                    $this->task->getExecution()->getEnd()) . ' [' . $this->task->getExecution()->getEnd() . ']'), 'interval' => $this->task->getExecution()->getInterval(), 'multiple' => ($this->task->getExecution()->getMultiple() ? 'yes' : 'no'), 'cronCmd' => ($this->task->getExecution()->getCronCmd() ?: 'not used'), 'message' => $message];

            try {
                /** @var SendMailService $sendMailService */
                $sendMailService = GeneralUtility::makeInstance(SendMailService::class);
                $sendMailService->sendMail($emailAddresses, $emailTemplate, $subject, $assignMultiple);

            } catch (\Exception $e) {
                throw new \Exception($e->getMessage(), 1575533775);
                // TODO: log: no sendmail possible
            }
        }
        // TODO: log: no valid email given
    }

    /**
     * @return string
     */
    public function getPathToMySql(): string
    {
        if (Environment::getContext()->isDevelopment()) {
            $this->pathToMySql = 'mysql';
        } else {
            $this->pathToMySql = 'mysql';
        }

        return $this->pathToMySql;
    }

    /**
     * @return string
     */
    public function getPathToMySqlDump(): string
    {
        if (Environment::getContext()->isDevelopment()) {
            $this->pathToMySqlDump = 'mysqldump';
        } else {
            $this->pathToMySqlDump = 'mysqldump';
        }

        return $this->pathToMySqlDump;
    }
}
