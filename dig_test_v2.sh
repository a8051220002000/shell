#!/bin/bash

#後續可以加上檢測子域名筆數 (迴圈要改如果是子域名，就不跑www)  檔案行數也變智能

printf '一個域名一行，此腳本是在跑dig您檔案給的A紀錄\n'
printf '如果有子域名直接跑偵測，會造成筆數不同\n'

read -p "請輸入你要測試的檔名 :" filename

rm -rf /tmp/dig_temp

exec < ${filename}

while read line

do
domain_main=$(dig ${line}  +short  A|sort -n)
domain_sub=$(dig www.${line}  +short  A|sort -n)
echo ${line}=$(echo ${domain_main}|sed "s/\n//g") #sed "s/\n//g" 去除換行符號
done
exit

  if [[ -z "${domain_main}" ]];then
    echo "${line} 空值" >> /tmp/dig_temp
  fi 

  if [[ -z ${domain_sub} ]];then
    echo "www.${line} 空值" >> /tmp/dig_temp
  fi
echo '==========='
done

exit
echo "您原測試檔案共$(cat ${filename}|wc -l)行"

if [[ -f /tmp/dig_temp  ]];then
echo "以下域名此次dig無紀錄請確認"
echo '無紀錄檔案位於/tmp/dig_temp'
cat /tmp/dig_temp
else
echo '此次域名dig檢測皆有A紀錄'
fi
