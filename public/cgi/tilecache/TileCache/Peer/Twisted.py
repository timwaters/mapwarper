# BSD Licensed, Copyright (c) 2006-2008 MetaCarta, Inc.

from Swarm import Message, Client
from twisted.internet.protocol import DatagramProtocol
from twisted.web import getPage
from twisted.internet import reactor

class TwistedClient (DatagramProtocol, Client):
    directoryURL = "..."

    def __init__ (self, service, key, weight = 10.0, *args, **kwargs):
        DatagramProtocol.__init__(self, *args, **kwargs)
        Client.__init__(self, service, key, None, weight)
    
    def datagramReceived(self, data, (host, port)):
        self.handle(data, (host, port))

    def send (self, peer, msg):
        self.transport.write( msg.freeze(), peer.address )
    
    def schedule (self, when, callback, *args):
        reactor.callLater(time.time() + when, callback, *args)

    def load_peers (self):
        d = getPage(self.directoryURL)
        d.addCallback(self.load_peers_from_string)
        self.schedule(15.0, self.load_peers)

    def startProtocol (self):
        self.load_peers()

if __name__ == '__main__':
    reactor.listenUDP(5150, Echo())
    reactor.run()

