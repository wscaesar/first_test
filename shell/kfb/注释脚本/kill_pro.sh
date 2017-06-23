#!/bin/sh
#用来查询某个参数的脚本
while true
do
	killall -15 $1
#命令解析：grep -v 反向搜索，
	obj=`ps | grep $1 | grep -v grep |grep -v $0 | awk '{print $1}'`
	

	if [ "$obj" != "" ]
	then
		sleep 1
	else
		echo "the pro has been killed"
		exit 0
	fi
done
