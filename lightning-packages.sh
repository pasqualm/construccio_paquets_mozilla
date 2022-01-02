#!/bin/bash

bad_arguments () {
	echo Has cridat l\'script passant un conjunt incorrecte de paremetres, la forma correcta de cridar-lo es:
	echo "lightning-packages.sh -c releases|candidates|nightly [-v ftp_folder"]
	echo
	echo Exemples:
	echo	lightning-packages.sh -c releases
	echo	lightning-packages.sh -c candidates -v 4.3b1-candidates
	echo	lightning-packages.sh -c nightly -v latest-comm-central
	echo 
	echo L''script afegira el locale ca-valencia al paquets que trobe en la ruta: 
	echo http://ftp.mozilla.org/pub/calendar/lightning/$releases/$ftp_folder
	echo 
	echo Aquest script s''ha d''executar posterioment a l''execucio de l''script de construccio del paquet de thunderbird ja que 
	echo aquest preparen les cadenes de text que despres aquest script injecta
	exit -1
}  

# habilita el mode de debug
debug=true
if [ "$debug" == "true" ]; then
	set -x 
fi

while getopts ":c:v:" opt; do
  case $opt in
    c)
      CHANNEL=$OPTARG
      ;;
    v)
      FTP_FOLDER=$OPTARG
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
if [[ $CHANNEL == "" ]]; then
	bad_arguments
fi

# si no passem cap versio l'script no esta ben parametritzat
if [[ $FTP_FOLDER == "" ]] && [[ $CHANNEL != "releases" ]]; then
	bad_arguments
fi
# si no passem cap producte l'script no esta ben parametritzat
if [[ $CHANNEL != "releases" ]] && [[ $CHANNEL != "candidates" ]] &&[[ $CHANNEL != "nightly" ]]; then
	bad_arguments
fi

# cre
OBJFF=`realpath $0 | xargs dirname`/mozobj

CC=gcc-4.7
CXX=g++-4.7
DATE=`date +%Y%m%d-%H%M`
release_version=esr45

# Obte els paquets de lightning
#-----------------------------------------
rm -rf $OBJFF/lightning-valencia
mkdir -p $OBJFF/lightning-valencia

