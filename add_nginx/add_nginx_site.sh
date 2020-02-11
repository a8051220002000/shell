#!/bin/bash

RED_C='\E[1;31m'  
YELOW_C='\E[1;33m' 
BLUE_C='\E[1;34m'  
RESET='\E[0m'
dir="/var/www/html/add_nginx_conf/pre_conf/$(date +%Y%m%d)"

read -p "請輸入新增的域名，新增多個請用空格分開，主域名請放在前面:" domain_name
if [ -z "${domain_name}"  ];then
echo '沒輸入'
exit 88
else
echo "你剛剛輸入${domain_name}"
#  read -p "請輸入原機IP:" source_ip
#  if [ -z ${source_ip}  ];then
#  echo '沒輸入'
#  exit 88
#  else
#  echo "你剛剛輸入${source_ip}"
read -p "輸入SSL CRT:" CRT
read -p "輸入SSL KEY:" KEY

  mkdir ${dir} 2>/dev/null

  new_domain=$(echo ${domain_name}|awk '{print $1}')
  cp sample_conf/sample.conf ${new_domain}.conf
  sed -i "s/old_domain_name/${domain_name}/" ${new_domain}.conf  #改domain
  sed -i "s/CRT/${CRT}/" ${new_domain}.conf  #改KEY CRT
  sed -i "s/KEY/${KEY}/" ${new_domain}.conf  #改KEY CRT
  mv ${new_domain}.conf ${dir}/
  fi

echo -e "${RED_C}新增檔案名稱:${new_domain}.conf ${RESET}"
echo '憑證與key檔案請丟到 /usr/local/nginx/conf.d/ 底下'
echo "皆確認無誤後，請將配置檔放置至正確位置，配置檔統一放置於/var/www/html/add_nginx_conf/pre_conf/$(date +%Y%m%d)"

echo -e "${RED_C}CRT跟key檔案名稱未修改，請記得修改${new_domain}.conf ${RESET}"



