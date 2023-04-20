//
// Copyright (c) 2010-2016  El Diablo <shadeline2000@yahoo.com>
//
//  War3Source: Evolution is free software: you may copy, redistribute
//  and/or modify it under the terms of the GNU General Public License as
//  published by the Free Software Foundation, either version 3 of the
//  License, or (at your option) any later version.
//
//  This file is distributed in the hope that it will be useful, but
//  WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//  General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
// This file incorporates work covered by the following copyright and
// permission notice:
/*  This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.

	War3source written by PimpinJuice (anthony) and Ownz (Dark Energy)
	All rights reserved.
*/

/*
* File: War3Source.sp
* Description: The main file for War3Source.
* Author(s): Anthony Iacono  & OwnageOwnz (DarkEnergy)
* All handle leaks have been considered.
* If you don't like it, read through the whole thing yourself and prove yourself wrong.
*/

/*
 *
 * NOTES:
 *
 * In War3Source_Engine_Race_KDR.sp
 * return view_as<int>(GetRaceKDR(raceid)); <-- may cause issue not sure
 * it was saying using "return GetRaceKDR(raceid);" was a tag mismatch
 *
 */

#pragma dynamic 600000

#pragma semicolon 1

// enable this when your ready to translate more code to 1.9
//#pragma newdecls required

#undef REQUIRE_EXTENSIONS
#include <war3source>

//#include <profiler>

#include "War3Source/include/War3Source_Version_Info.inc"
#include "War3Source/include/War3Source_Variables.inc"

//stocks needed by all included below:
#include "War3Source/include/War3Soruce_Internal_Only_Stocks.inc"

#include "War3Source/War3Source_001_OnMapStart.sp"
#include "War3Source/War3Source_001_OnMapEnd.sp"
#include "War3Source/War3Source_001_OnPluginStart.sp"
#include "War3Source/War3Source_001_OnPluginEnd.sp"
#include "War3Source/War3Source_001_OnRaceChanged.sp"
#include "War3Source/War3Source_001_OnW3Denyable.sp"
#include "War3Source/War3Source_001_OnAddSound.sp"
#include "War3Source/War3Source_001_OnGameFrame.sp"
#include "War3Source/War3Source_001_OnPlayerRunCmd.sp"
#include "War3Source/War3Source_001_OnSkillLevelChanged.sp"
#include "War3Source/War3Source_001_OnWar3Event.sp"
#include "War3Source/War3Source_001_Configuration.sp"
#include "War3Source/War3Source_001_Clients.sp"
#include "War3Source/War3Source_001_Engine_InitNatives.sp"
#include "War3Source/War3Source_001_Engine_InitForwards.sp"
#include "War3Source/War3Source_001_GameEvents.sp"
#include "War3Source/War3Source_001_OnW3TakeDmgAllPre.sp"

#include "War3Source/War3Source_000_Engine_Misc.sp"
#include "War3Source/War3Source_000_Engine_DatabaseConnect.sp"
#include "War3Source/War3Source_000_Engine_Hint.sp"
#include "War3Source/War3Source_000_Engine_Log.sp"

#include "War3Source/War3Source_Engine_Aura.sp"
#include "War3Source/War3Source_Engine_Bank.sp"
#include "War3Source/War3Source_Engine_BuffHelper.sp"
#include "War3Source/War3Source_Engine_BuffMaxHP.sp"
#include "War3Source/War3Source_Engine_BuffSpeedGravGlow.sp"
#include "War3Source/War3Source_Engine_BuffSystem.sp"
#include "War3Source/War3Source_Engine_CommandHook.sp"
#include "War3Source/War3Source_Engine_CooldownMgr.sp"

#if (GGAMETYPE == GGAME_CSGO)
#include "War3Source/War3Source_Engine_CSGO_Radar.sp"
#endif

#if (CYBORG_SKIN == MODE_ENABLED)
#include "War3Source/War3Source_Engine_Cyborg.sp"
#endif

