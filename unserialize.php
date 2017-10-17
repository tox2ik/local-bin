#!/usr/bin/php
<?php 

$fn = basename($argv[0], '.php');

if (! function_exists($fn)) {
    fwrite($stderr = fopen('php://stderr', 'a'), "$fn does not seem like a valid PHP function.\n");
    fclose($stderr);
    exit(1);
}

if (count($argv) == 2) {
    print_r($fn(
        is_file($argv[1])
            ? file_get_contents($argv[1])
            : $argv[1]
    ));
} else {
	print_r($fn(trim(fgets(STDIN))));
}

echo  PHP_EOL;
