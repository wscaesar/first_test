#! /bin/sh
### BEGIN INIT INFO
# File:				station_connect.sh	
# Description:      wifi station connect to AP 
# Author:			gao_wangsheng
# Email: 			gao_wangsheng@anyka.oa
# Date:				2012-8-2
### END INIT INFO
#用来为不同的网络进行连接的脚本

MODE=$1
GSSID="$2"
SSID=\'\"$GSSID\"\'
GPSK="$3"
PSK=\'\"$GPSK\"\'
KEY=$PSK
KEY_INDEX=$4
KEY_INDEX=${KEY_INDEX:-0}
NET_ID=
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin

usage()
{
	echo "Usage: $0 mode(wpa|wep|open) ssid password"
	exit 3
}

refresh_net()
{
	#### remove all connected netword
	while true
	do
	#命令解析：wpa_cli -iwlan0 list_network列出所有的网络，NR是指前面读取到的行数,$1第一个字段
		NET_ID=`wpa_cli -iwlan0 list_network\
			| awk 'NR>=2{print $1}'`

		if [ -n "$NET_ID" ];then
		#移除/var/run/wpa_supplicant路径下的 所有网络连接信息
			wpa_cli -p/var/run/wpa_supplicant remove_network $NET_ID
		else
			break
		fi
	done
	#选择 ap
	wpa_cli -p/var/run/wpa_supplicant ap_scan 1
}


station_connect()
{	

#使能网络，选择网络，并保存配置
	sh -c "wpa_cli -iwlan0 set_network $1 scan_ssid 1"
	wpa_cli -iwlan0 enable_network $1
	wpa_cli -iwlan0 select_network $1
#	wpa_cli -iwlan0 save_config
	
}

connet_wpa()
{
	NET_ID=""
	refresh_net

	NET_ID=`wpa_cli -iwlan0 add_network`
	sh -c "wpa_cli -iwlan0 set_network $NET_ID ssid $SSID"
	
	#加密类型为 WPA-PSK
	wpa_cli -iwlan0 set_network $NET_ID key_mgmt WPA-PSK
	
	#psk 密码
	sh -c "wpa_cli -iwlan0 set_network $NET_ID psk $PSK"

	station_connect $NET_ID
}

connet_wep()
{
	NET_ID=""
	refresh_net
	if [ "$NET_ID" = "" ];then
	{
		NET_ID=`wpa_cli -iwlan0 add_network`
		sh -c "wpa_cli -iwlan0 set_network $NET_ID ssid $SSID"
		wpa_cli -iwlan0 set_network $NET_ID key_mgmt NONE
		
		#命令解析：#KEY计算出变量KEY中的字符数量
		keylen=$echo${#KEY}
		
		if [ $keylen != "9" ] && [ $keylen != "17" ];then
		{
		#后面的符号没有找到相关说明，但加上后会将变量KEY中的值原样输出，实际上不加也原样输出
			wepkey1=${KEY#*'"'}
			wepkey2=${wepkey1%'"'*};
			KEY=$wepkey2;
			echo $KEY
		}
		fi		
#设置密码		
		sh -c "wpa_cli -iwlan0 set_network $NET_ID wep_key${KEY_INDEX} $KEY"
	}
	elif [ "$GPSK" != "" ];then
	{
		keylen=$echo${#KEY}
		if [ $keylen != "9" ] && [ $keylen != "17" ];then
		{
			wepkey1=${KEY#*'"'}
			wepkey2=${wepkey1%'"'*};
			KEY=$wepkey2;
			echo $KEY
		}
		fi	
		sh -c "wpa_cli -iwlan0 set_network $NET_ID wep_key${KEY_INDEX} $KEY"
	}
	fi

	station_connect $NET_ID
}

connet_open()
{
	NET_ID=""
	
	#重新连接网络
	refresh_net
	
	#添加网络，并返回网络ID
	NET_ID=`wpa_cli -iwlan0 add_network`
	
	#设置网络ID 和 ssid
	sh -c "wpa_cli -iwlan0 set_network $NET_ID ssid $SSID"
	
	#命令解析：key_mgmt 是ap的加密类型，为none 就是这个ap是开放的没有密码
	wpa_cli -iwlan0 set_network $NET_ID key_mgmt NONE

	station_connect $NET_ID
}

connect_adhoc()
{
	NET_ID=""
	refresh_net
	if [ "$NET_ID" = "" ];then
	{
		wpa_cli ap_scan 2
		NET_ID=`wpa_cli -iwlan0 add_network`
		sh -c "wpa_cli -iwlan0 set_network $NET_ID ssid $SSID"
		#设置mode 为 1 ，点对点通讯有两种模式 (Ad hoc mode和Infrastracuture mode)，1即为Ad hoc mode
		wpa_cli -iwlan0 set_network $NET_ID mode 1
		wpa_cli -iwlan0 set_network $NET_ID key_mgmt NONE
	}
	fi
#启动网络
	station_connect $NET_ID
}

check_ssid_ok()
{
	if [ "$GSSID" = "" ]
	then
		echo "Incorrect ssid!"
		usage
	fi
}

check_password_ok()
{
	if [ "$GPSK" = "" ]
	then
		echo "Incorrect password!"
		usage
	fi
}


#
# main:
#

echo $0 $*
case "$MODE" in
	wpa)
	#先进行判断ssid 和 password的内容
		check_ssid_ok
		check_password_ok
		connet_wpa 
		;;
	wep)
		check_ssid_ok
		check_password_ok
		connet_wep 
		;;
	open)
		check_ssid_ok
		connet_open 
		;;
	adhoc)
		check_ssid_ok
		connect_adhoc
		;;
	*)
		usage
		;;
esac
exit 0

