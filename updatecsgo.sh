#!/usr/bin/env bash

serverAPPid="740"

gamePath1="csgo"

gamePath2="csgo"

RNAME="hlserver"

# Game switcher for War3Source-EVO compiling
# either CSS or CSGO or TF2 or FOF
GAME_SWITCHER="CSGO"

# example /home/steamgameserver
# CPATH actually will install in what ever directory you start this script in,
# not really your home path, otherwise you can change $PWD to $HOME
# if you prefer the home path.
CPATH=$PWD

# spaceREQ
# CSGO 35
# TF2 10
# CSS 3
# FOF 4

#spaceREQ=35
#HDspace=$(df --output=avail -h ${CPATH} | sed '1d;s/[^0-9]//g')

#if [[ $HDspace -le $spaceREQ ]]; then
#     echo "You will need at least ${spaceREQ}GB of hard drive space before installing ${GAME_SWITCHER}!"
#     echo "You only have ${HDspace}GB hard drive free space on ${CPATH}"
#     df -h
#     exit
#fi

# example /home/steamgameserver/hlserver
installPath="$CPATH/$RNAME"

# example /home/steamgameserver/hlserver/steamcmd/css.txt
steamcmdFile="${installPath}/steamcmd/${gamePath1}.txt"

# example /home/steamgameserver/hlserver/css
gameInstallPath="${installPath}/${gamePath1}"

# example /home/steamgameserver/hlserver/css/cstrike
SourceMetaModWar3InstallPath="${gameInstallPath}/${gamePath2}"

echo '*************************************************************************'
echo '*'
echo '* WAR3SOURCE-EVO UPDATER ONLY'
echo '*'
echo 'Just hit enter key for defaults, unless you want to change them.'
echo 'Defaults will be surrounded by () unless it says (required)'
echo
echo 'What directory would you like to install in?'
echo
echo "SteamCMD Directory is ${installPath}"
echo "${GAME_SWITCHER} Game Directory is ${gameInstallPath}"
echo "Sourcemod/MetaMod/War3Source Directory is ${SourceMetaModWar3InstallPath}"
echo
echo "Should be the same directory you first used the installcsgo.sh script in"
echo
read -p "[${GAME_SWITCHER}] Install Directory ($installPath)" readInstallPath
if [[ "$readInstallPath" ]]; then
    $installPath = $readInstallPath
fi

# remove old War3Source plugin files
#rm -v "${SourceMetaModWar3InstallPath}/addons/plugins/War3Source*.smx"
#read -p "Press ENTER to continue" readTMP

date=$(date '+%m-%d-%Y')

# Backup Files if exists
test -e "${CPATH}/War3Source-EVO" && cp -vrf "${CPATH}/War3Source-EVO" "${CPATH}/War3Source-EVO-Backup-${date}"
test -e "${CPATH}/War3Source-EVO" && read -p "Press ENTER to continue" readTMP

# Remove old files
test -e "${CPATH}/War3Source-EVO" && rm -rf "${CPATH}/War3Source-EVO"

# git clone War3Source
git clone https://github.com/War3Evo/War3Source-EVO.git

# Copy possible new sounds
cp -rf "${CPATH}/War3Source-EVO/sound" "${SourceMetaModWar3InstallPath}"

# Get SourceMod 1.9 Required to compile War3Source-EVO
wget "http://www.sourcemod.net/latest.php?version=1.9&os=linux" -O "${CPATH}/War3Source-EVO/sourcemod-1.9-linux.tar.gz"
tar -zxvf "${CPATH}/War3Source-EVO/sourcemod-1.9-linux.tar.gz" --directory "${CPATH}/War3Source-EVO"

# Extract SourceMod as List
tar --list -f "${CPATH}/War3Source-EVO/sourcemod-1.9-linux.tar.gz" > "${CPATH}/War3Source-EVO/smlist19.txt"
#
# Give spcomp the required permissions
chmod a+x "${CPATH}/War3Source-EVO/addons/sourcemod/scripting/spcomp_1.9.0.6261"
chmod a+x "${CPATH}/War3Source-EVO/addons/sourcemod/scripting/game_switcher_${GAME_SWITCHER}.sh"
chmod a+x "${CPATH}/War3Source-EVO/addons/sourcemod/scripting/compile_for_github_action.sh"
bash -c "${CPATH}/War3Source-EVO/addons/sourcemod/scripting/game_switcher_${GAME_SWITCHER}.sh"
bash -c "${CPATH}/War3Source-EVO/addons/sourcemod/scripting/compile_for_github_action.sh" || true
# uncomment below if you want to stop at this point
echo "Compiled."
#read -p "Press ENTER to continue" readTMP

# Backup Files
cp -vrf "${SourceMetaModWar3InstallPath}/addons/sourcemod/plugins" "${SourceMetaModWar3InstallPath}/addons/sourcemod/pluginsbackup-${date}"
#echo "Backed up ${SourceMetaModWar3InstallPath}/addons/sourcemod/plugins to ${SourceMetaModWar3InstallPath}/addons/sourcemod/pluginsbackup-${date}"
read -p "Press ENTER to continue" readTMP

# Copy Compiled plugins
cp -vrf "${CPATH}/War3Source-EVO/addons/sourcemod/plugins" "${SourceMetaModWar3InstallPath}/addons/sourcemod"
read -p "Press ENTER to continue" readTMP

# Clean up & Remove SM 1.9
xargs rm -f < "${CPATH}/War3Source-EVO/smlist19.txt" || true

# GIT update information
currentPTH=$PWD
test -e "${CPATH}/War3Source-EVO" && cd "${CPATH}/War3Source-EVO/"
test -e "${CPATH}/War3Source-EVO" && git --no-pager log --since='Feb 28 2023'
test -e "${CPATH}/War3Source-EVO" && cd "${currentPTH}"
echo ""
echo "Always remember to check https://github.com/War3Evo/War3Source-EVO to see"
echo
echo "SCROLL UP for changes information"

# after git log delete git
test -e "${CPATH}/.github" && rm -rf "${CPATH}/War3Source-EVO/.github"
test -e "${CPATH}/War3Source-EVO/.git" && rm -rf "${CPATH}/War3Source-EVO/.git"
rm -rf "${CPATH}/War3Source-EVO"

echo UPDATE COMPLETED
