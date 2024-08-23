<?php

declare(strict_types=1);

namespace GjoSe\GjoConsole\Task\BusinessLogic;

use GjoSe\GjoMail\Service\SendMailService;
use Symfony\Component\Mailer\Exception\TransportException;
use TYPO3\CMS\Core\Core\Environment;
use TYPO3\CMS\Core\Utility\GeneralUtility;
use TYPO3\CMS\Scheduler\Task\AbstractTask;

abstract class AbstractTaskBusinessLogic
{
    public const string NECESSARY_LINE_BREAK = ' && echo ok 2>&1';

    public const string BACKUP_DIR = '/fileadmin/_temp_/Backup/';

    public const string DUMP_PARAMS_ONLY_STRUCTURE = ' --single-transaction --no-data ';

    public const string DUMP_PARAMS_COMPLETE = ' --opt --single-transaction ';

    public const string DUMP_STRUCTURE_FILE = '_structure.sql';

    public const string DUMP_COMPLETE_FILE = '_complete.sql';

    public const string MYSQL_PARAMS = ' --default-character-set=utf8 ';

    public const int KEEP_DUMPS = 5;

    public const string DATE_FORMAT = 'YmdHi';

    public const string SUCCESS = 'success';

    public const string ERROR = 'error';

    public const int SMALLEST_TIMESTAMP = 201912051004;

    public const string TARGET_BACKUP = 'Backup';

    public AbstractTask $task;

    /**
     * @var array<string>
     */
    protected array $ignoredTablesBasic = [
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
        'tx_scheduler_task',
        'tx_scheduler_task_group',
        'sys_lockedrecords',
    ];

    /**
     * TEST-DB is Master
     * @var array<string>
     */
    protected array $ignoredTablesOnTestingForBackup = [];

    /**
     * not used on DEV
     * @var array<string>
     */
    protected array $ignoredTablesOnTestingForDevelopment = [
        'sys_history',
        'sys_log',
    ];

    /**
     * // on PROD: empty, get Data from TEST
     * @var array<string>
     */
    protected array $ignoredTablesOnTestingForProduction = [
        'fe_groups',
        'fe_users',
        'tx_femanager_domain_model_log',
        'be_groups',
        'be_users',
        'tx_scheduler_task',
        'tx_scheduler_task_group',
        'sys_history',
        'sys_log',
    ];

    /**
     * only for Testing
     * @var array<string>
     */
    protected array $ignoredTablesOnDevelopmentForRestoretest = [
        'sys-log',
    ];

    /**
     * @var array<string>
     */
    protected array $ignoredTablesOnDevelopmentForBackup = [];

    /**
     * @var array<string>
     */
    protected array $ignoredTablesOnRestoretestForBackup = [];

    /**
     * @var array<string>
     */
    protected array $ignoredTablesOnProductionForBackup = [];

    /**
     * @var array<string>
     */
    protected array $connection = [];

    protected string $dbUser = '';

    protected string $dbPassword = '';

    protected string $dbHost = '';

    protected string $dbName = '';

    protected string $backupDate = '';

    protected string $pathToMySql = '';

    protected string $pathToMySqlDump = '';

    /**
     * @return array<string>
     */
    public function getIgnoredTablesOnTestingForBackup(): array
    {
        return array_merge($this->ignoredTablesBasic, $this->ignoredTablesOnTestingForBackup);
    }

    /**
     * @return array<string>
     */
    public function getIgnoredTablesOnTestingForDevelopment(): array
    {
        return array_merge($this->ignoredTablesBasic, $this->ignoredTablesOnTestingForDevelopment);
    }

    /**
     * @return array<string>
     */
    public function getIgnoredTablesOnTestingForProduction(): array
    {
        return array_merge($this->ignoredTablesBasic, $this->ignoredTablesOnTestingForProduction);
    }

