<?php

namespace GjoSe\GjoScheduler\Task;

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


use TYPO3\CMS\Scheduler\Task\AbstractTask as CoreAbstractTask;
use TYPO3\CMS\Core\Core\Environment;
use GjoSe\GjoBoilerplate\Service\SendMailService;
use TYPO3\CMS\Core\Utility\GeneralUtility;

/**
 * Database Deployment selected Tables from TEST-DB to PROD-DB
 */
abstract class AbstractTask extends CoreAbstractTask
{

    const NECESSARY_LINE_BREAK = ' && echo ok 2>&1';
    const BACKUP_DIR = '/fileadmin/_temp_/Backup/';
    const DUMP_PARAMS_ONLY_STRUCTURE = ' --single-transaction --no-data ';
    const DUMP_PARAMS_COMPLETE = ' --opt --single-transaction ';
    const DUMP_STRUCTURE_FILE = '_structure.sql';
    const DUMP_COMPLETE_FILE = '_complete.sql';
    const MYSQL_PARAMS = ' --default-character-set=utf8 ';
    const KEEP_DUMPS = 5;
    const DATE_FORMAT = "YmdHi";
    const SUCCESS = 'success';
    const ERROR = 'error';
    const SMALLEST_TIMESTAMP = 201912051004;
    const TARGET_BACKUP = 'Backup';

    protected $ignoredTablesBasic = Array(
        'be_sessions',
        'fe_sessions',
        'cache_md5params',
        'cache_treelist',
        'cf_cache_hash',
        'cf_cache_hash_tags',
        'cf_cache_imagesizes',
        'cf_cache_imagesizes_tags',
        'cf_cache_news_category',
        'cf_cache_news_category_tags',
        'cf_cache_pages',
        'cf_cache_pages_tags',
        'cf_cache_pagesection',
        'cf_cache_pagesection_tags',
        'cf_cache_rootline',
        'cf_cache_rootline_tags',
        'cf_extbase_datamapfactory_datamap',
        'cf_extbase_datamapfactory_datamap_tags',
        'cf_extbase_object',
        'cf_extbase_object_tags',
        'cf_extbase_reflection',
        'cf_extbase_reflection_tags',
        'cf_fluidcontent',
        'cf_fluidcontent_tags',
        'cf_flux',
        'cf_flux_tags',
        'cf_vhs_main',
        'cf_vhs_main_tags',
        'cf_vhs_markdown',
        'cf_vhs_markdown_tags',
        'tx_extensionmanager_domain_model_extension',
        'tx_extensionmanager_domain_model_repository',
        'sys_lockedrecords'
    );

    // TEST-DB ist der Master
    protected $ignoredTablesOnTestingForBackup = Array(
        // alle in Basics
    );

    protected $ignoredTablesOnTestingForDevelopment = Array(
        // sollen nicht im Development-Betrieb auftauchen
        'tx_scheduler_task',
        'tx_scheduler_task_group',
        // unnötig für DEV
        'sys_history',
        'sys_log'
    );

    protected $ignoredTablesOnTestingForProduction = Array(
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
        'sys_log'
    );

    // nur zu Testzwecken
    protected $ignoredTablesOnDevelopmentForRestoretest = Array(
        'sys-log'
    );

    protected $ignoredTablesOnDevelopmentForBackup = Array();

    protected $ignoredTablesOnRestoretestForBackup = Array();

    protected $ignoredTablesOnProductionForBackup = Array(
        // Backup before Deployment
    );



    protected $connection = array();

    protected $dbUser = '';

    protected $dbPassword = '';

    protected $dbHost = '';

    protected $dbName = '';

    protected $dbSource = '';

    protected $dbTarget = '';

    protected $backupDate = '';

    protected $pathToMySql = '';

    protected $pathToMySqlDump = '';

    protected $email = '';

    /**
     * @var SendMailService
     */
    protected $sendMailService;

    /**
     * Injects the SendMailService into the class.
     *
     * @param SendMailService $sendMailService
     */
    public function injectSendMailService(SendMailService $sendMailService)
    {
        $this->sendMailService = $sendMailService;
    }

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
     * @param array $connection
     *
     * @return void
     */
    public function setConnection($database)
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

    /**
     * @param false|string $backupDate
     *
     * @return void
     */
    public function setBackupDate($backupDate)
    {
        $this->backupDate = $backupDate;
    }

    protected function sendMail($emailTemplate, $subject, $success = 'success', $message = '')
    {
        if (filter_var($this->email, FILTER_VALIDATE_EMAIL)) {

            $emailAddresses = array(
                'toMail'   => $this->email,
                'toName'   => $this->email,
                'fromMail' => $GLOBALS['TYPO3_CONF_VARS']['MAIL']['defaultMailFromAddress'],
                'fromName' => $GLOBALS['TYPO3_CONF_VARS']['MAIL']['defaultMailFromName']
            );

            $subject = $subject . ' (' . $success . ')';

            if (TYPO3_REQUESTTYPE & TYPO3_REQUESTTYPE_CLI) {
                $calledBy = 'CLI module dispatcher';
                $site     = '-';
            } else {
                $calledBy = 'TYPO3 backend';
                $site     = GeneralUtility::getIndpEnv('TYPO3_SITE_URL');
            }

            $assignMultiple = array(
                'uid'         => $this->taskUid,
                'success'     => $success,
                'calledBy'    => $calledBy,
                'site'        => $site,
                'siteName'    => $GLOBALS['TYPO3_CONF_VARS']['SYS']['sitename'],
                'tstamp'      => date('Y-m-d H:i:s') . ' [' . time() . ']',
                'maxLifetime' => $this->scheduler->extConf['maxLifetime'],
                'start'       => date('Y-m-d H:i:s', $this->getExecution()->getStart()) . ' [' . $this->getExecution()->getStart() . ']',
                'end'         => (empty($this->getExecution()->getEnd()) ? '-' : date('Y-m-d H:i:s',
                        $this->getExecution()->getEnd()) . ' [' . $this->getExecution()->getEnd() . ']'),
                'interval'    => $this->getExecution()->getInterval(),
                'multiple'    => ($this->getExecution()->getMultiple() ? 'yes' : 'no'),
                'cronCmd'     => ($this->getExecution()->getCronCmd() ? $this->getExecution()->getCronCmd() : 'not used'),
                'message'     => $message
            );
            try {
                $this->sendMailService->sendMail($emailAddresses, $emailTemplate, $subject, $assignMultiple);
            } catch (\Exception $e) {
                //                throw new \TYPO3\CMS\Core\Exception($e->getMessage(), 1575533775);
                // log: no sendmail possible
            }
        }
            // TODO: log: no valid email given
    }

    public function getExtensionKey()
    {
        $extensionKey = '';
        if (strpos(__CLASS__, '\\') !== false) {
            $classNameParts = explode('\\', __CLASS__, 4);
            $extensionKey   = GeneralUtility::camelCaseToLowerCaseUnderscored($classNameParts[1]);
        }

        return $extensionKey;
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
