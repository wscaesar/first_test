#!/bin/sh
#本文件是关于WiFi的开启和关闭的脚本
#文件路径变量
cfgfile="/etc/jffs2/anyka_cfg.ini"

wifi_ap_start()
{
#杀死 smartlink wpa_supplicant进程 并错误重定向与空设备文件
	killall smartlink 2>/dev/null
	killall wpa_supplicant 2>/dev/null

	## check driver
#卸载 smartlink station ap 等模块
	wifi_driver.sh uninstall

#加载station模块
	wifi_driver.sh station

#开启wifi
	echo "start wlan0 on ap mode"
	ifconfig wlan0 up

#从/etc/jffs2/anyka_cfg.ini 文件中取出ssid
	ssid=`awk 'BEGIN {FS="="}/\[softap\]/{a=1} a==1 && 
	$1~/s_ssid/{gsub(/\"/,"",$2);gsub(/\;.*/, "", $2);
	gsub(/^[[:blank:]]*/,"",$2);print $2}' $cfgfile`
	
#从/etc/jffs2/anyka_cfg.ini 文件中取出password
	password=`awk 'BEGIN {FS="="}/\[softap\]/{a=1} a==1 && 
	$1~/s_password/{gsub(/\"/,"",$2);gsub(/\;.*/, "", $2);
	gsub(/^[[:blank:]]*/,"",$2);print $2}' $cfgfile`

	echo "ap :: ssid=$ssid password=$password"
#判断变量ssid 中是否为空，如果为空就将123456赋给变量ssid 
	if [ -z "$ssid" ];then
		ssid="123456"
	fi
#保存设备的名字和密码
	/usr/sbin/device_save.sh name "$ssid"
	/usr/sbin/device_save.sh password "$password"
	
#如果密码字符串为空则，执行if的语句,否则执行else的语句
	if [ -z $password ];then
		/usr/sbin/device_save.sh setwpa 0
	else
		/usr/sbin/device_save.sh setwpa 2
	fi

#开启wifi热点接入点，-B 后台运行
	hostapd /etc/jffs2/hostapd.conf -B

	ifconfig wlan0 192.168.0.1
	
#开启和关闭路由
	route del default 2>/dev/null
	route add default gw 192.168.0.1 wlan0
	
#配置udhcpd
	udhcpd /etc/udhcpd.conf
}

wifi_ap_stop()
{
#杀死 hostapd udhcpd进程 并错误重定向与空设备文件
	killall hostapd 2>/dev/null
	killall udhcpd 2>/dev/null
	
#关闭wifi
	ifconfig wlan0 down

#卸载WiFi模块
	wifi_driver.sh uninstall

#删除默认路由  并错误重定向与空设备文件
	route del default 2>/dev/null
}

#用法说明函数
usage()
{
	echo "$0 start | stop"
}

#主函数
case $1 in
	start)
		wifi_ap_start
		;;
	stop)
		wifi_ap_stop
		;;
	*)
		usage
		;;
esac
	


