#!/usr/bin/env bash

set -e

# Install dependencies
echo "Checking/installing dependencies..."
command -v curl || sudo apt-get install -yq curl
command -v jq || sudo apt-get install -yq jq

# Run configurations
VULN_REGEX_DETECTOR_ROOT=$(pwd)
export VULN_REGEX_DETECTOR_ROOT
./configure

echo 'Configuration complete'

# test
echo '{"file":"./autoInject.js"}' > checkfile.json   
perl ./bin/check-file.pl checkfile.json > checkfile-out.json
jq -r '.vulnRegexes | .[]?' < checkfile-out.json
# Scan for redos
changed_files=$(git diff --name-only HEAD^ HEAD | grep -v "^src/validate*")
echo "$changed_files"

SECONDS=0
for i in ${changed_files}
    do
        echo "Scanning for vulnerable regexes in $i"
        echo '{"file":"'"$i"'"}' > checkfile.json
       
        perl ./bin/check-file.pl checkfile.json > checkfile-out.json

        echo "The following vulnerable regexes were found in $i"
        jq -r '.vulnRegexes | .[]?' < checkfile-out.json
        printf "\n\n\n\n"
    done
duration=$SECONDS;
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed for scan."