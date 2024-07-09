<?php

namespace GjoSe\GjoConsole\Task;

/***************************************************************
 *  created: 03.12.19 - 12:13
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
use function GuzzleHttp\Psr7\_parse_request_uri;
use TYPO3\CMS\Core\Utility\File\ExtendedFileUtility;
use TYPO3\CMS\Core\Utility\GeneralUtility;


/**
 * A cleanup task to delete old (unused) dumps.
 *
 * Note: There is no rollback for this cleanup
 *
 * It takes the following options:
 *
 * * keepDumps - The number of dumps (for Database) to keep.
 *
 */
class CleanupDumpsTask extends BoilerplateAbstractTask
{
    const EMAIL_TEMPLATE_CLEANUP_DUMPS_TASK = 'CleanupDumpsTask';
    const EMAIL_SUBJECT_CLEANUP_DUMPS_TASK = 'CleanupDumpsTask';

    public function execute($backup = '')
    {
        if($backup){
            $backupPath = Environment::getPublicPath() . parent::BACKUP_DIR . $backup . '/';
        }else {
            $backupPath = Environment::getPublicPath() . parent::BACKUP_DIR . $this->backupPath . '/';
        }

        $cmd = "if [ -d $backupPath ]; then find $backupPath. -maxdepth 1 -type d -exec basename {} \; ; fi";

        $allDumpsList = shell_exec($cmd . parent::NECESSARY_LINE_BREAK);
        $allDumps = preg_split('/\s+/', $allDumpsList, -1, PREG_SPLIT_NO_EMPTY);

        $removableDumps = array_map('trim', array_filter($allDumps, function ($dump) {
            return $dump !== '.' && $dump !== 'ok';
        }));

        sort($removableDumps);
        $removeFolders = array_slice($removableDumps, 0, count($removableDumps) - parent::KEEP_DUMPS);

        $removeFiles = array();
        $fileArr = array();
        $fileArrHelper = array();
        foreach ($removeFolders as $removeFolder) {

            $fileArr = GeneralUtility::getAllFilesAndFoldersInPath($fileArrHelper, $backupPath . $removeFolder);

            if($fileArr){
                foreach ($fileArr as $file) {
                    if($file == $backupPath . $removeFolder . '/' . parent::DUMP_STRUCTURE_FILE || $file == $backupPath . $removeFolder . '/' . parent::DUMP_COMPLETE_FILE){
                        if(!unlink($file)){
                            $this->sendMail($this->getEmailTemplate(), self::EMAIL_SUBJECT_CLEANUP_DUMPS_TASK, parent::ERROR, "Can NOT unlink File $file");
                            //log error
                            return false;
                        }
                    }
                }
            }

            if(is_numeric($removeFolder) && $removeFolder >= parent::SMALLEST_TIMESTAMP){

                if(GeneralUtility::getFilesInDir($backupPath . $removeFolder)){
                    $this->sendMail($this->getEmailTemplate(), self::EMAIL_SUBJECT_CLEANUP_DUMPS_TASK, parent::ERROR, "Can NOT remove Dir $backupPath . $removeFolder");
                    // log error
                    return false;
                }else {
                    rmdir($backupPath . $removeFolder);
                }
            }
        }

        $this->sendMail($this->getEmailTemplate(), self::EMAIL_SUBJECT_CLEANUP_DUMPS_TASK, parent::SUCCESS, count($removeFolders) . " Dumps removed");
        // log success
        return true;
    }

    public function getEmailTemplate()
    {
        $emailTemplate = array(
            'extensionKey' => $this->getExtensionKey(),
            'fileName'     => self::EMAIL_TEMPLATE_CLEANUP_DUMPS_TASK
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
        return 'Backup-Path: ' . $this->backupPath;
    }
}
