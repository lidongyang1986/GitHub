因为4.14里面都默认自动安装，默认编译你都找不到nvme-core.ko

不要从source code编译，因为make menuconfig选项里面，nvme写死了成builtin模式至今不知道怎么改动。


注意几个文件

1. /driver/nvme/host/kconfig里面和make menuconfig相关的选项

2. /boot/linux-kernelXXX.config保存着所有你的配置文件。



1. 如果要改4.14以上的核，ubuntu18.04.

lsmod|grep nvme

自己就有，不是builtin



2. 要改/driver/nvme/host/makefile



ccflags-y				+= -I$(src)

obj-$(CONFIG_NVME_CORE)			+= nvme-core.o               改   obj-m			+= nvme-core.o         

obj-$(CONFIG_BLK_DEV_NVME)		+= nvme.o                  改   obj-m			+= nvme.o     

obj-$(CONFIG_NVME_FABRICS)		+= nvme-fabrics.o

obj-$(CONFIG_NVME_RDMA)			+= nvme-rdma.o

obj-$(CONFIG_NVME_FC)			+= nvme-fc.o

obj-$(CONFIG_NVME_TCP)			+= nvme-tcp.o







nvme-core-y				:= core.o

nvme-core-$(CONFIG_TRACING)		+= trace.o

nvme-core-$(CONFIG_NVME_MULTIPATH)	+= multipath.o

nvme-core-$(CONFIG_NVM)			+= lightnvm.o

nvme-core-$(CONFIG_FAULT_INJECTION_DEBUG_FS)	+= fault_inject.o



nvme-y					+= pci.o

nvme-fabrics-y				+= fabrics.o

nvme-rdma-y				+= rdma.o

nvme-fc-y				+= fc.o

nvme-tcp-y				+= tcp.o



改：

default:

	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:

	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean

  

  

3. 卸载和安装：

rmmod nvme

insmod nvme.ko

(在/driver/nvme/host里面操作)
