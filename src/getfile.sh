#!/bin/bash
#变量
config_path=$1
config_name=$(echo "$config_path" | awk -F / '{print $(NF)}' | cut -d. -f1)

#初始化
file_url=`cat $config_path |grep file_url |awk -F '=' '{print $2}'`
pcap_appid_url=`cat $config_path |grep pcap_appid_url |awk -F '=' '{print $2}'`
pcap_ips_url=`cat $config_path |grep pcap_ips_url |awk -F '=' '{print $2}'`

path="`pwd`"
cd ..
file_path="`pwd`/data/file/$config_name"
pcap_appid_path="`pwd`/data/pcap_appid_temp/$config_name"
pcap_ips_path="`pwd`/data/pcap_ips_temp/$config_name"
cd $path

mkdir -p $file_path
mkdir -p $pcap_appid_path
mkdir -p $pcap_ips_path

hfs_user=`cat $config_path |grep hfs_user |awk -F '=' '{print $2}'`
hfs_passwd=`cat $config_path |grep hfs_passwd |awk -F '=' '{print $2}'`
format="$2"

#获取文件
for ((j=0; j<1; j++))
do
	#curl -O -u huanglong:isFd00Wo http://10.51.213.30/ips/file/pcap_v6.zip --progress
	if [ "$format" == "file" ];then
		wget -c -r -np -nd -nH -R html,tmp --no-http-keep-alive --http-user=$hfs_user --http-password=$hfs_passwd $file_url -P $file_path
	elif [ "$format" == "pcap_appid" ];then
		wget -c -r -np -nd -nH -R index.html -R index.html.tmp --no-http-keep-alive --http-user=$hfs_user --http-password=$hfs_passwd $pcap_appid_url -P $pcap_appid_path
	elif [ "$format" == "pcap_ips" ];then
		wget -c -r -np -nd -nH -R index.html -R index.html.tmp --no-http-keep-alive --http-user=$hfs_user --http-password=$hfs_passwd $pcap_ips_url -P $pcap_ips_path
	else
		break
	fi
done