#include "War3Source/War3Source_Engine_DamageSystem.sp"
#include "War3Source/War3Source_Engine_DatabaseSaveXP.sp"
#include "War3Source/War3Source_Engine_DatabaseTop100.sp"
#include "War3Source/War3Source_Engine_Deny.sp"
#include "War3Source/War3Source_Engine_Dependency.sp"
#include "War3Source/War3Source_Engine_Download_Control.sp"
#include "War3Source/War3Source_Engine_Easy_Buff.sp"
#include "War3Source/War3Source_Engine_Events.sp"
#include "War3Source/War3Source_Engine_HelpMenu.sp"
#include "War3Source/War3Source_Engine_ItemClass.sp"
#include "War3Source/War3Source_Engine_ItemClass2.sp"
#if (SHOPMENU3 == MODE_ENABLED)
#include "War3Source/War3Source_Engine_ItemClass3.sp"
#endif

#if (SHOPMENU3 == MODE_ENABLED)
#include "War3Source/War3Source_Engine_ItemDatabase3.sp"
#endif

#include "War3Source/War3Source_Engine_ItemOwnership.sp"
#include "War3Source/War3Source_Engine_ItemOwnership2.sp"
#if (SHOPMENU3 == MODE_ENABLED)
#include "War3Source/War3Source_Engine_ItemOwnership3.sp"
#endif
#include "War3Source/War3Source_Engine_MenuChangerace.sp"
#include "War3Source/War3Source_Engine_MenuItemsinfo.sp"
#include "War3Source/War3Source_Engine_MenuItemsinfo2.sp"
#if (SHOPMENU3 == MODE_ENABLED)
#include "War3Source/War3Source_Engine_MenuItemsinfo3.sp"
#endif
#include "War3Source/War3Source_Engine_MenuRacePlayerinfo.sp"
#include "War3Source/War3Source_Engine_MenuShopmenu.sp"
#include "War3Source/War3Source_Engine_MenuShopmenu2.sp"
#if (SHOPMENU3 == MODE_ENABLED)
#include "War3Source/War3Source_Engine_MenuShopmenu3.sp"
#endif
#include "War3Source/War3Source_Engine_MenuSpendskills.sp"
#include "War3Source/War3Source_Engine_MenuWar3Menu.sp"

#if (MESSAGE_CONTROL_MODE == MODE_ENABLED)
// added 1/27/2022 - csgo can't handle spammy war3source
// I would rather rip it out of the source code, but maybe useful in
// the future.
#include "War3Source/War3Source_Engine_Messages.sp"
#endif

#include "War3Source/War3Source_Engine_Money_Timer.sp"
#include "War3Source/War3Source_Engine_NewPlayers.sp"
#include "War3Source/War3Source_Engine_Notifications.sp"
#include "War3Source/War3Source_Engine_PlayerClass.sp"
#include "War3Source/War3Source_Engine_PlayerCollision.sp"
#include "War3Source/War3Source_Engine_PlayerDeathWeapons.sp"
#include "War3Source/War3Source_Engine_PlayerLevelbank.sp"
#include "War3Source/War3Source_Engine_PlayerTrace.sp"
#include "War3Source/War3Source_Engine_RaceClass.sp"
#include "War3Source/War3Source_Engine_Race_KDR.sp"
#include "War3Source/War3Source_Engine_RaceRestrictions.sp"
#include "War3Source/War3Source_Engine_Regen.sp"
#include "War3Source/War3Source_Engine_ShowMOTD.sp"
#include "War3Source/War3Source_Engine_SkillEffects.sp"

// not usable currently under 1.7+ sourcemod (figure out later)
//#include "War3Source/War3Source_Engine_Statistics.sp"
//#include "War3Source/War3Source_Engine_StatSockets2.sp"

