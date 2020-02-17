#!/usr/bin/python
#-*- coding: utf-8 -*-

import xml.etree.ElementTree as ET
import sys

fname = sys.argv[1]

#doc = ET.parse('pom.xml')
doc = ET.parse(fname)


for item in doc.iterfind('{http://maven.apache.org/POM/4.0.0}dependencies/{http://maven.apache.org/POM/4.0.0}dependency'):
    id = item.findtext('{http://maven.apache.org/POM/4.0.0}artifactId')
    print(id)
