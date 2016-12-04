// War3Source_Engine_BuffMaxHP.sp

////BUFF SYSTEM

// if the extension is unable to load, Buff MaxHP will still run.
//#undef REQUIRE_PLUGIN
#if GGAMETYPE == GGAME_TF2
#tryinclude <tf2attributes>
#endif

/*
public Plugin:myinfo=
{
	name="War3Source Buff MAXHP",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.1",
	url="http://war3source.com/"
};*/

#if GGAMETYPE == GGAME_TF2
public War3Source_Engine_BuffMaxHP_OnPluginStart()
{
	if(!GetConVarBool(g_buffmaxhp_enable_tf2attributes))
	{
		for (int i = 1; i <= MaxClients; i++)
		{
				if (ValidPlayer(i))
				{
						SDKHook(i, SDKHook_GetMaxHealth, OnGetMaxHealth);
				}
		}
	}
}
#endif
new ORIGINALHP[MAXPLAYERSCUSTOM];

//GetConVarInt(g_buffmaxhp_enable_tf2attributes)

// TF2 ATTRIBUTES:

GetMaxHP(client)
{
	int MaxHP = ORIGINALHP[client] + GetBuffSumInt(client,iAdditionalMaxHealth);
	MaxHP = RoundToCeil(FloatMul(float(MaxHP),GetBuffStackedFloat(client,fMaxHealth)));
	return MaxHP;
}

setMax(client)
{
#if GGAMETYPE == GGAME_TF2
	if(GetConVarBool(g_buffmaxhp_enable_tf2attributes) && ValidPlayer(client))
	{
		//DP("ORIGHP setMax %i",ORIGINALHP[client]);
		int maxHP = GetMaxHP(client);

		if(maxHP<=0)
			return;

		War3_SetMaxHP_INTERNAL(client,maxHP);
		//DP("set max hp: %i",maxHP);

		if(GetConVarBool(g_buffmaxhp_enable_tf2attributes))
		{
			TF2Attrib_SetByName(client,"max health additive bonus", 1.0*GetBuffSumInt(client,iAdditionalMaxHealth));
		}
	}
	else if(!GetConVarBool(g_buffmaxhp_enable_tf2attributes) && ValidPlayer(client))
	{
		if(ORIGINALHP[client]>0)
		{
			//DP("ORIGHP setMax %i",ORIGINALHP[client]);
			int maxHP = GetMaxHP(client);

			if(maxHP<=0)
				return;

			War3_SetMaxHP_INTERNAL(client,maxHP);
			//DP("set max hp: %i",maxHP);

			if(GetConVarBool(g_buffmaxhp_enable_tf2attributes))
			{
				TF2Attrib_SetByName(client,"max health additive bonus", 1.0*GetBuffSumInt(client,iAdditionalMaxHealth));
			}
		}
		else
		{
			//DP("ORIGHP setMax %i",ORIGINALHP[client]);
			ORIGINALHP[client] = GetClientHealth(client);
			int maxHP = GetMaxHP(client);

			if(maxHP<=0)
				return;

			War3_SetMaxHP_INTERNAL(client,maxHP);
			//DP("set max hp: %i",maxHP);

			if(GetConVarBool(g_buffmaxhp_enable_tf2attributes))
			{
				TF2Attrib_SetByName(client,"max health additive bonus", 1.0*GetBuffSumInt(client,iAdditionalMaxHealth));
			}
		}
	}

	if(GetConVarBool(g_buffmaxhp_enable_tf2attributes))
	{
		//new Float:vec[3];
		//GetClientAbsOrigin(client, vec);
		if (War3_IsInSpawn(client))
			SetEntityHealth(client,Internal_War3_GetMaxHP(client));
	}
#else

	if(ValidPlayer(client))
	{
		if(ORIGINALHP[client]>0)
		{
			//DP("ORIGHP setMax %i",ORIGINALHP[client]);
			int maxHP = GetMaxHP(client);

			if(maxHP<=0)
				return;

			War3_SetMaxHP_INTERNAL(client,maxHP);
			//SetEntProp(client, Prop_Data, "m_iMaxHealth", maxHP);
			//DP("set max hp: %i",maxHP);
		}
		else
		{
			//DP("ORIGHP setMax %i",ORIGINALHP[client]);
			ORIGINALHP[client] = GetClientHealth(client);
			int maxHP = GetMaxHP(client);

			if(maxHP<=0)
				return;

			War3_SetMaxHP_INTERNAL(client,maxHP);
			//SetEntProp(client, Prop_Data, "m_iMaxHealth", maxHP);
			//DP("set max hp: %i",maxHP);
		}
	}
#endif
}

