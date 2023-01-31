 /**
 * File: War3Source_ShadowHunter.sp
 * Description: The Shadow Hunter race for War3Source.
 * Author(s): Anthony Iacono & Ownage | Ownz (DarkEnergy)
 *
 * [War3Source:EVO] -- Modified by El Diablo
 *
 */
#include <war3source>

#if (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
	#endinput
#endif


#define PLUGIN_VERSION "0.0.1.0 12/15/2013"

#pragma semicolon 1
//#pragma tabsize 0

#assert GGAMEMODE == MODE_WAR3SOURCE


#define RACE_ID_NUMBER 23

////TO DO:
//native that asks if the damage is by direct weapon, not lasting burn


new thisRaceID;

bool HooksLoaded = false;
public void Load_Hooks()
{
	if(HooksLoaded) return;
	HooksLoaded = true;

	W3Hook(W3Hook_OnW3TakeDmgAllPre, OnW3TakeDmgAllPre);
	W3Hook(W3Hook_OnUltimateCommand, OnUltimateCommand);
	W3Hook(W3Hook_OnAbilityCommand, OnAbilityCommand);
	W3Hook(W3Hook_OnWar3EventSpawn, OnWar3EventSpawn);
}
public void UnLoad_Hooks()
{
	if(!HooksLoaded) return;
	HooksLoaded = false;

	W3UnhookAll(W3Hook_OnW3TakeDmgAllPre);
	W3UnhookAll(W3Hook_OnUltimateCommand);
	W3UnhookAll(W3Hook_OnAbilityCommand);
	W3UnhookAll(W3Hook_OnWar3EventSpawn);
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


//new AuraID;

//new SKILL_HEALINGWAVE, SKILL_IMPROVEDHEALING, SKILL_HEX, SKILL_RECARN_WARD, ULT_VOODOO;
int SKILL_HEALINGWAVE, SKILL_IMPROVEDHEALING, SKILL_RECARN_WARD, ULT_VOODOO;


//skill 1
new Float:HealingWaveAmountArr[5]={0.0,1.0,2.0,3.0,4.0};
new Float:HealingWaveDistanceArr[5]={0.0,250.0,300.0,350.0,400.0};
//new ParticleEffect[MAXPLAYERSCUSTOM][MAXPLAYERSCUSTOM]; // ParticleEffect[Source][Destination]

//skill 2
//new Float:HexChanceArr[5]={0.00,0.25,0.50,0.75,1.00}; //buffed hex from 2.5% 5% 7.5% 10% to 25% 50% 75% 100%, bringing it in line with the Warden's Immunity ability, except for skills - Dagothur 1/13/2013

//skill 3
// Healing Ward Specific
new MaximumWards[5]={0,1,2,3,4};
new WardHeal[5]={0,2,4,6,8};


//ultimate
new Handle:ultCooldownCvar;

new Float:UltimateDuration[5]={0.0,0.66,1.0,1.33,1.66}; ///big bad voodoo duration

new bool:bVoodoo[65];

new String:ultimateSound[]="war3source/divineshield.wav";
//new String:wardDamageSound[]="war3source/thunder_clap.wav";

//new bool:particled[MAXPLAYERSCUSTOM]; //heal particle

//new AuraID;
public Plugin:myinfo =
{
	name = "Race - Shadow Paladin",
	author = "PimpinJuice & Ownz (DarkEnergy) Revised by NGU",
	description = "The Shadow Paladin race for War3Source.",
	version = "1.0.0.0",
	url = "http://Www.OwnageClan.Com www.nguclan.com"
};

public OnPluginStart()
{
	//CreateConVar("war3evo_ShadowPaladin",PLUGIN_VERSION,"War3evo Job Shadow Paladin",FCVAR_PLUGIN);
	ultCooldownCvar=CreateConVar("war3_hunter_voodoo_cooldown","20","Cooldown between Big Bad Voodoo (ultimate)");
	//CreateTimer(1.0,CalcHexHealWaves,_,TIMER_REPEAT);
	//CreateTimer(0.1,HealingWaveParticleTimer,_,TIMER_REPEAT);
	//LoadTranslations("w3s.race.hunter.phrases");
}
public OnAllPluginsLoaded()
{
	War3_RaceOnPluginStart("hunter");
}

public OnPluginEnd()
{
	if(LibraryExists("RaceClass"))
		War3_RaceOnPluginEnd("hunter");
}

public OnWar3LoadRaceOrItemOrdered2(num,reloadrace_id,String:shortname[])
{
	if(num==RACE_ID_NUMBER||(reloadrace_id>0&&StrEqual("hunter",shortname,false)))
	{
		thisRaceID=War3_CreateNewRace("Shadow Paladin","hunter",reloadrace_id,"Healing wards/wave");
		SKILL_HEALINGWAVE=War3_AddRaceSkill(thisRaceID,"Healing Wave",
		"Heal teammates around you.\n25/30/35/40 ft distance per level.\n1/2/3/4 HP/2 seconds",false,4);
		SKILL_IMPROVEDHEALING=War3_AddRaceSkill(thisRaceID,"Improved Healing Wave",
		"2nd aura of Healing Wave.\n25/30/35/40 ft distance per level.\n1/2/3/4 HP/2 seconds",false,4);
		//SKILL_HEX=War3_AddRaceSkill(thisRaceID,"Hex",
		//"Chance of resisting other enemy's skill attacks",false,4);
		SKILL_RECARN_WARD=War3_AddRaceSkill(thisRaceID,"Healing Ward",
		"Use +ability to make healing wards!\nBe strategic, ward heals both teams!",false,4);
		ULT_VOODOO=War3_AddRaceSkill(thisRaceID,"Big Bad Voodoo",
		"You are invulnerable from physical attacks for\n0.66/1.0/1.33/1.66 seconds",true,4);
		War3_CreateRaceEnd(thisRaceID);
		//AuraID=W3RegisterAura("hunter_healwave",HealingWaveDistance);
		War3_SetDependency(thisRaceID, SKILL_IMPROVEDHEALING, SKILL_HEALINGWAVE, 4);

		// 1st Aura
		War3_AddAuraSkillBuff(thisRaceID, SKILL_HEALINGWAVE, fHPRegen, HealingWaveAmountArr,
							 "HealingWave", HealingWaveDistanceArr, 5,
							 false, Immunity_None);
		// 2nd Aura
		War3_AddAuraSkillBuff(thisRaceID, SKILL_IMPROVEDHEALING, fHPRegen, HealingWaveAmountArr,
							 "HealingWave2", HealingWaveDistanceArr, 5,
							 false, Immunity_None);
	}
}

public OnW3Denyable(W3DENY:event,client)
{
	if(RaceDisabled)
		return;

	if((event == DN_CanBuyItem1) && (W3GetVar(EventArg1) == War3_GetItemIdByShortname("lace")))
	{
		if(War3_GetRace(client)==thisRaceID)
		{
			W3Deny();
			War3_ChatMessage(client, "{lightgreen}The necklace is unholy! Get it away from me!");
		}
	}

	if((event == DN_CanBuyItem1) && (W3GetVar(EventArg1) == War3_GetItemIdByShortname("shield")))
	{
		if(War3_GetRace(client)==thisRaceID)
		{
			W3Deny();
			War3_ChatMessage(client, "{lightgreen}Why waste my money on shield?  At max level of Hex I'm immune to all Skills!");
		}
	}
}


public OnWardExpire(wardindex, owner, behaviorID)
{
	if(RaceDisabled)
		return;

	if(ValidPlayer(owner) && War3_GetRace(owner)==thisRaceID)
	{
		new skill_level=War3_GetSkillLevel(owner,thisRaceID,SKILL_RECARN_WARD);
		W3Hint(owner,HINT_COOLDOWN_EXPIRED,4.0,"You now have %d/%d Healing Wards.", War3_GetWardCount(owner)-1, MaximumWards[skill_level]);
	}
}

// Events
public void OnWar3EventSpawn (int client)
{
	bVoodoo[client]=false;
//	StopParticleEffect(client, true);
}

/*
public OnClientDisconnect(client)
{
	StopParticleEffect(client, true);
}

public OnWar3EventDeath(victim, attacker)
{
	StopParticleEffect(victim, false);
}
*/

public OnAddSound(sound_priority)
{
	if(sound_priority==PRIORITY_LOW)
	{
		War3_AddSound(ultimateSound,_,thisRaceID);
	}
}

public OnWar3PlayerAuthed(client)
{
	bVoodoo[client]=false;
}

public OnRaceChanged(client,oldrace,newrace)
{
	War3_SetBuff(client,bImmunitySkills,thisRaceID,false);
	War3_SetBuff(client,fHPRegen,thisRaceID,0.0);
}

public void OnUltimateCommand(int client, int race, bool pressed, bool bypass)
{
	if(RaceDisabled)
		return;

	new userid=GetClientUserId(client);
	if(race==thisRaceID && pressed && userid>1 && IsPlayerAlive(client) )
	{
		new ult_level=War3_GetSkillLevel(client,race,ULT_VOODOO);
		if(ult_level>0)
		{
			if(!Silenced(client)&&War3_SkillNotInCooldown(client,thisRaceID,ULT_VOODOO,true))
			{
				bVoodoo[client]=true;

				W3SetPlayerColor(client,thisRaceID,255,200,0,_,GLOW_ULTIMATE); //255,200,0);
				CreateTimer(UltimateDuration[ult_level],EndVoodoo,client);
				new Float:cooldown=	GetConVarFloat(ultCooldownCvar);
				War3_CooldownMGR(client,cooldown,thisRaceID,ULT_VOODOO,_,_);
				W3MsgUsingVoodoo(client);
				War3_EmitSoundToAll(ultimateSound,client);
				War3_EmitSoundToAll(ultimateSound,client);
				War3_NotifyPlayerSkillActivated(client,ULT_VOODOO,true);
			}

		}
		else
		{
			W3MsgUltNotLeveled(client);
		}
	}
}



public Action:EndVoodoo(Handle:timer,any:client)
{
	bVoodoo[client]=false;
	W3ResetPlayerColor(client,thisRaceID);
	War3_NotifyPlayerSkillActivated(client,ULT_VOODOO,false);
	if(ValidPlayer(client,true))
	{
		W3MsgVoodooEnded(client);
	}
}

/*
public Action:CalcHexHealWaves(Handle:timer,any:userid)
{
	if(RaceDisabled)
		return Plugin_Continue;

	if(thisRaceID>0)
	{
		for(new i=1;i<=MaxClients;i++)
		{
			particled[i]=false;
			if(ValidPlayer(i,true))
			{
				if(War3_GetRace(i)==thisRaceID)
				{
					new bool:value=(GetRandomFloat(0.0,1.0)<=HexChanceArr[War3_GetSkillLevel(i,thisRaceID,SKILL_HEX)]&&!Hexed(i,false));
					War3_SetBuff(i,bImmunitySkills,thisRaceID,value);
				}
			}
		}
	}
	return Plugin_Continue;
}*/

/* ORC SWAP ABILITY BELOW */

public void OnAbilityCommand(int client, int ability, bool pressed, bool bypass)
{
	if(RaceDisabled)
		return;

	if(War3_GetRace(client)==thisRaceID && ability==0 && pressed && IsPlayerAlive(client))
	{
		new skill_level=War3_GetSkillLevel(client,thisRaceID,SKILL_RECARN_WARD);
		if(skill_level>0&&!Silenced(client))
		{
			if(War3_GetWardCount(client)<MaximumWards[skill_level])
			{
					new Float:location[3];
					GetClientAbsOrigin(client, location);
					if(War3_CreateWardMod(client, location, 60, 60.0, 0.5, "heal", SKILL_RECARN_WARD, WardHeal, WARD_TARGET_TEAMMATES)>-1)
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
}



public Action OnW3TakeDmgAllPre(int victim, int attacker, float damage)
{
	if(RaceDisabled)
		return;

	if(IS_PLAYER(victim)&&IS_PLAYER(attacker)&&victim>0&&attacker>0) //block self inflicted damage
	{
		if(bVoodoo[victim]&&attacker==victim){
			War3_DamageModPercent(0.0);
			return;
		}
		new vteam=GetClientTeam(victim);
		new ateam=GetClientTeam(attacker);


		if(vteam!=ateam)
		{
			if(bVoodoo[victim])
			{
				if(!W3HasImmunity(attacker,Immunity_Ultimates))
				{
#if GGAMETYPE == GGAME_TF2
					decl Float:pos[3];
					GetClientEyePosition(victim, pos);
					pos[2] += 4.0;
					War3_TF_ParticleToClient(0, "miss_text", pos); //to the attacker at the enemy pos
					//War3_TF_ParticleToClient(0, "healthgained_blu", pos);
#endif
					War3_DamageModPercent(0.0);
				}
				else
				{
					W3MsgEnemyHasImmunity(victim,true);
				}
			}
		}
	}
	return;
}

//=======================================================================
//                  HEALING WAVE PARTICLE EFFECT (TF2 ONLY!)
//=======================================================================

// Written by FoxMulder with some tweaks by me https://forums.alliedmods.net/showpost.php?p=909189&postcount=7
/*
AttachParticles(ent, String:particleType[], controlpoint)
{
	if(War3_GetGame() == Game_TF)
	{
		new particle  = CreateEntityByName("info_particle_system");
		new particle2 = CreateEntityByName("info_particle_system");
		if (IsValidEdict(particle))
		{
			new String:tName[128];
			Format(tName, sizeof(tName), "target%i", ent);
			DispatchKeyValue(ent, "targetname", tName);

			new String:cpName[128];
			Format(cpName, sizeof(cpName), "target%i", controlpoint);
			DispatchKeyValue(controlpoint, "targetname", cpName);

			//--------------------------------------
			new String:cp2Name[128];
			Format(cp2Name, sizeof(cp2Name), "tf2particle%i", controlpoint);

			DispatchKeyValue(particle2, "targetname", cp2Name);
			DispatchKeyValue(particle2, "parentname", cpName);

			SetVariantString(cpName);
			AcceptEntityInput(particle2, "SetParent");

			SetVariantString("flag");
			AcceptEntityInput(particle2, "SetParentAttachment");
			//-----------------------------------------------

			DispatchKeyValue(particle, "targetname", "tf2particle");
			DispatchKeyValue(particle, "parentname", tName);
			DispatchKeyValue(particle, "effect_name", particleType);
			DispatchKeyValue(particle, "cpoint1", cp2Name);

			DispatchSpawn(particle);

			SetVariantString(tName);
			AcceptEntityInput(particle, "SetParent");

			SetVariantString("flag");
			AcceptEntityInput(particle, "SetParentAttachment");

			//The particle is finally ready
			ActivateEntity(particle);
			AcceptEntityInput(particle, "start");

			ParticleEffect[ent][controlpoint] = particle;
		}
	}
}

StopParticleEffect(client, bKill)
{
	if(War3_GetGame() == Game_TF)
	{
		for(new i=1; i <= MaxClients; i++)
		{
			decl String:className[64];
			decl String:className2[64];

			if(IsValidEdict(ParticleEffect[client][i]))
				GetEdictClassname(ParticleEffect[client][i], className, sizeof(className));
			if(IsValidEdict(ParticleEffect[i][client]))
			GetEdictClassname(ParticleEffect[i][client], className2, sizeof(className2));

			if(StrEqual(className, "info_particle_system"))
			{
				if(IsValidEntity(ParticleEffect[i][client]))
				{
					AcceptEntityInput(ParticleEffect[i][client], "stop");
				}
//				AcceptEntityInput(ParticleEffect[client][i], "stop");
				if(bKill && IsValidEntity(ParticleEffect[client][i]))
					{
						AcceptEntityInput(ParticleEffect[client][i], "kill");
						ParticleEffect[client][i] = 0;
					}
			}

			if(StrEqual(className2, "info_particle_system"))
			{
				if(IsValidEntity(ParticleEffect[i][client]))
				{
					AcceptEntityInput(ParticleEffect[i][client], "stop");
				}
				if(bKill && IsValidEntity(ParticleEffect[i][client]))
					{
						AcceptEntityInput(ParticleEffect[i][client], "kill");
						ParticleEffect[i][client] = 0;
					}
			}
		}
	}
}


public Action:HealingWaveParticleTimer(Handle:timer, any:userid)
{
	if(War3_GetGame() == Game_TF)
		for(new client=1; client <= MaxClients; client++)
			if(ValidPlayer(client, true))
				if(War3_GetRace(client) == thisRaceID)
				{
	 				new skill = War3_GetSkillLevel(client,thisRaceID,SKILL_HEALINGWAVE) + War3_GetSkillLevel(client,thisRaceID,SKILL_IMPROVEDHEALING);
					if(skill > 0)
					{
						new Float:HealerPos[3];
						new Float:TeammatePos[3];
						new Float:maxDistance = HealingWaveDistanceArr[skill];

						GetClientAbsOrigin(client, HealerPos);

						for(new i=1; i <= MaxClients; i++)
							if(ValidPlayer(i, true) && GetClientTeam(i) == GetClientTeam(client) && (i != client))
							{
								if(IsValidEdict(ParticleEffect[client][i]))
								{
									decl String:className[64];
									GetEdictClassname(ParticleEffect[client][i], className, sizeof(className));

									GetClientAbsOrigin(i, TeammatePos);
									if(GetVectorDistance(HealerPos, TeammatePos) <= maxDistance)
									{
										if(StrEqual(className, "info_particle_system"))
											AcceptEntityInput(ParticleEffect[client][i], "start");
										else
											switch(GetClientTeam(client))
											{
												case(2):
													AttachParticles(client, "medicgun_beam_red", i);
													//AttachParticles(client, "medicgun_beam_red", i);
												case(3):
												//	AttachParticles(client, "medicgun_beam_blue", i);
													AttachParticles(client, "medicgun_beam_blue", i);
											}
									}
									else
									{
										if(StrEqual(className, "info_particle_system"))
											AcceptEntityInput(ParticleEffect[client][i], "stop");
									}
								}
							}
					}
				}
}
*/

