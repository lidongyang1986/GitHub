sudo dd if=memplus.mtx of=/dev/nvme0n1 bs=4096 count=256 oflag=direct seek=1 skip=0

sleep 2

sudo dd if=/dev/nvme0n1 of=outputdata.txt bs=4096 count=256 iflag=direct skip=131073






