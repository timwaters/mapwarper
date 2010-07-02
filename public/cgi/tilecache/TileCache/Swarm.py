# BSD Licensed, Copyright (c) 2006-2008 MetaCarta, Inc.

import struct, time
from sha import sha
from bisect import bisect_left

from Layer import Layer, Tile
from Client import WMS
from Service import Service

class Message (object):
    types           = ("PING", "PONG", "GET", "PUT", "DELETE")
    header          = "!20sLHH"
    header_len      = struct.calcsize(header)    
    tilespec        = "!31pHLL"
    tilespec_len    = struct.calcsize(tilespec)

    def __init__ (self, msgtype, key, seq, tile = None):
        self.key    = key
        self.seq_id = seq
        self.type   = msgtype
        self.tile   = tile

    def _thaw (classobj, msgtxt, layers):
        key, seq, msgtype, crc = struct.unpack( classobj.header,
                                                msgtxt[:classobj.header_len] )
        msg           = classobj( classobj.types[msgtype], key, seq )
        msg.checksum  = crc
        dispatch      = getattr(msg, "thaw_" + msg.type)
        dispatch( msgtxt[classobj.header_len:], layers )
        return msg
    thaw = classmethod(_thaw)
    
    def thaw_PING (self, msgtxt, layers):
        pass

    def thaw_PONG (self, msgtxt, layers):
        self.ping_id  = struct.unpack("!L", msgtxt)

    def thaw_GET (self, msgtxt, layers):
        layername, level, row, col = struct.unpack(self.tilespec, msgtxt)
        self.tile = Tile(layers[layername], row, col, level)

    def thaw_PUT (self, msgtxt, layers):
        self.thaw_GET(msgtxt[:self.tilespec_len], layers)
        self.tile.data = msgtxt[self.tilespec_len:]

    def thaw_DELETE (self, msgtxt, layers):
        layername, level, minrow, mincol, maxrow, maxcol = \
                    struct.unpack("!31pHLLLL", msgtxt)
        self.layer = layer[layername]
        self.level = level
        self.box   = (minrow, mincol, maxrow, maxcol)

    def freeze (self):
        msgtype, name = filter( lambda x: x[1] == self.type, 
                                enumerate(self.types) )[0]
        msgtxt      = struct.pack( self.header,
                                   self.key, self.seq_id, msgtype, 0 )
        dispatch    = getattr(self, "freeze_" + self.type)
        msgtxt     += dispatch()
        return msgtxt

    def freeze_PING (self):
        return ""

    def freeze_PONG (self):
        return struct.pack("!L", self.ping_id)

    def freeze_GET (self):
        tile = self.tile
        return struct.pack(self.tilespec,
                           tile.layer.name, tile.z, tile.x, tile.y) 
    
    def freeze_PUT (self):
        return self.freeze_GET() + self.tile.data

    def freeze_DELETE (self):
        return struct.pack("!31pHLLLL",
                           self.tile.layer.name, self.level, *self.box)

class Peer (object):
    min_timeout = 15
    def __init__ (self, key = None, address = None, weight = 10.0):
        self.address = address
        self.key     = key
        self.weight  = float(weight)
        self.seq_id  = 0L
        self.timeout = self.min_timeout

