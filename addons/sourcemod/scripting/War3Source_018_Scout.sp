// War3Source_018_Scout.sp

#include <war3source>
#assert GGAMEMODE == MODE_WAR3SOURCE
#assert GGAMETYPE_JAILBREAK == JAILBREAK_OFF

#if (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
	#endinput
#endif

#define RACE_ID_NUMBER 180

/**
* File: War3Source_NightElf.sp
* Description: The Night Elf race for War3Source.
* Author(s): Anthony Iacono
*/

//#pragma semicolon 1

//#include <sourcemod>
//#include "W3SIncs/War3Source_Interface"
//#include <sdktools>

new thisRaceID;
bool HooksLoaded = false;
public void Load_Hooks()
{
	if(HooksLoaded) return;
	HooksLoaded = true;

	W3Hook(W3Hook_OnW3TakeDmgBulletPre, OnW3TakeDmgBulletPre);
	W3Hook(W3Hook_OnW3TakeDmgAll, OnW3TakeDmgAll);
	//W3Hook(W3Hook_OnWar3EventPostHurt, OnWar3EventPostHurt);
	W3Hook(W3Hook_OnUltimateCommand, OnUltimateCommand);
	W3Hook(W3Hook_OnAbilityCommand, OnAbilityCommand);
	W3Hook(W3Hook_OnWar3EventSpawn, OnWar3EventSpawn);
}
public void UnLoad_Hooks()
{
	if(!HooksLoaded) return;
	HooksLoaded = false;

	W3UnhookAll(W3Hook_OnW3TakeDmgBulletPre);
	W3UnhookAll(W3Hook_OnW3TakeDmgAll);
	//W3UnhookAll(W3Hook_OnWar3EventPostHurt);
	W3UnhookAll(W3Hook_OnUltimateCommand);
	W3UnhookAll(W3Hook_OnAbilityCommand);
	W3UnhookAll(W3Hook_OnWar3EventSpawn);
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


//new SKILL_INVIS, SKILL_TRUESIGHT, SKILL_DISARM, ULT_MARKSMAN, SKILL_FADE,SKILL_IMPROVED_INVIS;
int SKILL_INVIS, SKILL_TRUESIGHT, ULT_MARKSMAN, SKILL_FADE;

// Chance/Data Arrays
//new Float:InvisDrain=0.05; //as a percent of your health
new Float:InvisDuration[5]={0.0,6.0,7.0,8.0,9.0};
new Handle:InvisEndTimer[MAXPLAYERSCUSTOM];
new bool:InInvis[MAXPLAYERSCUSTOM];

// SKILL FADE
new bool:InFade[MAXPLAYERSCUSTOM];
//new Handle:EndFadeTimer[MAXPLAYERSCUSTOM];
new Float:FadeCoolDown[5]={0.0,20.0,16.0,12.0,8.0};
new FadeDurationREQ[5]={0,20,16,12,8}; // 10 = 1 second of stand still


new Float:EyeRadius[5]={0.0,400.0,500.0,700.0,800.0};

//new Float:DisarmChance[5]={0.0,0.06,0.10,0.13,0.15};
//new Float:DisarmSeconds[5]={0.0,0.5,0.7,0.9,1.2};
new Float:MarksmanCrit[5]={0.0,0.15,0.3,0.45,0.6};
new const STANDSTILLREQ=1;


new bool:bDisarmed[MAXPLAYERSCUSTOM];
new Float:lastvec[MAXPLAYERSCUSTOM][3];
new standStillCount[MAXPLAYERSCUSTOM];

// Effects
//new BeamSprite,HaloSprite;

new AuraID;

public Plugin:myinfo =
{
	name = "Race - Scout",
	author = "Ownz",
	description = "The Night Elf race for War3Source.",
	version = "1.0.0.0",
	url = "http://pimpinjuice.net/"
};

public OnPluginStart()
{


	//UltCooldownCvar=CreateConVar("war3_scout_ult_cooldown","20","Cooldown timer.");

	//LoadTranslations("w3s.race.scout_o.phrases");
	CreateTimer(1.0,DeciSecondTimer,_,TIMER_REPEAT);

	AddCommandListener(Taunt, "+taunt");

	for(new i = 1; i <= MaxClients; i++)
	{
		if(ValidPlayer(i))
		{
			SDKHook(i, SDKHook_SetTransmit, SDK_FORWARD_TRANSMIT);
		}
	}
}
public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_SetTransmit, SDK_FORWARD_TRANSMIT);
}

