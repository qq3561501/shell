#! /bin/sh
#: run all the script
#$1 : ip address
#$2 : config files
#$3 : interactive modle
#$4 : rootfs tar package size
path=`dirname $0`
. ${path}/net/reserve.script/env.shf
. ${path}/net/reserve.script/print_check.shf
. ${path}/net/reserve.script/my_process_monitor.shf
box_serial=`sshpass -p tilera ssh root@$1 "cat /sys/hypervisor/board/board_serial"`
board_part=`sshpass -p tilera ssh root@$1 "cat /sys/hypervisor/board/board_part" | awk '{print $1}' `
board_part=`echo $board_part | tr -d '\b'` 
logfile="/opt/logs/${box_serial}_${board_part}"
[ ! -d /opt/logs ] && mkdir /opt/logs
echo $logfile
touch $logfile
org_dir=/opt/fival-dt-tilegx
sshpass -p tilera ssh root@$1 "rm -f /opt/fival-dt-tilegx.tar"

scripts=`cat ${path}/../manifest/$2 | grep -v "#"`


echo "[`date`]: offline start $board_part_all $box_serial" |tee -a "$logfile"

for script in $scripts ; do
	isdo=y
	if [ $3 -eq 1 ] ; then
		read -p "running script ${script} [y/n]:" isdo
	fi
	
	isdo=`echo $isdo | tr N n`
	
	if [ $isdo != n ] ; then
		echo -n "$script" | tee -a "$logfile"	 
		
		if [ $script == "25-rootfs.sh" ];then
		  scp_print $4 $1 | tee -a "$logfile"
		  echo "extract system " | tee -a "$logfile"  				
			sshpass -p tilera ssh root@$1 "${org_dir}/scripts/net/$script" > ./tmplog 2>&1 &
			sleep 5
			extract_print $1 | tee -a "$logfile"
		else			
			sshpass -p tilera ssh root@$1 "${org_dir}/scripts/net/$script" > ./tmplog	2>&1
		fi
		sshpass -p tilera ssh root@$1 " [ -f /opt/check_tmplog ] && cat /opt/check_tmplog"	
		return_arg=`cat ./tmplog | grep "return" | awk '{ print $2 }' `
		cat ./tmplog >> $logfile
		print_check $return_arg 
		
	fi	
	
done

[ -f ${path}/tmpresult_${box_serial}_${board_part} ] && rm ${path}/tmpresult/${box_serial}_${board_part}