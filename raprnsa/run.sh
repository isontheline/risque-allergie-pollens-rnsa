#!/usr/bin/with-contenv bashio
COUNTY=$(cat options.json |jq -r '.County')
COUNTY_JSON_FILE="/data/pollens_risks_thea_county_$COUNTY.json"
COUNTY_ENTRYPOINT="https://www.pollens.fr/risks/thea/counties/$COUNTY"
USER_AGENT="https://github.com/isontheline/risque-allergie-pollens-rnsa"
until false; do 
  curl -s -X GET "$COUNTY_ENTRYPOINT" -o $COUNTY_JSON_FILE
  RISK_LEVEL=$(cat $COUNTY_JSON_FILE | jq '.riskLevel')
  echo "Current Risk Level for County '$COUNTY' : $RISK_LEVEL"
  curl -s \
    -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $HASSIO_TOKEN" \
    -A "$USER_AGENT" \
    -d '{"state": "'$RISK_LEVEL'", "attributes":  {"unit_of_measurement": "level", "icon": "mdi:flower-pollen", "friendly_name": "Risk Level"}}' \
    http://hassio/homeassistant/api/states/weather.raprnsa_county_$COUNTY \
    2>/dev/null
  echo ""
  sleep 3600;
done
