#!/bin/bash

  function pre_install(){
  /opt/gitlab/bin/gitlab-ctl stop
  rpm -Uvh $1
  /opt/gitlab/bin/gitlab-ctl start
  gitlab-ctl reconfigure
  }
  function post_install(){
  echo ====確認版本===
  head -1 /opt/gitlab/version-manifest.txt
  echo ====確認服務===
  /opt/gitlab/bin/gitlab-ctl status
  echo ==== 結束 ====
  }
  #安裝git10版後必須套件
  if [[ $(rpm -qa |grep policycoreutils-python|wc -l) -ne 1 ]];then
	yum install policycoreutils-python -y
  fi

  if [[ -z $1 ]];then
	echo "變數1需輸入數值,不可為空"
	exit 1
  else
	echo "$1 不為空,開始執行升級"
	if [[ $(echo $1 |cut -d'-' -f3|cut -d'.' -f1) -lt 12 ]];then
		#小於12版本
		/opt/gitlab/bin/gitlab-rake gitlab:backup:create
		touch /etc/gitlab/skip-auto-migrations #告訴git升級檔，不用備份git的資料庫
		pre_install;
		rm /etc/gitlab/skip-auto-migrations -rf
		post_install;
	elif [[ $(echo $1 |cut -d'-' -f3|cut -d'.' -f1) -eq 12 ]];then
		#等於12版本
		/opt/gitlab/bin/gitlab-rake gitlab:backup:create
		touch /etc/gitlab/skip-auto-reconfigure  #告訴git升級檔，不用備份git的資料庫
		pre_install;
		rm /etc/gitlab/skip-auto-reconfigure -rf 
		post_install;
	fi
  fi


