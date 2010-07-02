#!/bin/sh
MAPSERV="/home/.vic/timwarp/wrp.geothings.net/current/public/cgi/mapserv.cgi"
MAPFOLDER="/home/.vic/timwarp/wrp.geothings.net/current/db/mapfiles"
if [ "${REQUEST_METHOD}" = "GET" ]; then
  if [ -z "${QUERY_STRING}" ]; then
    QUERY_STRING="map=${MAPFOLDER}"
  else
    QUERY_STRING="map=${MAPFOLDER}/${QUERY_STRING}"
  fi
  exec ${MAPSERV}
else
  echo "Sorry, I only understand GET requests."
fi
exit 1
# End of Script



