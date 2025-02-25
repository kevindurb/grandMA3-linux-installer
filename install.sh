#!/bin/sh
set -e

unzip -o $1 -d /tmp/grandMA3

pushd .
cd /tmp/grandMA3/ma/

RELEASEFILE=$(ls ./release_stick_*.xml | head -1)
FULLVERSION=$(xmllint -xpath '//GMA3/ReleaseFile/Version/text()' $RELEASEFILE)
VERSION="${FULLVERSION%.*}"

echo "RELEASEFILE: $RELEASEFILE"
echo "FULLVERSION: $FULLVERSION"
echo "VERSION: $VERSION"

### Unzip MA files in $HOME/MALightingTechnology directory ###
xmllint -xpath '//GMA3/ReleaseFile/MAPacket[not(contains(@Type, "sys")) and not(contains(@Type, "arm")) and not(contains(@Type, "gma2"))]/@Destination' $RELEASEFILE | sed "s/ Destination=/mkdir -p /" | sed "s|/home/ma|$HOME|" | sh
xmllint -xpath '//GMA3/ReleaseFile/MAPacket[not(contains(@Type, "sys")) and not(contains(@Type, "arm")) and not(contains(@Type, "gma2"))]/@*[name()="Name" or name()="Destination"]' $RELEASEFILE | sed "s/ Destination=/ -d /" | tr -d "\n" | sed "s/ Name=/\nunzip -o /g" | sed "s|/home/ma|$HOME|" | sh
popd

mkdir -p $HOME/.local/share/applications
mkdir -p $HOME/.local/share/gma3
mkdir -p $HOME/.local/bin

echo "#!/bin/sh
LD_LIBRARY_PATH=$HOME/MALightingTechnology/gma3_$VERSION/shared/third_party $HOME/MALightingTechnology/gma3_$VERSION/console/bin/app_gma3 HOSTTYPE=onPC" > $HOME/.local/bin/gma3
chmod +x $HOME/.local/bin/gma3
cp gma3.ico $HOME/.local/share/gma3/gma3.ico
echo "[Desktop Entry]
Type=Application
Terminal=true
Name=GrandMA3
Icon=$HOME/.local/share/gma3/gma3.ico
Exec=$HOME/.local/bin/gma3
" > $HOME/.local/share/applications/gma3.desktop
