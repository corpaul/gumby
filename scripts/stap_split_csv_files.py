#!/usr/bin/env python
'''
Created on Aug 26, 2013

@author: corpaul
'''
import unicodecsv
import sys
import os
from gumby.settings import loadConfig

headers = {}
headers["WRITE"] = ['TIMESTAMP', 'TYPE', 'TRACE', 'PROCESS', 'BYTES', 'FILE', 'TIME']
headers["CPU"] = ['TIMESTAMP', 'TYPE', 'TRACE', 'PROCESS', 'BYTES', 'FILE', 'TIME', 'CALLS', 'TOTALTIME']


def splitFile(csv, outputPath):
    with open(csv, 'rb') as csvfile:
        reader = unicodecsv.DictReader(csvfile, delimiter=',')
        output = {}
        for line in reader:
            if line['TYPE'] not in output:
                output[line['TYPE']] = []
            output[line['TYPE']].append(line)

    for t in output.iterkeys():
        print t
        with open('%s/%s.csv' % (outputPath, t), 'wb') as csvfile:
            fnames = headers[line['TYPE']]
            spamwriter = unicodecsv.DictWriter(csvfile, delimiter=',', fieldnames=fnames)
            spamwriter.writerow(dict((fn, fn) for fn in fnames))
            for line in output[t]:
                print line
                spamwriter.writerow(line)

if __name__ == '__main__':
    if len(sys.argv) < 4:
        print "Usage: python split_csv_files.py configFile csvFilename outputPath"
        sys.exit(0)

    config = loadConfig(sys.argv[1])
    csvFilename = sys.argv[2]
    outputPath = sys.argv[3]

    splitFile(csvFilename, outputPath)
