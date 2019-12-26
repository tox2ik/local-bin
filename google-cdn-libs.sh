#!/bin/sh
curl -s https://developers.google.com/speed/libraries/ |
html2text -width 120 -style pretty -nobs  |
sed -e '0,/^Libraries/d; /Troubleshooting/,$d; ' |
php -R 'echo htmlspecialchars_decode($argn) . PHP_EOL;' 
