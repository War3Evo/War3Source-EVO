// War3Source_Engine_PlayerClass.sp

//#assert GGAMEMODE == MODE_WAR3SOURCE



new p_xp[MAXPLAYERSCUSTOM][MAXRACES];
new p_level[MAXPLAYERSCUSTOM][MAXRACES];
new p_skilllevel[MAXPLAYERSCUSTOM][MAXRACES][MAXSKILLCOUNT];

new bool:bResetSkillsOnSpawn[MAXPLAYERSCUSTOM];
new RaceIDToReset[MAXPLAYERSCUSTOM];


new String:levelupSound[256]; //="war3source/levelupcaster.mp3";



new Handle:g_On_Race_Changed;
//new Handle:g_On_Race_Selected;
new Handle:g_OnSkillLevelChangedHandle;

new Handle:g_OnWar3RaceEnabled;
new Handle:g_OnWar3RaceDisabled;

/*
public Plugin:myinfo=
{
	name="W3S Engine player class",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};
*/
Handle hRaceEnableOrDisableCvar;
Handle hRaceEnableOrDisableFullCvar;

public War3Source_Engine_PlayerClass_OnPluginStart()
{
	RegConsoleCmd("war3notdev",cmdwar3notdev);

	RegAdminCmd("war3_all_races_enabled", cmdwar3RaceDynamicLoadingOn, ADMFLAG_ROOT, "war3_all_races_enabled");
	RegAdminCmd("war3_all_races_disabled", cmdwar3RaceDynamicLoadingOff, ADMFLAG_ROOT, "war3_all_races_disabled");

	// sets everything to default loading
	RegAdminCmd("war3_enable_race_dynamic_loading", cmdwar3EnableRaceDynamicLoading, ADMFLAG_ROOT, "war3_enable_race_dynamic_loading");
	HookEvent("player_team", Event_PlayerTeam);

	// If set to 1, it will enable / disable races automatically.
	// if set to 0, it will enable races automatically and not disable them.
	hRaceEnableOrDisableCvar=CreateConVar("war3_race_dynamic_loading","1","1 to enable, 0 to disable");

	// does not allow enabling or disabling of races
	// Do not set this to 1 on start up or no races willl be enabled!
	hRaceEnableOrDisableFullCvar=CreateConVar("war3_race_dynamic_loading_fulldisable","0","1 to enable, 0 to disable");
}


public War3Source_Engine_PlayerClass_OnAddSound(sound_priority)
{
	if(sound_priority==PRIORITY_LOW)
	{
		strcopy(levelupSound,sizeof(levelupSound),"war3source/levelupcaster.mp3");
		War3_AddSound(levelupSound);
	}
}

public bool:War3Source_Engine_PlayerClass_InitNativesForwards()
{
	g_On_Race_Changed=CreateGlobalForward("OnRaceChanged",ET_Ignore,Param_Cell,Param_Cell,Param_Cell);
	//No longer use:
	//g_On_Race_Selected=CreateGlobalForward("OnRaceSelected",ET_Ignore,Param_Cell,Param_Cell);
	g_OnSkillLevelChangedHandle=CreateGlobalForward("OnSkillLevelChanged",ET_Ignore,Param_Cell,Param_Cell,Param_Cell,Param_Cell,Param_Cell);

	g_OnWar3RaceEnabled=CreateGlobalForward("OnWar3RaceEnabled",ET_Ignore,Param_Cell);
	g_OnWar3RaceDisabled=CreateGlobalForward("OnWar3RaceDisabled",ET_Ignore,Param_Cell);

	return true;
}

public bool:War3Source_Engine_PlayerClass_InitNatives()
{
	CreateNative("War3_SetRace",NWar3_SetRace);
	CreateNative("War3_GetRace",NWar3_GetRace);

	CreateNative("War3_SetLevel",NWar3_SetLevel);
	CreateNative("War3_GetLevel",NWar3_GetLevel);
	CreateNative("War3_GetLevelEx",NWar3_GetLevelEx);

	CreateNative("War3_SetXP",NWar3_SetXP);
	CreateNative("War3_GetXP",NWar3_GetXP);

	//these return false if the player is not this race
	//CreateNative("War3_SetSkillLevel",NWar3_SetSkillLevel);
	CreateNative("War3_GetSkillLevel",NWar3_GetSkillLevel);

	//these return the skill without accounting if there are the current race
	CreateNative("War3_SetSkillLevelINTERNAL",NWar3_SetSkillLevelINTERNAL);
	CreateNative("War3_GetSkillLevelINTERNAL",NWar3_GetSkillLevelINTERNAL);

	CreateNative("W3SetPlayerProp",NW3SetPlayerProp);
	CreateNative("W3GetPlayerProp",NW3GetPlayerProp);

	CreateNative("W3GetTotalLevels",NW3GetTotalLevels);
	CreateNative("W3GetLevelsSpent",NW3GetLevelsSpent);
	CreateNative("W3ClearSkillLevels",NW3ClearSkillLevels);
	return true;
}

