#! /bin/sh
### BEGIN INIT INFO
# File:				wifi_run.sh	
# Provides:         manage wifi station and smartlink
# Required-Start:   $
# Required-Stop:
# Default-Start:     
# Default-Stop:
# Short-Description:start wifi run at station or smartlink
# Author:			
# Email: 			
# Date:				2012-8-8
### END INIT INFO

#关于wifi 运行的脚本

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin
MODE=$1
cfgfile="/etc/jffs2/anyka_cfg.ini"

play_please_config_net()
#将提示文件的路径和文件名写入到 提示音列表文件，然后给anyka_ipc进程发送信号，进程anyka_ipc接收到信号后，调取音频解码库，播放提升音
	echo "/usr/share/anyka_please_config_net.mp3" > /tmp/alarm_audio_list
	echo "play please config wifi tone"
	killall -12 anyka_ipc	## send signal to anyka_ipc
}

play_get_config_info()
{
	echo "/usr/share/anyka_camera_get_config.mp3" > /tmp/alarm_audio_list
	killall -12 anyka_ipc	## send signal to anyka_ipc
}

play_afresh_net_config()
{
	echo "/usr/share/anyka_afresh_net_config.mp3" > /tmp/alarm_audio_list
	echo "play please afresh config net tone"
	killall -12 anyka_ipc	## send signal to anyka_ipc
}

#设置WiFi的静态地址
using_static_ip()
{
	ipaddress=`awk 'BEGIN {FS="="}/\[ethernet\]/{a=1} a==1&&$1~/^ipaddr/{gsub(/\"/,"",$2);gsub(/\;.*/, "", $2);gsub(/^[[:blank:]]*/,"",$2);print $2}' $cfgfile`
	
	netmask=`awk 'BEGIN {FS="="}/\[ethernet\]/{a=1} a==1&&$1~/^netmask/{gsub(/\"/,"",$2);gsub(/\;.*/, "", $2);gsub(/^[[:blank:]]*/,"",$2);print $2}' $cfgfile`
	gateway=`awk 'BEGIN {FS="="}/\[ethernet\]/{a=1} a==1&&$1~/^gateway/{gsub(/\"/,"",$2);gsub(/\;.*/, "", $2);gsub(/^[[:blank:]]*/,"",$2);print $2}' $cfgfile`

	ifconfig wlan0 $ipaddress netmask $netmask
	route add default gw $gateway
	sleep 1
}

#启动WiFi的函数
station_start()
{
	### remove all wifi driver
	#将wifi驱动卸载
	/usr/sbin/wifi_driver.sh uninstall

	#杀死smartlink进程
	## stop smartlink app
	killall -9 smartlink

	## install station driver
	#加载wifi驱动
	/usr/sbin/wifi_driver.sh station
	
	i=0
	###### wait until the wifi driver insmod finished.
	#循环加载wifi模块
	while [ $i -lt 3 ]
	do
		if [ -d "/sys/class/net/wlan0" ];then
			ifconfig wlan0 up
			break
		else
			sleep 1
			#变量i的自增1
			i=`expr $i + 1`
		fi
	done
	
	if [ $i -eq 3 ];then
		echo "wifi driver install error, exit"
		return 1
	fi

	echo "wifi driver install OK"
	#wifi开始工作 
	/usr/sbin/wifi_station.sh start
	
	#获取wpa_supplicant 进程号，判断wifi是否已启动
	pid=`pgrep wpa_supplicant`
	if [ -z "$pid" ];then
		echo "the wpa_supplicant init failed, exit start wifi"
		return 1
	fi

	#wifi开始连接
	/usr/sbin/wifi_station.sh connect

	#判断上个命令的退出状态，或函数的返回值 就是判断pid的返回值
	ret=$?
	echo "wifi connect return val: $ret"
	
	#如果wifi启动成功，就启动指示灯
	if [ $ret -eq 0 ];then
		if [ -d "/sys/class/net/eth0" ]
		then
			ifconfig eth0 down
			ifconfig eth0 up
		fi
		#启动指示灯
		/usr/sbin/led.sh blink 4000 200
		echo "wifi connected!"
		return 0
	else
		echo "[station start] wifi station connect failed"
	fi

	return $ret
}
#启动smartlink_start
smartlink_start()
{
	/usr/sbin/wifi_driver.sh uninstall
	### start smartlink status led
	/usr/sbin/led.sh blink 1000 200
	/usr/sbin/wifi_driver.sh smartlink
	## run smartlink app
	smartlink &
}

#main

#获取wireless下ssid的值
ssid=`awk 'BEGIN {FS="="}/\[wireless\]/{a=1} a==1 && $1~/^ssid/{gsub(/\"/,"",$2);
	gsub(/\;.*/, "", $2);gsub(/^[[:blank:]]*/,"",$2);print $2}' $cfgfile`

if [ "$ssid" = "" ]
then
#启动USB串口烧录tencent.conf
    usb_serial & #start usb_serial here to burn tencent.conf

	sleep 3 #### sleep, wait the anyka_ipc load to the memery
	play_voice_flag=0
	while true
	do
		#wait anyka_ipc play the voice
	#启动smartlink_start
		smartlink_start
	
		while true
		do
			if [ "$play_voice_flag" = "0" ];then
				#echo "we will check anyka_ipc"
				#命令解析：pgrep anyka_ipc 获取指定进程的进程号
				check_ipc=`pgrep anyka_ipc`
				
				#如果check_ipc不为空则执行提示音
				if [ "$check_ipc" != "" ];then
					play_voice_flag=1
					sleep 2 
					play_please_config_net
				fi
			fi
#判断/tmp/wireless/gbk_ssid是否存在
			if [ -e "/tmp/wireless/gbk_ssid" ];then		
			#存在则播放提示音
				play_get_config_info
			#开始配置网络
				station_start
				
				#判断上个函数的返回值
				if [ "$?" = 0 ];then
					### start station status led
					启动指示灯
					/usr/sbin/led.sh blink 4000 200
					exit 0
				else
					echo "connect failed, ret: $?, please check your ssid and password !!!"
					#播放“请配置网络的提示音”
					play_afresh_net_config
					#### clean config file and re-config
					#将默认配置文件，拷贝到配置文件目录下
					cp /usr/local/factory_cfg.ini /etc/jffs2/anyka_cfg.ini	
					#删除wifi 的临时节点
					rm -rf /tmp/wireless/
					#停止wifi的工作
					/usr/sbin/wifi_station.sh stop
					break
				fi
			fi
			sleep 1
		done
	done

	killall usb_serial
	
	#g_file_storage这是？
	rmmod g_file_storage
fi


