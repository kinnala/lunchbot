#!/bin/bash

# Factory
if [ `date +%A` == "perjantai" ]; then
    FACTORY="$(curl -vs https://ravintolafactory.com/lounasravintolat/ravintolat/espoo-otaniemi/ 2>&1 | awk '/'`date +%A | sed 's/.*/\u&/'`'/{f=1} f; /Monday/{f=0}' | sed -e 's/<[^>]*>//g' | sed '$d')"
else
    FACTORY="$(curl -vs https://ravintolafactory.com/lounasravintolat/ravintolat/espoo-otaniemi/ 2>&1 | awk '/'`date +%A | sed 's/.*/\u&/'`'/{f=1} f; /'`date -d tomorrow +%A | sed 's/.*/\u&/'`'/{f=0}' | sed -e 's/<[^>]*>//g' | sed '$d')"
fi
echo "${FACTORY}"

# Silinteri
export PYTHONIOENCODING=utf8
SILINTERI=$(curl -s 'https://www.fazerfoodco.fi/modules/json/json/Index?costNumber=019002&language=fi' | \
                python2 -c "import sys, json; sonni=json.load(sys.stdin); ruuat=[sonni['MenusForDays'][0]['SetMenus'][i]['Name'] + ': ' + ', '.join(sonni['MenusForDays'][0]['SetMenus'][i]['Components']) for i in range(len(sonni['MenusForDays'][0]['SetMenus']))]; print '\n'.join(ruuat)")
echo "${SILINTERI}"

# Maukas
MAUKAS=$(curl -s 'https://www.mau-kas.fi/' | grep "block_level bold" | sed -e 's/<[^>]*>//g' | perl -MHTML::Entities -pe 'decode_entities($_);' | iconv -f ISO-8859-1 -t UTF-8 | sed '/VUORIMIEHEN/d')
echo "${MAUKAS}"

# Kipsari
KIPSARI=$(WD=`date +%a` WD=$(tr [:lower:] [:upper:] <<< ${WD:0:1})${WD:1} && curl -vs http://www.kipsari.com/ 2>&1 | grep -o -E ">$WD [^<]*<" | sed "s/^>$WD \([^<]*\)<$/\1/")
echo "${KIPSARI}"

# Pizza bar
PIZZABAR="$(curl -s 'https://www.pizzabar.fi/lounas' | grep -A6 -E "(Maanantai|Tiistai|Keskiviikko|Torstai|Perjantai) [0-9].?\.[0-9].?" | sed '/^$/d' | grep "hamburgerheaven" | perl -0777 -ne 'print "$1 $2LINEBREAK$3 $4 $5\n" while /[^\n]*(Maanantai|Tistai|Keskiviikko|Torstai|Perjantai)(?:.*?(?:burgerheaven\"\>(?=[a-zA-Z])))(.*?)(?=\<)[^\n]*\n(?:.*?(?:burgerheaven\"\>(?=[a-zA-Z])))(.*?)(?=\<)/smg' | (mapfile -t; echo "${MAPFILE[(($(date +%u)-2))]}") | cut -d ' ' -f  2- | sed s/LINEBREAK/\\n/ | sed s/'\&amp;'/'\&'/ | sed s/'\&nbsp;'/' '/ | sed s/'\&egrave;'/e/)"
echo "${PIZZABAR}"

if [[ -z "${LUNCH_SECRET}" ]]; then
	echo "Environment variable LUNCH_SECRET must be defined."
	echo "Output is sent to hooks.slack.com/services/\$LUNCH_SECRET."
	exit 1
fi

# Send to Slack
curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"_FACTORY_\n$FACTORY\"}" https://hooks.slack.com/services/$LUNCH_SECRET
curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"_SILINTERI_\n$SILINTERI\"}" https://hooks.slack.com/services/$LUNCH_SECRET
curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"_MAUKAS_\n$MAUKAS\"}" https://hooks.slack.com/services/$LUNCH_SECRET
curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"_KIPSARI_\n$KIPSARI\"}" https://hooks.slack.com/services/$LUNCH_SECRET
curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"_PIZZABAR_\n$PIZZABAR\"}" https://hooks.slack.com/services/$LUNCH_SECRET
