#!/bin/bash
#用途:分析/usr/local/nginx/conf 以及con.d底下的crt檔案，監控憑證剩餘幾天過期
#====con===
day_controll="30"  #CRT監控剩餘日期小於幾天告警
#==========
#2.0相較第1版，區域變數$crt_org 及 檔案ssl_storage 做出sort 以及uniq的排序，避免一個CRT驗證多次。
#2.0相較前版本，要做出一支CRT給多個域名的監控
RED_C='\E[1;31m'
RESET='\E[0m'
rm -rf /tmp/ssl_list #其他檔案位於/tmp/SSL/ 
rm -rf /tmp/SSL/
mkdir /tmp/SSL/

function find_ssl_info(){  #此function功能:比對現在時間與/usr/local/nginx/conf conf.d 兩個資料夾底下crt到期日 的差
  find /usr/local/nginx/ -name '*.conf' -exec grep 'ssl_certificate' {} \; > /tmp/SSL/ssl_org
  cat /tmp/SSL/ssl_org|grep -v '#'|grep -v '_key'|awk '{print $2}'|cut -d';' -f1|sort|uniq >>/tmp/SSL/ssl_storage
  crt_org=$(cat /tmp/SSL/ssl_org|grep -v '#'|grep -v '_key'|awk '{print $2}'|cut -d';' -f1|sort |uniq) 
    for line in ${crt_org}
    do
      cd /usr/local/nginx/conf
      end_date=$(openssl x509 -in ${line} -enddate </dev/null 2>/dev/null |           sed -n '/BEGIN CERTIFICATE/,/END CERT/p' |       openssl x509 -text 2>/dev/null |       sed -n 's/ *Not After : *//p')
      end_date_seconds=$(date '+%s' --date "$end_date")
      now_seconds=`date '+%s'`
    #echo "($end_date_seconds-$now_seconds)/24/3600" | bc
      see="$((($end_date_seconds-$now_seconds)/24/3600))"  #沒bc算法
      echo $see >> /tmp/SSL/ssl_expire
    done
}

function alarm(){ #利用/tmp/SSL/ssl_storage 行數以及比對 /tmp/SSL/ssl_expiret 產生一個檔案
  sum_line=$(cat /tmp/SSL/ssl_storage|wc -l)
    for (( i=1; i<=${sum_line}; i=i+1 ))
    do
      deadline=$(head -n ${i} /tmp/SSL/ssl_expire|tail -n 1) #比對日期 當下迴圈某一行
      info=$(head -n ${i} /tmp/SSL/ssl_storage|tail -n 1)  #比對CRT名稱 當下迴圈某一行
      all_domain=$(openssl x509 -in ${info} -noout -text|grep -oP '(?<=DNS:|IP Address:)[^,]+'|sort -uV)
    if [[ ${deadline} -le ${day_controll} ]] ;then #日期小於多少的判斷
      echo -e "${info} = 剩餘${deadline}日 ${RED_C} 影響域名  $(echo -e ${all_domain}|sed "s/\n//g") ${RESET}">>/tmp/ssl_list
    fi
done
}

find_ssl_info;
cat > /tmp/ssl_list <<EOF
此list是為了確認/usr/local/nginx/conf與conf.d 底下CRT檔案是否過期
會帶上檔名及剩下日期，告警觸發時請檢查nginx.conf server_name 對應之CRT都要過期了
EOF
alarm;

cat /tmp/ssl_list