#include "War3Source/War3Source_Engine_TrieKeyValue.sp"
#include "War3Source/War3Source_Engine_Wards_Checking.sp"
#include "War3Source/War3Source_Engine_Wards_Engine.sp"
#include "War3Source/War3Source_Engine_Wards_Engine_Behavior.sp"
#include "War3Source/War3Source_Engine_Wards_Wards.sp"
#include "War3Source/War3Source_Engine_Weapon.sp"
#include "War3Source/War3Source_Engine_XPGold.sp"

#if (SHOPMENU3 == MODE_ENABLED)
#include "War3Source/War3Source_Engine_XP_Platinum.sp"
#endif

#include "War3Source/War3Source_Engine_WCX_Engine_Bash.sp"
#include "War3Source/War3Source_Engine_WCX_Engine_Crit.sp"
#include "War3Source/War3Source_Engine_WCX_Engine_Dodge.sp"
#include "War3Source/War3Source_Engine_WCX_Engine_Skills.sp"
#include "War3Source/War3Source_Engine_WCX_Engine_Teleport.sp"

#if (GGAMETYPE != GGAME_CSGO)
#include "War3Source/War3Source_Engine_SteamTools.sp"
#endif

#include "War3Source/War3Source_Engine_BotControl.sp"
#include "War3Source/War3Source_Engine_DeciSecondLoop_Timer.sp"

#include "War3Source/War3Source_Engine_Casting.sp"

#include "War3Source/War3Source_002_OnW3HealthPickup.sp"
#if (GGAMETYPE == GGAME_TF2)
#include "War3Source/War3Source_002_OnW3SupplyLocker.sp"
#endif

#include "War3Source/War3Source_Engine_WCX_Engine_Vampire.sp"

#include "War3Source/War3Source_Engine_GameData.sp"

#include "War3Source/War3Source_003_RegisterPrivateForwards.sp"

#include "War3Source/War3Source_001_OnSkinChange.sp"

#include "War3Source/War3Source_Engine_SkillsClass.sp"

// Disabled for now
//#include "War3Source/War3Source_Engine_Talents.sp"
//#include "War3Source/"
//#include "War3Source/"

public Plugin:myinfo=
{
	name="War3Source:EVO",
	author=AUTHORS,
	description="The next generation of a Warcraft like gamemode to the Source engine.",
	version=VERSION_NUM,
};

/**********************
 * CAUTION, THE War3 INTERFACE NOW HANDLES AskPluginLoad2Custom BECAUSE IT IS REQUIRED TO HANDLE CERTAIN TASKS
 * It acually simplifies things for you:
 * Determines game mode
 * Mark Natives optional
 * Calls your own functions (hackish way) if you have them:
 * InitNativesForwards()
 * AskPluginLoad2Custom(Handle:myself,bool:late,String:error[],err_max);
 * So if you want to do something in AskPluginLoad2, implement public AskPluginLoad2Custom(...) instead.
 */
