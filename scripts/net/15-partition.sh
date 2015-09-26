#! /bin/sh

path=`dirname $0`
. ${path}/reserve.script/env.shf
. ${path}/reserve.script/partition.shf

returnarg=0
env_get
if [ $? -ne 0 ];then
	returnarg=1
  echo "return $returnarg"
	exit
fi

for disk in $media ; do
	partition $disk 
	fdisk -u /dev/$disk   <<MYEOF 
d
n
p
1


p
w
MYEOF
	[ $? -ne 0 ] &&  returnarg=15 
done 
echo "return $returnarg"





