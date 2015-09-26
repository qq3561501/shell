#! /bin/sh

path=`dirname $0`
. ${path}/reserve.script/env_get.shf
. ${path}/reserve.script/partition.shf
. ${path}/reserve.script/unpack.shf
returnarg=0
env_get
if [ $? -ne 0 ];then
	returnarg=1
  echo "return $returnarg"
	exit
fi



sbim --install-booter ${org_dir}/tilera/sromboot_433.bin -m 2 --yes 
[ $? -eq 0 ] && returnarg=15
slot_0=`sbim | grep "slot 0" | grep -c "locked"`
slot_1=`sbim | grep "slot 1" | grep -c "locked"`
[ $slot_0 -eq 1 ] && sbim -U @0
[ $slot_1 -eq 1 ] && sbim -U @1

sbim -i ${tilera}bootrom/fvcommon-ramfs -l @0 -c "RECOVERY"   
[ $? -ne 0 ] && returnarg=15
sbim -i ${tilera}bootrom/fvcommon-sda1 -l @1 -c "USER"   
[ $? -ne 0 ] && returnarg=15

sbim -L @0
echo "return $returnarg"
