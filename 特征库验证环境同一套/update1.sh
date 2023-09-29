#!/bin/bash
#变量
config_path=$1
config_name=$(echo "$config_path" | awk -F / '{print $(NF)}' | cut -d. -f1)
pc_ip=`cat $config_path |grep pc_ip |awk -F '=' '{print $2}'`
pc_user=`cat $config_path |grep pc_user |awk -F '=' '{print $2}'`
pc_passwd=`cat $config_path |grep pc_passwd |awk -F '=' '{print $2}'`
firewall_ip=`cat $config_path |grep firewall_ip |awk -F '=' '{print $2}'`

firewall_shell_user=`cat $config_path |grep firewall_shell_user |awk -F '=' '{print $2}'`
firewall_shell_passwd=`cat $config_path |grep firewall_shell_passwd |awk -F '=' '{print $2}'`
firewall_hostname=`cat $config_path |grep firewall_hostname |awk -F '=' '{print $2}'`
firewall_root_path=`cat $config_path |grep firewall_root_path |awk -F '=' '{print $2}'`

echo "" >/root/.ssh/known_hosts

/usr/bin/expect <<-EOF
		set timeout 5
		spawn ssh $firewall_shell_user@$firewall_ip
		expect "yes"
		send "yes\n"
		expect "assword"
		send "$firewall_shell_passwd\n"
		expect "$firewall_hostname"
		send "exit\n"
		send "exit\n"
		interact
		expect eof
		EOF

path="`pwd`"
cd ..
if [ -z "$4" ] ;then
	pc_path="`pwd`/update"
else
	pc_path="$4"
fi
cd $path

rm -rf $pc_path/$type/$config_name/*.log

type="$2"
if [ "$type" == "appid" ];then

/usr/bin/expect <<-EOF
        set timeout 60
        spawn ssh $firewall_shell_user@$firewall_ip
        expect "assword"
        send "$firewall_shell_passwd\n"
        expect "$firewall_hostname"
        send "sudo rm -rf $firewall_root_path/app*.zip\n"
		expect "$firewall_hostname"
        send "scp -r $pc_user@$pc_ip:$3 ./\n"
        expect "assword"
        send "$pc_passwd\n"
		expect "$firewall_hostname"
        send "sudo cat /etc/os-release|head -n 1 > /mnt/flash/app-rules.log\n"
		expect "$firewall_hostname"
        send "sudo cat /etc/.release >> /mnt/flash/app-rules.log\n"
		expect "$firewall_hostname"
		send "sudo cat /etc/.releaseID >> /mnt/flash/app-rules.log\n"
		expect "$firewall_hostname"
        send "sudo fpcmd fp app-id show version >> /mnt/flash/app-rules.log\n"
		expect "$firewall_hostname"
		#send "sudo echo >> /mnt/flash/app-rules.log\n"
		#expect "$firewall_hostname"
		send "sudo free >> /mnt/flash/app-rules.log\n"
		expect "$firewall_hostname"
        send "sudo fpcmd fp app-id debug file on\n"
		expect "$firewall_hostname"
        send "echo \"\" > /var/log/ntos/fastpath.log\n"
		expect "$firewall_hostname"
		send "sudo md5sum $firewall_root_path/app*.zip >> /mnt/flash/app-rules.log\n"
		expect "$firewall_hostname"
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
        send "sudo rm -rf $firewall_root_path/ips*.zip\n"
		expect "$firewall_hostname"
        send "scp -r $pc_user@$pc_ip:$3 ./\n"
        expect "assword"
        send "$pc_passwd\n"
		expect "$firewall_hostname"
		send "sudo cat /etc/os-release|head -n 1 > /mnt/flash/ips-rules.log\n"
        expect "$firewall_hostname"
        send "sudo cat /etc/.release >> /mnt/flash/ips-rules.log\n"
		expect "$firewall_hostname"
        send "sudo cat /etc/.releaseID >> /mnt/flash/ips-rules.log\n"
        expect "$firewall_hostname"
		send "sudo fpcmd fp ips show sig-info|grep \"sig version\" >> /mnt/flash/ips-rules.log\n"
        expect "$firewall_hostname"
		send "sudo free >> /mnt/flash/ips-rules.log\n"
        expect "$firewall_hostname"
		send "md5sum $firewall_root_path/ips*.zip >> /mnt/flash/ips-rules.log\n"
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


