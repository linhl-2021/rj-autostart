#!/bin/bash
#变量
config_path=$1
type="$2"
config_name=$(echo "$config_path" | awk -F / '{print $(NF)}' | cut -d. -f1)
pc_ip=`cat $config_path |grep pc_ip |awk -F '=' '{print $2}'`
pc_user=`cat $config_path |grep pc_user |awk -F '=' '{print $2}'`
pc_passwd=`cat $config_path |grep pc_passwd |awk -F '=' '{print $2}'`
firewall_ip=`cat $config_path |grep firewall_ip |awk -F '=' '{print $2}'`
firewall_shell_user=`cat $config_path |grep firewall_shell_user |awk -F '=' '{print $2}'`
firewall_shell_passwd=`cat $config_path |grep firewall_shell_passwd |awk -F '=' '{print $2}'`
firewall_hostname=`cat $config_path |grep firewall_hostname |awk -F '=' '{print $2}'`
firewall_root_path=`cat $config_path |grep firewall_root_path |awk -F '=' '{print $2}'`

shell_path="`pwd`"
cd ..
if [ -z "$4" ] ;then
	update_path="`pwd`/update/$type/$config_name"
else
	update_path="$4"
fi
cd $shell_path

rm -rf $update_path/*.log

if [ "$type" == "appid" ];then

/usr/bin/expect <<-EOF
        set timeout 60
        spawn ssh $firewall_shell_user@$firewall_ip
        expect "assword"
        send "$firewall_shell_passwd\n"
        expect "$firewall_hostname"
		# send "killall journalctl\n"
		# expect "$firewall_hostname"
        send "cat /var/log/ntos/fastpath.log |grep fp-rte|grep  \"APPID\" |tail -n 100 >> /mnt/flash/app-rules.log &\n"
        expect "$firewall_hostname"
		sleep 5
        send "sudo fpcmd fp app-id show sig-errlog |grep -v \"not exist\" >> /mnt/flash/app-rules.log\n"
		expect "$firewall_hostname"
		send "sudo free >> /mnt/flash/app-rules.log\n"
		expect "$firewall_hostname"
        send "sudo fpcmd fp app-id show version >> /mnt/flash/app-rules.log\n"
		expect "$firewall_hostname"
		#send "sudo echo >> /mnt/flash/app-rules.log\n"
		#expect "$firewall_hostname"
		send "sudo scp -r /mnt/flash/app-rules.log $pc_user@$pc_ip:$update_path/\n"
        expect "assword"
        send "$pc_passwd\n"
        expect "$firewall_hostname"
        send "sudo rm -rf $firewall_root_path/app*.zip\n"
        send "exit\n"
        send "exit\n"
        interact
		expect eof
		EOF

elif [ "$type" == "ips" ];then

/usr/bin/expect <<-EOF
        set timeout 60
        spawn ssh $firewall_shell_user@$firewall_ip
        expect "assword"
        send "$firewall_shell_passwd\n"
        expect "$firewall_hostname"
		send "sudo cat /mnt/flash/ips/log/ips-rules.log >>/mnt/flash/ips-rules.log\n"
        expect "$firewall_hostname"
		send "sudo free >> /mnt/flash/ips-rules.log\n"
		expect "$firewall_hostname"
		send "sudo fpcmd fp ips show sig-info|grep \"sig version\" >> /mnt/flash/ips-rules.log\n"
		expect "$firewall_hostname"
        send "sudo scp -r /mnt/flash/ips-rules.log $pc_user@$pc_ip:$update_path/\n"
        expect "assword"
        send "$pc_passwd\n"
        expect "$firewall_hostname"
        send "sudo rm -rf $firewall_root_path/ips*.zip\n"
        send "exit\n"
        send "exit\n"
        interact
		expect eof
		EOF

else

break

fi


