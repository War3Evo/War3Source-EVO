// War3Source_Engine_Aura.sp

/*
public Plugin:myinfo =
{
	name = "War3Source - Engine - Aura",
	author = "War3Source Team",
	description = "Aura Engine for War3Source"
};*/

// [AuraOwner][aura id][target of the aura]
new bool:player_AuraOwner[MAXPLAYERSCUSTOM][MAXAURAS][MAXPLAYERSCUSTOM];

// this has to do with AuraOwner himself.
new bool:player_AuraOrigin[MAXPLAYERSCUSTOM][MAXAURAS];
new player_AuraOriginLevel[MAXPLAYERSCUSTOM][MAXAURAS];
new Float:player_AuraDistance[MAXPLAYERSCUSTOM][MAXAURAS];

// This has to do with players whom have auras on them.
new player_HasAura[MAXPLAYERSCUSTOM][MAXAURAS]; //int, we just count up
new player_HasAuraLevel[MAXPLAYERSCUSTOM][MAXAURAS];

new String:player_AuraShort[MAXAURAS][32];
new bool:player_AuraTrackOtherTeam[MAXAURAS];
new Registered_AuraCount=0;

new Float:player_lastCalcAuraTime;

public War3Source_Engine_Aura_OnPluginStart()
{
	CreateTimer(0.5,CalcAura,_,TIMER_REPEAT);
}

public NW3RegisterAura(Handle:plugin,numParams)
{
	new String:taurashort[32];
	GetNativeString(1,taurashort,32);

	for(new aura=1; aura <= Registered_AuraCount; aura++)
	{
		if(StrEqual(taurashort, player_AuraShort[aura], false))
		{
			return aura; //already registered
		}
	}
	if(Registered_AuraCount + 1 < MAXAURAS)
	{
		Registered_AuraCount++;
		strcopy(player_AuraShort[Registered_AuraCount], 32, taurashort);

		for(new client=1;client<=MaxClients;client++)
		{
			player_AuraDistance[client][Registered_AuraCount] = Float:GetNativeCell(2);
		}

		player_AuraTrackOtherTeam[Registered_AuraCount] = bool:GetNativeCell(3);

		//War3_LogInfo("Registered aura \"%s\" with a distance of \"%f\". TrackOtherTeam: %i", player_AuraShort[Registered_AuraCount], player_AuraDistance[1][Registered_AuraCount], player_AuraTrackOtherTeam[Registered_AuraCount]);
		return Registered_AuraCount;
	}
	else
	{
		ThrowError("CANNOT REGISTER ANY MORE AURAS");
	}

	return -1;
}
public NW3SetAuraFromPlayer(Handle:plugin,numParams)
{
	new aura=GetNativeCell(1);
	new client=GetNativeCell(2);
	player_AuraOrigin[client][aura]=bool:GetNativeCell(3);
	player_AuraOriginLevel[client][aura]=GetNativeCell(4);
}

public NW3RegisterChangingDistanceAura(Handle:plugin,numParams)
{
	new String:taurashort[32];
	GetNativeString(1,taurashort,32);

	for(new aura=1; aura <= Registered_AuraCount; aura++)
	{
		if(StrEqual(taurashort, player_AuraShort[aura], false))
		{
			// Change values of aura, since its already registered
			player_AuraTrackOtherTeam[aura] = bool:GetNativeCell(2);
			//War3_LogInfo("Changed - Registered aura \"%s\" TrackOtherTeam: %i", player_AuraShort[aura], player_AuraTrackOtherTeam[aura]);
			return aura; //already registered
		}
	}
	if(Registered_AuraCount + 1 < MAXAURAS)
	{
		Registered_AuraCount++;
		strcopy(player_AuraShort[Registered_AuraCount], 32, taurashort);

		player_AuraTrackOtherTeam[Registered_AuraCount] = bool:GetNativeCell(2);

		//War3_LogInfo("Registered aura \"%s\" TrackOtherTeam: %i", player_AuraShort[Registered_AuraCount], player_AuraTrackOtherTeam[Registered_AuraCount]);
		return Registered_AuraCount;
	}
	else
	{
		ThrowError("CANNOT REGISTER ANY MORE AURAS");
	}

	return -1;
}
public NW3SetPlayerAura(Handle:plugin,numParams)
{
	new aura=GetNativeCell(1);
	new client=GetNativeCell(2);
	player_AuraDistance[client][aura]=Float:GetNativeCell(3);
	player_AuraOrigin[client][aura]=true;
	player_AuraOriginLevel[client][aura]=GetNativeCell(4);
}
public NW3RemovePlayerAura(Handle:plugin,numParams)
{
	new aura=GetNativeCell(1);
	new client=GetNativeCell(2);
	player_AuraDistance[client][aura]=0.0;
	player_AuraOrigin[client][aura]=false;
	player_AuraOriginLevel[client][aura]=0;
}
public NW3HasAura(Handle:plugin,numParams)
{
	new aura=GetNativeCell(1);
	new client=GetNativeCell(2);

	//new data=GetNativeCellRef(3); //we dont have to get
	SetNativeCellRef(3, player_HasAuraLevel[client][aura]);
	return ValidPlayer(client,true)&&player_HasAura[client][aura];
}
public InternalClearPlayerVars(client){
	for(new aura=1;aura<=Registered_AuraCount;aura++)
	{
		player_AuraOrigin[client][aura]=false;
		player_AuraDistance[client][aura]=0.0;
	}
}
//re calculate auras when one of these things happen, however a 0.1 delay minimum (like 32 players spawn at round start, we dont calculate 32 times)
public ShouldCalcAura()
{
	if(GetEngineTime()>player_lastCalcAuraTime+0.5) // was 0.1
	{
		CalcAura(INVALID_HANDLE);
	}
}

