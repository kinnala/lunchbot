#!/bin/bash

if [[ -z "${LUNCH_SECRET}" ]]; then
	echo "Environment variable LUNCH_SECRET must be defined."
	echo "Output is sent to hooks.slack.com/services/\$LUNCH_SECRET."
	exit 1
fi

FACTORY="$(curl -vs https://ravintolafactory.com/lounasravintolat/ravintolat/espoo-otaniemi/ 2>&1 | awk '/'`date +%A | sed 's/.*/\u&/'`'/{f=1} f; /'`date -d @$(($(date +%s)+84600)) +%A | sed 's/.*/\u&/'`'/{f=0}' | sed -e 's/<[^>]*>//g' | sed '$d')"
curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$FACTORY\"}" https://hooks.slack.com/services/$LUNCH_SECRET
