#!/bin/bash
# Kill processes on specified hosts
# [USAGE]
#    cpu_job_kill HOSTS_FILE(or HOST_NAME)
#    HOSTS_FILE : hosts file.(text file)
#                 each line is treated as an execusion host.
#                 if the given string is not file, it will be treated
#                 as HOST_NAME.
# [EXAMPLE]
#    cpu_job_kill.sh hosts.txt
#    cpu_job_kill.sh cbi-node01
#
# Copyright (C) 2011, ATR All Rights Reserved.
# License : New BSD License(see VBMEG_LICENSE.txt)

NARG=$#
if [ $NARG -lt 1 ]
then
    echo "Usage : cpu_job_kill HOSTS_FILE(or HOST_NAME)"
    exit 1
fi
REMOTE=""

#
# --- HOSTS
#
HOSTS_FILE=`readlink -f "$1"` # get full path
#echo $HOSTS_FILE
if [ "$HOSTS_FILE" == "" ] || [ ! -e $HOSTS_FILE ]
then
#    echo "HOSTS_FILE doesnt exist."
    HOSTS=("$1")
else
#    echo "HOSTS_FILE exist."
    OLD_IFS=IFS
    IFS=$'\n'
    HOSTS=(`cat "$HOSTS_FILE"`)
fi

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

function kill_host() {
    host="$1"
    is_remote_host $host
    if [ -z $REMOTE ] 
    then
        res=`killall -g cpu_job_proc.sh -s KILL 3>&1 > /dev/null 2>&3`
    else
        res=`ssh -x $USER@$host "killall -g cpu_job_proc.sh -s KILL" 3>&1 > /dev/null 2>&3`
    fi
}

#######################################################################
# Main Routine
#######################################################################

#
# --- Kill processes on HOSTS
#
script_path=`echo $(cd $(dirname $0);pwd)`
CPU_CHECK_SCRIPT="${script_path}/is_cpu_host_available.sh"

for host in ${HOSTS[@]}
do
    $CPU_CHECK_SCRIPT $host > /dev/null
    ret=$?
    case $ret in
       100 )
           echo "[NG]Unreachable : $host"
           ;;
       101 )
           echo "[NG]Cannot login via ssh. : $host"
           ;;
       * )
           while [ 1 ]
           do
               printf "Terminate processes on $host?[y/n]"
               read ANS

               if [ "$ANS" = "y" ] 
               then
                   kill_host $host
                   break
               elif [ "$ANS" = "n" ]
               then
                   break
               fi
           done
    esac
done
IFS=OLD_IFS
