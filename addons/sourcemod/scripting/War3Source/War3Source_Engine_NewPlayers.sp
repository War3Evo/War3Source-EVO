// War3Source_Engine_NewPlayers.sp

//
// TRANSLATED mostly... 3/30/2023
//
// TO DO:
// - need to add ability for translations to work with convars for this file

/* ========================================================================== */
/*                                                                            */
/*                                                                          */
/*   (c) 2012 El Diablo                                                       */
/*                                                                            */
/*   Description  A Race for developers whom want to test vanilla             */
/*                players (players without any modifications) vs              */
/*                what ever race they wish to go against.                     */
/* ========================================================================== */

/*
public Plugin:myinfo =
{
	name = "New Player Project",
	author = "El Diablo",
	description = "New Player Handicaps",
	version = "1.0.0.0",
	url = "http://Www.war3evo.info"
};
*/

public War3Source_Engine_NewPlayers_OnPluginStart()
{
	NewPlayerCvar=CreateConVar("war3_newplayer_enabled","1","1 for on, 0 for off. (default 1)");
	NewPlayerDaysCvar=CreateConVar("war3_newplayer_days","1","How long a new player is considered new after join date.");
	NewPlayerDamageModCvar=CreateConVar("war3_newplayer_damage_mod","0.90","0.0 = 100% damage reduction, 0.90 = 10% damage reduction, 1.0 = no damage reduction",0,true,0.0,true,1.0);

	NewPlayerRandomRaceEnabledCvar=CreateConVar("war3_newplayer_random_race_enabled","1","1 for on, 0 for off. (default 1)");
	NewPlayerRandomRacesCvar=CreateConVar("war3_newplayer_random_races","warden, undead, mage, nightelf, crypt, bh, naix, succubus, chronos, luna, lightbender,","warden, undead, mage, nightelf, crypt, bh, naix, succubus, chronos, luna, lightbender,");
	NewPlayerStartingGoldCvar=CreateConVar("war3_newplayer_starting_gold","1","1 for on, 0 for off. (default 1)");
	NewPlayerStartingLevelCvar=CreateConVar("war3_newplayer_starting_level","-999","-999 for max, 0 to 9999 (default -999)");


	HookConVarChange(NewPlayerCvar, W3CvarNewPlayerCvar);
	HookConVarChange(NewPlayerDaysCvar, W3CvarNewPlayerDaysCvar);
	HookConVarChange(NewPlayerDamageModCvar, W3CvarNewPlayerDamageModCvar);

	HookConVarChange(NewPlayerRandomRaceEnabledCvar, W3CvarNewPlayerRandomRaceEnabledCvar);
	HookConVarChange(NewPlayerRandomRacesCvar, W3CvarNewPlayerRandomRacesCvar);
	HookConVarChange(NewPlayerStartingGoldCvar, W3CvarNewPlayerStartingGoldCvar);
	HookConVarChange(NewPlayerStartingLevelCvar, W3CvarNewPlayerStartingLevelCvar);

	// old sm_newplayerlist
	RegAdminCmd("newplayerlist",Command_newplayerlist,ADMFLAG_BAN,"Allows an administrator to see all new players.");
}

public Action:Command_newplayerlist(client, args)
{
	PrintToConsole(client,"%T","New Players:",client);

	decl String:player_name[65];
	for (new i = 1; i <= MaxClients; i++)
	{
		if(ValidPlayer(i) && !IsFakeClient(i) && IsNewPlayer[i])
		{
			GetClientName(i, player_name, sizeof(player_name));
			PrintToConsole(client,"%s",player_name);
		}
	}
	PrintToConsole(client,"%T","End of New Players",client);
	return Plugin_Handled;
}

public bool:War3Source_Engine_NewPlayers_InitNatives()
{

	CreateNative("War3_IsNewPlayer",Native_War3_IsNewPlayer);

	return true;
}

