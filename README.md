# ![logo](https://avatars.githubusercontent.com/u/3613045?s=50) War3Source Evoultion Gamemode for Sourcemod

* [Introduction](#introduction)
* [Requirements](#requirements)
* [Install](#install)
* [Update](#update)
* [Oldinfo](#oldinfo)
* [Reporting issues](#reporting-issues)
* [Submitting fixes](#submitting-fixes)
* [Copyright](#copyright)
* [Links](#links)

## Introduction

War3Source Evoultion is a *RPG* Gamemode based mostly in Sourcepawn.

It is completely open source; community involvement is highly encouraged.

If you wish to contribute ideas or code, please visit our site linked below or
make pull requests to our [Github repository](https://github.com/War3Evo/War3Source-EVO/pulls).

For further information on the War3Source Evoultion project, please visit our project
website at [War3Evo.info](http://www.war3evo.info/).

## Requirements

### Hard Drive Space Requirements
* CSGO - 35 GB
* CSS - 3 GB
* TF2 - 10 GB
* FOF - 4 GB

### Minium Memory Requirements
* CSGO 1 GB / 1 GB SWAP
* CSS 512 MB / 256 MB SWAP
* TF2 512 MB / 256 MB SWAP
* FOF 512 MB / 256 MB SWAP

### Software Requirements
* Steam Server (SteamCMD) - https://developer.valvesoftware.com/wiki/SteamCMD#Downloading_SteamCMD
* MetaMod - https://www.metamodsource.net/downloads.php?branch=stable
* SourceMod - https://www.sourcemod.net/downloads.php?branch=stable
* War3Source-EVo - https://github.com/War3Evo/War3Source-EVO

### Steam Server Requirements
* Steam Game Server Account Management - https://steamcommunity.com/dev/managegameservers

## Install

The easiest way to install is to use the provided installation scripts.

The scripts was created using Debian 11. If you use a different Linux OS, your mileage may vary.

You will need to be a SUDO user to fully install using this script because it requires installing special libraries for the game server.

If you run the script for the first time and the server doesn't install correctly, open the script and uncomment all the #sudo apt-get install comments so that it can install those other libraries that your Linux may need.  Then try the script again.  If it still doesn't install correctly, report this issue along with what Linux OS your installing to and any other helpful information like the output of the install.  If a install doesn't install correctly it's usually because your missing a Linux library.  If you install a Linux library that isn't in our script, and it helps your install, please let us know.

It will prompt you for the installation directory and other information as it needs.installcsgo.sh

THIS IS A FULL INSTALL OF STEAM SERVER, SOURCEMOD, METAMOD, and War3Source-EVO!

DO NOT USE THIS TO UPDATE.  It will over write your cfg files. I'm working on a update script.

* CSS ./installcss.sh
```
wget "https://raw.githubusercontent.com/War3Evo/War3Source-EVO/master/installcss.sh" -O installcss.sh
chmod +x installcss.sh
./installcss.sh
```
* CSGO ./installcsgo.sh
```
wget "https://raw.githubusercontent.com/War3Evo/War3Source-EVO/master/installcsgo.sh" -O installcsgo.sh
chmod +x installcsgo.sh
./installcsgo.sh
```
* TF2 ./installtf2.sh
```
wget "https://raw.githubusercontent.com/War3Evo/War3Source-EVO/master/installtf2.sh" -O installtf2.sh
chmod +x installcss.sh
./installcss.sh
```
* FOF ./installfof.sh
```
wget "https://raw.githubusercontent.com/War3Evo/War3Source-EVO/master/installfof.sh" -O installfof.sh
chmod +x installfof.sh
./installfof.sh
```

## Update

The easiest way to update is to using the provided update scripts.

The only pain will be reading the git commit log to make sure you get the latest news on updates for your configuration file.  Which the update script will print out at the end of the update.  Make sure you scroll back and read it.  Or read it here: https://github.com/War3Evo/War3Source-EVO/commits/master

These update files currently only update War3Source-EVO.  I will work on something to help with sourcemod / metamod updates too. Keep watching for updates to this script, because it will get updated also when I am able to get sourcemod / metamod updates added.  If you badly need sourcemod / metamod update because your server "broke" use the install script to do it, but backup your config and cfg files first!

These updates will backup files into folders with part of the word as "backup" and a date of backup.  They will not write to cfg or config files, you'll need to make those changes yourself.

Make sure the same diretory you used install*.sh is the same directory you use this script in!

These scripts download the git, compile the latest War3Source-EVO, and copy files to your server directory.

* CSS ./updatecss.sh
```
wget "https://raw.githubusercontent.com/War3Evo/War3Source-EVO/master/installcss.sh" -O updatecss.sh
chmod +x updatecss.sh
./updatecss.sh
```
* CSGO ./updatecsgo.sh
```
wget "https://raw.githubusercontent.com/War3Evo/War3Source-EVO/master/updatecsgo.sh" -O updatecsgo.sh
chmod +x updatecsgo.sh
./updatecsgo.sh
```
* TF2 ./updatetf2.sh
```
wget "https://raw.githubusercontent.com/War3Evo/War3Source-EVO/master/updatetf2.sh" -O updatetf2.sh
chmod +x updatetf2.sh
./updatetf2.sh
```
* FOF ./updatefof.sh
```
wget "https://raw.githubusercontent.com/War3Evo/War3Source-EVO/master/installfof.sh" -O updatefof.sh
chmod +x updatefof.sh
./updatefof.sh
```

## Players having trouble downloading files from your CSGO server?

Make sure every player puts this into their console to enable downloads:

* sv_allowupload 1

This will allow the server to upload to the client. By default the clients have this disabled.

OR

Get a fastDL server and set your sv_downloadurl (see link --> https://developer.valvesoftware.com/wiki/Sv_downloadurl)

## Compile & Server Requirements

* https://github.com/War3Evo/War3Source-EVO/wiki/Compile-&-Server-Requirements

## Oldinfo

Read file [CHANGELOGS](CHANGELOG.md).

## Reporting Issues

Issues can be reported via the [Github issue tracker](https://github.com/War3Evo/War3Source-EVO/issues).

Please take the time to review existing issues before submitting your own to
prevent duplicates.

## Submitting Fixes

SourcePawn fixes are submitted as pull requests via Github.
For SQL only fixes, open a ticket; if a bug report exists for the bug, post on an existing ticket.

## Contributor Rules

* Keep the very first comment on top of file
* If you want to delete certain comments, it must be approved.
* TABS are required.
* Any major changes, must be approved.

## Inactive Contributors
* Anthony Iacono & OwnageOwnz (DarkEnergy) - Original Authors - 7/23/2016 - 8/31/2010
* Dagothur - Major Coding of the source code (2016) to (2020)
* JustZerooo - fixed CSGO FPS issue and some documentation work - 1/30/2023 to 2/1/2023
* ice-mann - submitted sound-pack branch & minor code changes (2016)

## Active Contributors
* El Diablo - Rewritten a lot of the Original War3Source source code - (2015) to (current)

## Copyright

License: GPL 3.0

Read file [COPYING](LICENSE).

## Links

* [Website](http://www.war3evo.info/)
* [Wiki](https://github.com/War3Evo/War3Source-EVO/wiki)
* [Discord Invite](https://discord.gg/uhTfXYgJfB)
