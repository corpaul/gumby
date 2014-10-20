#!/usr/bin/env python
# bartercast_client.py ---
#
# Filename: bartercast_client.py
# Description:
# Author: Cor-Paul Bezemer
# Maintainer:
# Created: Wed Oct 15 16:43:53 2014 (+0200)

# Commentary:
#
#
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

from os import path
from sys import path as pythonpath

from gumby.experiments.dispersyclient import DispersyExperimentScriptClient, main

from random import choice
from string import letters
from time import time
import logging
from twisted.internet.task import LoopingCall


# TODO(emilon): Fix this crap
pythonpath.append(path.abspath(path.join(path.dirname(__file__), '..', '..', '..', "./tribler")))


class BarterClient(DispersyExperimentScriptClient):

    def __init__(self, *argv, **kwargs):
        from Tribler.community.bartercast4.community import BarterCommunity
        DispersyExperimentScriptClient.__init__(self, *argv, **kwargs)
        self.community_class = BarterCommunity
        self._logger = logging.getLogger()
        self._logger.error("starting BarterClient")

    def start_dispersy(self):
        from Tribler.community.allchannel.community import AllChannelCommunity

        DispersyExperimentScriptClient.start_dispersy(self)
        self._dispersy.define_auto_load(AllChannelCommunity, self._my_member, (), {"integrate_with_tribler": False})

    def registerCallbacks(self):
        self.scenario_runner.register(self.request_stats, 'request-stats')

    def request_stats(self, candidate, amount=1):
        amount = int(amount)
        for _ in xrange(amount):
            self._logger.error('creating-stats-request')
            key = u'torrents_received'
            self._community.create_stats_request(candidate, key)


if __name__ == '__main__':
    BarterClient.scenario_file = "barter.scenario"
    main(BarterClient)

#
# demers_client.py ends here
