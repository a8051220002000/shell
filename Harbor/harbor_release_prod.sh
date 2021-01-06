#!/bin/bash

IP=${1}
PROJECT_NAME=${2}
NUMBER=${3}
NOW_SECONDS=`date '+%s'`
FILE_NAME="/tmp/harbor_delete_${2}.txt"
rm -rf ${FILE_NAME}
  #echo "${1} ${2}"
  if [[ -z ${IP} ]];then
    echo 'error $1 ip empty'
    exit 1
  elif [[ -z ${PROJECT_NAME}  ]];then
    echo 'error $2 PORJECTNAME empty'
    exit 2
  elif [[ ${PROJECT_NAME} == 'dev'  ]];then
    echo 'error $2 PORJECTNAME equal dev. dev name rule is different can not get tag_id. please use harbor_all.sh'
    exit 3
  elif [[ -z ${NUMBER}  ]];then
    echo 'error $3 NUMBER empty'
    exit 4
  else   #while all ture check http or https and project_name_check
    curl -sI ${IP}|grep https 
    if [[ $? == 0 ]];then
      PORT=https  
    else
      PORT=http
    fi  
  fi
REPO_COUNT=$(curl -sX GET "${PORT}://${IP}/api/v2.0/projects?name=${PROJECT_NAME}" -H "accept: application/json" -u "ACCOUNT:PASSWORD"|jq -r '.[] | .repo_count') #get project count
PROJECT_LIST=$(curl -sX GET "${PORT}://${IP}/api/v2.0/projects/${PROJECT_NAME}/repositories?page_size=${REPO_COUNT}" -H "accept: applicaton/json" -u "ACCOUNT:PASSWORD") #list all register name
  echo ${PROJECT_LIST}
  for row0 in $(echo "${PROJECT_LIST}" | jq -r '.[] | @base64');
  do
    _jq() {
      echo ${row0} | base64 --decode | jq -r ${1}
    } 
    ARTIFACT_NAME=$(_jq '.name')
    ARTIFACT_COUNT=$(_jq '.artifact_count')
    #echo test_point2 ${ARTIFACT_NAME} , ${ARTIFACT_COUNT}  
    if [[ ${ARTIFACT_COUNT} -gt ${NUMBER} ]];then # if $ARTIFACT_COUNT > ${NUMBER} then try to delete images
        
      TAG_NAME=$(echo ${ARTIFACT_NAME}|cut -d'/' -f2) #取得名稱去掉release/xxxxx 只拿xxxxx
	  ARTIFACTS_LIST=$(curl -sX GET "${PORT}://${IP}/api/v2.0/projects/${PROJECT_NAME}/repositories/${TAG_NAME}/artifacts?page_size=${ARTIFACT_COUNT}" -H "accept: applicaton/json" -u "ACCOUNT:PASSWORD")
      echo ${ARTIFACT_NAME} than ${NUMBER}...scan rule     
      for row1 in $(echo $ARTIFACTS_LIST | jq -r '.[] | @base64');do
        _jq1() {
	      echo "${row1}" | base64 --decode | jq -r ${1}
        }

        TAG_ID=$(_jq1 '.id') #取得實際需刪除ID
        TAG_DIGEST=$(_jq1 '.digest') #取得UI TAGS欄位
        TAG_PUSH_TIME=$(_jq1 '.push_time') #取得images push上來的時間以此時間來判斷是否大於30天
        TAG_PUSH_TIME_DAY=$((((${NOW_SECONDS} - $(date '+%s' --date ${TAG_PUSH_TIME} ) + 1  )) /24/3600))  
          echo ${TAG_PUSH_TIME_DAY},${TAG_PUSH_TIME},${TAG_ID},${TAG_DIGEST} >> ${FILE_NAME}
      done

      DELETE_NUMBER=$(( ${ARTIFACT_COUNT} - ${NUMBER} ))          
      for  (( i=1;i<=DELETE_NUMBER;i++ ))
        do        
        DELETE_DAY=$(cat ${FILE_NAME}|awk -F ',' '{print $1}'|tail -n ${i}|head -n 1) #caculate nowtime - upload_time and convert to days
        DELETE_PUSH_TIME=$(cat ${FILE_NAME}|awk -F ',' '{print $2}'|tail -n ${i}|head -n 1) #upload time
        DELETE_NAME=$(cat ${FILE_NAME}|awk -F ',' '{print $3}'|tail -n ${i}|head -n 1) #digest
        DELETE_ID=$(cat ${FILE_NAME}|awk -F ',' '{print $4}'|tail -n ${i}|head -n 1) #id        
          #echo ${i}
          if [[ ${DELETE_DAY} -gt 30  ]];then #than one month delete
            echo "DAY=${DELETE_DAY},NAME=${DELETE_NAME},ID=${DELETE_ID} is deleted"
            curl -sX DELETE "${PORT}://${IP}/api/v2.0/projects/${PROJECT_NAME}/repositories/${TAG_NAME}/artifacts/${DELETE_ID}" -H "accept: application/json" -u "ACCOUNT:PASSWORD"
          else 
            echo "DAY=${DELETE_DAY},NAME=${DELETE_NAME},ID=${DELETE_ID} less 30 days"
            break #這邊下break 是因為有排序，只要當下某個name開始小於30 代表接下來同個昌庫的都會小於30，所以可以直接break 屬於效能優化
          fi       
        done

	elif [[ ${ARTIFACT_COUNT} -le ${NUMBER} ]];then
	  echo ${ARTIFACT_NAME} less than ${NUMBER}
	  continue
	fi
  done 	

exit 0
