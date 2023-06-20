#!/usr/bin/php
<?php

// todo: strcmp(a, b)

$fn = basename($argv[0], '.php');

if (! function_exists($fn)) {
    fwrite($stderr = fopen('php://stderr', 'a'), "$fn does not seem like a valid PHP function.\n");
    fclose($stderr);
    exit(1);
}

if (count($argv) == 3) {
    echo $fn($argv[1], $argv[2]);

} elseif (count($argv) == 2) {
    $data = is_file($argv[1])
        ? file_get_contents($argv[1])
        : $argv[1];

    $res = $fn( $data );
    if (is_scalar($res)) echo $res ; else  print_r($res);
    //echo 
} else {
    //$h1 = fopen('r', STDIN);

    while ($line = fgets(STDIN)) {
        echo $fn($line);
        //print_r($fn(trim($line)));
    }
}

echo  PHP_EOL;
