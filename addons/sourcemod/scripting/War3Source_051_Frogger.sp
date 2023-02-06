#include <war3source>

/*
	WARNING	WARNING	WARNING	WARNING	WARNING	WARNING	WARNING	WARNING	WARNING	WARNING
	* 
	* THERE ARE 'FindSendProp*' and other warnings that will show up in the compiler... for now I'm just ignoring them and you can too.
	* 
	* I'll fix those annoyances later.
 */

#pragma semicolon 1
//#include <sourcemod>
#include <tf2attributes>
//#include "sdkhooks"
//#include <sdkhooks>
//#include "W3SIncs/War3Source_Interface"
#if GGAMETYPE != GGAME_TF2
	#endinput
#endif

#if GGAMETYPE2 != GGAME_TF2_NORMAL
	#endinput
#endif

#if GGAMEMODE != MODE_WAR3SOURCE
	#endinput
#endif

#if GGAMETYPE_JAILBREAK != JAILBREAK_OFF
	#endinput
#endif
//#assert GGAMEMODE == MODE_WAR3SOURCE
//#assert GGAMETYPE == GGAME_TF2
//#assert GGAMETYPE_JAILBREAK == JAILBREAK_OFF

#define RACE_ID_NUMBER 510

//main list of player/teleport relation
enum telelist {
	tele_entity,			//teleport entity
	//tele_owner_team,		//team of teleport owner
	//Float: tele_ind_time	//individual teleport time (set by native call)
};
new TeleporterList[MAXPLAYERS + 1][telelist];

//new HasExtraDispenser[MAXPLAYERS + 1];

float ProgressiveCost[5]={1.0,0.90,0.80,0.70,0.60};

new MaximumWards[5]={0,1,2,3,4};
new PushPower[5]={0,1,2,3,4};

new
	//Handle:g_cvJumpBoost	= INVALID_HANDLE,
	Handle:g_cvJumpEnable	= INVALID_HANDLE,
	Handle:g_cvJumpMax		= INVALID_HANDLE,
	//Float:g_flBoost			= 250.0,
	bool:g_bDoubleJump		= true,
	g_fLastButtons[MAXPLAYERS+1],
	g_fLastFlags[MAXPLAYERS+1],
	g_iJumps[MAXPLAYERS+1],
	g_iJumpMax;

//new JumpDamage[5]={0,40,30,20,10};
new Float:JumpDistance[5]={0.0,200.0,300.0,400.0,500.0};

new Float:SwimSpeed[5]={0.0,1.2,1.3,1.4,1.5};

// War3Source stuff
new thisRaceID, SKILL_JUMP, SKILL_SWIMFAST, SKILL_BUGZAP_WARD, ULTIMATE, SKILL_FROGMAGIC; //, SKILL_UNDERWATER_WEAPON;

bool HooksLoaded = false;
public void Load_Hooks()
{
	if(HooksLoaded) return;
	HooksLoaded = true;

	W3Hook(W3Hook_OnW3TakeDmgAllPre, OnW3TakeDmgAllPre);
	W3Hook(W3Hook_OnAbilityCommand, OnAbilityCommand);
}
public void UnLoad_Hooks()
{
	if(!HooksLoaded) return;
	HooksLoaded = false;

	W3UnhookAll(W3Hook_OnW3TakeDmgAllPre);
	W3UnhookAll(W3Hook_OnAbilityCommand);
}
public void OnMapStart()
{
	UnLoad_Hooks();
}
bool RaceDisabled=true;
public OnWar3RaceEnabled(newrace)
{
	if(newrace==thisRaceID)
	{
		Load_Hooks();

		RaceDisabled=false;
	}
}
public OnWar3RaceDisabled(oldrace)
{
	if(oldrace==thisRaceID)
	{
		RaceDisabled=true;

		UnLoad_Hooks();
	}
}
//	if(RaceDisabled)
//		return;


public Plugin:myinfo =
{
	name = "War3Source Race - Frogger",
	author = "El Diablo",
	description = "Frogger race for War3Source.",
	version = "1.0.0.0",
	url = ""
};

new m_vecVelocity_0, m_vecVelocity_1, m_vecBaseVelocity; //offsets

int g_offsCollisionGroup;

public OnPluginStart()
{
	g_offsCollisionGroup = FindSendPropOffs("CBaseEntity", "m_CollisionGroup");

	// temporary until I can add to reloading of races or something?
	LoadTranslations("w3s._common.phrases");

		// DOUBLE JUMP
	g_cvJumpEnable = CreateConVar(
		"sm_doublejump_enabled", "1",
		"Enables double-jumping.",
		FCVAR_PLUGIN|FCVAR_NOTIFY
	);

	//g_cvJumpBoost = CreateConVar(
		//"sm_doublejump_boost", "800.0",
		//"The amount of vertical boost to apply to double jumps.",
		//FCVAR_PLUGIN|FCVAR_NOTIFY
	//);

	g_cvJumpMax = CreateConVar(
		"sm_doublejump_max", "3",
		"The maximum number of re-jumps allowed while already jumping.",
		FCVAR_PLUGIN|FCVAR_NOTIFY
	);

	//HookConVarChange(g_cvJumpBoost,		convar_ChangeBoost);
	HookConVarChange(g_cvJumpEnable,	convar_ChangeEnable);
	HookConVarChange(g_cvJumpMax,		convar_ChangeMax);

	g_bDoubleJump	= GetConVarBool(g_cvJumpEnable);
	//g_flBoost		= GetConVarFloat(g_cvJumpBoost);
	g_iJumpMax		= GetConVarInt(g_cvJumpMax);

	HookEvent("player_builtobject", event_player_builtobject, EventHookMode_Pre);
	HookEvent("player_carryobject", event_player_carryobject, EventHookMode_Pre);
	HookEvent("player_teleported", event_player_teleported, EventHookMode_Pre);

	m_vecVelocity_0 = FindSendPropOffs("CBasePlayer","m_vecVelocity[0]");
	m_vecVelocity_1 = FindSendPropOffs("CBasePlayer","m_vecVelocity[1]");
	m_vecBaseVelocity = FindSendPropOffs("CBasePlayer","m_vecBaseVelocity");

	HookEvent("player_changeclass", Frogger_PlayerChangeClassEvent, EventHookMode_Pre);

	/*
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
		}
	}*/
}

public Frogger_PlayerChangeClassEvent(Handle:event,const String:name[],bool:dontBroadcast)
{
	if(RaceDisabled)
		return;

	new userid=GetEventInt(event,"userid");
	//new classid=GetEventInt(event,"class");
	//_:TF2_GetPlayerClass(i)==classid
	if(userid>0)
	{
		new client=GetClientOfUserId(userid);
		if(ValidPlayer(client))
		{
			if(War3_GetRace(client)==thisRaceID)
			{
				InitPassiveSkills(client);
			}
		}
	}
}

public OnAllPluginsLoaded()
{
	War3_RaceOnPluginStart("frogger");
}

/**
 * Gets the Flags of an entity.
 *
 * @param entity			Entity Index.
 * @return					Entity Flags.
 */
stock Entity_GetFlags(entity)
{
	return GetEntProp(entity, Prop_Data, "m_fFlags");
}
/**
 * Sets the Flags of an entity.
 *
 * @param entity			Entity index.
 * @param flags				New Flags value
 * @noreturn
 */
stock Entity_SetFlags(entity, flags)
{
	SetEntProp(entity, Prop_Data, "m_fFlags", flags);
}

/**
 * Adds Flags to the entity
 *
 * @param entity			Entity index.
 * @param flags				Flags to add
 * @noreturn
 */
