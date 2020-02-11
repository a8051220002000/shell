#!/bin/sh
base_dir="/opt/backup/mysqlbak/"
log_file="/tmp/mysql_backup.log"
chk_log="/tmp/mysql_backup.chk"
nowday=$(date +"%Y%m%d")
nowtime=$(date +"%Y%m%d %H:%M")
yday=$(date -d "-3 day" +%Y%m%d)
user=root
password='!ta3hyk#8yW'


increse_dir=$(grep "Backup created in directory" $log_file | awk -F "'" {'print$2'})

dir_name=$(grep "Backup created in directory" $log_file | awk -F "'" {'print$2'} | awk -F "/" {'print$6'})

increse_dir_path=$(grep "Backup created in directory" $log_file | awk -F "'" {'print$2'} | awk -F '/' '{for(i=1;i<=5;i++)printf $i"/"; printf "\n"}')

fullbackup_exist=$(ls $base_dir | wc -l)


if [ $fullbackup_exist = 0 -a "$1" != "full_backup" ];then
echo "you must make the fullbackup first! please usage: $0 full_backup"
exit 88;
fi


#function
#--slave-info for 在slave 備份時使用,将binlog位置和master的binlog写到xtrabackup_slave_info，作为change master的命令
full_backup() {
        echo $nowday > ${base_dir}/ndir
        innobackupex --user=$user --password=$password $base_dir/$nowday
	cat $log_file >> $base_dir/$nowday/mysql_backup.log
	
	dir_name=$(grep "Backup created in directory" $log_file | awk -F "'" {'print$2'} | awk -F "/" {'print$6'})
	increse_dir_path=$(grep "Backup created in directory" $log_file | awk -F "'" {'print$2'} | awk -F '/' '{for(i=1;i<=5;i++)printf $i"/"; printf "\n"}')
	cd $increse_dir_path
        # tar 上一次備份資料夾,pigz會使用CPU多核線程壓縮加速
        tar -I pigz -cf ${dir_name}.tgz $dir_name
	#異地備份至google bucket
        mkdir -p /opt/cy_bucket/$(hostname)/mysqlbak/$nowday
        rsync -av ${dir_name}.tgz /opt/cy_bucket/$(hostname)/mysqlbak/$nowday
	rm -rf ${dir_name}.tgz
	rsync -ah /opt/backup/mysqlbak/*.sh /opt/cy_bucket/$(hostname)/mysqlbak/ 
}

increase_backup() {
	ndir=$(cat ${base_dir}/ndir)
	innobackupex --user=$user --password=$password --incremental-basedir=$increse_dir --incremental $base_dir/${ndir}
	cat $log_file >> $base_dir/${ndir}/mysql_backup.log


        dir_name=$(grep "Backup created in directory" $log_file | awk -F "'" {'print$2'} | awk -F "/" {'print$6'})
	increse_dir_path=$(grep "Backup created in directory" $log_file | awk -F "'" {'print$2'} | awk -F '/' '{for(i=1;i<=5;i++)printf $i"/"; printf "\n"}')
        cd $increse_dir_path
	# tar 上一次備份資料夾,pigz會使用CPU多核線程壓縮加速
        tar -I pigz -cf ${dir_name}.tgz $dir_name
        #異地備份至google bucket
	mkdir -p /opt/cy_bucket/$(hostname)/mysqlbak/${ndir}
        rsync -avh ${dir_name}.tgz /opt/cy_bucket/$(hostname)/mysqlbak/${ndir}
        #限速2m並有進度條 rsync -ah  --progress --bwlimit=2m 
        rm -rf ${dir_name}.tgz
	rm -rf /opt/backup/mysqlbak/${yday}
}

case "$1" in
	full_backup)
		full_backup > $log_file 2>& 1
	;;
	increase_backup)
		increase_backup > $log_file 2>& 1
	;;
	*)
	echo "usage: $0 {full_backup|increase_backup}"
	;;
esac
