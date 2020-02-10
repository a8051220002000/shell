#!/bin/bash
nowday=$(date +"%Y%m%d_%H%M")
rm -rf /tmp/${nowday}_tcp_time_wait.txt

function daemon_check(){
#if [[ $(rpm -qa |grep postfix|wc -l) -eq 0 ]];then
#wget http://rpmfind.net/linux/centos/7.7.1908/os/x86_64/Packages/postfix-2.10.1-7.el7.x86_64.rpm
#rpm -ivh  postfix-2.10.1-7.el7.x86_64.rpm
#fi
if [[ $(rpm -qa |grep mailx|wc -l) -eq 0 ]];then
wget http://rpmfind.net/linux/centos/7.7.1908/os/x86_64/Packages/mailx-12.5-19.el7.x86_64.rpm
rpm -ivh mailx-12.5-19.el7.x86_64.rpm
fi
}

function collect_time_wait(){
netstat -ntu |grep TIME_WAIT | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -nr >> /tmp/${nowday}_tcp_time_wait.txt
}
function send_mail(){
name=$(cat /etc/bashrc |grep '平台'|awk -F '@' '{print $2}'|awk '{print $1}')
  mail -s "[TCP_TIME_WIAT_IP收集-${name}-${nowday}]" it@mail.office.holdingfull.com  < /tmp/${nowday}_tcp_time_wait.txt
}

daemon_check;
collect_time_wait;

if [[ ! -s /root/.mailrc ]];then
cat  > /root/.mailrc <<EOF
set smtp=smtps://mail.office.holdingfull.com:465
set smtp-auth=login
set smtp-auth-user=teleport
set ssl-verify=ignore
set nss-config-dir=/etc/pki/nssdb
set from=teleport@mail.office.holdingfull.com
EOF
echo 'set smtp-auth-password=4U%y^EXc$z4zeAaV' >> /root/.mailrc  #因為剛好密碼有$導致密碼會錯誤
fi
send_mail;