stock Entity_AddFlags(entity, flags)
{
	new setFlags = Entity_GetFlags(entity);
	setFlags |= flags;
	Entity_SetFlags(entity, flags);
}

/**
 * Removes flags from the entity
 *
 * @param entity			Entity index.
 * @param flags				Flags to remove
 * @noreturn
 */
stock Entity_RemoveFlags(entity, flags)
{
	new setFlags = Entity_GetFlags(entity);
	setFlags &= ~flags;
	Entity_SetFlags(entity, setFlags);
}

public OnPluginEnd()
{
	if(LibraryExists("RaceClass"))
		War3_RaceOnPluginEnd("frogger");
}

//http://optf2.com/440/attributes
public OnWar3LoadRaceOrItemOrdered2(num,reloadrace_id,String:shortname[])
{
	if(num==RACE_ID_NUMBER||(reloadrace_id>0&&StrEqual("frogger",shortname,false)))
	{
		thisRaceID = War3_CreateNewRace( "Frogger", "frogger",reloadrace_id, "Frogger" );

		SKILL_JUMP = War3_AddRaceSkill( thisRaceID, "Super Jump", "Take half fall damage\nEvery level gives you increased jump range\n and increased boost out of water.\n(+ability2) Leap forward.", false, 4 );
		if(SKILL_JUMP>0)
		{
			PrintToServer("Frogger Race loaded");
		}
		SKILL_SWIMFAST = War3_AddRaceSkill( thisRaceID, "Swim Fast", "Every level gives you increases your swim speed\nwhile in water.", false, 4 );

		SKILL_BUGZAP_WARD = War3_AddRaceSkill( thisRaceID, "Bug Zapper", "(+ability) Zaps enemies.\nMaximum of 4 wards 60 ft radius.\n1/2/3/4 dmg per quarter second", false, 4 );

		SKILL_FROGMAGIC = War3_AddRaceSkill( thisRaceID, "Frog Magic", "You can build 3-way Mini Sentries.\nBuildings get cheaper.\nBuildings cost 90/80/70/60 percent of normal cost.\nDuring the 20 second cooldown, you can not build sentries.", false, 4 );

		ULTIMATE =  War3_AddRaceSkill( thisRaceID, "Lilly Pads", "[Lvl 1]Can use any teleporter (blue/red)\n[Lvl 2]Teleporters instant recharge when you walk thru them\n[Lvl 3]Mini-Instant level 3 teleporter\n[Lvl 4]Build Double Dispensers", true, 4 );

		War3_CreateRaceEnd( thisRaceID );
		
/*     Race Dependences work better on the OnWar3PluginReady() forward and not here.
		new GetRaceID=War3_GetRaceIDByShortname("sailfish");
		if(GetRaceID>0)
		{
			War3_SetRaceDependency(thisRaceID, GetRaceID, 13);
		}
		GetRaceID=War3_GetRaceIDByShortname("hyperC");
		if(GetRaceID>0)
		{
			War3_SetRaceDependency(thisRaceID, GetRaceID, 16);
		}*/
//hyperC
	}
}

public OnWar3PluginReady()
{
	/*  temporary remove race dependancies
	new GetRaceID=War3_GetRaceIDByShortname("sailfish");
	if(GetRaceID>0)
	{
		War3_SetRaceDependency(thisRaceID, GetRaceID, 13);
	}
	else
	{
		SetFailState("Could Not Find sailfish Race on Load.");
	}
	GetRaceID=War3_GetRaceIDByShortname("hyperC");
	if(GetRaceID>0)
	{
		War3_SetRaceDependency(thisRaceID, GetRaceID, 16);
	}
	else
	{
		SetFailState("Could Not hyperC Race on Load.");
	}
	*/
}
/*

public void OnWar3EventSpawn (int client)
* {
	HasExtraDispenser[client]=-1;
}*/
/*
public OnWar3EventDeath(victim, attacker, deathrace, distance, attacker_hpleft){
	//AcceptEntityInput(HasExtraDispenser[victim], "Kill");
	//HasExtraDispenser[victim]=-1;
	if(ValidPlayer(victim) && deathrace==thisRaceID)
	{
			// destory left over sentries
			int iEnt;
			bool iCleanDestroy = true;
			while ((iEnt = FindEntityByClassname(iEnt, "obj_sentrygun")) != INVALID_ENT_REFERENCE)
			{
					if (GetEntPropEnt(iEnt, Prop_Send, "m_hBuilder") == victim)
					{
						if (iCleanDestroy)
							AcceptEntityInput(iEnt, "Kill");
						else
						{
							SetVariantInt(1000);
							AcceptEntityInput(iEnt, "RemoveHealth");
						}
					}
			}
	}
}*/

public void OnSkillLevelChanged(int client, int currentrace, int skill, int newskilllevel, int oldskilllevel)
{
	if (currentrace == thisRaceID)
	{
		if(skill == SKILL_FROGMAGIC && newskilllevel>0)
		{
			if(TF2_GetPlayerClass(client)==TFClass_Engineer)
			{
				if(TF2Attrib_GetByName(client, "building cost reduction")==Address_Null)
				{
					TF2Attrib_SetByName(client, "building cost reduction",ProgressiveCost[newskilllevel]);
				}
			}
		}
	}
}

public InitPassiveSkills(client)
{
	if(War3_GetRace(client)==thisRaceID)
	{
		if(TF2_GetPlayerClass(client)==TFClass_Engineer)
		{
			new skill_level=War3_GetSkillLevel(client,thisRaceID,SKILL_FROGMAGIC);
			if(skill_level>0)
			{
				if(TF2Attrib_GetByName(client, "building cost reduction")==Address_Null)
				{
					TF2Attrib_SetByName(client, "building cost reduction",ProgressiveCost[skill_level]);
				}
			}
		}
	}
}

public OnRaceChanged(client,oldrace,newrace)
{
	if(newrace==thisRaceID)
	{
		DestoryEngiBuildings(client);

		if(TF2_GetPlayerClass(client)==TFClass_Heavy)
		{
			War3_SetBuff(client,fArmorPhysical,thisRaceID,-6.0);
		}
		else
		{
			War3_SetBuff(client,fArmorPhysical,thisRaceID,0.0);
		}

		InitPassiveSkills(client);

/*
		if(TF2_GetPlayerClass(client)==TFClass_Engineer)
		{
			//TF2Attrib_SetByName(client, "SET BONUS: special dsp", 11.0);

			new skill_level=War3_GetSkillLevel(client,thisRaceID,SKILL_TADPOLES);
			if(skill_level>0)
			{
				if(TF2Attrib_GetByName(client, "engy disposable sentries")==Address_Null)
				{
					TF2Attrib_SetByName(client, "engy disposable sentries", 2.0);
				}
				else
				{
					TF2Attrib_RemoveByName(client, "engy disposable sentries");
					TF2Attrib_SetByName(client, "engy disposable sentries", 2.0);
				}
			}
		}
	} else if(oldrace==thisRaceID)
	{
		War3_SetBuff(client,fArmorPhysical,thisRaceID,0.0);
		TF2Attrib_RemoveByName(client, "engy disposable sentries");
	}*/
	} else //if(oldrace==thisRaceID)
	{
		DestoryEngiBuildings(client);

		TF2Attrib_RemoveByName(client, "building cost reduction");

		//SDKUnhook(client,SDKHook_WeaponSwitchPost,SDK_OnWeaponSwitchPost);
		War3_SetBuff(client,fArmorPhysical,thisRaceID,0.0);
	}
}
/*
public SDK_OnWeaponSwitchPost(client, weapon)
{
	if(RaceDisabled)
		return;

	if(ValidPlayer(client))
	{
		if(War3_GetRace(client)==thisRaceID && TF2_GetPlayerClass(client)==TFClass_Engineer)
		{
			new skill_level=War3_GetSkillLevel(client,thisRaceID,SKILL_TADPOLES);
			if(skill_level>0)
			{
				if(weapon>-1)
				{
					new wep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

					if (!IsValidEntity(wep)) return;
					//mult_reload_time
					if(wep>-1 && TF2Attrib_SetByName(wep, "multiple sentries", 1.0))
					{
						//DP("It has been SSSSSSSSSSSSSSSet");
					}
					if(wep>-1 && TF2Attrib_SetByName(wep, "engy disposable sentries", 2.0))
					{
						//DP("It has been SSSSSSSSSSSSSSSet");
					}
				}
			}
		}
		else
		{
			new wep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			//if(wep>-1 && TF2Attrib_GetByName(wep, "engy disposable sentries")!=Address_Null)
			if(wep>-1)
			{
				TF2Attrib_RemoveByName(wep, "engy disposable sentries");
			}
		}
	}
}*/

