��cpu_job_throw.sh
ʣ���Υۥ����Ф�������֤�ư�������륷���륹����ץ�

��ǽ��
(a)���ꤷ���ۥ��Ȥˡ�����֤��������롣
  - �ۥ��Ȥ����Ѳ�ǽ��CPU��100%̤���λ������Υۥ��Ȥ����Ѥϸ�󤷤ˤ��롣
(b)����ּ¹Ԥ����
  - Ctrl+C�򲡤��ȡ�Terminate?[y/n]��ɽ�����졢y�����򤹤�ȡ����ƤΥۥ��Ⱦ�Υ���֤�kill���롣

���Ȥ���
cpu_job_throw.sh JOBS_FILE HOSTS_FILE
or
cpu_job_throw.sh JOBS_FILE HOSTS_FILE ENV_FILE

���ե�����
*JOBS_FILE
���ƥ����ȥե����롣
��1�Ԥ򣱥���֤�ǧ�����롣
��Linux���ޥ�ɥ饤��Ǽ¹Բ�ǽ�ʥ��ޥ�ɤ򵭽Ҥ��롣
  (MATLAB�Υ��ޥ�ɤμ¹���ϡ�job_matlab.txt�򻲾ȡ�)
��ʣ���Ԥ��Ϥäơ�������֤򵭺ܤ��뤳�Ȥ��Ǥ��ʤ��Τ������ߤ����»��ࡣ

*HOSTS_FILE
���ƥ����ȥե����롣
��1�Ԥ�1�ۥ��Ȥ�ǧ�����롣
��JOB_FILE��������줿����֤��ܥե�����˵��ܤ��줿�ۥ��Ȥ˥���֤��ꤲ�롣
  (�¹�����Խ����뤳�Ȥǡ��ۥ��ȿ���������)

*ENV_FILE
��[���ץ���ʥ�]����֤�¹Ԥ������˼¹Ԥ���륷���륹����ץȡ�
  �Ķ��ѿ���ѥ�����򵭺ܤ��Ƥ����������ȥǥ��쥯�ȥ���������ˤ�Ȥ��롣

  ����Ū�ʻ��ͤ�񤯤ȡ�����ּ¹����ˡ�
  $>source ENV_FILE
  ���¹Ԥ���롣

��������
���ꤷ�����ۥ��Ȥˡ����餫����ѥ����̵���ǥ�����Ǥ���褦�ˤ��Ƥ���ɬ�פ����롣

�����Τ褦�ʴ���
====
_rhayashi@ravel<101> ssh cbi-node01
Last login: Thu Feb 14 21:47:46 2013 from cbi-node01.cns.atr.jp
_rhayashi@cbi-node01<101>
====

��ˡ�ˤĤ��Ƥϡ��ʲ��򻲾ȤΤ��ȡ�
http://ravel.cns.atr.jp/~rhayashi/dynamic/vikiwiki.cgi?p=cbi_ssh_without_passwd


���¹���

*job.txt
hostname
hostname
hostname
hostname

*hosts.txt
cbi-node01
cbi-node02
cbi-node03
cbi-node04

*env.sh
��

* �¹�
setenv PATH "$PATH":/home/cbi/rhayashi/cpu_job_throw
cd /home/cbi/rhayashi/cpu_job_throw/example
cpu_job_throw.sh job.txt hosts.txt env.sh
Checking host : cbi-node01      ... OK.
Checking host : cbi-node02      ... OK.
Checking host : cbi-node03      ... OK.
Checking host : cbi-node04      ... OK.
4 valid host(s) were found.
4 job(s) will run on the host(s).
==================================================
Started JOB_ID:1, HOST:cbi-node01 (2013ǯ  4�� 15�� ������ 12:42:46 JST)
==================================================
hostname
==================================================
Started JOB_ID:2, HOST:cbi-node02 (2013ǯ  4�� 15�� ������ 12:42:47 JST)
==================================================
hostname
==================================================
Started JOB_ID:3, HOST:cbi-node03 (2013ǯ  4�� 15�� ������ 12:42:48 JST)
==================================================
hostname
==================================================
Started JOB_ID:4, HOST:cbi-node04 (2013ǯ  4�� 15�� ������ 12:42:49 JST)
==================================================
hostname
[MSG]All job(s) are running. Please wait for the processing to complete.
[MSG]Finished (2013ǯ  4�� 15�� ������ 12:42:49 JST).
========================================
Execusion result (ExitCode 0: success)
========================================
JOB_ID=1, HOST=cbi-node01, ExitCode=0
JOB_ID=2, HOST=cbi-node02, ExitCode=0
JOB_ID=3, HOST=cbi-node03, ExitCode=0
JOB_ID=4, HOST=cbi-node04, ExitCode=0
========================================

