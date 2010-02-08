# encoding: utf-8
'''
Created on 2010/01/30

'''
import sys
import os
import re
import codecs

def main():
    target = sys.argv[1]
    if os.path.isdir(target):
        for root, dirs, files in os.walk(sys.argv[1]):
            for file in files:
                file = open(file, 'r')
    else:           
        file = codecs.open(target, 'r', 'utf-8')
    
    freqwords = {}
    freqpair = {}
    #単語出現回数と、共起単語出現回数をカウント
    for line in file:
        line = line.strip()
        if re.search("\S*$", line) == None:
            continue
        words = line.split(',')
        words.sort()
        for i in range(len(words)):
            if words[i] in freqwords:
                freqwords[words[i]] += 1
            else:
                freqwords[words[i]] = 1
            for j in range(i + 1, len(words)):
                if words[i] + "\t" + words[j] in freqpair:
                    freqpair[words[i] + "\t" + words[j]] += 1
                else:
                    freqpair[words[i] + "\t" + words[j]] = 1
        
               
    simp = {}    
    #単語出現回数、共起単語出現回数からシンプソン係数を計算 
    for key, value in freqpair.iteritems():
        if freqpair[key] == 1: 
            continue
        p = re.compile('^([^\t]+)\t([^\t]+)$')
        m = p.search(key)
        if m == None:
            continue
        if freqwords[m.group(1)] < freqwords[m.group(2)]:
            simpthon = float(value) / float(freqwords[m.group(1)])
        else:
            simpthon = float(value) / float(freqwords[m.group(2)])
        if simpthon < 0.1:
            continue
        simp[key] = simpthon
        
    for key, value in freqwords.iteritems():
        print "%s\t%s" % (key, value)
    
    for key, value in simp.iteritems():
        print "%s\t%s" % (key, value)

if __name__ == '__main__':
    main()