class Client (Peer):
    max_ring_inserts = 64
    replication      = 3

    def __init__ (self, service = None, **kwargs):
        Peer.__init__(self, **kwargs)
        self.seq_id     = long( time.time() )
        self.ring       = []
        self.peers      = {}
        self.requests   = {}
        self.config     = service
        self.server     = None

    def tile_key (self, tile):
        id = tile.layer + struct.pack("xHLL", tile.z, tile.x, tile.y)
        return sha(id).digest()

    def message (self, type, tile = None):
        self.seq_id += 1
        return Message(type, self.key, self.seq_id, tile)

    def drop_timeout (self, peer):
        if peer.timeout: peer.timeout -= 1

    def schedule_timeout (self, peer):
        self.schedule(1.0, self.drop_timeout, peer)

    def set_put_callback (self, tile, callback):
        key = self.tile_key(tile)
        if key not in self.requests:
            self.requests[key] = []
        self.requests[key].append(callback)

    def trigger_put_callbacks (self, tile):
        key = self.tile_key(tile)
        if key not in self.requests:
            return
        for callback in self.requests[key]:
            callback(tile)
        del self.requests[key]

    def send (self, peer, msg):
        raise NotImplementedError()

    def schedule (self, when, callback, *args):
        raise NotImplementedError()

    def load_peers (self):
        raise NotImplementedError()
        self.schedule(15.0, self.load_peers)

    def load_peers_from_string(self, data): 
        directory = []
        found     = {}
        for line in data.split("\n"):
            key, ip, port, weight = line.split(" ")
            directory.append(Peer(key, (ip, port), weight)) 
        self.set_peers(directory)

    def set_peers (self, peers):
        new_peers = dict(map(lambda p: (p.key, p), peers))

        for key, peer in new_peers:
            if key in self.peers:           # already have it
                continue 
            else:
                self.peers[key] = peer      # don't? then add it

        for key, peer in self.peers:
            if key not in new_peers:
                del self.peers[key]         # don't need it anymore

        self.rebalance_peers()

    def rebalance_peers (self):
        ring    = []
        peers   = self.peers.values()
        total_weight = sum([p.weight for p in peers]) + 1.0
        for peer in peers:
            normal_weight = peer.weight / total_weight * self.max_ring_inserts
            self.ring.append((peer.key, peer))
            for i in range(1, int(normal_weight)):
                subkey = sha(peer.key + chr(i)).digest()
                self.ring.append((subkey, peer))
        ring.sort()
        self.ring = ring

    def select_peers (self, key, count = replication):
        if type(key) is Tile:
            key = self.tile_key(key)
        start  = bisect_left(self.ring, (key,))
        cursor = start
        selected = []
        while len(selected) < count:
            peer = self.ring[cursor][1]
            if peer.timeout and peer.key != self.key:
                selected.append(peer)
            if cursor == len(self.ring):
                cursor = 0
            else:
                cursor += 1
            if cursor == start: break
        return selected

    def send_GET (self, tile, callback = None):
        if callable(callback):
            self.set_put_callback(tile, callback)
        for target in self.select_peers(tile):
            msg = self.message("GET", tile)
            self.send(target, msg)
            self.schedule_timeout(target)

    def send_PUT (self, tile):
        for target in self.select_peers(tile):
            msg = self.message("PUT", tile)
            self.send(target, msg)

    def send_PING (self, peer):
        self.send( peer, self.message("PING") ) 
        self.schedule_timeout(peer)

    def send_PONG (self, ping):
        msg = self.message("PONG")
        msg.ping_id = ping.seq_id
        peer = self.peers[ping.key]
        self.send( peer, msg )

    def handle (self, thunk, (host, port)):
        msg = Message.thaw(thunk, self.config.layers)
        peer = self.peers[msg.key]
        # validate originating host/port here
        peer.timeout = self.max_timeout
        dispatch = getattr(self, "handle_" + msg.type)
        dispatch(peer, msg) 

    def handle_GET (self, peer, msg):
        data = self.config.cache.get(msg.tile)
        if data:
            msg.tile.data = data
            reply = self.message("PUT", msg.tile)
            self.send( peer, reply )
        else:
            self.send_PONG( msg )
        
    def handle_PUT (self, peer, msg):
        self.config.cache.set(msg.tile, msg.tile.data) 
        self.handle_put_callbacks(msg.tile) 
        
    def handle_PING (self, peer, msg):
        self.send_PONG(msg)
        
    def handle_PONG (self, peer, msg):
        # already reset peer timeout, nothing to be done
        pass

    def handle_DELETE (self, peer, msg):
        # not implemented yet
        pass
