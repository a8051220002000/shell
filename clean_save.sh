#!/bin/bash

#每天整點移除當天傳過來的jenkins備份


cd /opt/backup/save

find /opt/backup/save  -maxdepth 1 -type f  -mtime +1 -name "*.tar.gz"|xargs rm -rf > /dev/null 2>&1

#刪除超過1天檔案
