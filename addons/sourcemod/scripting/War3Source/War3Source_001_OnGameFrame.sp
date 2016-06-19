// War3Source_Engine_OnGameFrame.sp

public OnGameFrame()
{
	if(!MapChanging || War3SourcePause)
	{
		for(new i=1;i<MaxClients;i++){   // was MAXPLAYERSCUSTOM
			bHasDiedThisFrame[i]=0;
		}
	}

	War3Source_Engine_BuffSpeedGravGlow_OnGameFrame();

	War3Source_000_Engine_Hint_OnGameFrame();

	War3Source_Engine_PlayerDeathWeapons_OnGameFrame();

	War3Source_Engine_Regen_OnGameFrame();

	//War3Source_Engine_StatSockets2_OnGameFrame();

	War3Source_Engine_Wards_Engine_OnGameFrame();

	War3Source_Engine_Weapon_OnGameFrame();
}
