#!/usr/bin/env bash
rand () 
{ 
    local tall=0;
    while [ ${#tall} -lt 5 ]; do
        tall=`dd if=/dev/urandom bs=512 count=33 2>/dev/null | tr -c '[:graph:]' ' ' |md5sum.exe  |tr -d '7-9a-z0*-' | cut -c 3-7`;
    done;
    echo $tall
}
dice () 
{ 
    moo=`rand`;
    while [ $moo -gt 666666 ]; do
        moo=`rand`;
    done;
    echo $moo
}
dice_n () 
{ 
    [[ "`check_randomOrg`" = offline ]] && for i in {0..99};
    do
        dice;
    done | sort -R | tail -n $1 || randOrg $1
}
diceware () 
{ 
    dice_n $1 | xargs -I% grep % ~/tmp/diceware
}
dice_fetch () 
{ 
    url=http://world.std.com/~reinhold/diceware.wordlist.asc;
    if [ ! -d ~/tmp ]; then
        mkdir ~/tmp;
    fi;
    if [ ! -f ~/tmp/diceware ]; then
        curl $url | grep '^[0-9]' > ~/tmp/diceware;
    fi
}
randOrg () 
{ 
    local n=$(( $1 * 5 ));
    if [ "`check_randomOrg`" == "online" ]; then
        curl -silent 'http://www.random.org/integers/?num='${n}'&min=1&max=6&col=5&base=10&format=plain&rnd=new' 2> /dev/null | grep '^[0-9]';
    fi | tr -d ' \t'
}
check_randomOrg () 
{ 
    ping -w 2000 67.23.25.127 -n 1 2>&1 > /dev/null && echo online || echo offline
}

diceware $1
