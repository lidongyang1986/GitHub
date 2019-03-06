#!/bin/bash
#write by wangchao 2019-1-2

ps -ef|grep '014_poweron_read_verify.sh'1>/dev/null 2>&1;
if [ $? -eq 1 ] ;then
	exit
fi

echo "now execute 014_poweron_read_verify.sh.................................................................................................................."
echo "wait for about 10m.................................................................................................................."
sn=`cat 014_script_config.txt| grep 'disk sn is'|awk -F : '{print $2}'`
dev_var=`nvme list|grep $sn |awk '{print $1}'`

tail -n 1 014_script_config.txt|grep 'yes' 1>/dev/null 2>&1;
if [ $? -eq 0 ]; then
	echo "..`date`..whether poweron_datacompare_test:no" >> 014_script_config.txt
	fio --ioengine=sync --direct=1 --thread=1 --numjobs=1 --iodepth=1 --bs=128k --rw=read --verify_pattern=0x5c5c --verify_interval=4096 --do_verify=1 --verify_state_load=1 --verify_fatal=1 --verify_dump=1 --group_reporting --name=test1 --filename=$dev_var --output=powerontest 1>/dev/null 2>&1;
	if [ $? -ne 0 ] ;then
		echo "run test readverify fail....`date`.................................................................................................................."
		exit 0
	else
		echo "run test readverify ok....`date`.................................................................................................................."
	fi
fi