public OnAllPluginsLoaded()
{
	War3_RaceOnPluginStart("scout_o");
}

public OnPluginEnd()
{
	if(LibraryExists("RaceClass"))
		War3_RaceOnPluginEnd("scout_o");
	for(new i = 1; i <= MaxClients; i++)
	{
		if(ValidPlayer(i))
		{
			SDKUnhook(i, SDKHook_SetTransmit, SDK_FORWARD_TRANSMIT);
		}
	}
}

public OnMapStart()
{
	UnLoad_Hooks();
	//BeamSprite=PrecacheModel("materials/sprites/lgtning.vmt");
	//HaloSprite=PrecacheModel("materials/sprites/halo01.vmt");

}

public OnWar3LoadRaceOrItemOrdered2(num,reloadrace_id,String:shortname[])
{
	if(num==RACE_ID_NUMBER||(reloadrace_id>0&&StrEqual("scout_o",shortname,false)))
	{
		thisRaceID=War3_CreateNewRace("Scoot","scout_o",reloadrace_id,"See cloaked enemies(no spys)");
		SKILL_INVIS=War3_AddRaceSkill(thisRaceID,"Vanish","+ability: Turn invisible for 6-9 seconds.\nCannot shoot for 1 second out of invis.\nLeave invis early by using ability again",false,4);
		SKILL_TRUESIGHT=War3_AddRaceSkill(thisRaceID,"TrueSight","Enemies cannot be invisible or partially invisible around you. \n400-800 units.\nDoes not affect spy cloak",false,4);

		//SKILL_DISARM=War3_AddRaceSkill(thisRaceID,"Disarm","6/10/13/15% chance to disarm the enemy on hit\n0.5/0.7/0.9/1.2 seconds to disarm victim.",false,4);
		ULT_MARKSMAN=War3_AddRaceSkill(thisRaceID,"Marksman","Standing still for 1 second, scout is able to deal 1.2-1.6x damage the further the target.\n1000 units or more deals maximum damage",true,4);
		SKILL_FADE=War3_AddRaceSkill(thisRaceID,"Blink","If standing still for 20/16/12/8 seconds, you go completely invisible.\nAny movement or damage (to or from you) makes you visible.",false,4);
		//SKILL_IMPROVED_INVIS=War3_AddRaceSkill(thisRaceID,"OutPost","+ability2: While pressed, locks your position down.",false,1);

		War3_CreateRaceEnd(thisRaceID);

		AuraID =W3RegisterChangingDistanceAura("scout_reveal",true);

		War3_SetDependency(thisRaceID, SKILL_FADE, ULT_MARKSMAN, 1);
		//War3_SetDependency(thisRaceID, SKILL_IMPROVED_INVIS, SKILL_INVIS, 4);

		//ServerCommand("war3 scout_flags hidden");
		//ServerExecute();
	}
}

public OnW3Denyable(W3DENY:event,client)
{
	if(RaceDisabled)
		return;

	if((event == DN_CanBuyItem1) && (W3GetVar(EventArg1) == War3_GetItemIdByShortname("ring")))
	{
		if(War3_GetRace(client)==thisRaceID)
		{
			W3Deny();
			War3_ChatMessage(client, "What?!  Not on my trigger finger!");
		}
	}
}


public OnRaceChanged(client,oldrace,newrace)
{
	if(newrace==thisRaceID)
	{
		InitPassiveSkills(client);
	}
	else //if(oldrace==thisRaceID)
	{
		RemovePassiveSkills(client);
	}
}