public void EnableRace(newrace)
{
	if(GetConVarBool(hRaceEnableOrDisableFullCvar)) return;

	// Enable new race
	Call_StartForward(g_OnWar3RaceEnabled);
	Call_PushCell(newrace);
	Call_Finish(dummy);

	//new String:rName[128];
	//War3_GetRaceName(newrace,rName,sizeof(rName));
	//PrintToServer("Race Enabled: %s",rName);
	//DP("Race Enabled: %s",rName);

}

public void DisableRace(oldrace)
{
	if(!GetConVarBool(hRaceEnableOrDisableCvar)) return;
	if(GetConVarBool(hRaceEnableOrDisableFullCvar)) return;

	new iRaceCount=0;
	for(new i=1;i<=MaxClients;i++)
	{
		if(GetRace(i)==oldrace)
		{
			iRaceCount++;
		}
	}

	if(iRaceCount==0)
	{
		// disable unused race
		Call_StartForward(g_OnWar3RaceDisabled);
		Call_PushCell(oldrace);
		Call_Finish(dummy);

		//new String:rName[128];
		//War3_GetRaceName(oldrace,rName,sizeof(rName));
		//PrintToServer("Race Disabled: %s",rName);
		//DP("Race Disabled: %s",rName);
	}
}

public Action:cmdwar3RaceDynamicLoadingOn(client,args){
	new RacesLoaded = internal_GetRacesLoaded();
	new String:LongRaceName[32];
	for(new x=1;x<=RacesLoaded;x++)
	{
		Call_StartForward(g_OnWar3RaceEnabled);
		Call_PushCell(x);
		Call_Finish(dummy);
		GetRaceName(x,LongRaceName,sizeof(LongRaceName));
		PrintToConsole(client,"%s Enabled",LongRaceName);
	}

	return Plugin_Handled;
}

public Action:cmdwar3RaceDynamicLoadingOff(client,args){
	new RacesLoaded = internal_GetRacesLoaded();
	new String:LongRaceName[32];
	for(new x=1;x<=RacesLoaded;x++)
	{

		Call_StartForward(g_OnWar3RaceDisabled);
		Call_PushCell(x);
		Call_Finish(dummy);
		GetRaceName(x,LongRaceName,sizeof(LongRaceName));
		PrintToConsole(client,"%s Disabled",LongRaceName);
	}

	return Plugin_Handled;
}


public Action:cmdwar3EnableRaceDynamicLoading(client,args){
	SetConVarInt(hRaceEnableOrDisableCvar, 1);
	SetConVarInt(hRaceEnableOrDisableFullCvar, 0);
	new RacesLoaded = internal_GetRacesLoaded();
	new String:LongRaceName[32];
	new iRaceCount=0;
	for(new x=1;x<=RacesLoaded;x++)
	{
		iRaceCount=0;

		for(new i=1;i<=MaxClients;i++)
		{
			if(GetRace(i)==x)
			{
				iRaceCount++;
			}
		}

		if(iRaceCount==0)
		{
			Call_StartForward(g_OnWar3RaceDisabled);
			Call_PushCell(x);
			Call_Finish(dummy);
			GetRaceName(x,LongRaceName,sizeof(LongRaceName));
			PrintToConsole(client,"%s Disabled",LongRaceName);
		}
		else
		{
			Call_StartForward(g_OnWar3RaceEnabled);
			Call_PushCell(x);
			Call_Finish(dummy);
			GetRaceName(x,LongRaceName,sizeof(LongRaceName));
			PrintToConsole(client,"%s Enabled",LongRaceName);
		}
	}

	return Plugin_Handled;
}

