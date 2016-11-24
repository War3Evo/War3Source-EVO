// War3Source_Engine_CSGO_Radar.sp

public void War3Source_Engine_CSGO_Radar_OnClientChange(int client)
{
	CSGO_Radar_Changed[client]=0;
}

public void War3Source_Engine_CSGO_Radar_OnPluginStart()
{
	mp_teamcashawards = FindConVar("mp_teamcashawards");
	mp_playercashawards = FindConVar("mp_playercashawards");
}

public void War3Source_Engine_CSGO_Radar_OnMapStart()
{
	CreateTimer(0.2, Timer_CheckMenu, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}

public Action:Timer_CheckMenu(Handle:timer)
{
	if(MapChanging || War3SourcePause) return Plugin_Continue;

	for (new i = 1; i <= MaxClients; i++)
	{
		if (ValidPlayer(i,true))
		{
			if (GetClientMenu(i) != MenuSource_None && CSGO_Radar_Changed[i]!=10)
			{
				// menu enabled / radar off
				CSGO_Radar_Changed[i]=10;
				CSGO_RADAR(i,false);
				SendConVarValue(i, mp_teamcashawards, "0");
				SendConVarValue(i, mp_playercashawards, "0");
			}
			else if(CSGO_Radar_Changed[i]!=11)
			{
				// menu disabled / radar on
				CSGO_Radar_Changed[i]=11;
				CSGO_RADAR(i,true);
				SendConVarValue(i, mp_teamcashawards, "1");
				SendConVarValue(i, mp_playercashawards, "1");
			}
		}
	}
	return Plugin_Continue;
}

