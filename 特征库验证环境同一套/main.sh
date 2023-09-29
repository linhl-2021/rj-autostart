#!/bin/bash

#函数
is_empty_dir(){
    return `ls -A $1|wc -w`
}

work(){
	cd $shell_path
	rm -rf $pc_path/data/pcap_${type}/$config_name/*
	mkdir -p $pc_path/data/pcap_${type}/$config_name
	bash getfile.sh $config_path pcap_${type}
	sleep 3
	if [ "`ls -A $pc_path/data/pcap_${type}_temp/$config_name`" == "" ];then
		bash getfile.sh $config_path pcap_${type}
		sleep 3
    fi

	if [ "`ls -A $pc_path/data/pcap_${type}_temp/$config_name`" == "" ];then
		cp -r $pc_path/data/pcap_${type}_b/* $pc_path/data/pcap_${type}/$config_name/
		#echo "i am bak"
	else
		cp -r $pc_path/data/pcap_${type}_temp/$config_name/* $pc_path/data/pcap_${type}/$config_name/
		#echo "i am temp"
	fi

	python del_space.py "$pc_path/data/pcap_${type}/$config_name"
	bash $shell_path/check.sh $config_path ${type} ${debug} ${key} ${key_fs} > $pc_path/log/log_"$type"_"$config_name".txt
	cat $pc_path/log/log_"$type"_"$config_name".txt|grep info:|awk -F 'info:' '{print $2}' > $pc_path/report/history/report_temp/$config_name/replay.log
}

report(){
	cd $pc_path/report/history/report_temp
	time="$(date +%Y%m%d%H%M%S)"
	mv $config_name report_${type}_${version}_${time}
	zip -q -r report_${type}_${version}_${time}.zip report_${type}_${version}_${time}
	report="report_${type}_${version}_${time}.zip"
	curl -F "action=upload" -F "filename=@$report" -u $hfs_user:$hfs_passwd $hfs_base_url/report/$type/
	rm -rf $report
	cd $shell_path
	bash send_fs.sh $config_path file "$hfs_base_url/report/$type/report_${type}_${version}_${time}.zip" $key_fs
}

#变量
config_path=$1
config_name=$(echo "$config_path" | awk -F / '{print $(NF)}' | cut -d. -f1)
# echo $current_directory
# script_directory=$(dirname "$current_directory")
#全局变量初始化
hfs_user=`cat $config_path |grep hfs_user |awk -F '=' '{print $2}'`
hfs_passwd=`cat $config_path |grep hfs_passwd |awk -F '=' '{print $2}'`
hfs_base_url=`cat $config_path |grep hfs_base_url |awk -F '=' '{print $2}'`
firewall_ip=`cat $config_path |grep firewall_ip |awk -F '=' '{print $2}'`
firewall_user=`cat $config_path |grep firewall_user |awk -F '=' '{print $2}'`
firewall_passwd=`cat $config_path |grep firewall_passwd |awk -F '=' '{print $2}'`
firewall_langue=`cat $config_path |grep firewall_langue |awk -F '=' '{print $2}'`
debug=""
key=""
key_fs=""
type=""
version=""
shell_path="`pwd`"
cd ..
pc_path="`pwd`"
cd $shell_path
#主函数
#for ((i=0; i<1; i++))
while :
do
	sleep 10
########################################################################################################################################################
	#获取文件
	cd $pc_path
	rm -rf data/file/$config_name/*
	rm -rf data/pcap_appid_temp/$config_name/*
	rm -rf data/pcap_ips_temp/$config_name/*
	mkdir -p  data/file/$config_name/
	mkdir -p  data/pcap_appid_temp/$config_name/
	mkdir -p  data/pcap_ips_temp/$config_name/
	cd $shell_path
	bash getfile.sh $config_path file
	#根据下载的文件需求设置主要参数
	cd $pc_path
	if [ -e data/file/$config_name/test ];then
		appid_key=""
		ips_key=""
		appid_key_fs=""
		ips_key_fs=""
		debug="test"
		# type="`cat data/file/$config_name/test`"
		type="`cat data/file/$config_name/test |head -n 1| tr -d '\r\n'`"
	elif [ -e data/file/$config_name/ok ];then
		appid_key="f7a44f62-d361-4db9-a6ac-556007faf234"
		ips_key="faf4bf93-a33e-455b-9a32-c2736fbdafb0"
		appid_key_fs="08c71cec-15b3-4630-ab30-eafa6e6c2b10"
		ips_key_fs="1dd56c87-e54e-4151-8bc3-159c8477c79e"
		debug="formal"
		type="`cat data/file/$config_name/ok`"
	else
		continue
	fi
	#删除http服务器上的上传文件
	cd $pc_path/data/file/$config_name/
	filename="`ls *.zip`"
	curl -F "action=delete" -F "selection=$filename" -u $hfs_user:$hfs_passwd $hfs_base_url/file/
	sleep 1
	curl -F "action=delete"  -F "selection=ok" -u $hfs_user:$hfs_passwd $hfs_base_url/file/
	sleep 1
	curl -F "action=delete"  -F "selection=test" -u $hfs_user:$hfs_passwd $hfs_base_url/file/

	#特征库下发升级获取升级结果
	mkdir -p $pc_path/update/appid/$config_name
	mkdir -p $pc_path/update/ips/$config_name
	mkdir -p $pc_path/update/appid_back
	mkdir -p $pc_path/update/ips_back
	cd $pc_path/data/file/$config_name/
	if [ -e app*.zip ];then
		key="$appid_key"
		key_fs="$appid_key_fs"
		type="appid"
		cd $shell_path
		#bash update.sh appid $pc_path/data/file/$config_name/app*zip
		bash send_fs.sh $config_path message "$firewall_langue 开始升级应用识别特征库" $key_fs
		bash test.sh $config_path appid $pc_path/data/file/$config_name/app*zip
		error="`cat $pc_path/update/appid/$config_name/app-rules*.log|grep \"update fail\.\" |grep -v file_list`"
		if [ -n "$error" ]; then
			content="$firewall_langue appid signature update fail!!!"
			bash send_fs.sh $config_path message "$content" $key_fs
			mkdir -p $pc_path/report/history/report_temp/$config_name
			scp -r $pc_path/update/appid/$config_name/app-rules*.log $pc_path/report/history/report_temp/$config_name/
			report
			continue
		fi
		line1="`cat $pc_path/update/appid/$config_name/app-rules*.log|head -n 4|tail -n 1`"
		line2="`cat $pc_path/update/appid/$config_name/app-rules*.log|tail -n 1`"
		sleep 30
		if [ "$line1" == "$line2" ];then
			#bash update.sh appid $pc_path/update/appid_back/app*zip
			#bash update.sh appid $pc_path/data/file/$config_name/app*zip
			bash test.sh $config_path appid $pc_path/update/appid_back/app_signature_image_20220807.1404_with_lib_R3.zip
			bash test.sh $config_path appid $pc_path/data/file/$config_name/app*zip
		fi
		line1="`cat $pc_path/update/appid/$config_name/app-rules*.log|head -n 4|tail -n 1`"
		line2="`cat $pc_path/update/appid/$config_name/app-rules*.log|tail -n 1`"
		softwarever="`cat $pc_path/update/appid/$config_name/app-rules*.log|head -n 3|tr '\n' ' '|awk -F '=' '{print $2}'`"
		md5="`cat $pc_path/update/appid/$config_name/app-rules*.log|grep "/root/app"|awk -F ' ' '{print $1}'`"
		version="`echo $line2`"
		free="`cat $pc_path/update/appid/$config_name/app-rules*.log|grep "Mem:"`"
		if [ "$line1" != "$line2" -a "$line2" != "00000000.0000" ];then
			content="$softwarever\nThe name of the library to upgrade is $filename\nmd5 is $md5\n一、$firewall_langue appid signature update success ! \nnow version is $version\n"
			bash send.sh message "$content$free" $key
			bash send_fs.sh $config_path message "$content" $key_fs
			bash send.sh file $pc_path/update/appid/$config_name/app-rules*.log $key
			mkdir -p $pc_path/report/history/report_temp/$config_name
			echo -e $content > $pc_path/report/history/report_temp/$config_name/result.txt
			scp -r $pc_path/update/appid/$config_name/app-rules*.log $pc_path/report/history/report_temp/$config_name/
			content1=$(python -c 'from app_tool import getappdate;getappdate("https://'"$firewall_ip"'","'"$firewall_langue"'","'"$firewall_user"'","'"$firewall_passwd"'","'"$pc_path"'/report/history/report_temp/'"$config_name"'/result.txt")')
			#content1=$(python -c 'from app_tool import getappdate;getappdate("https://10.51.212.211","ch","admin","Ruijie@123","/home/result.txt")')
			if [ "$firewall_langue" = "ch" ]; then
				echo "执行国内"
				update_result1="`cat $pc_path/report/history/report_temp/$config_name/result.txt |grep -A 2 'First level menu' |grep 'application name not change'`"
				update_result2="`cat $pc_path/update/appid/$config_name/app-rules*.log |grep -A 1 'signature files error log:' |grep 'app'`"
				if [ -z "$update_result1" ] || [ -n "$update_result2" ]; then
					echo "update_result is empty"
					content="国内 First level menu is change or APP_RULE load err!!!"
					bash send_fs.sh $config_path message "$content" $key_fs
					mkdir -p $pc_path/report/history/report_temp/$config_name
					scp -r $pc_path/update/appid/$config_name/app-rules*.log $pc_path/report/history/report_temp/$config_name/
					report
				continue
				fi
			elif [ "$firewall_langue" = "small" ]; then
				echo "执行小库"
				update_result1="`cat $pc_path/report/history/report_temp/$config_name/result.txt |grep -A 2 'First level menu' |grep 'application name not change'`"
				update_result2="`cat $pc_path/update/appid/$config_name/app-rules*.log |grep -A 1 'signature files error log:' |grep 'app'`"
				mkdir -p $pc_path/report/history/report_temp/$config_name
				if [ -z "$update_result1" ] || [ -n "$update_result2" ]; then
					content="小库 Fail: First level menu is change or APP_RULE load err!!!"
				else
					content="小库 Normal: First level menu is no change and APP_RULE load no err!!!"
				fi
				scp -r $pc_path/update/appid/$config_name/app-rules*.log $pc_path/report/history/report_temp/$config_name/
				bash send_fs.sh $config_path message "$content" $key_fs
				report
				continue
			else
				echo "执行海外"
				update_result0="`cat $pc_path/report/history/report_temp/$config_name/result.txt |grep 'Exist Chinese'`"
				update_result1="`cat $pc_path/report/history/report_temp/$config_name/result.txt |grep -A 2 'First level menu' |grep 'application name not change'`"
				update_result2="`cat $pc_path/update/appid/$config_name/app-rules*.log |grep -A 1 'signature files error log:' |grep 'app'`"
				if [ -n "$update_result0" ] || [ -z "$update_result1" ]|| [ -n "$update_result2" ]; then
					echo "update_result is empty"
					content="Exist Chinese or First level menu is change or APP_RULE load err!!!"
					bash send_fs.sh $config_path message "$content" $key_fs
					mkdir -p $pc_path/report/history/report_temp/$config_name
					scp -r $pc_path/update/appid/$config_name/app-rules*.log $pc_path/report/history/report_temp/$config_name/
					report
				continue
				fi
			fi
		else
			content="$softwarever\nThe name of the library to upgrade is $filename\nmd5 is $md5\n一、$firewall_langue appid signature update fail ! \nnow version is $version\n"
			bash send.sh message "$content$free" $key
			bash send_fs.sh $config_path message "$content" $key_fs

			bash send.sh file $pc_path/update/appid/$config_name/app-rules*.log $key
			mkdir -p $pc_path/report/history/report_temp/$config_name
			echo -e $content > $pc_path/report/history/report_temp/$config_name/result.txt
			scp -r $pc_path/update/appid/$config_name/app-rules*.log $pc_path/report/history/report_temp/

			echo "This feature library is fail !" >> $pc_path/report/history/report_temp/$config_name/result.txt
			report
			continue
		fi
		work
	elif [ -e ips*.zip ];then
		key="$ips_key"
		key_fs="$ips_key_fs"
		type="ips"
		cd $shell_path
		#bash update.sh ips $pc_path/data/file/$config_name/ips*zip
		bash test.sh $config_path ips $pc_path/data/file/$config_name/ips*zip
		update_same="`cat $pc_path/update/ips/$config_name/ips-rules*.log|grep -i "Same Version"`"
		if [ "$update_same" != "" ];then
			#bash update.sh ips $pc_path/update/ips_back/ips*zip
			#bash update.sh ips $pc_path/data/file/$config_name/ips*zip
			bash test.sh $config_path ips $pc_path/update/ips_back/ips*zip
			bash test.sh $config_path ips $pc_path/data/file/$config_name/ips*zip
		fi
		line1="`cat $pc_path/update/ips/$config_name/ips-rules*.log|head -n 4|tail -n 1`"
		line2="`cat $pc_path/update/ips/$config_name/ips-rules*.log|tail -n 1`"
		softwarever="`cat $pc_path/update/ips/$config_name/ips-rules*.log|head -n 3|tr '\n' ' '|awk -F '=' '{print $2}'`"
		md5="`cat $pc_path/update/ips/$config_name/ips-rules*.log|grep "/root/ips"|awk -F ' ' '{print $1}'`"
		update_err="`cat $pc_path/update/ips/$config_name/ips-rules*.log|grep -i err`"
		update_wrong="`cat $pc_path/update/ips/$config_name/ips-rules*.log|grep -i wrong`"
		free="`cat $pc_path/update/ips/$config_name/ips-rules*.log|grep "Mem:"`"
		if [ "$line1" != "$line2"  -a "$line2" != "sig version: 00000000.0000"  ];then
			if [ "$update_err" == "" -a "$update_wrong" == "" ];then
				exception="no problem"
			else
				exception="there is something wrong"
			fi
			version="`cat $pc_path/update/ips/$config_name/ips-rules*.log|grep "ips signature update success" |awk -F ' ' '{print $8}'`"
			rule="`cat $pc_path/update/ips/$config_name/ips-rules*.log|grep "rules successfully"|awk -F '.' '{print $2}'|awk '$1=$1'`"
			content="$softwarever\nThe name of the library to upgrade is $filename\nmd5 is $md5\n一、ips signature update success ! \nnow version is $version\n$rule\n$exception\n"
			bash send.sh message "$content$free" $key
			bash send_fs.sh $config_path message "$content" $key_fs
			bash send.sh file $pc_path/update/ips/$config_name/ips-rules*.log $key
			mkdir -p $pc_path/report/history/report_temp/$config_name/
			echo -e $content > $pc_path/report/history/report_temp/$config_name/result.txt
			scp -r $pc_path/update/ips/$config_name/ips-rules*.log $pc_path/report/history/report_temp/$config_name/
			bash send.sh message "Now packet playback verification on version $version" $key
			bash send_fs.sh $config_path message "Now packet playback verification on version $version\n" $key_fs
		else
			version="`cat  $pc_path/update/ips/$config_name/ips-rules*.log|head -n 4|tail -n 1|awk -F ' ' '{print $3}'`"

			content="$softwarever\nThe name of the library to upgrade is $filename\nmd5 is $md5\n一、ips signature update fail ! \nnow version is $version\n"
			bash send.sh message "$content" $key
			bash send_fs.sh $config_path message "$content" $key_fs
			bash send.sh file $pc_path/update/ips/$config_name/ips-rules*.log $key
			mkdir -p $pc_path/report/history/report_temp
			echo -e $content > $pc_path/report/history/report_temp/$config_name/result.txt
			scp -r $pc_path/update/ips/$config_name/ips-rules*.log $pc_path/report/history/report_temp/$config_name/

			echo "This feature library is fail !" >> $pc_path/report/history/report_temp/$config_name/result.txt
			report
			continue
		fi
		work
	else
		cd $shell_path
		version="original"
		if [ "$type" == "appid" ] && [ "$firewall_langue" != "small" ];then
			key="$appid_key"
			key_fs="$appid_key_fs"
			version="`cat $pc_path/update/appid/$config_name/app-rules.log |tail -n 1| tr -d '\r\n'`"
			content="一、Use the appid $version feature library  !"
		elif [ "$type" == "ips" ] && [ "$firewall_langue" != "small" ];then
			key="$ips_key"
			key_fs="$ips_key_fs"
			content="一、Use the ips original feature library  !"
		else
			continue
		fi
		bash send.sh message "$content" $key
		bash send_fs.sh $config_path message "$content" $key_fs
		mkdir -p $pc_path/report/history/report_temp/$config_name
		echo "$content" > $pc_path/report/history/report_temp/$config_name/result.txt
		# echo `date` >> $pc_path/log/zhuzhijie.log
		work
		# echo `date` >> $pc_path/log/zhuzhijie.log
	fi
	report
########################################################################################################################################################
done

