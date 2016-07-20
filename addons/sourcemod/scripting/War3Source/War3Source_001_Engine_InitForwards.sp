// War3Source_000_Engine_InitForwards.sp

//=============================================================================
// War3Source_InitForwards
//=============================================================================
public bool War3Source_InitForwards()
{
	bool Return_InitForwards=false;

	g_OnWar3PluginReadyHandle=CreateGlobalForward("OnWar3LoadRaceOrItemOrdered",ET_Ignore,Param_Cell);//ordered
	g_OnWar3PluginReadyHandle2=CreateGlobalForward("OnWar3LoadRaceOrItemOrdered2",ET_Ignore,Param_Cell,Param_Cell,Param_String);//ordered
	g_OnWar3PluginReadyHandle3=CreateGlobalForward("OnWar3PluginReady",ET_Ignore); //unodered rest of the items or races. backwards compatable..

	// OnWar3EventSpawn is now a Private Forward.  See war3source.inc
	p_OnWar3EventSpawnFH=CreateForward(ET_Ignore,Param_Cell);

	// Need to convert War3EventDeath into a private forward
	g_OnWar3EventDeathFH=CreateGlobalForward("OnWar3EventDeath",ET_Ignore,Param_Cell,Param_Cell,Param_Cell,Param_Cell,Param_Cell,Param_Cell,Param_Cell);

//=============================
// War3Source_001_OnSkinChange
//=============================

	p_OnWar3SkinChange=CreateForward(ET_Ignore,Param_Cell,Param_Cell);

//=============================
// War3Source_000_Engine_Log
//=============================
	hGlobalErrorFwd=CreateGlobalForward("OnWar3GlobalError",ET_Ignore,Param_String);

//=============================
// War3Source_Engine_Aura
//=============================
	g_Forward=CreateGlobalForward("OnW3PlayerAuraStateChanged",ET_Ignore,Param_Cell,Param_Cell,Param_Cell,Param_Cell,Param_Cell,Param_Cell);

//=============================
// War3Source_Engine_Bank
//=============================
	g_OnWar3_BANK_PlayerLoadData=CreateGlobalForward("OnWar3_BANK_PlayerLoadData",ET_Ignore,Param_Cell);

//=============================
// War3Source_Engine_CommandHook
//=============================
	//"OnUltimateCommand" private forward
	p_OnUltimateCommand=CreateForward(ET_Ignore,Param_Cell,Param_Cell,Param_Cell,Param_Cell,Param_Cell);
	//"OnAbilityCommand" private forward
	p_OnAbilityCommand=CreateForward(ET_Ignore,Param_Cell,Param_Cell,Param_Cell,Param_Cell);
	//"OnUseItemCommand" private forward
	p_OnUseItemCommand=CreateForward(ET_Ignore,Param_Cell,Param_Cell,Param_Cell);

	Return_InitForwards = War3Source_Engine_Casting_InitForwards();

	Return_InitForwards = War3Source_Engine_CooldownMgr_InitNativesForwards();

	Return_InitForwards = War3Source_Engine_DamageSystem_InitNativesForwards();

	Return_InitForwards = War3Source_Engine_Download_Control_InitNativesForwards();

	Return_InitForwards = War3Source_Engine_Events_InitNativesForwards();

	Return_InitForwards = War3Source_Engine_ItemOwnership_InitNativesForwards();

	Return_InitForwards = War3Source_Engine_ItemOwnership2_InitNativesForwards();

#if SHOPMENU3 == MODE_ENABLED
	Return_InitForwards = War3Source_Engine_ItemOwnership3_InitNativesForwards();
#endif

	Return_InitForwards = War3Source_Engine_MenuChangerace_InitNativesForwards();

	Return_InitForwards = War3Source_Engine_PlayerClass_InitNativesForwards();

	Return_InitForwards = War3Source_Engine_Wards_Engine_InitNativesForwards();

	Return_InitForwards = War3Source_Engine_Weapon_InitNativesForwards();

	Return_InitForwards = War3Source_Engine_WCX_Engine_Dodge_InitNativesForwards();

	Return_InitForwards = War3Source_Engine_WCX_Engine_Teleport_InitNativesForwards();

#if GGAMETYPE == GGAME_TF2
	Return_InitForwards = War3Source_002_OnW3SupplyLocker_InitNativesForwards();
#endif

	Return_InitForwards = War3Source_002_OnW3HealthPickup_InitNativesForwards();

	Return_InitForwards = War3Source_Engine_SkillsClass_InitForwards();

	//Return_InitForwards =
	//Return_InitForwards =
	//Return_InitForwards =
	//Return_InitForwards =

	return Return_InitForwards;
}
