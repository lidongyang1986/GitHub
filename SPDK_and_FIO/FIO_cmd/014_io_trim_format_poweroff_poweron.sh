#!/bin/bash
#write by wangchao 2019-1-2

function check_result()
{
	j=$1
	type=$2
	if [ $j -ne 0 ] ;then
		echo "run test $type fail....`date`.................................................................................................................."
		exit 0
	else
		echo "run test $type ok....`date`.................................................................................................................."
	fi
}

function io_4kalign_test()
{
	#seq/random read/write/rw
	verify_backlog_var=`expr $RANDOM % 5 + 1`
	verify_backlog_batch_var=`expr $RANDOM % 10 + 1`
	fio_opt_base="--ioengine=sync --direct=1 --thread=1 --numjobs=1 --group_reporting"
	fio_opt_varify1="--do_verify=1 --verify_interval=4096 --verify_backlog=$verify_backlog_var --verify_backlog_batch=$verify_backlog_batch_var --verify_fatal=1 --verify_dump=1 --verify_pattern=0x55aa66bb77cc88dd99eeaaff"
	for bssplit_var in 4k 128k 4k:64k:128k:96k:1024k;do
		for iodepth_var in 256 1;do
			for rw_var in rw randrw;do
				for rwmixread_var in 0 50 100;do 
					number_ios_var=$(((RANDOM%1025+1)*100))
					fio_opt_spec="--bssplit=$bssplit_var --iodepth=$iodepth_var --rw=$rw_var --rwmixread=$rwmixread_var --number_ios=$number_ios_var --filename=$1 --name=test" #--minimal
					echo -e "`date +\%Y-\%m-\%d_\%H-\%M-\%S`:Run fio: $fio_opt_base $fio_opt_varify1 $fio_opt_spec"
					fio $fio_opt_base $fio_opt_varify1 $fio_opt_spec 1>/dev/null 2>&1
					check_result $? io_4kalign
				done;
			done;
		done;
	done;
}

function io_512balign_test()
{
	#seq/random read/write/rw
	verify_backlog_var=`expr $RANDOM % 5 + 1`
	verify_backlog_batch_var=`expr $RANDOM % 10 + 1`
	fio_opt_base="--ioengine=sync --direct=1 --thread=1 --numjobs=1 --group_reporting"
	fio_opt_varify1="--do_verify=1 --verify_interval=512 --verify_backlog=$verify_backlog_var --verify_backlog_batch=$verify_backlog_batch_var --verify_fatal=1 --verify_dump=1 --verify_pattern=0x55aa66bb77cc88dd99eeaaff"
	for bssplit_var in 512 128k 512:1536:2k:4k:63k:64k:96k:97k:128k:512k;do
		for iodepth_var in 256 1;do
			for rw_var in rw randrw;do
				for rwmixread_var in 0 50 100;do 
					number_ios_var=$(((RANDOM%1025+1)*100))
					fio_opt_spec="--bssplit=$bssplit_var --iodepth=$iodepth_var --rw=$rw_var --rwmixread=$rwmixread_var --number_ios=$number_ios_var --filename=$1 --name=test" #--minimal
					echo -e "`date +\%Y-\%m-\%d_\%H-\%M-\%S`:Run fio: $fio_opt_base $fio_opt_varify1 $fio_opt_spec"
					fio $fio_opt_base $fio_opt_varify1 $fio_opt_spec 1>/dev/null 2>&1
					check_result $? io_512balign
				done;
			done;
		done;
	done;
}

function format_test()
{
	dev=$1
	lbaf=$2
	nvme format -s 0 -n 1 -l $lbaf $dev 1>tmp 2>&1
	cat tmp|grep "Success" 1>/dev/null 2>&1
	check_result $? format$lbaf
	rmmod nvme
	sleep 2
	ver=`uname -r`
	grep 'centos' /proc/version 1>/dev/null 2>&1
	if [ $? -eq 0 ] ;then
		modprobe nvme
		#insmod `find / -name nvme|grep $ver`
	fi
	grep 'Ubuntu' /proc/version 1>/dev/null 2>&1
	if [ $? -eq 0 ] ;then
		insmod `find / -name nvme.ko|grep $ver`
	fi
	modprobe nvme
	sleep 2
	dev=`nvme list|grep $sn |awk '{print $1}'`
	fio --direct=1 --thread=1 --ioengine=libaio --name=test --refill_buffers --scramble_buffers=1 --userspace_reap --numjobs=1 --iodepth=256 --group_reporting --randrepeat=0 --filename=$dev --size=10g --runtime=60 --time_based --blocksize=128k --rw=randrw --rwmixread=30 --do_verify=1 --verify_interval=4k --verify_fatal=1 --verify_dump=1 --verify_pattern=0x55aa --verify_backlog=1 --verify_backlog_batch=1 --output=format_test1
	check_result $? formatAfterIo
}

