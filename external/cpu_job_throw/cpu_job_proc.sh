#!/bin/bash
# launch process. get command from JOBS_FILE and run it.
# [USAGE]
#    cpu_job_proc.sh JOBS_FILE JOB_ID ENV_FILE
# [IN]
#    JOBS_FILE: text format. The file is containing all job commands.
#      JOB_ID : JOB_ID is a line number of JOBS_FILE.(from 1)
#     LOG_FILE: logfile name
#     ENV_FILE: environment setup file(shell script) [Optional]
#
# Copyright (C) 2011, ATR All Rights Reserved.
# License : New BSD License(see VBMEG_LICENSE.txt)


NARG=$#
# if $NARG < 1
if [ $NARG -lt 3 ] 
then
    echo "Usage : cpu_job_proc.sh JOB_FILE JOB_ID LOG_FILE [ENV_FILE]"
    exit 1
fi


# File
JOBS_FILE=$1
JOB_ID=`expr $2 - 1`
LOG_FILE=$3

if [ $NARG -gt 3 ] 
then
    ENV_FILE=$4
    if [ ! -e $ENV_FILE ] 
    then
        echo "[Error]ENV_FILE: $ENV_FILE doesn't exist."
        exit 1
    fi
    # Set environment
    source $ENV_FILE
fi

# Error check
if [ ! -e $JOBS_FILE ] 
then
    echo "[Error]JOBS_FILE:$JOBS_FILE doesn't exist."
    exit 1
fi
if [ $JOB_ID -lt 0 ] 
then
    echo "[Error]JOB_ID:should be >= 1"
    exit 1
fi


# read and get JOB
OLD_IFS=IFS
IFS=$'\n'
JOBS=(`cat "$JOBS_FILE"`)
IFS=OLD_IFS
JOB=${JOBS[$JOB_ID]}
#echo $JOBS
#echo $JOB

# Execute
echo "$JOB" > "$LOG_FILE"
LOG_ERR_FILE="$LOG_FILE.err.txt"

ret=`eval "$JOB 1>$LOG_FILE 2>$LOG_ERR_FILE; echo \\${PIPESTATUS[@]}"`
OLDIFS=IFS
IFS=" "
token=(${ret})
IFS=OLDIFS
for i in ${token[@]}
do
    if [ $i != "0" ] 
    then
        exit `expr $i` # error case
    fi
done
exit 0