    /**
     * @return array<string>
     */
    public function getIgnoredTablesOnDevelopmentForRestoretest(): array
    {
        return array_merge($this->ignoredTablesBasic, $this->ignoredTablesOnDevelopmentForRestoretest);
    }

    /**
     * @return array<string>
     */
    public function getIgnoredTablesOnDevelopmentForBackup(): array
    {
        return array_merge($this->ignoredTablesBasic, $this->ignoredTablesOnDevelopmentForBackup);
    }

    /**
     * @return array<string>
     */
    public function getIgnoredTablesOnRestoretestForBackup(): array
    {
        return array_merge($this->ignoredTablesBasic, $this->ignoredTablesOnRestoretestForBackup);
    }

    /**
     * @return array<string>
     */
    public function getIgnoredTablesOnProductionForBackup(): array
    {
        return array_merge($this->ignoredTablesBasic, $this->ignoredTablesOnProductionForBackup);
    }

    public function getDbUser(): string
    {
        $this->dbUser = $this->getConnection()['user'];

        return $this->dbUser;
    }

    /**
     * @return array<string>
     */
    public function getConnection(): array
    {
        return $this->connection;
    }

    public function setConnection(string $database): void
    {
        $this->connection = $GLOBALS['TYPO3_CONF_VARS']['DB']['Connections'][$database];
    }

    public function getDbPassword(): string
    {
        $this->dbPassword = $this->getConnection()['password'];

        return $this->dbPassword;
    }

    public function getDbHost(): string
    {
        $this->dbHost = $this->getConnection()['host'];

        return $this->dbHost;
    }

    public function getDbName(): string
    {
        $this->dbName = $this->getConnection()['dbname'];

        return $this->dbName;
    }

    public function getBackupDate(): string
    {
        if ($this->backupDate !== '' && $this->backupDate !== '0') {
            return $this->backupDate;
        }

        $this->backupDate = date(self::DATE_FORMAT);

        return $this->backupDate;

    }

    public function getPathToMySql(): string
    {
        $this->pathToMySql = 'mysql';

        return $this->pathToMySql;
    }

    public function getPathToMySqlDump(): string
    {
        $this->pathToMySqlDump = 'mysqldump';

        return $this->pathToMySqlDump;
    }

    /**
     * @throws TransportException
     */
    protected function sendMailTask(string $email, string $emailTemplate, string $subject, string $success = 'success', string $message = ''): void
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

            $assignMultiple = [
                'uid' => $this->task->getTaskUid(),
                'success' => $success,
                'calledBy' => $calledBy,
                'site' => $site,
                'siteName' => $GLOBALS['TYPO3_CONF_VARS']['SYS']['sitename'],
                'tstamp' => date('Y-m-d H:i:s') . ' [' . time() . ']',
                'start' => date('Y-m-d H:i:s', $this->task->getExecution()->getStart()) . ' [' . $this->task->getExecution()->getStart() . ']',
                'end' => (empty($this->task->getExecution()->getEnd()) ? '-' : date('Y-m-d H:i:s', $this->task->getExecution()->getEnd()) . ' [' . $this->task->getExecution()->getEnd() . ']'),
                'interval' => $this->task->getExecution()->getInterval(),
                'multiple' => ($this->task->getExecution()->getMultiple() ? 'yes' : 'no'),
                'cronCmd' => ($this->task->getExecution()->getCronCmd() ?: 'not used'),
                'message' => $message,
            ];

            try {
                /** @var SendMailService $sendMailService */
                // DI NOT in Scheduler
                $sendMailService = GeneralUtility::makeInstance(SendMailService::class);
                $sendMailService->sendMail($emailAddresses, $emailTemplate, $subject, $assignMultiple);

            } catch (TransportException $e) {
                throw new TransportException($e->getMessage(), 1575533775, $e);
                // @todo-next-iteration: log & try/catch: no sendmail possible
            }
        }

        // @todo-next-iteration: log: no valid email given
    }
}