public Action:CalcAura(Handle:t)
{
	if(MapChanging || War3SourcePause) return Plugin_Continue;

	//if(GetEngineTime()>player_lastCalcAuraTime+0.5) return Plugin_Continue;

	player_lastCalcAuraTime=GetEngineTime();

	//store old aura count
	int OldHasAura[MAXPLAYERSCUSTOM][MAXAURAS];
	int OldHasAuraLevel[MAXPLAYERSCUSTOM][MAXAURAS];
	for(new client=1;client<=MaxClients;client++)
	{
		for(new aura=1;aura<=Registered_AuraCount;aura++){
			OldHasAura[client][aura]=player_HasAura[client][aura];
			OldHasAuraLevel[client][aura]=player_HasAuraLevel[client][aura];
			player_HasAura[client][aura]=0; //clear bool aura
			player_HasAuraLevel[client][aura]=0; // clear levels .. was -1
			for(new owner=1;owner<=MaxClients;owner++)
			{
				player_AuraOwner[owner][aura][client]=false;
			}
		}
	}

	float vec1[3];
	float vec2[3];
	int teamtarget;
	int teamclient;
	//DP("START START START START START START");
	//DP("START START START START START START");
	//DP("START START START START START START");
	//DP("START START START START START START");
	for(int client=1;client<=MaxClients;client++)
	{
		for(int target=1;target<=MaxClients;target++)
		{
			if(ValidPlayer(target,true)
			&& ValidPlayer(client,true))
			{
				teamtarget=GetClientTeam(target);
				teamclient=GetClientTeam(client);
				for(int aura=1;aura<=Registered_AuraCount;aura++)
				{
					if(!player_AuraOrigin[client][aura] && !player_AuraOrigin[target][aura])
					{
						continue;
					}

					//boolean magic!!!!!!!! De Morgan wuz here   (And El Diablo improved it! 9/3/2013)
					if( (!player_AuraTrackOtherTeam[aura])==(teamclient==teamtarget) )
					{

						//client is target and originating an aura and is tracking his own team
						if(player_AuraOrigin[client][aura] && client==target)
						{
							player_AuraOwner[client][aura][target]=true;
							player_HasAura[target][aura]++;
							player_HasAuraLevel[target][aura]=player_AuraOriginLevel[client][aura];
							//DP("client==target  %d is  %d and in aura - player_HasAura %d %d",client,target,player_HasAura[client][aura],player_HasAura[target][aura]);
							continue;
						}

						if(player_AuraOrigin[client][aura])
						{
							War3_CachedPosition(client,vec1);
							War3_CachedPosition(target,vec2);
							float dis=GetVectorDistance(vec1,vec2);
							//DP("aura %d  %f",client,dis);

							if(dis<=player_AuraDistance[client][aura])
							{
								player_AuraOwner[client][aura][target]=true;
								player_HasAura[target][aura]++;
								player_HasAuraLevel[target][aura]=IntMax(player_HasAuraLevel[target][aura],player_AuraOriginLevel[client][aura]); //what level is larger, old level or new level brought by the new origin player
								//DP("%d is owner and in aura, %d is in aura - player_HasAura %d %d",client,target,player_HasAura[client][aura],player_HasAura[target][aura]);
								continue;
							}
						}

						//target originating an aura
						//skip if client is target, which we already did up top
						if(player_AuraOrigin[target][aura])
						{
							War3_CachedPosition(client,vec1);
							War3_CachedPosition(target,vec2);
							float dis=GetVectorDistance(vec1,vec2);
							//DP("aura %d  %f",client,dis);

							if(dis<=player_AuraDistance[target][aura])
							{
								player_AuraOwner[target][aura][client]=true;
								player_HasAura[client][aura]++;
								player_HasAuraLevel[client][aura]=IntMax(player_HasAuraLevel[client][aura],player_AuraOriginLevel[target][aura]);
								//DP("%d is owner and in aura, %d is in aura - player_HasAura %d %d",target,client,player_HasAura[target][aura],player_HasAura[client][aura]);
							}
						}
					}
				}
			}
		}
	}
	//DP("END END END END END END END ");
	//DP("END END END END END END END ");
	//DP("END END END END END END END ");
	//DP("END END END END END END END ");
	for(int client=1;client<=MaxClients;client++)
	{
		if(ValidPlayer(client))
		{
			for(int aura=1;aura<=Registered_AuraCount;aura++)
			{
				//stat changed?
				if(  (OldHasAura[client][aura]!=player_HasAura[client][aura])
				||   (OldHasAuraLevel[client][aura]!=player_HasAuraLevel[client][aura])
				)
				{
					for(int owner=1;owner<=MaxClients;owner++)
					{
						if(player_AuraOrigin[owner][aura])
						{
							Call_StartForward(g_Forward);
							Call_PushCell(client);
							Call_PushCell(aura);
							Call_PushCell(player_AuraOwner[owner][aura][client]);
							Call_PushCell(player_HasAuraLevel[client][aura]);
							Call_PushCell(player_HasAura[client][aura]); // aura stack
							Call_PushCell(owner);
							Call_Finish(dummy);
						}
					}
				}
			}
		}
	}
	DoFwd_War3_Event(OnAuraCalculationFinished,0);

	return Plugin_Continue;
}
