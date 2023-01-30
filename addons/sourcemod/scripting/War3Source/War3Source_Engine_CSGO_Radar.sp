// War3Source_Engine_CSGO_Radar.sp

public void War3Source_Engine_CSGO_Radar_OnClientChange(int client)
{
    CSGO_Radar_Changed[client]=false;
}

public void War3Source_Engine_CSGO_Radar_OnWar3EventDeath(int victim)
{
    CSGO_Radar_Changed[victim]=false;
}

public void War3Source_Engine_CSGO_Radar_OnPluginStart()
{
    mp_teamcashawards = FindConVar("mp_teamcashawards");
    mp_playercashawards = FindConVar("mp_playercashawards");
}

public void War3Source_Engine_CSGO_Radar_OnMapStart()
{
    //mp_teamcashawards = FindConVar("mp_teamcashawards");
    //mp_playercashawards = FindConVar("mp_playercashawards");
    //if(g_War3Source_Engine_CSGO_Radar==null)
    //{
        //g_War3Source_Engine_CSGO_Radar = CreateTimer(0.2, Timer_CheckMenu, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
        
    //g_War3Source_Engine_CSGO_Radar = CreateTimer(0.2, Timer_CheckMenu, _, TIMER_REPEAT);
    CreateTimer(0.2, Timer_CheckMenu, _, TIMER_REPEAT);
    
    //}
}

public Action:Timer_CheckMenu(Handle:timer)
{
    if(MapChanging) return Plugin_Continue;
    
    if(War3SourcePause) return Plugin_Continue;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (ValidPlayer(i,true) && !IsFakeClient(i))
        {
            if (GetClientMenu(i) != MenuSource_None)  // if menu is displayed then turn money and radar off
            {
                if(CSGO_Radar_Changed[i]==false)  // if you haven't changed the radar / money, then do so
                {
                    CSGO_RADAR(i,false);   // turn off radar
                    if(SendConVarValue(i, mp_teamcashawards, "0")==false)  // turn money off
                    {
                        PrintToServer("[WAR3SOURCE:EVO] mp_teamcashawards 0 ERROR");
                        War3_ChatMessage(0,"mp_teamcashawards 0 ERROR -->CSGO RADAR"); // to everyone
                    }
                    if(SendConVarValue(i, mp_playercashawards, "0") == false)  // turn money off
                    {
                        PrintToServer("WAR3SOURCE:EVO mp_playercashawards 0 ERROR");
                        War3_ChatMessage(0, "mp_teamcashawards 0 ERROR -->CSGO RADAR"); // to everyone
                    }
                    CSGO_Radar_Changed[i] = true;
                }
            }
            else
            {
                if(CSGO_Radar_Changed[i]) {
                    CSGO_RADAR(i, true);  // turn radar back on
                    if(SendConVarValue(i, mp_teamcashawards, "1") == false)  // turn money back on
                    {
                        PrintToServer("[WAR3SOURCE:EVO] mp_teamcashawards 1 ERROR");
                        War3_ChatMessage(0, "mp_teamcashawards 1 ERROR -->CSGO RADAR"); // to everyone
                    }
                    if(SendConVarValue(i, mp_playercashawards, "1") == false)  // turn money back on
                    {
                        PrintToServer("WAR3SOURCE:EVO mp_playercashawards 1 ERROR");
                        War3_ChatMessage(0, "mp_teamcashawards 1 ERROR -->CSGO RADAR"); // to everyone
                    }
                    CSGO_Radar_Changed[i] = false;    // Radar is no longer forced off
                }
            }
        }
    }
    return Plugin_Continue;
}
