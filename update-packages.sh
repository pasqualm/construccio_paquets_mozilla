#!/bin/bash

bad_arguments () {
	echo Has cridat l\'script passant un conjunt incorrecte de paremetres, la forma correcta de cridar-lo es:
	echo "update-packages.sh -r repositori -p firefox|thunderbird [-t tag_de_versio]"
	echo
	echo Exemples:
	echo	update-packages.sh -r beta -p thunderbird
	echo	update-packages.sh -r beta -p firefox
	echo	update-packages.sh -r esr38 -p thunderbird -t THUNDERBIRD_38_2_0_RELEASE
	echo	update-packages.sh -r esr45 -p thunderbird -t THUNDERBIRD_45_0_RELEASE
	echo	update-packages.sh -r esr38 -p firefox -t FIREFOX_38_2_1esr_RELEASE
	echo	update-packages.sh -r release -p firefox -t FIREFOX_40_0_3_RELEASE
	echo 
	echo Consultar repositoris disponibles en:
	echo   https://hg.mozilla.org/releases/mozilla-esr38/tags
	echo   https://hg.mozilla.org/releases/comm-esr38/tags
	echo   https://hg.mozilla.org/releases/comm-esr45/tags
	echo   https://hg.mozilla.org/releases/mozilla-release/tags
	echo
	echo Consultar els tags disponibles en el repositori que corresponga, per exemple:
	echo http://hg.mozilla.org/releases/l10n/mozilla-release/ca/tags 
	echo http://hg.mozilla.org/releases/l10n/mozilla-beta/ca/tags
	echo Si estem construint una versio beta els tags son opcionals
	exit -1
}  

# habilita el mode de debug
debug=false
if [ "$debug" == "true" ]; then
	set -x 
fi

while getopts ":r:p:t:" opt; do
  case $opt in
    r)
      VERSION=$OPTARG
      ;;
    p)
      PRODUCTE=$OPTARG
      ;;
    t)
      REPO_TAG=$OPTARG
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

# si no passem cap versio l'script no esta ben parametritzat
if [[ $VERSION == "" ]]; then
	bad_arguments
fi

# si no passem cap producte l'script no esta ben parametritzat
if [[ $PRODUCTE == "" ]]; then
	bad_arguments
fi

#si passem un producte que no es firefox o thunderbird l'script no esta ben parametritzat
if [[ $PRODUCTE != "firefox" ]] && [[ $PRODUCTE != "thunderbird" ]]; then
	if [[ $COMM_TAG == "" ]] || [[ $MOZILLA_TAG == "" ]]; then	
		bad_arguments
	fi 
fi

#si passem una versio o no es beta, l'escript ha d'incloure els tags correctes
if [[ $VERSION != "" ]] && [[ $VERSION != "beta" ]] && [[ $REPO_TAG == "" ]]; then
	bad_arguments
fi

# cre
OBJFF=`realpath $0 | xargs dirname`/mozobj

CC=gcc-4.7
CXX=g++-4.7
DATE=`date +%Y%m%d-%H%M`

if [ "$VERSION" == "beta" ]; then
	L10N_VERSION=beta
else
	L10N_VERSION=release
fi

OUTPATH=`realpath $0 | xargs dirname`/paquets_finals-$VERSION
mkdir -p $OUTPATH

# Obte les traduccions actuals de Mozilla
#-----------------------------------------
if [[ $PRODUCTE == "firefox" ]]; then
	rm -rf $OBJFF/firefox-valencia
	mkdir -p $OBJFF/firefox-valencia
	#mkdir -p $OBJFF/aragon-firefox-valencia
	#mkdir -p $OBJFF/seamonkey-valencia
	#if [ "$debug" != "true" ]; then
		cd mozilla-$VERSION
		#./mach mercurial-setup --update-only
		hg pull -u
		hg update --clean $REPO_TAG
		cd ..
	#fi
