// War3Source_001_OnPluginStart.sp

//=============================================================================
// OnPluginStart
//=============================================================================

public OnPluginStart()
{
	PrintToServer("--------------------------OnPluginStart----------------------");

	if(GetExtensionFileStatus("sdkhooks.ext") < 1)
		SetFailState("SDK Hooks is not loaded.");

	if(!War3Source_HookEvents())
		SetFailState("[War3Source:EVO] There was a failure in initiating event hooks.");
	if(!War3Source_InitCVars()) //especially sdk hooks
		SetFailState("[War3Source:EVO] There was a failure in initiating console variables.");

	hCvarLoadRacesAndItemsOnMapStart=CreateConVar("war3_Load_RacesAndItems_every_map","0","0 = Disable | 1 = Enable");
	LoadRacesAndItemsOnMapStart=GetConVarBool(hCvarLoadRacesAndItemsOnMapStart);
	HookConVarChange(hCvarLoadRacesAndItemsOnMapStart, hCvarLoadRacesAndItemsOnMapStartChanged);

	// DeciSecondLoop Timer
	War3Source_Engine_DeciSecondLoop_Timer_OnPluginStart();

	War3Source_000_Engine_Hint_OnPluginStart();
	War3Source_Engine_Aura_OnPluginStart();
	War3Source_Engine_Bank_OnPluginStart();
	War3Source_Engine_BuffHelper_OnPluginStart();
#if (GGAMETYPE == GGAME_TF2)
	War3Source_Engine_BuffMaxHP_OnPluginStart();
#endif
	War3Source_Engine_BuffSystem_OnPluginStart();
	War3Source_Engine_CommandHook_OnPluginStart();
#if CYBORG_SKIN == MODE_ENABLED
#if (GGAMETYPE == GGAME_TF2)
	War3Source_Engine_Cyborg_OnPluginStart();
#endif
#endif
	War3Source_Engine_DamageSystem_OnPluginStart();
	War3Source_Engine_DatabaseSaveXP_OnPluginStart();
	War3Source_Engine_DatabaseTop100_OnPluginStart();
	War3Source_Engine_Dependency_OnPluginStart();
	War3Source_Engine_Download_Control_OnPluginStart();
	War3Source_Engine_Easy_Buff_OnPluginStart();
	War3Source_Engine_HelpMenu_OnPluginStart();

#if SHOPMENU3 == MODE_ENABLED
	War3Source_Engine_ItemDatabase3_OnPluginStart();
#endif
	War3Source_Engine_ItemOwnership_OnPluginStart();
	War3Source_Engine_ItemOwnership2_OnPluginStart();
#if SHOPMENU3 == MODE_ENABLED
	War3Source_Engine_ItemOwnership3_OnPluginStart();
#endif
	War3Source_Engine_MenuChangerace_OnPluginStart();
	War3Source_Engine_MenuRacePlayerinfo_OnPluginStart();
	War3Source_Engine_MenuShopmenu_OnPluginStart();
	War3Source_Engine_MenuShopmenu2_OnPluginStart();
#if SHOPMENU3 == MODE_ENABLED
	War3Source_Engine_MenuShopmenu3_OnPluginStart();
#endif
	War3Source_Engine_MenuSpendskills_OnPluginStart();
	War3Source_Engine_Money_Timer_OnPluginStart();
//#if (GGAMETYPE_JAILBREAK != JAILBREAK_OFF)
	War3Source_Engine_NewPlayers_OnPluginStart();
//#endif
	War3Source_Engine_PlayerClass_OnPluginStart();
	War3Source_Engine_PlayerCollision_OnPluginStart();
	War3Source_Engine_PlayerLevelbank_OnPluginStart();
	War3Source_Engine_RaceClass_OnPluginStart();
	War3Source_Engine_Race_KDR_OnPluginStart();
	War3Source_Engine_RaceRestrictions_OnPluginStart();
	War3Source_Engine_ShowMOTD_OnPluginStart();
	War3Source_Engine_SkillEffects_OnPluginStart();
	//War3Source_Engine_Statistics_OnPluginStart();
	//War3Source_Engine_StatSockets2_OnPluginStart();
	War3Source_Engine_TrieKeyValue_OnPluginStart();
	War3Source_Engine_Wards_Checking_OnPluginStart();
	War3Source_Engine_Wards_Engine_OnPluginStart();
	War3Source_Engine_Wards_Wards_OnPluginStart();
	War3Source_Engine_XPGold_OnPluginStart();
#if SHOPMENU3 == MODE_ENABLED
	War3Source_Engine_XP_Platinum_OnPluginStart();
#endif
	War3Source_Engine_WCX_Engine_Bash_OnPluginStart();
	War3Source_Engine_WCX_Engine_Skills_OnPluginStart();
#if (GGAMETYPE != GGAME_CSGO)
	War3Source_Engine_SteamTools_OnPluginStart();
#endif
	War3Source_Engine_BotControl_OnPluginStart();

#if (GGAMETYPE == GGAME_TF2)
	War3Source_002_OnW3SupplyLocker_OnPluginStart();
#endif

#if (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
	War3Source_Engine_CSGO_Radar_OnPluginStart();
#endif

	War3Source_002_OnW3HealthPickup_OnPluginStart();

	War3Source_Engine_Casting_OnPluginStart();

	War3Source_Engine_GameData_OnPluginStart();

	War3Source_003_RegisterPrivateForwards_OnPluginStart();


#if (GGAMETYPE == GGAME_FOF)
	// FOF player health change
	War3Source_000_Engine_Misc_OnPluginStart();
#endif


	//g_Prof = CreateProfiler();
	//g_Prof2 = CreateProfiler();

	PrintToServer("[War3Source:EVO] Plugin finished loading.\n-------------------END OnPluginStart-------------------");
}
