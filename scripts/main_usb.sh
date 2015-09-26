#! /bin/sh
# [$1]: STRING  Network port.
# [$2]: STRING  USB PORT
udhcpc -i $1 --quit > /dev/null
sleep 10
ifconfig $1 | grep "UP BROADCAST RUNNING MULTICAST" > /dev/null
if [ $? -ne 0 ]
	then
	echo "Hmm,It seems theres no link on $1"
	exit 10
        else
                ifconfig $1 netmask 255.255.0.0
                ip=`ifconfig $1 | grep "inet addr" | awk '{ print $2 }'`
                ip=`echo $ip | awk -F : '{ print $2 }'`
                echo $ip > tmpip$2
                sleep 1
fi

 
