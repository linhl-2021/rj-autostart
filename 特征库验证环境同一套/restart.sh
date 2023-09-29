#!/bin/bash
echo -e "killing main.sh\n"
ps -ef|grep main.sh|grep -v grep|awk -F " " '{print $2}'|xargs kill -9
path=`pwd`

echo -e "removing log in /home/release/log/ ...\n"
rm -rf $path/../log/*


config_path=$path/config
keyword="switch=on"
# 遍历目录中的文件
for config in "$config_path"/*; do
    if  [[ ! "$config" =~ "ini" ]]; then
        echo "文件名不包含 'config.*ini'，删除文件 $config"
        rm "$config"
    fi
    if [[ -f "$config" ]]; then
		if grep -q "switch=on" "$config"; then
			echo "在文件 $config 中找到关键字 '$keyword'，开启防火墙"
			config_name=$(echo "$config" | awk -F / '{print $(NF)}' | cut -d. -f1)
			nohup ./main.sh $config >$path/../log/main-$config_name.log 2>&1 >/dev/null &

        else
            echo "在文件 $config 中未找到关键字 '$keyword'，不开启防火墙"
            # 在这里执行命令 B
        fi
    fi
done
echo -e "starting main.sh ...\n"
# nohup ./main.sh >$path/../log/main.log 2>&1 >/dev/null &



pid=`ps -ef|grep main.sh|grep -v grep|awk -F " " '{print $2}'`


if [ "$pid" != "" ];then
	echo -e "start main.sh success, pid is $pid,enjoy your time!!!\n"
else
	echo -e "start main.sh failed,please check it!!!\n"
fi