public InitPassiveSkills(client)
{
	// Natural Armor Buff
	//War3_SetBuff(client,fArmorPhysical,thisRaceID,3.0);
	//War3_SetBuff(client,fArmorMagic,thisRaceID,3.0);
	new level=War3_GetSkillLevel(client,thisRaceID,SKILL_TRUESIGHT);
	if(level>0){
		W3SetPlayerAura(AuraID,client,EyeRadius[level],level);
	}
	else
	{
		W3RemovePlayerAura(AuraID,client);
	}
}

public RemovePassiveSkills(client)
{
	//War3_SetBuff(client,fArmorPhysical,thisRaceID,0.0);
	//War3_SetBuff(client,fArmorMagic,thisRaceID,0.0);
	W3ResetAllBuffRace(client, thisRaceID);
	W3RemovePlayerAura(AuraID,client);
	War3_SetBuff(client,bNoMoveMode,thisRaceID,false);
	EndFade(client);
}


public void OnSkillLevelChanged(int client, int currentrace, int skill, int newskilllevel, int oldskilllevel)
{
	if(RaceDisabled)
		return;

	if(currentrace==thisRaceID)
	{
		if(skill==SKILL_TRUESIGHT) //1
		{
			W3RemovePlayerAura(AuraID,client);
			if(newskilllevel>0){
				W3SetPlayerAura(AuraID,client,EyeRadius[newskilllevel],newskilllevel);
			}
		}
	}
}

