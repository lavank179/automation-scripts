#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]];
then
  echo "USAGE: `basename $0` [FileToBeParsed] [ResultsFile]"
  exit 0
fi


INPUT_FILE=$1
if [[ "$INPUT_FILE" == "" ]]; then
  INPUT_FILE="/var/log/syslog"
fi

OUTPUT_FILE=$2
if [[ "$INPUT_FILE" == "" ]]; then
  INPUT_FILE="f.log"
fi

while read -r line;
do
  echo "$line" | grep --color -i -E "error|failed" | grep -v "warn" >> "ftemp.log";
done < $INPUT_FILE

uniq ftemp.log > $OUTPUT_FILE
rm -f ftemp.log