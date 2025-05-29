#!/bin/bash

# This script backs up the /etc directory to a with a timestamped filename and compresses it.
USER=ubuntu
BACKUP_DIR="etc"

DESTINATION="/home/$USER/backup"
if [[ ! -d "$DESTINATION" ]]; then
  echo "$DESTINATION doesn't exist. creating one"
  mkdir "$DESTINATION"
fi

# current date&time in UTC format: 2025-01-01T00:00:01ZUTC
BACKED_UP_FOLDER="$DESTINATION/$(date -u '+%Y-%m-%dT%H.%M.%S%Z')"

mkdir "$BACKED_UP_FOLDER"
cp -r "/$BACKUP_DIR" "/$BACKED_UP_FOLDER"
