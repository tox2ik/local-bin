hash=${1:-21232f297a57a5a743894a0e4a801fc3}
curl -s https://md5.gromweb.com/?md5=$hash | html2text -nobs -style pretty |\
sed \
-e '1,/The MD5 hash:/d' \
-e '/Feel free to provide/{s/.*//; q }' \
-e 's/was succesfully.*//' | tr \\n ' '
echo
