#!/bin/bash
# This script throws job on specified hosts.
# If the one of the hosts are busy,
# skip throwing job to the host.
# [USAGE]
#    cpu_job_throw JOBS_FILE HOSTS_FILE [ENV_FILE]
# [IN]
#     JOBS_FILE : jobs file.(text file)
#                 each line is treated as a single job.
#    HOSTS_FILE : hosts file.(text file)
#                 each line is treated as an execusion host.
#      ENV_FILE : environment setup file(shell script)[OPTIONAL]
# [EXAMPLE]
#    cpu_job_throw.sh jobs.txt hosts.txt env.sh
#
# Copyright (C) 2011, ATR All Rights Reserved.
# License : New BSD License(see VBMEG_LICENSE.txt)

NARG=$#
# if $NARG < 2
if [ $NARG -lt 2 ] 
then
    echo "Usage : cpu_job_throw JOBS_FILE HOSTS_FILE [ENV_FILE]"
    exit 1
fi

#
# --- Files
#
JOBS_FILE=`readlink -f "$1"` # get full path
HOSTS_FILE=`readlink -f "$2"` # get full path
ENV_FILE=""
if [ "$JOBS_FILE" == "" ] || [ ! -e $JOBS_FILE ] 
then
    echo "[Error]JOBS_FILE:$JOBS_FILE doesn't exist."
    exit 1;
fi
if [ "$HOSTS_FILE" == "" ] || [ ! -e $HOSTS_FILE ]
then
    echo "[Error]HOSTS_FILE:$HOSTS doesn't exist."
    exit 1;
fi
if [ $NARG -gt 2 ] 
then
    ENV_FILE=`readlink -f "$3"` # get fullpath
fi

#
# --- other settings
#
LOG_DIR=`echo "${JOBS_FILE%/*}"`"/log"`date '+%Y%m%d%H%M%S'`
#echo $LOG_DIR

mkdir $LOG_DIR
USER=`whoami`
PIDs=()
RUN_HOSTS=()
REMOTE=""

#
# --- Read JOBS
#
OLD_IFS=IFS
IFS=$'\n'
JOBS=(`cat "$JOBS_FILE"`)
HOSTS=(`cat "$HOSTS_FILE"`)
OLD_IFS=IFS

#
# --- Sub functions
#
function is_remote_host(){
    if [ "`hostname`" = "$1" ] 
    then
        REMOTE=""
    else
        REMOTE="1"
    fi
}

function kill_process() {
    for host in ${RUN_HOSTS[@]}
    do
    # error -> res
    CMD="ps aux | grep $LOG_DIR | grep -v grep | awk '{ print \"pkill -9 -P\", \$2}' | sh"
    #echo $CMD
    is_remote_host $host
    if [ -z $REMOTE ] 
    then
        eval "$CMD"
    else
        res=`ssh -x $USER@$host "$CMD"`
    fi
    done
    kill -9 ${PIDs[@]} > /dev/null 2>&1
}

function signalExit() {
    # When pushing Ctrl-C, signalExit will be called by trap
    while [ 1 ]
    do
        printf "\nTerminate?[y/n]"
        read ANS

        if [ "$ANS" = "y" ] 
        then
            kill_process
            exit 2;
        elif [ "$ANS" = "n" ] 
        then
            break
        fi
    done
}

# When pushing Ctrl-C, signalExit will be called by trap
trap signalExit SIGINT
trap kill_process EXIT

#######################################################################
# Main Routine
#######################################################################
declare -i NJOBS NHOSTS JOB_ID HOST_ID ret
NJOBS=${#JOBS[@]}
NHOSTS=${#HOSTS[@]}

JOB_ID=0
HOST_ID=0

#echo "JOBS = ${JOBS[@]}"
#echo "HOSTS= ${HOSTS[@]}"
#echo "NJOBS = $NJOBS"
#echo "NHOSTS = $NHOSTS"
#exit 0

script_path=`echo $(cd $(dirname $0);pwd)`
GPU_CHECK_SCRIPT="${script_path}/is_cpu_host_available.sh"

#
# --- Validity check of hosts.
#
declare -i valid_hosts invalid_hosts
valid_hosts=0
for host in ${HOSTS[@]}
do
    printf "Checking host : %-15s ... " $host
    $GPU_CHECK_SCRIPT $host > /dev/null
    ret=$?
    case $ret in
       0 )
          echo "OK."
          valid_hosts=`expr $valid_hosts + 1`
          ;;
       1 ) 
          echo "OK."
          valid_hosts=`expr $valid_hosts + 1`
          ;;
      100 )
          echo "[NG]Unreachable."
          ;;
      101 )
          echo "[NG]Cannot login via ssh."
          ;;
      102 )
          echo "[NG]GPU check tool(nvidia-smi) is not installed."
          ;;
    esac
done

#
# --- Ask users when invalid hosts were found
#
invalid_hosts=`expr $NHOSTS - $valid_hosts`

if [ $valid_hosts -eq 0 ] 
then
    echo "No available host(s). check setting of host."
    exit 2
elif [ $valid_hosts -eq $NHOSTS ] 
then
    echo "$valid_hosts valid host(s) were found."
fi

