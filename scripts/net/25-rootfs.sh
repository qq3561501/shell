#! /bin/sh
path=`dirname $0`
. ${path}/reserve.script/env.shf
. ${path}/reserve.script/partition.shf
. ${path}/reserve.script/unpack.shf

returnarg=0
env_get
if [ $? -ne 0 ];then
	returnarg=1
  echo "return $returnarg"
	exit
fi
for disk in $media ;do
	[ -d /mnt/${disk}_mnt ] || mkdir /mnt/${disk}_mnt
	mount /dev/${disk}1 /mnt/${disk}_mnt 
	xzdec /opt/tile.tar.xz | tar x -C /mnt/${disk}_mnt & 
done 
while [ 1 ];do
	ps aux | grep xzdec | grep tar > /dev/null
	a=$?
	ps aux | grep tar | grep mnt > /dev/null
	b=$?
	if [ "$a" != "0" ] && [ "$b" != "0" ] ;then
		break
	fi
done	
for disk in $media ;do
	[ -d /mnt/${disk}_mnt ] || mkdir /mnt/${disk}_mnt
	umount  /mnt/${disk}_mnt 

done
#	for disk in $media ; do
#		$disk_size=`df -h | grep $disk | awk '{print $3}'`
#		sed -i -r "s /($disk)[^<]*/\1\t\t$disk_size" /opt/rootfs_tmplog
#	done
#done			

echo "return $returnarg"