stock SetRace(client,newrace)
{
	if(newrace<0||newrace>internal_GetRacesLoaded()){
		W3LogError("WARNING SET INVALID RACE for client %d to race %d",client,newrace);
		return;
	}
	if (client > 0 && client <= MaxClients)
	{
		new oldrace=p_properties[client][CurrentRace];
		if(oldrace==newrace){
			//WTF ABORT
			return;
		}
		else{
			EnableRace(newrace);

			internal_W3SetVar(OldRace,p_properties[client][CurrentRace]);

			if(oldrace>0&&ValidPlayer(client)){
				W3SaveXP(client,oldrace);
			}


			p_properties[client][CurrentRace]=newrace;

			// Change Race First before setting the new skills!

			Internal_On_Race_Changed(client,oldrace,newrace);

			//announce race change
			Call_StartForward(g_On_Race_Changed);
			Call_PushCell(client);
			Call_PushCell(oldrace);
			Call_PushCell(newrace);
			Call_Finish(dummy);

			// Change Skin after all other changes
			Internal_OnSkinChange(client, newrace);

			// this makes no sense (We should only send for the new race or current race):
			/*
			if(oldrace>0){
				//we move all the old skill levels (apparrent ones)
				for(new i=1;i<=GetRaceSkillCount(oldrace);i++){
					Call_StartForward(g_OnSkillLevelChangedHandle);
					Call_PushCell(client);
					Call_PushCell(oldrace);
					Call_PushCell(i); //i is skillid
					Call_PushCell(0); //force 0
					Call_PushCell(0); //force 0
					Call_Finish(dummy);
				}
			}*/
			if(newrace>0)
			{
				for(int i=1;i<=GetRaceSkillCount(newrace);i++)
				{
					Call_StartForward(g_OnSkillLevelChangedHandle);
					Call_PushCell(client);
					Call_PushCell(newrace);
					Call_PushCell(i); //i is skillid
					Call_PushCell(War3_GetSkillLevelINTERNAL(client,newrace,i)); //i is skillid
					Call_PushCell(0); //force 0
					Call_Finish(dummy);
				}
			}

			//REMOVE DEPRECATED
			//Call_StartForward(g_On_Race_Selected);
			//Call_PushCell(client);
			//Call_PushCell(newrace);
			//Call_Finish(dummy);

			if(newrace>0) {
				if(IsPlayerAlive(client)){
					War3_EmitSoundToAll(levelupSound,client);
				}
				else{
					War3_EmitSoundToClient(client,levelupSound);
				}

				if(W3SaveEnabled()){ //save enabled
				}
				else {//if(oldrace>0)
					SetXP(client,newrace,War3_GetXP(client,oldrace));
					SetLevel(client,newrace,War3_GetLevel(client,oldrace));
					W3DoLevelCheck(client);
				}

				decl String:buf[32];
				GetRaceName(newrace,buf,sizeof(buf));
				War3_ChatMessage(client,"%T","You are now {racename}",client,buf);

				//if(oldrace==0){
				//	War3_ChatMessage(client,"%T","say war3bug <description> to file a bug report",client);
				//}
				DoFwd_War3_Event(DoCheckRestrictedItems,client);
			}

			// Signal Enable / Disable Race Events
		}
		DisableRace(oldrace);
	}
	return;
}

public NWar3_SetRace(Handle:plugin,numParams){

	//set old race
	new client=GetNativeCell(1);
	new race=GetNativeCell(2);
	SetRace(client,race);
}

stock GetRace(client)
{
	if (client > 0 && client <= MaxClients)
		return p_properties[client][CurrentRace];
	return -2; //return -2 because u usually compare your race
}

public NWar3_GetRace(Handle:plugin,numParams){
	new client = GetNativeCell(1);
	return GetRace(client);
}

SetLevel(client,race,level)
{
	if (client > 0 && client <= MaxClients && race > 0 && race < MAXRACES)
	{
		//new String:name[32];
		//GetPluginFilename(plugin,name,sizeof(name));
		//DP("SETLEVEL %d %s",GetNativeCell(3),name);
		p_level[client][race]=level;
		return 1;
	}
	return 0;
}

public NWar3_SetLevel(Handle:plugin,numParams){
	new client = GetNativeCell(1);
	new race = GetNativeCell(2);
	new level = GetNativeCell(3);
	return SetLevel(client,race,level);
}

