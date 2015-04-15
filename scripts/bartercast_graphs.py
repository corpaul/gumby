from Tribler.dispersy.dispersy import Dispersy
from Tribler.dispersy.endpoint import ManualEnpoint
from Tribler.community.bartercast4.statistics import BarterStatistics, BartercastStatisticTypes
from graphviz import Digraph
from _collections import defaultdict
import os
import random
import timeit
import datetime
from abc import ABCMeta, abstractmethod
import csv


class BarterGraphs():
    def __init__(self, db):
        self.dispersy = Dispersy(ManualEnpoint(0), db)
        self.stats = BarterStatistics()
        self.peers = defaultdict()
        self.last_peer = 1

    def get_peer_node(self, peer_id):
        if not peer_id in self.peers:
            self.set_peer_node(peer_id)
        return self.peers[peer_id]

    def set_peer_node(self, peer_id):
        if not peer_id in self.peers:
            self.peers[peer_id] = ("%d" % self.last_peer)
            self.last_peer = self.last_peer + 1

    def get_interactions(self):
        sql = u"SELECT peer1, peer2, type, value, max(date) FROM interaction_log GROUP BY peer1,peer2"
        self.stats._init_database(self.dispersy)
        rows = self.stats.db.execute(sql).fetchall()
        return rows

    def dot_interaction_graph(self):
        rows = self.get_interactions()
        dot = Digraph(comment="Peer interactions")
        dot.graph_attr = {"overlap": "false", "splines": "true"}
        dot.node_attr = {"label": "", "shape": "circle", "width": "0.1"}
        dot.edge_attr = {"arrowsize": "0.1", "arrowhead": "dot", "penwidth": "0.1"}
        for r in rows:
            dot.edge(self.get_peer_node(r[0]), self.get_peer_node(r[1]))

        return dot

    def build_graph(self, dot, engine, name, output_dir):
        print "Building .gv file"
        path = os.path.join(output_dir, name)
        with open("%s.gv" % path, "w") as text_file:
            text_file.write(dot.source)
        dot.engine = engine
        print "[%s] Building graphviz graph with %s" % (datetime.datetime.now().time(), dot.engine)
        tic = timeit.default_timer()
        dot.render("%s.gv" % path)
        toc = timeit.default_timer()
        print "Time elapsed during graph generation: %d seconds" % (toc - tic)


class AbstractBarterDataGenerator():
    __metaclass__ = ABCMeta

    def __init__(self, db):
        self.dispersy = Dispersy(ManualEnpoint(0), db)
        self.stats = BarterStatistics()
        self.stats._init_database(self.dispersy)
        # clear the database for this thing because we want to generate all the data
        self.stats.db.cleanup()

    @abstractmethod
    def generate_data(self, nodes):
        pass


class BCSetDimitra(AbstractBarterDataGenerator):
    def generate_data(self, nodes):
        with open("../lib/data/BC.txt", "r") as input:
            csvreader = csv.reader(input, delimiter=' ', quotechar='|')
            csvreader.next()
            type = BartercastStatisticTypes.TORRENTS_RECEIVED
            for row in csvreader:
                node1 = unicode(row[1])
                node2 = unicode(row[2])
                value = unicode(row[3])
                if value > 0:
                    peer_from = node1
                    peer_to = node2
                else:
                    peer_from = node2
                    peer_to = node1
                self.stats.log_interaction(self.dispersy, type, peer_from, peer_to, value)
            self.stats.close()



class GenerateBarterData(AbstractBarterDataGenerator):
    def generate_data(self, nodes):
        for n in range(1, nodes):
            peer_from = u"192.168.1.%d" % n
            peer_ranges = range(1, nodes)
            peer_ranges.remove(n)
            # generate random records
            # for i in range(1, nodes / 2):
            # set 10 edges per node
            for i in range(1, max(nodes - 1, 3)):
                x = random.choice(peer_ranges)
                peer_to = u"192.168.1.%d" % x
                peer_ranges.remove(x)
                type = BartercastStatisticTypes.TORRENTS_RECEIVED
                value = random.randint(1, 1000)
                # date = "strftime('%s', 'now')"
                # sql = u"INSERT INTO interaction_log (peer1, peer2, type, value, date) values (%s, %s, %s, %s, %s)" % (peer_from, peer_to, type, value, date)
                self.stats.log_interaction(self.dispersy, type, peer_from, peer_to, value)
            print "... node: %s" % peer_from
            self.stats.close()


nodes = "dimitra"
# nodes = 10
data = u"/home/corpaul/workspace/output/%s" % nodes
print "Working directory: %s" % data

if nodes == "dimitra":
    engine = "sfdp"
elif nodes > 10:
    # engine = "sfdp"
    engine = "sfdp"
else:
    engine = "neato"

if not os.path.exists(data):
    os.makedirs(data)

if nodes == "dimitra":
    print "Loading dimitra dataset"
    generated_data = BCSetDimitra(data)
else:
    print "Generating random data for %d nodes" % nodes
    generated_data = GenerateBarterData(data)

generated_data.generate_data(nodes)

# build graphs
print "Building graph"
bg = BarterGraphs(data)
bg.build_graph(bg.dot_interaction_graph(), engine, "test", data)
# print bg.peers
