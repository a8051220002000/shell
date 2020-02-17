#!/bin/bash

#last_day變數，當域名到期日，「小於等於」此變數時，會開始送TG
#============
last_day="30"
#============

#域名重新打文檔，for寄TG用
send_file="/tmp/domain_sendTG.txt"
#取得平台名稱
name=$(cat /etc/bashrc |grep '平台'|awk -F '@' '{print $2}'|awk '{print $1}')
rm -rf ${send_file}


function send_TG(){
list=$(echo -e "\n" && cat ${send_file}|while read line; do echo ${line}; done)
sub=$(echo -e "以下域名將在${last_day}天後過期，注意域名過期會很麻煩!!")


#我的TG
curl -X POST "https://api.telegram.org/bot號碼以及token/sendMessage" -d "chat_id=xxxx&text=${name}_${sub} ${list}"

}

#確認domain用的檔案的確存在，並且有內容
if [[ -s /tmp/domain_expired_list ]];then 
#域名日期確認
  cat /tmp/domain_expired_list |tail -n +3|while read line
  do
	if [[ $(echo $line|awk '{print $3}') -le ${last_day}  ]];then
	  echo ${line} >> ${send_file}
	fi
  done
	if [[ -s ${send_file} ]];then
	  echo "有天數小於${last_day}天"
	  send_TG;
	else
	  echo "沒天數小於${last_day}天問題，不觸發TG"
	fi
else
  echo '/tmp/domain_expired_list  檔案不存在 請檢查/etc/zabbix/scripts/check_domain_expire_v2.0.sh 腳本'
  exit 1;
fi