public OnWardExpire(wardindex, owner, behaviorID)
{
	if(RaceDisabled)
		return;

	if(ValidPlayer(owner) && War3_GetRace(owner)==thisRaceID)
	{
		new skill_level=War3_GetSkillLevel(owner,thisRaceID,SKILL_BUGZAP_WARD);
		W3Hint(owner,HINT_COOLDOWN_EXPIRED,4.0,"You now have %d/%d Bug Zapper Wards.", War3_GetWardCount(owner)-1, MaximumWards[skill_level]);
	}
}

public Action:TF2_OnPlayerTeleport(client, teleporter, &bool:result)
{
	if(RaceDisabled)
		return Plugin_Continue;

	if(War3_GetRace(client)==thisRaceID)
	{
		if(War3_GetSkillLevel(client,thisRaceID,ULTIMATE)>0)
		{
			result = true;
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}

/*
stock BuildDispenser(iBuilder, Float:fOrigin[3], Float:fAngle[3], iDisabled=0)
{
	new Float:fBuildMaxs[3] = { 24.0, 24.0, 66.0 };
	//new Float:fMdlWidth[3] = { 1.0, 0.5, 0.0 };

	new iTeam = GetClientTeam(iBuilder);

	new iHealth = 150;
	new iMetal = 1000;

	new iDispenser = CreateEntityByName("obj_dispenser");

	DispatchSpawn(iDispenser);

	TeleportEntity(iDispenser, fOrigin, fAngle, NULL_VECTOR);

	SetEntityModel(iDispenser,"models/buildables/dispenser_light.mdl");

	//SetEntProp(iDispenser, Prop_Send, "m_flAnimTime",                         51);
	SetEntProp(iDispenser, Prop_Send, "m_nNewSequenceParity",                 4, 4);
	SetEntProp(iDispenser, Prop_Send, "m_nResetEventsParity",                 4, 4);
	SetEntProp(iDispenser, Prop_Send, "m_iMaxHealth",                         iHealth, 4);
	SetEntProp(iDispenser, Prop_Send, "m_iHealth",                             iHealth, 4);
	SetEntProp(iDispenser, Prop_Send, "m_iAmmoMetal",                         iMetal, 4);
	SetEntProp(iDispenser, Prop_Send, "m_bBuilding",                         0, 2);
	SetEntProp(iDispenser, Prop_Send, "m_bPlacing",                         0, 2);
	SetEntProp(iDispenser, Prop_Send, "m_bDisabled",                         iDisabled, 2);
	SetEntProp(iDispenser, Prop_Send, "m_iObjectType",                         0, 1);
	SetEntProp(iDispenser, Prop_Send, "m_bHasSapper",                         0, 2);
	SetEntProp(iDispenser, Prop_Send, "m_nSkin",                             (iTeam-2), 1);
	SetEntProp(iDispenser, Prop_Send, "m_bServerOverridePlacement",         1, 1);

	SetEntPropEnt(iDispenser, Prop_Send, "m_nSequence",                     0);
	SetEntPropEnt(iDispenser, Prop_Send, "m_hBuilder",                      iBuilder);

	SetEntPropFloat(iDispenser, Prop_Send, "m_flCycle",                     0.0);
	SetEntPropFloat(iDispenser, Prop_Send, "m_flPlaybackRate",                 1.0);
	SetEntPropFloat(iDispenser, Prop_Send, "m_flPercentageConstructed",     1.0);
	SetEntPropFloat(iDispenser, Prop_Send, "m_flModelWidthScale",             1.0);

	SetEntPropVector(iDispenser, Prop_Send, "m_vecOrigin",                     fOrigin);
	SetEntPropVector(iDispenser, Prop_Send, "m_angRotation",                 fAngle);
	SetEntPropVector(iDispenser, Prop_Send, "m_vecBuildMaxs",                fBuildMaxs);

	SetVariantInt(iTeam);
	AcceptEntityInput(iDispenser, "TeamNum", -1, -1, 0);

	SetVariantInt(iTeam);
	AcceptEntityInput(iDispenser, "SetTeam", -1, -1, 0);

	new Handle:event = CreateEvent("player_builtobject");
	if (event != INVALID_HANDLE)
	{
		SetEventInt(event, "userid", GetClientUserId(iBuilder));
		SetEventInt(event, "object", 0);
		FireEvent(event);
	}
	return iDispenser;
}
*/

//public OnAbilityCommand(client,ability,bool:pressed)
//{
	//if(War3_GetRace(client)==thisRaceID && ability==0 && pressed && IsPlayerAlive(client))
	//{
		//new skill_level=War3_GetSkillLevel(client,thisRaceID,SKILL_UNDERWATER_WEAPON);
		//if(skill_level>0&&!Silenced(client))
		//if(!Silenced(client))
		//{
			//War3_ChatMessage(client,"does nothing");
			//new fCurFlags	= GetEntityFlags(client);
			//fCurFlags &= ~FL_INWATER;
			//SetEntityFlags(client, fCurFlags);

			//DP("Set flags");
			//new weapon =  GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");

			//if (IsValidEntity(weapon)) {
				//SetEntProp(weapon, Prop_Data, "m_bFiresUnderwater", true);
				//DP("set fire underwater");
			//}
		//}
	//}
//}

//leap
new Float:leapPower[5]={0.0,1400.0,1600.0,1800.0,2000.0};
new String:leapsnd[256]; //="war3source/chronos/timeleap.mp3";

public OnAddSound(sound_priority)
{
	if(sound_priority==PRIORITY_MEDIUM)
	{
		strcopy(leapsnd,sizeof(leapsnd),"war3source/chronos/timeleap.mp3");

		War3_AddSound(leapsnd);
	}
}
public void OnAbilityCommand(int client, int ability, bool pressed, bool bypass)
{
	if(RaceDisabled)
	{
		//PrintToChatAll("Frogger race disabled... exiting...");
		return;
	}

	if(War3_GetRace(client)==thisRaceID && ability==0 && pressed && IsPlayerAlive(client))
	{
		new skill_level=War3_GetSkillLevel(client,thisRaceID,SKILL_BUGZAP_WARD);
		if(skill_level>0&&!Silenced(client))
		{
			if(War3_GetWardCount(client)<MaximumWards[skill_level])
			{
					new Float:location[3];
					GetClientAbsOrigin(client, location);
					if(War3_CreateWardMod(client, location, 60, 10.0, 0.5, "zap", SKILL_BUGZAP_WARD, PushPower, WARD_TARGET_ENEMYS)>-1)
					{
						W3MsgCreatedWard(client, War3_GetWardCount(client), MaximumWards[skill_level]);
					}
			}
			else
			{
				W3MsgNoWardsLeft(client);
			}
		}
	}
	if(War3_GetRace(client)==thisRaceID && ability==2 && pressed && IsPlayerAlive(client))
	{
		//PrintToChatAll("Frogger +ability2 pushed");
		new skill_level=War3_GetSkillLevel(client,thisRaceID,SKILL_JUMP);
		if(skill_level>0&&!Silenced(client)&&SkillAvailable(client,thisRaceID,SKILL_JUMP,true))
		{
			//PrintToChatAll("Frogger skill abilable");
			new Float:velocity[3]={0.0,0.0,0.0};
			velocity[0]= GetEntDataFloat(client,m_vecVelocity_0);
			velocity[1]= GetEntDataFloat(client,m_vecVelocity_1);
			new Float:len=GetVectorLength(velocity);
			if(len>3.0)
			{
				//PrintToChatAll("pre  vec %f %f %f",velocity[0],velocity[1],velocity[2]);
				ScaleVector(velocity,leapPower[skill_level]/len);

				//PrintToChatAll("post vec %f %f %f",velocity[0],velocity[1],velocity[2]);
				SetEntDataVector(client,m_vecBaseVelocity,velocity,true);
				War3_EmitSoundToAll(leapsnd,client);
				War3_EmitSoundToAll(leapsnd,client);
				War3_CooldownMGR(client,10.0,thisRaceID,SKILL_JUMP,_,_);
			}
		}
	}
}



// DOUBLE JUMP
//public convar_ChangeBoost(Handle:convar, const String:oldVal[], const String:newVal[]) {
	//g_flBoost = StringToFloat(newVal);
//}

public convar_ChangeEnable(Handle:convar, const String:oldVal[], const String:newVal[]) {
	if (StringToInt(newVal) >= 1) {
		g_bDoubleJump = true;
	} else {
		g_bDoubleJump = false;
	}
}

public convar_ChangeMax(Handle:convar, const String:oldVal[], const String:newVal[]) {
	g_iJumpMax = StringToInt(newVal);
}

public OnGameFrame() {
	if(RaceDisabled)
		return;

	if (g_bDoubleJump) {							// double jump active
		for (new i = 1; i <= MaxClients; i++) {		// cycle through players
			if (
				IsClientInGame(i) &&				// is in the game
				IsPlayerAlive(i) &&					// is alive
				War3_GetRace(i)==thisRaceID
			) {
				DoubleJump(i);						// Check for double jumping
				//Entity_SetFlags(i, FL_ONGROUND);
			}
		}
	}
}


stock DoubleJump(const any:client) {
	new
		fCurFlags	= GetEntityFlags(client),		// current flags
		fCurButtons	= GetClientButtons(client);		// current buttons

	if (g_fLastFlags[client] & FL_ONGROUND) {		// was grounded last frame
		if (
			!(fCurFlags & FL_ONGROUND) &&			// becomes airbirne this frame
			!(g_fLastButtons[client] & IN_JUMP) &&	// was not jumping last frame
			fCurButtons & IN_JUMP					// started jumping this frame
		) {
			OriginalJump(client);					// process jump from the ground
		}
	} else if (										// was airborne last frame
		fCurFlags & FL_ONGROUND						// becomes grounded this frame
	) {
		Landed(client);								// process landing on the ground
	} else if (										// remains airborne this frame
		!(g_fLastButtons[client] & IN_JUMP) &&		// was not jumping last frame
		fCurButtons & IN_JUMP						// started jumping this frame
	) {
		ReJump(client);								// process attempt to double-jump
	}



	// force jump out of water
	if (g_fLastFlags[client] & FL_INWATER) {		// was grounded last frame
		if (
			!(g_fLastButtons[client] & IN_JUMP) &&	// was not jumping last frame
			fCurButtons & IN_JUMP					// started jumping this frame
		) {
			g_iJumps[client]++;
			ReJump(client,true);					// process jump from the ground
		}
	}

	g_fLastFlags[client]	= fCurFlags;				// update flag state for next frame
	g_fLastButtons[client]	= fCurButtons;			// update button state for next frame
}

stock OriginalJump(const any:client) {
	g_iJumps[client]++;	// increment jump count
}

stock Landed(const any:client) {
	g_iJumps[client] = 0;	// reset jumps count
}

stock ReJump(const any:client,bool:extraforce=false) {
	new skill_level=War3_GetSkillLevel(client,thisRaceID,SKILL_JUMP);
	if(skill_level>0)
	{
		// has jumped at least once but hasn't exceeded max re-jumps
		if ( 1 <= g_iJumps[client] <= g_iJumpMax)
		{
			g_iJumps[client]++;											// increment jump count

			//if(GetClientHealth(client)>JumpDamage[skill_level])
			//{
				//War3_DecreaseHP(client,JumpDamage[skill_level]);
			//}
			//else
			//{
				//War3_DealDamage(client,JumpDamage[skill_level],client,DMG_GENERIC,"Frog Jump", W3DMGORIGIN_UNDEFINED , W3DMGTYPE_TRUEDMG , false , false, true);
			//}

			decl Float:vVel[3];
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);	// get current speeds

			if(extraforce)
			{
				vVel[2] = FloatMul(JumpDistance[skill_level],2.0);
			}
			else
			{
				vVel[2] = JumpDistance[skill_level];
			}

			W3TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);		// boost player
		}
	}
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if(RaceDisabled)
		return Plugin_Continue;

	if(W3Paused()) return Plugin_Continue;

	if (War3_GetRace(client)==thisRaceID && ((buttons & IN_FORWARD)||(buttons & IN_BACK)))
	{
		new skill_level=War3_GetSkillLevel(client,thisRaceID,SKILL_SWIMFAST);
		if(skill_level>0)
		{
			//new fCurFlags	= GetEntityFlags(client);
			if(GetEntityFlags(client) & FL_INWATER)
			{
				War3_SetBuff(client,fMaxSpeed,thisRaceID,SwimSpeed[skill_level]);
			}
			else
			{
				War3_SetBuff(client,fMaxSpeed,thisRaceID,1.0);
			}
		}
	}
	else
	{
		War3_SetBuff(client,fMaxSpeed,thisRaceID,1.0);
	}

	if (!IsClientInGame(client)) return Plugin_Continue;
	if (!IsPlayerAlive(client)) return Plugin_Continue;
	if(TF2_GetPlayerClass(client)!=TFClass_Engineer) return Plugin_Continue;

	if(War3_GetRace(client)!=thisRaceID) return Plugin_Continue;

	char wep[64];
	int offs = FindSendPropInfo("CObjectSentrygun", "m_hEnemy");
	int wepent = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if (wepent < MaxClients || !IsValidEntity(wepent)) return Plugin_Continue;
	if (GetEntProp(client, Prop_Send, "m_bFeignDeathReady")) return Plugin_Continue;
	if (TF2_IsPlayerInCondition(client, TFCond_Cloaked) || TF2_IsPlayerInCondition(client, TFCond_Bonked)) return Plugin_Continue;
	if (TF2_IsPlayerInCondition(client, TFCond_Dazed) && GetEntProp(client, Prop_Send, "m_iStunFlags") & (TF_STUNFLAG_BONKSTUCK|TF_STUNFLAG_THIRDPERSON)) return Plugin_Continue;
	float time = GetGameTime();
	if (time < GetEntPropFloat(client, Prop_Send, "m_flNextAttack")) return Plugin_Continue;
	if (time < GetEntPropFloat(client, Prop_Send, "m_flStealthNoAttackExpire")) return Plugin_Continue;
	bool nextprim = time >= GetEntPropFloat(wepent, Prop_Send, "m_flNextPrimaryAttack");
	bool nextsec = time >= GetEntPropFloat(wepent, Prop_Send, "m_flNextSecondaryAttack");
	if (!nextprim && !nextsec) return Plugin_Continue;
	GetClientWeapon(client, wep, sizeof(wep));
	if (!StrEqual(wep, "tf_weapon_laser_pointer", false)) return Plugin_Continue;
	int i = -1;
	int level;
	while ((i = FindEntityByClassname(i, "obj_sentrygun")) != -1)
	{
		if (GetEntPropEnt(i, Prop_Send, "m_hBuilder") != client) continue;
		if (GetEntProp(i, Prop_Send, "m_bDisabled")) continue;
		level = GetEntProp(i, Prop_Send, "m_iUpgradeLevel");
		if (nextsec && level == 3 && buttons & IN_ATTACK2) SetEntData(i, offs+5, 1, 1, true);
		if (nextprim && buttons & IN_ATTACK) SetEntData(i, offs+4, 1, 1, true);
	}
	return Plugin_Continue;
}

