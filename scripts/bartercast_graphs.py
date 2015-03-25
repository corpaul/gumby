from Tribler.dispersy.dispersy import Dispersy
from Tribler.dispersy.endpoint import ManualEnpoint
from Tribler.community.bartercast4.statistics import BarterStatistics
from graphviz import Digraph
from _collections import defaultdict
import os


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
            self.peers[peer_id] = ("P%d" % self.last_peer)
            self.last_peer = self.last_peer + 1

    def get_interactions(self):
        sql = u"SELECT peer1, peer2, type, value, max(date) FROM interaction_log GROUP BY peer1,peer2"
        self.stats._init_database(self.dispersy)
        rows = self.stats.db.execute(sql).fetchall()
        return rows

    def dot_interaction_graph(self):
        rows = self.get_interactions()
        dot = Digraph(comment="Peer interactions")
        for r in rows:
            dot.edge(self.get_peer_node(r[0]), self.get_peer_node(r[1]))
        # for p in self.peers:
            # dot.node(p, self.peers[p])

        return dot

    def build_graph(self, dot, name, output_dir):
        path = os.path.join(output_dir, name)
        with open("%s.gv" % path, "w") as text_file:
            text_file.write(dot.source)

        dot.render("%s.gv" % path)

bg = BarterGraphs(u"/home/corpaul/workspace/output/")
bg.build_graph(bg.dot_interaction_graph(), "test", "/home/corpaul/workspace/output/")
print bg.peers
