#!/bin/bash
#变量
config_path=$1
config_name=$(echo "$config_path" | awk -F / '{print $(NF)}' | cut -d. -f1)

type=$2
user=$3
firewallmodel=`cat $config_path |grep firewallmodel |awk -F '=' '{print $2}'`
firewall_ip=`cat $config_path |grep firewall_ip |awk -F '=' '{print $2}'`
firewall_hostname=`cat $config_path |grep firewall_hostname |awk -F '=' '{print $2}'`
firewall_shell_passwd=`cat $config_path |grep firewall_shell_passwd |awk -F '=' '{print $2}'`
pc_ip=`cat $config_path |grep pc_ip |awk -F '=' '{print $2}'`
pc_passwd=`cat $config_path |grep pc_passwd |awk -F '=' '{print $2}'`

path=`pwd`
cd ..
pc_path="`pwd`/report/"$firewallmodel"_$2"/$config_name
cd $path

if [ "$type" == "appid" ];then

	if [ "$user" == "root" ];then
		/usr/bin/expect <<-EOF
				set timeout 5
				spawn ssh $user@$firewall_ip
				expect "assword"
				send "$firewall_shell_passwd\n"
				expect "$firewall_hostname"
				send "sudo fp-npfctl cookie 3 > $type.txt\n"
				expect "$firewall_hostname"
				send "sudo fp-npfctl cookie 3 >> $type.txt\n"
				expect "$firewall_hostname"
				send "sudo fp-npfctl cookie 3 >> $type.txt\n"
				expect "$firewall_hostname"
				send "sudo scp -r $type.txt $user@$pc_ip:$pc_path/\n"
				expect "assword"
				send "$pc_passwd\n"
				expect "$firewall_hostname"
				send "sudo rm -rf $type.txt\n"
				#expect "$firewall_hostname"
				#send "sudo fp-npfctl flows-flush\n"
				expect "$firewall_hostname"
				send "exit\n"
				send "exit\n"
				interact
				expect eof
				EOF
	elif [ "$user" == "admin" ];then
		/usr/bin/expect <<-EOF
				set timeout 5
				spawn ssh $user@$firewall_ip
				expect "assword"
				send "$firewall_shell_passwd\n"
				expect "$firewall_hostname"
				send "show nfp cookie pid 3\n"
				expect "$firewall_hostname"
				sleep 1
				send " \n"
				#expect "$firewall_hostname"
				#send "flush nfp flows\n"
				expect "$firewall_hostname"
				send "exit\n"
				send "exit\n"
				interact
				expect eof
				EOF
	else
		/usr/bin/expect <<-EOF
				set timeout 5
				spawn ssh $user@$firewall_ip
				expect "assword"
				send "$firewall_shell_passwd\n"
				expect "$firewall_hostname"
				send "sudo ls\n"
				expect "assword"
				send "$firewall_shell_passwd\n"
				expect "$firewall_hostname"
				send "sudo fp-npfctl cookie 3 > $type.txt\n"
				expect "$firewall_hostname"
				send "sudo fp-npfctl cookie 3 >> $type.txt\n"
				expect "$firewall_hostname"
				send "sudo fp-npfctl cookie 3 >> $type.txt\n"
				expect "$firewall_hostname"
				send "sudo scp -r $type.txt $user@$pc_ip:$pc_path/\n"
				expect "assword"
				send "$pc_passwd\n"
				expect "$firewall_hostname"
				send "sudo rm -rf $type.txt\n"
				#expect "$firewall_hostname"
				#send "sudo fp-npfctl flows-flush\n"
				expect "$firewall_hostname"
				send "exit\n"
				send "exit\n"
				interact
				expect eof
				EOF
	fi

elif [ "$type" == "ips" ];then
	if [ "$user" == "root" ];then

		/usr/bin/expect <<-EOF
				set timeout 5
				spawn ssh $user@$firewall_ip
				expect "assword"
				send "$firewall_shell_passwd\n"
				expect "$firewall_hostname"
				send "echo `date` > time_check\n"
				expect "$firewall_hostname"
				#send "sudo journalctl |grep IPS|tail -n 300 > $type.txt\n"
				#expect "$firewall_hostname"
				send "tail -n 10000 /var/log/ntos/fastpath.log|grep IPS > $type.txt\n"
				expect "$firewall_hostname"
                send "tail -n 10000 /var/log/ntos/fastpath.log|grep PM >> $type.txt\n"
                expect "$firewall_hostname"
				send "echo `date` >> time_check\n"
				expect "$firewall_hostname"
				send "sudo scp -r $type.txt $user@$pc_ip:$pc_path/\n"
				expect "assword"
				send "$pc_passwd\n"
				expect "$firewall_hostname"
				send "sudo fpcmd log-level-set 7\n"
				expect "$firewall_hostname"
				send "sudo rm -rf $type.txt\n"
				#expect "$firewall_hostname"
				#send "sudo fp-npfctl flows-flush\n"
				expect "$firewall_hostname"
				send "echo `date` > time_check\n"
				expect "$firewall_hostname"
				send "exit\n"
				send "exit\n"
				interact
				expect eof
				EOF

	elif [ "$user" == "admin" ];then

		/usr/bin/expect <<-EOF
				set timeout 5
				spawn ssh $user@$firewall_ip
				expect "assword"
				send "$firewall_shell_passwd\n"
				expect "$firewall_hostname"
				send "cmd debug-support fp exec \"log-level-set 7\"\n"
				expect "$firewall_hostname"
				send "show log max-lines 100 | match sid\n"
				expect "$firewall_hostname"
				sleep 1
				send " \n"
				sleep 1
				send " \n"
				sleep 1
				send " \n"
				sleep 1
				send " \n"
				sleep 1
				send " \n"
				sleep 1
				send " \n"
				sleep 1
				send " \n"
				sleep 1
				send " \n"
				sleep 1
				send " \n"
				sleep 1
				send " \n"
				sleep 1
				send " \n"
				sleep 1
				send " \n"
				sleep 1
				send " \n"
				sleep 1
				send " \n"
				sleep 1
				send " \n"
				expect "$firewall_hostname"
				send "exit\n"
				send "exit\n"
				interact
				expect eof
				EOF
	else

		/usr/bin/expect <<-EOF
				set timeout 5
				spawn ssh $user@$firewall_ip
				expect "assword"
				send "$firewall_shell_passwd\n"
				expect "$firewall_hostname"
				send "sudo ls\n"
				expect "assword"
				send "$firewall_shell_passwd\n"
				expect "$firewall_hostname"
				#send "sudo journalctl -n 100 > $type.txt\n"
				send "tail -n 500 /var/log/ntos/fastpath.log|grep IPS > $type.txt\n"
				expect "$firewall_hostname"
                send "tail -n 500 /var/log/ntos/fastpath.log|grep PM >> $type.txt\n"
                expect "$firewall_hostname"
				send "sudo scp -r $type.txt $user@$pc_ip:$pc_path/\n"
				expect "assword"
				send "$pc_passwd\n"
				expect "$firewall_hostname"
				send "sudo fpcmd log-level-set 7\n"
				expect "$firewall_hostname"
				send "sudo rm -rf $type.txt\n"
				#expect "$firewall_hostname"
				#send "sudo fp-npfctl flows-flush\n"
				expect "$firewall_hostname"
				send "exit\n"
				send "exit\n"
				interact
				expect eof
				EOF
fi
else

	break
fi
