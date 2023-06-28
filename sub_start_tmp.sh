#!/usr/bin/env bash
#DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DIR="/work/u00cjz00/guest_jobs/$(whoami)/$(hostname -s)";
echo "WORKSPACE set to $DIR/.."
echo $BASHPID
mkdir -p $DIR/transfer 

SECONDS=0
lst=-400
restart_count=0


start_fl() {
  if [[ $(( $SECONDS - $lst )) -lt 300 ]]; then
    ((restart_count++))
  else
    restart_count=0
  fi
  if [[ $(($SECONDS - $lst )) -lt 300 && $restart_count -ge 5 ]]; then
    echo "System is in trouble and unable to start the task!!!!!"
    rm -f $DIR/transfer/pid.fl $DIR/transfer/shutdown.fl $DIR/transfer/restart.fl $DIR/transfer/daemon_pid.fl
    exit
  fi
  lst=$SECONDS
  #(./sleep.sh 2>&1 & echo $! >&3 ) 3> $DIR/transfer/pid.fl
  #((python sleep.py 2>&1 & echo $! >&3 ) 3>$DIR/transfer/pid.fl )
  tmpfile=$(mktemp)
  cp /work/u00cjz00/bash_job/cmd_tmp.php $tmpfile
  chmod 755 $tmpfile
  (($tmpfile 2>&1 & echo $! >&3 ) 3>$DIR/transfer/pid.fl )
  #((/work/u00cjz00/bash_job/cmd.php 2>&1 & echo $! >&3 ) 3>$DIR/transfer/pid.fl )
  #((python3 -u -m nvflare.private.fed.app.server.server_train -m $DIR/.. -s fed_server.json --set secure_train=false config_folder=config host=${host} sp=${sp} 2>&1 & echo $! >&3 ) 3>$DIR/transfer/pid.fl )
  pid=`cat $DIR/transfer/pid.fl`
  echo "new pid ${pid}"
  sleep 1
  rm $tmpfile
}


stop_fl() {
  if [[ ! -f "$DIR/transfer/pid.fl" ]]; then
    echo "No pid.fl.  No need to kill process."
    return
  fi
  pid=`cat $DIR/transfer/pid.fl`
  sleep 5
  kill -0 ${pid} 2> /dev/null 1>&2
  if [[ $? -ne 0 ]]; then
    echo "Process already terminated"
    return
  fi
  kill -9 $pid
  rm -f $DIR/transfer/pid.fl $DIR/transfer/shutdown.fl $DIR/transfer/restart.fl
}
  
  
if [[ -f "$DIR/transfer/daemon_pid.fl" ]]; then
  dpid=`cat $DIR/transfer/daemon_pid.fl`
  kill -0 ${dpid} 2> /dev/null 1>&2
  if [[ $? -eq 0 ]]; then
    echo "There seems to be one instance, pid=$dpid, running."
    echo "If you are sure it's not the case, please kill process $dpid and then remove daemon_pid.fl in $DIR/.."
    exit
  fi
  rm -f $DIR/transfer/daemon_pid.fl
fi

echo $BASHPID > $DIR/transfer/daemon_pid.fl


while true
do
  sleep 5
  if [[ ! -f "$DIR/transfer/pid.fl" ]]; then
    echo "start fl because of no pid.fl"
    start_fl
    continue
  fi
  pid=`cat $DIR/transfer/pid.fl`
  kill -0 ${pid} 2> /dev/null 1>&2
  if [[ $? -ne 0 ]]; then
    if [[ -f "$DIR/transfer/shutdown.fl" ]]; then
      echo "Gracefully shutdown."
      break
    fi
    echo "start fl because process of ${pid} does not exist"
    start_fl
    continue
  fi
  if [[ -f "$DIR/transfer/shutdown.fl" ]]; then
    echo "About to shutdown."
    stop_fl
    break
  fi
  if [[ -f "$DIR/transfer/restart.fl" ]]; then
    echo "About to restart."
    stop_fl
  fi  
done


rm -f $DIR/transfer/pid.fl $DIR/transfer/shutdown.fl $DIR/transfer/restart.fl $DIR/transfer/daemon_pid.fl
