#!/bin/bash

#透過檢查8068端口不通的域名一併檢查其 NS 及 A record ，若為CNAME就顯示CNAME
#執行方式 sh curl_check_8068.sh filename


check() {


exec < ${filename}

while read line

do
http_code=$(curl -o /dev/null -m 3 -s -w %{http_code} "${line}:8068")
domain_cname="no"
	if [ ${http_code} == "000" ];then
    		
		record=$(dig +short cname ${line})
		if [[ -n "${record}" ]] ;then
			domain_cname="yes"
		else
			record=$(dig +short ${line})
		fi

		if [[ -z "${record}" ]] ;then
	            record="Null"
         	fi
		
		if [ ${domain_cname} == "yes" ];then
			ns="cname"

		else
			count=$(echo ${line} |grep -o '\.'|wc -l)
			if [[ $count -eq 2 ]];then
				domain=$(echo ${line}|cut -d'.' -f2,3)
				ns=$(dig +short NS ${domain} |tail -n1)
			fi
		fi

		echo "${line} , ${record} , ${ns} , timeout"
	fi
done
}


case "$1" in
	-f)
	  filename="list/$2"
	  check
	  exit $?
	  ;;
	*)
	  echo "使用方式 sh curl_check_8068.sh -f filename"
	  exit $?
	  ;;
esac
