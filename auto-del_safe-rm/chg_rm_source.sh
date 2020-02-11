#!/bin/bash

nday=$(date +%Y%m%d%H%M)
cp /etc/profile /etc/profile_${nday}

grep JAVA /etc/profile 
if [[ $? -eq 0 ]];then #有取到值
PATH_ADD=$(grep -n 'PATH=$JAVA' /etc/profile|grep -v CLASS|cut -d':' -f1) #定位PATH的位置
EXPORT_ADD=$(grep -n 'export' /etc/profile|grep CLASSPATH|cut -d':' -f1) #定位export的位置
else
echo '環境變數沒有取到JAVA值，請確認原機的環境變數位置'
exit 1
fi

wget http://34.92.211.206:19890/safe-rm/safe-rm-0.12.tar.gz
wget http://34.92.211.206:19890/safe-rm/auto-del.sh   #不是每台都有上先不抓
wget http://34.92.211.206:19890/safe-rm/safe-rm.conf

mkdir -p /usr/local/auto-del/logs
rsync -ah auto-del.sh /usr/local/auto-del/
chmod 755 /usr/local/auto-del/auto-del.sh


tar zxf safe-rm-0.12.tar.gz
chmod 755 safe-rm-0.12/safe-rm
chown root.root safe-rm-0.12/safe-rm
mv safe-rm-0.12/safe-rm /usr/local/sbin/safe-rm
ln -s /usr/local/sbin/safe-rm /usr/local/bin/rm #讓safe-rm串軟連結rm


org=$(sed -n ''"${EXPORT_ADD}"'p' /etc/profile)  #儲存export那行的內容
change=$(echo $org PATHRM)  #echo出export那行內容再加上PATHRM，利用下面那行替換
sed -i "${EXPORT_ADD}s|.*|${change}|" /etc/profile #指定行(export) 替換

sed ''"${PATH_ADD}"' i 'PATHRM=/usr/local/bin:/bin:/usr/bin'' -i /etc/profile #讓/usr/local/sbin/safe-rm優先讀取大於一般rm

mv safe-rm.conf /etc/
chmod 755 auto-del.sh
rsync -ah auto-del.sh /root/auto-del.sh
echo 'safe-rm conf 位於/etc/底下'

echo '檢查export後，請下  source /etc/profile  生效'

