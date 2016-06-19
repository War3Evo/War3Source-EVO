// War3Source_Engine_DeciSecondLoop_Timer.sp

public War3Source_Engine_DeciSecondLoop_Timer_OnPluginStart()
{
	CreateTimer(0.1,DeciSecondLoop,_,TIMER_REPEAT);
}

//=============================================================================
// DeciSecondLoop
//=============================================================================
public Action:DeciSecondLoop(Handle:timer)
{
	if(!MapChanging && !War3SourcePause)
	{
		for(new client=1;client<=MaxClients;client++)
		{
			if(ValidPlayer(client,true))
			{
				if(!W3IsPlayerXPLoaded(client))
				{
					if(GetGameTime()>LastLoadingHintMsg[client]+4.0)
					{
						PrintHintText(client,"Loading XP... Please Wait");
						LastLoadingHintMsg[client]=GetGameTime();
					}
					continue;
				}
			}
		}
	}

	Engine_BuffSpeedGravGlow_DeciSecondTimer();
	War3Source_Engine_BuffHelper_DeciSecondTimer();
	War3Source_Engine_CooldownMgr_DeciSecondTimer();
	War3Source_Engine_Weapon_DeciSecondTimer();
}
