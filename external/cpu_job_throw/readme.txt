■cpu_job_throw.sh
複数のホスト対し、ジョブを自動投入するシェルスクリプト

機能：
(a)指定したホストに、ジョブを投入する。
  - ホストの利用可能なCPUが100%未満の時、そのホストの利用は後回しにする。
(b)ジョブ実行の停止
  - Ctrl+Cを押すと、Terminate?[y/n]と表示され、yを選択すると、全てのホスト上のジョブをkillする。

●使い方
cpu_job_throw.sh JOBS_FILE HOSTS_FILE
or
cpu_job_throw.sh JOBS_FILE HOSTS_FILE ENV_FILE

●ファイル
*JOBS_FILE
・テキストファイル。
・1行を１ジョブと認識する。
・Linuxコマンドラインで実行可能なコマンドを記述する。
  (MATLABのコマンドの実行例は、job_matlab.txtを参照。)
※複数行に渡って、１ジョブを記載することができないのが、現在の制限事項。

*HOSTS_FILE
・テキストファイル。
・1行を1ホストと認識する。
・JOB_FILEに定義されたジョブを、本ファイルに記載されたホストにジョブを投げる。
  (実行中に編集することで、ホスト数の増減可)

*ENV_FILE
・[オプショナル]ジョブを実行する前に実行されるシェルスクリプト。
  環境変数やパス設定を記載しておく。カレントディレクトリの設定等にも使える。

  内部的な仕様を書くと、ジョブ実行前に、
  $>source ENV_FILE
  が実行される。

●前準備
指定したいホストに、あらかじめパスワード無しでログインできるようにしておく必要がある。

下記のような感じ
====
_rhayashi@ravel<101> ssh cbi-node01
Last login: Thu Feb 14 21:47:46 2013 from cbi-node01.cns.atr.jp
_rhayashi@cbi-node01<101>
====

方法については、以下を参照のこと。
http://ravel.cns.atr.jp/~rhayashi/dynamic/vikiwiki.cgi?p=cbi_ssh_without_passwd


●実行例

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
空

* 実行
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
Started JOB_ID:1, HOST:cbi-node01 (2013年  4月 15日 月曜日 12:42:46 JST)
==================================================
hostname
==================================================
Started JOB_ID:2, HOST:cbi-node02 (2013年  4月 15日 月曜日 12:42:47 JST)
==================================================
hostname
==================================================
Started JOB_ID:3, HOST:cbi-node03 (2013年  4月 15日 月曜日 12:42:48 JST)
==================================================
hostname
==================================================
Started JOB_ID:4, HOST:cbi-node04 (2013年  4月 15日 月曜日 12:42:49 JST)
==================================================
hostname
[MSG]All job(s) are running. Please wait for the processing to complete.
[MSG]Finished (2013年  4月 15日 月曜日 12:42:49 JST).
========================================
Execusion result (ExitCode 0: success)
========================================
JOB_ID=1, HOST=cbi-node01, ExitCode=0
JOB_ID=2, HOST=cbi-node02, ExitCode=0
JOB_ID=3, HOST=cbi-node03, ExitCode=0
JOB_ID=4, HOST=cbi-node04, ExitCode=0
========================================

●ログディレクトリ・ログファイル

*ログディレクトリ
 JOB_FILEと同じ場所に、"log日付"という名前のディレクトリが作成される。
 ログディレクトリ中に、各ジョブの実行状況を格納したjobN.txtという
 ファイルが作られる。

*jobN.txt
 実行ジョブの標準出力・標準エラー出力の結果を含むファイル。
 ジョブがホストに投入された瞬間に作成される。１行目には、実行中の
 コマンドが記載される。逐次更新されるので、このファイルを確認
 することで、ジョブの実行状況を確認することができる。

*result.txt
 全てのジョブの実行結果。ExitCodeは、ジョブスクリプトが返す値を表し、
 通常０が正常終了。それ以外の値を返せば、エラーとなる。ただし、ジョブ関数が
 エラー発生時も、エラーハンドリングを行わず、０を返すようにしていると、
 ExitCodeは0となり、正常終了と区別が付かないので注意。
 ========================================
 Execusion result (ExitCode 0: success)
 ========================================
 JOB_ID=1, HOST=cbi-node01, ExitCode=0
 JOB_ID=2, HOST=cbi-node02, ExitCode=0
 JOB_ID=3, HOST=cbi-node03, ExitCode=0
 JOB_ID=4, HOST=cbi-node04, ExitCode=0
 ========================================

例：
/home/cbi-data/rhayashi/cpu_job_throw/log20130423174150
job1.txt   (ジョブの実行中の標準出力・標準エラー出力)
job2.txt
job3.txt
…
jobN.txt
result.txt (全ての実行結果)

※ジョブの実行中にCtrl+Cでジョブを終了させた場合は、
　その時点までに書かれた内容が、ログファイルになる。

●その他のコマンド
cpu_job_kill.sh HOSTS_FILE(or HOST_NAME)

HOSTS_FILE内に記載されたホスト上で走っているジョブを削除する。
もし、HOSTS_FILEがファイルではない場合は、ホスト名と解釈され、
そのホスト上のジョブを削除する。

* HOSTS_FILE
cpu_job_kill.sh hosts.txt
Terminate processes on cbi-node01?[y/n]y
Terminate processes on cbi-node02?[y/n]y
Terminate processes on cbi-node03?[y/n]y

* HOST_NAME
cpu_job_kill.sh cbi-node01
Terminate processes on cbi-node01[y/n]y
