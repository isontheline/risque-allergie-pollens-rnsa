#!/usr/bin/with-contenv bashio
COUNTY=$(cat options.json |jq -r '.County')
until false; do 
  curl "https://pollens.fr/load_vigilance_map" -o /data/rnsa_load_vigilance_map.json
  RISK_LEVEL=$(cat /data/rnsa_load_vigilance_map.json | jq '.vigilanceMapCounties | fromjson | .["'$COUNTY'"].riskLevel')
  echo "Current Risk Level for County '$COUNTY' : $RISK_LEVEL"
  curl -s -X POST -H "Content-Type: application/json"  -H "Authorization: Bearer $HASSIO_TOKEN" -d '{"state": "'$RISK_LEVEL'", "attributes":  {"unit_of_measurement": "state", "icon": "mdi:flower-pollen", "friendly_name": "Risk Level"}}' http://hassio/homeassistant/api/states/sensor.raprnsa.county_$COUNTY 2>/dev/null
  sleep 120;
done
