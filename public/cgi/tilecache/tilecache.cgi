#!/usr/bin/env python

from TileCache import Service, cgiHandler, cfgfiles

if __name__ == '__main__':
    svc = Service.load(*cfgfiles)
    cgiHandler(svc)

