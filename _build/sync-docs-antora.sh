#!/bin/bash

#############################################################################################
#
# Script copies built output zip from antora documents build into this git repo.
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
# Named differently than in sync-docs.sh to avoid clashes on paralell runs
sourceBaseDir="copyworkdirantora"

# --- SCRIPT ---

# make working directory and ensure there is no such dir yet (will be removed at the end of script again)
mkdir $sourceBaseDir

echo "Unzip $sourceZip to $sourceBaseDir"

unzip -q $sourceZip -d $sourceBaseDir

# define sourceDir / targetDir
sourceDir="${sourceBaseDir}/site"
targetDir="${targetRepoDir}"

echo "Copy files from $sourceDir to $targetDir ..."

rsync -q -r --delete ${sourceDir} ${targetDir}/

rm -rf $sourceBaseDir

echo "Copy successfully completed"
