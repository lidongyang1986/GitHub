#!/bin/bash

function identify_lbaf()
{
	lbaf=$(nvme id-ns $1 | awk '/lbaf/&&/in use/''{print $5}')
	if [ "$lbaf" = "lbads:9" ]; then
		verify_interval_var="512"
		BSSPLIT="512:255k:1m:7k 7680:510k:2m:1k 10752:125k:4m 13k:8m:400k 23040:144k:32k 24k:288k:3k 28k:400k:31k 44544:40k:126k"
	elif [ "$lbaf" = "lbads:12" ]; then
		verify_interval_var="4096"
		BSSPLIT="4k:256k:1m 8k:512k:2m 12k:128k:4m 16k:8m:4100k 20k:144k:532k 24k:288k:4116k 28k:400k:8316k 44k:40k:52k"
	fi
}

function input_param()
{
	echo -e "Input the device under test(Default:/dev/nvme0n1):\c"
	read -t 10 line
	[ "$line" == "" ] && dev_var=/dev/nvme0n1
	[ "$line" != "" ] && dev_var=$line
}

function identify_disk()
{
	disks=$(fdisk -l | awk '{if($2~/nvme/) {split($2,a,":"); disk=disk" "a[1];}} END {print disk}')
	disksA=$(iostat | awk '{if($1~/nvme/) {$1="/dev/"$1;disk=disk" "$1;}} END {print disk}')
	if [[ "${disks[@]}" =~ "$1" ]]; then
		echo "Make sure to run fio on:" $1
		if [[ "${disksA[@]}" =~ "$1" ]]; then
			direct=1
		else
			direct=1
		fi
	else
		echo -e "\033[1;31mWarnning:the device under test $1 is absent ...\033[0m"
		exit 2
	fi
}


function get_param()
{
	verify_backlog_var=`expr $RANDOM % 5 + 1`
	verify_backlog_batch_var=`expr $RANDOM % 10 + 1`
	fio_opt_base="--ioengine=sync --direct=$direct --thread=1 --numjobs=$numjobs --group_reporting"
	fio_opt_varify1="--do_verify=1 --verify_interval=$verify_interval_var --verify_backlog=$verify_backlog_var --verify_backlog_batch=$verify_backlog_batch_var --verify_fatal=1 --verify_dump=1 --verify_pattern=0x000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfefffffefdfcfbfaf9f8f7f6f5f4f3f2f1f0efeeedecebeae9e8e7e6e5e4e3e2e1e0dfdedddcdbdad9d8d7d6d5d4d3d2d1d0cfcecdcccbcac9c8c7c6c5c4c3c2c1c0bfbebdbcbbbab9b8b7b6b5b4b3b2b1b0afaeadacabaaa9a8a7a6a5a4a3a2a1a09f9e9d9c9b9a999897969594939291908f8e8d8c8b8a898887868584838281807f7e7d7c7b7a797877767574737271706f6e6d6c6b6a696867666564636261605f5e5d5c5b5a595857565554535251504f4e4d4c4b4a494847464544434241403f3e3d3c3b3a393837363534333231302f2e2d2c2b2a292827262524232221201f1e1d1c1b1a191817161514131211100f0e0d0c0b0a09080706050403020100"
	fio_opt_varify2="--do_verify=1 --verify_interval=$verify_interval_var --verify_fatal=1 --verify_dump=1 --verify_pattern=0x000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfefffffefdfcfbfaf9f8f7f6f5f4f3f2f1f0efeeedecebeae9e8e7e6e5e4e3e2e1e0dfdedddcdbdad9d8d7d6d5d4d3d2d1d0cfcecdcccbcac9c8c7c6c5c4c3c2c1c0bfbebdbcbbbab9b8b7b6b5b4b3b2b1b0afaeadacabaaa9a8a7a6a5a4a3a2a1a09f9e9d9c9b9a999897969594939291908f8e8d8c8b8a898887868584838281807f7e7d7c7b7a797877767574737271706f6e6d6c6b6a696867666564636261605f5e5d5c5b5a595857565554535251504f4e4d4c4b4a494847464544434241403f3e3d3c3b3a393837363534333231302f2e2d2c2b2a292827262524232221201f1e1d1c1b1a191817161514131211100f0e0d0c0b0a09080706050403020100"
}
# simple script menu
function menu() 
{    
	clear    
	echo    
	echo -e "\t\t\tTest Options Menu\n"
	echo -e "\t1: 128k_overall_randwrite"
	echo -e "\t2: 128k_overall_seqwrite"
	echo -e "\t3: 128k_overall_randread_verify"
	echo -e "\t4: 128k_overall_seqread_verify"
	echo -e "\t5: 128k_overall_randwrite_randread_verify"
	echo -e "\t6: 128k_overall_randwrite_seqread_verify"
	echo -e "\t7: 128k_overall_seqwrite_seqread_verify"
	echo -e "\t8: 128k_overall_seqwrite_randread_verify"
	echo -e "\t9: mix_io_patterns_verify"
	echo -e "\t10: randomread_4k_iops_FOB"
	echo -e "\t11: randomwrite_4k_iops_FOB"
	echo -e "\t12: seqread_128k_throughput_FOB"
	echo -e "\t13: seqwrite_128k_throughout_FOB"
	echo -e "\t14: io_trim_format_poweroff_poweron.sh"
	echo -e "\t0. Exit program\n\n"
	echo -en "\t\tEnter your option: "
	read -n 3 option
}
while [ 1 ]
do    
	input_param
	identify_disk $dev_var
	identify_lbaf $dev_var
	menu    
	case $option in        
		0)        
		break
		;;
		1)
		clear
		numjobs=1
		get_param        
		source 001_128k_overall_randwrite.sh 1
		;;
		2)
		clear
		numjobs=1
		get_param
		source 002_128k_overall_seqwrite.sh 1
		;;
		3)
		clear
		numjobs=1
		get_param
		source 003_128k_overall_randread_verify.sh 1
		;;
		4)
		clear
		numjobs=1
		get_param
		source 004_128k_overall_seqread_verify.sh 1
		;;
		5)
		clear
		numjobs=1
		get_param
		source 005_128k_overall_randwrite_randread_verify.sh 1
		;;
		6)
		clear
		numjobs=1
		get_param
		source 006_128k_overall_randwrite_seqread_verify.sh 1
		;;
		7)
		clear
		numjobs=1
		get_param
		source 007_128k_overall_seqwrite_seqread_verify.sh 1
		;;
		8)
		clear
		numjobs=1
		get_param
		source 008_128k_overall_seqwrite_randread_verify.sh 1
		;;
		9)
		clear
		numjobs=1
		get_param
		source 009_mix_io_patterns_verify.sh 1
		;;
		10)
		clear
		numjobs=4
		get_param
		source 010_randomread_4k_iops_FOB.sh 1
		;;
		11) 
		clear
		numjobs=4
		get_param
		source 011_randomwrite_4k_iops_FOB.sh 1
		;;
		12) 
		clear
		numjobs=4
		get_param		
		source 012_seqread_128k_throughput_FOB.sh 1
		;;
		13)
		clear
		numjobs=4
		get_param
		source 013_seqwrite_128k_throughout_FOB.sh 1
		;;
		14)
		clear		
		source 014_io_trim_format_poweroff_poweron.sh $dev_var
		#host will poweroff...need manaul login the linux to readverify
		;;
		*)        
		clear
		echo -e "\033[1;31mError:your choice is absent ...\033[0m"
		;;        
	esac    
	echo -en "\n\n\t\t\tHit any key to continue"    
	read -n 1 line
done
clear