//=============================================================================
// AskPluginLoad2
//=============================================================================
public APLRes:AskPluginLoad2(Handle:plugin,bool:late,String:error[],err_max)
{
	//DetermineGameMode();
	char game[64];
	GetGameFolderName(game, sizeof(game));
#if (GGAMETYPE == GGAME_TF2)
	CurrentGameMode = GAME_MODE_TF2;

	new String:mapName[128];
	GetCurrentMap(mapName,sizeof(mapName));
	if (StrContains(mapName, "mvm_", false) != -1)
	{
		CurrentGameMode = CurrentGameMode | GAME_MODE_MVM;
	}

	if (strncmp(game, "tf", 2, false) != 0)
	{
		strcopy(error, err_max, "War3Source:EVO is currently built for TF2. Look for a compiled version for your game mode.");
		return APLRes_Failure;
	}
#elseif (GGAMETYPE == GGAME_CSS)
	CurrentGameMode = GAME_MODE_CSS;
	if (strncmp(game, "cstrike", 7, false) != 0)
	{
		strcopy(error, err_max, "War3Source:EVO is currently built for CSS. Look for a compiled version for your game mode.");
		return APLRes_Failure;
	}
#elseif (GGAMETYPE == GGAME_FOF)
	CurrentGameMode = GAME_MODE_FOF;
	if (strncmp(game, "fof", 3, false) != 0)
	{
		strcopy(error, err_max, "War3Source:EVO is currently built for FOF. Look for a compiled version for your game mode.");
		return APLRes_Failure;
	}
#elseif (GGAMETYPE == GGAME_CSGO)
	CurrentGameMode = GAME_MODE_CSGO;
	if (strncmp(game, "csgo", 4, false) != 0)
	{
		strcopy(error, err_max, "War3Source:EVO is currently built for CSGO. Look for a compiled version for your game mode.");
		return APLRes_Failure;
	}
#else
	// For future game modes
	if(StrContains(gameDir, "left4dead2", false) == 0)
	{
		CurrentGameMode = GAME_MODE_L4D2;
	}
	else if(StrContains(gameDir, "left4dead", false) == 0)
	{
		CurrentGameMode = GAME_MODE_L4D;
	}
	else if (StrContains(gameDir, "dod", false) == 0)
	{
		CurrentGameMode = GAME_MODE_DOD;
	}
#endif
	//GlobalOptionalNatives();
	new Function:func;
	func=GetFunctionByName(plugin, "InitNativesForwards");
	if(func!=INVALID_FUNCTION) { //non war3 plugins dont have this function
		Call_StartFunction(plugin, func);
		Call_Finish(dummy);
		if(!dummy) {
			LogError("InitNativesForwards did not return true, possible failure");
		}
	}
	func=GetFunctionByName(plugin, "AskPluginLoad2Custom");
	if(func!=INVALID_FUNCTION) { //non war3 plugins dont have this function
		Call_StartFunction(plugin, func);
		Call_PushCell(plugin);
		Call_PushCell(late);
		Call_PushString(error);
		Call_PushCell(err_max);
		Call_Finish(dummy);
		if(APLRes:dummy==APLRes_SilentFailure) {
			return APLRes_SilentFailure;
		}
		if(APLRes:dummy!=APLRes_Success) {
			LogError("AskPluginLoad2Custom did not return true, possible failure");
		}
	}
	func=GetFunctionByName(plugin, "LoadCheck");
	if(func!=INVALID_FUNCTION) { //non war3 plugins dont have this function
		Call_StartFunction(plugin, func);
		Call_Finish(dummy);
		if(dummy==0) {
			return APLRes_SilentFailure;
		}
	}
/*
	func=GetFunctionByName(plugin, "OnWar3SourceReady");
	if(func!=INVALID_FUNCTION) { //after all war3source_natives_loaded
		Call_StartFunction(plugin, func);
		Call_Finish(dummy);
		if(!dummy) {
			LogError("OnWar3SourceReady did not return true, possible failure");
		}
	}
*/
	RegPluginLibrary("War3Source");
//#if defined _steamtools_included
	//MarkNativeAsOptional("Steam_SetGameDescription");
//#endif
	return APLRes_Success;
}

