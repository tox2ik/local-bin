#!/usr/bin/php
<?php 

if (count($argv) == 2) {

    print_r(unserialize(is_file($argv[1])
        ? file_get_contents($argv[1])
        : $argv[1]
    ));
} else {
	print_r(unserialize(trim(fgets(STDIN))));
}

echo  PHP_EOL;