//SetEntPropFloat(entity, Prop_Send, "m_flRechargeTime", GetGameTime() + time);
/*
public void OnUltimateCommand(int client, int race, bool pressed, bool bypass)
{
	if(race==thisRaceID && pressed && ValidPlayer(client,true,true) && !Silenced(client))
	{
		new ult_level=War3_GetSkillLevel(client,race,ULTIMATE);
		if(War3_SkillNotInCooldown(client,thisRaceID,ULTIMATE,true))
		{
			//if(TF2_IsPlayerInCondition(client,TFCond_Disguising)||TF2_IsPlayerInCondition(client,TFCond_Disguised))
			if(ult_level>1)
			{
				new iEnt=GetClientAimTarget(client, false);
				if(iEnt>-1)
				{
					new String:EntityLongName[64];
					GetEntityClassname(iEnt, EntityLongName, 64);

					if(StrEqual("obj_teleporter",EntityLongName,false)==true)
					{
						//check for entrance (0 = entrance, 1 = exit)
						if((GetEntProp(iEnt, Prop_Send, "m_iObjectMode") == 0))
						{
							if(IsValidEntity(iEnt))
							{
								SetEntPropFloat(iEnt, Prop_Send, "m_flRechargeTime", GetGameTime() + 0.01);
								War3_ChatMessage(client,"{lightgreen}Teleporter Recharge Set!");
								War3_CooldownMGR(client,1.0,thisRaceID,ULTIMATE,true,true);
							}
						}
						else
						{
							War3_ChatMessage(client,"{lightgreen}Can only set entrance!");
						}
					}
				}
			}
		}
	}
}*/

