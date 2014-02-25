#!/bin/bash -e

python django/tests/runtests.py
#cd django
#djangobench --control=1.2 --experiment=master