public void OnWar3EventSpawn (int client)
{
	if(bDisarmed[client]){
		EndInvis2(INVALID_HANDLE,client);
	}
	if(InInvis[client]||InFade[client]){
		War3_SetBuff(client,fInvisibilitySkill,thisRaceID,1.0);
#if (GGAMETYPE == GGAME_TF2)
		TF2_RemoveCondition(client, TFCond_Stealthed);
		//SetVariantInt(0);
		if (AcceptEntityInput(client, "EnableShadow"))
		{
			//War3_ChatMessage(client,"{blue}Shadows Enabled");
		}
#endif
		War3_SetBuff(client,fHPDecay,thisRaceID,0.0);
		InInvis[client]=false;
		InFade[client]=false;
	}
}
public void OnAbilityCommand(int client, int ability, bool pressed, bool bypass)
{
	if(RaceDisabled)
		return;

	if(ValidPlayer(client,true) && War3_GetRace(client)==thisRaceID)
	{
		if(ability==0 && pressed)
		{
			new skilllvl = War3_GetSkillLevel(client,thisRaceID,SKILL_INVIS);
			if(skilllvl > 0)
			{
				if(ValidPlayer(client) && InInvis[client]){
					TriggerTimer(InvisEndTimer[client]);

				}
				else if(!Silenced(client)&&War3_SkillNotInCooldown(client,thisRaceID,SKILL_INVIS,true))
				{
					if(ValidPlayer(client) && !InFade[client])
					{
						War3_SetBuff(client,bDisarm,thisRaceID,true);
						bDisarmed[client]=true;
#if (GGAMETYPE == GGAME_TF2)
						TF2_AddCondition(client, TFCond_Stealthed, 2400.0);
						SetVariantInt(1);
						if (AcceptEntityInput(client, "DisableShadow"))
						{
							//War3_ChatMessage(client,"{blue}Shadows Disabled");
						}
#elseif (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
						War3_SetBuff(client,fInvisibilitySkill,thisRaceID,0.03);
#endif
						//War3_SetBuff(client,fHPDecay,thisRaceID,War3_GetMaxHP(client)*InvisDrain);
						InvisEndTimer[client]=CreateTimer(InvisDuration[skilllvl],EndInvis,client);


						PrintHintText(client,"You sacrificed part of yourself for invis");
						InInvis[client]=true;
						War3_CooldownMGR(client,15.0,thisRaceID,SKILL_INVIS);
					}
					else
					{
						PrintHintText(client,"You cannot invis while blinked!");
					}

				}
			}
		}
		/*
		if(ability==2)
		{
			new skilllvl = War3_GetSkillLevel(client,thisRaceID,SKILL_IMPROVED_INVIS);
			if(skilllvl>0)
			{
				if(pressed)
				{
					new bool:ToggleButton=W3GetBuff(client,bNoMoveMode,thisRaceID);
					if(!ToggleButton && InFade[client])
					{
						PrintHintText(client,"OUTPOST ON");
						War3_SetBuff(client,bNoMoveMode,thisRaceID,true);
					}
					else
					{
						PrintHintText(client,"OUTPOST OFF");
						War3_SetBuff(client,bNoMoveMode,thisRaceID,false);
					}
				}
			}
		}*/
	}
}
public OnWar3EventDeath(victim,attacker){
	if(RaceDisabled)
		return;
	if(War3_GetRace(victim)==thisRaceID)
	{
		War3_SetBuff(victim,bNoMoveMode,thisRaceID,false);
	}
}
public EndFade(client)
{
	if(ValidPlayer(client))
	{
		InFade[client]=false;

		if(W3GetBuff(client,bNoMoveMode,thisRaceID))
		{
			PrintHintText(client,"OUTPOST OFF");
			War3_SetBuff(client,bNoMoveMode,thisRaceID,false);
		}

#if (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
		War3_SetBuff(client,fInvisibilitySkill,thisRaceID,1.0);
#elseif (GGAMETYPE == GGAME_TF2)
		TF2_RemoveCondition(client, TFCond_Stealthed);
		//SetVariantInt(0);
		if (AcceptEntityInput(client, "EnableShadow"))
		{
			//War3_ChatMessage(client,"{blue}Shadows Enabled");
		}
#endif
		PrintHintText(client,"You Blink into the Light!");
		new skilllvl = War3_GetSkillLevel(client,thisRaceID,SKILL_FADE);
		War3_CooldownMGR(client,FadeCoolDown[skilllvl],thisRaceID,SKILL_FADE);
	}

}
public Action:EndInvis(Handle:timer,any:client)
{
	InInvis[client]=false;
	if(!InFade[client])
	{
#if (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
		War3_SetBuff(client,fInvisibilitySkill,thisRaceID,1.0);
#elseif (GGAMETYPE == GGAME_TF2)
		TF2_RemoveCondition(client, TFCond_Stealthed);
		//SetVariantInt(0);
		if (AcceptEntityInput(client, "EnableShadow"))
		{
			//War3_ChatMessage(client,"{blue}Shadows Enabled");
		}
#endif
	}
	//War3_SetBuff(client,fHPDecay,thisRaceID,0.0);
	// Got an Error in the logs, so added ValidPlayer for checking.
	if (ValidPlayer(client))
		CreateTimer(1.0,EndInvis2,client);
	PrintHintText(client,"No Longer Invis! Cannot shoot for 1 sec!");
}
public Action:EndInvis2(Handle:timer,any:client){
	War3_SetBuff(client,bDisarm,thisRaceID,false);
	bDisarmed[client]=false;
	//SetVariantInt(0);
	if (AcceptEntityInput(client, "EnableShadow"))
	{
		//War3_ChatMessage(client,"{blue}Shadows Enabled");
	}
}

public Action OnW3TakeDmgAll(int victim,int attacker, float damage)
{
	if(RaceDisabled)
		return;

	if(ValidPlayer(victim)&&ValidPlayer(attacker))
	{
		if(War3_GetRace(attacker)==thisRaceID)
		{
			new lvl=War3_GetSkillLevel(attacker,thisRaceID,SKILL_FADE);
			if(lvl>0 && InFade[attacker]){ //stood still for 10 second
			if(ValidPlayer(attacker))
				EndFade(attacker);
			}
		}
		else
		if(War3_GetRace(victim)==thisRaceID)
		{
			new lvl=War3_GetSkillLevel(victim,thisRaceID,SKILL_FADE);
			if(lvl>0 && InFade[victim]){ //stood still for 10 second
			if(ValidPlayer(victim))
				EndFade(victim);
			}
		}
	}
}

