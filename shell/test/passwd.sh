#! /bin/bash
test1()
{
echo $0
echo $1
echo $2
echo $3
}

key()
{
KEY=123567878549846466531654#  #
keylen=${KEY#*'"'}
keylen1=${keylen%'"'*}
echo "$keylen1"
}

nz()
{
knul=
knull=1
if [ -n $knull ]
	then
	echo "2"
fi
}
