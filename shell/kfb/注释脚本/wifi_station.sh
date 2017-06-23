#! /bin/sh
### BEGIN INIT INFO
# File:				wifi_station.sh	
# Provides:         wifi station start, stop and connect
# Author:			
# Date:				2015年11月10日
### END INIT INFO
#wifi 设置配置相关的脚本

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin
MODE=$1
cfgfile="/etc/jffs2/anyka_cfg.ini"
#用法函数
usage()
{
	echo "Usage: $0 start | stop | connect"
}

wifi_station_start()
{
#启动wifi 
#命令解析：-B 后台运行，-D 选择驱动，-c 文件名，-i 接口，监听的接口
	wpa_supplicant -B -iwlan0 -Dwext -c /etc/jffs2/wpa_supplicant.conf
}

using_static_ip()
{
#从配置文件中取出ip地址，子网掩码，网关，并启动wifi 添加路由
	ipaddress=`awk 'BEGIN {FS="="}/\[ethernet\]/{a=1} a==1 &&
		$1~/^ipaddr/{gsub(/\"/,"",$2);gsub(/\;.*/, "", $2);
		gsub(/^[[:blank:]]*/,"",$2);print $2}' $cfgfile`
	netmask=`awk 'BEGIN {FS="="}/\[ethernet\]/{a=1} a==1 && 
		$1~/^netmask/{gsub(/\"/,"",$2);gsub(/\;.*/, "", $2);
		gsub(/^[[:blank:]]*/,"",$2);print $2}' $cfgfile`
	gateway=`awk 'BEGIN {FS="="}/\[ethernet\]/{a=1} a==1 && 
		$1~/^gateway/{gsub(/\"/,"",$2);gsub(/\;.*/, "", $2);
		gsub(/^[[:blank:]]*/,"",$2);print $2}' $cfgfile`

	ifconfig wlan0 $ipaddress netmask $netmask
	route add default gw $gateway
}

check_ip_and_start()
{
	echo "check ip and start"
#获取配置文件中dhcp中的值
	dhcp=`awk 'BEGIN {FS="="}/\[ethernet\]/{a=1} a==1 && 
		$1~/^dhcp/{gsub(/\"/,"",$2);gsub(/\;.*/, "", $2);
		gsub(/^[[:blank:]]*/,"",$2);print $2}' $cfgfile`
	status=
	i=0
	#循环分配wifi的动态地址，如果分配不到，就是使用静态地址
	while [ $i -lt 2 ]
	do
		if [ $dhcp -eq 1 ];then
			echo "using dynamic ip ..."
			killall udhcpc
			udhcpc -i wlan0 &
			sleep 3
		elif [ $dhcp -eq 0 ];then
			echo "using static ip ..."
			using_static_ip
			sleep 1
		fi
		status=`ifconfig wlan0 | grep "inet addr:"`
		if [ "$status" != "" ];then
			break
		fi
		i=`expr $i + 1`
	done
	
	if [ $i -eq 2 ];then
		echo "[WiFi Station] fails to get ip address"
		return 1
	fi

	return 0
}

wifi_station_do_connect()
{
	security=$1
	ssid=$2
	pswd=$3
	#### when debug, echo next line, other times don't print it
	echo "security=$security ssid=$ssid password=$pswd"
	#启动网络
	/usr/sbin/station_connect.sh $security "$ssid" "$pswd"
	#获取上一个命令执行的结果，并将其打印出来，
	ret=$?
	echo "/usr/sbin/station_connect.sh, return val:$ret"
	sleep 1

	if [ $ret -eq 0 ];then
		i=0
		
	#循环获取wlan的状态
		while [ $i -lt 8 ]
		do
			sleep 3
			OK=`wpa_cli -iwlan0 status | grep wpa_state`
			if [ "$OK" = "wpa_state=COMPLETED" ];then
				echo "[WiFi Station] $OK, security=$security ssid=$ssid pswd=$pswd"
				check_ip_and_start   #### get ip
				if [ $? -eq 0 ];then
					return 0
				else
					return 1
				fi
			else
				echo "wpa_cli still connectting, info[$i]: $OK"
			fi
			i=`expr $i + 1`
		done
		### time out judge
		if [ $i -eq 8 ];then
			echo "wpa_cli connect time out, try:$i, result:$OK"
			return 1
		fi
	else
		echo "station_connect.sh run failed, ret:$ret, check your arguments"
		return $ret
	fi
}

store_config_2_ini()
{
#保存数据
	#### save security
	if [ -n "$1" ];then
		old_security=`awk 'BEGIN {FS="="}/\[wireless\]/{a=1} a==1&&
			$1~/^security/{gsub(/\"/,"",$2);gsub(/\;.*/, "", $2);
			gsub(/^[[:blank:]]*/,"",$2);print $2}' $cfgfile`
		#### store info by replace
		echo "Save Security, new: $1"
		#将配置文件中的security的值赋给old_security
		sed -i -e "/security/ s%= $old_security%= $1%" $cfgfile
	fi

	#### save ssid
	if [ -n "$2" ];then
		old_ssid=`awk 'BEGIN {FS="="}/\[wireless\]/{a=1} a==1&&
			$1~/^ssid/{gsub(/\"/,"",$2);gsub(/\;.*/, "", $2);
		gsub(/^[[:blank:]]*/,"",$2);print $2}' $cfgfile`
		#### store info by replace
		echo "Save Ssid, new: $1"
		sed -i -e "/^ssid/ s/= $old_ssid/= $2/" $cfgfile
	fi

	echo "[WiFi Station] Save Config OK"
	#### for debug, show ini file first 23 line content
	##head -23 $cfgfile
}

