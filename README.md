# War3Source Evoultion -->>ReadME.md updated 1/30/2023<<--

Join the discord: https://discord.gg/kYDNhDwwZV

AlliedModders: https://forums.alliedmods.net/showthread.php?t=284415

**Don't forget to switch game before compiling**

Edit GAME_SWITCHER before compiling to switch for your game mode:
addons/sourcemod/scripting/include/GAME_SWITCHER/currentgame.inc

**Road MAP**

Currently checking these for bugs:

- [x] TF2 is working. (9/15/2022)

- [x] CS:GO FPS issue fixed. (1/30/2023)

- [ ] TF2 is being rechecked and when done I will compile a version for Allied Modders and post a link here - 1/30/2023

-- [x] War3Source CORE fixed (9/17/2022)

-- [ ] Checking each race for errors

------- [ ] One of the races is causing an error model (need to find and fix it)

-- [ ] Checking each addon for errors

-- [ ] Check for sound files / models needed and create a package for users to download the zip

- [ ] CS:S is next on list

- [ ] FOF is last to be looked at

- [ ] Add Translations back into War3Source:EVO

**RamNode Servers Recommendation**
If your good with setting up your own VPS, then I highly recommend using RamNode open vps servers as they've been around for over a decade.

War3Source:Evo does require at least 1 gb of ram to run smoothly.  At minimum 750 mb of ram with 250 mb of vswap in openvz.

