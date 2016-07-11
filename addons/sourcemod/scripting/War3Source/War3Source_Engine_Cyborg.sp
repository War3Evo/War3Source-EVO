// War3Source_Engine_Cyborg.sp

#pragma semicolon 1

#if CYBORG_SKIN == MODE_ENABLED
#if GGAMETYPE == GGAME_TF2
/*
public Plugin:myinfo =
{
	name = "War3Source:EVO Cyborg Engine",
	author = "El Diablo",
	description = "War3Source:EVO Core Cyborg Engine.",
	version = "1.0.0.0",
	url = "http://Www.war3evo.info"
};
*/

enum RobotStatus {
	RobotStatus_Human = 0, // Client is human
	RobotStatus_WantsToBeRobot, // Client wants to be robot, but can't because of defined rules.
	RobotStatus_Robot // Client is a robot. Beep boop.
}

// robot
new RobotStatus:Status[MAXPLAYERS + 1] = { RobotStatus_Human, ... };
new Float:LastTransformTime[MAXPLAYERS + 1];


public War3Source_Engine_Cyborg_OnPluginStart()
{
	// a copy is in War3Source_002_OnW3SupplyLocker_OnPluginStart
	HookEvent("post_inventory_application", Event_Inventory, EventHookMode_Post);
}

public bool:War3Source_Engine_Cyborg_InitNatives()
{
	CreateNative("War3_ToggleCyborgSkin",NWar3_ToggleCyborgSkin);
	return true;
}


public NWar3_ToggleCyborgSkin(Handle:plugin,numParams)
{
	new client=GetNativeCell(1);
	new bool:toggle=GetNativeCell(2);
	if (ValidPlayer(client))
	{
		ToggleRobot(client,toggle);
	}
}

public War3Source_Engine_Cyborg_OnClientPutInServer(client)
{
	if(ValidPlayer(client))
	{
		Status[client]=RobotStatus_Human;
	}
}
public War3Source_Engine_Cyborg_OnClientDisconnect(client)
{
	if(ValidPlayer(client))
	{
		Status[client]=RobotStatus_Human;
	}
}

