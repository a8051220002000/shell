#!/usr/bin/python3
'''
只印出/etc/passwd每個user以及其家目錄
'''

import os 

fp = open("/etc/passwd", "r")
list = fp.readlines()
print((list))
print(type(list))


for word in list:
  list_2 = word.split(":")
  print(list_2[0], list_2[-1], end="")

