#/!bin/bash
#用途:提前安裝相依性套件
#V2.0 利用帶變數數去取值

echo "$1"
/usr/bin/python /var/lib/jenkins/shell/parse.py ./$1/pom.xml>/tmp/mvn_install.txt

#這個$WORK_SPACE的命名，「jenkins專案名稱」 要與正確git repo 名稱相同才能撈到值，儲存到/tmp/mvn_install.txt

filename=/tmp/mvn_install.txt

cat /tmp/mvn_install.txt|while read line

do
	if [ -f "./${line}/pom.xml"  ];then
	/usr/share/maven/bin/mvn install -f ./${line}/pom.xml -Dmaven.test.skip=true
fi

done


