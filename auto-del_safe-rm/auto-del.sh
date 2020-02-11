#!/bin/bash
#更新日期2020/02/05 判斷式grep改為egrep
#更新日期2020/01/10 新增反項比對，不刪非六個java應用底下的檔案

#自動讀取文本 移除四支tomcat && 兩個應用 底下檔案

RED_C='\E[1;31m'
RESET='\E[0m'
day=$(date +"%Y%m%d-%H:%M:%S")
day_d=$(date +"%Y%m%d%H%M%S")

logs='/usr/local/auto-del/logs'
file_local='/usr/local/auto-del'

function init_check(){
if [[ ! -d $logs   ]];then #沒有logs資料夾就建立
mkdir -p $logs
fi
}
app="/usr/local/tomcat-app-8005-8086-8009"
pc="/usr/local/tomcat-pc-8008-8087-8012"
web="/usr/local/tomcat-web-8006-9080-8010"
webchat="/usr/local/tomcat-webchat-8022-8085-8023"
lotteryserver="/usr/local/lotteryServer"
platform="/usr/local/admin-platform"



init_check;
read -p '輸入刪除清單的名稱，清單位置請放在/usr/local/auto-del/底下:' filename


echo "運行時間:${day}" >> ${logs}/${day_d}_auto-del_err.log
echo "運行時間:${day}" >> ${logs}/${day_d}_auto-del.log
list="${logs}/${day_d}_auto-del.log"
err_list="${logs}/${day_d}_auto-del_err.log"

cat ${file_local}/${filename}|grep -v -E ""${app}"|"${pc}"|"${web}"|"${webchat}"|"${lotteryserver}"|"${platform}""|grep -v '#' >> ${err_list}  #反向選擇，此為不在/usr/local路徑的

cat ${file_local}/${filename}|grep -E ""${app}"|"${pc}"|"${web}"|"${webchat}"|"${lotteryserver}"|"${platform}""|grep -v '#'|while read line

do
  space=$(echo $line|egrep [[:space:]])
  if [[ -n $space  ]];then #有空白
  echo "$line"' 帶空白' >> ${err_list}
  else #有此檔案且沒空白
  /usr/local/sbin/safe-rm -vrf $line 1>>${list} 2>>${err_list}
  fi
done

echo -e "${RED_C}刪除掉的檔案請cat ${list} 確認 ${RESET}"
echo -e "${RED_C}沒有刪除掉的檔案如下(確認有此檔案，或是不在路徑規範內)，為空就是都有殺掉${RESET}"
echo -e "${RED_C}刪除規範是/usr/local底下四個tomcat以及lotteryServer、adminplatform  ${RESET}"
cat ${err_list}

