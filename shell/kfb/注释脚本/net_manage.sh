#! /bin/sh
### BEGIN INIT INFO
# File:				net_manage.sh
# Provides:         select eth or wifi
# Required-Start:   $
# Required-Stop:
# Default-Start:     
# Default-Stop:
# Short-Description 
# Author:			
# Email: 			
# Date:				2013-1-15
### END INIT INFO
#进行网络的选择，WiFi或者eth0

mode=""
status=""

check_and_start_wlan()
{
	if [ "$mode" != "wlan" ]
	then
		mode=wlan
		ip=`ifconfig eth0 | grep 'inet addr' | awk '{print $2}' | awk -F ':' '{print $2}'`
		ipaddr del $ip dev eth0 2>/dev/null
		ifconfig eth0 down
		/usr/sbin/wifi_manage.sh start
		ifconfig eth0 up
	fi
}

check_and_start_eth()
{
	if [ "$mode" != "eth" ]
	then
		mode=eth
		/usr/sbin/wifi_manage.sh stop
		/usr/sbin/eth_manage.sh start
	fi
}


#
#main
#
#主函数
#Do load ethernet module?

#判断/sys/class/net/eth0是否为目录，并结果取非
#如果不是目录则执行下面的命令 即启动WiFi
if [ ! -d "/sys/class/net/eth0" ]
then
	/usr/sbin/wifi_manage.sh start
	exit 1
else
	#ethernet always up
	ifconfig eth0 up
	sleep 3
fi
	
status=`ifconfig eth0 | grep RUNNING`
while true
do
	#check whether insert internet cable
	
	if [ "$status" = "" ]
	then
	#启动wifi
		#don't insert internet cable
		check_and_start_wlan		
	else
	#启动有线网络
		#have inserted internet cable
		check_and_start_eth
	fi

	tmp=`ifconfig eth0 | grep RUNNING`
	if [ "$tmp" != "$status" ]
	then		
		sleep 2
		tmp=`ifconfig eth0 | grep RUNNING`
		status=$tmp
	fi
    sleep 1
done
exit 0

