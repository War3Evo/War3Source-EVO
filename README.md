# ![logo](https://avatars.githubusercontent.com/u/3613045?s=50) War3Source Evolution Win/Linux/Mac Server for CSGO, CSS, TF2, and FOF
Requires Sourcemod and Steamcmd - install.sh script for Linux installs everything needed

* :grey_question:[What is War3Evo War3Source Evolution](#what-is-war3evo-war3source-evolution)
* :sparkles:[Discord Server invite](#discord)
* :grey_exclamation:[Introduction](#introduction)
* :video_game:[Keyboard Bindings](#keyboard-bindings-for-pushing-buttons-for-your-abilities-and-ultimate)
* :star:[Requirements](#requirements)
* :point_right:[Install](#install)
* :rotating_light:[Update](#update)
* :older_man:[Oldinfo](#oldinfo)
* :speech_balloon:[Reporting issues](#reporting-issues)
* :hammer:[Submitting fixes](#submitting-fixes)
* :bulb:[Submit Ideas](#submitting-ideas)
* :globe_with_meridians:[Development and Roadmap](#development-and-roadmap)
* :copyright:[Copyright](#copyright)
* :link:[Links](#links)
* :clipboard:[To Do List](#to-do-list)

## Discord
![](https://dcbadge.vercel.app/api/shield/521064507121074210)

Server Invite:

[![](https://dcbadge.vercel.app/api/server/uhTfXYgJfB)](https://discord.gg/uhTfXYgJfB)

* https://discord.gg/uhTfXYgJfB

## What is War3Evo War3Source Evolution:grey_question:

From https://war3source.com/:
War3Source brings the Warcraft 3 leveling style and races into the game. It is originally based on the amxmodx (AMX) version War3FT.

Each standard race has total of 16 levels, made up of 3 skills and 1 ultimate where each skill/ultimate can be leveled 4 times for a total of 16 levels.

War3Source features a modular design where races can be coded independently and loaded into the main plugin. Independent plugins (Addons) can be created to complement or change aspects War3Source.

There are also shop items in W3S as there are in all Warcraft mods.

It comes with several pre-made races, and :shopping: shop items to get you started.  There's plans to offer bundle packs of new races in the future or you can create your own.

![logo](https://avatars.githubusercontent.com/u/3613045?s=50) War3Source: Evolution expands on War3Source.

&#x1F537;**W3Faction**&#x1F539;created by Don Revan was updated in War3Evo's War3Source. You can build races that use W3Factions to determine if a player shares the same faction or not. You could create a race that uses factions in order to give bonuses or negatives to a player race. A W3Faction can be anything you want... elf, dwarf, orc, etc. OR wood, stone, fire OR Light, Dark, Grey... whatever you desire in your race.

&#x1F537;**Casting**&#x1F539;allows you to implement a delay in your race before "casting a spell" with spell effects that "shows" others that your about to cast a spell.

&#x1F537;**Wards**&#x1F539;allows you to implement a area on the map that would be placed for a certain amount of seconds. The ward could be used to help your team or hurt the other team or both. The ward is visible to everyone and is color coded. Usually there is a timer and a limited number of wards a race can put down.

### :shopping:Shop Menu 1 Items - Costs Gold :coin:
These items lasts until player death.  Server owner can change the prices of these items in the war3source*.cfg files.  *.cfg files are text based files.
* :boot:boot - fun faster
* claw - extra dmg to enemy
* cloak - partially invisible
* mask - gain hp on hit
* lace - immunity to ultimates
* orb - slow on hit
* :ring:ring - regenerate hit points
* tome - buy xp
* sock - less gravity
* oil - Coats your weapons with ability to penetrate plates and helm.
* plate - Prevents All Damage to Chest.
* helm - no headshots to self
* shield - immunity to skills
* :fire:fireorb - chance fire enemy
* courage - 15% dmg reduction
* faith - 15% magic dmg reduction
* antiward - immunity to wards
* piercing - pierce physical armor

### TF2 Engineer Only Shop Items
*stophack - When a someone tries to hack your building, this item will be used instead. (single use item)

### TF2 Medic Only Shop Items
* uber50 - +50 uber
* :boot:mboots - Gives healing target increased movement speed
* :ring:mring - Gives healing target regeneration of hp
* :heartbeat:mhealth - Gives healing target extra hp

### TF2 PVM Game Mode
* leather - +12 phys armor
* chainmail - +14 phys armor
* bandedmail - +16 phys armor
* halfplate - +18 phys armor
* fullplate - +20 phys armor
* dragonmail - +50 magic armor

### :shopping:Shop Menu 2 Items - Costs Diamonds :gem:
These items you buy only once and lasts until map change.
* :running:posthaste - +3% speed
* :two_hearts:lifetube - +1 HP regeneration
* :heart:trinket - +0.5 HP regeneration
* sbracelt - +5% Evasion
* fbracer - +10 max HP

### TF2 MVM Game Mode
* :moneybag:mvmcashregen "My Piggy Bank" - MVM cash regeneration

### Keyboard Bindings for pushing buttons for your abilities and ultimate
Players will need to gain access to their developer console for the game in order to create keyboard bindings for the game.
* :video_game: +ability is a command that you can bind to a key on your keyboard in order to use that ability in game.
* :video_game: +ability2 is a command that you can bind to a key on your keyboard in order to use that ability in game.
* :video_game: +ultimate is a command that you can bind to a key on your keyboard in order to use that ability in game.

### Race Skills and Abilities you'll have to play the game to find out 

### Race Passive Ultimates - does not use +ultimate to activate
* :ambulance:Undead Scourge - Reincarnation - When you die, you revive on the spot. Has a 60/50/40/30 second cooldown.
* :flashlight:Scout - Marksman - Standing still for 1 second, scout is able to deal 1.2-1.6x damage the further the target.\n1000 units or more deals maximum damage

### Race Activate Ultimates - uses +ultimate to activate
* :boom:Human Alliance - Teleport - Teleport toward where you aim. 600/700/850/1000 range. Ultimate Immunity has 350 blocking radius.
* :evergreen_tree:Entangling Roots - Bind enemies to the ground, rendering them immobile for 0.25/0.50/0.75/1.0 seconds. Distance of increases per level units.
* :fire:Blood Mage TF2 - Flame Strike - Burn the enemy over time for 10 damage 4-10 times. 50/60/70/80ft. range
* :smiling_imp:Corrupted Disciple - Overload - Shocks the lowest hp enemy around you per second while you gain damage per hit
* :broken_heart:Soul Reaper - Demonic Execution - Deals a large amount of damage based on how much of the enemy's health is missing
* :droplet:Blood Hunter - Hemorrhage - The target will take damage if he moves. Duration Scales 4/5/6/7 seconds.
* :rage:N'aix - Rage - Naix goes into a maddened Rage, gaining 15-40% attack speed for 2-5 seconds
* :skull:Succubus Hunter - Deamonic Transformation - Get More speed, and more HP. Costs 1/2/3/4 SKULLs
* :watch:Chronos - Chronosphere - Rip space and time to trap enemy. Trapped victims cannot move and can only deal/receive melee damage, Sphere protects chornos from outside damage. It lasts 3/3.5/4/4.5 seconds
* :zap:Lich - Death And Decay - Deals 2/4/6/8 magic damage to all enemies on map
* :hocho:Sacred Warrior - Life Break - Damage yourself (10/15/20/25%% of maxHP) to deal a great amount of damage (20/30/40/50%% of victim's maxHP)
* :milky_way:Hammerstorm - Gods Strength - Greatly enhance your damage by 20/30/40/50 percent for a short amount of time.
* :crystal_ball:Dark Elf - DarkOrb - Blind a player. 0.5-2 second duration & 1000 Range
* :rose:Fluttershy - BeGentle - Target cannot deal damage for 1-1.8 seconds
* :no_smoking:Dragonborn TF2 - Dragons Breath - Applies jarate effect. 400-700 range.
* :zzz:Rarity - Hold - Hold and blinds player up to 2.3 seconds
* :rainbow::dash:Rainbow Dash - Sonic Rainboom - Buff teammates' damage around you for 4 sec, 200-400 units. Must be in speed (ability) mode to cast.
* :last_quarter_moon_with_face:Luna Moonfang - Eclipse - Calls to the moon`s magic, summoning a concentrated burst of Lucent Beams to damage targets around Luna. 4-10 beams.
* :frog:Frogger TF2 - Lilly Pads - [Lvl 1]Can use any teleporter (blue/red) [Lvl 2]Teleporters instant recharge when you walk thru them [Lvl 3]Mini-Instant level 3 teleporter [Lvl 4]Build Double Dispensers
* :boom:Light Bender - Flash - Teleport a random ally to you!
* :eyeglasses:Shadow Paladin TF2 - Big Bad Voodoo - You are invulnerable from physical attacks for 0.66/1.0/1.33/1.66 seconds
* :syringe:Soul Medic TF2 - Soul Swap - You swap HP with your partner. You become ubered for 2/3/4/5 seconds. CD: 60s

### Technical
Races loaded in War3EVo's War3Source are in memory, but functions inside the addons is disabled if they are not used by any player or bot. This helps in reducing wasted CPU cycles.

## Introduction

War3Source Evoultion is a *RPG* Gamemode based mostly in Sourcepawn.

It is completely open source; :family:community involvement is highly encouraged.

If you wish to contribute :bulb:ideas or :page_with_curl:code, please visit our site linked below or
make pull requests to our [Github repository](https://github.com/War3Evo/War3Source-EVO/pulls).

For further information on the War3Source Evoultion scroll:project, please visit our scroll:project
website at [War3Evo.info](http://www.war3evo.info/).

## Requirements

### :floppy_disk:Hard Drive Space Requirements
* CSGO - 35 GB
* CSS - 3 GB
* TF2 - 10 GB
* FOF - 4 GB

### :computer:Minium Memory Requirements
* CSGO 1 GB / 1 GB SWAP
* CSS 512 MB / 256 MB SWAP
* TF2 512 MB / 256 MB SWAP
* FOF 512 MB / 256 MB SWAP

### :bell:Software Requirements
* Steam Server (SteamCMD) - https://developer.valvesoftware.com/wiki/SteamCMD#Downloading_SteamCMD
* MetaMod - https://www.metamodsource.net/downloads.php?branch=stable
* SourceMod requires 1.9 to compile - Runs on the latest version - https://www.sourcemod.net/downloads.php?branch=stable
* War3Source-EVo - https://github.com/War3Evo/War3Source-EVO

### :key:Steam Server Requirements
* Steam Game Server Account Management - https://steamcommunity.com/dev/managegameservers

## Install

The easiest way to install is to use the provided installation scripts.

The scripts was created using Debian 11. If you use a different Linux OS, your mileage may vary.

You will need to be a SUDO user to fully install using this script because it requires installing special libraries for the game server.

If you run the script for the first time and the server doesn't install correctly, open the script and uncomment all the #sudo apt-get install comments so that it can install those other libraries that your Linux may need.  Then try the script again.  If it still doesn't install correctly, report this issue along with what Linux OS your installing to and any other helpful information like the output of the install.  If a install doesn't install correctly it's usually because your missing a Linux library.  If you install a Linux library that isn't in our script, and it helps your install, please let us know.

If you plan to use a non-sudo or non-root user to run this server for security purposes,
then you'll need to change the ownership before and after the script.

* Before script example
``` sudo chown -R YourSudoYourName:YourSudoYourName /home/NonSudoUser ```
* After script example
``` sudo chown -R NonSudoUser:NonSudoUser /home/NonSudoUser ```

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

_Can be ran as a Non-Root / Non-Sudo user as long as the user owns all the directories._

The easiest way to update is to using the provided update scripts.

Make sure you read the git commit log for updates: https://github.com/War3Evo/War3Source-EVO/commits/master

**_You can edit the .sh file based on true or false depending on what you want to update. Do you want to update the Steam Server, SourceMod, MetaMod, and or War3Source-EVO?  You can change that in the top of the .sh file. Make sure you do not change the formatting. Adding or removing spaces can create errors in the script!_**

_If before the update you had no plug-in issues, but after the update you do.  You may have to either restore from the backup files or backup your config and cfg files, then use the install*.sh script._

These updates will backup files into folders with part of the word as "backup" and a date of backup.  They will not write to cfg or config files, you'll need to make those changes yourself.

Make sure the same diretory you used install*.sh is the same directory you use this script in!

At the end of the update script, it should output the git commit log.  Scroll up to see past updates info for changes you may need to make to your configuration files.

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

## :speech_balloon:Reporting Issues

Issues can be reported via the [Github issue tracker](https://github.com/War3Evo/War3Source-EVO/issues).

Please take the time to review existing issues before submitting your own to
prevent duplicates.

## :hammer:Submitting Fixes

SourcePawn fixes are submitted as pull requests via Github.
For SQL only fixes, open a ticket; if a bug report exists for the bug, post on an existing ticket.

## :bulb:Submitting Ideas

https://github.com/War3Evo/War3Source-EVO/discussions/categories/ideas

## Development and Roadmap

3/5/2023
The develop branch is currently working on making War3source fully translatable.
Players will soon be able to type commands in thier own language for War3Source:EVO.
Anyone willing to help with translating for your language, see the Develop branch for the **_new translation files_** and submit to discussion or issue area of github. If you install this mod using the linux install script, you can change the git branch inside the upgrade script.

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

## To Do List

This isn't in order of priority 

[ ] Finish Translations
[ ] Upgrade from SourceMod 1.9 to the latest
[ ] Add new Races
[ ] Rework the wiki
[ ] create a shell script to promopt for configuration changes


