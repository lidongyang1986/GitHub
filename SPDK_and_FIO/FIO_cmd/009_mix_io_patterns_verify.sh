#!/bin/bash
# check parameter
#++++++++++++++++++++++++++++++++++++++++
#useage:random min max 
function random()
{
	min=$1
	max=$2-$1
	num=$(date +%s%N)
	((retnum=$num%$max + $min))
	echo $retnum
}

function gen_fio_param()
{
	IODEPTH="256 512"
	RW="write read rw randwrite randread randrw"
	RWMIXREAD="10 50 90"
	
}

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

##################################################
#####  Run fio
function run_single_fio()
{
	echo -ne "$fio_opt;\n"
	fio $fio_opt >> /dev/null
	if [ $? != 0 ]; then
		echo -e "\033[1;31mfio errors,exit......\033[0m"
		exit 1
	fi
}

function identify_disk()
{
	disks=$(fdisk -l | awk '{if($2~/nvme/) {split($2,a,":"); disk=disk" "a[1];}} END {print disk}')
	disksA=$(iostat | awk '{if($1~/nvme/) {$1="/dev/"$1;disk=disk" "$1;}} END {print disk}')
	if [[ "${disks[@]}" =~ "$1" ]]; then
		echo "Make sure to run fio on:" $1
		if [[ "${disksA[@]}" =~ "$1" ]]; then
			direct="1"
		else
			direct="1"
		fi
	else
		echo -e "\033[1;31mWarnning:the device under test $1 is absent ...\033[0m"
		exit 2
	fi
}

function random_write_overall()
{
	## Unit:KiB
	blocksize_ver="128"
	## capacity,B
	DiskSize_B=`sudo fdisk -l $1 2>/dev/null | awk '/Disk/&&/bytes/''{print $5}'`
	Cnt4KiB=`sudo fdisk -l $1 2>/dev/null | awk '/Disk/&&/bytes/''{print int($5/4096)}'`
	Mul4kBS=$(($blocksize_ver/4))
	CntBsAlig=$(($Cnt4KiB/$Mul4kBS))
	DiskSize_BSKiB=$(($CntBsAlig*$blocksize_ver*1024))
	Cnt4KibBsUnalig=$(($Cnt4KiB%$Mul4kBS))
	DiskSize_BsUnalig=$(($Cnt4KibBsUnalig*4096))

	echo -e "\033[32m`date +\%Y-\%m-\%d_\%H-\%M-\%S`: the capacity of $1 is $DiskSize_B Bytes = $CntBsAlig * ${blocksize_ver}k + $Cnt4KibBsUnalig * 4k = $DiskSize_BSKiB + $DiskSize_BsUnalig\033[0m"
	echo -e "`date +\%Y-\%m-\%d_\%H-\%M-\%S`: Attempting ${blocksize_ver}k random write on the ${blocksize_ver}k aligned of entire device. This may take a while..."
	fio_opt_spec="--blocksize=${blocksize_ver}k --rw=randwrite  --filename=$1 --name=test --iodepth=256 --size=$DiskSize_BSKiB"
	fio_opt="$fio_opt_base $fio_opt_spec $fio_opt_varify1"
	echo -ne "$fio_opt;\n"
	fio $fio_opt
	if [ $? = 0 ]; then
		echo -e "\033[32m`date +\%Y-\%m-\%d_\%H-\%M-\%S`: ${blocksize_ver}k random write on entire device successful...\033[0m"
	else
		echo -e "\033[1;31m`date +\%Y-\%m-\%d_\%H-\%M-\%S`: ${blocksize_ver}k random write on entire device fail...\033[0m"
		exit 1
	fi
	
	if [ $DiskSize_BsUnalig -eq 0 ]; then
		return 0
	fi
	echo -e "`date +\%Y-\%m-\%d_\%H-\%M-\%S`: Attempting 4k random write on the ${blocksize_ver}k unaligned of entire device. This may take a while..."
	fio_opt_spec="--blocksize=4k --rw=randwrite  --filename=$1 --name=test --iodepth=256 --offset=$DiskSize_BSKiB --size=$DiskSize_BsUnalig"
	fio_opt="$fio_opt_base $fio_opt_spec $fio_opt_varify1"
	echo -ne "$fio_opt;\n"
	fio $fio_opt
	if [ $? = 0 ]; then
		echo -e "\033[32m`date +\%Y-\%m-\%d_\%H-\%M-\%S`: 4k random write on entire device successful...\033[0m"
	else
		echo -e "\033[1;31m`date +\%Y-\%m-\%d_\%H-\%M-\%S`: 4k random write on entire device fail...\033[0m"
		exit 1
	fi
}

