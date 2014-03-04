#!/bin/bash -e

cd youtube-dl
nosetests
cd ..

#cd django
#djangobench --control=1.2 --experiment=master
