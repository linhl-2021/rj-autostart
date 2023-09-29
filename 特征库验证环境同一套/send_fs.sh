#!/bin/bash
fs_api_key="$4"
#变量
config_path=$1
config_name=$(echo "$config_path" | awk -F / '{print $(NF)}' | cut -d. -f1)
echo $config_path
if [ "$fs_api_key" == ""  ];then
        fs_api_key=`cat $config_path |grep fs_api_key |awk -F '=' '{print $2}'`
		echo 1111:$fs_api_key
fi
send_url="https://open.feishu.cn/open-apis/bot/v2/hook/$fs_api_key"
echo $fs_api_key


#发送消息
function send_message(){
curl -X POST "$send_url" -H 'Content-Type: application/json' -d "
   {
        \"msg_type\":\"text\",
        \"content\":{\"text\":\"$1\"}
   }"
}

#发送消息
function send_file(){
curl -X POST "$send_url" -H 'Content-Type: application/json' -d "
   {
	\"msg_type\": \"post\",
	\"content\": {
		\"post\": {
			\"zh_cn\": {
				\"content\": [
					[
						{
							\"tag\": \"a\",
							\"text\": \"请查看测试报告\",
							\"href\": \"$1\"
						},
						{
							\"tag\": \"at\",
							\"user_id\": \"all\"
						}
					]
				]
			}
		}
	}
   }"
}
#发送单包消息
function send_simple_pcap(){
curl -X POST "$send_url" -H 'Content-Type: application/json' -d "
   {
	\"msg_type\": \"post\",
	\"content\": {
		\"post\": {
			\"zh_cn\": {
				\"content\": [
					[
						{
							\"tag\": \"a\",
							\"text\": \"单包\",
							\"href\": \"$1\"
						},
						{
							\"tag\": \"at\",
							\"user_id\": \"all\"
						}
					]
				]
			}
		}
	}
   }"
}


if [ "$2" = "message" ]; then
    send_message "$3"
elif [ "$2" = "simple_zip" ]; then
    send_simple_pcap "$3"
else
    send_file "$3"
fi
