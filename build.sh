#!/usr/bin/env bash
NAME=$(echo $1 | cut -d'.' -f1)
LIST=$2
if [ -n "$LIST" ]; then
  LIST=-$NAME.txt
fi
dasm $1 $LIST -f3 -v5 -o$NAME.bin
