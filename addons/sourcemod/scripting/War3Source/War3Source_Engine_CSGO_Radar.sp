// War3Source_Engine_CSGO_Radar.sp

public War3Source_Engine_CSGO_Radar_OnMapStart()
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
			if (GetClientMenu(i) != MenuSource_None)
			{
				// menu enabled / radar off
				CSGO_RADAR(i,false);
			}
			else
			{
				// menu disabled / radar on
				CSGO_RADAR(i,true);
			}
		}
	}
	return Plugin_Continue;
}

