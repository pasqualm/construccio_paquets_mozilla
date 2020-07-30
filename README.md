Scripts per a generar paquets d'idioma del Firefox i del Thunderbird a partir dels repositoris de Mozilla

* inicialitza_carpetes.sh - Inicialitza el directori creant totes les carpetes que fan falta, baixant el fitxers que corresponga i inicialitzant els repositoris, requereix que li passes el nom del repositori del que faras el clone (ara mateix: esr38, release o beta)
* update-packages.sh - Genera el paquet per al producte que toque, amb els arguments es parametritza el repositori que es gasta, el producte i el tag de versio

* lightning-packages.sh - Genera el paquest de lightning amb el locale ca-valencia a partir dels xpi que estan en el servidor ftp de Mozilla, requereix que abans de la seua execucio, l'script update-packages.sh haja deixat preparades les locales

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

per a que l'script funcione poden fer paquets addicionals en el sistema:
perl-Encode-Detect
perl-Archive-Zip
autoconf213
gtk2-devel
GConf2-devel
dbus-glib-devel
yasm
alsa-lib-devel
libXt-devel
cbindgen
gcc-c++
rustc
rustfmt
llvm
llvm-devel
clang
clang-devel
nodejs
gtk3-devel
translate-toolkit
nasm

També pot fer falta tindre instal·lat aquests paquets de python:
sudo pip3 install -U compare-locales
sudo pip3 install -U fluent

i el cbindgen aixi (si el de la distro es massa vell):
cargo install cbindgen --force

el cbindgen es pot actualitzar amb:
cargo install cargo-update
cargo install-update -a

# per veure les diferecies de fitxers
hg status

# per agregar un nou fitxer al repo 
hg add browser/browser/fxaDisconnect.ft

# per llevar fitxer del repo 
hg ¿¿???

# per afegir i llevar tots
hg addremove

# per veure el contingut de les diferencies 
hg diff -g

Per a fer un nou patch
hg qnew -m "Bug 1632904 - Manual update for repo ca-valencia in l10n-central." 1632904.patch
hg qpop -a

# per buscar errors amb compare-locales:
compare-locales ./gecko-strings/_configs/browser.toml ./l10n-central ca-valencia | less

Per fets commits manuls utilitzat aquest commit message:
Manual update for repo ca-valencia in l10n-central

Per que el hg push funcione cal ficar aquesta linia en el .hg/hgrc en la seccio paths:
default-push = ssh://hg.mozilla.org/l10n-central/ca-valencia

i fer un hg push
