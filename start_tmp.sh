#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
mkdir -p $DIR/transfer 
tmpfile=$(mktemp)
cp $DIR/sub_start_tmp.sh $tmpfile
chmod 755 $tmpfile
sleep 1
$tmpfile &
sleep 1
rm $tmpfile
