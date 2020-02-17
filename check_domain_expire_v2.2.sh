#!/bin/bash
#====con===
day_controll="30"  #CRT監控剩餘日期小於幾天告警
#==========
#2.0 相較第一版，新增無法利用whois查詢到的，1.利用curl去查，如果仍為空輸入/tmp/domain_expired_list
#2.1 2020 02/13更新，增加執行 check_domain_sendTG.sh
#2.2 2020/02/17更新，之前版本都是nginx 撈crt，開始改為撈hostname

rm -rf /tmp/domain_expired_list #其他檔案位於/tmp/domain/ 
rm -rf /tmp/domain/
mkdir /tmp/domain/

function find_domain_info(){   #此function收集nginx.conf內全部域名

  find /usr/local/nginx/ -name '*.conf' -exec grep 'server_name' {} \; > /tmp/domain/crt_org
domain_org_list=$(cat /tmp/domain/crt_org|grep -v '_\;'|grep -v fastcgi|grep -v '301'|grep -v '#'|cut -d';' -f1)
  for line in ${domain_org_list}
    do
	if [[ ${line} != 'server_name' ]];then
	echo $line >> /tmp/domain/crt_storage #文本整理，撈出全部域名
	fi 
    done
}

function delete_subdomain(){ #上面文本撈出正確域名，排除掉不要得
  cat /tmp/domain/crt_storage|sort|uniq|sort -n|cut -d',' -f1|grep -v ' ' > /tmp/domain/domain_org #文本處理 去掉重複、空格 逗號
sub_line=$(cat /tmp/domain/domain_org|wc -l) 
  for (( i=1; i<=${sub_line}; i=i+1 )) #如果是sub domain就變成main domain
    do#sub_domain去除成為一級域名並且重新排序
    sub_domain=$(head -n ${i}   /tmp/domain/domain_org|tail -n 1)
    count=$(echo ${sub_domain} |grep -o '\.'|wc -l)  #變成橫向後計算.出現次數
	if [[ $count -eq 2 ]];then #確定是子網域
	main_domain=$(echo ${sub_domain}|cut -d'.' -f2,3) #成為主要網域
	 sed -i ''"${i}"'c '"${main_domain}"''  /tmp/domain/domain_org #取代塞回
	fi
    done

  cat /tmp/domain/domain_org|sort|uniq|sort -n > /tmp/domain/domain_storage #此為去掉全部子網域的一級域名清單
}

function delete_random(){
random_line=$(cat /tmp/domain/domain_storage|wc -l)
  for (( a=${random_line}; a>=1; a=a-1 ))
    do
    random_domain=$(head -n ${a}  /tmp/domain/domain_storage|tail -n 1) 
    random_count=$(echo ${random_domain} |grep -o '\.'|wc -l)  #變成橫向後計算.出現次數
	if [[ ${random_count} -eq 0 ]];then #沒有 . 等於不是網址
	  sed -i ''"${a}d"'' /tmp/domain/domain_storage #遞減移除 避免行數變更
	fi
    done
}

function domain_expire_check(){
  cat /tmp/domain/domain_storage|while read line
    do
    domain_time=$(whois ${line}|grep -i Expiry|awk '{print $4}')
	if [[ -z $domain_time ]];then #這區塊在做whois查不到資料的
	value=$(curl -sL https://domain.cloudmax.com.tw/whois-search.php|grep csrf|head -1|awk -F "value" '{print  $2}'|cut -d '"' -f 2) 
#    domain_time=$(curl -sX POST --data "csrf=7fe68cfafddd87438c99cbf81eb1b62a5afe13e3&domain=${line}&Submit="  https://domain.cloudmax.com.tw/whois-search.php|grep -i Expiry|awk '{print $4}'|cut -d'T' -f1) #利用別人家的網站curl查whois資訊
	domain_time=$(curl -sX POST --data "csrf=${value}&domain=${line}&Submit="  https://domain.cloudmax.com.tw/whois-search.php|grep -i Expiry|awk '{print $4}'|cut -d'T' -f1) #利用別人家的網站curl查whois資訊
	fi
    end_date_seconds=$(date '+%s' --date ${domain_time} )
    now_seconds=`date '+%s'`
    see="$((($end_date_seconds-$now_seconds)/24/3600))"
    echo $see >> /tmp/domain/domain_expire
    done
}


function alarm(){ 
sum_line=$(cat /tmp/domain/domain_storage|wc -l)
  for (( o=1; o<=${sum_line}; o=o+1 ))
    do
    deadline=$(head -n ${o}   /tmp/domain/domain_expire|tail -n 1) #比對剩餘日期
    info=$(head -n ${o} /tmp/domain/domain_storage|tail -n 1)  #比對域名
	if [[ ${deadline} -le ${day_controll} ]] ;then #日期小於等於多少的判斷
	  echo $info = $deadline >> /tmp/domain_expired_list
	fi
    done
}


find_domain_info;
delete_subdomain;
delete_random;
cat > /tmp/domain_expired_list <<EOF
此list是為了確認/usr/local/nginx/conf與conf.d 底下CRT檔案去分析出域名，以及其域名是否過期
會帶上域名及剩下日期，告警觸發時請檢查域名是否過期，或是負值是無法正確whois出域名
EOF
domain_expire_check;
  alarm;
  /usr/bin/sh /etc/zabbix/scripts/check_domain_sendTG.sh
  cat /tmp/domain_expired_list
