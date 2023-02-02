#!/bin/bash

#############################################################################################
#
# Script copies built output zip from documents build into this git repo.
#  - Folder 'images' is always synchronized (checksum based)
#  - html files with their corresponding pdf and zip files:
#    - only copied there are changes in html except the "Last updated" date
#
#############################################################################################

# exit when any command fails
set -e
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command failed with exit code $?."' ERR

if (( $# != 2 )); then
    echo "Expecting arguments: zip file and target repository directory"
    echo "example: eclipsescout.github.io.zip workspace/eclipsescout.github.io"
    exit 2
fi

# --- VARIABLES ---

sourceZip=$1
targetRepoDir=$2
sourceBaseDir="copyworkdir"

# --- SCRIPT ---

# make working directory and ensure there is no such dir yet (will be removed at the end of script again)
mkdir $sourceBaseDir

echo "Unzip $sourceZip to $sourceBaseDir"

unzip -q $sourceZip -d $sourceBaseDir

# find version directory and define sourceDir / targetDir
files=($sourceBaseDir/eclipsescout.github.io/*)
versionDir="${files[0]##*/}"

sourceDir="${sourceBaseDir}/eclipsescout.github.io/${versionDir}"
targetDir="${targetRepoDir}/${versionDir}"

mkdir -p ${targetDir}/images/

echo "Copy files from $sourceDir to $targetDir ..."

# copy images and track changes (rsync using only checksums)
rsync --archive --checksum --info=name ${sourceDir}/images/* ${targetDir}/images/

for htmlFile in ${sourceDir}/*.html
do
  htmlFilename=${htmlFile##*/}
  filename=${htmlFilename%.*}

  # for each html, check if the target file exists or if there are changes except for 'last updated timestamp'
  if [ ! -f ${targetDir}/${htmlFilename} ] || [ -n "$(diff -q --ignore-matching-lines='Last updated [0-9\-]\+ [0-9:]\+' ${sourceDir}/${htmlFilename} ${targetDir}/${htmlFilename})" ]; then
    echo "File ${htmlFilename} changed: copy ${filename}.html, ${filename}.pdf and ${filename}.zip"

    cp "${sourceDir}/${filename}.html" "${targetDir}/${filename}.html"
    cp "${sourceDir}/${filename}.pdf" "${targetDir}/${filename}.pdf"
    cp "${sourceDir}/${filename}.zip" "${targetDir}/${filename}.zip"

  fi

done

rm -rf $sourceBaseDir

echo "Copy successfully completed"