#descarrega els paquets de lighting als que anem a ficar la nova locale
case $CHANNEL in
	releases)
		#echo Fent ftp de http://ftp.mozilla.org/pub/calendar/lightning/$CHANNEL/$FTP_FOLDER
		#wget http://ftp.mozilla.org/pub/calendar/lightning/$CHANNEL/$FTP_FOLDER/linux/lightning.xpi -O $OBJFF/lightning-valencia/lightning_linux.xpi
		#wget http://ftp.mozilla.org/pub/calendar/lightning/$CHANNEL/$FTP_FOLDER/mac/lightning.xpi -O $OBJFF/lightning-valencia/lightning_mac.xpi
		#wget http://ftp.mozilla.org/pub/calendar/lightning/$CHANNEL/$FTP_FOLDER/win32/lightning.xpi -O $OBJFF/lightning-valencia/lightning_win32.xpi
		echo Fent ftp de latest release
		wget https://addons.mozilla.org/thunderbird/downloads/latest/2313/platform:2/addon-2313-latest.xpi?src=dp-btn-primary -O $OBJFF/lightning-valencia/lightning_linux.xpi
		wget https://addons.mozilla.org/thunderbird/downloads/latest/2313/platform:3/addon-2313-latest.xpi?src=dp-btn-primary -O $OBJFF/lightning-valencia/lightning_mac.xpi
		wget https://addons.mozilla.org/thunderbird/downloads/latest/2313/platform:5/addon-2313-latest.xpi?src=dp-btn-primary -O $OBJFF/lightning-valencia/lightning_win32.xpi
		FTP_FOLDER=latest
		OUTPATH=`realpath $0 | xargs dirname`/paquets_finals-$release_version
		mkdir -p $OUTPATH
		;;
	candidates)
		echo Fent ftp de http://ftp.mozilla.org/pub/calendar/lightning/$CHANNEL/$FTP_FOLDER/build1
		wget --no-parent -r -A 'lightning*.xpi' http://ftp.mozilla.org/pub/calendar/lightning/$CHANNEL/$FTP_FOLDER/build1/linux-i686/
		wget --no-parent -r -A 'lightning*.xpi' http://ftp.mozilla.org/pub/calendar/lightning/$CHANNEL/$FTP_FOLDER/build1/mac/
		wget --no-parent -r -A 'lightning*.xpi' http://ftp.mozilla.org/pub/calendar/lightning/$CHANNEL/$FTP_FOLDER/build1/win32/
		mv ftp.mozilla.org/pub/calendar/lightning/$CHANNEL/$FTP_FOLDER/build1/linux-i686/lightning-*.linux-i686.xpi $OBJFF/lightning-valencia/lightning_linux.xpi
		mv ftp.mozilla.org/pub/calendar/lightning/$CHANNEL/$FTP_FOLDER/build1/mac/lightning-*.mac.xpi $OBJFF/lightning-valencia/lightning_mac.xpi
		mv ftp.mozilla.org/pub/calendar/lightning/$CHANNEL/$FTP_FOLDER/build1/win32/lightning-*.win32.xpi $OBJFF/lightning-valencia/lightning_win32.xpi
		rm -rf ftp.mozilla.org
		OUTPATH=`realpath $0 | xargs dirname`/paquets_finals-beta
		mkdir -p $OUTPATH
		;;
	nightly)
		echo Fent ftp de http://ftp.mozilla.org/pub/calendar/lightning/$CHANNEL/$FTP_FOLDER/
		wget --no-parent -r -A 'lightning*.xpi' http://ftp.mozilla.org/pub/calendar/lightning/$CHANNEL/$FTP_FOLDER/
		mv ftp.mozilla.org/pub/calendar/lightning/$CHANNEL/$FTP_FOLDER/lightning-*.linux-i686.xpi $OBJFF/lightning-valencia/lightning_linux.xpi
		mv ftp.mozilla.org/pub/calendar/lightning/$CHANNEL/$FTP_FOLDER/lightning-*.mac.xpi $OBJFF/lightning-valencia/lightning_mac.xpi
		mv ftp.mozilla.org/pub/calendar/lightning/$CHANNEL/$FTP_FOLDER/lightning-*.win32.xpi $OBJFF/lightning-valencia/lightning_win32.xpi
		rm -rf ftp.mozilla.org
		OUTPATH=`realpath $0 | xargs dirname`/paquets_finals-beta
		mkdir -p $OUTPATH
		;;
	*)
	  echo "Error: Versio no suportada." >&2
	  exit 1
	  ;;
esac

#crea l'estructura de directori necessari per fer l'agregacio de locale
rm -rf chrome chrome.manifest
mkdir -p chrome/calendar-ca-valencia/locale/ca-valencia/calendar chrome/lightning-ca-valencia/locale/ca-valencia/lightning

