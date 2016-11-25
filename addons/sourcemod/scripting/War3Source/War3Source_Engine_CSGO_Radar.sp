// War3Source_Engine_CSGO_Radar.sp

public void War3Source_Engine_CSGO_Radar_OnClientChange(int client)
{
	CSGO_Radar_Changed[client]=0;
}

public void War3Source_Engine_CSGO_Radar_OnWar3EventDeath(int victim)
{
	CSGO_Radar_Changed[victim]=0;
}

/*
public void War3Source_Engine_CSGO_Radar_OnPluginStart()
{
	mp_teamcashawards = FindConVar("mp_teamcashawards");
	mp_playercashawards = FindConVar("mp_playercashawards");
}*/

public void War3Source_Engine_CSGO_Radar_OnMapStart()
{
	mp_teamcashawards = FindConVar("mp_teamcashawards");
	mp_playercashawards = FindConVar("mp_playercashawards");
	CreateTimer(0.2, Timer_CheckMenu, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}

public Action:Timer_CheckMenu(Handle:timer)
{
	if(MapChanging || War3SourcePause) return Plugin_Continue;

	for (int i = 1; i <= MaxClients; i++)
	{
		//if (ValidPlayer(i,true))
		if (ValidPlayer(i))
		{
			if (GetClientMenu(i) != MenuSource_None)
			{
				// menu enabled / radar off
				CSGO_RADAR(i,false);
				if(CSGO_Radar_Changed[i]!=10)
				{
					//PrintToChatAll("dollar sign off");
					CSGO_Radar_Changed[i]=10;
					if(mp_teamcashawards==null || mp_playercashawards==null)
					{
						PrintToServer("[WAR3SOURCE:EVO] mp_teamcashawards or mp_playercashawards is NULL ERROR");
						continue;
					}
					if(!SendConVarValue(i, mp_teamcashawards, "0"))
					{
						PrintToServer("[WAR3SOURCE:EVO] mp_teamcashawards 0 ERROR");
					}
					if(!SendConVarValue(i, mp_playercashawards, "0"))
					{
						PrintToServer("WAR3SOURCE:EVO mp_playercashawards 0 ERROR");
					}
				}
			}
			else
			{
				// menu disabled / radar on
				//CSGO_RADAR(i,true);
				if(CSGO_Radar_Changed[i]!=11)
				{
					CSGO_RADAR(i,true);
					//PrintToChatAll("dollar sign ON");
					CSGO_Radar_Changed[i]=11;
					if(mp_teamcashawards==null || mp_playercashawards==null)
					{
						PrintToServer("[WAR3SOURCE:EVO] mp_teamcashawards or mp_playercashawards is NULL ERROR");
						continue;
					}
					if(!SendConVarValue(i, mp_teamcashawards, "1"))
					{
						PrintToServer("[WAR3SOURCE:EVO] mp_teamcashawards 1 ERROR");
					}
					if(!SendConVarValue(i, mp_playercashawards, "1"))
					{
						PrintToServer("WAR3SOURCE:EVO mp_playercashawards 1 ERROR");
					}
				}
			}
		}
	}
	return Plugin_Continue;
}

