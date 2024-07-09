<?php

use TYPO3\CMS\Core\Utility\ArrayUtility;

if (PHP_SAPI != 'cli') {
    exit;
}

define('TYPO3_cliMode', true);

$arguments = $argv;
if (!isset($arguments[1])) {
    print "No key defined.\n";
    exit;
}

require_once('typo3_src/typo3/sysext/core/Classes/Utility/ArrayUtility.php');

$key    = $arguments[1];
$system = isset($arguments[2]) ? $arguments[2] : null;

if ($system) {
    $config = require_once('config/' . strtoupper($system) . '/LocalConfiguration.php');
} else {
    $config = require_once('web/typo3conf/LocalConfiguration.php');
}

try {
    $value = ArrayUtility::getValueByPath($config, $key, '.');

    if (gettype($value) == 'string') {
        print $value;
    }
} catch (Exception $e) {
    print '';
}