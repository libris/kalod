#!/usr/bin/env python
# -*- coding: utf-8 -*-

# I am parsing XML with regexp. http://bit.ly/cu5Prt

import urllib2
import re
import sys

p = re.compile('<resumptionToken>([^<]*)</resumptionToken>')
base = sys.argv[1]
setName = sys.argv[3]
fileBase = sys.argv[4]
url = base + '?verb=ListRecords&set=' + setName + '&metadataPrefix=' + sys.argv[2]
n = 1

while True:
	print url
	data = urllib2.urlopen(url).read()
	open(fileBase + '-' + str(n) + '.xml', 'w').write(data)
	m = p.search(data)

	if m:
		url = base + '?verb=ListRecords&resumptionToken=' + urllib2.quote(m.group(1))
		n = n + 1
	else:
		break

