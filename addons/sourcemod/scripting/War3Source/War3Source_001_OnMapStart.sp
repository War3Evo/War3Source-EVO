//War3Source_001_OnMapStart
// moved from War3Source.sp

//=============================================================================
// OnMapStart
//=============================================================================
public OnMapStart()
{
	
	// moved to gameEvents.sp
	//MapChanging = false;

	PrintToServer("War3Source:EVO OnMapStart Start");

	if(!MapStart)
	{
		LoadTranslations("w3s._common.phrases");
	}

	if(LoadRacesAndItemsOnMapStart)
	{
		LoadRacesAndItems();
		RacesAndItemsLoaded=true;
	} else if(!LoadRacesAndItemsOnMapStart&&!RacesAndItemsLoaded)
	{
		LoadRacesAndItems();
		RacesAndItemsLoaded=true;
	}

	MapStart=true;
	
	War3Source_Engine_Casting_OnMapStart();

#if GGAMETYPE == GGAME_CSGO
	War3Source_Engine_CSGO_Radar_OnMapStart();
	War3Source_Engine_BuffSpeedGravGlow_OnMapStart();
#endif

	War3Source_Engine_CooldownMgr_OnMapStart();
#if CYBORG_SKIN == MODE_ENABLED
#if GGAMETYPE == GGAME_TF2
	War3Source_Engine_Cyborg_OnMapStart();
#endif
#endif
	War3Source_Engine_DatabaseTop100_OnMapStart();
	War3Source_Engine_Download_Control_OnMapStart();
	War3Source_Engine_MenuChangerace_OnMapStart();
	War3Source_Engine_Race_KDR_OnMapStart();
	War3Source_Engine_SkillEffects_OnMapStart();
	//War3Source_Engine_Statistics_OnMapStart();
	War3Source_Engine_Wards_Checking_OnMapStart();
	War3Source_Engine_XPGold_OnMapStart();
	War3Source_Engine_WCX_Engine_Skills_OnMapStart();
#if GGAMETYPE == GGAME_TF2
	War3Source_Engine_BotControl_OnMapStart();
#endif
	//War3Source_Engine_PlayerDeathWeapons_OnMapStart();
	War3Source_Engine_Weapon_OnMapStart();

	War3Source_003_RegisterPrivateForwards_OnMapStart();

	//CreateTimer(5.0, CheckCvars, 0);

	// No Reason to check interface versions
	//OneTimeForwards();

	PrintToServer("War3Source:EVO OnMapStart Finished");
}

