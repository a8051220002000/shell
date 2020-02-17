#!/bin/bash

#用途:為了刪除mvn install build完多餘的檔案


NOW_DIR=`pwd`

find ./* -type d -name  'properties' -exec ls -ad {} \; > /tmp/`(date +"%Y-%m-%d")`.txt
#找當下資料夾properties，匯出log至/tmp/日期.txt後移除這個資料夾
grep 'classes/config' /tmp/`(date +"%Y-%m-%d")`.txt |awk '{print $0}'|xargs rm -rf {}





#install完後產生的jdbc.properties 把他殺掉。會這樣殺是判斷後續利用jenkins的，也不需要此檔案，直接殺掉應該沒關係




