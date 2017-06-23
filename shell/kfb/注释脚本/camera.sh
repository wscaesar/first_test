#! /bin/sh
### BEGIN INIT INFO
# File:				camera.sh	
# Provides:         
# Required-Start:   $
# Required-Stop:
# Default-Start:     
# Default-Stop:
# Short-Description: install or remove camera drivers
# Author:			
# Email: 			
# Date:				2015-9-28
### END INIT INFO
#本文件是关于摄像头的加载和卸载的脚本

#$1 传入的第一个参数
MODE=$1 

#用法说明函数
usage()
{
	echo "Usage: $0 setup | remove"
}

#摄像头移除
camera_remove()
{
#卸载akcamera.ko模块
	rmmod /usr/modules/akcamera.ko
	
#命令解析：find /usr/modules -maxdepth 1 在路径/usr/modules下  -maxdepth 1 是指查找的最大目录深度是1，-type f 文件类型是文件 
# -name "sensor_*.ko" 名字为sensor_*.ko 的文件，-exec 后面是命令，这里是rmmod命令，{} 里面是find命令查找的结果，
#\; 命令结束符有关反斜杠转义
	find /usr/modules -maxdepth 1 -type f -name "sensor_*.ko" -exec rmmod {} \;
	find /etc/jffs2 -maxdepth 1 -type f -name "sensor_*.ko" -exec rmmod {} \;
#以上的命令是查找到指定的模块并卸载
}

camera_setup()
{
	find /etc/jffs2 -maxdepth 1 -type f -name "sensor_*.ko" -exec insmod {} \;
	find /usr/modules -maxdepth 1 -type f -name "sensor_*.ko" -exec insmod {} \;
	insmod /usr/modules/akcamera.ko
#以上的命令是查找到指定的模块并加载
}

#根据传入的参数，进行选择相应的函数
case "$MODE" in
	setup)
		camera_setup
		;;
	remove)
		camera_remove
		;;
	*)
		usage
		;;
esac
exit 0