//new icount = 0;
public Action OnW3TakeDmgBulletPre(int victim, int attacker, float damage, int damagecustom)
{
	//if(RaceDisabled)
		//return;
#if (GGAMETYPE == GGAME_TF2)
	if(ValidPlayer(attacker) && ValidPlayer(victim) && War3_GetRace(attacker)==thisRaceID && !War3_SkillNotInCooldown(attacker,thisRaceID,SKILL_INVIS,false))
	{
		switch (damagecustom)
		{
			case TF_CUSTOM_TAUNT_HADOUKEN, TF_CUSTOM_TAUNT_HIGH_NOON, TF_CUSTOM_TAUNT_GRAND_SLAM, TF_CUSTOM_TAUNT_FENCING,
			TF_CUSTOM_TAUNT_ARROW_STAB, TF_CUSTOM_TAUNT_GRENADE, TF_CUSTOM_TAUNT_BARBARIAN_SWING,
			TF_CUSTOM_TAUNT_UBERSLICE, TF_CUSTOM_TAUNT_ENGINEER_SMASH, TF_CUSTOM_TAUNT_ENGINEER_ARM, TF_CUSTOM_TAUNT_ARMAGEDDON:
			{
				War3_DamageModPercent(0.0);
				CreateTimer(0.1,EndTauntkill,attacker);
				return;
			}
		}
	}
#endif

	if(ValidPlayer(victim)&&ValidPlayer(attacker)&&W3GetDamageIsBullet())
	{
		new vteam=GetClientTeam(victim);
		new ateam=GetClientTeam(attacker);
		if(vteam!=ateam)
		{
			if(War3_GetRace(attacker)==thisRaceID){
				new lvl=War3_GetSkillLevel(attacker,thisRaceID,ULT_MARKSMAN);
				if(lvl>0&& standStillCount[attacker]>=STANDSTILLREQ){ //stood still for 1 second
					if(!W3HasImmunity(victim,Immunity_Ultimates))
					{
						new Float:vicpos[3];
						new Float:attpos[3];
						GetClientAbsOrigin(victim,vicpos);
						GetClientAbsOrigin(attacker,attpos);
						new Float:distance=GetVectorDistance(vicpos,attpos);

						if(distance>1000.0){ //0-512 normal damage 512-1024 linear increase, 1024-> maximum
							distance=1000.0;
						}
						new Float:multi=distance*MarksmanCrit[lvl]/1000.0;
						War3_DamageModPercent(multi+1.0);
						//W3ForceDamageIsBullet();
						//icount++;
						PrintToConsole(attacker,"[War3Source:EVO] %.2fX dmg by marksman shot",multi);
						//DP("[War3Source:EVO] %.2fX dmg by marksman shot (DamageStack %d) (DamageType %d) (Damage Inflictor %d) count = %d",multi,W3GetDamageStack(),W3GetDamageType(),W3GetDamageInflictor(),icount);

					}
					else
					{
						War3_NotifyPlayerImmuneFromSkill(attacker, victim, ULT_MARKSMAN);
					}
				}
			}
		}
	}
}

public Action:EndTauntkill(Handle:t,any:client)
{
	FakeClientCommand(client, "kill");
}

/*
public Action OnWar3EventPostHurt(int victim, int attacker, float dmgamount, char weapon[32], bool isWarcraft, const float damageForce[3], const float damagePosition[3])
{
	if(RaceDisabled)
		return;

	if(W3GetDamageIsBullet()&&ValidPlayer(victim,true)&&ValidPlayer(attacker,true)&&GetClientTeam(victim)!=GetClientTeam(attacker))
	{
		if(War3_GetRace(attacker)==thisRaceID)
		{
			new skill_level=War3_GetSkillLevel(attacker,thisRaceID,SKILL_DISARM);
			if(skill_level>0&&!Hexed(attacker,false))
			{
				if(!bDisarmed[victim]){
					if(  W3Chance(DisarmChance[skill_level]*W3ChanceModifier(attacker))  ){
						if(!W3HasImmunity(victim,Immunity_Skills))
						{
							War3_SetBuff(victim,bDisarm,thisRaceID,true);
							CreateTimer(DisarmSeconds[skill_level],Undisarm,victim);
						}
						else
						{
							War3_NotifyPlayerImmuneFromSkill(attacker, victim, SKILL_DISARM);
						}
					}
				}
			}
		}
	}
}
public Action:Undisarm(Handle:t,any:client){
	War3_SetBuff(client,bDisarm,thisRaceID,false);
}*/


