#bin/bash

datelist=`date +[%Y-%m-%d]%H:%M:%S`
filename="README.txt"

VAR1="zImage"
VAR2="root.sqsh4"
VAR3="usr.sqsh4"
VAR4="usr.jffs2"

DIR1="./build/arch/arm/boot/"
DIR2="./platform/rootfs/"
DIR3="./firmware/$datelist"

CheckDir()
{
	if [ ! -d "firmware" ]
	then 
	mkdir firmware
	fi
}

BuildNewDirAndFile()
{
	mkdir ${DIR3}
	touch ${DIR3}/${filename}
}


ShowFileListAndCopyFile()
{
	ls -la ${DIR1} | grep ${VAR1} | head -1
	ls -la ${DIR2} | grep -E "${VAR2}|${VAR3}|${VAR4}"

	cp ${DIR1}${VAR1} ${DIR3}
	for firmware in ${VAR2} ${VAR3} ${VAR4}
		do
			cp ${DIR2}${firmware} ${DIR3}
		done
}

InputFileDescription()
{
	echo "请输入文件说明:"
	read word 
	echo "$datelist >> $word" >> ${DIR3}/${filename}
	cat ${DIR3}/${filename}
}

CheckDir
BuildNewDirAndFile
ShowFileListAndCopyFile
InputFileDescription


