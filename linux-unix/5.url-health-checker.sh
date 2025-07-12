#!/bin/bash

URL="https://jsonplaceholder.typicode.com/posts"
LOG_FILE="healthcheck.log"
REFRESH_TIME=300

while true;
do
  STATUS=$(curl -o /dev/null -s -w '%{http_code}' $URL)
  echo "$(date):: $STATUS" >> $LOG_FILE
  sleep $REFRESH_TIME # run every $REFRESH_TIME seconds once.
done