public W3CvarNewPlayerCvar(Handle:cvar, const String:oldValue[], const String:newValue[])
{
	new value = StringToInt(newValue);
	SetConVarInt(NewPlayerCvar,value);
	if(value==1)
		NewPlayerIsEnabled=true;
	else
		NewPlayerIsEnabled=false;
}
public W3CvarNewPlayerDaysCvar(Handle:cvar, const String:oldValue[], const String:newValue[])
{
	new value = StringToInt(newValue);
	SetConVarInt(NewPlayerDaysCvar,value);
	NewPlayerDays=value;
}
public W3CvarNewPlayerDamageModCvar(Handle:cvar, const String:oldValue[], const String:newValue[])
{
	new Float:value = StringToFloat(newValue);
	SetConVarFloat(NewPlayerDamageModCvar,value);
	NewPlayerDamageMod=value;
}
public W3CvarNewPlayerRandomRaceEnabledCvar(Handle:cvar, const String:oldValue[], const String:newValue[])
{
	// new player random races enabled
	new value = StringToInt(newValue);
	SetConVarInt(NewPlayerRandomRaceEnabledCvar,value);
	if(value==1)
		NewPlayerRandomRaceEnabled=true;
	else
		NewPlayerRandomRaceEnabled=false;
}
public W3CvarNewPlayerRandomRacesCvar(Handle:cvar, const String:oldValue[], const String:newValue[])
{
	// new player random races string
    strcopy(NewPlayerRandomRaces, 511, newValue); 
	SetConVarString(NewPlayerRandomRacesCvar, newValue); 
}
public W3CvarNewPlayerStartingGoldCvar(Handle:cvar, const String:oldValue[], const String:newValue[])
{
	// new player starting gold
	new value = StringToInt(newValue);
	SetConVarInt(NewPlayerStartingGoldCvar,value);
	NewPlayerStartingGold=value;
}
public W3CvarNewPlayerStartingLevelCvar(Handle:cvar, const String:oldValue[], const String:newValue[])
{
	// new player starting level
	new value = StringToInt(newValue);
	SetConVarInt(NewPlayerStartingLevelCvar,value);
	NewPlayerStartingLevel=value;
}


public War3Source_Engine_NewPlayers_OnWar3EventDeath(victim, attacker, deathrace, distance, attacker_hpleft)
{
	if(victim!=attacker && ValidPlayer(victim) && ValidPlayer(attacker)
	&& IsNewPlayer[victim] && NewPlayerIsEnabled && !IsFakeClient(victim) )
	{
		CreateTimer(4.5,quickerspawn,victim);
	}
}
public Action:quickerspawn(Handle:timer, any:client)
{
	if(MapChanging || War3SourcePause) return Plugin_Stop;

	if(ValidPlayer(client) && !IsPlayerAlive(client) && IsNewPlayer[client])
	{
		War3_ChatMessage(client, "%T","{green}[New Player Fast Respawn]{lightgreen}Because your new on our servers, you get a slightly faster respawn.",client);
#if (GGAMETYPE == GGAME_TF2)
		TF2_RespawnPlayer(client);
#else
		War3_SpawnPlayer(client);
#endif
	}
	return Plugin_Continue;
}

public War3Source_Engine_NewPlayers_OnW3TakeDmgAllPre(victim,attacker,Float:damage)
{
	if(ValidPlayer(victim) && ValidPlayer(attacker) && NewPlayerIsEnabled && !IsFakeClient(victim) && IsNewPlayer[victim])
	{
		//if(GetRandomFloat(0.0,1.0)<NewPlayerDamage2ModChance)
		//{
#if (GGAMETYPE == GGAME_TF2)
		if (TF2_GetPlayerClass(attacker) != TFClass_Sniper)
		{
			DamageModPercent(NewPlayerDamageMod);
		}
#else
		DamageModPercent(NewPlayerDamageMod);
#endif
		//}
	}
}

public Internal_Engine_NewPlayers_OnWar3PlayerAuthedHandle(client)
{
	if(ValidPlayer(client))
	{
		new TheJoinDate = GetPlayerProp(client,JoinDate);
		if(TheJoinDate>0)
		{
			TheJoinDate+=(NewPlayerDays*86400);
			if(TheTimeLeft(TheJoinDate)>0)
			{
				IsNewPlayer[client]=true;
				return;
			}
		}
	}
	IsNewPlayer[client]=false;
	return;
}

public Native_War3_IsNewPlayer(Handle:plugin,numParams) //buff is from an item
{
	if(numParams==1 && NewPlayerIsEnabled) //client,race,buffindex,value
	{
		new client=GetNativeCell(1);
		//if(CurrentPlayerTotalLevels[client]<=NewPlayerMaxLevel&&!IsFakeClient(client))
			//return true;

		return IsNewPlayer[client];
	}
	return false;
}

public War3Source_Engine_NewPlayers_OnClientDisconnect(client)
{
	IsNewPlayer[client]=false;
}