public Action:DeciSecondTimer(Handle:t){
	if(RaceDisabled)
		return;

	for(new client=1;client<=MaxClients;client++)
	{
		if(ValidPlayer(client,true,true)&&War3_GetRace(client)==thisRaceID)
		{
			static Float:vec[3];
			GetClientAbsOrigin(client,vec);
			if(GetVectorDistance(vec,lastvec[client])>1.0)
			{
				//DP("TRIGGER");
				standStillCount[client]=0;
				if(ValidPlayer(client) && InFade[client])
				{
					EndFade(client);
					//DP("TRIGGER END FADE");
				}
			}
			else
			{
				standStillCount[client]++;
				/*
				FIXES  THE PROBLEM WHEN YOU SHOOT AND BECOME VISIBLE FOR A SECOND
				if(InFade[client])
					standStillCount[client]=10;
				*/
				new skilllvl = War3_GetSkillLevel(client,thisRaceID,SKILL_FADE);
				if(InFade[client])
					standStillCount[client]=FadeDurationREQ[skilllvl];
				//if(InFade[client] && standStillCount[client]>600)
					//standStillCount[client]=600;
			}
			lastvec[client][0]=vec[0];
			lastvec[client][1]=vec[1];
			lastvec[client][2]=vec[2];
		}
		//PrintToChatAll("stand still client %i count %i",client,standStillCount[client]);
		if(ValidPlayer(client,true)&&War3_GetRace(client)==thisRaceID)
		{
			new skilllvl = War3_GetSkillLevel(client,thisRaceID,SKILL_FADE);
			if(skilllvl>0 && standStillCount[client]>=FadeDurationREQ[skilllvl] && War3_SkillNotInCooldown(client,thisRaceID,SKILL_FADE,true))
			{
				//FADE
				if(!InFade[client])
				{
					InFade[client]=true;
					//EndFadeTimer[client]=CreateTimer(FadeDurationT[skilllvl],EndFade,client);
					/*
					//FIXES  THE PROBLEM WHEN YOU SHOOT AND BECOME VISIBLE FOR A SECOND
					standStillCount[client]=10;
					*/
					standStillCount[client]=FadeDurationREQ[skilllvl]-10;
					//if(InFade[client] && standStillCount[client]>600)
						//standStillCount[client]=600;

#if (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
					War3_SetBuff(client,fInvisibilitySkill,thisRaceID,0.03);
#elseif (GGAMETYPE == GGAME_TF2)
					TF2_AddCondition(client, TFCond_Stealthed,2400.0);
					//SetVariantInt(1);
					if (AcceptEntityInput(client, "DisableShadow"))
					{
						//War3_ChatMessage(client,"{blue}Shadows Disabled");
					}
#endif
					W3Hint(client,HINT_SKILL_STATUS,5.0,"You Blink into darkness..");
				}
			}
		}
	}
}

