# War3Source Evoultion

https://forums.alliedmods.net/showthread.php?p=2431473


**GAME MODE CURRENTLY SETUP TO COMPILE FOR IS CSGO**

Updated for Sourcemod 1.8

If something is missing during compiling, let me know.


Currently not commpatible with the Original War3Source Races. May add compatibility later.

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
