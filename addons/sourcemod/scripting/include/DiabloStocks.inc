// My Personal Stocks that I reuse often
// <DiabloStocks>
// it's also included in war3source.inc

#include <switchgamemode>

#if (GGAMETYPE == GGAME_TF2)
#include <tf2_stocks>
#endif

#if defined _diablostocks_included
 #endinput
#endif
#define _diablostocks_included

#define STRING(%1) %1, sizeof(%1)

#define LoopMaxClients(%1) for(new %1=1;%1<=MaxClients;++%1)

#define LoopConnectedClients(%1) for(new %1=1;%1<=MaxClients;++%1)\
								if(IsClientConnected(%1))

#define LoopIngameClients(%1) for(new %1=1;%1<=MaxClients;++%1)\
								if(IsClientInGame(%1))

#define LoopInGameBots(%1) for(new %1=1;%1<=MaxClients;++%1)\
								if(IsClientInGame(%1) && IsFakeClient(%1))

#define LoopIngamePlayers(%1) for(new %1=1;%1<=MaxClients;++%1)\
								if(IsClientInGame(%1) && !IsFakeClient(%1))

#define LoopAuthorizedPlayers(%1) for(new %1=1;%1<=MaxClients;++%1)\
								if(IsClientConnected(%1) && IsClientAuthorized(%1))

#define LoopAlivePlayers(%1) for(new %1=1;%1<=MaxClients;++%1)\
								if(IsClientInGame(%1) && IsPlayerAlive(%1))

#define LoopTeamPlayers(%1,%2) for(new %2=1;%2<=MaxClients;++%2)\
								if(IsClientInGame(%2) && IsPlayerAlive(%2) && (GetClientTeam(%1)==GetClientTeam(%2)))

#define LoopDeadPlayers(%1) for(new %1=1;%1<=MaxClients;++%1)\
								if(IsClientInGame(%1) && !IsPlayerAlive(%1))

#define Toggle(%1) %1=%1?false:true

stock TheTimeLeft(amount)
{
	new diff = amount-GetTime();
	if(diff < 0)
	{
		return 0;
	}
	return diff;
}

stock GetClientBySteamID(String:steamid[])
{
	new String:authid[32];
	new String:legacy[32];
	for(new i=1;i<=MaxClients;++i)
	{
		if(!IsClientInGame(i))
			continue;
		if(!IsClientAuthorized(i))
			continue;
		GetClientAuthString(i, STRING(authid));
		GetClientAuthString(i, STRING(legacy));
		if(strcmp(legacy[8], steamid[8])==0 || strcmp(authid, steamid)==0)
			return i;
	}
	return 0;
}

stock GetClientByIP(String:ip[])
{
	decl String:client_ip[16];
	for(new i=1;i<=MaxClients;++i)
	{
		if(!IsClientInGame(i))
			continue;
		GetClientIP(i, client_ip, sizeof(client_ip));
		if(strcmp(client_ip, ip)==0)
			return i;
	}
	return 0;
}

stock bool:IsPluginLoaded(String:name[])
{
	new String:m_szName[PLATFORM_MAX_PATH];
	new Handle:pluginIterator = GetPluginIterator();
	while (MorePlugins(pluginIterator))
	{
		new Handle:currentPlugin = ReadPlugin(pluginIterator);
		GetPluginFilename(currentPlugin, STRING(m_szName));
		m_szName[strlen(m_szName)-4]=0;
		if(strcmp(name, m_szName)==0)
			return true;
	}
	return false;
}

/**
 * Prints Message to server and all chat
 * For debugging prints
 */
stock DP(const String:szMessage[], any:...)
{
#if defined debugon
	decl String:szBuffer[1000];

	VFormat(szBuffer, sizeof(szBuffer), szMessage, 2);
	PrintToServer("[DebugP %d] %s",RoundFloat(GetGameTime())%100, szBuffer);
	PrintToChatAll("[DebugP %d] %s",RoundFloat(GetGameTime())%100, szBuffer);
#endif
}
//prring plugin
stock DPP(Plugin:plugin)
{
	new String:szBuffer[1000];
	GetPluginFilename(Handle:plugin, szBuffer,sizeof(szBuffer));
	DP("[Debug PrintP] %s", szBuffer);
}

