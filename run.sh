#!/bin/bash

FOO="$(curl -vs https://ravintolafactory.com/lounasravintolat/ravintolat/espoo-otaniemi/ 2>&1 | awk '/'`date +%A | sed 's/.*/\u&/'`'/{f=1} f; /'`date -d @$(($(date +%s)+84600)) +%A | sed 's/.*/\u&/'`'/{f=0}' | sed -e 's/<[^>]*>//g' | sed '$d')"
curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$FOO\"}" https://hooks.slack.com/services/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
