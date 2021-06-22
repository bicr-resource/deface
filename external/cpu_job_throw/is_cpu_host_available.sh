#!/bin/bash
# Check if the speicifed host is available for GPU caliculation.
#[USAGE]
#   is_cpu_host_available host_name
#   e.g. is_cpu_host_available cbi-node01g
#[IN]
#     host_name : host name
#[OUT]
#    1 : The host is available.
#    0 : The host is busy.
#  100 : Unreachable host.
#  101 : Cannot login to the host via ssh.
#  102 : GPU check tool(nvidia-smi) is not installed.
#  110 : Wrong usage of this command
#[NOTE]
#    conditions of unavailable.
#    a) modules which use GPU is running on the host.
#       modules are listed in "./cpu_modules.txt".
#    b) cpu utilization (nvidia-smi -q | grep Gpu | grep %) is larger than 0.
#
# Copyright (C) 2011, ATR All Rights Reserved.
# License : New BSD License(see VBMEG_LICENSE.txt)

NARG=$#
# if $NARG < 1
if [ $NARG -lt 1 ] 
then
    echo "Usage : is_host_available host_name"
    exit 110
fi

USER=`whoami`
HOST=$1
script_path=`echo $(cd $(dirname $0);pwd)`
SSH="ssh -x $USER@$HOST"

# The spcified host is alive?
ping -c 1 -i 5 "$HOST" > /dev/null 2>&1
if [ $? -ne 0 ] 
then
    echo "Unreachable host($HOST)."
    exit 100
fi
if [ "`hostname`" != "$HOST" ] 
then
    # Can the host receive ssh connection?
    $SSH "hostname" > /dev/null 2>&1
    if [ $? -ne 0 ] 
    then
        echo "Cannot login to the host($HOST) via ssh."
        exit 101
    fi
else
    SSH=""
fi
QUERY_CORES=`$SSH cat /proc/cpuinfo | awk 'BEGIN{RS=""}END {print NR}'`
echo "CPU cores: $QUERY_CORES"
#if [ -z "$QUERY_CORES" ] # QUERY_CORES == ""
#then
#    echo -e "Unable to get CPU status from host:$HOST\n(/proc/cpuinfo is not available.)";
#    exit 102
#fi
#QUERY_LOADAVG=`$SSH cat /proc/loadavg | awk '{print $1}'`
QUERY_LOADAVG=`$SSH top -b -n 1 | awk 'NR>7 { totuse = totuse + $9 } END { print totuse }' `
echo "Current CPU Usage:$QUERY_LOADAVG"
res=`echo "scale=2; ($QUERY_CORES*100)*0.8 - $QUERY_LOADAVG" | bc`
echo "Available:$res%"
bigger=`echo "$res < 100.0" | bc`
echo $bigger
if [ $bigger -eq 1 ]
then
    echo "CPU is busy."
    exit 0
fi

exit 1

$SSH which nvidia-smi > /dev/null 2>&1
if [ $? -ne 0 ] 
then
    echo -e "Unable to get GPU utilization ratio from host:$HOST\n(check \"nvidia-smi\" command is available on the host)";
    exit 102
fi

########################################################
# Check if there are GPU processes on HOST
########################################################
#IFS=$'\n'
GPU_PROCESSES=(`cat "${script_path}"/cpu_modules.txt`)

for PROCESS in ${GPU_PROCESSES[@]}
do
#    echo $PROCESS
    # Search process including $PROCESS
    if [ -z "$SSH" ] 
    then
        QUERY=`ps -fe | grep "$PROCESS"`
    else
        QUERY=`$SSH "ps -fe | grep $PROCESS"`
    fi
    QRESULT=`echo "$QUERY" | awk '{print $8}'`

    for ITEM in ${QRESULT[@]}
    do
        # Confirm Process name(match full)
        if [ "$ITEM" = "$PROCESS" ] 
        then
            echo "Found process($PROCESS). $HOST is busy."
            exit 0
        fi
    done
done

#exit 1 # debug
############################
# Check utilization of GPU
############################
QUERY=`ssh -x $USER@$HOST "nvidia-smi -q | grep Gpu | grep %" 2>/dev/null`
if [ -z "$QUERY" ] # QUERY == ""
then
    echo -e "Unable to get GPU utilization ratio from host:$HOST\n(check \"nvidia-smi\" command is available on the host)";
    exit 102
fi

# UTILIZATION is treated as a number.
declare -i UTILIZATION
UTILIZATION=`echo $QUERY | sed -e "s/Gpu : \([0-9]*\) %/\1/g"`

if [ $UTILIZATION -ne  0 ] # != 0
then
    echo "GPU utilization ratio > 0%. $HOST is busy."
    exit 0
fi

echo "$HOST is available."
exit 1