stock HasSMAccess(client, flag) {
	new flags = GetUserFlagBits(client);
	//DP("flags %d",flags);
	if (flags & flag)
	{
		return true;
	}

	return false;
}


stock bool IsEntLimitReached()
{
	if (GetEntityCount() >= (GetMaxEntities()-16))
	{
		PrintToServer("Warning: Entity limit is nearly reached! Please switch or reload the map!");
		LogError("Entity limit is nearly reached: %d/%d", GetEntityCount(), GetMaxEntities());
		return true;
	}
	else
		return false;
}

stock TF_SpawnEntity(client, String:name[], r=255, g=255, b=255, a=-1, bool:RandomPositions=false,team=0)
{
	new Float:PlayerPosition[3];
	GetClientAbsOrigin(client, PlayerPosition);

	if (PlayerPosition[0] != 0.0 && PlayerPosition[1] != 0.0 && PlayerPosition[2] != 0.0 && IsEntLimitReached() == false)
	{
		//DP("Got thru the if statement");
		//PlayerPosition[2] += 40.0;
		if(RandomPositions)
		{
			PlayerPosition[2] += GetRandomFloat(10.0, 60.0);
			new Rand = GetRandomInt(0,7);
			if(Rand==0)
			{
				PlayerPosition[1] += GetRandomFloat(40.0, 60.0);
				PlayerPosition[0] += GetRandomFloat(40.0, 60.0);
			}
			else if(Rand==1)
			{
				PlayerPosition[1] -= GetRandomFloat(40.0, 60.0);
				PlayerPosition[0] -= GetRandomFloat(40.0, 60.0);
			}
			else if(Rand==2)
			{
				PlayerPosition[1] += GetRandomFloat(40.0, 60.0);
				PlayerPosition[0] -= GetRandomFloat(40.0, 60.0);
			}
			else if(Rand==3)
			{
				PlayerPosition[1] -= GetRandomFloat(40.0, 60.0);
				PlayerPosition[0] += GetRandomFloat(40.0, 60.0);
			}
			else if(Rand==4)
			{
				PlayerPosition[1] -= GetRandomFloat(40.0, 60.0);
			}
			else if(Rand==5)
			{
				PlayerPosition[0] -= GetRandomFloat(40.0, 60.0);
			}
			else if(Rand==6)
			{
				PlayerPosition[1] += GetRandomFloat(40.0, 60.0);
			}
			else if(Rand==7)
			{
				PlayerPosition[0] += GetRandomFloat(40.0, 60.0);
			}
		}
		else
		{
			PlayerPosition[2] += 40.0;
			PlayerPosition[1] += 0.0;
			PlayerPosition[0] += 0.0;
		}

		new SpawnItem = CreateEntityByName(name);
		DispatchKeyValue(SpawnItem, "OnPlayerTouch", "!self,Kill,,0,-1");
		if (DispatchSpawn(SpawnItem))
		{
			TeleportEntity(SpawnItem, PlayerPosition, NULL_VECTOR, NULL_VECTOR);

			if(a>-1)
			{
				SetEntityRenderColor(SpawnItem, r, g, b, a);
			}
			//EmitSoundToAll(SOUND_B, SpawnItem, _, _, _, 0.75);

			if(team==2 || team==3)
			{
				SetEntProp(SpawnItem, Prop_Send, "m_iTeamNum", team, 4);
			}
			return SpawnItem;
		}
	}
	return 0;
}

////////////////////////////////////////////////////////////////////////////
//								CLIENT
////////////////////////////////////////////////////////////////////////////