public Action:event_player_teleported(Handle:event, const String:name[], bool:dontBroadcast) {
	if(RaceDisabled)
		return Plugin_Continue;

	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(War3_GetRace(client)==thisRaceID)
	{
		//DP("race");
		if(War3_GetSkillLevel(client,thisRaceID,ULTIMATE)>1)
		{
			//DP("ultimate level");
			new owner, entity;
			owner = GetClientOfUserId(GetEventInt(event, "builderid"));
			entity = TeleporterList[owner][tele_entity];
			if(entity>MaxClients && IsValidEntity(entity)) {
				SetEntPropFloat(entity, Prop_Send, "m_flRechargeTime", GetGameTime()+0.01);
			}
		}
	}
	return Plugin_Continue;
}

/* FROM tf2.inc line 167
enum TFObjectType
{
	TFObject_CartDispenser = 0,
	TFObject_Dispenser = 0,
	TFObject_Teleporter = 1,
	TFObject_Sentry = 2,
	TFObject_Sapper = 3
};
*/

public Action:event_player_builtobject(Handle:event, const String:name[], bool:dontBroadcast)
{
	new index = GetEventInt(event, "index");
	new TFObjectType:BuildingType = TFObjectType:GetEventInt(event, "object");

	new owner = GetClientOfUserId(GetEventInt(event, "userid"));
	if(War3_GetRace(owner)==thisRaceID)
	{
		//decl String:classname[32];
		//GetEdictClassname(index, classname, sizeof(classname));
		//if((GetEntProp(index, Prop_Send, "m_bMiniBuilding") != 1 ))
		//{
			int skill_level=War3_GetSkillLevel(owner,thisRaceID,ULTIMATE);

			if(BuildingType == TFObject_Sentry)
			{
				int Frog_level=War3_GetSkillLevel(owner,thisRaceID,SKILL_FROGMAGIC);
				if(Frog_level>0)
				{
					if(War3_SkillNotInCooldown(owner,thisRaceID,SKILL_FROGMAGIC,true))
					{
						//if(GetEntProp(index, Prop_Send, "m_iHighestUpgradeLevel")==3 && GetEntProp(index, Prop_Send, "m_bMiniBuilding") == 1 )
						//{
						//SetEntPropFloat(index, Prop_Send, "m_flModelScale",0.50);
						SetEntProp(index, Prop_Send, "m_bBuilding",1);
						SetEntProp(index, Prop_Send, "m_bMiniBuilding",1);
						SetEntProp(index, Prop_Send, "m_iHealth", 50);
						SetEntProp(index, Prop_Send, "m_iMaxHealth", 50);

						static Float:g_fSentryMaxs[] = {9.0, 9.0, 29.7};
						SetEntPropVector(index, Prop_Send, "m_vecMaxs", g_fSentryMaxs);

						new OldMetal = GetEntData(owner, FindDataMapOffs(owner, "m_iAmmo") + (3 * 4), 4);
						SetEntData(owner, FindDataMapOffs(owner, "m_iAmmo") + (3 * 4), OldMetal+30, 4, true);
						new Metal = GetEntData(owner, FindDataMapOffs(owner, "m_iAmmo") + (3 * 4), 4);
						if(Metal>200)
							SetEntData(owner, FindDataMapOffs(owner, "m_iAmmo") + (3 * 4), 200, 4, true);
						//}
						//if((GetEntProp(index, Prop_Send, "m_bBuilding") == 1 ))
						SetEntProp(index, Prop_Send, "m_iHighestUpgradeLevel", 1);

						CreateTimer(1.0, SkinFix, index); //sentries only fix

						new Float:position[3];
						GetEntPropVector(index, Prop_Send, "m_vecOrigin", position);

						new Float:flAngles[3];
						GetClientAbsAngles(owner, flAngles);

						//TeleportEntity(owner, NULL_VECTOR, NULL_VECTOR, NULL_VECTOR);

						//GetEntPropVector(index, Prop_Data, "m_angRotation", flAngles);
						//position[1] += 30.0;

						BuildSentry(owner,position,flAngles,1);
						position[1] += 20.0;
						BuildSentry(owner,position,flAngles,1);

						position[1] -= 10.0;
						position[2] += 50.0;

						//SetEntProp(index, Prop_Data, "m_CollisionGroup", 0); //players can walk through sentry so they dont get stuck
						SetEntData(index, g_offsCollisionGroup, 5, 4, true);
						TeleportEntity(index, position, NULL_VECTOR, NULL_VECTOR);
					}
					else
					{
						if(index>MaxClients && IsValidEntity(index))
						{
							AcceptEntityInput(index,"Kill");
							War3_ChatMessage(owner,"{lightgreen}You can not build a sentry while your Frog Magic is on cooldown!");
						}
					}
				}
			}
			else if(BuildingType == TFObject_Teleporter && skill_level>=3)
			{
				//if(GetEntProp(index, Prop_Send, "m_iHighestUpgradeLevel")==3 && GetEntProp(index, Prop_Send, "m_bMiniBuilding") == 1 )
				//{
				SetEntPropFloat(index, Prop_Send, "m_flModelScale",0.50);
				SetEntProp(index, Prop_Send, "m_bMiniBuilding",0);
				SetEntProp(index, Prop_Send, "m_bBuilding",1);
				SetEntProp(index, Prop_Send, "m_iHealth", 70);
				SetEntProp(index, Prop_Send, "m_iMaxHealth", 70);

				static Float:g_fSentryMaxs[] = {9.0, 9.0, 29.7};
				SetEntPropVector(index, Prop_Send, "m_vecMaxs", g_fSentryMaxs);

				new OldMetal = GetEntData(owner, FindDataMapOffs(owner, "m_iAmmo") + (3 * 4), 4);
				SetEntData(owner, FindDataMapOffs(owner, "m_iAmmo") + (3 * 4), OldMetal+30, 4, true);
				new Metal = GetEntData(owner, FindDataMapOffs(owner, "m_iAmmo") + (3 * 4), 4);
				if(Metal>200)
					SetEntData(owner, FindDataMapOffs(owner, "m_iAmmo") + (3 * 4), 200, 4, true);
				//}
				//if((GetEntProp(index, Prop_Send, "m_bBuilding") == 1 ))
				SetEntProp(index, Prop_Send, "m_iHighestUpgradeLevel", 3);

				if(IsValidEntity(index)) {
					//check for entrance (0 = entrance, 1 = exit)
					if(GetEntProp(index, Prop_Send, "m_iObjectMode") == 0) {
						TeleporterList[owner][tele_entity] = index;
					}
				}

				//CreateTimer(1.0, SkinFix, index); //sentries only fix
			}
			else if(BuildingType == TFObject_Dispenser && skill_level>=4)
			{
				// destory left over dispensers
				/*
				int iEnt;
				bool iCleanDestroy = true;
				while ((iEnt = FindEntityByClassname(iEnt, "obj_dispenser")) != INVALID_ENT_REFERENCE)
				{
					if(iEnt!=index)
					{
						if (GetEntPropEnt(iEnt, Prop_Send, "m_hBuilder") == owner)
						{
							if (iCleanDestroy)
								AcceptEntityInput(iEnt, "Kill");
							else
							{
								SetVariantInt(1000);
								AcceptEntityInput(iEnt, "RemoveHealth");
							}
						}
					}
				}*/

				//if(GetEntProp(index, Prop_Send, "m_iHighestUpgradeLevel")==3 && GetEntProp(index, Prop_Send, "m_bMiniBuilding") == 1 )
				//{
				SetEntPropFloat(index, Prop_Send, "m_flModelScale",0.6);
				SetEntProp(index, Prop_Send, "m_bMiniBuilding",0);
				SetEntProp(index, Prop_Send, "m_bBuilding",1);
				SetEntProp(index, Prop_Send, "m_iHealth", 300);
				SetEntProp(index, Prop_Send, "m_iMaxHealth", 300);

				static Float:g_fSentryMaxs[] = {9.0, 9.0, 29.7};
				SetEntPropVector(index, Prop_Send, "m_vecMaxs", g_fSentryMaxs);

				new OldMetal = GetEntData(owner, FindDataMapOffs(owner, "m_iAmmo") + (3 * 4), 4);
				SetEntData(owner, FindDataMapOffs(owner, "m_iAmmo") + (3 * 4), OldMetal+30, 4, true);
				new Metal = GetEntData(owner, FindDataMapOffs(owner, "m_iAmmo") + (3 * 4), 4);
				if(Metal>200)
					SetEntData(owner, FindDataMapOffs(owner, "m_iAmmo") + (3 * 4), 200, 4, true);
				//}
				if((GetEntProp(index, Prop_Send, "m_bBuilding") == 1 ))
					SetEntProp(index, Prop_Send, "m_iHighestUpgradeLevel", 3);

				new Float:position[3];
				GetEntPropVector(index, Prop_Send, "m_vecOrigin", position);

				new Float:flAngles[3];
				//GetEntPropVector(index, Prop_Send, "m_vecAngles", flAngles);
				GetEntPropVector(index, Prop_Data, "m_angRotation", flAngles);
				//GetClientAbsAngles(client, flAngles);
				position[2] += 30.0;

				BuildDispenser(owner,position,flAngles,3);

				//CreateTimer(1.0, SkinFix, index); //sentries only fix
			}
		//}
	}

	//check for teleport
	//if ( BuildingType != TFObject_Teleporter) return Plugin_Continue;
	/*
	if ( BuildingType != TFObject_Sentry) return Plugin_Continue;

	if (ValidPlayer(owner))
	{
		if(War3_GetRace(owner)==thisRaceID)
		{
			if(BuildingType == TFObject_Sentry)
			{
				AcceptEntityInput(index, "Kill");
				War3_ChatMessage(owner,"{lightgreen}Wow! Did that just explode in my hands?");
				//new Float:angl[3], Float:vec[3];
				//angl[0] = 0.0;
				//angl[1] = 0.0;
				//angl[2] = 0.0;
				//GetClientAbsOrigin(owner, vec);
				//vec[1]+=40;

				//if(!IsValidEntity(HasExtraDispenser[owner]))
				//{
					//HasExtraDispenser[owner]=BuildDispenser(owner, vec, angl, 0);
				//}

				//BuildSentry(owner, angl, 1);
			}
		}
	}*/

		/*
		if(War3_GetRace(owner)==thisRaceID && skill_level>2)
		{
			SetEntPropFloat(index, Prop_Send, "m_flModelScale",0.10);
			SetEntProp(index, Prop_Send, "m_iHealth", 100);
			SetEntProp(index, Prop_Send, "m_iMaxHealth", 100);
			SetEntProp(index, Prop_Send, "m_bMiniBuilding",0);
			SetEntProp(index, Prop_Send, "m_bBuilding",1);
			if((GetEntProp(index, Prop_Send, "m_bBuilding") == 1 ))
				SetEntProp(index, Prop_Send, "m_iHighestUpgradeLevel", 3);
		}
	}
	*/
	return Plugin_Continue;
}

