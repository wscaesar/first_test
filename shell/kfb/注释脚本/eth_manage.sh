#! /bin/sh
### BEGIN INIT INFO
# File:				eth_manage.sh	
# Required-Start:   $
# Required-Stop:
# Default-Start:     
# Default-Stop:
# Description: ethernet manager
# Author:			
# Email: 			
# Date:				2014-8-8
### END INIT INFO
#这个脚本就是用来设置有线网络

MODE=$1

#设置环境变量的路径
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin

#用法函数
usage()
{
	echo "Usage: $0 start|stop|restart)"
	exit 3
}

#关闭udhcpc的服务
stop()
{
	echo "stop ethernet......"
	killall udhcpc
}

#配置静态网络地址
use_static_ip()
{
#指定陆军那个配置文件
	inifile="/etc/jffs2/anyka_cfg.ini"
#取出配置文件中的ipaddr 的值
	ipaddr=`awk 'BEGIN {FS="="}/\[ethernet\]/{a=1} a==1&&$1~/ipaddr/{gsub(/\"/,"",$2);gsub(/\;.*/, "", $2);gsub(/^[[:blank:]]*/,"",$2);print $2}' $inifile`

#取出配置文件中的netmask 的值
	netmask=`awk 'BEGIN {FS="="}/\[ethernet\]/{a=1} a==1&&$1~/netmask/{gsub(/\"/,"",$2);gsub(/\;.*/, "", $2);gsub(/^[[:blank:]]*/,"",$2);print $2}' $inifile`
	
#取出配置文件中的gateway 的值
	gateway=`awk 'BEGIN {FS="="}/\[ethernet\]/{a=1} a==1&&$1~/gateway/{gsub(/\"/,"",$2);gsub(/\;.*/, "", $2);gsub(/^[[:blank:]]*/,"",$2);print $2}' $inifile`

#取出配置文件中的firstdns 的值
	firstdns=`awk 'BEGIN {FS="="}/\[ethernet\]/{a=1} a==1&&$1~/firstdns/{gsub(/\"/,"",$2);gsub(/\;.*/, "", $2);gsub(/^[[:blank:]]*/,"",$2);print $2}' $inifile`

#取出配置文件中的backdns 的值
	backdns=`awk 'BEGIN {FS="="}/\[ethernet\]/{a=1} a==1&&$1~/backdns/{gsub(/\"/,"",$2);gsub(/\;.*/, "", $2);gsub(/^[[:blank:]]*/,"",$2);print $2}' $inifile`

#配置ip地址和子网掩码
	ifconfig eth0 $ipaddr netmask $netmask

#添加路由网关
	route add default gw $gateway
	
#在原文件上修改，nameserver $firstdns 与 nameserver $backdns"进行替换
	sed -i "2,\$c nameserver $firstdns \
		nameserver $backdns" /etc/jffs2/resolv.conf

	sleep 1
}

check_ip_and_start()
{
#获取指定路径的配置文件
	inifile="/etc/jffs2/anyka_cfg.ini"
	i=0

#取出配置文件中dhcp中的值
	dhcp=`awk 'BEGIN {FS="="}/\[ethernet\]/{a=1} a==1&&$1~/dhcp/{gsub(/\"/,"",$2);gsub(/\;.*/, "", $2);gsub(/^[[:blank:]]*/,"",$2);print $2}' $inifile`

#如果dhcp等于0
	if [ $dhcp -eq 0 ]
	then
		echo "using static ip address..."
		
#使用静态ip地址
		use_static_ip
		status=ok
	else
		status=
#如果i小于2，这里满足条件
		while [ $i -lt 2 ]
		do
		
#判断有线网络是否开启（网线插入）
			cable=`ifconfig eth0 | grep RUNNING`
			if [ "$cable" = "" ]
			then
#打印网线被拔出
				echo "Network cable has been unplug!"
#退出
				return
			fi

			echo "Getting ip address..."
#杀死udhcpc进程
			killall udhcpc
			
#指定网络端口
			udhcpc -i eth0 &

#延时5秒是因为，一些路由分配IP地址比较慢
			####  sleep 5 seconds, because some router allocate IP address is too slow
			sleep 5

#获取网路地址
			status=`ifconfig eth0 | grep "inet addr:"`
			if [ -z "$status" ];then
				i=`expr $i + 1`
			else
				break
			fi
			
#这里的判断语句是为了连续2次获取IP地址。		
		done

#如果ip地址为空，而且已经连续2次获取了，就打印无法获取动态地址，并使用静态地址
		status=`ifconfig eth0 | grep "inet addr:"`
		if [ "$status" = "" ] && [ $i -eq 2 ];then
			echo "can't getting ip address by dynamic, using static ip address!"
			killall udhcpc
			use_static_ip
		fi
	fi
	
#关闭指示灯	
	/usr/sbin/led.sh off
}

start ()
{
#先进行判断网络是否连接，然后获取动态IP地址，如果动态IP地址获取失败，就使用静态IP地址。
	echo "start ethernet......"
	check_ip_and_start
}

restart ()
{
	echo "restart ethernet......"
	stop
	start
}

#
# main:
#
#主函数 根据传入的参数来执行函数。
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

