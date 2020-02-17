#!/bin/bash

#npm build 之前先刪除檔案


if [ -f package-lock.json ] || [ -d 'node_modules' ];then

	/usr/bin/rm -rf package-lock.json
	/usr/bin/rm -rf node_modules
	#清理
fi

#即便上述if沒檔案也要跑，所以沒有設置在if內






