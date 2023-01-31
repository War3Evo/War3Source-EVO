#include <war3source>
#assert GGAMEMODE == MODE_WAR3SOURCE
#assert GGAMETYPE_JAILBREAK == JAILBREAK_OFF

#define RACE_ID_NUMBER 16

//////////////////////////////////////
// 			T F 2   O N L Y         //
//////////////////////////////////////

//#pragma semicolon 1

//#include <sourcemod>
//#include <tf2>
//#include <tf2_stocks>
//#include "W3SIncs/War3Source_Interface"

new thisRaceID;
public Plugin:myinfo =
{
	name = "Race - Dragonborn",
	author = "Smilax", //with help from Glider
	description = "The Dragonborn race for War3Source:EVO.",
	version = "2.0.0.0",
	url = "http://www.war3evo.info/"
};

bool HooksLoaded = false;
public void Load_Hooks()
{
	if(HooksLoaded) return;
	HooksLoaded = true;

	W3Hook(W3Hook_OnUltimateCommand, OnUltimateCommand);
	W3Hook(W3Hook_OnAbilityCommand, OnAbilityCommand);
}
public void UnLoad_Hooks()
{
	if(!HooksLoaded) return;
	HooksLoaded = false;

	W3UnhookAll(W3Hook_OnUltimateCommand);
	W3UnhookAll(W3Hook_OnAbilityCommand);
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

new SKILL_ROAR,SKILL_SCALES,SKILL_DRAGONBORN,ULTIMATE_DRAGONBREATH;
/*
Roar - Stuns targets in a radius and applys the scare effect.
Scales - Gives you a small armor bonus, &  at level 4 makes you invunerable to ultimates due to your magic scales.
Dragonborn - You get increased health from being dragonborn.
Dragonbreath - Breathe fire in an area infront of you.

To Do:
Roar - Finished except for effect		|Fear effect
Dragonborn - Finished					|No effects
Scales - Finished						|No effects
Ultimate - Unfinished
Effects - Unfinished
IT'S ALL FINISHED

V. 2.0.0.0
Changed max hp to ability immunitys because tf2 max hp is dumb.

Cool things learned this race:
**W3PrintSkillDmgConsole(i,client,War3_GetWar3DamageDealt(),SKILL_NAME);
**if (TF2_GetClass(client) == TFClass_Scout) etc etc
**new const SkillColor[4] = {255, 255, 255, 155} changing skill colors via array, neato.
**That max health in tf2 is stupid.
*/
float RoarRadius=400.0;
#if GGAMETYPE == GGAME_TF2
new Float:RoarDuration[5]={0.0,0.2,0.4,0.6,0.7};
#endif
new Float:RoarCooldownTime=25.0;
new Float:ScalesPhysical[5]={0.0,1.0,1.66,2.33,3.0};
new Float:ImmunityChance=0.15;
new Float:dragvec[3]={0.0,0.0,0.0};
new Float:victimvec[3]={0.0,0.0,0.0};
new Float:DragonBreathRange[5]={0.0,400.0,500.0,600.0,700.0};

// Sounds
new String:roarsound[]="war3source/dragonborn/roar.mp3";
new String:ultsndblue[]="war3source/dragonborn/ultblue.mp3";
new String:ultsndred[]="war3source/dragonborn/ultred.mp3";


public OnWar3LoadRaceOrItemOrdered2(num,reloadrace_id,String:shortname[])
{
	if(num==RACE_ID_NUMBER||(reloadrace_id>0&&StrEqual("dragonborn_o",shortname,false)))
	{

		thisRaceID=War3_CreateNewRace("Dragonborn","dragonborn_o",reloadrace_id,"Jarate AoE ultimate");
		SKILL_ROAR=War3_AddRaceSkill(thisRaceID,"Roar","(+Ability) Puts all those around you in a 400 radius in a fear state for 0.4-1.0 second.",false,4);
		SKILL_SCALES=War3_AddRaceSkill(thisRaceID,"Scales","1-3 physical armor",false,4);
		SKILL_DRAGONBORN=War3_AddRaceSkill(thisRaceID,"Dragonborn","Being dragonborn gives immunitys to certain magics.\n15%% chance of immunity to wards/slows/skills/ultimates ",false,4);
		ULTIMATE_DRAGONBREATH=War3_AddRaceSkill(thisRaceID,"Dragons Breath","Applies jarate effect. 400-700 range.",true,4);
		War3_CreateRaceEnd(thisRaceID); ///DO NOT FORGET THE END!!!
	}
}

public OnPluginStart()
{
	CreateTimer(0.5,HalfSecondTimer,_,TIMER_REPEAT); //The footstep effect
	//LoadTranslations("w3s.race.dragonborn_o.phrases");
}
public OnAllPluginsLoaded()
{
	War3_RaceOnPluginStart("dragonborn_o");
}

public OnPluginEnd()
{
	if(LibraryExists("RaceClass"))
		War3_RaceOnPluginEnd("dragonborn_o");
}

#if GGAMETYPE == GGAME_TF2
//#define TRAILSMOKE "explosion_trailSmoke"
#define BURNINGPLAYER "burningplayer_flyingbits"
#define WATER_BULLET "water_bulletsplash01"
#define WATERFALL "waterfall_bottomwaves"
//#define TRAILFIRE "explosion_trailFire"
//#define YIKES_TEXT "yikes_text"
#define NEMESIS_RED "particle_nemesis_burst_red"
#define NEMESIS_BLUE "particle_nemesis_burst_blue"
#elseif GGAMETYPE == GGAME_CSGO
//#define TRAILSMOKE "explosion_trailSmoke"
#define BURNINGPLAYER "office_fire"
#define WATER_BULLET "water_splash_02_vertical"
#define WATERFALL "water_foam_01c"
//#define TRAILFIRE "explosion_trailFire"
//#define YIKES_TEXT "yikes_text"
#define NEMESIS_RED "slime_splash_01"
#define NEMESIS_BLUE "slime_splash_01"
#else
//#define TRAILSMOKE ""
#define BURNINGPLAYER ""
#define WATER_BULLET ""
#define WATERFALL ""
//#define TRAILFIRE ""
//#define YIKES_TEXT ""
#define NEMESIS_RED ""
#define NEMESIS_BLUE ""
#endif

public OnMapStart()
{

	//War3_PrecacheParticle(TRAILSMOKE);//ultimate trail
	War3_PrecacheParticle(BURNINGPLAYER); //Red Team foot effect
	War3_PrecacheParticle(WATER_BULLET); //Blue Team foot effect
	War3_PrecacheParticle(WATERFALL); //Blue Team DragonsBreath Effect
	//War3_PrecacheParticle(TRAILFIRE);//Red Team DragonsBreath Effect
	//War3_PrecacheParticle(YIKES_TEXT);//Roar Effect Victim
	War3_PrecacheParticle(NEMESIS_RED);//Red Team Roar Caster
	War3_PrecacheParticle(NEMESIS_BLUE);//Blue Team Roar Caster
	//War3_PrecacheSound(roarsound);
	//War3_PrecacheSound(ultsndblue);
	//War3_PrecacheSound(ultsndred);
}

public OnAddSound(sound_priority)
{
	if(sound_priority==PRIORITY_MEDIUM)
	{
		War3_AddSound(roarsound);
		War3_AddSound(ultsndblue);
		War3_AddSound(ultsndred);
	}
}

public void OnUltimateCommand(int client, int race, bool pressed, bool bypass)
{
	if(RaceDisabled)
		return;

	new userid=GetClientUserId(client);
	if(race==thisRaceID && pressed && userid>1 && IsPlayerAlive(client) )
	{
		new ult_level=War3_GetSkillLevel(client,race,ULTIMATE_DRAGONBREATH);
		if(ult_level>0)
		{
			if(!Silenced(client)&&(bypass||War3_SkillNotInCooldown(client,thisRaceID,ULTIMATE_DRAGONBREATH,true)))
			{
				new Float:breathrange= DragonBreathRange[ult_level];
				//War3_GetTargetInViewCone(client,Float:max_distance=0.0,bool:include_friendlys=false,Float:cone_angle=23.0,Function:FilterFunction=INVALID_FUNCTION);
				new target = War3_GetTargetInViewCone(client,breathrange,false,23.0,UltFilter,ULTIMATE_DRAGONBREATH);
				//new Float:duration = DarkorbDuration[ult_level];
				if(target>0)
				{
					War3_EmitSoundToAll(ultsndblue,client);
					War3_EmitSoundToAll(ultsndblue,target); //play sound to target ... - Dagothur 1/16/2013
					GetClientAbsOrigin(target,victimvec);
#if GGAMETYPE == GGAME_TF2
					TF2_AddCondition(target, TFCond_Jarated, 5.0);
#else
					DP("ULTIMATE DRAGONBREATH skill is not currently working correctly for CSGO yet.");
#endif
					AttachThrowAwayParticle(target, WATERFALL, victimvec, "", 2.0);
					War3_CooldownMGR(client,25.0,thisRaceID,ULTIMATE_DRAGONBREATH,_,_);
					W3Hint(target,HINT_COOLDOWN_NOTREADY,5.0,"A dragon weakend you with dragon breath");
				}
				else{
					W3MsgNoTargetFound(client,breathrange);
				}
			}
		}
	}
}

//public bool:DragonFilter(client,target)
//{
	//return (!W3HasImmunity(client,Immunity_Ultimates));
//}

public Action:HalfSecondTimer(Handle:timer,any:clientz) //footsy flame/water effects only on ground yay!
{
	if(RaceDisabled)
		return Plugin_Continue;

	for(new client=1; client <= MaxClients; client++)
	{
		if(ValidPlayer(client, true))
		{
#if GGAMETYPE == GGAME_TF2
			if(War3_GetRace(client) == thisRaceID&&!IsInvis(client))
#else
			if(War3_GetRace(client) == thisRaceID)
#endif
			{
				GetClientAbsOrigin(client,dragvec);
				//dragvec[2]+=35.0;  Crotch Level lololol Firecrotch
				dragvec[2]+=15;
#if GGAMETYPE == GGAME_TF2
				AttachThrowAwayParticle(client, GetApparentTeam(client) == TEAM_BLUE?WATER_BULLET:BURNINGPLAYER, dragvec, "", 1.5);
#endif
			}
		}
	}
	return Plugin_Continue;
}

public Action:stopspeed(Handle:t,any:client){
//W3ResetBuffRace(client,fMaxSpeed,thisRaceID);
//TF2_StunPlayer(client,0.0, 0.0,TF_STUNFLAGS_LOSERSTATE,0);
}
//Roar - If it's too overpowered I might add in an adrenaline effect to all clients effect afterward (Increased speed during thirdperson stun animation)
public void OnAbilityCommand(int client, int ability, bool pressed, bool bypass)
{
	//PrintToChatAll("OnAbilityCommand client %d ability %d pressed %s bypass %s",client,ability,pressed?"true":"false",ability,bypass?"true":"false");
	//TF2_StunPlayer(client,5.0, 0.0,TF_STUNFLAG_SLOWDOWN|TF_STUNFLAG_THIRDPERSON,0);
	//War3_SetBuff(client,fMaxSpeed,thisRaceID,2.0);
	//CreateTimer(1.0,stopspeed,client);
	if(War3_GetRace(client)==thisRaceID && ability==0 && pressed && IsPlayerAlive(client))
	{
		//PrintToChatAll("dragonborn pressed ability == 0");

		if(!Silenced(client)&&(bypass||War3_SkillNotInCooldown(client,thisRaceID,SKILL_ROAR,true)))
		{
			//PrintToChatAll("dragonborn War3_SkillNotInCooldown!");
			int skilllvl = War3_GetSkillLevel(client,thisRaceID,SKILL_ROAR);
			//if(skilllvl > 0)
			if(HasLevels(client, skilllvl, 1))
			{
				//PrintToChatAll("dragonborn skilllvl > 0");
				float AttackerPos[3];
				GetClientAbsOrigin(client,AttackerPos);
				int AttackerTeam = GetClientTeam(client);
				float VictimPos[3];
				bool victimfound = false;
				for(int i=1;i<=MaxClients;i++)
				{
					if(ValidPlayer(i,true))
					{
						GetClientAbsOrigin(i,VictimPos);
						if(GetVectorDistance(AttackerPos,VictimPos)<RoarRadius)
						{
							if(GetClientTeam(i)!=AttackerTeam) //fixed immunity; this was checking if the dragonborn had skill immunity rather than the target - Dagothur 1/16/2013
							{
								if(!W3HasImmunity(i,Immunity_Skills))
								{
									//TF2_StunPlayer(client, Float:duration, Float:slowdown=0.0, stunflags, attacker=0);
									War3_EmitSoundToAll(roarsound,client);
									War3_EmitSoundToAll(roarsound,i); //fixed playing the roar sound to the affected player; this used to play it to the client, which as you can see above, resulted in it being played twice - Dagothur 1/16/2013

#if GGAMETYPE == GGAME_TF2
									TF2_StunPlayer(i, RoarDuration[skilllvl], _, TF_STUNFLAGS_GHOSTSCARE,client);
#else
									DP("SKILL_ROAR is not currently working for CSGO yet.");
#endif
									War3_CooldownMGR(client,RoarCooldownTime,thisRaceID,SKILL_ROAR,_,_);
									GetClientAbsOrigin(client,dragvec);
									dragvec[2]+=70;
									if(AttackerTeam == TEAM_RED)
									{
										AttachThrowAwayParticle(client, NEMESIS_RED, dragvec, "", 1.5);
										W3Hint(i,HINT_COOLDOWN_NOTREADY,1.5,"OH GOD A DRAGON");
									}
									if(AttackerTeam == TEAM_BLUE)
									{
										AttachThrowAwayParticle(client, NEMESIS_BLUE, dragvec, "", 1.5);
										W3Hint(i,HINT_COOLDOWN_NOTREADY,1.5,"OH GOD A DRAGON");
									}
									victimfound=true;
								}
								else
								{
									War3_NotifyPlayerImmuneFromSkill(client, i, SKILL_ROAR);
								}
							}
						}
					}
				}
				if(!victimfound)
				{
					War3_ChatMessage(client,"{lightgreen}No victims found for Roar!");
					War3_CooldownMGR(client,5.0,thisRaceID,SKILL_ROAR,_,_);
				}
			}
		}
	}
}

public InitPassiveSkills(client)
{
	if(War3_GetRace(client)==thisRaceID)
	{
		//scales
		new skilllevel_armor=War3_GetSkillLevel(client,thisRaceID,SKILL_SCALES);
		War3_SetBuff(client,fArmorPhysical,thisRaceID,ScalesPhysical[skilllevel_armor]);

		//dragonborn
		new skilllvl = War3_GetSkillLevel(client,thisRaceID,SKILL_DRAGONBORN);
		new bool:value=(GetRandomFloat(0.0,1.0)<=ImmunityChance&&!Hexed(client,false));
		if(value && skilllvl > 0)
		{
			War3_SetBuff(client,bImmunityWards,thisRaceID,1);
			if (skilllvl > 1)
			{
				War3_SetBuff(client,bSlowImmunity,thisRaceID,1);
			}
			if (skilllvl >2)
			{
				War3_SetBuff(client,bImmunitySkills,thisRaceID,1);
			}
			if (skilllvl >3)
			{
				War3_SetBuff(client,bImmunityUltimates,thisRaceID,1);
			}
		}
		else{
			RemoveImmunity(client);
		}
	}
}
RemoveImmunity(client){
	War3_SetBuff(client,bImmunityWards,thisRaceID,0);
	War3_SetBuff(client,bImmunitySkills,thisRaceID,0);
	War3_SetBuff(client,bSlowImmunity,thisRaceID,0);
	War3_SetBuff(client,bImmunityUltimates,thisRaceID,0);
}
public OnRaceChanged(client,oldrace,newrace)
{
	if(newrace==thisRaceID)
	{
		InitPassiveSkills(client);
	}
	else //if(oldrace==thisRaceID)
	{
		War3_SetBuff(client,fArmorPhysical,thisRaceID,0);
		RemoveImmunity(client);
	}
}
