#!/bin/bash

# Change directory to the 'android' folder
cd android || exit 1

echo "Running detekt check..."
fileArray=($@)
detektInput=$(IFS=,;printf  "%s" "${fileArray[*]}")
echo "Input files: $detektInput"

OUTPUT=$(./gradlew detekt --input "$detektInput" 2>&1)
EXIT_CODE=$?

# Return to the original directory
cd - > /dev/null || exit 1

if [ $EXIT_CODE -ne 0 ]; then
  echo "$OUTPUT"
  echo "***********************************************"
  echo "                 detekt failed                 "
  echo " Please fix the above issues before committing "
  echo "***********************************************"
  exit $EXIT_CODE
fi
