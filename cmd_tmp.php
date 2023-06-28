#!/work/u00cjz00/binary/python374
<?php
$guest=trim(shell_exec('whoami'));
$node=trim(shell_exec('hostname -s'));

$script_folder="/work/u00cjz00/guest_jobs/$guest/$node/01_script";
$finish_folder="/work/u00cjz00/guest_jobs/$guest/$node/02_finish";
echo $script_folder;

exec("mkdir -p $script_folder");
exec("mkdir -p $finish_folder");

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
