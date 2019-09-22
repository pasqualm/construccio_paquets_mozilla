#!/bin/bash

# habilita el mode de debug
#set -x 

echo Inicialitza les carpetes de locales de l10n-central de catala i valencia

#no fa falta, ve amb el paquet translate-toolkit
#echo 
#echo Descarregant fitxer get_moz_enUS.py
#wget --quiet -r -O get_moz_enUS.py https://raw.githubusercontent.com/translate/translate/master/tools/mozilla/get_moz_enUS.py
#chmod a+x get_moz_enUS.py

# normalment ja el trindrem baixat amb el inicialitza_carpetes
#echo 
#echo Descarregant valencianitzador de fitxers font
#wget --quiet -r -O po/recorre_les_fonts-moz https://raw.githubusercontent.com/Softcatala/adaptadorvariants/master/tools/mozilla/recorre_les_fonts-moz
#chmod a+x po/recorre_les_fonts-moz
#wget --quiet -r -O po/src2valencia-moz.sed https://raw.githubusercontent.com/Softcatala/adaptadorvariants/master/tools/mozilla/src2valencia-moz.sed
#chmod a+x po/src2valencia-moz.sed

mkdir -p l10n-central
echo 
echo Clonant repositori de locale de catala...
hg clone -- https://hg.mozilla.org/l10n-central/ca l10n-central/ca-original
echo 
echo Clonant repositori de locale de valencia...
hg clone -- https://hg.mozilla.org/l10n-central/ca-valencia l10n-central/ca-valencia-original
