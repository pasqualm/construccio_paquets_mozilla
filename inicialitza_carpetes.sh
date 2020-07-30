#!/bin/bash

# habilita el mode de debug
#set -x 

while getopts ":r:" opt; do
  case $opt in
    r)
      repositori=$OPTARG
      ;;
    \?)
      echo "Opció invàlida: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Opció -$OPTARG requireix un argument." >&2
      exit 1
      ;;
  esac
done

if [ "$repositori" == "" ]; then
	echo Has cridat l\'script sense passar un repostori, la sintaxi de l\'script es:
	echo inicialitza_carpetes.sh -r repositori
	echo
	echo Exemples:
	echo	inicialitza_carpetes.sh -r esr38
	echo	inicialitza_carpetes.sh -r beta
	echo 
	echo Consultar repositoris disponibles en https://hg.mozilla.org/releases/mozilla-esr38/
	exit -1
fi

echo Inicialitza el directori creant totes les carpetes que fan falta, baixant el fitxers que corresponga i inicialitzant els repositoris

#no fa falta, ve amb el paquet translate-toolkit
#echo 
#echo Descarregant fitxer get_moz_enUS.py
#wget --quiet -r -O get_moz_enUS.py https://raw.githubusercontent.com/translate/translate/master/tools/mozilla/get_moz_enUS.py
#chmod a+x get_moz_enUS.py

echo 
echo Descarregant valencianitzador de fitxers font
wget --quiet -r -O po/recorre_les_fonts-moz https://raw.githubusercontent.com/Softcatala/adaptadorvariants/master/tools/mozilla/recorre_les_fonts-moz
chmod a+x po/recorre_les_fonts-moz
wget --quiet -r -O po/src2valencia-moz.sed https://raw.githubusercontent.com/Softcatala/adaptadorvariants/master/tools/mozilla/src2valencia-moz.sed
chmod a+x po/src2valencia-moz.sed

echo 
echo Clonant repositoris de locale en català
mkdir -p l10n
hg clone -- http://hg.mozilla.org/releases/l10n/mozilla-beta/ca/ l10n/ca-beta
hg clone -- http://hg.mozilla.org/releases/l10n/mozilla-release/ca/ l10n/ca-release
hg clone -- https://hg.mozilla.org/l10n-central/ca l10n/ca-central

echo 
echo Clonant repositori $repositori de Firefox
hg clone -- https://hg.mozilla.org/releases/mozilla-$repositori/ mozilla-$repositori
echo 

echo Clonant repositori $repositori contenidor de firefox per a Thunderbird
hg clone -- https://hg.mozilla.org/releases/mozilla-$repositori/ comm-$repositori

mkdir comm-$repositori/comm
echo
echo clonant subrepositori de thunderbird
hg clone -- https://hg.mozilla.org/releases/comm-$repositori/ comm-$repositori/comm

mkdir gecko-strings
echo
echo clonant gecko-strings, s'utilitza per a compare-locales
hg clone -- https://hg.mozilla.org/l10n/gecko-strings gecko-strings