public Action:event_player_carryobject(Handle:event, const String:name[], bool:dontBroadcast)
{
	new index = GetEventInt(event, "index");
	new TFObjectType:BuildingType = TFObjectType:GetEventInt(event, "object");

	new owner = GetClientOfUserId(GetEventInt(event, "userid"));
	if(War3_GetRace(owner)==thisRaceID)
	{
		if(BuildingType == TFObject_Dispenser)
		{
			// destory left over dispensers
			int iEnt;
			bool iCleanDestroy = true;
			while ((iEnt = FindEntityByClassname(iEnt, "obj_dispenser")) != INVALID_ENT_REFERENCE)
			{
				if(iEnt!=index)
				{
					if (GetEntPropEnt(iEnt, Prop_Send, "m_hBuilder") == owner)
					{
						if (iCleanDestroy)
							AcceptEntityInput(iEnt, "Kill");
						else
						{
							SetVariantInt(1000);
							AcceptEntityInput(iEnt, "RemoveHealth");
						}
					}
				}
			}
		}
		else if(BuildingType == TFObject_Sentry)
		{
			// destory left over sentries
			int iEnt;
			bool iCleanDestroy = true;
			while ((iEnt = FindEntityByClassname(iEnt, "obj_sentrygun")) != INVALID_ENT_REFERENCE)
			{
				if(iEnt!=index)
				{
					if (GetEntPropEnt(iEnt, Prop_Send, "m_hBuilder") == owner)
					{
						if (iCleanDestroy)
							AcceptEntityInput(iEnt, "Kill");
						else
						{
							SetVariantInt(1000);
							AcceptEntityInput(iEnt, "RemoveHealth");
						}
					}
				}
			}
		}
	}
}

