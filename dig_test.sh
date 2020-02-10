#!/bin/bash

#後續可以加上檢測子域名筆數 (迴圈要改如果是子域名，就不跑www)  檔案行數也變智能

printf '一個域名一行，此腳本是在跑dig您檔案給的A紀錄\n'

read -p "請輸入你要測試的檔名 :" filename
read -p "請輸入你要測試的NS server :" dnsstore

rm -rf /tmp/dig_temp
rm -rf /tmp/dig_save

exec < ${filename}

while read line

do
echo "==${line}==="
domain_main=$(dig @${dnsstore} ${line}  +short  A|sort -n)
echo ${line}=$(echo ${domain_main}|sed "s/\n//g")  #sed "s/\n//g" 去除換行符號
  if [[ -z "${domain_main}" ]];then
    echo "${line} 空值" >> /tmp/dig_temp
  fi 
done

echo "您原測試檔案共$(cat ${filename}|wc -l)行"

if [[ -f /tmp/dig_temp  ]];then
echo '以下域名此次dig無紀錄，無紀錄檔案位於/tmp/dig_temp 全部A紀錄儲存於/tmp/dig_save'
cat /tmp/dig_temp
else
echo '此次域名dig檢測皆有A紀錄'
fi
