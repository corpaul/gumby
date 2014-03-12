#!/bin/bash -e

python django/tests/runtests.py --settings=test_sqlite
#cd django
#djangobench --control=1.2 --experiment=master