public bool:TraceFilterIgnorePlayers(entity, contentsMask, any:client)
{
	if(entity >= 1 && entity <= MaxClients)
	{
		return false;
	}

	return true;
}

IsValidClient(client, bool:replaycheck = true)
{
	if (client <= 0 || client > MaxClients) return false;
	if (!IsClientInGame(client)) return false;
	if (GetEntProp(client, Prop_Send, "m_bIsCoaching")) return false;
	if (replaycheck)
	{
		if (IsClientSourceTV(client) || IsClientReplay(client)) return false;
	}
	return true;
}

public Action:SkinFix(Handle:timer, any:sentry)
{
	decl String:classname[32];

	if(!IsValidEntity(sentry)) return Plugin_Continue;

	if(GetEntityClassname(sentry, classname, sizeof(classname)) && StrEqual(classname, "obj_sentrygun", false))
	{
		if((GetEntProp(sentry, Prop_Send, "m_bPlacing") == 0))
		{
			new client = GetEntDataEnt2(sentry, FindSendPropOffs("CObjectSentrygun","m_hBuilder"));
			if(!IsValidClient(client)) return Plugin_Continue;

			//SetEntProp(sentry, Prop_Send, "m_nSkin", GetClientTeam(client)-2);
			SetEntProp(sentry, Prop_Send, "m_nSkin", GetClientTeam(client));
			SetEntProp(sentry, Prop_Send, "m_nBody", 5, 1);
		}
	}

	return Plugin_Continue;
}

// This is the working one below if ever needed again:
public Action OnW3TakeDmgAllPre(int victim, int attacker, float damage)
{
	if(RaceDisabled)
		return;

	if(War3_GetRace(victim)==thisRaceID)
	{
		if(War3_GetSkillLevel(victim,thisRaceID,SKILL_JUMP)>0 && (W3GetDamageType() & DMG_FALL))
		{
			War3_DamageModPercent(0.50);
			return;
		}
		//if(!(GetEntityFlags(victim) & FL_ONGROUND))
		//{
			//War3_DamageModPercent(2.0);
			//return;
		//}
	}
}

public OnEntityDestroyed(entity) // removed cause player doesn't build sentrys now
{
	if(RaceDisabled)
		return;

	if (entity <= MaxClients)
	{
		return;
	}
	else if (IsValidEntity(entity))
	{
		decl String:classname[32];

		if(GetEntityClassname(entity, classname, sizeof(classname)))
		{
			/*
			if(StrEqual(classname, "obj_sentrygun", false))
			{
				new client = GetEntDataEnt2(entity, FindSendPropOffs("CObjectSentrygun","m_hBuilder"));
				if(ValidPlayer(client,true) && War3_GetRace(client)==thisRaceID)
				{
					War3_ChatMessage(client,"Your link to the sentry kills you when it dies!");
					ForcePlayerSuicide(client);
				}
			}*/
			if(StrEqual(classname, "obj_dispenser", false))
			{
				new client = GetEntDataEnt2(entity, FindSendPropOffs("CObjectDispenser","m_hBuilder"));
				//if(ValidPlayer(client) && HasExtraDispenser[client]==entity && War3_GetRace(client)==thisRaceID)
				//{
					//HasExtraDispenser[client]=-1;
				//}
				if(ValidPlayer(client) && War3_GetRace(client)==thisRaceID)
				{
					int iEnt;
					bool iCleanDestroy = true;
					while ((iEnt = FindEntityByClassname(iEnt, "obj_dispenser")) != INVALID_ENT_REFERENCE)
					{
						if (GetEntPropEnt(iEnt, Prop_Send, "m_hBuilder") == client)
						{
							if (iCleanDestroy)
								AcceptEntityInput(iEnt, "Kill");
							else
							{
								SetVariantInt(1000);
								AcceptEntityInput(iEnt, "RemoveHealth");
							}
						}
					}
				}
			}
			else if(StrEqual(classname, "obj_sentrygun", false))
			{
				new client = GetEntDataEnt2(entity, FindSendPropOffs("CObjectSentrygun","m_hBuilder"));
				//if(ValidPlayer(client) && HasExtraDispenser[client]==entity && War3_GetRace(client)==thisRaceID)
				//{
					//HasExtraDispenser[client]=-1;
				//}
				if(ValidPlayer(client) && War3_GetRace(client)==thisRaceID)
				{
					int iEnt;
					bool iCleanDestroy = true;
					while ((iEnt = FindEntityByClassname(iEnt, "obj_sentrygun")) != INVALID_ENT_REFERENCE)
					{
						if (GetEntPropEnt(iEnt, Prop_Send, "m_hBuilder") == client)
						{
							if (iCleanDestroy)
								AcceptEntityInput(iEnt, "Kill");
							else
							{
								SetVariantInt(1000);
								AcceptEntityInput(iEnt, "RemoveHealth");
							}
						}
					}

					War3_CooldownMGR(client,20.0,thisRaceID,SKILL_FROGMAGIC,_,_);
					//SKILL_FROGMAGIC
				}
			}
		}
	}
}


/*
public Action:OnTakeDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(RaceDisabled)
		return Plugin_Continue;

	if(War3_GetRace(client)==thisRaceID && War3_GetSkillLevel(client,thisRaceID,SKILL_JUMP)>0)
	{
		if(damagetype & DMG_FALL)
		{
			return Plugin_Handled;
		}

	}

	return Plugin_Continue;
}*/

public DestoryEngiBuildings(client)
{
	if(ValidPlayer(client))
	{
		bool iCleanDestroy = true;
		int iEnt = -1;

		while ((iEnt = FindEntityByClassname(iEnt, "obj_sentrygun")) != INVALID_ENT_REFERENCE)
		{
			if (GetEntPropEnt(iEnt, Prop_Send, "m_hBuilder") == client)
			{
				if (iCleanDestroy)
					AcceptEntityInput(iEnt, "Kill");
				else
				{
					SetVariantInt(1000);
					AcceptEntityInput(iEnt, "RemoveHealth");
				}
			}
		}
		while ((iEnt = FindEntityByClassname(iEnt, "obj_dispenser")) != INVALID_ENT_REFERENCE)
		{
			if (GetEntPropEnt(iEnt, Prop_Send, "m_hBuilder") == client)
			{
				if (iCleanDestroy)
					AcceptEntityInput(iEnt, "Kill");
				else
				{
					SetVariantInt(1000);
					AcceptEntityInput(iEnt, "RemoveHealth");
				}
			}
		}
		while ((iEnt = FindEntityByClassname(iEnt, "obj_teleporter")) != INVALID_ENT_REFERENCE)
		{
			if (GetEntPropEnt(iEnt, Prop_Send, "m_hBuilder") == client && TF2_GetObjectMode(iEnt) == TFObjectMode_Entrance)
			{
				if (iCleanDestroy)
					AcceptEntityInput(iEnt, "Kill");
				else
				{
					SetVariantInt(1000);
					AcceptEntityInput(iEnt, "RemoveHealth");
				}
			}
		}
		while ((iEnt = FindEntityByClassname(iEnt, "obj_teleporter")) != INVALID_ENT_REFERENCE)
		{
			if (GetEntPropEnt(iEnt, Prop_Send, "m_hBuilder") == client && TF2_GetObjectMode(iEnt) == TFObjectMode_Exit)
			{
				if (iCleanDestroy)
					AcceptEntityInput(iEnt, "Kill");
				else
				{
					SetVariantInt(1000);
					AcceptEntityInput(iEnt, "RemoveHealth");
				}
			}
		}
	}
}

