#!/usr/bin/env bash

#    CSS - 232330
#    CSGO - 740
#    FOF - 295230
#    TF2 - 232250
#    L4D - 222840
#    L4D2 - 222860

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

spaceREQ=35
HDspace=$(df --output=avail -h ${CPATH} | sed '1d;s/[^0-9]//g')

if [[ $HDspace -le $spaceREQ ]]; then
     echo "You will need at least ${spaceREQ}GB of hard drive space before installing ${GAME_SWITCHER}!"
     echo "You only have ${HDspace}GB hard drive free space on ${CPATH}"
     df -h
     exit
fi

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
echo '* STEAMCMD / METAMOD / SOURCEMOD / WAR3SOURCE-EVO INSTALLER'
echo '*'
echo 'SUDO user is required to install libraries needed'
echo 'for SteamCMD, SourceMod, MetaMod, and to compile War3Source'
echo
echo 'Know that installing this as root is a security risk! SUDO user is HIGHLY RECOMMENDED!'
echo 'Know that installing this as root is a security risk! SUDO user is HIGHLY RECOMMENDED!'
echo 'Know that installing this as root is a security risk! SUDO user is HIGHLY RECOMMENDED!'
echo
echo 'You will need to type in your password, even if your not root to exit on some systems. ctrl+c does not always exit.'
echo
read -p "[${GAME_SWITCHER}] Press ENTER to continue" readTMP
echo
sudo apt-get update
sudo dpkg --add-architecture i386
sudo apt-get install wget
sudo apt-get install git
sudo apt-get install tar
sudo apt-get install screen
sudo apt-get install nano
sudo apt-get install lib32gcc1
sudo apt-get install lib32gcc-s1
sudo apt-get install lib32stdc++6
sudo apt-get install libc6-i386
sudo apt-get install linux-libc-dev:i386
#
# You may need these libraries for your linux server
# Uncomment if you want to see if they help you install or run the steam server
#
#sudo apt-get install clang
#sudo apt-get install lib32z1
#sudo apt-get install libbz2-1.0:i386
#sudo apt-get install libncurses5:i386
#sudo apt-get install libtinfo5:i386
#sudo apt-get install libcurl3-gnutls:i386
#sudo apt-get install libsdl2-2.0-0:i386
#sudo apt-get install libc6-dev-i386
echo
echo 'Some systems may complain about not see all files for apt-get,'
echo 'try to install anyhow, your system may not need them.'
echo
echo 'Just hit enter key for defaults, unless you want to change them.'
echo 'Defaults will be surrounded by () unless it says (required)'
echo
echo 'What directory would you like to install in?'
echo
read -p "[${GAME_SWITCHER}] Install Directory ($installPath)" readInstallPath
if [[ "$readInstallPath" ]]; then
    $installPath = $readInstallPath
fi
echo
echo "SteamCMD Directory is ${installPath}"
echo "${GAME_SWITCHER} Game Directory is ${gameInstallPath}"
echo "Sourcemod/MetaMod/War3Source Directory is ${SourceMetaModWar3InstallPath}"
echo
echo

# Create directories
test -e "${installPath}" || mkdir "${installPath}"
test -e "${installPath}/steamcmd" || mkdir "${installPath}/steamcmd"
test -e "${gameInstallPath}" || mkdir "${gameInstallPath}"
test -e "${SourceMetaModWar3InstallPath}" || mkdir "${SourceMetaModWar3InstallPath}"
# uncomment below if you want to stop at this point
#read -p "Press ENTER to continue" readTMP

# Download and Extract SteamCMD
test -e "steamcmd_linux.tar.gz" || wget "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" -O steamcmd_linux.tar.gz
tar -zxvf steamcmd_linux.tar.gz --directory "${installPath}"

# Create SteamCMD Script file
echo "force_install_dir ${gameInstallPath}" > "${steamcmdFile}"
echo "login anonymous" >> "${steamcmdFile}"
echo "app_update ${serverAPPid}" >> "${steamcmdFile}"
echo "quit" >> "${steamcmdFile}"

# Give Permissions
SCRIPT_PATH="${installPath}/steamcmd.sh"
chmod a+x "${SCRIPT_PATH}"

# RUN steamCMD installer
SCRIPT_RUN="${SCRIPT_PATH} +runscript ${steamcmdFile}"
bash -c "${SCRIPT_RUN}"

# uncomment below if you want to stop at this point
#read -p "Press ENTER to continue" readTMP

# git clone War3Source
git clone https://github.com/War3Evo/War3Source-EVO.git
cp -vrf ./War3Source-EVO/cfg "${SourceMetaModWar3InstallPath}"
# uncomment below if you want to stop at this point
#read -p "Press ENTER to continue" readTMP

cp -vrf ./War3Source-EVO/addons "${SourceMetaModWar3InstallPath}"
# uncomment below if you want to stop at this point
#read -p "Press ENTER to continue" readTMP

cp -vrf ./War3Source-EVO/sound "${SourceMetaModWar3InstallPath}"
rm -rf ./War3Source-EVO

# uncomment below if you want to stop at this point
#read -p "Press ENTER to continue" readTMP