�����ǥ��쥯�ȥꡦ���ե�����

*���ǥ��쥯�ȥ�
 JOB_FILE��Ʊ�����ˡ�"log����"�Ȥ���̾���Υǥ��쥯�ȥ꤬��������롣
 ���ǥ��쥯�ȥ���ˡ��ƥ���֤μ¹Ծ������Ǽ����jobN.txt�Ȥ���
 �ե����뤬����롣

*jobN.txt
 �¹ԥ���֤�ɸ����ϡ�ɸ�२�顼���Ϥη�̤�ޤ�ե����롣
 ����֤��ۥ��Ȥ��������줿�ִ֤˺�������롣�����ܤˤϡ��¹����
 ���ޥ�ɤ����ܤ���롣�༡���������Τǡ����Υե�������ǧ
 ���뤳�Ȥǡ�����֤μ¹Ծ������ǧ���뤳�Ȥ��Ǥ��롣

*result.txt
 ���ƤΥ���֤μ¹Է�̡�ExitCode�ϡ�����֥�����ץȤ��֤��ͤ�ɽ����
 �̾�����ｪλ������ʳ����ͤ��֤��С����顼�Ȥʤ롣������������ִؿ���
 ���顼ȯ�����⡢���顼�ϥ�ɥ�󥰤�Ԥ鷺�������֤��褦�ˤ��Ƥ���ȡ�
 ExitCode��0�Ȥʤꡢ���ｪλ�ȶ��̤��դ��ʤ��Τ���ա�
 ========================================
 Execusion result (ExitCode 0: success)
 ========================================
 JOB_ID=1, HOST=cbi-node01, ExitCode=0
 JOB_ID=2, HOST=cbi-node02, ExitCode=0
 JOB_ID=3, HOST=cbi-node03, ExitCode=0
 JOB_ID=4, HOST=cbi-node04, ExitCode=0
 ========================================

�㡧
/home/cbi-data/rhayashi/cpu_job_throw/log20130423174150
job1.txt   (����֤μ¹����ɸ����ϡ�ɸ�२�顼����)
job2.txt
job3.txt
��
jobN.txt
result.txt (���Ƥμ¹Է��)

������֤μ¹����Ctrl+C�ǥ���֤�λ���������ϡ�
�����λ����ޤǤ˽񤫤줿���Ƥ������ե�����ˤʤ롣

������¾�Υ��ޥ��
cpu_job_kill.sh HOSTS_FILE(or HOST_NAME)

HOSTS_FILE��˵��ܤ��줿�ۥ��Ⱦ�����äƤ��른��֤������롣
�⤷��HOSTS_FILE���ե�����ǤϤʤ����ϡ��ۥ���̾�Ȳ�ᤵ�졢
���Υۥ��Ⱦ�Υ���֤������롣

* HOSTS_FILE
cpu_job_kill.sh hosts.txt
Terminate processes on cbi-node01?[y/n]y
Terminate processes on cbi-node02?[y/n]y
Terminate processes on cbi-node03?[y/n]y

* HOST_NAME
cpu_job_kill.sh cbi-node01
Terminate processes on cbi-node01[y/n]y
