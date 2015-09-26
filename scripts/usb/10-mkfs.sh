#! /bin/sh
#
# [$1]: STRING	System link to startup the box. 
# [$2]: STRING	Network port.
# [$3]: STRING	IP Address.
#

depends=./depends/
tilera=./tilera/

box_serial=`cat /sys/hypervisor/board/board_serial`
board_part_all="`cat /sys/hypervisor/board/board_part`"
board_part=`cat /sys/hypervisor/board/board_part |awk '{print $1}'`
logfile="./logs/${box_serial}_${board_part}"
box_type=`cat /sys/hypervisor/board/board_part | awk '{print $3}'`
echo "[`date`]: offline start $board_part_all $box_serial" |tee -a "$logfile"

cp ${depends}dmesg /bin
cp ${depends}mkfs.ext4 /bin
cp ${depends}lib* /lib

sda_size=0
sdb_size=0
sdc_size=0

# Make sure that we have three disks.
sda=`dmesg | grep -wq "\[sda\]" && echo "in"`
if [ "$sda" != "in" ]
then
	echo "We can't find Sda on $box_type $box_serial " |tee -a "$logfile"
else
	mknod /dev/sda b 8 0 > /dev/null 2>&1
	mknod /dev/sda1 b 8 1 > /dev/null 2>&1

	sda_log=`fdisk /dev/sda > ./${box_type}-${box_serial}.sda <<MYEOF
d
n
p
1


p
w
MYEOF`

	# Get the size of Sda.
	sda_size=`cat ./${box_type}-${box_serial}.sda | grep "Disk /dev/sda" | sed 's/.*, \([0-9]*\) bytes.*/\1/g'`
	echo "Find Sda: $sda_size bytes, start to mkfs." |tee -a "$logfile"

	rm -rf ./${box_type}-${box_serial}.sda

	mkfs.ext4 /dev/sda1 > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
		echo "Initialize the disk(sda) success." |tee -a "$logfile"
	else
		echo "Initialize the disk(sda) failed." |tee -a "$logfile"
	fi		
fi

sdb=`dmesg | grep -wq "\[sdb\]" && echo "in"`
if [ "$sdb" != "in" ]
then
	echo "We can't find Sdb on $box_type $box_serial " |tee -a "$logfile"
else
	mknod /dev/sdb b 8 16 > /dev/null 2>&1
	mknod /dev/sdb1 b 8 17 > /dev/null 2>&1

	sdb_log=`fdisk /dev/sdb > ./${box_type}-${box_serial}.sdb <<MYEOF
d
n
p
1


p
w
MYEOF`

	# Get the size of Sdb.
	sdb_size=`cat ./${box_type}-${box_serial}.sdb | grep "Disk /dev/sdb" | sed 's/.*, \([0-9]*\) bytes.*/\1/g'`
	echo "Find Sdb: $sdb_size bytes, start to mkfs." |tee -a "$logfile"

	rm -rf ./${box_type}-${box_serial}.sdb

	mkfs.ext4 /dev/sdb1 > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
		echo "Initialize the disk(sdb) success." |tee -a "$logfile"
	else
		echo "Initialize the disk(sdb) failed." |tee -a "$logfile"
	fi
fi

sdc=`dmesg | grep -wq "\[sdc\]" && echo "in"`
if [ "$sdc" != "in" ]
then
	echo "We can't find Sdc on $box_type $box_serial " |tee -a "$logfile"
else
	mknod /dev/sdc b 8 32 > /dev/null 2>&1
	mknod /dev/sdc1 b 8 33 > /dev/null 2>&1

	sdc_log=`fdisk /dev/sdc > ./${box_type}-${box_serial}.sdc <<MYEOF
d
n
p
1


p
w
MYEOF`

	# Get the size of Sdc.
	sdc_size=`cat ./${box_type}-${box_serial}.sdc | grep "Disk /dev/sdc" | sed 's/.*, \([0-9]*\) bytes.*/\1/g'`
	echo "Find Sdc: $sdc_size bytes, start to mkfs." |tee -a "$logfile"

	rm -rf ./${box_type}-${box_serial}.sdc

	mkfs.ext4 /dev/sdc1 > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
		echo "Initialize the disk(sdc) success." |tee -a "$logfile"
	else
		echo "Initialize the disk(sdc) failed." |tee -a "$logfile"
	fi
fi

# FIXME: We should check the box type here.
#ms=`cat /sys/hypervisor/board/board_part | grep -c "NAPA-MASTER"`
#if [ $ms -ne 0 ]
#then
#	box_type="NapaMaster"
#else
#	box_type="NapaSlave"
#fi

#sbim --install-booter ${tilera}sromboot_433.bin -m 2 --yes
#if [ $? -eq 0 ]
#then
#	echo "sbim install sromboot_433.bin success." |tee -a "$logfile"
#else
#	echo "sbim install sromboot_433.bin failed." |tee -a "$logfile"
#fi

#slot_0=`sbim | grep "slot 0" | grep -c "locked"`
#slot_1=`sbim | grep "slot 1" | grep -c "locked"`
#if [ $slot_0 -eq 1 ]
#then
#	sbim -U @0
#fi
#if [ $slot_1 -eq 1 ]
#then
#	sbim -U @1
#fi
#sbim -i ${tilera}fvcommon-ramfs-184581sp1.01.bootrom -l @0 -c "RECOVERY"   
#    if [ $? -eq 0 ]
#    then
#	    echo "sbim install ${tilera}fvcommon-ramfs-184581.sp1.01.bootrom success." |tee -a "$logfile"
#    else
#	    echo "sbim install ${tilera}fvcommon-ramfs-184581.sp1.01.bootrom failed." |tee -a "$logfile"
#    fi
#sbim -i ${tilera}fvcommon-sda1-184581sp1.01.bootrom -l @1 -c "USER"    
#    if [ $? -eq 0 ]
#    then
#	    echo "sbim install ${tilera}fvcommon-sda1-184581.sp1.01.bootrom success." |tee -a "$logfile"
#    else
#	    echo "sbim install ${tilera}fvcommon-sda1-184581.sp1.01.bootrom failed." |tee -a "$logfile"
#    fi

#sbim -L @0
#
if [ $sda_size -ne 0 ]
then
	mkdir /sda_mnt
fi
if [ $sdb_size -ne 0 ]
then
	mkdir /sdb_mnt
fi
if [ $sdb_size -ne 0 ] 
then
	mkdir /sdc_mnt
fi
if [ ! -d /sda_mnt ] && [ ! -d /sdb_mnt ] && [ ! -d /sdb_mnt ]
then
	sbim -p @0
fi 


# Dump the version of the FPGA's rom.
#if [ "$box_type" == "NapaMaster" ]
#then
#	insmod ./napabsp/driver/drv_hwlogic_3.10.61.ko
#	drv_major=`cat /proc/devices | grep drv_hwlogic_bdctrl | awk '{print $1}'`
#	if [ "$drv_major" != "" ]
#	then
#		mknod /dev/drv_hwlogic_bdctrl c $drv_major 0
#	fi
#	napa_drv |tee -a "$logfile"
#	#major=`napa_drv | grep "Major version" | awl -F ":" '{print $2}'`
#	#release_date=`napa_drv | grep "release date" | awl -F ":" '{print $2}'`
#
#	#echo "Get the version of the FPGA's rom: $major, release at: $release_date".
#fi

# Linkup the network port.
ifconfig $2 $3 netmask 255.255.0.0
sleep 5

exit 0





