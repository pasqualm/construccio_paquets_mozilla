#!/bin/bash

# habilita el mode de debug
debug=false
if [ "$debug" == "true" ]; then
	set -x 
fi

DIRECTORI_BASE=`realpath $0 | xargs dirname`

PATH_ORIGINAL_L10N_CA=`realpath $0 | xargs dirname`/l10n-central/ca-original
PATH_ORIGINAL_L10N_CA_VALENCIA=`realpath $0 | xargs dirname`/l10n-central/ca-valencia-original
PATH_FINAL_L10N_CA_VALENCIA=`realpath $0 | xargs dirname`/l10n-central/ca-valencia

L10NTMP=`realpath $0 | xargs dirname`/l10n-central/tmp
rm -rf $L10NTMP
mkdir -p $L10NTMP

#actualitza els fitxers d'idioma catala des del repo
cd $PATH_ORIGINAL_L10N_CA
hg pull -u
#hg update --clean $REPO_TAG
hg update --clean
cd ../..

#actualitza els fitxers d'idioma valencia des del repo
cd $PATH_ORIGINAL_L10N_CA_VALENCIA
hg pull -u
#hg update --clean $REPO_TAG
hg update --clean
cd ../..

#triem des d'on fem la traduccio
TRANSLATE_FROM=$PATH_ORIGINAL_L10N_CA_VALENCIA

# clona el repo original en el final
rm -rf $PATH_FINAL_L10N_CA_VALENCIA
cp -r $TRANSLATE_FROM $PATH_FINAL_L10N_CA_VALENCIA


# Crea fitxers PO catalans  a tmp
#-----------------------------------------
moz2po -t $TRANSLATE_FROM -i $TRANSLATE_FROM -o $L10NTMP -x "*.ftl" -x "*.properties" -x "*.js" -x "*.rdf" -x "*.inc" -x "*.txt" -x "*.mn" -x "README" -x "*.aff" -x "*.dic" -x "*.xml" -x "*.gif" -x "*.png" -x "*.css" -x "*.xhtml" -x "*.extra" -x "*.html" -x "*.ini"

# valencianitza els PO
cd $DIRECTORI_BASE/po
echo
echo Valencianitzant els PO...
./recorre_les_fonts-moz $L10NTMP
echo

#passa els PO de nou a format mozilla en ca-valencia
echo Insertant els PO adaptats en $PATH_FINAL_L10N_CA_VALENCIA...
po2moz -t $TRANSLATE_FROM -i $L10NTMP -o $PATH_FINAL_L10N_CA_VALENCIA
echo

#copia els ftl i properties al TMP desres de netejarlo
rm -rf $L10NTMP/*
cd $TRANSLATE_FROM
find . -name *.ftl -or -name *.properties -or -name *.ini | cpio -pdm $L10NTMP/

#adapta els ftl i properties
echo Valencianitzant els FTL i PROPERTIES...
cd $DIRECTORI_BASE/po
./recorre_les_fonts-moz-fluent $L10NTMP

echo Insertant els FTL i PROPERTIES adaptats en $PATH_FINAL_L10N_CA_VALENCIA...
cd $L10NTMP
find . -name *.ftl -or -name *.properties | cpio -pdm $PATH_FINAL_L10N_CA_VALENCIA

echo Adaptació finalitzada :\)
