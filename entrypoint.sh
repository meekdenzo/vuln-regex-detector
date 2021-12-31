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
echo '{"file":"./autoInject.js"}' > repo.json   
perl ./bin/check-file.pl repo.json > repo-out.json
jq -r '.vulnRegexes | .[]?' < repo-out.json
# Scan for redos
changed_files=$(git diff --name-only "$GITHUB_BASE_REF" "$GITHUB_HEAD_REF")
echo "$changed_files"

for i in ${changed_files}
    do
        echo "Scanning for vulnerable regexes in $i"
        echo '{"file":"'"$i"'"}' > repo.json
       
        perl ./bin/check-file.pl repo.json > repo-out.json

        echo "The following vulnerable regexes were found in $i"
        jq -r '.vulnRegexes | .[]?' < repo-out.json
        printf "\n\n\n\n"
    done

# Suggest changes