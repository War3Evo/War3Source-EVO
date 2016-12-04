// War3Source_Engine_ClassControl.sp

#define FADE_DELAY		0.5

UserMsg fadeMsg;

//Permit new clip (you get ammo from nothing)
bool g_bNewClip = false;

TFCond PreserveConditions[] = {
	TFCond_Jarated,
	TFCond_Bleeding,
	TFCond_Milked,
	TFCond_OnFire,
	TFCond_Bonked,
	TFCond_MarkedForDeath,
};

enum ShapeShiftData
{
	Float:lastUseTime,
	bool:inRespawn,
	bool:regenCheck,
	TFClassType:lockedClass,
};

any SData[MAXPLAYERS+1][ShapeShiftData];
//bool PlayerShiftLocked[MAXPLAYERS+1];


float ConditionTimes[] = {
	10.0,
	10.0,
	10.0,
	10.0,
	10.0,
	10.0
};

TFCond ClientConditions[MAXPLAYERS+1][sizeof(PreserveConditions)];

int FadeSteps[] = { 255, 128, 64, 48, 24, 0 };

public bool War3Source_Engine_ClassControl_InitNatives()
{
	CreateNative("War3_SetClass",Native_War3_SetClass);

	return true;
}

public War3Source_Engine_ClassControl_OnMapStart()
{
	//Internal_War3_AddSound("npc/ichthyosaur/water_growl5.wav",STOCK_SOUND,PRIORITY_TOP);
	PrecacheSound("npc/ichthyosaur/water_growl5.wav");
}

public bool SetClass(int client, TFClassType targetClass, bool bSpecialEffects, bool bTryRemoveProblemEffects)
{
	if(TF2_IsPlayerInCondition(client, TFCond:44))
	{
		if(bTryRemoveProblemEffects)
		{
			TF2_RemoveCondition(client, TFCond:44);
			if(TF2_IsPlayerInCondition(client, TFCond:44))
			{
				War3_ChatMessage(client,"{red}You can change classes while having that kind of crits!");
				return false;
			}
		}
		else
		{
			return false;
		}
	}

	if(!TF2_IsPlayerInCondition(client, TFCond_Bonked))
	{
		if(bTryRemoveProblemEffects)
		{
			TF2_RemoveCondition(client, TFCond_Bonked);
			if(TF2_IsPlayerInCondition(client, TFCond_Bonked))
			{
				return false;
			}
		}
		else
		{
			return false;
		}
	}

	return DoShapeShift(client, targetClass, bSpecialEffects);
}

public int Native_War3_SetClass(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	TFClassType targetClass = view_as<TFClassType>(GetNativeCell(2));
	bool bSpecialEffects = view_as<bool>(GetNativeCell(3));
	bool bTryRemoveProblemEffects = view_as<bool>(GetNativeCell(4));

	// Make sure client is in game and alive
	if(ValidPlayer(client,true))
	{
		return view_as<int>(SetClass(client,targetClass,bSpecialEffects,bTryRemoveProblemEffects));
	}
	return false;
}


