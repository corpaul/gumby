#!/bin/bash -ex
# sqlite_benchmark_setup.sh ---
#
# Filename: sqlite_benchmark_setup.sh
# Description:
# Author: Cor-Paul Bezemer
# Maintainer:
# Created: Feb 26 2014
# Version:

# Commentary:
#
# %*% This setup script should be used for any experiment involving the Sqlite benchmark.
#
#

# Change Log:
#
#
#
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; see the file COPYING. If not, write to
# the Free Software Foundation, Inc., 51 Franklin Street, Fifth
# Floor, Boston, MA 02110-1301, USA.
#
#

# Code:


if [ -z "$LOCAL_RUN" -o $(echo $USE_LOCAL_VENV | tr '[:upper:]' '[:lower:]') == 'true' ]; then
build_virtualenv.sh
fi

mkdir -p sqlite_bld

# See http://www.wtfpl.net/txt/copying for license details
# Creates a minimal manifest and manifest.uuid file so sqlite (and fossil) can build
cd $REPOSITORY_DIR
git rev-parse --git-dir >/dev/null || exit 1
git log -1 --format=format:%ci%n | sed -e 's/ [-+].*$//;s/ /T/;s/^/D /' | tee manifest
git log -1 --format=format:%H | tee manifest.uuid

cd ..

#pip install -e django
#pip install -e git://github.com/django/djangobench.git#egg=djangobench


#
# django_experiment_setup.sh ends here