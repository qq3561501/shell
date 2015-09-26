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
	mkfs.ext4  /dev/${disk}1 
	[ $? -ne 0 ] && returnarg=20
done
echo "return $returnarg"