else
	rm -rf $OBJFF/thunderbird-valencia
	mkdir -p $OBJFF/thunderbird-valencia
	#if [ "$debug" != "true" ]; then
		cd comm-$VERSION
		#./mach mercurial-setup --update-only
		cd comm
		hg pull -u
		hg update --clean $REPO_TAG
		#python client.py checkout
		cd ../..
	#fi
fi

#actualitza els fitxers d'idioma per a que siguen els que corresponguen a la versio concreta de firefox
cd l10n/ca-$L10N_VERSION
hg pull -u
#hg update --clean $REPO_TAG
hg update --clean
cd ../..

# actualitza el repo de fitxers d'idioma en format ftl
cd l10n/ca-central
hg pull -u
#hg update --clean $REPO_TAG
hg update --clean
cd ../..

# Fa copia de seguretat i ho borra tot
#-----------------------------------------
rm -rf l10n/en-US
rm -rf po/ca
rm -rf po/ca-fluent

# Crea estructura  l10n/en-US
#----------------------------------------
if [[ $PRODUCTE == "firefox" ]]; then
	get_moz_enUS.py -s mozilla-$VERSION -d l10n -p browser
else
	get_moz_enUS.py -s comm-$VERSION -d l10n -p browser
fi
get_moz_enUS.py -s comm-$VERSION/comm -d l10n -p mail
get_moz_enUS.py -s comm-$VERSION/comm -d l10n -p calendar
#Patch irc
#mkdir -p l10n/en-US/extensions/irc
#cp -rf comm-$VERSION/mozilla/extensions/irc/locales/en-US/* l10n/en-US/extensions/irc

# Crea fitxers PO catalans  a po/ca
#-----------------------------------------
#mkdir -p po/ca
#moz2po -t l10n/en-US -i l10n/ca-$L10N_VERSION -o po/ca
moz2po -t l10n/en-US -i l10n/ca-central -o po/ca -x "*.ftl" -x "*.properties"
# no es pot utilitzar perque no funciona be, algunes coses no es passen el .po
#l20n2po -t l10n/en-US -i l10n/ca-central -o po/ca-fluent

# Update SVN
cd po
#svn up

#Copy ca-valencia
rm -rf ca-valencia
cp -rf ca ca-valencia
./recorre_les_fonts-moz ca-valencia

rm -rf ca-valencia-fluent
cd ../l10n/ca-central
find . -name *.ftl -or -name *.properties | cpio -pdm ../../po/ca-valencia-fluent/

cd ../../po
./recorre_les_fonts-moz-fluent ca-valencia-fluent
cd ..

