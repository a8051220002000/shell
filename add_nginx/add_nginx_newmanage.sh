#!/bin/bash

read -p "此為新增 新管理後台域名。EX manage.91cs.com  :" add_domain
read -p "輸入SSL CRT:" CRT
read -p "輸入SSL KEY:" KEY

dir="/var/www/html/add_nginx_conf/pre_conf/$(date +%Y%m%d)"


echo "您輸入的為 ${add_domain}"

change_1()
{
cp sample_conf/new_sample.conf ${add_domain}.conf
sed -e  "s/example.com/${add_domain}/g" -i ${add_domain}.conf
sed -i "s/CRT/${CRT}/" ${add_domain}.conf  #改KEY CRT
sed -i "s/KEY/${KEY}/" ${add_domain}.conf  #改KEY CRT
}


mkdir ${dir} 2>/dev/null
change_1;
mv ${add_domain}.conf ${dir}/

echo "你剛剛新增的是 ${add_domain}.conf 請注意檔名無誤"
echo '已改動完成，記得檢查配置檔內 key以及CRT檔名與配置檔是匹配的'
echo "皆確認無誤後，請將配置檔放置至正確位置，配置檔統一放置於/var/www/html/add_nginx_conf/pre_conf/$(date +%Y%m%d)"

echo '配置檔放置位置 　/usr/local/nginx/conf.d/'
echo 'CRT KEY放置位置　/usr/local/nginx/'