function trim_test()
{	
	trim_cyc=$2
	dev_var=$1
	slba=0;for((i=0;i<$trim_cyc;i++));do ((slba=slba+32768));nvme dsm $dev_var -s $slba -b 0x8000 -n 1 -d -a 0 1>/dev/null 2>&1 & done
	#trim all disk*1-30%
	slba=0;tmp=$(printf "%d" `nvme id-ns $dev_var |grep nsze |awk '{print $NF}'`);((len=$tmp*(RANDOM%30+1)/100));for((i=0;i<$trim_cyc;i++));do nvme dsm $dev_var -s $slba -b $len -n 1 -d -a 0 1>/dev/null 2>&1 ;check_result $? trimsmallarea_$len; done
	#trim all disk*50-99%
	slba=0;tmp=$(printf "%d" `nvme id-ns $dev_var |grep nsze |awk '{print $NF}'`);((len=$tmp*(RANDOM%50+50)/100));for((i=0;i<$trim_cyc;i++));do nvme dsm $dev_var -s $slba -b $len -n 1 -d -a 0 1>/dev/null 2>&1 ;check_result $? trimbigarea_$len; done
	#trim all disk
	slba=0;len=`nvme id-ns $dev_var |grep nsze |awk '{print $NF}'`;for((i=0;i<$trim_cyc;i++));do nvme dsm $dev_var -s $slba -b $len -n 1 -d -a 0 1>/dev/null 2>&1 ; check_result $? trimalldisk_$len; done
}

function poweroff_test()
{
	dev_var=$1
	power_cycle=$2
	echo "..`date`..whether poweron_datacompare_test:yes" >> 014_script_config.txt 
	grep 014_poweron_read_verify.sh /etc/profile 1>/dev/null 2>&1 ;
	if [ $? -eq 1 ]; then 
		echo 'if [ -f /root/AKeyDeployment/simple/014_script_config.txt ] && [ -f /root/AKeyDeployment/simple/014_poweron_read_verify.sh ]; then tail -n 1 /root/AKeyDeployment/simple/014_script_config.txt |grep  yes 1>/dev/null 2>&1;if [ $? -eq 0 ]; then  cd /root/AKeyDeployment/simple;sh ./014_poweron_read_verify.sh; fi;fi;' >>/etc/profile 
	fi
	((timeout=(RANDOM%55+5)))
	echo "run test $timeout s,will be poweroff.....need manaul login the linux to readverify.....`date`................................................................."
	fio --ioengine=sync --direct=1 --thread=1 --numjobs=1 --runtime=60 --time_based --iodepth=1 --bs=128k --rw=write --verify_pattern=0x5c5c --verify_interval=4096 --verify_state_save=1 --do_verify=0 --group_reporting --name=test1 --filename=$dev_var --output=powerofftest --trigger="echo 0 > /sys/class/rtc/rtc0/wakealarm;echo `date '+%s' -d '+ 2 minutes'` > /sys/class/rtc/rtc0/wakealarm;poweroff" --trigger-timeout=$timeout
}

if [ $# -eq 1 ]; then 
	dev_var=$1
else
	dev_var=/dev/nvme0n1
fi
sn=`nvme list|grep $dev_var |awk '{print $2}'`
echo "disk sn is :$sn" >014_script_config.txt

#format sector:0 -512
format_test $dev_var 0
io_512balign_test $dev_var
trim_test $dev_var 30
#format sector:1 -4096
format_test $dev_var 1
io_4kalign_test $dev_var
poweroff_test $dev_var

