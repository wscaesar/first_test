#!/bin/sh
#本文件是把设备的相关信息保存在指定的文件中的脚本
#
### BEGIN INIT INFO
# File:				device_save.sh
# Brief:			Modify soft APs name and password
# Provides:          
# Required-Start:   $
# Required-Stop:
# Default-Start:     
# Default-Stop:
# Short-Description:
# Author:			gao_wangsheng
# Email: 			gao_wangsheng@anyka.oa
# Date:				2012-8-1
### END INIT INFO
#

#用变量保存指定路径的文件
AP_FILE=/etc/jffs2/hostapd.conf

#保存第二个传入的参数
AP_NAME=$2

#保存第三个传入的参数
PASSWORD=$3

#命令解析：${PASSWORD:-$2}  如果PASSWORD存在，则AP_PASSWORD 为 PASSWORD的值，如果PASSWORD不存在，则AP_PASSWORD 为$2
AP_PASSWORD=${PASSWORD:-$2}

#保存名字，
save_name () 
{
#如果[ "$1" != "" ]为假则执行后面的命令
	[ "$1" != "" ] || return 

#命令解析;sh -c 执行后面的“”中的命令，sed -i 直接修改，s/^ssid=.* 以ssid=.*起始 其中是s/替换的意思，.*字符匹配。格式为s/被替换的内容/替换成为/其它开关选项；
#这个命令是在指定的文件中将某些字符替换掉
	sh -c "sed -i 's/^ssid=.*/ssid=$1/' $AP_FILE"
}

#保存密码
save_password () 
{
	[ "$1" != "" ] || return 
	PASS=$1
#不明白PASS//\&/\\&这个表达式的作用，反正删了也没有影响
	PASS=${PASS//\&/\\&}
	sh -c "sed -i 's/^wpa_passphrase=.*/wpa_passphrase=$PASS/' $AP_FILE"
}

#保存WPA
set_wpa () {
	[ "$1" != "" ] || return
	WPA=$1
	WPA=${WPA//\&/\\&}
	sh -c "sed -i 's/^wpa=.*/wpa=$WPA/' $AP_FILE"
}

#保存名字和密码
save_all () {
	save_name "$1"
	save_password $2
}

#
#main
#

case "$1" in
	name)
#函数传参
		save_name $2
		;;
	password)
		save_password $2
		;;
	setwpa)
		set_wpa $2
		;;
	all)
		save_all "$AP_NAME" $AP_PASSWORD
		;;
	*)
		echo "Usage: $0 name|password|all ..."
		exit -1
		;;
esac
	
exit 0


