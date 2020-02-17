#!/bin/bash

#備份/usr/local/底下幾個tomcat


cd /usr/local/

find ./ -maxdepth 1 -type d -name 'tomcat*' -exec tar --exclude='logs' -zcf {}-$(date +"%Y%m%d").tar.gz {} \;

#找檔案&&備份
find /opt/backup/  -maxdepth 1 -type f  -mtime +10 -name "*.tar.gz"|xargs rm -rf > /dev/null 2>&1

#刪除單層超過10天備份
