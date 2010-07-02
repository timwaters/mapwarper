#!/usr/bin/python
from TileCache.Service import wsgiApp
from optparse import OptionParser

def run(port=8080, threading=False, config=None):
    from wsgiref import simple_server
    if threading:
        from SocketServer import ThreadingMixIn
        class myServer(ThreadingMixIn, simple_server.WSGIServer):
            pass 
        httpd = myServer(('',port), simple_server.WSGIRequestHandler,)
    else:    
        httpd = simple_server.WSGIServer(('',port), simple_server.WSGIRequestHandler,)
    httpd.set_app(wsgiApp)
    try:
        print "Listening on port %s" % port
        httpd.serve_forever()
    except KeyboardInterrupt:
        print "Shutting down."

if __name__ == '__main__':
    parser = OptionParser()
    parser.add_option("-p", "--port", help="port to run webserver on. Default is 8080", dest="port", action='store', type="int", default=8080)
    parser.add_option("-t", "--threading", help="threading http server. default is false", dest="threading", action='store_true', default=False)
    (options, args) = parser.parse_args()
    run(options.port, options.threading)
