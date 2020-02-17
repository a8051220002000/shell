#!/bin/bash
#先備份原始檔案
#把檔案移動或覆蓋到正確位置


WORK_NAME=`pwd|cut -d / -f 6`
#得到該工作目錄名稱以及對應的檔案名稱


#找到文件名

if [ $(ssh -p 30022 root@192.168.3.26 "ls -t /root/tomcat/*_${WORK_NAME}.tar.gz" 2>/dev/null |wc -l) == 1 ];then

	if $(ssh -p 30022 root@192.168.3.26 "find  -type d -name "app"|cut -d / -f2|uniq" 2>dev/null|wc -l) 
#backup

#rm




#後續打算改成hostname 