public NWar3_GetLevel(Handle:plugin,numParams){
	new client = GetNativeCell(1);
	new race = GetNativeCell(2);
	if (client > 0 && client <= MaxClients && race > 0 && race < MAXRACES)
	{
		//DP("%d",p_level[client][race]);
		new level=p_level[client][race];
		if(level>GetRaceMaxLevel(race))
			level=GetRaceMaxLevel(race);
		return level;
	}
	//else
	return 0;
}

public NWar3_GetLevelEx(Handle:plugin,numParams){
	new client = GetNativeCell(1);
	new race = GetNativeCell(2);
	new bool:truelevel = GetNativeCell(3);
	if (client > 0 && client <= MaxClients && race > 0 && race < MAXRACES)
	{
		//DP("%d",p_level[client][race]);
		if(truelevel==true)
		{
			return p_level[client][race];
		}
		else
		{
			new level=p_level[client][race];
			if(level>GetRaceMaxLevel(race))
			{
				level=GetRaceMaxLevel(race);
				return level;
			}
		}
	}
	//else
	return 0;
}

stock SetXP(client,race,xp)
{
	if (client > 0 && client <= MaxClients && race > 0 && race < MAXRACES)
	{
		p_xp[client][race]=xp;
		return 1;
	}
	return 0;
}

public NWar3_SetXP(Handle:plugin,numParams){
	return SetXP(GetNativeCell(1),GetNativeCell(2),GetNativeCell(3));
}

stock GetXP(client,race)
{
	if (client > 0 && client <= MaxClients && race > 0 && race < MAXRACES)
		return p_xp[client][race];
	else
		return 0;
}
public NWar3_GetXP(Handle:plugin,numParams){
	new client = GetNativeCell(1);
	new race = GetNativeCell(2);
	return GetXP(client,race);
}

///this non INTERNAL may be deprecated
/*
public NWar3_SetSkillLevel(Handle:plugin,numParams){
	new client=GetNativeCell(1);
	new race=GetNativeCell(2);
	new skill=GetNativeCell(3);
	new level=GetNativeCell(4);
	if (client > 0 && client <= MaxClients && race >= 0 && race < MAXRACES)
	{
		p_skilllevel[client][race][skill]=level;
		Call_StartForward(g_OnSkillLevelChangedHandle);
		Call_PushCell(client);
		Call_PushCell(race);
		Call_PushCell(skill);
		Call_PushCell(level);
		Call_Finish(dummy);
	}

}*/

stock GetSkillLevel(client,race,skill)
{
	if (client > 0 && client <= MaxClients && race >= 0 && race < MAXRACES && GetRace(client)==race && skill >0 && skill < MAXSKILLCOUNT)
	{
		return p_skilllevel[client][race][skill];
	}
	else
		return 0;
}
public NWar3_GetSkillLevel(Handle:plugin,numParams){
	return GetSkillLevel(GetNativeCell(1),GetNativeCell(2),GetNativeCell(3));
}

stock void SetSkillLevelINTERNAL(int client, int race, int skill, int level)
{
	if (client > 0 && client <= MaxClients && race >= 0 && race < MAXRACES)
	{
		int oldlevel=p_skilllevel[client][race][skill];
		p_skilllevel[client][race][skill]=level;
		if(GetRace(client)==race)
		{
			Call_StartForward(g_OnSkillLevelChangedHandle);
			Call_PushCell(client);
			Call_PushCell(race);
			Call_PushCell(skill);
			Call_PushCell(level);
			Call_PushCell(oldlevel);
			Call_Finish(dummy);
		}
	}
}

public NWar3_SetSkillLevelINTERNAL(Handle:plugin,numParams)
{
	int client=GetNativeCell(1);
	int race=GetNativeCell(2);
	int skill=GetNativeCell(3);
	int level=GetNativeCell(4);
	SetSkillLevelINTERNAL(client,race,skill,level);
}
public NWar3_GetSkillLevelINTERNAL(Handle:plugin,numParams){
	new client=GetNativeCell(1);
	new race=GetNativeCell(2);
	new skill=GetNativeCell(3);
	if (client > 0 && client <= MaxClients && race >= 0 && race < MAXRACES && skill >0 && skill < MAXSKILLCOUNT)
	{
		return p_skilllevel[client][race][skill];
	}
	else
		return 0;
}