//=============================================================================
// AskPluginLoad2Custom
//=============================================================================
public APLRes:AskPluginLoad2Custom(Handle:myself,bool:late,String:error[],err_max)
{

	//PrintToServer("<< War3Source:EVO is Loading >>");
	PrintToServer("");
	PrintToServer("");
	PrintToServer(" #     #    #    ######   #####   #####  ####### #     # ######   #####  ####### ");
	PrintToServer(" #  #  #   # #   #     # #     # #     # #     # #     # #     # #     # #       ");
	PrintToServer(" #  #  #  #   #  #     #       # #       #     # #     # #     # #       #       ");
	PrintToServer(" #  #  # #     # ######   #####   #####  #     # #     # ######  #       #####   ");
	PrintToServer(" #  #  # ####### #   #         #       # #     # #     # #   #   #       #       ");
	PrintToServer(" #  #  # #     # #    #  #     # #     # #     # #     # #    #  #     # #       ");
	PrintToServer("  ## ##  #     # #     #  #####   #####  #######  #####  #     #  #####  ####### ");
	PrintToServer("");
	PrintToServer("");
	PrintToServer(" ####### #     # ####### #       #     # ####### ### ####### #     # ");
	PrintToServer(" #       #     # #     # #       #     #    #     #  #     # ##    # ");
	PrintToServer(" #       #     # #     # #       #     #    #     #  #     # # #   # ");
	PrintToServer(" #####   #     # #     # #       #     #    #     #  #     # #  #  # ");
	PrintToServer(" #        #   #  #     # #       #     #    #     #  #     # #   # # ");
	PrintToServer(" #         # #   #     # #       #     #    #     #  #     # #    ## ");
	PrintToServer(" #######    #    ####### #######  #####     #    ### ####### #     # ");
	PrintToServer("");
	PrintToServer("");
	PrintToServer("");
	PrintToServer("");
	PrintToServer("");

#if (GGAMETYPE == GGAME_TF2)
			PrintToServer("#######    #######     #####  ");
			PrintToServer("   #       #          #     # ");
			PrintToServer("   #       #                # ");
			PrintToServer("   #       #####       #####  ");
			PrintToServer("   #       #          #       ");
			PrintToServer("   #       #          #       ");
			PrintToServer("   #       #          ####### ");

#elseif (GGAMETYPE == GGAME_CSS)

			PrintToServer(" #####      #####      #####  ");
			PrintToServer("#     #    #     #    #     # ");
			PrintToServer("#          #          #       ");
			PrintToServer("#           #####      #####  ");
			PrintToServer("#                #          # ");
			PrintToServer("#     #    #     #    #     # ");
			PrintToServer(" #####      #####      #####  ");

#elseif (GGAMETYPE == GGAME_CSGO)

			PrintToServer(" #####      #####      #####     ####### ");
			PrintToServer("#     #    #     #    #     #    #     # ");
			PrintToServer("#          #          #          #     # ");
			PrintToServer("#           #####     #  ####    #     # ");
			PrintToServer("#                #    #     #    #     # ");
			PrintToServer("#     #    #     #    #     #    #     # ");
			PrintToServer(" #####      #####      #####     ####### ");

#elseif (GGAMETYPE == GGAME_FOF)

			PrintToServer("#######    #######    ####### ");
			PrintToServer("#          #     #    #       ");
			PrintToServer("#          #     #    #       ");
			PrintToServer("#####      #     #    #####   ");
			PrintToServer("#          #     #    #       ");
			PrintToServer("#          #     #    #       ");
			PrintToServer("#          #######    #       ");

#else
			PrintToServer("UNKNOWN GAME"):
#endif

	char version[64];
	Format(version,sizeof(version),"%s by %s",VERSION_NUM,AUTHORS);
	char Eversion[64];
	Format(Eversion,sizeof(Eversion),"Contributions by %s",eAUTHORS);
	CreateConVar("war3e_version",version,"War3Source:EVO version.",FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	CreateConVar("credits",Eversion,".",FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);

	CreateNative("W3Paused",NW3Paused);

	if(!War3Source_InitNatives())
	{
		LogError("[War3Source:EVO] There was a failure in creating the native based functions, definately halting.");
		return APLRes_Failure;
	}

	PrintToServer("PASSED War3Source_InitNatives");

	if(!War3Source_InitForwards())
	{
		LogError("[War3Source:EVO] There was a failure in creating the forward based functions, definately halting.");
		return APLRes_Failure;
	}

	PrintToServer("PASSED War3Source_InitForwards");

//=============================
// War3Source_000_Engine_Log
//=============================
	new String:path_log[1024];
	BuildPath(Path_SM,path_log,sizeof(path_log),"logs/war3sourcelog.txt");
	new Handle:hFile=OpenFile(path_log,"a+");
	if(hFile)
	{
		CloseHandle(hFile);
		// using this file for war3bug, why delete it on restart???
		//DeleteFile(path_log);

	}

	hW3Log=OpenFile(path_log,"a+");

	BuildPath(Path_SM,path_log,sizeof(path_log),"logs/war3sourceerrorlog.txt");
	hW3LogError=OpenFile(path_log,"a+");




	BuildPath(Path_SM,path_log,sizeof(path_log),"logs/war3sourcenoterrorlog.txt");
	hFile=OpenFile(path_log,"a+");
	if(hFile)
	{
		CloseHandle(hFile);
		DeleteFile(path_log);
	}
	hW3LogNotError=OpenFile(path_log,"a+");

	PrintToServer("PASSED War3Source_000_Engine_Log");

	return APLRes_Success;
}
//=============================================================================
// OnAllPluginsLoaded
//=============================================================================
public OnAllPluginsLoaded()
{
	PrintToServer("War3Source:EVO OnAllPluginsLoaded");
	ConnectDB();
}
//=============================================================================
// OnGetGameDescription
//=============================================================================
public Action:OnGetGameDescription(String:gameDesc[64])
{
	if(GetConVarInt(hChangeGameDescCvar)>0)
	{
		Format(gameDesc,sizeof(gameDesc),"War3Source %s",VERSION_NUM);
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

//=============================================================================
// LoadRacesAndItems
//=============================================================================
LoadRacesAndItems()
{
	PrintToServer("RACE ITEM LOAD");
	PrintToServer("RACE ITEM LOAD");
	PrintToServer("RACE ITEM LOAD");
	float starttime=GetEngineTime();
	//ordered loads
	int res;
	for(int i;i<=MAXRACES*30;i++) // 3000
	{
		//PrintToServer("LoadRacesAndItems #1 i = ", i);
		Call_StartForward(g_OnWar3PluginReadyHandle);
		Call_PushCell(i);
		//Call_PushCell(-1); //removed for backwards compatbility.
		Call_Finish(res);
	}

	//orderd loads 2
	for(int i;i<=MAXRACES*30;i++) // 3000
	{
		//PrintToServer("LoadRacesAndItems #2 i = ", i);
		//DoForward_OnWar3LoadRaceOrItemOrdered2(i,-1,"");
		Call_StartForward(g_OnWar3PluginReadyHandle2);
		Call_PushCell(i);
		Call_PushCell(-1);
		Call_PushString("");
		Call_Finish(res);
	}

	//unorderd loads
	Call_StartForward(g_OnWar3PluginReadyHandle3);
	Call_Finish(res);

	//War3Source_Engine_BotControl
	War3Source_BotControl_LoadRacesAndItems();

	PrintToServer("RACE ITEM LOAD FINISHED IN %.2f seconds",GetEngineTime()-starttime);
	PrintToServer("RACE ITEM LOAD FINISHED IN %.2f seconds",GetEngineTime()-starttime);
	PrintToServer("RACE ITEM LOAD FINISHED IN %.2f seconds",GetEngineTime()-starttime);

	DelayedWar3SourceCfgExecute();

}
//=============================================================================
// DelayedWar3SourceCfgExecute
//=============================================================================
DelayedWar3SourceCfgExecute()
{
	PrintToServer("[War3Source:EVO] DelayedWar3SourceCfgExecute()");
#if (GGAMETYPE == GGAME_TF2)
	if(FileExists("cfg/war3source_tf2.cfg"))
	{
		ServerCommand("exec war3source_tf2.cfg");
		PrintToServer("[War3Source] Executing war3source_tf2.cfg");
	}
	else
	{
		PrintToServer("[War3Source] Could not find war3source_tf2.cfg, we recommend all servers have this file");
		PrintToServer("[War3Source] Trying to load cfg/war3source.cfg instead...");
		if(FileExists("cfg/war3source.cfg"))
		{
			ServerCommand("exec war3source.cfg");
			PrintToServer("[War3Source] Executing war3source.cfg");
		}
		else
		{
			PrintToServer("[War3Source] Could not find war3source.cfg.");
		}
	}
#elseif (GGAMETYPE == GGAME_CSGO)
	if(FileExists("cfg/war3source_csgo.cfg"))
	{
		ServerCommand("exec war3source_csgo.cfg");
		PrintToServer("[War3Source] Executing war3source_csgo.cfg");
	}
	else
	{
		PrintToServer("[War3Source] Could not find war3source_csgo.cfg, we recommend all servers have this file");
		PrintToServer("[War3Source] Trying to load cfg/war3source.cfg instead...");
		if(FileExists("cfg/war3source.cfg"))
		{
			ServerCommand("exec war3source.cfg");
			PrintToServer("[War3Source] Executing war3source.cfg");
		}
		else
		{
			PrintToServer("[War3Source] Could not find war3source.cfg.");
		}
	}
#elseif (GGAMETYPE == GGAME_FOF)
	if(FileExists("cfg/war3source_fof.cfg"))
	{
		ServerCommand("exec war3source_fof.cfg");
		PrintToServer("[War3Source] Executing war3source_fof.cfg");
	}
	else
	{
		PrintToServer("[War3Source] Could not find war3source_fof.cfg, we recommend all servers have this file");
		PrintToServer("[War3Source] Trying to load cfg/war3source.cfg instead...");
		if(FileExists("cfg/war3source.cfg"))
		{
			ServerCommand("exec war3source.cfg");
			PrintToServer("[War3Source] Executing war3source.cfg");
		}
		else
		{
			PrintToServer("[War3Source] Could not find war3source.cfg.");
		}
	}
#elseif (GGAMETYPE == GGAME_CSS)
	if(FileExists("cfg/war3source_css.cfg"))
	{
		ServerCommand("exec war3source_css.cfg");
		PrintToServer("[War3Source] Executing war3source_css.cfg");
	}
	else
	{
		PrintToServer("[War3Source] Could not find war3source_css.cfg, we recommend all servers have this file");
		PrintToServer("[War3Source] Trying to load cfg/war3source.cfg instead...");
		if(FileExists("cfg/war3source.cfg"))
		{
			ServerCommand("exec war3source.cfg");
			PrintToServer("[War3Source] Executing war3source.cfg");
		}
		else
		{
			PrintToServer("[War3Source] Could not find war3source.cfg.");
		}
	}
#else
	if(FileExists("cfg/war3source_other.cfg"))
	{
		ServerCommand("exec war3source_other.cfg");
		PrintToServer("[War3Source] Executing war3source_other.cfg");
	}
	else
	{
		PrintToServer("[War3Source] Could not find war3source configuration file, we recommend all servers have this file");
		PrintToServer("[War3Source] Trying to load cfg/war3source.cfg instead...");
		if(FileExists("cfg/war3source.cfg"))
		{
			ServerCommand("exec war3source.cfg");
			PrintToServer("[War3Source] Executing war3source.cfg");
		}
		else
		{
			PrintToServer("[War3Source] Could not find war3source.cfg.");
		}
	}
#endif

#if (GGAMETYPE == GGAME_TF2)
	//if (IsMvM(true))
	//{
#if (GGAMETYPE2 == GGAME_MVM)
		if(FileExists("cfg/war3sourceMVM.cfg"))
		{
			ServerCommand("exec war3sourceMVM.cfg");
			PrintToServer("[War3Source] Executing war3sourceMVM.cfg");
		}
		else
		{
			PrintToServer("[War3Source] Could not find war3sourceMVM.cfg, we recommend all servers have this file");
		}
#endif
	//}
#endif

	// executes global war3source.cfg file
	if(FileExists("cfg/war3source.cfg"))
	{
			ServerCommand("exec war3source.cfg");
			PrintToServer("[War3Source] Executing war3source.cfg");
	}

}
//=============================================================================
// War3Source_HookEvents
//=============================================================================
stock bool War3Source_HookEvents()
{
	PrintToServer("[War3Source:EVO] War3Source_HookEvents() START");
	// Events for all games
	if(!HookEventEx("player_spawn",War3Source_PlayerSpawnEvent,EventHookMode_Pre)) //,EventHookMode_Pre
	{
		PrintToServer("[War3Source] Could not hook the player_spawn event.");
		return false;
	}
	if(!HookEventEx("player_death",War3Source_PlayerDeathEvent,EventHookMode_Pre))
	{
		PrintToServer("[War3Source] Could not hook the player_death event.");
		return false;
	}
/*
	if(!HookEventEx("teamplay_round_win",War3Source_RoundOverEvent))
	{
		PrintToServer("[War3Source] Could not hook the teamplay_round_win event.");
		return false;
	}
*/
	PrintToServer("[War3Source:EVO] War3Source_HookEvents() END");
	return true;

}
//=============================================================================
// DoForward_OnWar3EventSpawn
//=============================================================================
DoForward_OnWar3EventSpawn(client)
{
		PrintToServer("[War3Source:EVO] DoForward_OnWar3EventSpawn()");
		Call_StartForward(p_OnWar3EventSpawnFH);
		Call_PushCell(client);
		Call_Finish(dummyreturn);
		// Change Skin after all other changes (-1 = let the engine handle the race stuff)
		Internal_OnSkinChange(client, -1);
}
//=============================================================================
// DoForward_OnWar3EventDeath
//=============================================================================
DoForward_OnWar3EventDeath(victim,killer,deathrace,distance,attacker_hpleft)
{
		PrintToServer("[War3Source:EVO] DoForward_OnWar3EventDeath()");
		Call_StartForward(g_OnWar3EventDeathFH);
		Call_PushCell(victim);
		Call_PushCell(killer);
		Call_PushCell(deathrace);
		Call_PushCell(distance);
		Call_PushCell(attacker_hpleft);
		Call_Finish(dummyreturn);
}
//=============================================================================
// NW3GetW3Revision
//=============================================================================
public NW3GetW3Revision(Handle:plugin,numParams){
	return REVISION_NUM;
}
//=============================================================================
// NW3GetW3Version
//=============================================================================
public NW3GetW3Version(Handle:plugin,numParams){
	SetNativeString(1,VERSION_NUM,GetNativeCell(2));
}
//=============================================================================
// Native_War3_InFreezeTime
//=============================================================================
public Native_War3_InFreezeTime(Handle:plugin,numParams)
{
	return (bInFreezeTime)?1:0;
}

//=============================================================================
// hCvarLoadRacesAndItemsOnMapStartChanged
//=============================================================================
public hCvarLoadRacesAndItemsOnMapStartChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	LoadRacesAndItemsOnMapStart=GetConVarBool(hCvarLoadRacesAndItemsOnMapStart);
}

stock GetEntityAlpha(index)
{
	return GetEntData(index,m_OffsetClrRender+3,1);
}

stock GetPlayerR(index)
{
	return GetEntData(index,m_OffsetClrRender,1);
}

stock GetPlayerG(index)
{
	return GetEntData(index,m_OffsetClrRender+1,1);
}

stock GetPlayerB(index)
{
	return GetEntData(index,m_OffsetClrRender+2,1);
}

stock SetPlayerRGB(index,r,g,b)
{
	SetEntityRenderMode(index,RENDER_TRANSCOLOR);
	SetEntityRenderColor(index,r,g,b,GetEntityAlpha(index));
}

public NW3Paused(Handle:plugin,numParams)
{
	return War3SourcePause;
}