public Action:SoundHook(clients[64], &numClients, String:sound[PLATFORM_MAX_PATH], &Ent, &channel, &Float:volume, &level, &pitch, &flags)
{
	//if (!GetConVarBool(cvarSounds)) return Plugin_Continue;
	if (volume == 0.0 || volume == 0.9997) return Plugin_Continue;
	if (!IsValidClient(Ent)) return Plugin_Continue;
	new client = Ent;
	new TFClassType:class = TF2_GetPlayerClass(client);
	if (Status[client] == RobotStatus_Robot)
	{
		if (StrContains(sound, "player/footsteps/", false) != -1 && class != TFClass_Medic)
		{
			new rand = GetRandomInt(1,18);
			Format(sound, sizeof(sound), "mvm/player/footsteps/robostep_%s%i.wav", (rand < 10) ? "0" : "", rand);
			pitch = GetRandomInt(95, 100);
			War3_EmitSoundToAll(sound, client, _, _, _, 0.25, pitch);
			return Plugin_Changed;
		}
		if (StrContains(sound, "vo/", false) == -1) return Plugin_Continue;
		if (StrContains(sound, "announcer", false) != -1) return Plugin_Continue;
		if (volume == 0.99997) return Plugin_Continue;
		ReplaceString(sound, sizeof(sound), "vo/", "vo/mvm/norm/", false);
		ReplaceString(sound, sizeof(sound), ".wav", ".mp3", false);
		new String:classname[10], String:classname_mvm[15];
		TF2_GetNameOfClass(class, classname, sizeof(classname));
		Format(classname_mvm, sizeof(classname_mvm), "%s_mvm", classname);
		ReplaceString(sound, sizeof(sound), classname, classname_mvm, false);
		new String:soundchk[PLATFORM_MAX_PATH];
		Format(soundchk, sizeof(soundchk), "sound/%s", sound);
		if (!FileExists(soundchk, true)) return Plugin_Continue;
		War3_AddSound(sound,1,PRIORITY_LOW);
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public War3Source_Engine_Cyborg_OnMapStart()
{
	new String:classname[10], String:Mdl[PLATFORM_MAX_PATH];
	for (new TFClassType:i = TFClass_Scout; i <= TFClass_Engineer; i++)
	{
		TF2_GetNameOfClass(i, classname, sizeof(classname));
		Format(Mdl, sizeof(Mdl), "models/bots/%s/bot_%s.mdl", Mdl, Mdl);
		PrecacheModel(Mdl, true);
	}
	//ComeOnPrecacheZeSounds();
	PrecacheModel("models/bots/demo/bot_sentry_buster.mdl");
}

bool:CheckForCyborg(client)
{
	new String:RaceSTRname[32];
	GetRaceName(GetRace(client),RaceSTRname,sizeof(RaceSTRname));
	if(StrContains(RaceSTRname,"cyborg",false)>-1)
		return true;
	else
		return false;
}

public War3Source_Engine_Cyborg_OnW3Denyable(W3DENY:event,client)
{
	if((event == DN_CanBuyItem1) && (internal_W3GetVar(EventArg1) == War3_GetItemIdByShortname("mask")))
	{
		if(CheckForCyborg(client))
		{
			W3Deny();
			War3_ChatMessage(client, "Cyborgs can't feel the effects of these items!");
		}
	}
	if((event == DN_CanBuyItem1) && (internal_W3GetVar(EventArg1) == War3_GetItemIdByShortname("ring")))
	{
		if(CheckForCyborg(client))
		{
			W3Deny();
			War3_ChatMessage(client, "Cyborgs can't feel the effects of these items!");
		}
	}
	if((event == DN_CanBuyItem1) && (internal_W3GetVar(EventArg1) == War3_GetItemIdByShortname("gauntlet")))
	{
		if(CheckForCyborg(client))
		{
			W3Deny();
			War3_ChatMessage(client, "Cyborgs can't feel the effects of these items!");
		}
	}
	if((event == DN_CanBuyItem1) && (internal_W3GetVar(EventArg1) == War3_GetItemIdByShortname("hope")))
	{
		if(CheckForCyborg(client))
		{
			W3Deny();
			War3_ChatMessage(client, "Cyborgs can't feel the effects of these items!");
		}
	}
}


bool:CheckTheRules(client)
{
	if (!IsPlayerAlive(client)) return false;
	if (TF2_IsPlayerInCondition(client, TFCond_Taunting) ||
	TF2_IsPlayerInCondition(client, TFCond_Dazed)) return false;
	return true;
}

// a copy is in War3Source_002_OnW3SupplyLocker_OnPluginStart
public Cyborg_Event_Inventory(client, const String:name[], bool:dontBroadcast)
{
	if (Status[client])
	{
		new Float:cooldown = 0.0, bool:immediate;
		if (LastTransformTime[client] + cooldown <= GetTickedTime()) immediate = true;
		ToggleRobot(client, false);
		if (immediate) LastTransformTime[client] = 0.0;
		ToggleRobot(client, true);
	}
}

bool:ToggleRobot(client, bool:toggle = bool:2)
{
	if (Status[client] == RobotStatus_WantsToBeRobot && toggle != false && toggle != true) return true;
	if (!Status[client] && !toggle) return true;
	if (Status[client] == RobotStatus_Robot && toggle == true && CheckTheRules(client)) return true;
	if (!Status[client] || Status[client] == RobotStatus_WantsToBeRobot)
	{
		new bool:rightnow = true;
		if (!IsPlayerAlive(client)) rightnow = false;
	//	if (isBuster[client]) return false;
		if (!CheckTheRules(client)) rightnow = false;
		if (!rightnow)
		{
			Status[client] = RobotStatus_WantsToBeRobot;
			return false;
		}
	}
	if (toggle == true || (toggle == bool:2 && Status[client] == RobotStatus_Human))
	{
		new String:classname[10];
		TF2_GetNameOfClass(TF2_GetPlayerClass(client), classname, sizeof(classname));
		new String:Mdl[PLATFORM_MAX_PATH];
		Format(Mdl, sizeof(Mdl), "models/bots/%s/bot_%s.mdl", classname, classname);
		ReplaceString(Mdl, sizeof(Mdl), "demoman", "demo", false);
		SetVariantString(Mdl);
		AcceptEntityInput(client, "SetCustomModel");
		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
		LastTransformTime[client] = GetTickedTime();
		Status[client] = RobotStatus_Robot;
		SetWearableAlpha(client, 0);
	}
	else if (!toggle || (toggle == bool:2 && Status[client] == RobotStatus_Robot)) // Can possibly just be else. I am not good with logic.
	{
		SetVariantString("");
		AcceptEntityInput(client, "SetCustomModel");
		LastTransformTime[client] = GetTickedTime();
		Status[client] = RobotStatus_Human;
		SetWearableAlpha(client, 255);
	}
	return true;
}

TF2_GetNameOfClass(TFClassType:class, String:name[], maxlen)
{
	switch (class)
	{
		case TFClass_Scout: Format(name, maxlen, "scout");
		case TFClass_Soldier: Format(name, maxlen, "soldier");
		case TFClass_Pyro: Format(name, maxlen, "pyro");
		case TFClass_DemoMan: Format(name, maxlen, "demoman");
		case TFClass_Heavy: Format(name, maxlen, "heavy");
		case TFClass_Engineer: Format(name, maxlen, "engineer");
		case TFClass_Medic: Format(name, maxlen, "medic");
		case TFClass_Sniper: Format(name, maxlen, "sniper");
		case TFClass_Spy: Format(name, maxlen, "spy");
	}
}

bool:IsValidClient(client)
{
	if (client <= 0 || client > MaxClients) return false;
	if (!IsClientInGame(client)) return false;
	if (IsClientSourceTV(client) || IsClientReplay(client)) return false;
	return true;
}

SetWearableAlpha(client, alpha)
{
	new count;
	for (new z = MaxClients + 1; z <= 2048; z++)
	{
		if (!IsValidEntity(z)) continue;
		decl String:cls[35];
		GetEntityClassname(z, cls, sizeof(cls));
		if (!StrEqual(cls, "tf_wearable") && !StrEqual(cls, "tf_powerup_bottle")) continue;
		if (client != GetEntPropEnt(z, Prop_Send, "m_hOwnerEntity")) continue;
		SetEntityRenderMode(z, RENDER_TRANSCOLOR);
		SetEntityRenderColor(z, 255, 255, 255, alpha);
		count++;
	}
	return count;
}

public War3Source_Engine_Cyborg_OnAddSound(sound_priority)
{
	if(sound_priority==PRIORITY_TOP) //tf2 stock should load very fast
	{
		War3_AddSound("mvm/sentrybuster/mvm_sentrybuster_explode.wav",STOCK_SOUND);
		War3_AddSound("mvm/sentrybuster/mvm_sentrybuster_intro.wav",STOCK_SOUND);
		War3_AddSound("mvm/sentrybuster/mvm_sentrybuster_loop.wav",STOCK_SOUND);
		War3_AddSound("mvm/sentrybuster/mvm_sentrybuster_spin.wav",STOCK_SOUND);
		for (new i = 1; i <= 18; i++)
		{
			decl String:snd[PLATFORM_MAX_PATH];
			Format(snd, sizeof(snd), "mvm/player/footsteps/robostep_%s%i.wav", (i < 10) ? "0" : "", i);
			War3_AddSound(snd,1);
			if (i <= 4)
			{
				Format(snd, sizeof(snd), "mvm/sentrybuster/mvm_sentrybuster_step_0%i.wav", i);
				War3_AddSound(snd,STOCK_SOUND);
			}
			if (i <= 6)
			{
				Format(snd, sizeof(snd), "vo/mvm_sentry_buster_alerts0%i.wav", i);
				War3_AddSound(snd,STOCK_SOUND);
			}
		}
	}
}
#endif
#endif
