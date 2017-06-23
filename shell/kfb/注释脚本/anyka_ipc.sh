#! /bin/sh
### BEGIN INIT INFO
# File:				camera.sh	
# Provides:         camera service 
# Required-Start:   $
# Required-Stop:
# Default-Start:     
# Default-Stop:
# Short-Description:web service
# Author:			gao_wangsheng
# Email: 			gao_wangsheng@anyka.oa
# Date:				2012-8-8
### END INIT INFO

#将脚本执行时的第一个参数 赋给变量MODE
MODE=$1

#添加环境变量路径（其中包含shell脚本的解释器的路径）
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin

#将hostapd赋给变量mode
mode=hostapd
network=

#用法说明：该函数调用时会打印 Usage: -sh start|stop;就是该脚本的执行方式：脚本 start 或 stop
usage()
{
	echo "Usage: $0 start|stop)"
	exit 3
}

#stop函数 向内核发送信号 杀死anyka_ipc进程，并打印相关信息
stop()
{
	killall -15 anyka_ipc
#	pid=`pgrep anyka_ipc`
#	while [ "$pid" != "" ]
#	do         
#	    sleep 0.5        
#		pid=`pgrep anyka_ipc`
#   done
	echo "we don't stop ipc service......"
}

#start函数 
start ()
{
#打印信息
	echo "start ipc service......"

#将/etc/jffs2/anyka_cfg.ini作为变量 赋值给inifile
	inifile="/etc/jffs2/anyka_cfg.ini"
	
#取出/etc/jffs2/anyka_cfg.ini文件中cloud段下的onvif的值 
	onvif=`awk 'BEGIN {FS="="}/\[cloud\]/{a=1} a==1&&$1~/onvif/{gsub(/\"/,"",$2);gsub(/\;.*/, "", $2);gsub(/^[[:blank:]]*/,"",$2);print $2}' $inifile`
	
#判断onvif的值 如果onvif 的值为 1
	if [ "$onvif" = "1" ]
	then
		echo "start onvif service ......"
		
		#执行命令pgrep cmd的结果赋给变量pid
		pid=`pgrep cmd`
		
		#如果等于空 就执行命令 cmd &（&符号的意思是后台执行）
		if [ "$pid" = "" ]
		then
			cmd &    ##for onvif
		fi
		
		#执行命令discovery的结果赋给变量pid
		pid=`pgrep discovery`
		
		#如果等于空 就执行命令 discovery & 
		if [ "$pid" = "" ]
		then
			discovery & ##for onvif
		fi
	fi

#如果onvif 的值不为1  #执行命令anyka_ipc的结果赋给变量pid
	pid=`pgrep anyka_ipc`
	
	#如果等于空 就执行命令 anyka_ipc & 
    if [ "$pid" = "" ]
    then
	    anyka_ipc &
	fi
	
	
}
#重启函数
restart ()
{
	echo "restart ipc service......"
	stop
	start
}

#
# main:
#
#主函数
case "$MODE" in
	start)
		start
		;;
	stop)
		stop
		;;
	restart)
		restart
		;;
	*)
		usage
		;;
esac
exit 0

