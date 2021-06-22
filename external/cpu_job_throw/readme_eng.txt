cpu_job_throw.sh

* Automatically send jobs to cluster nodes.

(a) Send jobs to specified nodes.
	If CPU usage is exceeded than (# of core) * 100 %
	this node is skipped.

(b) You can stop the automation process by pressing Ctrl+C

* Usage:
cpu_job_throw.sh JOBS_FILE HOSTS_FILE
or
cpu_job_throw.sh JOBS_FILE HOSTS_FILE ENV_FILE

JOBS_FILE
	Text file defining job commands for each line.
	Executable command on Linux.
	See an example file(job_matlab.txt) if you want to use MATLAB command.

HOSTS_FILE
	Text file defining host names for each line
	You can modify this file to change the number of hosts while throwing jobs.

ENV_FILE
	[Optional]Shell script before start each job.
	Set environment value, change current path, etc.
	(inner spec: `source ENV_FILE` will be executed  before launching JOB.)

* Notice: 
	Before you will use this script, 
	you need to enable SSH login without password
http://ravel.cns.atr.jp/~rhayashi/dynamic/vikiwiki.cgi?p=cbi_ssh_without_passwd


* Example of job and host files

env.sh
[empty file]

hosts.txt
cbi-node01
cbi-node02
cbi-node03
cbi-node04

job.txt
job_run.sh 0.1
job_run.sh 0.5
job_run.sh 1.0

* Log Directory, Logfile
A log directory is created at the same place of JOB_FILE.
The name is "LogYYYYMMDDHHMMSS".
and execution result will be put there.

*jobN.txt
 This file contains stdout/stderr of jobN.
 The file is created when the job starts on host.
 Line 1 is an execution command.
 You can check a status of a job by seeing its contents.
 : If you terminate jobs by pressing Ctrl+C during executing jobs,
   the logging is terminated in the same timing.

*result.txt
 Execution results of all jobs. ExitCode is a return value of job script.
 Normally zero means success. But if a job script returns zero without 
 error handling, ExitCode become zero.
 In that case, it can't distinguish between success and failure. 

for example
/home/cbi-data/rhayashi/cpu_job_throw/log20130423174150
 job1.txt    (contains stdout and stderr of job1)
 job2.txt
 job3.txt
 ¡Ä
 jobN.txt
 result.txt  (contains execusion results)

* Run the script

setenv PATH "$PATH":/home/cbi/rhayashi/cpu_job_throw
cd /home/cbi/rhayashi/cpu_job_throw/example
cpu_job_throw.sh job.txt hosts.txt env.sh

* Other command
cpu_job_kill.sh HOSTS_FILE(or HOST_NAME)

Kill jobs on hosts which are described in HOSTS_FILE.
If the file is not a file, it will be treated as HOST_NAME,
Then the jobs will be killed on HOST_NAME.

* HOSTS_FILE
cpu_job_kill.sh hosts.txt
Terminate processes on cbi-node01?[y/n]y
Terminate processes on cbi-node02?[y/n]y
Terminate processes on cbi-node03?[y/n]y

* HOST_NAME
cpu_job_kill.sh cbi-node01
Terminate processes on cbi-node01[y/n]y