if [ $invalid_hosts -ne 0 ] 
then
    echo "$invalid_hosts invalid host(s) were found."
    while [ 1 ]
    do
        INVALID=`expr $NHOSTS - $valid_hosts`
        echo -n "Do you wish to continue?[y/n]"
        read ANS
        if [ "$ANS" = "y" ] 
        then
            break
        elif [ "$ANS" = "n" ] 
        then
            echo "Terminated."
            exit 2;
        fi
    done
fi

############################################################
# Start throwing jobs
############################################################
declare -i waiting

waiting=0
echo "$NJOBS job(s) will run on the host(s)."

while [ $NJOBS -ne 0 ] 
do
    # check current status of host.
#    $GPU_CHECK_SCRIPT ${HOSTS[HOST_ID]}
    $GPU_CHECK_SCRIPT ${HOSTS[HOST_ID]} > /dev/null
    is_gpu_avaibale=$?

    if [ $is_gpu_avaibale -eq 1 ] 
    then
        #
        # --- Throw job
        #

        if [ $waiting -ne 0 ] 
        then
            printf "\b\b\b\b\b\b\b\b\b"
            # reset waiting
            waiting=0
        fi

        JOB=${JOBS[$JOB_ID]}
        EXEC_HOST="${HOSTS[HOST_ID]}"
        DATE=`date`
        echo "=================================================="
        echo "Started JOB_ID:`expr $JOB_ID + 1 `, HOST:$EXEC_HOST ($DATE)"
        echo "=================================================="

        CMD="${JOBS[$JOB_ID]}"
        echo "$CMD"

        LOG_FILE="$LOG_DIR/job`expr $JOB_ID + 1`.txt"
        WRAP_CMD="${script_path}/cpu_job_proc.sh $JOBS_FILE `expr $JOB_ID + 1` $LOG_FILE $ENV_FILE; echo \"JOB_ID=`expr $JOB_ID + 1`, HOST=$EXEC_HOST, ExitCode=\$?\""
        # echo $WRAP_CMD
        result_files[$JOB_ID]=`mktemp`

        # It is difficult to make command...
        is_remote_host $EXEC_HOST
        if [ -z "$REMOTE" ] 
        then
            # local
            eval "$WRAP_CMD > ${result_files[$JOB_ID]} &" &
        else
            ssh -x -n $USER@$EXEC_HOST "$WRAP_CMD" > ${result_files[$JOB_ID]} &
        fi

        PID=$!
        RUN_HOSTS=("${RUN_HOSTS[@]}" "$EXEC_HOST")
        PIDs=("${PIDs[@]}" $PID)
        JOB_ID=`expr $JOB_ID + 1`

        sleep 1s
    else
        WAIT_CHAR=("/" "-" "\\" "|")
        if [ $waiting -ne 0 ] 
        then
            printf "\b\b\b\b\b\b\b\b\b"
        fi
        printf "Waiting %s" ${WAIT_CHAR[$waiting % 4]}
        waiting=`expr $waiting + 1`
        sleep 0.1s
    fi

    # Reload HOSTS_FILE
    HOSTS=(`cat "$HOSTS_FILE"`)
    NHOSTS=${#HOSTS[@]}

    HOST_ID=`expr $HOST_ID + 1`
    HOST_ID=`expr $HOST_ID % $NHOSTS`

    if [ $JOB_ID -eq $NJOBS ] 
    then
        break
    fi
done
echo "[MSG]All job(s) are running. Please wait for the processing to complete."

while [ ${#PIDs[@]} -ne 0 ] 
do
#    N=${#PIDs[@]}
#    echo $N
    i=0
    for pid in ${PIDs[@]} 
    do
        if kill -0 "$pid" 2>/dev/null 
        then
            : # do nothing
            # process is alive
#            echo "process $pid is alive."
        else
#            echo "process $pid is dead. array : $i"
            unset PIDs[$i]
        fi
        i=$((i+1))
    done
    PIDs=(${PIDs[@]})
    sleep 1s
done


###################################################
# Result file check
###################################################
final_result=`mktemp`
CAT=""
i=0
while [ $i -lt $NJOBS ] 
do
    if [ -s ${result_files[i]} ] 
    then
        CAT="$CAT ${result_files[$i]}"
    else
        sleep 3s
    fi
    i=`expr $i + 1`
done
echo "[MSG]Finished (`date`)."

# Create execusion result
if [ "$CAT" ]
then
    eval "cat $CAT > $final_result"
fi
# Display result
LOG_FILE="$LOG_DIR/result.txt"
echo "========================================" | tee -a $LOG_FILE
echo "Execusion result (ExitCode 0: success)"   | tee -a $LOG_FILE
echo "========================================" | tee -a $LOG_FILE
if [ -e $final_result ] 
then
    eval "cat $final_result" | tee -a $LOG_FILE
fi
echo "========================================" | tee -a $LOG_FILE
echo "Execusion result: $LOG_FILE"
# Check ExitCode
ret=0
while read line
do
#    echo $line
    code=`echo $line | awk -F = '{print $4}'`
    if [ "$code" != "0" ] 
    then
        echo "[MSG]Found error. check setting and log file" | tee -a $LOG_FILE
        ret=1 # error exit
        break
    fi
done < $final_result
rm $final_result
exit $ret