public BuildDispenser(iBuilder, Float:flOrigin[3], Float:flAngles[3], iLevel)
{
	new String:strModel[100];
	flAngles[0] = 0.0;
	//decl String:name[60];
	//GetClientName(iBuilder,name,sizeof(name));
	//ShowActivity2(iBuilder,"[SM]","Spawned a dispenser(lvl %d)", iLevel);
	new iTeam = GetClientTeam(iBuilder);
	new iHealth;
	new iAmmo = 400;
	if(iLevel == 2)
	{
		strcopy(strModel, sizeof(strModel), "models/buildables/dispenser_lvl2.mdl");
		iHealth = 300; //180
	}
	else if(iLevel == 3)
	{
		strcopy(strModel, sizeof(strModel), "models/buildables/dispenser_lvl3.mdl");
		iHealth = 300; //216
	}
	else
	{
		strcopy(strModel, sizeof(strModel), "models/buildables/dispenser.mdl");
		iHealth = 300; //150
	}

	new iDispenser = CreateEntityByName("obj_dispenser");
	if(iDispenser > MaxClients && IsValidEntity(iDispenser))
	{
		DispatchSpawn(iDispenser);

		TeleportEntity(iDispenser, flOrigin, flAngles, NULL_VECTOR);

		SetEntityModel(iDispenser, strModel);

		SetVariantInt(iTeam);
		AcceptEntityInput(iDispenser, "TeamNum");
		SetVariantInt(iTeam);
		AcceptEntityInput(iDispenser, "SetTeam");

		ActivateEntity(iDispenser);

		SetEntPropEnt(iDispenser, Prop_Send, "m_hBuilder", iBuilder);
		SetEntProp(iDispenser, Prop_Send, "m_iAmmoMetal", iAmmo);
		SetEntProp(iDispenser, Prop_Send, "m_iHealth", iHealth);
		SetEntProp(iDispenser, Prop_Send, "m_iMaxHealth", iHealth);
		SetEntProp(iDispenser, Prop_Send, "m_iObjectType", _:TFObject_Dispenser);
		SetEntProp(iDispenser, Prop_Send, "m_iTeamNum", iTeam);
		SetEntProp(iDispenser, Prop_Send, "m_nSkin", iTeam-2);
		SetEntProp(iDispenser, Prop_Send, "m_iHighestUpgradeLevel", iLevel);
		SetEntPropFloat(iDispenser, Prop_Send, "m_flPercentageConstructed", 1.0);
		//SetEntPropEnt(iDispenser, Prop_Send, "m_hBuilder", iBuilder);
		SetEntPropFloat(iDispenser, Prop_Send, "m_flModelScale",0.6);
	}
	return;
}
public Action:BuildSentry(iBuilder,Float:fOrigin[3], Float:fAngle[3],iLevel)
{
	fAngle[0] = 0.0;
	fAngle[2] = 0.0;
	decl String:name[60];
	GetClientName(iBuilder,name,sizeof(name));
	//ShowActivity2(iBuilder,"[SM]","Spawned a sentry(lvl %d)", iLevel);
	decl String:sModel[64];
	new iTeam = GetClientTeam(iBuilder);

	new iShells, iHealth, iRockets;
	if(iLevel == 1)
	{
		sModel = "models/buildables/sentry1.mdl";
		iShells = 100;
		iHealth = 300; //150
	}
	else if(iLevel == 2)
	{
        sModel = "models/buildables/sentry2.mdl";
        iShells = 120;
        iHealth = 300; //180
	}
	else if(iLevel == 3)
	{
		sModel = "models/buildables/sentry3.mdl";
		iShells = 144;
		iHealth = 300; //216
		iRockets = 20;
	}
	new iSentry = CreateEntityByName("obj_sentrygun");

	DispatchSpawn(iSentry);
	ActivateEntity(iSentry);

	//SetEntPropVector(iSentry, Prop_Send, "m_vecOrigin", fOrigin);
	//SetEntPropVector(iSentry, Prop_Send, "m_angRotation", fAngle);

	TeleportEntity(iSentry, fOrigin, fAngle, NULL_VECTOR);

	//SetEntityRenderMode(iSentry, RENDER_TRANSCOLOR);
	//SetEntityRenderColor(iSentry, 255, 255, 255, 0);

	SetEntData(iSentry, g_offsCollisionGroup, 5, 4, true);
	//SetEntProp(iSentry, Prop_Data, "m_CollisionGroup", 0); //players can walk through sentry so they dont get stuck

	SetEntityModel(iSentry,sModel);

	SetEntData(iSentry, FindSendPropOffs("CObjectSentrygun","m_flAnimTime"), 51, 4 , true);
	//SetEntProp(iSentry, Prop_Send, "m_bBuilding",1);

	SetEntProp(iSentry, Prop_Send, "m_iAmmoShells", iShells);
	SetEntProp(iSentry, Prop_Send, "m_iHealth", iHealth);
	SetEntProp(iSentry, Prop_Send, "m_iMaxHealth", iHealth);
	SetEntProp(iSentry, Prop_Send, "m_bDisabled", 0);
	//SetEntProp(iSentry, Prop_Send, "m_iObjectType", _:TFObject_Sentry);
	SetEntProp(iSentry, Prop_Send, "m_iObjectType", 2);
	SetEntProp(iSentry, Prop_Send, "m_iState", 1);

	SetEntProp(iSentry, Prop_Send, "m_iTeamNum", iTeam);
	//SetEntProp(iSentry, Prop_Send, "m_nSkin", iTeam-2);
	SetEntProp(iSentry, Prop_Send, "m_iUpgradeLevel", iLevel);
	SetEntProp(iSentry, Prop_Send, "m_iHighestUpgradeLevel", iLevel);
	SetEntProp(iSentry, Prop_Send, "m_iAmmoRockets", iRockets);

	SetEntProp(iSentry, Prop_Send, "m_bMiniBuilding",1);

	SetEntProp(iSentry, Prop_Send, "m_bPlacing", 0);
	SetEntProp(iSentry, Prop_Send, "m_nNewSequenceParity", 3+iLevel);
	SetEntProp(iSentry, Prop_Send, "m_nResetEventsParity", 3+iLevel);
	SetEntProp(iSentry, Prop_Send, "m_bServerOverridePlacement", 0);
	SetEntProp(iSentry, Prop_Send, "m_nSequence", 0);

	SetEntProp(iSentry, Prop_Data, "m_spawnflags", 4);

	SetEntPropEnt(iSentry, Prop_Send, "m_hBuilder", iBuilder);

	SetEntPropFloat(iSentry, Prop_Send, "m_flPercentageConstructed", 1.0);
	SetEntProp(iSentry, Prop_Send, "m_bPlayerControlled", 1);

	SetEntProp(iSentry, Prop_Send, "m_bHasSapper", 0);

	SetEntProp(iSentry, Prop_Send, "m_nSkin", iTeam);
	SetEntProp(iSentry, Prop_Send, "m_nBody", 5, 1);

	SetEntProp(iSentry, Prop_Data, "m_takedamage", 2);

	SetEntPropEnt(iSentry, Prop_Data, "m_hOwnerEntity", iBuilder);

	//SetVariantString("build");
	//AcceptEntityInput(iSentry, "SetAnimation", -1, -1, 0);


	//SetEntPropFloat(iSentry, Prop_Send, "m_flModelScale",0.5);
	return Plugin_Handled;
}
