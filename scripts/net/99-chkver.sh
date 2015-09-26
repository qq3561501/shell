#!/bin/sh
path=`dirname $0`
. ${path}reserve.script/env.shf
. ${path}reserve.script/partition.shf
. ${path}reserve.script/unpack.shf

returnarg=0
env_get
if [ $? -ne 0 ];then
	returnarg=1
  echo "return $returnarg"
	exit
fi
md5sum_str="
21afde3b757c395da2b165992c9a5629  fvcommon-ramfs-149467.sp1.03.bootrom\n
853998ca7a889a6c2819942f44f499e9  fvcommon-ramfs-149467sp1.1.bootrom\n
f0c954b2bfbea22da8193584f4dedc7c  fvcommon-ramfs-169597.sp1.0.bootrom\n
9976ea740ad45acd13974dfd8f3cfb16  fvcommon-ramfs-169597sp1.1.bootrom\n
b61203e39905fcdb1bee57903c6c94c1  fvcommon-ramfs-169597sp1.2.bootrom\n
1c30ff5f765239d8cfc324644268cd6e  fvcommon-ramfs-169597sp1.3.bootrom\n
c1874a0e69256fe2ea127968e2510a67  fvcommon-sda1-149467.sp1.03.bootrom\n
a90672ba75da9ded5116e5f625370550  fvcommon-sda1-149467sp1.1.bootrom\n
f4e399f98e488be3be17767b585b3fd5  fvcommon-sda1-169597.sp1.0.bootrom\n
4fc71fca14c63da8bb79a3bccce37950  fvcommon-sda1-169597sp1.1.bootrom\n
0337e51969659e654d6cf692dfb8bcb3  fvcommon-sda1-169597sp1.2.bootrom\n
f3a65bf542b1691fc76fdfd648307ff3  fvcommon-sda1-169597sp1.3.bootrom\n
82cc580cf2682630c36733b30949e598  fvcommon-sda1-debug-149467.sp1.03.bootrom\n
ee4440513a502c44930df9536accf8bb  sda1_422_uart_basesp1.3.bootrom\n
7b8d677f987f9db06cba0ce67e37f535  fvcommon-ramfs-184581sp1.01.bootrom\n
e4450b4df8ceb0e528766f3b2efdb65f  fvcommon-sda1-184581sp1.01.bootrom\n
"
board_version=`cat /sys/hypervisor/board/board_serial`
slot1_serial=`cat /sys/hypervisor/board/slot1_serial`
slot2_serial=`cat /sys/hypervisor/board/slot2_serial`
bib_version=`cat /sys/hypervisor/board/board_revision`
mde_version=`cat /sys/hypervisor/version`
memtotal=`cat /proc/meminfo | grep "MemTotal" | awk '{printf $2}'`
memory_size=`awk 'BEGIN {printf '$memtotal'/1024.0/1024.0}'`
mem_freq=`cat /proc/tile/memory | grep "0_speed" | awk '{print $2}'`
mem_freq=`expr $mem_freq / 8000000`
cpu_freq=`cat /proc/cpuinfo | grep "cpu MHz" | awk '{print $4}'`
cpu_freq=`echo $cpu_freq | sed 's/\([0-9]*\).\(0*\)/\1/g'`
cpu_freq=`awk 'BEGIN {printf '$cpu_freq'/1000.0}'`
srombin_size=`sbim | grep "SROM booter" | awk '{print $4}'`
disk_link_speed=`dmesg | grep "link up" | awk '{print $5}'`
echo "[`date`]: fival version $board_part $box_serial" > /opt/check_tmplog
# Dump the version of the FPGA's rom.
if [ "$box_type" == "NAPA-MASTER" ];then
	insmod ${bsp}/napabsp/driver/drv_hwlogic_3.10.61.ko
	drv_major=`cat /proc/devices | grep drv_hwlogic_bdctrl | awk '{print $1}'`
	if [ ! -f /dev/drv_hwlogic_bdctrl ];then
	mknod /dev/drv_hwlogic_bdctrl c $drv_major 0
	fi
	major=`napa_fpgaver | grep "Major version" | awk -F ":" '{print $2}'`
	release_date=`napa_fpgaver | grep "Release date" | awk -F ":" '{print $2}'` 
	echo "[FPGA-VERSION-----`date +'%Y-%m-%d %T'`]: Get the FPGA version     : ${major} release at : $release_date" > /opt/check_tmplog
       #echo "Get the version of the FPGA's rom: $major, release at: $release_date".