stock GetPlayerProp(client,W3PlayerProp:property)
{
	if (client > 0 && client <= MaxClients)
	{
		return p_properties[client][property];
	}
	else
		return 0;
}

public NW3GetPlayerProp(Handle:plugin,numParams)
{
	return GetPlayerProp(GetNativeCell(1),W3PlayerProp:GetNativeCell(2));
}

stock SetPlayerProp(client,W3PlayerProp:property,any:value)
{
	if (client > 0 && client <= MaxClients)
	{
		p_properties[client][property]=value;
	}
}

public NW3SetPlayerProp(Handle:plugin,numParams){
	SetPlayerProp(GetNativeCell(1),W3PlayerProp:GetNativeCell(2),any:GetNativeCell(3));
}

stock GetTotalLevels(client)
{
	//new client=GetNativeCell(1);
	new total_level=0;
	if (client > 0 && client <= MaxClients)
	{
		new racesLoaded = internal_GetRacesLoaded();
		for(new r=1;r<=racesLoaded;r++)
		{
			total_level+=War3_GetLevel(client,r);
		}
	}
	return  total_level;
}

public NW3GetTotalLevels(Handle:plugin,numParams){
	return GetTotalLevels(GetNativeCell(1));
}
public internal_ClearSkillLevels(client,race)
{
	if (client > 0 && client <= MaxClients)
	{
		int iRaceSkillCount = GetRaceSkillCount(race);
		for(int i=1;i<=iRaceSkillCount;i++)
		{
			War3_SetSkillLevelINTERNAL(client,race,i,0);
		}
	}
}
public NW3ClearSkillLevels(Handle:plugin,numParams)
{
	int client=GetNativeCell(1);
	if (client > 0 && client <= MaxClients)
	{
		int race=GetNativeCell(2);
		internal_ClearSkillLevels(client,race);
	}
}

stock GetLevelsSpent(client,race)
{
	//new client=GetNativeCell(1);
	//new race=GetNativeCell(2);
	new ret=0;
	if (client > 0 && client <= MaxClients && race > 0 && race < MAXRACES)
	{
		new iRaceSkillCount = GetRaceSkillCount(race);
		for(new i=1;i<=iRaceSkillCount;i++)
			ret+=War3_GetSkillLevelINTERNAL(client,race,i);
	}
	return ret;
}

public NW3GetLevelsSpent(Handle:plugin,numParams)
{
	return GetLevelsSpent(GetNativeCell(1),GetNativeCell(2));
}


public Event_PlayerTeam(Handle:event,  const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	SetPlayerProp(client,LastChangeTeamTime,GetEngineTime());
}



public Action:cmdwar3notdev(client,args){
	if(ValidPlayer(client)){
		SetPlayerProp(client,isDeveloper,false);

	}
	return Plugin_Handled;
}