function run_mix_io_patterns()
{
	echo ===== Now testing SSDs:$1
	gen_fio_param
	for bssplit_var  in $BSSPLIT; do
		for iodepth_var in $IODEPTH; do
			for rw_var in $RW; do
				number_ios_var=$(random 1 102400)
				case $rw_var in
					"write" | "randwrite")
					fio_opt_spec="--bssplit=$bssplit_var --iodepth=$iodepth_var --rw=$rw_var --number_ios=$number_ios_var --filename=$1 --name=test" #--minimal
					fio_opt="$fio_opt_base $fio_opt_spec $fio_opt_varify1"
					echo -e "`date +\%Y-\%m-\%d_\%H-\%M-\%S`:Run fio: $fio_opt_spec"
					run_single_fio
					;;
					"read" | "randread")
					fio_opt_spec="--bssplit=$bssplit_var --iodepth=$iodepth_var --rw=$rw_var --number_ios=$number_ios_var --filename=$1 --name=test" #--minimal
					fio_opt="$fio_opt_base $fio_opt_spec $fio_opt_varify2"
					echo -e "`date +\%Y-\%m-\%d_\%H-\%M-\%S`:Run fio: $fio_opt_spec"
					run_single_fio
					;;
					"rw" | "randrw")
					for rwmixread_var in $RWMIXREAD; do
						number_ios_var=$(random 1 102400)
						fio_opt_spec="--bssplit=$bssplit_var --iodepth=$iodepth_var --rw=$rw_var --rwmixread=$rwmixread_var --number_ios=$number_ios_var --filename=$1 --name=test" #--minimal
						fio_opt="$fio_opt_base $fio_opt_spec $fio_opt_varify1"
						echo -e "`date +\%Y-\%m-\%d_\%H-\%M-\%S`:Run fio: $fio_opt_spec"
						run_single_fio
					done
					;;
					*)
					;;
				esac
			done
		done
	done
}

if [[ $# -eq 0 ]]; then
	dev_var="/dev/nvme0n1"
	identify_disk $dev_var
	identify_lbaf $dev_var
	verify_backlog_var=`expr $RANDOM % 5 + 1`
	verify_backlog_batch_var=`expr $RANDOM % 10 + 1`
	fio_opt_base="--ioengine=sync --direct=$direct --thread=1 --numjobs=1 --group_reporting"
	fio_opt_varify1="--do_verify=1 --verify_interval=$verify_interval_var --verify_backlog=$verify_backlog_var --verify_backlog_batch=$verify_backlog_batch_var --verify_fatal=1 --verify_dump=1 --verify_pattern=0x000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfefffffefdfcfbfaf9f8f7f6f5f4f3f2f1f0efeeedecebeae9e8e7e6e5e4e3e2e1e0dfdedddcdbdad9d8d7d6d5d4d3d2d1d0cfcecdcccbcac9c8c7c6c5c4c3c2c1c0bfbebdbcbbbab9b8b7b6b5b4b3b2b1b0afaeadacabaaa9a8a7a6a5a4a3a2a1a09f9e9d9c9b9a999897969594939291908f8e8d8c8b8a898887868584838281807f7e7d7c7b7a797877767574737271706f6e6d6c6b6a696867666564636261605f5e5d5c5b5a595857565554535251504f4e4d4c4b4a494847464544434241403f3e3d3c3b3a393837363534333231302f2e2d2c2b2a292827262524232221201f1e1d1c1b1a191817161514131211100f0e0d0c0b0a09080706050403020100"
	fio_opt_varify2="--do_verify=1 --verify_interval=$verify_interval_var --verify_fatal=1 --verify_dump=1 --verify_pattern=0x000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfefffffefdfcfbfaf9f8f7f6f5f4f3f2f1f0efeeedecebeae9e8e7e6e5e4e3e2e1e0dfdedddcdbdad9d8d7d6d5d4d3d2d1d0cfcecdcccbcac9c8c7c6c5c4c3c2c1c0bfbebdbcbbbab9b8b7b6b5b4b3b2b1b0afaeadacabaaa9a8a7a6a5a4a3a2a1a09f9e9d9c9b9a999897969594939291908f8e8d8c8b8a898887868584838281807f7e7d7c7b7a797877767574737271706f6e6d6c6b6a696867666564636261605f5e5d5c5b5a595857565554535251504f4e4d4c4b4a494847464544434241403f3e3d3c3b3a393837363534333231302f2e2d2c2b2a292827262524232221201f1e1d1c1b1a191817161514131211100f0e0d0c0b0a09080706050403020100"
fi

for count in `seq 2`; do
	random_write_overall $dev_var
done
run_mix_io_patterns $dev_var


