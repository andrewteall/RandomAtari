#!/usr/bin/env bash
NAME=$(echo $1 | cut -d'.' -f1)
LIST=$2
if [ -n "$LIST" ]; then
  LIST=-l$NAME.lst
  SYM=-s$NAME.sym
fi
dasm $1 $LIST $SYM -f3 -v5 -o$NAME.bin
mkdir -p bin
mv $NAME.bin bin/
if [ -n "$LIST" ]; then
  mv $NAME.lst bin/
  mv $NAME.sym bin/
fi
