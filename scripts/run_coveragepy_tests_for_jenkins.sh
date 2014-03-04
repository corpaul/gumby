#!/bin/bash -e

cd coveragepy
tox
cd ..

#cd django
#djangobench --control=1.2 --experiment=master
