#! /bin/sh
path=`dirname $0`
. ${path}/reserve.script/env.shf
. ${path}/reserve.script/partition.shf
. ${path}/reserve.script/unpack.shf

returnarg=0
env_get
[ $? -ne 0 ] && echo "return 1";exit
for disk in $media ; do
	[ -d /mnt/${disk}_mnt ] || mkdir /mnt/${disk}_mnt
	mount /dev/${disk}1 /mnt/${disk}_mnt
	[ $? -ne 0 ] && echo "return 1";exit 	
  cp -rL $bsp/napabsp /mnt/${disk}_mnt/opt             	
	grep "rc.final" /mnt/${disk}_mnt/etc/init/tilera.conf > /dev/null
	if [ $? -ne 0 ];then
		sed -i '/end script/ i /etc/rc.final' /mnt/${disk}_mnt/etc/init/tilera.conf
	fi	
	mv /${disk}_mnt/opt/napabsp/rc.final /mnt/${disk}_mnt/etc/
	mv /${disk}_mnt/opt/napabsp/.profile /mnt/${disk}_mnt/root
	sed -i "s/ONBOOT=yes/ONBOOT=no/g" /mnt/${disk}_mnt/etc/sysconfig/network-scripts/ifcfg-gbe1
	sed -i "s/ONBOOT=yes/ONBOOT=no/g" /mnt/${disk}_mnt/etc/sysconfig/network-scripts/ifcfg-eth0
	sed -i '1s/#LABEL=root/\/dev\/sda1/g' /mnt/${disk}_mnt/etc/fstab
	umount /opt/${disk}_mnt >> /dev/null 2>&1
done	
echo "return $returnarg"
	



