#! /bin/sh
#########################################################
# 	Name: run.sh																				#	
# 	OS: For use and tested against CentOS 6.x           #
# 	Description: The first script for FIVAL offline test#
#		Author: Mr.handsome Su                              #
#                                                       #
#	 	Last Updated: Sep 25th 2015                         #
#########################################################
#		input:                                              #
# 	[$1]: STRING	System link to startup the box.       #
# 	[$2]: STRING	Network port.                         #
# 	[$3]: STRING	IP Address.                           #
#########################################################
#		output                                              #
#		none                                                #
#########################################################
tilera=./tilera/
sequence=1
tarpack=TileraMDE-4.3.3.184581_tilegx_tile_full.tar.xz
manis=`ls ./manifest | sort `
for mani in $manis ; do
	eval mani$sequence=$mani
	tmpprint=`cat ./manifest/$mani | grep "#:"`

	if [ $? -ne 0 ];then
		tmpprint="#:$mani"
	fi

	echo $tmpprint | sed "s/#/${sequence}\)$mani/"
	let sequence=$sequence+1
done

read -p "choose a number to run : " number
configs=mani$number
eval configs=\$$configs


monitor_pid=`ps -elf | grep "tile-monitor" | grep "$1"`
if [ "$monitor_pid" != "" ]
then
	kill -9 $monitor_pid > /dev/null 2>&1
fi

## Startup the box with the default bootrom, and test the link.
ip=$1
interactive=$2
if [ $# == 3 ] ; then
	tile-monitor --dev $1 --bootrom-file ${tilera}bootrom/fvcommon-ramfs --quit &
	sleep 100
	monitor_pid=`ps -elf | grep "tile-monitor" | grep "$1" | awk '{print $4}'`
	if [ "$monitor_pid" != "" ];then
		kill -9 $monitor_pid > /dev/null 2>&1
		echo "Check the system link, we can't link the box though: $1."
		exit 10
	fi
	tile-monitor --dev $1 --resume --here --launch -+- ./scripts/main_usb.sh $2  -+- --wait --quit
	ip=`cat ./tmpip$1`
	rm ./tmpip$1
	interactive=$3
	echo "### left test no need usb you can move to test next board ###"
fi
path_tmp=`pwd`
cd  ../
rm  fival-dt-tilegx.tar
tar -cf fival-dt-tilegx.tar fival-dt-tilegx

sshpass -p tilera scp -r fival-dt-tilegx.tar $ip:/opt
sshpass -p tilera ssh root@$ip  "tar xf /opt/fival-dt-tilegx.tar -C /opt/"
#sshpass -p password ssh root@$ip "mount -t nfs 192.168.10.7:/Gx_btk/Gx_btk_GA_V1.0 /mnt "	
#if [ $? -ne 0 ] ;then
#	echo "can't ssh"
#	exit 99
#fi
packsize=`ls -l $tarpack | awk '{print $5}'`
 sshpass -p tilera scp  $tarpack $ip:/opt/tile.tar.xz &
cd $path_tmp
./scripts/main_net.sh $ip $configs $interactive $packsize
#tile-monitor --net $ip --resume --here --launch -+- ./scripts/main_net.sh $configs $interactive -+- --wait --quit