Please help me pay for my test servers by using my [Affiliate Link](https://clientarea.ramnode.com/aff.php?aff=1227) 

**War3Evo War3Source: Evolution 3.0 Test Server is here: 107.191.126.14:27015**

https://www.gametracker.com/server_info/107.191.126.14:27015/

**Norad is running a public server running this mod here: 136.57.191.195:27018**

https://forums.alliedmods.net/showthread.php?p=2431473

**Seems to compile fine for TF2 using the 1.9 compiler, but once you go to the 1.10 compiler... you'll get tons of errors!**
```
git_War3Evo_OPENSOURCE_4_JUNE_2016/addons/sourcemod/scripting/compile.sh "War3Source.sp" (in directory: git_War3Evo_OPENSOURCE_4_JUNE_2016/addons/sourcemod/scripting)
Single File Compiling War3Source.sp...SourcePawn Compiler 1.9.0.6261
Copyright (c) 1997-2006 ITB CompuPhase
Copyright (c) 2004-2017 AlliedModders LLC
Code size:           597404 bytes
Data size:          8862768 bytes
Stack/heap size:    2400000 bytes
Total requirements:11860172 bytes
Done.
Compilation finished successfully.
```
You can find SourceMod 1.9 here: https://www.sourcemod.net/downloads.php?branch=1.9-dev&all=1

I believe you can download the latest SourceMod for the server, then just compile the code for War3Source: EVO using spcomp from 1.9

**For CSGO, I have the latest SourceMod and MetaMod programs running on the CSGO server, while I still compile using a SourceMod 1.9 spcomp compiler.  Reason: Anything after 1.9 they've changed the compiler so much it is just too time comsuming to change the thousands of lines of code just so it looks better.  In reality, SourceMod 1.9 should continue to work forever as the changes they are making to the compiler is cosmetic.**

If something is missing during compiling, let me know.

**War3Evo War3source: EVO IS NOT commpatible with the Original War3Source Races.** 
May add compatibility later, but don't get your hopes up.

Translations do not fully work on this version, as I ripped out a lot of translations during updates for my private version.  English is the language used without translation files.


# Notes

* Compiles fine for TF2, but you may need certain extensions to run
* You need to go to change the contents in the file War3Source-EVO/addons/sourcemod/scripting/include/GAME_SWITCHER/currentgame.inc in order to compile for your platform


# All Game Mode Convars

* war3AllowInstantRaceChange - 0 disabled / 1 enabled. Allows players to change race instantly in spawn. (default 1)
* war3pause - 0 disabled / 1 enabled. Pauses all War3Source stuff, so plugins can be reloaded easier. (default 0)
* war3_allow_developer_access - 0 disabled / 1 enabled. Allows developer to have developer access. (default 0)
* war3_allow_developer_powers - 0 disabled / 1 enabled allows developer to bypass race restrictions, etc. (default 0)
* war3_racelimit_enable - 0 disabled / 1 enabled. Should race limit restrictions per team be enabled. (default 1)
* war3_game_desc - 0 disabled / 1 enabled. change game description to war3source? does not affect player connect. (default 1)
* war3_metric_system - 0 disabled / 1 enabled. Do you want use metric system? 1-Yes, 0-No. (default 0)
* war3_bots_invisibility_gives_evasion - 0 disabled / 1 enabled. Should invisibility give evasion against bots? (default 1)
* war3_disable_races_mapend - 0 disabled / 1 enabled. Disable races on round end? (default 1)
* war3_enable_races_mapstart - 0 disabled / 1 enabled. Enable races on round start? (default 1)
* war3_newplayer_enabled - 0 disabled / 1 enabled.  Do you want to enable new player benefits? (does not include levelbank) (default 1)
* war3_new_player_levelbank - The amount of free levels a person gets that is new to the server (no xp record) (default 20)
* war3_print_levelbank_spawn - 0 disabled / 1 enabled. Print how much you have in your level bank in chat every time you spawn? (default 0)
* war3_ignore_bots_xp - 0 disabled / 1 enabled. Set to 1 to not award XP for killing bots.(default 0)
* war3_max_shopitems - (default 2)
* war3_max_shopitems2 - (default 3)
* war3_max_shopitems3 - (default 3)
* war3_Load_RacesAndItems_every_map - 0 disabled / 1 enabled.
* sm_bank_withdraw_timelimit - default 2700 = 45 minutes (default 2700)
* war3_clan_id - If GroupID is non-zero the plugin will use steamtools to identify clan players(Overrides 'war3_bonusclan_name')
* war3_no_spendskills_limit - Set to 1 to require no limit on non-ultimate spendskills. (default 0)
* war3_show_playerinfo_other_player_items - 0 disables showing other players items using playerinfo. (default 1)
* war3_savexp - 0 disabled / 1 enabled. (default 1)
* war3_set_job_on_join - 0 disabled / 1 enabled. Jobs = Races .. Just another way of saying races. (default 1)
* war3_race_dynamic_loading - 0 disabled / 1 enabled. (default 1)
* war3_race_dynamic_loading_fulldisable - 0 disabled / 1 enabled. (default 0)
* war3_sh3_autosavetime - (300 default)
* war3_buyitems_category - Enable/Disable shopitem categorys. (0 default)
* war3_disable_ward_checking - 0 disabled / 1 enabled. (default 0)
* war3_maxplatinum - (1000000 default)
* war3_command_blocking - 0 disabled / 1 enabled. block chat commands from showing up. (default 0)
* war3_minimumultimatelevel - (10 default)

# TF2 Game Mode Convar

* tf2_attributes - 0 disabled / 1 enabled. (default 0)

# RACES INCLUDED (TESTED ON CSGO, TF2)
* Undead Scourge
* Human Alliance
* Night Elf

# RACES INCLUDED (TESTED ON TF2)
* Blood Mage
* Corrupted Disciple
* Soul Reaper
* Blood Hunter
* Naix
* Succubus Hunter
* Chronos
* Lich
* Sacred Warriror
* Hammer Storm
* Scout
* Dark Elf
* Dragon Born
* Flutter Shy
* Rarity
* Rainbow Dash
* Luna
* Light Bender
* Soul Medic

# CSGO doesn't like the following:
* [SM] Exception reported: Using two team colors in one message is not allowed

# CSGO
* Client gamers need to add this to their console: sv_allowupload 1
