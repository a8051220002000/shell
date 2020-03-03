#!/bin/bash

#env
python=`which python3`
ansible=`which ansible`
one="${1}" #此變數是為了將shell層$1儲存起來,否則進入sw case $1就失效了
#file
day=$(date +"%Y%m%d")
day_d=$(date -d '1 day ago' +"%Y%m%d")
tempFile="/tmp/${day}_hostname_temp"
returnFile="/opt/zabbix_api/${one}_list.txt"

function update_list(){ #更新ansible主機名稱清單
sudo ${ansible}   all -m script -a  /opt/zabbix_api/cache_zabbix_hostname.sh > ${tempFile}
}

function chose(){
	case "$1" in
	  unreachable)
	  set_var;
	  unreachable_check;	  	
	  ;;
	  *) 
	  echo "input error"
	esac
}

function send_TG(){
list=$(echo -e "\n" && cat ${returnFile})
#公司TG
  curl -X POST "https://api.telegram.org/bot802001485:AAEoiOpr4QHLkZQxg2hXAvkxRenHQyu8_WY/sendMessage" -d "chat_id=-398859134&text=主機:${triggerNameToAnsibleName}_${one}  ${list}"

#我的TG
  #curl -X POST "https://api.telegram.org/bot1052983262:AAFKP89Plnv7WWDjUObuH3Qb2OwTG_bCvbM/sendMessage" -d "chat_id=-309196620&text=主機:${triggerNameToAnsibleName}_${one}  ${list}"
}



function set_var(){ 
#利用輸入的$1是zabbix需要撈取的狀態，去換取ansible正確主機名稱，進一步利用ansible去下指令
  orgTriggerName=$(${python} test_get_trigger.py|grep ${one}|awk '{print $1}'|head -1) #利用關鍵字找到trigger的hostname,最後會需要加上head，是因為zabbix是用時間排序，印上第一排等同於印出最新的
  if [[ -n ${orgTriggerName}  ]];then
  triggerNameToAnsibleName=$(grep -B10 ${orgTriggerName} ${tempFile}|grep CHANGED|awk '{print $1}')
  else
	echo '無法取值到此次告警的參數!! (請檢查是不是${1}的告警沒有出現在zabbix web介面告警上)'
	echo "測試指令 python /opt/zabbix_api/test_get_trigger.py|grep ${one}|awk '{print $1}'"
	exit 1
  fi
}

function unreachable_check(){
#發生問題時對應的動作的function
  if [[ -n ${triggerNameToAnsibleName}  ]];then
	#echo ${orgTriggerName}
  	#echo ${triggerNameToAnsibleName}
	ansible ${triggerNameToAnsibleName} -m ping  > ${returnFile}
	send_TG
  else #會進入這邊代表/etc/ansible/hosts內無法撈出主機名，所以重跑一次
	update_list;
	unset orgTriggerName triggerNameToAnsibleName
	set_var;
	unreachable_check;
	if [[ -z ${triggerNameToAnsibleName}  ]];then
	 echo "AnsibleName無法正確取值,請確認/etc/ansible/hosts內有對應${orgTriggerName}相關名稱，及檢查zabbix web監控面板"
	 exit 2
	fi
  fi
}

  if [[ ! -s ${tempFile}  ]];then #如果zabbix主機名清單不在，靠以下function更新
        update_list;
  fi
  chose $1