wifi_station_check_security()
{
	echo "check security, curval: $1"
	#### 加密方式不为wpa或open的都认为需要重新获取
	if [ "$1" != "wpa" ] && [ "$1" != "open" ];then
		echo "[check security] invalid, val:$1"
		return 1
	elif [ -z "$1" ];then
		echo "[check security] invalid, val is null"
		return 1
	else
		echo "[check security] ok, val: $1"
		return 0
	fi
}

wifi_station_connect()
{
	echo "connect wifi station......"
	#### get ini info
	#从配置文件中取出ssid、password、security、中的值
	ssid=`awk 'BEGIN {FS="="}/\[wireless\]/{a=1} a==1 && 
		$1~/^ssid/{gsub(/\"/,"",$2);gsub(/\;.*/, "", $2);
		gsub(/^[[:blank:]]*/,"",$2);print $2}' $cfgfile`
	password=`awk 'BEGIN {FS="="}/\[wireless\]/{a=1} a==1 && 
		$1~/^password/{gsub(/\"/,"",$2);gsub(/\;.*/, "", $2);
		gsub(/^[[:blank:]]*/,"",$2);print $2}' $cfgfile`
	security=`awk 'BEGIN {FS="="}/\[wireless\]/{a=1} a==1 &&
		$1~/^security/{gsub(/\"/,"",$2);gsub(/\;.*/, "", $2);
		gsub(/^[[:blank:]]*/,"",$2);print $2}' $cfgfile`

	############################# 正常连接时 ##########################
	#### ssid不为空则认为机器被配置过。已配置过的机器，进入正常连接
	while [ -n "$ssid" ]
	do
		#### 正常连接时，检查加密方式，不正确则通过当前ssid去搜索并改写为正确的。
		#判断加密方式
		wifi_station_check_security "$security"
		#### 隐藏时通过ssid无法扫描到加密方式
		if [ $? -eq 1 ];then
			security="" #### clean the value
			break		#### 无法通过扫描获取加密方式时，尝试wpa和open方式
		fi

		#### 此时所有参数应为正常的，否则连接会失败
		#获取动态IP地址，和检查wlan状态
		wifi_station_do_connect "$security" "$ssid" "$password"
		
		if [ $? -eq 0 ];then
			echo "[WiFi Station] Connect OK"
			return 0
		elif [ $? -eq 3 ];then
			echo "[WiFi Station] Normal connect failed, argments error"
			return 3
		else
			echo "[WiFi Station] Normal connect failed"
			return 1
		fi
	done
	############################# 正常连接时 ##########################

	#### if run to here, 说明ssid被隐藏了或者某些原因上述代码无法获取加密方式，此时需要尝试
	if [ -n "$ssid" ] && [ -z "$security" ];then
		wpa_cli -iwlan0 scan #### must scan
		sleep 1
		for security in wpa open
		do
			wifi_station_do_connect $security "$ssid" "$password"
			if [ 0 -eq $? ];then
				store_config_2_ini $security "" #### save config, ssid don't need save
				return 0
			elif [ $? -eq 3 ];then
				echo "$security connect, arguments error, please check"
				return 3
			fi
		done
		echo "[WiFi Station] Normal connect failed"
		return 1
	fi

	######## 通过smartlink 或者 voicelink 配置网络时 运行下面的代码 ######## 
	#### if run to here, it means the mechine need to be config ####

	#### 1. get two encode types ssid from temporary file
	gbk_ssid=`cat /tmp/wireless/gbk_ssid`
	utf8_ssid=`cat /tmp/wireless/utf8_ssid`
	echo "##### gbk_ssid: $gbk_ssid"
	echo "##### utf-8_ssid: $utf8_ssid"

	#### 2. if pswd is empty, it means security is open, connect direct
	if [ -z "$password" ];then
		echo "connect open router, no password"
		for ssid in "$gbk_ssid" "$utf8_ssid"
		do
			wifi_station_do_connect open "$ssid" "" 	## the password fill empty
			if [ 0 -eq $? ];then
				store_config_2_ini open "$ssid"		## save config
				return 0
			elif [ $? -eq 3 ];then
				echo "wpa connect, arguments error, please check"
				return 3
			fi
		done
		echo "open security connect faile, please check"
		return 1
	fi

	#### 3. if security is not open, we only use wpa with two encode types ssid to try connect
	for ssid in "$gbk_ssid" "$utf8_ssid"
	do
		wifi_station_do_connect wpa "$ssid" "$password"
		if [ $? -eq 0 ];then
			store_config_2_ini wpa "$ssid" 
			return 0
		elif [ $? -eq 3 ];then
			echo "wpa connect, arguments error, please check"
			return 3
		fi
	done
	#### if run to here, that means the way wpa+gbk or wpa+utf8 connect failed, need to be reconfiguration
	echo "[WiFi Station] Connect Failed, try again !!!"
	return 1
}

wifi_station_stop()
{
	echo "stop wifi station......"
	killall wpa_supplicant
	killall udhcpc
	ifconfig wlan0 down
}

#主函数，根据传入的参数进行执行函数
case "$MODE" in
	start)
		wifi_station_start
		;;
	stop)
		wifi_station_stop
		;;
	connect)
		wifi_station_connect
		return $?
		;;
	*)
		usage
		;;
esac
exit 0


