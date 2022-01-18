#!/usr/bin/env bash

set -e

# # Install dependencies
# # echo "Checking/installing dependencies..."
# # command -v curl || sudo apt-get install -yq curl
# # command -v jq || sudo apt-get install -yq jq

# # CHANGED_FILES=$(git diff --name-only HEAD^ HEAD | grep -v "^src/validate*")
# CHANGED_FILES="autoInject.js"
# echo "$CHANGED_FILES"

# # # Run configurations
# # git clone https://github.com/davisjam/vuln-regex-detector.git
# # cd vuln-regex-detector
# # VULN_REGEX_DETECTOR_ROOT=$(pwd)
# # export VULN_REGEX_DETECTOR_ROOT
# # ./configure
# # cd ..

# # # test
# # echo '{"file":"./autoInject.js"}' > checkfile.json   
# # perl ./bin/check-file.pl checkfile.json > checkfile-out.json
# # jq -r '.vulnRegexes | .[]?' < checkfile-out.json

# VULN_COUNT=0
# # Scan for redos
# SECONDS=0
# for i in ${CHANGED_FILES}
#     do
#         echo "Scanning for vulnerable regexes in $i"
#         echo '{"file":"'"$i"'"}' > checkfile.json
       
#         perl ./bin/check-file.pl checkfile.json > checkfile-out.json

#         echo "The following vulnerable regexes were found in $i"
#         jq -r '.vulnRegexes | .[]?' < checkfile-out.json
#         printf "\n\n\n\n"

#         COUNT=$(jq '.anyVulnRegexes' < checkfile-out.json)
#         echo "count=$COUNT"
#         echo "vuln_count=$VULN_COUNT"
#         VULN_COUNT=$((VULN_COUNT+$COUNT))
#     done
# duration=$SECONDS;
# echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed for scan."

# # isFaulty=1
# # isFaulty=$((isFaulty+1))
# # echo $isFaulty
# # # if [`jq '.anyVulnRegexes' < checkfile-out.json` == null]; then
# # # if [ $isFaulty = "true" ]; then
# if [ $VULN_COUNT -eq 0 ]; then
#     echo "No vulnerable regex was detected. You're good to go!"
# else
#     echo "$VULN_COUNT vulnerable regex(es) were detected. See logs above."
#     exit 10
# fi

# # isFaulty=1
# # hash=$(jq '.anyVulnRegexes' < checkfile-out.json)
# # echo $hash
# # echo $isFaulty
# # isFaulty=$((isFaulty+$hash))
# # echo $isFaulty

####################################3

# Install dependencies
echo "Checking/installing dependencies..."
command -v curl || sudo apt-get install -yq curl
command -v jq || sudo apt-get install -yq jq

CHANGED_FILES=$(git diff --name-only HEAD^ HEAD | grep -v "^src/validate*")
echo "The following files were changed: \n$CHANGED_FILES"

# Run configurations
STABLE_RELEASE="54ddfd60ced5ea0735ed42b910505fa14d3b41bf"
CLONE_DIR="vuln-regex-detector"

git clone https://github.com/davisjam/vuln-regex-detector.git $CLONE_DIR
cd $CLONE_DIR
git checkout $STABLE_RELEASE
VULN_REGEX_DETECTOR_ROOT=$(pwd)
export VULN_REGEX_DETECTOR_ROOT
./configure
cd ..

# Scan for redos
VULN_COUNT=0
SECONDS=0
for i in ${CHANGED_FILES}
    do
        echo "Scanning for vulnerable regexes in $i"
        echo '{"file":"'"$i"'"}' > checkfile.json
       
        perl ./$CLONE_DIR/bin/check-file.pl checkfile.json > checkfile-out.json

        echo "The following vulnerable regexes were found in $i"
        jq -r '.vulnRegexes | .[]?' < checkfile-out.json
        printf "\n\n\n\n"

        COUNT=$(jq '.anyVulnRegexes' < checkfile-out.json)
        VULN_COUNT=$((VULN_COUNT+$COUNT))

    done
duration=$SECONDS;
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed for scan."

if [ $VULN_COUNT -eq 0 ]; then
    echo "No vulnerable regex was detected. You're good to go!"
else
    echo "$VULN_COUNT vulnerable regex(es) were detected. See logs above."
    exit 10
fi