rm -rf l10n/ca-valencia
po2moz -t l10n/en-US -i po/ca-valencia -o l10n/ca-valencia
#esborrem els .ftl.ftl, no serveixen per a res i no se que fan alli
#find l10n/ca-valencia -type f -name "*.ftl.ftl" -delete
#no es pot utilitzar perque per als ftl el mecanisme de conversio a po no va be
#po2l20n -t l10n/en-US -i po/ca-valencia-fluent -o l10n/ca-valencia
#copiem directament, hem fet l'adaptacio sobre els ftl directament
cp -rf po/ca-valencia-fluent/* l10n/ca-valencia


#cp -rf l10n/ca-$L10N_VERSION/browser/searchplugins/* l10n/ca-valencia/browser/searchplugins
#cp -rf l10n/ca-$L10N_VERSION/mail/searchplugins/* l10n/ca-valencia/mail/searchplugins

#cp -rf l10n/ca-$L10N_VERSION/suite/searchplugins l10n/ca-valencia/browser
#cp -rf l10n/ca-$L10N_VERSION/mail/searchplugins l10n/ca-valencia/mail

#Process files
perl po/processMozFile.pl l10n/ca-valencia/browser/chrome/browser/browser.dtd dtd savePageCmd.accesskey2 "d"
perl po/processMozFile.pl l10n/ca-valencia/toolkit/chrome/global/intl.properties props general.useragent.locale "ca-valencia"
perl po/processMozFile.pl l10n/ca-valencia/toolkit/chrome/global/intl.properties props intl.accept_languages "ca-valencia, ca, en-us, en"
perl po/processMozFile.pl l10n/ca-valencia/toolkit/defines.inc define MOZ_LANG_TITLE "Català (valencià)"

#
sed -i s~MOZ_OBJDIR=.*~MOZ_OBJDIR=$OBJFF/firefox-valencia~ po/mozilla/mozconfig-firefox 
sed -i s~with-l10n-base=.*~with-l10n-base=`pwd`\/l10n~ po/mozilla/mozconfig-firefox 
sed -i s~MOZ_OBJDIR=.*~MOZ_OBJDIR=$OBJFF/thunderbird-valencia~ po/mozilla/mozconfig-thunderbird 
sed -i s~with-l10n-base=.*~with-l10n-base=`pwd`\/l10n~ po/mozilla/mozconfig-thunderbird 
#sed -i s~MOZ_OBJDIR=.*~MOZ_OBJDIR=$OBJFF/aragon-firefox-valencia~ po/mozilla/mozconfig-aragon-firefox
#sed -i s~with-l10n-base=.*~with-l10n-base=`pwd`\/l10n~ po/mozilla/mozconfig-aragon-firefox
#sed -i s~MOZ_OBJDIR=.*~MOZ_OBJDIR=$OBJFF/seamonkey-valencia~ po/mozilla/mozconfig-seamonkey
#sed -i s~with-l10n-base=.*~with-l10n-base=`pwd`\/l10n~ po/mozilla/mozconfig-seamonkey

cp -f po/mozilla/mozconfig-firefox mozilla-$VERSION/.mozconfig
cp -f po/mozilla/mozconfig-thunderbird comm-$VERSION/.mozconfig
base=`pwd` 
#workaround perque el make -f ../../mozilla-$VERSION/client.mk no es queixe
#export MACH=true

if [[ $PRODUCTE == "firefox" ]]; then
	#####################################################################################
	# fase de creacio de la extensio de firefox 
	echo
	echo Fent make de Firefox
	cd $OBJFF/firefox-valencia
	#make -f ../../mozilla-$VERSION/client.mk configure
	../../mozilla-$VERSION/mach configure
	cd config
	make

	echo
	echo Fent make de langpacks de Firefox
	cd ../browser/locales
	make merge-ca-valencia LOCALE_MERGEDIR=./mergedir
	make langpack-ca-valencia LOCALE_MERGEDIR=./mergedir

	cd $base
	LASTFFXPI=`ls -lrt $OBJFF/firefox-valencia/dist/linux-x86_64/xpi | awk '{ f=$NF }; END{ print f }'`
	zip -d $LASTTBXPI browser/chrome/ca-valencia/locale/browser/searchplugins 

	LASTFFXPIOUT=$LASTFFXPI.$DATE.xpi
	perl po/modifyMaxMin.pl $OBJFF/firefox-valencia/dist/linux-x86_64/xpi/$LASTFFXPI
	cd $OBJFF/firefox-valencia/dist/linux-x86_64/xpi
	rm -rf tmp
	mkdir tmp
	cp $LASTFFXPI tmp
	cd tmp
	unzip -q $LASTFFXPI
	find . -name ".mkdir.done" -exec rm -rf {} \;
	rm -rf browser/crashreporter-override.ini
	rm -rf browser/defaults
	rm -rf browser/searchplugins
	rm -f browser/chrome/ca-valencia/locale/browser/searchplugins/amazondotcom.xml browser/chrome/ca-valencia/locale/browser/searchplugins/wikipedia.xml browser/chrome/ca-valencia/locale/browser/searchplugins/yahoo.xml

	cp -rf $base/l10n/ca-$L10N_VERSION/suite/searchplugins/* browser/chrome/ca-valencia/locale/browser/searchplugins
	cp -rf $base/llibres.xml browser/chrome/ca-valencia/locale/browser/searchplugins
	
	echo "{\"default\": {\"visibleDefaultEngines\": [\"google\", \"bing\", \"diec2\", \"ddg\", \"twitter\", \"wikipedia-ca\", \"llibres\"]}}" >browser/chrome/ca-valencia/locale/browser/searchplugins/list.json
	rm $LASTFFXPI
	# reanomena l'id de l'extensio, no esta funcionant be
	#if [[ $VERSION != "release" ]] && [[ $VERSION != "beta" ]]; then
	#	sed -i "s~{ec8030f7-c20a-464f-9b0e-13a3a9e97384}~firefoxESRvalencia@softvalencia.org~" chrome.manifest
	#	sed -i "s~{ec8030f7-c20a-464f-9b0e-13a3a9e97384}~firefoxESRvalencia@softvalencia.org~" install.rdf
	#fi
	zip -q -r $LASTFFXPI chrome.manifest install.rdf browser chrome localization manifest.json
	cp $LASTFFXPI $OUTPATH/$LASTFFXPIOUT
	#####################################################################################
else
	#####################################################################################
	# fase de creacio de la extensio de thunderbird 
	echo 	
	echo Adaptant fitxers l10n.toml perque reconeguen ca-valencia com a locale valid
	if ! grep -q ca-valencia "comm-$VERSION/comm/calendar/locales/l10n.toml"; then
  		cp "comm-$VERSION/comm/calendar/locales/l10n.toml" "comm-$VERSION/comm/calendar/locales/l10n.toml.orig"
		sed -i 's~locales = \[~locales = \["ca-valencia",~' "comm-$VERSION/comm/calendar/locales/l10n.toml"
	fi
	if ! grep -q ca-valencia "comm-$VERSION/comm/mail/locales/l10n.toml"; then
  		cp "comm-$VERSION/comm/mail/locales/l10n.toml" "comm-$VERSION/comm/mail/locales/l10n.toml.orig"
		sed -i 's~locales = \[~locales = \["ca-valencia",~' "comm-$VERSION/comm/mail/locales/l10n.toml"
	fi
	echo 
	echo Fent make de Thunderbird
	cd $OBJFF/thunderbird-valencia
	#make -f ../../comm-$VERSION/client.mk configure
	../../comm-$VERSION/mach configure
	cd config
	make
	#read -p "Press [Enter] key to continue ..."
		
	echo
	echo Fent make de langpacks de Thunderbird
	cd ../comm/mail/locales
	make merge-ca-valencia LOCALE_MERGEDIR=./mergedir
	make langpack-ca-valencia LOCALE_MERGEDIR=./mergedir
	# intente fer que es construisca tambe el calendari
	#make calendar-merge-ca-valencia LOCALE_MERGEDIR=./mergedir
	#make calendar-langpack-ca-valencia LOCALE_MERGEDIR=./mergedir
	#read -p "Press [Enter] key to continue ..."

	cd $base
	LASTTBXPI=`ls -lrt $OBJFF/thunderbird-valencia/dist/linux-x86_64/xpi | awk '{ f=$NF }; END{ print f }'`	
	LASTTBXPIOUT=$LASTTBXPI.$DATE.xpi
	#perl po/modifyMaxMin.pl $OBJFF/thunderbird-valencia/dist/linux-x86_64/xpi/$LASTTBXPI
	cd $OBJFF/thunderbird-valencia/dist/linux-x86_64/xpi
	rm -rf tmp
	mkdir tmp
	cp $LASTTBXPI tmp
	cd tmp
	unzip -q $LASTTBXPI
	find . -name ".mkdir.done" -exec rm -rf {} \;
	rm -rf mail/crashreporter-override.ini
	rm -rf mail/defaults
	rm -rf mail/searchplugins
	rm $LASTTBXPI
	zip -q -r $LASTTBXPI chrome.manifest install.rdf mail chrome localization manifest.json
	cp $LASTTBXPI $OUTPATH/$LASTTBXPIOUT
	#####################################################################################
fi

echo Construccio finalitzada :\)
