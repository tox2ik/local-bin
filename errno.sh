#!/usr/bin/env bash

# Run your command

if [[ $1 =~ ^[0-9]+$ ]]; then
    s=$1
elif [[ $1 == man ]]; then
    man errno | grep '\<[0-9]\{1,\} [A-Z]' -A9
    exit
else
    "$@"
    s=$?
fi


case $s in
    0) ;;
    1) ;;
    2) echo "Exit code 2: Misuse of shell builtins" ;;
    126) echo "Exit code 126: Found but not executable (maybe EACCES=13)" ;;
    127) echo "Exit code 127: Not found (maybe ENOENT=2)" ;;
    128) echo "Exit code 128: Invalid exit argument" ;;
    *)
        if ((s > 128)); then
            sig=$((s-128))
            kill -l | sed  's/[0-9]\{1,\})/\n&/g'| sed '/^ *$/d; s/\t//; s/ $//' | column
            echo "Exit code $s: Process terminated by signal $sig"

        else
            errno.sh man | grep -e "\<$s [A-Z]" -A9
            echo
            echo "Exit code $s: Program-defined or errno"
            # Optionally, try to match to an errno manually:
            # Example for EACCES=13, ENOENT=2, ECANCELED=125, etc
            case $s in
                2) echo "Possible errno: ENOENT=2";;
                13) echo "Possible errno: EACCES=13";;
                125) echo "Possible errno: ECANCELED=125";;
                5) echo "Possible errno: EIO=5";;
            esac
        fi
        ;;
esac

