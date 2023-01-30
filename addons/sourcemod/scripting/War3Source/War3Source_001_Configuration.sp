// War3Source_000_Configuration.sp

War3Source_InitCVars()
{
#if MESSAGE_CONTROL_MODE == MODE_ENABLED
	// This only disables War3Source text, if a race uses a different method to send text, this will not disable that method.
	gh_CVAR_DisableAllText = CreateConVar("war3DisableAllMessages", "0", "0 disabled / 1 enabled\nDisables all War3Source based text.");
#endif

	gh_CVAR_AllowInstantSpawn = CreateConVar("war3AllowInstantRaceChange", "0", "0 disabled / 1 enabled\nAllows players to change race instantly in spawn.");

	gh_CVAR_War3Source_Pause = CreateConVar("war3pause", "0", "0 disabled / 1 enabled\nPauses all War3Source stuff, so plugins can be reloaded easier.");

	gh_AllowDeveloperAccess = CreateConVar("war3_allow_developer_access", "0", "0 disabled / 1 enabled\nallows developer to have developer access.");

	gh_AllowDeveloperPowers = CreateConVar("war3_allow_developer_powers", "0", "0 disabled / 1 enabled\nallows developer to bypass race restrictions, etc.");

#if GGAMETYPE == GGAME_TF2
	gh_MaxSpeedLimitConvar = CreateConVar("war3_maxspeed_limit", "9999.0", "9999.0 to disable speed limit. Must be a float.\nControls the overall speed limit of Warcraft, and allows TF2 speed bonuses to exceed it.");

	gh_MaxSpeedDebugConvar = CreateConVar("war3_maxspeed_debug", "0", "0 disabled / 1 enabled\nallows maxspeed debug messages.");

	HookConVarChange(gh_MaxSpeedDebugConvar, War3ConVarChanged);
	HookConVarChange(gh_MaxSpeedLimitConvar, War3ConVarChanged);
#endif
	HookConVarChange(gh_CVAR_War3Source_Pause, War3ConVarChanged);

	/*
	ChanceModifierPlasma=CreateConVar("war3_chancemodifier_directburn","0.0625","From 0.0 to 1.0 chance modifier for direct burns (plasma)");
	ChanceModifierBurn=CreateConVar("war3_chancemodifier_burn","0.10","From 0.0 to 1.0 chance modifier for burns");
	ChanceModifierHeavy=CreateConVar("war3_chancemodifier_heavy","0.125","From 0.0 to 1.0 chance modifier for heavy gun");
	ChanceModifierMedic=CreateConVar("war3_chancemodifier_medic","0.125","From 0.0 to 1.0 chance modifier for medic needle gun");
	ChanceModifierSMGSniper=CreateConVar("war3_chancemodifier_smgsniper","0.5","From 0.0 to 1.0 chance modifier for sniper SMG");

	*/
	hRaceLimitEnabled=CreateConVar("war3_racelimit_enable","1","Should race limit restrictions per team be enabled");
	internal_W3SetVar(hRaceLimitEnabledCvar,hRaceLimitEnabled);


	hChangeGameDescCvar=CreateConVar("war3_game_desc","1","change game description to war3source? does not affect player connect");

	hUseMetric=CreateConVar("war3_metric_system","0","Do you want use metric system? 1-Yes, 0-No");
	internal_W3SetVar(hUseMetricCvar,hUseMetric);

//=============================
// War3Source_Engine_BuffMaxHP
//=============================
#if GGAMETYPE == GGAME_TF2
	g_buffmaxhp_enable_tf2attributes = CreateConVar("tf2_attributes", "0", "1 = enabled, 0 is default.");
#endif

//=============================
// War3Source_Engine_BuffMaxHP
//=============================

	return true;
}

public War3ConVarChanged(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	if(cvar == gh_CVAR_War3Source_Pause)
	{
		int tmpinfo = StringToInt(newVal);
		War3SourcePause = tmpinfo?true:false;

		if(War3SourcePause)
		{
			War3_ChatMessage(0,"{yellow}War3Source:EVO has now been paused.");
		}
		else
		{
			War3_ChatMessage(0,"{yellow}War3Source:EVO has now resumed.");
		}
	}
#if GGAMETYPE == GGAME_TF2
	else if(cvar == gh_MaxSpeedLimitConvar)
	{
		fWar3_MaxSpeedLimit = StringToFloat(newVal);

		War3_ChatMessage(0,"{yellow}Max Warcraft Speed limits:");
		float fScout = FloatMul(fWar3_MaxSpeedLimit,TF2_GetClassSpeed(TFClass_Scout));
		float fSoldier = FloatMul(fWar3_MaxSpeedLimit,TF2_GetClassSpeed(TFClass_Soldier));
		float fDemo = FloatMul(fWar3_MaxSpeedLimit,TF2_GetClassSpeed(TFClass_DemoMan));
		float fMedic = FloatMul(fWar3_MaxSpeedLimit,TF2_GetClassSpeed(TFClass_Medic));
		float fPyro = FloatMul(fWar3_MaxSpeedLimit,TF2_GetClassSpeed(TFClass_Pyro));
		float fSpy = FloatMul(fWar3_MaxSpeedLimit,TF2_GetClassSpeed(TFClass_Spy));
		float fEngineer = FloatMul(fWar3_MaxSpeedLimit,TF2_GetClassSpeed(TFClass_Engineer));
		float fSniper = FloatMul(fWar3_MaxSpeedLimit,TF2_GetClassSpeed(TFClass_Sniper));
		float fHeavy = FloatMul(fWar3_MaxSpeedLimit,TF2_GetClassSpeed(TFClass_Heavy));

		War3_ChatMessage(0,"{yellow}Scout %.2f | Soldier %.2f | Demo %.2f",fScout,fSoldier,fDemo);
		War3_ChatMessage(0,"{yellow}Medic %.2f | Pyro %.2f | Spy %.2f",fMedic,fPyro,fSpy);
		War3_ChatMessage(0,"{yellow}Engineer %.2f | Sniper %.2f | Heavy %.2f",fEngineer,fSniper,fHeavy);

		// force speed update on all alive clients
		for(int client=1;client<=MaxClients;client++)
		{
			if(ValidPlayer(client,true))
			{
				reapplyspeed[client]++;
			}
		}
	}
	else if(cvar == gh_MaxSpeedDebugConvar)
	{
		bMaxSpeedDebugMessages = view_as<bool>(StringToInt(newVal));
	}
#endif
}