public War3Source_Engine_PlayerClass_OnWar3Event(W3EVENT:event,client)
{
	if(event==InitPlayerVariables)
	{
		char steamid[32];
		GetClientAuthId(client,AuthId_Steam2,STRING(steamid),true);

		// Old Developer Steam ids:
		//if(StrEqual(steamid,"STEAM_0:1:9724315",false)||StrEqual(steamid,"STEAM_0:1:6121386",false)||StrEqual(steamid,"STEAM_0:0:11672517",false)){

		// Default 0 for war3_allow_developer_access convar
		// If requested by developer you can use war3_allow_developer_access 1 to allow
		// developer access, but developer will need to reconnect to gain those powers.
		if(GetConVarBool(gh_AllowDeveloperAccess))
		{
			// El Diablo's Steam ID
			if(StrEqual(steamid,"STEAM_0:1:35173666",false))
			{
				SetPlayerProp(client,isDeveloper,true);    // Default is true
			}
		}

		//items 2 remembered in ext, on unload it won't be cleared
		// BOTS don't use shopmenu2 or shopmenu3
		if(!IsFakeClient(client))
		{
			for(new i=0;i<MAXITEMS2;i++)
			{
				internal_W3SetVar(TheItemBoughtOrLost,i);
				DoFwd_War3_Event(DoForwardClientLostItem2,client);
			}
			for(new h=1;h<MAXRACES;h++)
			{
				internal_W3SetVar(TheRaceItemBoughtOrLost,h);
				for(new i=0;i<MAXITEMS3;i++){
					internal_W3SetVar(TheItemBoughtOrLost,i);
					DoFwd_War3_Event(DoForwardClientLostItem3,client);
				}
			}
		}
	}
	else if(event==ClearPlayerVariables){
		//set xp loaded first, to block saving xp after race change
		SetPlayerProp(client,xpLoaded,false);
		for(new i=0;i<MAXRACES;i++)
		{
			SetLevel(client,i,0);
			SetXP(client,i,0);
			for(new x=1;x<MAXSKILLCOUNT;x++)
			{
				War3_SetSkillLevelINTERNAL(client,i,x,0);
			}
		}

		for(new i=0;i<MAXITEMS;i++)
		{
			internal_W3SetVar(TheItemBoughtOrLost,i);
			DoFwd_War3_Event(DoForwardClientLostItem,client);
		}

		// clear all buffs from races
		for(new i=0;i<MAXRACES;i++)
		{
			// client, raceID
			W3ResetAllBuffRace(client, i);
		}

		// BOTS don't use shopmenu2 or shopmenu3
		if(!IsFakeClient(client))
		{
			for(new i=0;i<MAXITEMS2;i++)
			{
				internal_W3SetVar(TheItemBoughtOrLost,i);
				DoFwd_War3_Event(DoForwardClientLostItem2,client);
			}
			for(new h=1;h<MAXRACES;h++)
			{
				internal_W3SetVar(TheRaceItemBoughtOrLost,h);
				for(new i=0;i<MAXITEMS3;i++){
					internal_W3SetVar(TheItemBoughtOrLost,i);
					DoFwd_War3_Event(DoForwardClientLostItem3,client);
				}
			}
		}


		SetPlayerProp(client,PendingRace,0);
		War3_SetRace(client,0); //need the race change event fired
		SetPlayerProp(client,dbRaceSelected,false);
		SetPlayerProp(client,PlayerGold,0);
		War3_SetDiamonds(client,0);
		War3_SetPlatinum(client,0);
		//DP("DERP");
		SetPlayerProp(client,iMaxHP,0);
		SetPlayerProp(client,bIsDucking,false);

		SetPlayerProp(client,RaceChosenTime,0.0);
		SetPlayerProp(client,RaceSetByAdmin,false);
		SetPlayerProp(client,SpawnedOnce,false);
		SetPlayerProp(client,sqlStartLoadXPTime,0.0);
		SetPlayerProp(client,isDeveloper,false);
		SetPlayerProp(client,LastChangeTeamTime,0.0);
		SetPlayerProp(client,bStatefulSpawn,true);
		bResetSkillsOnSpawn[client]=false;
	}
	else if(event == DoResetSkills)
	{
		new raceid = GetRace(client);
		if(IsPlayerAlive(client)){
			bResetSkillsOnSpawn[client]=true;
			RaceIDToReset[client]=raceid;
			War3_ChatMessage(client,"%T","Your skills will be reset when you die",client);
		}
		else
		{
			internal_ClearSkillLevels(client,raceid);
			War3_ChatMessage(client,"%T","Your skills have been reset for your current job",client);
			if(War3_GetLevel(client,raceid)>0)
			{
				DoFwd_War3_Event(DoShowSpendskillsMenu,client);
			}
		}
	}
}

public ResetSkillsAndSetVar(client)
{
	if (ValidPlayer(client))
	{
		if(bResetSkillsOnSpawn[client]==true)
		{
			internal_ClearSkillLevels(client,RaceIDToReset[client]);
			bResetSkillsOnSpawn[client]=false;

			// Check if the level of the race we reset is > 0 and the current job is still the one we reset
			if((War3_GetLevel(client,RaceIDToReset[client])>0)&&(GetRace(client)==RaceIDToReset[client])){
				War3_ChatMessage(client,"%T","Your skills have been reset for your current job",client);
				DoFwd_War3_Event(DoShowSpendskillsMenu,client);
			}
		}
	}
}

public War3Source_Engine_PlayerClass_OnWar3EventSpawn(client)
{
		ResetSkillsAndSetVar(client);
}

public War3Source_Engine_PlayerClass_OnWar3EventDeath(victim, attacker)
{
		ResetSkillsAndSetVar(victim);
}
