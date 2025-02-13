#!/usr/bin/with-contenv bashio
COUNTY=$(cat options.json |jq -r '.County')
COUNTY_JSON_FILE="/data/pollens_risks_thea_county_$COUNTY.json"
COUNTY_ENTRYPOINT="https://www.pollens.fr/risks/thea/counties/$COUNTY"
USER_AGENT="https://github.com/isontheline/risque-allergie-pollens-rnsa"
until false; do
  curl -s \
    -X GET \
    -A "$USER_AGENT" \
    "$COUNTY_ENTRYPOINT" \
    -o $COUNTY_JSON_FILE
  RISK_LEVEL=$(cat $COUNTY_JSON_FILE | jq '.riskLevel')
  echo "[$(date)] Current Risk Level for County '$COUNTY' : $RISK_LEVEL"
  curl -s \
    -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $HASSIO_TOKEN" \
    -d '{"state": "'$RISK_LEVEL'", "attributes":  {"device_class": "AQI", "state_class": "measurement", "icon": "mdi:flower-pollen", "friendly_name": "Pollens Risk Level (County '$COUNTY')"}}' \
    http://hassio/homeassistant/api/states/weather.raprnsa_county_$COUNTY \
    2>/dev/null
  echo ""
  sleep 3600;
done
