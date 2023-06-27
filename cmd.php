#!/work/u00cjz00/binary/php/7.4/bin/php
<?php
$script_folder="/home/u00cjz00/bash_job/01_script";
$finish_folder="/home/u00cjz00/bash_job/02_finish";

$i=0;
while ( $i<1 ) {
 sleep(10);
 exec_cmd($script_folder,$finish_folder);
}

function exec_cmd($script_folder,$finish_folder){
 exec("find $script_folder -type f -name \"*.sh\"", $fileresult);
 foreach ($fileresult as $ori_file) {
  $file=$finish_folder."/".basename($ori_file);
  $cmd="mv $ori_file $file.run && bash $file.run && mv $file.run $file.run.finish";
  //echo $cmd."\n";
  $log_file="$file.run.finish.log";
  $nohup_cmd=nohup_cmd($cmd,$log_file);
  $pid=trim(shell_exec($nohup_cmd));
  $fp = fopen("$file.run.pid", "w"); fwrite($fp, $pid); fclose($fp);
  echo $pid."\n";
 }
}

function nohup_cmd($command, $outputFile = '/dev/null') {
 $nohup_cmd="nohup bash  -c \"".$command."\" > ".$outputFile." 2>&1 & echo \$!";
 return $nohup_cmd;
}
