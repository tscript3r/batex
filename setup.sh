#!/bin/bash

OSM_PBF="poland-latest.osm.pbf"
URL="https://download.geofabrik.de/europe/${OSM_PBF}"

echo ''
echo ">>>> DOWNLOAD ${OSM_PBF}"
echo ''
rm -rf osrm/*
mkdir -p osrm
chmod 777 osrm
cd osrm || exit
wget ${URL}

echo ''
echo '>>>> EXTRACT'
echo ''
docker run --name osrm-data-builder-1 -t -v "${PWD}:/data" osrm/osrm-backend osrm-extract -p /opt/car.lua /data/${OSM_PBF}
echo ''
echo '>>>> PARTITION'
echo ''
docker run --name osrm-data-builder-2 -t -v "${PWD}:/data" osrm/osrm-backend osrm-partition /data/${OSM_PBF}
echo ''
echo '>>>> CUSTOMIZE'
echo ''
docker run --name osrm-data-builder-3 -t -v "${PWD}:/data" osrm/osrm-backend osrm-customize /data/${OSM_PBF}
docker stop osrm-data-builder-1 osrm-data-builder-2 osrm-data-builder-3
docker rm osrm-data-builder-1 osrm-data-builder-2 osrm-data-builder-3