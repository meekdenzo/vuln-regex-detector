#!/usr/bin/env bash

set -e

# Install dependencies
echo "Installing dependencies..."
sudo apt install -yq curl jq

# Run configurations
export VULN_REGEX_DETECTOR_ROOT=`pwd`
./configure

echo 'Configuration complete'

# test
echo '{"file":"./autoInject.js"}' > repo.json   
perl ./bin/check-file.pl repo.json > repo-out.json
cat repo-out.json | jq -r '.vulnRegexes | .[]?'
# Scan for redos
changed_files=`git show --name-only --pretty=format:`
echo $changed_files

for i in ${changed_files}
    do
        echo "Scanning for vulnerable regexes in $i"
        echo '{"file":"'$i'"}' > repo.json   
       
        perl ./bin/check-file.pl repo.json > repo-out.json

        echo "The following vulnerable regexes were found in $i"
        cat repo-out.json | jq -r '.vulnRegexes | .[]?'
        printf "\n\n\n\n"
    done

# Suggest changes