#if !defined _vanilla_constants_included
//#if !defined _War3Source_included
stock bool ValidPlayer(int client, bool check_alive=false, bool alivecheckbyhealth=false) {
	if(client>0 && client<=MaxClients && IsClientConnected(client) && IsClientInGame(client))
	{
		if(check_alive && !IsPlayerAlive(client))
		{
			return false;
		}
		if(alivecheckbyhealth&&GetClientHealth(client)<1) {
			return false;
		}
		return true;
	}
	return false;
}
//#endif
#endif

////////////////////////////////////////////////////////////////////////////
//								KEYVALUES
////////////////////////////////////////////////////////////////////////////

stock bool:KvGetYesOrNo(Handle:kv, const String:key[], bool:curdefault)
{
	decl String:value[12];
	KvGetString(kv, key, value, sizeof(value), curdefault ? "yes" : "no");
	return (strcmp(value, "yes") == 0);
}


#if (GGAMETYPE == GGAME_TF2)
//=======================================================================
//                                 TF2 Stocks
//=======================================================================
#if !defined SMASHBROS
stock Float:TF2_GetClassSpeed(TFClassType:class)
{
		switch (class)
		{
				case TFClass_Scout:     return 400.0;
				case TFClass_Soldier:   return 240.0;
				case TFClass_DemoMan:   return 280.0;
				case TFClass_Medic:     return 320.0;
				case TFClass_Pyro:      return 300.0;
				// Spy was 300.0, but patch update made it 320.0
				// https://wiki.teamfortress.com/wiki/Speed
				case TFClass_Spy:       return 320.0;
				case TFClass_Engineer:  return 300.0;
				case TFClass_Sniper:    return 300.0;
				case TFClass_Heavy:     return 230.0;
		}
		return 0.0;
}
stock TF2_GetCurrentWeaponClass(client, String:name[], maxlength)
{
	if( client > 0 )
	{
		new index = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if (index > 0)
			GetEntityNetClass(index, name, maxlength);
	}
}
stock TF2_GetHealingTarget(client)
{
	new String:classname[64];
	TF2_GetCurrentWeaponClass(client, classname, sizeof(classname));

	if( StrEqual(classname, "CWeaponMedigun") )
	{
		new index = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if( GetEntProp(index, Prop_Send, "m_bHealing") == 1 )
		{
			return GetEntPropEnt(index, Prop_Send, "m_hHealingTarget");
		}
	}

	return -1;
}
stock TF_SetUberLevel(client, Float:uberlevel)
{
	new index = GetPlayerWeaponSlot(client, 1);
	if (index > 0)
		SetEntPropFloat(index, Prop_Send, "m_flChargeLevel", uberlevel*0.01);
}
stock Float:TF_GetUberLevel(client)
{
	new index = GetPlayerWeaponSlot(client, 1);
	if (index > 0)
		return GetEntPropFloat(index, Prop_Send, "m_flChargeLevel")*100.0;
	else
		return 0.0;
}
stock TF_SetCloakLevel(client, Float:cloaklevel)
{
	//new index = GetPlayerWeaponSlot(client, 1);
	//if (index > 0)
	if (ValidPlayer(client))
		SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", cloaklevel);
}
stock Float:TF_GetCloakLevel(client)
{
	//new index = GetPlayerWeaponSlot(client, 1);
	if (ValidPlayer(client))
		return GetEntPropFloat(client, Prop_Send, "m_flCloakMeter");
	else
		return 0.0;
}

stock float GetRageMeter(client)
{
	return GetEntPropFloat(client, Prop_Send, "m_flRageMeter");
}

stock void AddRageMeter(int client, float flRageAdd)
{
	if(flRageAdd <= 0.0) return;
	if(flRageAdd>100.0) flRageAdd=100.0;
	float flNewRage = FloatAdd(GetRageMeter(client),flRageAdd);
	SetEntPropFloat(client, Prop_Send, "m_flRageMeter", flNewRage);
}

stock void SetRageMeter(int client, Float:flRage = 100.0)
{
	SetEntPropFloat(client, Prop_Send, "m_flRageMeter", flRage);
}
#endif
#endif
