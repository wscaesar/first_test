#!/bin/sh

filename="README.txt"
datefile=`date +%Y-%m-%d-%H-%M-%S`

if [ -s $filename ];then
	test=1
else
	test=0
fi

empty()
{	
	touch $filename
	echo "这个文件的内容为空，请输入文件说明:"
	read word 
	echo "[$datefile]$word" >> $filename
	cat $filename
}

append()
{
	echo "您选择的是”追加“，请输入文件说明："
	read word 
	echo "[$datefile]$word" >> $filename
	echo "************************"
	echo "       文件内容："
	echo "************************"
	cat $filename
	echo "************************"
	echo "************************"
}


cover()
{
	echo "您选择的是”覆盖“，请输入文件说明："
	read word 
	echo "[$datefile]$word" > $filename
	echo "************************"
	echo "       文件内容："
	echo "************************"
	cat $filename
	echo "************************"
	echo "************************"
}

nonempty()
{
	echo "以下是文件的内容："
	cat $filename
	echo "************************"
	echo "追加：0 | 覆盖：1"
	echo "请选择:"
	echo "************************"
	read selected
	case "$selected" in
		0)
		append
		;;
		1)
		cover
		;;
	esac
}



case "$test" in
	0)
	empty
	;;
	1)
	nonempty
	;;
esac
	
	









