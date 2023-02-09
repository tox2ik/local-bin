#!/bin/bash

api_key=$(< ~/.secrets/access-tokes/pastebin.com)


curl -d "api_paste_code=$(jq -sRr @uri)" \
     -d "api_dev_key=$api_key" \
     -d 'api_option=paste' 'https://pastebin.com/api/api_post.php'

echo
