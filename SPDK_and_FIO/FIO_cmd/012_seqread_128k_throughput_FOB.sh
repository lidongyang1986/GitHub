#!/bin/bash
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

function seq_read_128k_throughput()
{
	echo -e "`date +\%Y-\%m-\%d_\%H-\%M-\%S`: Attempting 128k sequential read 1 min..."
	fio_opt_spec="--blocksize=128k --rw=read  --filename=$1 --name=test --iodepth=256 --runtime=60 --time_based"
	
	fio_opt="$fio_opt_base $fio_opt_spec"
	echo -ne "$fio_opt;\n"
	fio $fio_opt
	if [ $? = 0 ]; then
		echo -e "\033[32m`date +\%Y-\%m-\%d_\%H-\%M-\%S`: 128k sequential read 1 min successful!!!\033[0m"
	else
		echo -e "\033[1;31m`date +\%Y-\%m-\%d_\%H-\%M-\%S`: 128k sequential read 1 min fail!!!\033[0m"
		exit 1
	fi
}

if [[ $# -eq 0 ]]; then
	dev_var="/dev/nvme0n1"
	identify_disk $dev_var
	fio_opt_base="--ioengine=libaio --direct=$direct --thread=1 --numjobs=4 --userspace_reap --group_reporting"
fi

seq_read_128k_throughput $dev_var