fi


sbim -e ./ramfs_rom -l @0
cur_md5=`md5sum ./ramfs_rom | awk '{print $1}'`
spi_ramfs_version=`echo -e $md5sum_str | grep ${cur_md5} | awk '{print $2}'`
rm -f   ./ramfs_rom
sbim -e ./sda_rom -l @1
cur_md5=`md5sum ./sda_rom | awk '{print $1}'`
spi_sda_version=`echo -e $md5sum_str | grep ${cur_md5} | awk '{print $2}'`
rm -f   ./sda_rom
[ $spi_ramfs_version ] || spi_ramfs_version="unknown version"
[ $spi_sda_version   ] || spi_sda_version="unknown version"

    

echo "[BOARD-VERSION----`date +'%Y-%m-%d %T'`]: Get board serial     : ${board_version}" 				> /opt/check_tmplog
echo "[SLOT1-SERIAL-----`date +'%Y-%m-%d %T'`]: Get slot1 serial     : ${slot1_serial}" 				> /opt/check_tmplog
echo "[SLOT2-SERIAL-----`date +'%Y-%m-%d %T'`]: Get slot2 serial     : ${slot2_serial}" 				> /opt/check_tmplog
echo "[BIB-VERSION------`date +'%Y-%m-%d %T'`]: Get bib versionl     : ${bib_version}"   				> /opt/check_tmplog
echo "[MDE-VERSION------`date +'%Y-%m-%d %T'`]: Get mde version      : ${mde_version}"    			> /opt/check_tmplog
echo "[MEM-SIZE---------`date +'%Y-%m-%d %T'`]: Get memory size      : ${memory_size} GB" 			> /opt/check_tmplog
echo "[MEM-FREQ---------`date +'%Y-%m-%d %T'`]: Get memory freq      : ${mem_freq} MHz"   			> /opt/check_tmplog
echo "[CPU-FREQ---------`date +'%Y-%m-%d %T'`]: Get cpu freq         : ${cpu_freq} GHz"   			> /opt/check_tmplog
echo "[SROMBOOT-SIZE----`date +'%Y-%m-%d %T'`]: Get sromboot size    : ${srombin_size} Bytes" 	> /opt/check_tmplog
echo "[RAMFSROM-VERSION-`date +'%Y-%m-%d %T'`]: Get ramfsrom version : ${spi_ramfs_version}" 		> /opt/check_tmplog
echo "[SDAROM-VERSION---`date +'%Y-%m-%d %T'`]: Get sdasrom version  : ${spi_sda_version}" 			> /opt/check_tmplog
echo "[DISK-LINKSPEED---`date +'%Y-%m-%d %T'`]: Get disk linkspeed   : ${disk_link_speed} Gbps" > /opt/check_tmplog

for disk in media ;do
    if [ -b /dev/${disk} ]
    then
        disk_size=`fdisk -l /dev/${disk} | grep "Disk /dev/sd" | awk '{print $3}'`
        disk_type=`fdisk -l /dev/${disk} | grep "Disk /dev/sd" | awk '{print $4}'`
	
        echo "[DISK-SIZE--------`date +'%Y-%m-%d %T'`]: Get  $disk size         : ${disk_size} ${disk_type}" > /opt/check_tmplog
    fi
done
echo "return $returnarg"
