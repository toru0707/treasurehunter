# encoding: utf-8
'''
Created on 2010/01/30

'''
import sys
import os
import urllib
import codecs
from xml.etree.ElementTree import *

def main():
    target = sys.argv[1]
    if os.path.isdir(target):
        for root, dirs, files in os.walk(sys.argv[1]):
            for f in files:
                file = open(target, 'r')
    else:           
        file = codecs.open(target, 'r', 'utf-8')
    
    for line in file:
        str = ""
        for word in webma(line):
            str += word.text.encode('utf-8') + ","
        print str[:len(str)-1]
    
def webma(line):
    url = 'http://jlp.yahooapis.jp/MAService/V1/parse'
    appid = 'PPoeEQ.xg67eTkRPQR58Du4Jhb1Ku9krKEv.GzpzreDh90wnR1hJpfQD50vqN3I-'
    params = urllib.urlencode({'appid':appid, 'results':'uniq', 'uniq_filter':'9', 'sentence':line})#'?appid=' + appid + '&result=uniq&uniq_filter=9&sentence=' + line
    req = urllib.urlopen(url, params)
    doc = req.read()
    elem = fromstring(doc)
    return elem.findall('.//{urn:yahoo:jp:jlp}surface')
    
if __name__ == '__main__':main()