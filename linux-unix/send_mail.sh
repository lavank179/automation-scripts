#!/bin/bash

API_KEY=""  # Your SendGrid API key
TO=$1
FROM=""
SUBJECT=$2
BODY=$2
ATTACHMENT_NAME=$3
ENCODED_CONTENT=$(base64 -w 0 "$ATTACHMENT_NAME")
SEND_ENABLED=0

if [[ $SEND_ENABLED == 0 ]]; then
  echo "Sending Email Disbled!"
  exit 0
fi

curl -s --request POST \
  --url https://api.sendgrid.com/v3/mail/send \
  --header "Authorization: Bearer $API_KEY" \
  --header "Content-Type: application/json" \
  --data @- <<EOF
{
  "personalizations": [
    {
      "to": [{ "email": "$TO" }]
    }
  ],
  "from": {
    "email": "$FROM"
  },
  "subject": "$SUBJECT",
  "content": [
    {
      "type": "text/plain",
      "value": "$BODY"
    }
  ],
  "attachments": [
    {
      "content": "$ENCODED_CONTENT",
      "type": "text/plain",
      "filename": "$ATTACHMENT_NAME",
      "disposition": "attachment"
    }
  ]
}