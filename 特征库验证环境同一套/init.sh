#!/bin/bash
#变量
config_path=$1
config_name=$(echo "$config_path" | awk -F / '{print $(NF)}' | cut -d. -f1)

type=$2
user=$3
firewall_ip=`cat $config_path |grep firewall_ip |awk -F '=' '{print $2}'`
firewall_shell_passwd=`cat $config_path |grep firewall_shell_passwd |awk -F '=' '{print $2}'`
firewall_hostname=`cat $config_path |grep firewall_hostname |awk -F '=' '{print $2}'`
pc_ip=`cat $config_path |grep pc_ip |awk -F '=' '{print $2}'`
pc_passwd=`cat $config_path |grep pc_passwd |awk -F '=' '{print $2}'`
path="`pwd`"
cd ..
pc_path="`pwd`/update/$type/$config_name"
cd $path

echo "" >/root/.ssh/known_hosts

/usr/bin/expect <<-EOF
		set timeout 5
		spawn ssh $user@$firewall_ip
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

if [ "$type" == "appid" ];then

	if [ "$user" == "root" ];then

		/usr/bin/expect <<-EOF
				set timeout 5
				spawn ssh $user@$firewall_ip
				expect "assword"
				send "$firewall_shell_passwd\n"
				expect "$firewall_hostname"
				send "sudo fpcmd fp app-id cfg enable cache false\n"
				expect "$firewall_hostname"
				send "sudo fpcmd fp app-id cfg enable expect false\n"
				expect "$firewall_hostname"
				send "sudo fpcmd fp app-id show application > /mnt/flash/appid-rules.txt\n"
				expect "$firewall_hostname"
				send "sudo scp -r /mnt/flash/appid-rules.txt root@$pc_ip:$pc_path/\n"
				expect "assword"
				send "$pc_passwd\n"
				expect "$firewall_hostname"
				send "sudo fp-npfctl flows-flush\n"
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
				send "cmd appid run \'app-id cache-enable false\'\n"
				expect "$firewall_hostname"
				send "cmd appid run \'app-id expect-enable false\'\n"
				expect "$firewall_hostname"
				send "flush nfp flows\n"
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
				send "sudo fpcmd fp app-id cfg enable cache false\n"
				expect "$firewall_hostname"
				send "sudo fpcmd fp app-id expect-enable false\n"
				expect "$firewall_hostname"
				send "sudo fp-npfctl flows-flush\n"
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
				send "sudo fpcmd fp app-id cfg enable cache false\n"
				expect "$firewall_hostname"
				send "sudo fpcmd fp app-id expect-enable false\n"
				expect "$firewall_hostname"
				send "sudo sqlite3 /tmp/ips/ips_sig.db .dump > /mnt/flash/ips-rules.txt\n"
				expect "$firewall_hostname"
				send "sudo scp -r /mnt/flash/ips-rules.txt root@$pc_ip:$pc_path/\n"
				expect "assword"
				send "$pc_passwd\n"
				expect "$firewall_hostname"
				send "sudo fpcmd fp ips debug pkt-debug off\n"
				expect "$firewall_hostname"
				send "sudo fpcmd fp ips debug post-match off\n"
				expect "$firewall_hostname"
				send "sudo fpcmd fp ips debug log on\n"
				expect "$firewall_hostname"
				send "sudo fpcmd log-level-set 7\n"
				expect "$firewall_hostname"
				send "sudo fpcmd log-type-set all off\n"
				expect "$firewall_hostname"
				send "sudo fpcmd log-type-set APP_PARSER on\n"
				expect "$firewall_hostname"
				send "sudo fpcmd log-type-set IPS on\n"
				expect "$firewall_hostname"
                send "sudo fpcmd log-type-set PATTERN_MATCH on\n"
                expect "$firewall_hostname"
                send "sudo fpcmd fp pattern-match debug log on\n"
                expect "$firewall_hostname"
                send "sudo fpcmd fp pattern-match debug pkt-debug off\n"
                expect "$firewall_hostname"
                send "sudo fpcmd fp pattern-match debug post-match off\n"
                expect "$firewall_hostname"
				send "sudo fp-npfctl flows-flush\n"
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
				send "cmd appid run \'app-id cache-enable false\'\n"
				expect "$firewall_hostname"
				send "cmd appid run \'app-id expect-enable false\'\n"
				expect "$firewall_hostname"
				send "cmd ips run \"debug pkt-debug off\"\n"
				expect "$firewall_hostname"
				send "cmd ips run \"debug post-match off\"\n"
				expect "$firewall_hostname"
				send "cmd ips run \"debug log on\"\n"
				expect "$firewall_hostname"
				send "cmd debug-support fp exec \"log-level-set 7\"\n"
				expect "$firewall_hostname"
				send "cmd debug-support fp exec \"log-type-set all off\"\n"
				expect "$firewall_hostname"
				send "cmd debug-support fp exec \"log-type-set APP_PARSER on\"\n"
				expect "$firewall_hostname"
				send "cmd debug-support fp exec \"log-type-set IPS on\"\n"
				expect "$firewall_hostname"
                                send "cmd debug-support fp exec \"log-type-set PATTERN_MATCH on\"\n"
                                expect "$firewall_hostname"
                                send "cmd debug-support fp exec \"fp pattern-match debug log on\"\n"
                                expect "$firewall_hostname"
                                send "cmd debug-support fp exec \"fp pattern-match debug pkt-debug off\"\n"
                                expect "$firewall_hostname"
                                send "cmd debug-support fp exec \"fp pattern-match debug post-match off\"\n"
                                expect "$firewall_hostname"
				send "flush nfp flows\n"
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
				send "sudo fpcmd fp app-id cfg enable cache false\n"
				expect "$firewall_hostname"
				send "sudo fpcmd fp app-id expect-enable false\n"
				expect "$firewall_hostname"
				send "sudo fpcmd fp ips debug pkt-debug off\n"
				expect "$firewall_hostname"
				send "sudo fpcmd fp ips debug post-match off\n"
				expect "$firewall_hostname"
				send "sudo fpcmd fp ips debug log on\n"
				expect "$firewall_hostname"
				send "sudo fpcmd log-level-set 7\n"
				expect "$firewall_hostname"
				send "sudo fpcmd log-type-set all off\n"
				expect "$firewall_hostname"
				send "sudo fpcmd log-type-set APP_PARSER on\n"
				expect "$firewall_hostname"
				send "sudo fpcmd log-type-set IPS on\n"
				expect "$firewall_hostname"
                                send "sudo fpcmd log-type-set PATTERN_MATCH on\n"
                                expect "$firewall_hostname"
                                send "sudo fpcmd fp pattern-match debug log on\n"
                                expect "$firewall_hostname"
                                send "sudo fpcmd fp pattern-match debug pkt-debug off\n"
                                expect "$firewall_hostname"
                                send "sudo pcmd fp pattern-match debug post-match off\n"
                                expect "$firewall_hostname"
				send "sudo fp-npfctl flows-flush\n"
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
