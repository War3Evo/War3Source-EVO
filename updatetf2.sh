#!/usr/bin/env bash

# ***********************************
# OPTIONS
#
# true or false
update_steam_server=true

# true or false
update_metamod=true

# true or false
update_sourcemod=true

# true or false
update_war3source_evo=true

# latest known stable version 1.11
metaversion="1.11"

# latest known stable version 1.11
sourcemodversion="1.11"

# ***********************************
# ***********************************
# DO NOT CHANGE BELOW THIS LINE
# DO NOT CHANGE BELOW THIS LINE
# DO NOT CHANGE BELOW THIS LINE
# DO NOT CHANGE BELOW THIS LINE
# DO NOT CHANGE BELOW THIS LINE
# ***********************************
# ***********************************

# developer varaible
# false allows me to see the git log only
update_war3=true

# branch of War3Source-EVO
git_branch="master"

todayDate=$(date +"%b %d %Y")
startTime="'Feb 28 2023'"
updateDate="'Feb 28 2023'"

test -e "time_start_do_not.delete" && startTime=$(cat time_start_do_not.delete)
if [[ $todayDate == $startTime ]]; then
	startTime="'Feb 28 2023'"
	updateDate="'Feb 28 2023'"
else
	updateDate="${startTime}"
fi

# overwrite file with new date every time the script runs
date +"%b %d %Y" > time_start_do_not.delete

gamePath1="tf2"

gamePath2="tf"

RNAME="hlserver"

# Game switcher for War3Source-EVO compiling
# either CSS or CSGO or TF2 or FOF
GAME_SWITCHER="TF2"

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
echo 'You can change these options in the updatecss.sh top of file'
echo 'by changing the words from true to false or false to true'
echo '*'
if $update_steam_server; then
    echo '* STEAM SERVER UPDATER'    
fi
if $update_metamod; then
    echo '* METAMOD UPDATER'    
fi
if $update_sourcemod; then
    echo '* SOURCEMOD UPDATER'    
fi
if $update_war3source_evo; then
    echo '* WAR3SOURCE-EVO UPDATER'    
fi
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
echo "Should be the same directory you first used the installtf2.sh script in"
echo
read -p "[${GAME_SWITCHER}] Install Directory ($installPath)" readInstallPath
if [[ "$readInstallPath" ]]; then
    $installPath = $readInstallPath
fi

if $update_steam_server; then
    # Give Permissions
    SCRIPT_PATH="${installPath}/steamcmd.sh"
    chmod a+x "${SCRIPT_PATH}"

    # UPDATE STEAM SERVER
    SCRIPT_RUN="${SCRIPT_PATH} +runscript ${steamcmdFile}"
    bash -c "${SCRIPT_RUN}"
fi

if $update_metamod; then
    # remove old metamod file
    rm -f 'metamod*'
    # Download MetaMod
    wget "https://www.metamodsource.net/latest.php?version=${metaversion}&os=linux" -O "metamod-${metaversion}-linux.tar.gz"

    # Extract Metamod
    tar --overwrite -zxvf "metamod-${metaversion}-linux.tar.gz" "addons/metamod/bin/" --directory "${SourceMetaModWar3InstallPath}"
fi

if $update_sourcemod; then
    # remove old sourcemod file
    rm -f 'sourcemod*'

    # Download SourceMod
    wget "http://www.sourcemod.net/latest.php?version=${sourcemodversion}&os=linux" -O "sourcemod-${sourcemodversion}-linux.tar.gz"

    # Extract SourceMod
    tar --overwrite -zxvf "sourcemod-${sourcemodversion}-linux.tar.gz" "addons/sourcemod/bin/" --directory "${SourceMetaModWar3InstallPath}"
    tar --overwrite -zxvf "sourcemod-${sourcemodversion}-linux.tar.gz" "addons/sourcemod/extensions/" --directory "${SourceMetaModWar3InstallPath}"
    tar --overwrite -zxvf "sourcemod-${sourcemodversion}-linux.tar.gz" "addons/sourcemod/gamedata/" --directory "${SourceMetaModWar3InstallPath}"
fi

if $update_war3source_evo; then
if $update_war3; then
    # remove old War3Source plugin files
    #rm -v "${SourceMetaModWar3InstallPath}/addons/plugins/War3Source*.smx"
    #read -p "Press ENTER to continue" readTMP

    date=$(date '+%m-%d-%Y')

    # Backup Files if exists
    test -e "${CPATH}/War3Source-EVO" && cp -vrf "${CPATH}/War3Source-EVO" "${CPATH}/War3Source-EVO-Backup-${date}"
    test -e "${CPATH}/War3Source-EVO" && read -p "Press ENTER to continue" readTMP

    # Remove old files
    test -e "${CPATH}/War3Source-EVO" && rm -rf "${CPATH}/War3Source-EVO"
fi
    # git clone War3Source
    git clone https://github.com/War3Evo/War3Source-EVO.git --branch ${git_branch}
if $update_war3; then
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

    # Copy Compiled plugins
    cp -vrf --remove-destination "${CPATH}/War3Source-EVO/addons/sourcemod/plugins" "${SourceMetaModWar3InstallPath}/addons/sourcemod"

    # Backup Translations
    cp -vrf "${SourceMetaModWar3InstallPath}/addons/sourcemod/translations" "${SourceMetaModWar3InstallPath}/addons/sourcemod/translations-${date}"

    # Copy Translations
    cp -vrf --remove-destination "${CPATH}/War3Source-EVO/addons/sourcemod/translations" "${SourceMetaModWar3InstallPath}/addons/sourcemod"

    # Store difference between CFG and CONFIG files and output them at the end
    diff -ar "${CPATH}/War3Source-EVO/cfg" "${SourceMetaModWar3InstallPath}/cfg" > CFGdifferences.txt
    diff -ar "${CPATH}/War3Source-EVO/addons/sourcemod/configs" "${SourceMetaModWar3InstallPath}/addons/sourcemod/configs" > CONFIGdifferences.txt

    # Clean up & Remove SM 1.9
    xargs rm -rf < "${CPATH}/War3Source-EVO/smlist19.txt" || true
    #read -p "Press ENTER to continue" readTMP
fi
    # GIT update information
    currentPTH=$PWD
    test -e "${CPATH}/War3Source-EVO" && cd "${CPATH}/War3Source-EVO/"
    test -e "${CPATH}/War3Source-EVO" && git --no-pager log --reverse --since="${updateDate}"
    test -e "${CPATH}/War3Source-EVO" && cd "${currentPTH}"

    echo ""
    echo "Any files with -end of file- errors during compiling is normal"
    echo "it means, those files are not compiled for your game mode."
    echo ""
    echo "Always remember to check https://github.com/War3Evo/War3Source-EVO to see"
    echo
    echo "SCROLL UP for changes information"

    # after git log delete git
    test -e "${CPATH}/.github" && rm -rf "${CPATH}/War3Source-EVO/.github"
    test -e "${CPATH}/War3Source-EVO/.git" && rm -rf "${CPATH}/War3Source-EVO/.git"
    rm -rf "${CPATH}/War3Source-EVO"
fi

echo "You can type 'cat CFGdifferences.txt' without the quotes to see this again."
echo "Here's the difference between CFG and yours.cat CFGdifferences.txt"
cat CFGdifferences.txt
read -p "press enter to continue" readSSS
echo ""
echo "You can type 'cat CONFIGdifferences.txt' without the quotes to see this again."
echo "Here's the difference between CFG and yours.cat CONFIGdifferences.txt"
cat CONFIGdifferences.txt

echo UPDATE COMPLETED
