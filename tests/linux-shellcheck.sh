#!/bin/bash

# set +e

cd linux-unix/
FILES=(*)
errs=0
for FILE in "${FILES[@]}"; do
  echo "Checking $FILE ..."
  shellcheck $FILE
  er=$?
  if [[ $er -ne 0 ]]; then
    errs=$(($errs+1))
  fi
  echo "-----------------------------------------------------------------------------------------------------------------------"
done
if [[ $errs -gt 0 ]]; then
  echo "FAILED: $errs Erros in shell script files. Kindly check above"
  exit 1
else
  echo "🎉 Woot! No lint or syntax errors."
fi