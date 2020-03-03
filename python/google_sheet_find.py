#!/usr/bin/python3
# coding=UTF-8
import gspread
import re
import os
import dns.resolver
from oauth2client.service_account import ServiceAccountCredentials
#auth_json_path = 'python-sheet-268807-4bc4d3502516.json'
auth_json_path =  'python-sheet-268807-0e93bbc8cce7.json'
gss_scopes = ['https://spreadsheets.google.com/feeds']
#連線
credentials = ServiceAccountCredentials.from_json_keyfile_name(auth_json_path,gss_scopes)
gss_client = gspread.authorize(credentials)
#開啟 Google Sheet 資料表
#spreadsheet_key = '4bc4d35025167c54f2a6a1b93f0286101323d217' 
spreadsheet_key = '14ARvWPOGzNqaoTK7u-yU4Kw3AomXX9WlomQq7d868Ds' 
#建立工作表1
sheet = gss_client.open_by_key(spreadsheet_key).sheet1
#自定義工作表名稱
#sheet = gss_client.open_by_key(spreadsheet_key).worksheet('測試1')

#Google Sheet 資料表操作(20191224新版)
#sheet.update_acell('D2', 'ABC')  #D2加入ABC
#sheet.update_cell(12, 4, 'ABC')   #D2加入ABC(第2列第4行即D2)
#寫入一整列(list型態的資料)
#values = ['A','B','C','D']
#sheet.insert_row(values, 1) #插入values到第1列
#讀取儲存格
#sheet.acell('B1').value
#sheet.cell(1, 2).value
#讀取整欄或整列
#sheet.row_values(1) #讀取第1列的一整列
#sheet.col_values(1) #讀取第1欄的一整欄
#讀取整個表
#sheet.get_all_values()
#print(sheet.row_values)
#印出一整列(左>右 )
#print(sheet.row_values('1'))
#印出一整欄(上>下)
#print(sheet.col_values('1'))
#印出整張表
#print(sheet.get_all_values())


hostNameOrg = input('請輸入英文主機名: ')
hostName = hostNameOrg.upper()
a=0
#將每列的第一行拿來搜尋(用戶名)
for i in sheet.row_values('1'):
 match = re.findall(hostName, i)
 a+=1
 #print('第%d次' %a)
 #當用戶名被搜尋命中，進判斷式
 if match != []:
    #將搜尋到的該列一行一行域名跑迴圈
    for o in sheet.col_values(a):
      #文本處理去除域名後標註的字 例如 (廢棄) (APP)這種字
      cstr_org = o.split('(')
      try:
       #去除多餘網址後的空白
       cstr = str.rstrip(cstr_org[0])
       #print('此次檢測為',cstr)
       #A紀錄檢查
       result = dns.resolver.query(cstr, 'A')
       for ipval in result:
        print(o,'=',ipval)
      except Exception as e:
       print(o,'=','查詢無結果,請手動確認')
    break  