#copia els fitxers de llegua a una ubicacio es pecial per fer l'agregacio de locale
cp -r l10n/ca-valencia/calendar/chrome/calendar/* chrome/calendar-ca-valencia/locale/ca-valencia/calendar
cp -r l10n/ca-valencia/calendar/chrome/lightning/* chrome/lightning-ca-valencia/locale/ca-valencia/lightning

# fica dins dels paquets la nova locale
zip -r -q $OBJFF/lightning-valencia/lightning_linux.xpi chrome/calendar-ca-valencia
zip -r -q $OBJFF/lightning-valencia/lightning_linux.xpi chrome/lightning-ca-valencia
zip -r -q $OBJFF/lightning-valencia/lightning_mac.xpi chrome/calendar-ca-valencia
zip -r -q $OBJFF/lightning-valencia/lightning_mac.xpi chrome/lightning-ca-valencia
zip -r -q $OBJFF/lightning-valencia/lightning_win32.xpi chrome/calendar-ca-valencia
zip -r -q $OBJFF/lightning-valencia/lightning_win32.xpi chrome/lightning-ca-valencia

#configura el paquet per poder treballar amb el nou locale
unzip -q -o $OBJFF/lightning-valencia/lightning_linux.xpi chrome.manifest
sed -i "s~locale calendar en-US chrome/calendar-en-US/locale/en-US/calendar/~locale calendar en-US chrome/calendar-en-US/locale/en-US/calendar/\nlocale calendar ca-valencia chrome/calendar-ca-valencia/locale/ca-valencia/calendar/~" chrome.manifest
sed -i "s~locale lightning en-US chrome/lightning-en-US/locale/en-US/lightning/~locale lightning en-US chrome/lightning-en-US/locale/en-US/lightning/\nlocale lightning ca-valencia chrome/lightning-ca-valencia/locale/ca-valencia/lightning/~" chrome.manifest
zip -q $OBJFF/lightning-valencia/lightning_linux.xpi chrome.manifest
unzip -q -o $OBJFF/lightning-valencia/lightning_mac.xpi chrome.manifest
sed -i "s~locale calendar en-US chrome/calendar-en-US/locale/en-US/calendar/~locale calendar en-US chrome/calendar-en-US/locale/en-US/calendar/\nlocale calendar ca-valencia chrome/calendar-ca-valencia/locale/ca-valencia/calendar/~" chrome.manifest
sed -i "s~locale lightning en-US chrome/lightning-en-US/locale/en-US/lightning/~locale lightning en-US chrome/lightning-en-US/locale/en-US/lightning/\nlocale lightning ca-valencia chrome/lightning-ca-valencia/locale/ca-valencia/lightning/~" chrome.manifest
zip -q $OBJFF/lightning-valencia/lightning_mac.xpi chrome.manifest
unzip -q -o $OBJFF/lightning-valencia/lightning_win32.xpi chrome.manifest
sed -i "s~locale calendar en-US chrome/calendar-en-US/locale/en-US/calendar/~locale calendar en-US chrome/calendar-en-US/locale/en-US/calendar/\nlocale calendar ca-valencia chrome/calendar-ca-valencia/locale/ca-valencia/calendar/~" chrome.manifest
sed -i "s~locale lightning en-US chrome/lightning-en-US/locale/en-US/lightning/~locale lightning en-US chrome/lightning-en-US/locale/en-US/lightning/\nlocale lightning ca-valencia chrome/lightning-ca-valencia/locale/ca-valencia/lightning/~" chrome.manifest
zip -q $OBJFF/lightning-valencia/lightning_win32.xpi chrome.manifest

#esborra fitxers temporals 
rm -rf chrome chrome.manifest

#mou paquets construits a la seua ubicacio final
my_datetime=`date +"%Y%m%d-%H%M"`
mv $OBJFF/lightning-valencia/lightning_linux.xpi $OUTPATH/lightning_linux-$FTP_FOLDER-$CHANNEL.$my_datetime.xpi
ln -f -s $OUTPATH/lightning_linux-$FTP_FOLDER-$CHANNEL.$my_datetime.xpi $OUTPATH/lightning_linux-ca-valencia-latest.xpi
mv $OBJFF/lightning-valencia/lightning_mac.xpi $OUTPATH/lightning_mac-$FTP_FOLDER-$CHANNEL.$my_datetime.xpi
ln -f -s $OUTPATH/lightning_mac-$FTP_FOLDER-$CHANNEL.$my_datetime.xpi $OUTPATH/lightning_mac-ca-valencia-latest.xpi
mv $OBJFF/lightning-valencia/lightning_win32.xpi $OUTPATH/lightning_win32-$FTP_FOLDER-$CHANNEL.$my_datetime.xpi
ln -f -s $OUTPATH/lightning_win32-$FTP_FOLDER-$CHANNEL.$my_datetime.xpi $OUTPATH/lightning_win32-ca-valencia-latest.xpi

echo Construccio finalitzada :\)
