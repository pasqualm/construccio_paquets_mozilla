Scripts per a generar paquets d'idioma del Firefox i del Thunderbird a partir dels repositoris de Mozilla

* inicialitza_carpetes.sh - Inicialitza el directori creant totes les carpetes que fan falta, baixant el fitxers que corresponga i inicialitzant els repositoris, requereix
							que li passes el nom del repositori del que faras el clone (ara mateix: esr38, release o beta)
* update-packages.sh - Genera el paquet per al producte que toque, amb els arguments es parametritza el repositori que es gasta, el producte i el tag de versio

* lightning-packages.sh - Genera el paquest de lightning amb el locale ca-valencia a partir dels xpi que estan en el servidor ftp de Mozilla, requereix que abans de la seua
						  execucio, l'script update-packages.sh haja deixat preparades les locales

El directori po/mozilla conté els fitxers .mozconfig segons els programa

Cal tenir translate-tookit: pip install translate-toolkit

Cal tindre l'script get_moz_enUS.py (https://github.com/translate/translate/blob/master/tools/mozilla/get_moz_enUS.py), l'script inicialitza_carpetes.sh el baixa automaticament

Per tal de funcionar calen els directoris (els crea i inicialitza l'script inicialitza_carpetes.sh):

* mozilla-$reponame: amb codi arrel de la branca que corrsponga 
		https://hg.mozilla.org/releases/mozilla-beta/
		https://hg.mozilla.org/releases/mozilla-esr38/
		https://hg.mozilla.org/releases/mozilla-release/
* comm-$reponame: amb codi arrel de branca que corresponga
		https://hg.mozilla.org/releases/comm-beta/
		https://hg.mozilla.org/releases/comm-esr38/
		https://hg.mozilla.org/releases/comm-release/
* l10n
  * ca-$reponame: 
		http://hg.mozilla.org/releases/l10n/mozilla-beta/ca/
		http://hg.mozilla.org/releases/l10n/mozilla-release/ca/
		
  * en-US: generat per l'script
  * ca-valencia: generat per l'script

Cal tenir en el directori po que es genera els fitxers:
* processMozFile.pl
* modifyMaxMin.pl

i els fitxers del repositori https://github.com/Softcatala/adaptadorvariants/tree/master/tools/mozilla (els descarrega el inicialitza_carpetes.sh)
* recorre_les_fonts-moz
* src2valencia-moz.sed

per a que l'script funcione poden fer paquets addicionals en el sistema, per exemple en el cas d'un CentOS 7:
perl-Encode-Detect-1.01-13.el7.x86_64
perl-Archive-Zip-1.30-11.el7.noarch
autoconf213
gtk2-devel
gconf2-devel
dbus-glib-devel
yasm
alsa-lib-devel
libXt-devel

També pot fer falta tindre instal·lat aquest paquet de python:
easy_install compare-locales
