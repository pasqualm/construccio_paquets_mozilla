#!/bin/bash

# habilita el mode de debug
debug=false
if [ "$debug" == "true" ]; then
	set -x 
fi

# carpetes que no existeix en ca-valencia i per tant no es deuen traduir des de ca
exclude_folders=( ".hgtags" ".hg" "calendar" "chat" "editor" "./extensions" "mail" "mobile" "other-licenses" "suite" )

# fitxer que no es deuen tocar en ca-valencia
forbidden_files=( "region.properties" "intl.properties" "defines.inc" )

DIRECTORI_BASE=`realpath $0 | xargs dirname`

PATH_ORIGINAL_L10N_CA=`realpath $0 | xargs dirname`/l10n-central/ca-original
PATH_ORIGINAL_L10N_CA_VALENCIA=`realpath $0 | xargs dirname`/l10n-central/ca-valencia-original
PATH_FINAL_L10N_CA_VALENCIA=`realpath $0 | xargs dirname`/l10n-central/ca-valencia

#triem des d'on fem la traduccio
TRANSLATE_FROM=$PATH_ORIGINAL_L10N_CA

L10NTMP=`realpath $0 | xargs dirname`/l10n-central/tmp
rm -rf $L10NTMP
mkdir -p $L10NTMP

#actualitza els fitxers d'idioma catala des del repo
cd $PATH_ORIGINAL_L10N_CA
hg pull -u
hg update --clean
cd ../..

#actualitza els fitxers d'idioma valencia des del repo
cd $PATH_ORIGINAL_L10N_CA_VALENCIA
hg pull -u
hg update --clean
cd ../..

# clona el repo original en el final
rm -rf $PATH_FINAL_L10N_CA_VALENCIA

for i in "${!exclude_folders[@]}"
do
  exclude_folders[i]="--exclude=${exclude_folders[i]}"
done
rsync -a "${exclude_folders[@]}" $TRANSLATE_FROM/* $PATH_FINAL_L10N_CA_VALENCIA

# copiem els fitxers intocables del ca-valencia original al final
for i in "${forbidden_files[@]}"
do
    for j in `find $PATH_ORIGINAL_L10N_CA_VALENCIA -name $i`
	do
		cp "$j" "${j/$PATH_ORIGINAL_L10N_CA_VALENCIA/$PATH_FINAL_L10N_CA_VALENCIA}"
	done
done

# copia els fitxers de repo a la ubicacio final
cp -r $PATH_ORIGINAL_L10N_CA_VALENCIA/.hg $PATH_FINAL_L10N_CA_VALENCIA

# Crea fitxers PO catalans  a tmp
#-----------------------------------------
moz2po -t $PATH_FINAL_L10N_CA_VALENCIA -i $PATH_FINAL_L10N_CA_VALENCIA -o $L10NTMP -x "*.ftl" -x "*.properties" -x "*.js" -x "*.rdf" -x "*.inc" -x "*.txt" -x "*.mn" -x "README" -x "*.aff" -x "*.dic" -x "*.xml" -x "*.gif" -x "*.png" -x "*.css" -x "*.xhtml" -x "*.extra" -x "*.html" -x "*.ini"

# valencianitza els PO
cd $DIRECTORI_BASE/po
echo
echo Valencianitzant els PO...
./recorre_les_fonts-moz $L10NTMP
echo

#passa els PO de nou a format mozilla en ca-valencia
echo Insertant els PO adaptats en $PATH_FINAL_L10N_CA_VALENCIA...
po2moz -t $PATH_FINAL_L10N_CA_VALENCIA -i $L10NTMP -o $PATH_FINAL_L10N_CA_VALENCIA
echo

#copia els ftl i properties al TMP desres de netejarlo
rm -rf $L10NTMP/*
cd $PATH_FINAL_L10N_CA_VALENCIA
find . -name *.ftl -or -name *.properties -or -name *.ini | cpio -pdm $L10NTMP/

#adapta els ftl i properties
echo Valencianitzant els FTL i PROPERTIES...
cd $DIRECTORI_BASE/po
./recorre_les_fonts-moz-fluent $L10NTMP

echo Insertant els FTL i PROPERTIES adaptats en $PATH_FINAL_L10N_CA_VALENCIA...
cd $L10NTMP
find . -name *.ftl -or -name *.properties | cpio -pdm $PATH_FINAL_L10N_CA_VALENCIA

echo Adaptació finalitzada :\)
