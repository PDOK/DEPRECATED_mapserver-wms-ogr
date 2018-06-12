FROM pdok/mapserver-wms-ogr

COPY /etc/natura2000.map /srv/data/natura2000.map
COPY /etc/natura2000.gpkg /srv/data/natura2000.gpkg
COPY /etc/header.inc /srv/data/header.inc
COPY /etc/style.inc /srv/data/style.inc