public void OnUltimateCommand(int client, int race, bool pressed, bool bypass)
{
	if(RaceDisabled)
		return;

	if(race==thisRaceID && IsPlayerAlive(client) && pressed)
	{
		new skill_level=War3_GetSkillLevel(client,race,SKILL_TRUESIGHT);
		if(skill_level>0)
		{
			if(!Silenced(client)&&War3_SkillNotInCooldown(client,thisRaceID,SKILL_TRUESIGHT,true)){


			}
		}
		else
		{
			//print no eyes availabel
		}
	}
}
public OnW3PlayerAuraStateChanged(client,tAuraID,bool:inAura,level,AuraStack,AuraOwner){
	if(RaceDisabled)
		return;

	if(tAuraID==AuraID)
	{
		//DP(inAura?"in aura":"not in aura");
		//new String:StrOwner[128];
		//GetClientName(AuraOwner,StrOwner,sizeof(StrOwner));
		//DP("Scout Aura Owner %s",StrOwner);
		if(!W3HasImmunity(client,Immunity_Skills))
		{
			if(AuraStack>0)
			{
				War3_SetBuff(client,bInvisibilityDenyAll,thisRaceID,true,AuraOwner);
			}
			else
			{
				War3_SetBuff(client,bInvisibilityDenyAll,thisRaceID,false);
			}
#if (GGAMETYPE == GGAME_TF2)
			if(ValidPlayer(client,true) && !Spying(client))
			{
				TF2_RemoveCondition(client, TFCond_Stealthed);
			}
#endif
		}
		else
		{
			War3_SetBuff(client,bInvisibilityDenyAll,thisRaceID,false);
			War3_NotifyPlayerImmuneFromSkill(AuraOwner, client, SKILL_TRUESIGHT);
		}
	}

}

#if (GGAMETYPE == GGAME_TF2)
public TF2_OnConditionRemoved(client, TFCond:condition)
{
	if(RaceDisabled)
		return;

	if(ValidPlayer(client) && War3_GetRace(client)==thisRaceID)
	{
		if(condition==TFCond_Stealthed)
		{
			EndFade(client);
		}
	}

}
#endif

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if(RaceDisabled)
		return Plugin_Continue;

	if((buttons & IN_ATTACK))
	{
		if(ValidPlayer(client) && War3_GetRace(client)==thisRaceID)
		{
			EndFade(client);
		}
	}
	else if((buttons & IN_ATTACK2))
	{
		if(ValidPlayer(client) && War3_GetRace(client)==thisRaceID)
		{
			EndFade(client);
		}
	}
	return Plugin_Continue;
}

public Action:Taunt(client, String:cmd[], args)
{
	if (client <= 0)
	{
		return Plugin_Continue;
	}
	if (!IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Continue;
	}
	//if (!TF2_IsPlayerInCondition(client, TFCond_Taunting))
	//{
		//DP("not taunting");
		//return Plugin_Continue;
	//}
	if(ValidPlayer(client) && War3_GetRace(client)==thisRaceID)
	{
		EndFade(client);
		//return Plugin_Handled;
	}
	return Plugin_Continue;
}


public Action:SDK_FORWARD_TRANSMIT(entity, client)
{
	if(RaceDisabled)
		return Plugin_Continue;

#if (GGAMETYPE == GGAME_TF2)
	if(entity!=client
	&& InFade[client]
	&& ValidPlayer(entity)
	&& ValidPlayer(client)
	&& War3_GetRace(client)==thisRaceID
	&& W3HasImmunity(entity,Immunity_Skills))
	{
		new ClientTeam=GetClientTeam(client);
		if((ClientTeam==2 || ClientTeam==3)
		&& GetClientTeam(entity)!=ClientTeam
		&& IsPlayerAlive(entity)
		&& GetPlayerDistance(client,entity)>60.0
		&& !TF2_IsPlayerInCondition(entity, TFCond_Jarated)
		&& !TF2_IsPlayerInCondition(entity, TFCond_OnFire)
		&& !TF2_IsPlayerInCondition(entity, TFCond_Milked))
		{
			return Plugin_Handled;
		}
	}
#else
	if(entity!=client
	&& InFade[client]
	&& ValidPlayer(entity)
	&& ValidPlayer(client)
	&& War3_GetRace(client)==thisRaceID
	&& W3HasImmunity(entity,Immunity_Skills))
	{
		new ClientTeam=GetClientTeam(client);
		if((ClientTeam==2 || ClientTeam==3)
		&& GetClientTeam(entity)!=ClientTeam
		&& IsPlayerAlive(entity)
		&& GetPlayerDistance(client,entity)>60.0)
		{
			return Plugin_Handled;
		}
	}
#endif
	return Plugin_Continue;
}
