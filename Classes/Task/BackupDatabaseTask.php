<?php

declare(strict_types=1);

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

use TYPO3\CMS\Scheduler\Task\AbstractTask;
use TYPO3\CMS\Core\Utility\GeneralUtility;
use GjoSe\GjoConsole\Task\BusinessLogic\BackupDatabaseTaskBusinessLogic;

class BackupDatabaseTask extends AbstractTask
{
    public $dbSource = '';

    public $dbTarget = '';

    public $email = '';

    /**
     * @return bool
     */
    #[\Override]
    public function execute(): bool
    {
        $businessLogic = GeneralUtility::makeInstance(BackupDatabaseTaskBusinessLogic::class);
        return $businessLogic->run($this, $this->dbSource, $this->dbTarget, $this->email);
    }
}