public bool DoShapeShift(int client, TFClassType targetClass, bool bSpecialEffects)
{
	TF2_RemoveCondition(client, TFCond:44);

	if (p_properties[client][CurrentClass] == TFClass_Engineer)
		KillBuildings(client);			// Else they'll keep em

	int oldAmmo1 = GetEntData(client, FindSendPropInfo("CTFPlayer", "m_iAmmo") + 4, 4);
	int oldAmmo2 = GetEntData(client, FindSendPropInfo("CTFPlayer", "m_iAmmo") + 8, 4);

	// Originally used timers to reapply Conditions, so stored globally
	// Might be necessary again, not sure

	for (int i = 0; i < sizeof(PreserveConditions); i++)
		ClientConditions[client][i] = TFCond:-1;
	int count = 0;
	for (int i = 0; i < sizeof(PreserveConditions); i++) {
		if (TF2_IsPlayerInCondition(client, PreserveConditions[i])) {
			ClientConditions[client][count++] = PreserveConditions[i];
		}
	}

	int oldFlags = GetEntityFlags(client);
	SetEntityFlags(client, oldFlags & ~FL_NOTARGET);	// Remove notarget if it was there
														// for whatever reason, weapons won't be
														// regenerated if FL_NOTARGET is set.

	int oldHealth = GetClientHealth(client);
	TF2_RegeneratePlayer(client);	// Prevents rare crash & gets ammo maxs
	//new oldMaxHealth = GetClientHealth(client);

	// now get the maxs, since the current ammo = max
	int oldMaxAmmo1 = GetEntData(client, FindSendPropInfo("CTFPlayer", "m_iAmmo") + 4, 4);
	int oldMaxAmmo2 = GetEntData(client, FindSendPropInfo("CTFPlayer", "m_iAmmo") + 8, 4);

	TF2_SetPlayerClass(client, targetClass, false, true);
	SData[client][regenCheck] = true;
	SetEntityHealth(client, 1);			// otherwise, if health > max health, you
										// keep current health with RegeneratePlayer
										// getting the new max health requires doing this
	TF2_RegeneratePlayer(client);

	int newMaxAmmo1 = GetEntData(client, FindSendPropInfo("CTFPlayer", "m_iAmmo") + 4, 4);
	int newMaxAmmo2 = GetEntData(client, FindSendPropInfo("CTFPlayer", "m_iAmmo") + 8, 4);

	// If old ammo == oldmaxammo, then use newmaxammmo
	// Avoids rounding

	int scaled1 = RoundFloat(oldMaxAmmo1 == oldAmmo1 ? float(newMaxAmmo1) :
		float(oldAmmo1) * (float(newMaxAmmo1) / float(oldMaxAmmo1)));

	int scaled2 = RoundFloat(oldMaxAmmo2 == oldAmmo2 ? float(newMaxAmmo2) :
		float(oldAmmo2) * (float(newMaxAmmo2) / float(oldMaxAmmo2)));

	int ws1 = GetPlayerWeaponSlot(client, 0);
	int ws2 = GetPlayerWeaponSlot(client, 1);
	int clipMain = -1, clip2nd = -1;
	if (ws1 > 0)
		clipMain = GetEntData(ws1, FindSendPropInfo("CTFWeaponBase", "m_iClip1"));
	if (ws2 > 0)
		clip2nd = GetEntData(ws2, FindSendPropInfo("CTFWeaponBase", "m_iClip1"));

	if (!g_bNewClip) {
		// Setting to 0 bugs certain weapons
		if (clipMain > -1)
			SetEntData(ws1, FindSendPropInfo("CTFWeaponBase", "m_iClip1"), 1);
		if (clip2nd > -1)
			SetEntData(ws2, FindSendPropInfo("CTFWeaponBase", "m_iClip1"), 1);
	}

	SetEntData(client, FindSendPropInfo("CTFPlayer", "m_iAmmo") + 4,
		scaled1);
	SetEntData(client, FindSendPropInfo("CTFPlayer", "m_iAmmo") + 8,
		scaled2);

	// Engies shouldn't get ammo
	if (targetClass == TFClass_Engineer)
		SetEntData(client, FindSendPropInfo("CTFPlayer", "m_iAmmo") + 12, 0, 4);
	/*
	new newMaxHealth = GetClientHealth(client);
	new Float:scaledHealth = oldHealth >= oldMaxHealth ? float(newMaxHealth) :
		float(oldHealth) * (float(newMaxHealth) / float(oldMaxHealth));
	new convertedHealth = RoundFloat(scaledHealth);

	// Prevent Scaling Up health == bad == free health
	// Only permit this if full health in the first place
	if (convertedHealth > oldHealth
		&& oldHealth < oldMaxHealth) convertedHealth = oldHealth;

	if (convertedHealth < 1) convertedHealth = 1;
	//SetEntityHealth(client, convertedHealth);
	*/
	SetEntityHealth(client,oldHealth);

	for (int i = 0; i < sizeof(PreserveConditions); i++) {
		if (ClientConditions[client][i] == TFCond:-1) break;
		if (ClientConditions[client][i] == TFCond_OnFire) {
			// removed because broken - need sourcemod update
			TF2_IgnitePlayer(client, client); continue;
		}
		TF2_AddCondition(client, ClientConditions[client][i], ConditionTimes[i]);
	}

	SData[client][lastUseTime] = GetGameTime();

	if (bSpecialEffects)
	{
		float origin[3];
		GetClientAbsOrigin(client, origin);
		War3_EmitSoundToAll("npc/ichthyosaur/water_growl5.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS,
			0.9, SNDPITCH_NORMAL, -1, origin, NULL_VECTOR, true, 0.0); //stock War3Source_Engine_Download_Control.inc

		StopFade(client);
		DoFade(client, 255);

		float special[3];
		float top[3];
		GetClientEyePosition(client, special);
		special[2] += 11.0;
		top = special;
		top[2] -= 30.0;

		if (GetClientTeam(client) == 2)
		{
			TimedParticle(client, "teleporter_red_entrance_level1", origin, 4.0);
			TimedParticle(client, "player_sparkles_red", special, 3.0);
			TimedParticle(client, "player_dripsred", special, 3.5);
			TimedParticle(client, "player_dripsred", top, 3.5);
			TimedParticle(client, "critical_rocket_red", top, 3.0);
			TimedParticle(client, "player_recent_teleport_red", top, 3.5);
		}
		else {
			TimedParticle(client, "teleporter_blue_entrance_level1", origin, 4.0);
			TimedParticle(client, "player_sparkles_blue", special, 3.0);
			TimedParticle(client, "player_drips_blue", special, 3.5);
			TimedParticle(client, "player_drips_blue", top, 3.5);
			TimedParticle(client, "critical_rocket_blue", top, 3.0);
			TimedParticle(client, "player_recent_teleport_blue", top, 3.5);
		}

		Handle dp = CreateDataPack();
		WritePackCell(dp, client);
		WritePackCell(dp, sizeof(FadeSteps)-1);
		CreateTimer(FADE_DELAY, Timer_Fade, dp, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}

	int slot;
	if ((slot = GetPlayerWeaponSlot(client, 0)) > -1)
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", slot);

	CreateTimer(1.0, Remove_Cond_44, GetClientUserId(client));

	//if (readyTimer && g_iDisplayReady > 0)
		//CreateTimer(g_fCooldown, Timer_DisplayReady, client);
	return true;
}

// force removal of heavy crits
public Action Remove_Cond_44(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if(ValidPlayer(client) && TF2_IsPlayerInCondition(client, TFCond:44))
	{
		TF2_RemoveCondition(client, TFCond:44);
		//CreateTimer(0.2, Remove_Cond_44, GetClientUserId(client));
	}
}

// *********************************************************************************************************************************************


stock void DoFade(int client, int amount)
{
	int clients[2];
	clients[0] = client;

	Handle message = StartMessageEx(fadeMsg, clients, 1);

	if(message!=INVALID_HANDLE)
	{
		if (GetUserMessageType() == UM_Protobuf)
		{
			PbSetInt(message, "duration", 255);
			PbSetInt(message, "hold_time", 255);
			PbSetInt(message, "flags", (0x0002));
			decl color[4] = { 255, 255, 255, 255 };
			PbSetColor(message, "clr", color);
		}
		else
		{
			BfWriteShort(message, 255);
			BfWriteShort(message, 255);
			BfWriteShort(message, (0x0002));
			BfWriteByte(message, 255);
			BfWriteByte(message, 255);
			BfWriteByte(message, 255);
			BfWriteByte(message, amount);
		}
		EndMessage();
	}
}

// *********************************************************************************************************************************************


stock void StopFade(int client)
{
	int clients[2];
	clients[0] = client;

	Handle message = StartMessageEx(fadeMsg, clients, 1);
	BfWriteShort(message, 1536);
	BfWriteShort(message, 1536);
	BfWriteShort(message, (0x0001 | 0x0010));
	BfWriteByte(message, 0);
	BfWriteByte(message, 0);
	BfWriteByte(message, 0);
	BfWriteByte(message, 0);
	EndMessage();
}

// *********************************************************************************************************************************************


stock void KillBuildings(int client)
{
	int maxentities = GetMaxEntities();
	for (int i = MaxClients+1; i <= maxentities; i++)
	{
		if (!IsValidEntity(i)) continue;
		char netclass[32];
		GetEntityNetClass(i, netclass, sizeof(netclass));

		if (strcmp(netclass, "CObjectSentrygun") == 0 || strcmp(netclass, "CObjectDispenser") == 0 || strcmp(netclass, "CObjectTeleporter") == 0) {
			if (GetEntDataEnt2(i, FindSendPropInfo("CObjectSentrygun","m_hBuilder")) == client)
			{
				SetVariantInt(9999);
				AcceptEntityInput(i, "RemoveHealth");
			}
		}
    }
}

// *********************************************************************************************************************************************


stock void TimedParticle(int ent, char[] name, float pos[3], float time)
{
	int particle = CreateEntityByName("info_particle_system");
	if (!IsValidEntity(particle)) return;
	DispatchKeyValue(particle, "effect_name", name);
	TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(particle);
	ActivateEntity(particle);
	AcceptEntityInput(particle, "start");

	if (ent > 0) {
		SetVariantString("!activator");
		AcceptEntityInput(particle, "SetParent", ent, particle, 0);
	}
	CreateTimer(time, Timer_ParticleEnd, particle);
}


// *********************************************************************************************************************************************

public Action Timer_ParticleEnd(Handle timer, any particle)
{
	if (!IsValidEntity(particle)) return;
	char classn[32];
	GetEdictClassname(particle, classn, sizeof(classn));
	if (strcmp(classn, "info_particle_system") != 0) return;
	RemoveEdict(particle);
}

// *********************************************************************************************************************************************

public Action Timer_Fade(Handle timer, any dp)
{
	ResetPack(dp);
	int client = ReadPackCell(dp);
	int index = ReadPackCell(dp);
	if (!IsClientInGame(client)) { CloseHandle(dp); return Plugin_Stop; }
	if (index < 1) { StopFade(client); CloseHandle(dp); return Plugin_Stop; }
	//SetPackPosition(dp, 0);
	ResetPack(dp, false);
	WritePackCell(dp, client);
	WritePackCell(dp, index-1);
	StopFade(client);
	DoFade(client, FadeSteps[index]);
	return Plugin_Continue;
}