Handle timers[MAXPLAYERSCUSTOM];
public Action:thisSpawn(Handle:h,any:client)
{
		if(ValidPlayer(client))
		{
			int iClientHealth=GetClientHealth(client);
			if(iClientHealth>1)
			{
				//DP("client health on spawn = %d",iClientHealth);
				//DP("W3GetBuffSumInt(client,iAdditionalMaxHealth) on spawn = %d",W3GetBuffSumInt(client,iAdditionalMaxHealth));
				ORIGINALHP[client]=iClientHealth - GetBuffSumInt(client,iAdditionalMaxHealth);
				setMax(client);
				int MaxHP=Internal_War3_GetMaxHP(client);
				if(MaxHP>0)
				{
					//SetEntityHealth(client,MaxHP);
					nsEntity_SetHealth(client, MaxHP);
				}
				timers[client]=INVALID_HANDLE;
			}
			else
			{
				timers[client]=CreateTimer(0.5, thisSpawn, client);
				//DP("timers[]");
			}
		}
}
#if GGAMETYPE == GGAME_TF2
public War3Source_Engine_BuffMaxHP_OnWar3EventSpawn(client)
{
	//DP("Spawned");
	if(GetConVarBool(g_buffmaxhp_enable_tf2attributes))
	{
		timers[client]=CreateTimer(1.0, thisSpawn, client);
	}
}
#endif

public War3Source_Engine_BuffMaxHP_OnWar3Event(client)
{
		if((internal_W3GetVar(EventArg1)==iAdditionalMaxHealth || internal_W3GetVar(EventArg1)==fMaxHealth)&&ValidPlayer(client,false)){
				if (GetMaxHP(client) != Internal_War3_GetMaxHP(client))
				{
#if GGAMETYPE == GGAME_TF2
					if(GetConVarBool(g_buffmaxhp_enable_tf2attributes))
					{
						setMax(client);
						if (timers[client] != INVALID_HANDLE)
							return;
					}
					else
					{
						setMax(client);
						int MaxHP=Internal_War3_GetMaxHP(client);
						if(MaxHP>0 && GetPlayerProp(client,bStatefulSpawn))
						{
							SetEntProp(client, Prop_Data, "m_iHealth", MaxHP);
							War3_SetMaxHP_INTERNAL(client,MaxHP);
						}
					}
#else
					setMax(client);
					int MaxHP=Internal_War3_GetMaxHP(client);
					if(MaxHP>0 && GetPlayerProp(client,bStatefulSpawn))
					{
						//DP("bStatefulSpawn");
						SetEntityHealth(client,MaxHP);      //TFCond_Overhealed
						War3_SetMaxHP_INTERNAL(client,MaxHP);
					}
#endif
				}
		}
}

// NON-TF2 ATTRIBUTES VERSION:
#if GGAMETYPE == GGAME_TF2
public OnConfigsExecuted()
{
	if(!GetConVarBool(g_buffmaxhp_enable_tf2attributes))
	{
		for (int i = 1; i <= MaxClients; i++)
		{
				if (ValidPlayer(i))
				{
						SDKHook(i, SDKHook_GetMaxHealth, OnGetMaxHealth);
				}
		}
	}
}
public War3Source_Engine_BuffMaxHP_OnClientPutInServer(client)
{
	if(!GetConVarBool(g_buffmaxhp_enable_tf2attributes))
	{
		SDKHook(client, SDKHook_GetMaxHealth, OnGetMaxHealth);
	}
}
#else
public OnConfigsExecuted()
{
	for (new i = 1; i <= MaxClients; i++)
	{
			if (ValidPlayer(i))
			{
					SDKHook(i, SDKHook_GetMaxHealth, OnGetMaxHealth);
			}
	}
}
public War3Source_Engine_BuffMaxHP_OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_GetMaxHealth, OnGetMaxHealth);
}
#endif

public War3Source_Engine_BuffMaxHP_OnClientDisconnect(client)
{
	ORIGINALHP[client]=0;
}

public Action:OnGetMaxHealth(client, &maxhealth)
{
	if(MapChanging || War3SourcePause) return Plugin_Continue;
#if GGAMETYPE == GGAME_TF2
	if (ValidPlayer(client) && !GetConVarBool(g_buffmaxhp_enable_tf2attributes))
	{
		if((GetBuffSumInt(client,iAdditionalMaxHealth)>0 || GetBuffStackedFloat(client,fMaxHealth)!=1.0) && !GetBuffHasOneTrue(client,bBuffDenyAll))
		{
			if(!TF2_IsPlayerInCondition(client,TFCond_Overhealed))
			{
				// This works better (but not well with spy kunai weapon)
				//maxhealth+=W3GetBuffSumInt(client,iAdditionalMaxHealth);

				// this makes weapon health bonuses from valve not work

				if(maxhealth>ORIGINALHP[client]||maxhealth<ORIGINALHP[client])
				{
					ORIGINALHP[client]=maxhealth;
				}
				maxhealth=GetMaxHP(client);
			}
			else
			{
				if(GetClientHealth(client)<=GetMaxHP(client))
				{
					maxhealth=GetMaxHP(client);
				}
			}
		}

		return Plugin_Handled;
	}
#else
	if (ValidPlayer(client))
	{
		if((GetBuffSumInt(client,iAdditionalMaxHealth)>0 || GetBuffStackedFloat(client,fMaxHealth)!=1.0) && !GetBuffHasOneTrue(client,bBuffDenyAll))
		{
			if(GetClientHealth(client)<=GetMaxHP(client))
			{
				maxhealth=GetMaxHP(client);
			}
			else if(GetClientHealth(client)>GetMaxHP(client))
			{
				maxhealth=(GetMaxHP(client))-1;
			}
		}

		return Plugin_Handled;
	}
#endif
	return Plugin_Continue;
}


