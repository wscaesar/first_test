#!/bin/sh
# File:				update.sh	
# Provides:         
# Description:      update zImage&rootfs under dir1/dir2/...
# Author:			xc

#升级四个固件的脚本

VAR1="zImage"
VAR2="root.sqsh4"
VAR3="usr.sqsh4"
VAR4="usr.jffs2"

ZMD5="zImage.md5"
SMD5="usr.sqsh4.md5"
JMD5="usr.jffs2.md5"
RMD5="root.sqsh4.md5"

DIR1="/tmp"
DIR2="/mnt"
UPDATE_DIR_TMP=0

update_voice_tip(){
	echo "play update voice tips"
	echo "/usr/share/anyka_update_device.mp3" > /tmp/alarm_audio_list
	killall -12 anyka_ipc
	sleep 3
}

update_ispconfig()
{
	rm -rf /etc/jffs2/isp*.conf
}

update_kernel()
{
	echo "check ${VAR1}............................."

	if [ -e ${DIR1}/${VAR1} ] 
	then
		if [ -e ${DIR1}/${ZMD5} ];then
#命令解析：md5sum命令用于生成和校验文件的md5值，-c 根据已生成的md5值，对现存文件进行校验
			result=`md5sum -c ${DIR1}/${ZMD5} | grep OK`
			if [ -z "$result" ];then
				echo "MD5 check zImage failed, can't updata"
				return
			else
				echo "MD5 check zImage success"
			fi
		fi

		echo "update ${VAR1} under ${DIR1}...."
		#在/tmp目录下更新zimage文件
		updater local K=${DIR1}/${VAR1}
	fi	
}

update_squash()
{		
	echo "check ${VAR3}.........................."

	if [ -e ${DIR1}/${VAR3} ]
	then
		if [ -e ${DIR1}/${SMD5} ];then

			result=`md5sum -c ${DIR1}/${SMD5} | grep OK`
			if [ -z "$result" ];then
				echo "MD5 check usr.sqsh4 failed, can't updata"
				return
			else
				echo "MD5 check usr.sqsh4 success"
			fi
		fi

		echo "update ${VAR3} under ${DIR1}...."
		updater local MTD2=${DIR1}/${VAR3}
	fi	
}

update_jffs2()
{
	echo "check ${VAR4}........................"

	if [ -e ${DIR1}/${VAR4} ]
	then
		if [ -e ${DIR1}/${JMD5} ];then

			result=`md5sum -c ${DIR1}/${JMD5} | grep OK`
			if [ -z "$result" ];then
				echo "MD5 check usr.jffs2 failed, can't updata"
				return
			else
				echo "MD5 check usr.jffs2 success"
			fi
		fi

		echo "update ${VAR4} under ${DIR1}...."
		updater local MTD3=${DIR1}/${VAR4}
	fi	
}

update_rootfs_squash()
{		
	echo "check ${VAR2}.........................."

	if [ -e ${DIR1}/${VAR2} ]
	then
		if [ -e ${DIR1}/${RMD5} ];then

			result=`md5sum -c ${DIR1}/${RMD5} | grep OK`
			if [ -z "$result" ];then
				echo "MD5 check root.sqsh4 failed, can't updata"
				return
			else
				echo "MD5 check root.sqsh4 success"
			fi
		fi

		echo "update ${VAR2} under ${DIR1}...."
		updater local MTD1=${DIR1}/${VAR2}
	fi	
}

update_check_image()
{
	echo "check update image .........................."
#循环检测四个固件是否在tmp 目录下
	for target in ${VAR1} ${VAR2} ${VAR3} ${VAR4}
	do
		if [ -e ${DIR1}/${target} ]; then
			echo "find a target ${target}, update in /tmp"
			UPDATE_DIR_TMP=1
			break
		fi	
	done
}

#
# main:
#
echo "stop system service before update....."
killall -15 syslogd
killall -15 klogd
killall -15 tcpsvd

# play update vioce tip播放提示音
update_voice_tip

# send signal to stop watchdog
killall -12 daemon 
sleep 5
# kill apps, MUST use force kill
killall -9 daemon
killall -9 anyka_ipc
killall -9 net_manage.sh
/usr/sbin/wifi_manage.sh stop
killall -9 smartlink

# sleep to wait the program exit
i=5
#循环获取anyka_ipc的进程号
while [ $i -gt 0 ]
do
	sleep 1
	pid=`pgrep anyka_ipc`
	if [ -z "$pid" ];then
		echo "The main app anyka_ipc has exited !!!"
		break
	fi

	i=`expr $i - 1`
done

if [ $i -eq 0 ];then
	echo "The main app anyka_ipc is still run, we don't do update, reboot now !!!"
	reboot
fi

echo "############ please wait a moment. And don't remove TFcard or power-off #############"

#led blink开启指示灯
/usr/sbin/led.sh blink 50 50

# cp busybox to tmp, avoid the command become no use
#将busybox拷贝至/tmp/目录下，避免命令不能使用
cp /bin/busybox /tmp/

#检查固件文件是否在指定的目录下
update_check_image

#如果/tmp目录下没有指定的固件，就将/mnt目录下的文件拷贝至/tmp目录下
if [ $UPDATE_DIR_TMP -ne 1 ];then
	## copy the image file to /tmp to avoid update fail on TF-card
	for dir in ${VAR1} ${VAR2} ${VAR3} ${VAR4}
	do
		cp ${DIR2}/${dir} /tmp/ 2>/dev/null
		cp ${DIR2}/${dir}.md5 /tmp/ 2>/dev/null
	done
	umount /mnt/ -l
	echo "update use image from /mnt"
else
	echo "update use image from /tmp"
fi
cd ${DIR1}

#删除所有的isp*.conf文件
update_ispconfig
#升级四个固件
update_kernel
update_jffs2
update_squash
update_rootfs_squash

/tmp/busybox echo "############ update finished, reboot now #############"

/tmp/busybox sleep 3
/tmp/busybox reboot -f