# Get SourceMod Required to compile War3Source-EVO
wget "http://www.sourcemod.net/latest.php?version=1.9&os=linux" -O "${SourceMetaModWar3InstallPath}/sourcemod-1.9-linux.tar.gz"
tar -zxvf "${SourceMetaModWar3InstallPath}/sourcemod-1.9-linux.tar.gz" --directory "${SourceMetaModWar3InstallPath}"
# uncomment below if you want to stop at this point
#read -p "Press ENTER to continue" readTMP

# Extract SourceMod as List
tar --list -f "${SourceMetaModWar3InstallPath}/sourcemod-1.9-linux.tar.gz" > "${SourceMetaModWar3InstallPath}/smlist19.txt"
# uncomment below if you want to stop at this point
#read -p "Press ENTER to continue" readTMP

#
# COMPILE WAR3SOURCE-EVO
#
# Give spcomp the required permissions
chmod a+x "${SourceMetaModWar3InstallPath}/addons/sourcemod/scripting/spcomp_1.9.0.6261"
chmod a+x "${SourceMetaModWar3InstallPath}/addons/sourcemod/scripting/game_switcher_${GAME_SWITCHER}.sh"
chmod a+x "${SourceMetaModWar3InstallPath}/addons/sourcemod/scripting/compile_for_github_action.sh"
bash -c "${SourceMetaModWar3InstallPath}/addons/sourcemod/scripting/game_switcher_${GAME_SWITCHER}.sh"
bash -c "${SourceMetaModWar3InstallPath}/addons/sourcemod/scripting/compile_for_github_action.sh" || true
# uncomment below if you want to stop at this point
#read -p "Press ENTER to continue" readTMP

# Clean up & Remove SM 1.9
xargs rm -f < "${SourceMetaModWar3InstallPath}/smlist19.txt" || true
rm -rf ./War3Source-EVO
rm -rf .github
rm -rf .git
# uncomment below if you want to stop at this point
#read -p "BEFORE SOURCMOE 1.11 ** Press ENTER to continue" readTMP

# Download SourceMod
test -e "sourcemod-1.11-linux.tar.gz" ||  wget "http://www.sourcemod.net/latest.php?version=1.11&os=linux" -O sourcemod-1.11-linux.tar.gz

# Extract SourceMod
tar -zxvf sourcemod-1.11-linux.tar.gz --directory "${SourceMetaModWar3InstallPath}"
# uncomment below if you want to stop at this point
#read -p "Press ENTER to continue" readTMP

# Download MetaMod
test -e "metamod-1.11-linux.tar.gz" ||  wget "https://www.metamodsource.net/latest.php?version=1.11&os=linux" -O metamod-1.11-linux.tar.gz

# Extract Metamod
tar --overwrite -zxvf metamod-1.11-linux.tar.gz --directory "${SourceMetaModWar3InstallPath}"

# Steam Account ID
echo "You can get your ${GAME_SWITCHER} Steam Game Server Account from here:"
echo "https://steamcommunity.com/dev/managegameservers"
read -p "[${GAME_SWITCHER}] Please enter Steam Game Server Account (required):" readSteamAccount

publicIPaddress=$(sudo ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1');
read -p "[${GAME_SWITCHER}] Server IP Address (${publicIPaddress}):" readServerIPAddress
read -p "[${GAME_SWITCHER}] Server Port (27015):" readServerPort

ServerIP=$publicIPaddress

if [[ "$readServerIPAddress" ]]; then
        $ServerIP=$readServerIPAddress
fi

ServerPort=27015

if [[ "$readServerPort" ]]; then
	$ServerPort=$readServerPort
fi

if [[ "$readSteamAccount" ]]; then
    echo "screen -mS csgo ${gameInstallPath}/srcds_run -game csgo -secure -console -usercon +game_type 0 +game_mode 0  +mapgroup mg_active +ip ${ServerIP} +port ${ServerPort} -autoupdate +sv_consistency 0 +sv_pure 0 +map de_dust2 +maxplayers 32 +exec server.cfg +sv_setsteamaccount ${readSteamAccount} -steam_dir ${installPath} -steamcmd_script ${steamcmdFile}" > "${installPath}/start${GAME_SWITCHER}.sh"
    chmod a+x "${installPath}/start${GAME_SWITCHER}.sh"
    echo "*******************************************************************"
    echo "${installPath}/start${GAME_SWITCHER}.sh has been created for you:"
    cat "${installPath}/start${GAME_SWITCHER}.sh"
    echo "*******************************************************************"
    echo "*******************************************************************"
    echo "[READ EVERYTHING FIRST]"
    echo "Then to run server type this below and press enter:"
    echo "${installPath}/start${GAME_SWITCHER}.sh"
    echo "*******************************************************************"
    echo "*******************************************************************"
    echo "ctrl + a then press d to leave server running in the background"
    echo "to resume the server that is in background type: screen -r"
    echo "*******************************************************************"
    echo "ctrl + c to exit screen & terminate server."
    echo "Best Results: Type in quit and then press enter, before using ctrl + c."
    echo "*******************************************************************"
fi

echo DONE
echo FINISHED
echo COMPLETED
