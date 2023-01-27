// War3Source_000_Engine_InitNatives.sp

//=============================================================================
// War3Source_InitNatives
//=============================================================================
public bool War3Source_InitNatives()
{
	bool Return_InitNatives=false;

	///LIST ALL THESE NATIVES IN INTERFACE

	CreateNative("W3GetW3Version",NW3GetW3Version);
	CreateNative("W3GetW3Revision",NW3GetW3Revision);
	CreateNative("War3_InFreezeTime",Native_War3_InFreezeTime);

	CreateNative("W3FlashScreen",Native_W3FlashScreen);
	CreateNative("War3_ShakeScreen",Native_War3_ShakeScreen);

	CreateNative("War3_SpawnPlayer",Native_War3_SpawnPlayer);

#if GGAMETYPE == GGAME_TF2
	CreateNative("War3_IsUbered",Native_War3_IsUbered);

	//CreateNative("War3_PrecacheSound",Native_War3_PrecacheSound);
	CreateNative("War3_IsCloaked",Native_War3_IsUbered);

	CreateNative("War3_TF_ParticleToClient",Native_War3_TF_PTC);
#endif
	CreateNative("War3_HealToMaxHP",Native_War3_HTMHP);
	CreateNative("War3_HealToBuffHP",Native_War3_HTBHP);
	CreateNative("War3_DecreaseHP",Native_War3_DecreaseHP);

	CreateNative("W3IsDeveloper",NW3IsDeveloper);
	CreateNative("W3IsHelper",NW3IsHelper);

	CreateNative("W3GetVar",NW3GetVar);
	CreateNative("W3SetVar",NW3SetVar);
	CreateNative("W3HasDiedThisFrame",NW3HasDiedThisFrame);

//=============================
// War3Source_000_Engine_Hint
//=============================
	CreateNative("W3Hint",NW3Hint);

//=============================
// War3Source_000_Engine_Log
//=============================
	CreateNative("W3Log",NW3Log);
	CreateNative("W3LogError",NW3LogError);
	CreateNative("W3LogNotError",NW3LogNotError);

	CreateNative("CreateWar3GlobalError",NCreateWar3GlobalError);

//=============================
// War3Source_Engine_Aura
//=============================
	//Backwards compatible old format / easy buff compatible
	CreateNative("W3RegisterAura",NW3RegisterAura);//for races
	CreateNative("W3SetAuraFromPlayer",NW3SetAuraFromPlayer);

	// New format allows greater flexiblity with distances
	CreateNative("W3RegisterChangingDistanceAura",NW3RegisterChangingDistanceAura);//for races
	CreateNative("W3SetPlayerAura",NW3SetPlayerAura);

	// Both systems use this:
	CreateNative("W3RemovePlayerAura",NW3RemovePlayerAura);
	CreateNative("W3HasAura",NW3HasAura);

//=============================
// War3Source_Engine_Bank
//=============================
	CreateNative("War3_BankCanWithdraw",NWar3_BankCanWithdraw);
	CreateNative("War3_BankWithdrawTimeLeft",NWar3_BankWithdrawTimeLeft);

	CreateNative("War3_DepositGoldBank",NWar3_DepositGoldBank);
	CreateNative("War3_WithdrawGoldBank",NWar3_WithdrawGoldBank);
	CreateNative("War3_SetGoldBank",NWar3_SetGoldBank);
	CreateNative("War3_GetGoldBank",NWar3_GetGoldBank);

//=============================
// War3Source_Engine_BuffHelper
//=============================
	//CreateNative("W3RegisterBuffHelper",NW3ApplyBuff);
	//CreateNative("W3SetBuffHelper",NW3ApplyBuff);
	CreateNative("W3ApplyBuffSimple",NW3ApplyBuffSimple);

//=============================
// War3Source_Engine_BuffSpeedGravGlow
//=============================
	Return_InitNatives = War3Source_Engine_BuffSpeedGravGlow_InitNatives();


	Return_InitNatives = War3Source_Engine_Casting_InitNatives();


	Return_InitNatives = War3Source_Engine_BuffSystem_InitNatives();

	Return_InitNatives = War3Source_Engine_CooldownMgr_InitNatives();

#if CYBORG_SKIN == MODE_ENABLED
#if GGAMETYPE == GGAME_TF2
	Return_InitNatives = War3Source_Engine_Cyborg_InitNatives();
#endif
#endif

	Return_InitNatives = War3Source_Engine_DamageSystem_InitNatives();

	Return_InitNatives = War3Source_Engine_DatabaseSaveXP_InitNatives();

	Return_InitNatives = War3Source_Engine_Dependency_InitNatives();

	Return_InitNatives = War3Source_Engine_Download_Control_InitNatives();

	Return_InitNatives = War3Source_Engine_Easy_Buff_InitNatives();

	Return_InitNatives = War3Source_Engine_Events_InitNatives();

	Return_InitNatives = War3Source_Engine_HelpMenu_InitNatives();

	Return_InitNatives = War3Source_Engine_ItemClass_InitNatives();

	Return_InitNatives = War3Source_Engine_ItemClass2_InitNatives();

#if SHOPMENU3 == MODE_ENABLED
	Return_InitNatives = War3Source_Engine_ItemClass3_InitNatives();
#endif

#if SHOPMENU3 == MODE_ENABLED
	Return_InitNatives = War3Source_Engine_ItemDatabase3_InitNatives();
#endif

	Return_InitNatives = War3Source_Engine_ItemOwnership_InitNatives();

	Return_InitNatives = War3Source_Engine_ItemOwnership2_InitNatives();

#if SHOPMENU3 == MODE_ENABLED
	Return_InitNatives = War3Source_Engine_ItemOwnership3_InitNatives();
#endif

	Return_InitNatives = War3Source_Engine_MenuChangerace_InitNatives();

	Return_InitNatives = War3Source_Engine_NewPlayers_InitNatives();

	Return_InitNatives = War3Source_Engine_Notifications_InitNatives();

	Return_InitNatives = War3Source_Engine_PlayerClass_InitNatives();

	Return_InitNatives = War3Source_Engine_PlayerDeathWeapons_InitNatives();

	Return_InitNatives = War3Source_Engine_PlayerLevelbank_InitNatives();

	Return_InitNatives = War3Source_Engine_PlayerTrace_InitNatives();

	Return_InitNatives = War3Source_Engine_RaceClass_InitNatives();

	Return_InitNatives = War3Source_Engine_SkillsClass_InitNatives();

	Return_InitNatives = War3Source_Engine_Race_KDR_InitNatives();

	Return_InitNatives = War3Source_Engine_SkillEffects_InitNatives();

	//Return_InitNatives = War3Source_Engine_Statistics_InitNatives();
	//Return_InitNatives = War3Source_Engine_StatSockets2_InitNatives();

	Return_InitNatives = War3Source_Engine_TrieKeyValue_InitNatives();

	Return_InitNatives = War3Source_Engine_Wards_Engine_InitNatives();

	Return_InitNatives = War3Source_Engine_Wards_Engine_Behavior_InitNatives();

	Return_InitNatives = War3Source_Engine_Weapon_InitNatives();

	Return_InitNatives = War3Source_Engine_XPGold_InitNatives();

#if SHOPMENU3 == MODE_ENABLED
	Return_InitNatives = War3Source_Engine_XP_Platinum_InitNatives();
#endif

	Return_InitNatives = War3Source_Engine_WCX_Engine_Skills_InitNatives();

	Return_InitNatives = War3Source_Engine_WCX_Engine_Teleport_InitNatives();
#if GGAMETYPE != GGAME_CSGO
	Return_InitNatives = War3Source_Engine_SteamTools_InitNatives();
#endif

	Return_InitNatives = War3Source_Engine_BotControl_InitNatives();

	Return_InitNatives = War3Source_Engine_GameData_InitNatives();

	Return_InitNatives = War3Source_003_RegisterPrivateForwards_InitNatives();
	
	Return_InitNatives = War3Source_Engine_Messages_InitNatives();

	//disabled
	//Return_InitNatives = War3Source_Engine_Talents_InitNatives();


	//Return_InitNatives =
	//Return_InitNatives =

	return Return_InitNatives;
}


