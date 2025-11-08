#!/usr/bin/env bash
{
[[ $# -eq 0 ]] &&
exiftool * ||
exiftool "$@";
} | grep ^Dura | aa 3 | awk-sum-hours
