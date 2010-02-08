# encoding: utf-8
'''
Created on 2010/01/30

'''
import sys
import os
import re

def main():
	target = sys.argv[1]
	if os.path.isdir(target):
		for root, dirs, files in os.walk(sys.argv[1]):
			for f in files:
				file = open(target, 'r')
	else:		   
		file = open(target, 'r')
		
	print "<?xml version=\"1.0\"?>"
	print "<graph title=\"Simple Graph Demo\" bgcolor=\"ffffff\" linecolor=\"cccccc\" viewmode=\"display\" width=\"725\" height=\"400\">"
	
	id = 0
	idMap = {}
	p1 = re.compile('^([^\t]+)\t([^\t]+)$')
	p2 = re.compile('^([^\t]+)\t([^\t]+)\t([^\t]+)$')
	
	for line in file:
		line = line.strip()
		
		m1 = p1.search(line)
		if m1 != None:
			#ノード要素が見つかった
			print "<node id=\"%s\" text=\"%s\" scale=\"%s\" color=\"cccccc\" textcolor=\"000000\"/>" % (id,m1.group(1), m1.group(2))
			idMap[m1.group(1)] = id
		
		else:
			m2 = p2.search(line)
			if m2 != None:
				#共起頻度要素が見つかった
				print "<edge sourceNode=\"%s\" targetNode=\"%s\" label=\"\" textcolor=\"555555\"/>" % (idMap[m2.group(1)], idMap[m2.group(2)])
		
		id += 1

if __name__ == '__main__':main()