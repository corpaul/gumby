#!/bin/bash -e
# django_experiment_setup.sh ---
#
# Filename: django_experiment_setup.sh
# Description:
# Author: Cor-Paul Bezemer
# Maintainer:
# Created: Feb 25 2014
# Version:

# Commentary:
#
# %*% This setup script should be used for any experiment involving Django.
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
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; see the file COPYING.  If not, write to
# the Free Software Foundation, Inc., 51 Franklin Street, Fifth
# Floor, Boston, MA 02110-1301, USA.
#
#

# Code:


if [ -z "$LOCAL_RUN" -o $(echo $USE_LOCAL_VENV | tr '[:upper:]' '[:lower:]') == 'true' ]; then
    build_virtualenv.sh
fi

pip install -e django
#pip install -e git://github.com/django/djangobench.git#egg=djangobench


#
# django_experiment_setup.sh ends here
