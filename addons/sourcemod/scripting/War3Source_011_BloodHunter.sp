#include <war3source>
#assert GGAMEMODE == MODE_WAR3SOURCE

#define RACE_ID_NUMBER 110

#define PLUGIN_VERSION "0.0.0.1 (1/20/2013) 9:12AM EST"
/**
 *
 * Description:   BH from HON
 * Author(s): Ownz (DarkEnergy)
 */

//#pragma semicolon 1

//#include <sourcemod>
//#include "W3SIncs/War3Source_Interface"
public W3ONLY(){} //unload this?


new thisRaceID;
new Handle:ultCooldownCvar;

new SKILL_CRAZY, SKILL_FEAST,SKILL_SENSE,ULT_RUPTURE; //,ULT_IMPROVED_RUPTURE;


// Chance/Data Arrays
new Float:CrazyDuration[7]={0.0,2.0,3.0,4.0,5.0,6.0,7.0};
new Float:CrazyUntil[MAXPLAYERSCUSTOM];
new bool:bCrazyDot[MAXPLAYERSCUSTOM];
new CrazyBy[MAXPLAYERSCUSTOM];

new Float:FeastAmount[7]={0.0,0.05,0.1,0.15,0.20,0.25,0.30};

new Float:BloodSense[7]={0.0,0.15,0.20,0.25,0.30,0.35,0.40};

new Float:ultRange=300.0;
// was new Float:ultiDamageMultiPerDistance[5]={0.0,0.06,0.073,0.086,0.10};
new Float:ultiDamageMultiPerDistance[5]={0.0,0.03,0.0365,0.043,0.05};
new Float:lastRuptureLocation[MAXPLAYERSCUSTOM][3];
new Float:RuptureDuration[5]={0.0,4.0,5.0,6.0,7.0};
new Float:RuptureUntil[MAXPLAYERSCUSTOM];
new bool:bRuptured[MAXPLAYERSCUSTOM];
new RupturedBy[MAXPLAYERSCUSTOM];

new String:ultsnd[]="war3source/bh/ult.mp3";


public Plugin:myinfo =
{
	name = "Race - Blood Hunter",
	author = "Ownz (DarkEnergy)",
	description = "Blood Hunter for War3Source.",
	version = "1.1",
	url = "War3Source.com"
};

bool HooksLoaded = false;
public void Load_Hooks()
{
	if(HooksLoaded) return;
	HooksLoaded = true;

	W3Hook(W3Hook_OnW3TakeDmgBulletPre, OnW3TakeDmgBulletPre);
	W3Hook(W3Hook_OnUltimateCommand, OnUltimateCommand);
	W3Hook(W3Hook_OnWar3EventSpawn, OnWar3EventSpawn);
}
public void UnLoad_Hooks()
{
	if(!HooksLoaded) return;
	HooksLoaded = false;

	W3UnhookAll(W3Hook_OnW3TakeDmgBulletPre);
	W3UnhookAll(W3Hook_OnUltimateCommand);
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


public OnPluginStart()
{
	CreateConVar("BloodHunter",PLUGIN_VERSION,"War3Source:EVO Blood Hunter",FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	ultCooldownCvar=CreateConVar("war3_bh_ult_cooldown","20","Cooldown time for Ultimate.");
	CreateTimer(0.1,RuptureCheckLoop,_,TIMER_REPEAT);
	CreateTimer(0.5,BloodCrazyDOTLoop,_,TIMER_REPEAT);

	RegAdminCmd("rme", ruptureme, ADMFLAG_ROOT, "Sets rupture on yourself without damage");

	//LoadTranslations("w3s.race.bh.phrases");
}

public OnAllPluginsLoaded()
{
	War3_RaceOnPluginStart("bh");
}

public OnPluginEnd()
{
	if(LibraryExists("RaceClass"))
		War3_RaceOnPluginEnd("bh");
}

public Action:ruptureme(client,args){
	bRuptured[client]=true;
	RupturedBy[client]=client;
	RuptureUntil[client]=GetGameTime()+999999.0;
	GetClientAbsOrigin(client,lastRuptureLocation[client]);

	return Plugin_Handled;
}

public OnWar3LoadRaceOrItemOrdered2(num,reloadrace_id,String:shortname[])
{
	if(num==RACE_ID_NUMBER||(reloadrace_id>0&&StrEqual("bh",shortname,false))){

		thisRaceID=War3_CreateNewRace("Blood Hunter","bh",reloadrace_id,"Hemorrhage,Feast");
		SKILL_CRAZY=War3_AddRaceSkill(thisRaceID,"Blood Crazy","Those damaged by you will bleed for 2 HP per second for 2 - 5 seconds\nOn activation, has cooldown of 4-10 seconds.",false,4);
		SKILL_FEAST=War3_AddRaceSkill(thisRaceID,"Feast","Heal 5-20 percent of the victim's max HP on kill",false,4);
		SKILL_SENSE=War3_AddRaceSkill(thisRaceID,"Blood Sense","Those who are below 15-30% max HP take critical damage",false,4);
		ULT_RUPTURE=War3_AddRaceSkill(thisRaceID,"Hemorrhage","The target will take damage if he moves.\nDuration Scales 4/5/6/7 seconds.",true,4);
		//ULT_IMPROVED_RUPTURE=War3_AddRaceSkill(thisRaceID,"Improved Hemorrhage","You heal 10/20 percent of the damage rupture deals.",false,2);
		War3_CreateRaceEnd(thisRaceID);
		//War3_SetDependency(thisRaceID, ULT_IMPROVED_RUPTURE, ULT_RUPTURE, 4);
	}
}

//public OnMapStart()
//{
	//War3_PrecacheSound(ultsnd);
//}

public OnAddSound(sound_priority)
{
	if(sound_priority==PRIORITY_MEDIUM)
	{
		War3_AddSound("Blood Hunter",ultsnd,CUSTOM_SOUND);
	}
}


public void OnUltimateCommand(int client, int race, bool pressed, bool bypass)
{
	if(RaceDisabled)
		return;

	if(race==thisRaceID && pressed && IsPlayerAlive(client))
	{
#if (GGAMETYPE == GGAME_TF2)
		if(!Spying(client))
		{
#endif
			int skill=War3_GetSkillLevel(client,race,ULT_RUPTURE);
			if(skill>0)
			{
				if(!Silenced(client)&&War3_SkillNotInCooldown(client,thisRaceID,ULT_RUPTURE,true))
				{
					int target=War3_GetTargetInViewCone(client,ultRange,false);
					if(ValidPlayer(target,true))
					{
						if(!W3HasImmunity(target,Immunity_Ultimates))
						{
							bRuptured[target]=true;
							RupturedBy[target]=client;
							RuptureUntil[target]=GetGameTime()+RuptureDuration[skill];
							GetClientAbsOrigin(target,lastRuptureLocation[target]);


							War3_CooldownMGR(client,GetConVarFloat(ultCooldownCvar),thisRaceID,ULT_RUPTURE,true,true);

							War3_EmitSoundToAll(ultsnd,client);

							War3_EmitSoundToAll(ultsnd,target);
							War3_EmitSoundToAll(ultsnd,target);
							PrintHintText(target,"You have been ruptured! You take damage if you move!");
							PrintHintText(client,"Rupture!");
						}
						else
						{
							War3_NotifyPlayerImmuneFromSkill(client, target, ULT_RUPTURE);
						}
					}
					else
					{
						W3MsgNoTargetFound(client,ultRange);
					}
				}
			}
			else
			{
				W3MsgUltNotLeveled(client);
			}
#if (GGAMETYPE == GGAME_TF2)
		}
		else
		{
			War3_ChatMessage(client,"You can not be cloaked or disguised while using Hemorrhage!");
		}
#endif
	}
}

stock clearvariables(client)
{
	bRuptured[client]=false;
	bCrazyDot[client]=false;
	RuptureUntil[client]=GetGameTime();
	bCrazyDot[client]=false;
}

public void OnWar3EventSpawn(int client)
{
	clearvariables(client);
}

public OnWar3EventDeath(victim,attacker){
	if(RaceDisabled)
		return;

	if(ValidPlayer(attacker,true)){
		if(War3_GetRace(attacker)==thisRaceID){
			new skill=War3_GetSkillLevel(attacker,thisRaceID,SKILL_FEAST);
			if(skill>0&&!Hexed(attacker,false)){
				War3_HealToMaxHP(attacker,RoundFloat(FloatMul(float(War3_GetMaxHP(victim)),FeastAmount[skill])));
				W3FlashScreen(attacker,RGBA_COLOR_GREEN,0.3,_,FFADE_IN);
			}
		}
	}
}

public Action:RuptureCheckLoop(Handle:h,any:data)
{
	new Float:origin[3];
	new attacker;
	new skilllevel;
	//new improvedskilllevel;
	//new Float:fImproved;
	new Float:dist;
	for(new i=1;i<=MaxClients;i++){

		if(ValidPlayer(i,true))
		{
			if(bRuptured[i])
			{
				attacker=RupturedBy[i];
				if(ValidPlayer(attacker))
				{

					Gore(i);
					skilllevel=War3_GetSkillLevel(attacker,thisRaceID,ULT_RUPTURE);
					//improvedskilllevel=War3_GetSkillLevel(attacker,thisRaceID,ULT_IMPROVED_RUPTURE);
					GetClientAbsOrigin(i,origin);
					dist=GetVectorDistance(origin,lastRuptureLocation[i]);

					new damage=RoundFloat(FloatMul(dist,ultiDamageMultiPerDistance[skilllevel]));
					if(damage>0)
					{
						if(War3_DealDamage(i,damage,attacker,_,"rupture",_,W3DMGTYPE_TRUEDMG))
						{
							/*
							if(improvedskilllevel>0)
							{
								fImproved=FloatMul(float(improvedskilllevel),0.10);
								fImproved=FloatMul(fImproved,float(damage));
								War3_HealToMaxHP(attacker, RoundToCeil(fImproved));
							}*/

							// both the same
							//DP("damage %d War3_GetWar3DamageDealt %d",damage,War3_GetWar3DamageDealt());
							War3_NotifyPlayerTookDamageFromSkill(i, attacker, damage, ULT_RUPTURE);
						}
#if (GGAMETYPE == GGAME_TF2)
						War3_TF_ParticleToClient(0, GetClientTeam(i)==2?"healthlost_red":"healthlost_blu", origin);
#endif
					}
					lastRuptureLocation[i][0]=origin[0];
					lastRuptureLocation[i][1]=origin[1];
					lastRuptureLocation[i][2]=origin[2];
					W3FlashScreen(i,RGBA_COLOR_RED,1.0,_,FFADE_IN);
				}
			}
			if(GetGameTime()>RuptureUntil[i])
			{
				bRuptured[i]=false;
			}
		}
	}
}
public Action:BloodCrazyDOTLoop(Handle:h,any:data)
{
	new attacker;
	for(new i=1;i<=MaxClients;i++)
	{
		if(ValidPlayer(i,true))
		{
			if(bCrazyDot[i])
			{
				attacker=CrazyBy[i];
				if(ValidPlayer(attacker,true) && GetClientTeam(i)!=GetClientTeam(attacker))
				{
					if(!W3HasImmunity(i,Immunity_Skills))
					{
						new damage=GetRandomInt(1, 3);
						if(War3_DealDamage(i,damage,attacker,_,"bleed_kill"))
						{
							War3_NotifyPlayerTookDamageFromSkill(i, attacker, damage, SKILL_CRAZY);
							//new String:iClientName1[32],String:iClientName2[32];
							//GetClientName(i,iClientName1,sizeof(iClientName1));
							//GetClientName(attacker,iClientName2,sizeof(iClientName2));
							//DP("%s (atk) did %d damage to %s (vic) with skill blood crazy",iClientName2,damage,iClientName1);
						}
						/*
						else
						{
							new String:iClientName1[32],String:iClientName2[32];
							GetClientName(i,iClientName1,sizeof(iClientName1));
							GetClientName(attacker,iClientName2,sizeof(iClientName2));
							DP("%s (atk) DAMAGE FAILED to %s (vic) with skill blood crazy",iClientName2,iClientName1);
						}*/
						new Float:pos[3];
						GetClientAbsOrigin(i,pos);
#if (GGAMETYPE == GGAME_TF2)
						War3_TF_ParticleToClient(0, GetClientTeam(i)==2?"healthlost_red":"healthlost_blu", pos);
#endif
					}
					else
					{
						War3_NotifyPlayerImmuneFromSkill(attacker, i, SKILL_CRAZY);
						bCrazyDot[i]=false;
					}
				}
				if(GetGameTime()>CrazyUntil[i])
				{
					bCrazyDot[i]=false;
				}
			}
		}
	}

}
public Action OnW3TakeDmgBulletPre(int victim, int attacker, float damage, int damagecustom)
{
	if(RaceDisabled)
		return;

	if(ValidPlayer(victim)&&ValidPlayer(attacker)&&victim!=attacker&&GetClientTeam(victim)!=GetClientTeam(attacker)){ //fixed blood hunter not respecting skill immunity - Dagothur 1/19/2013
#if (GGAMETYPE == GGAME_TF2)
		if(!W3IsOwnerSentry(attacker) && War3_GetRace(attacker)==thisRaceID&&!Hexed(attacker,false)){
#else
		if(War3_GetRace(attacker)==thisRaceID&&!Hexed(attacker,false)){
#endif
			new skilllevel=War3_GetSkillLevel(attacker,thisRaceID,SKILL_CRAZY);
			if(skilllevel>0 && !bCrazyDot[victim]){
				if(!W3HasImmunity(victim,Immunity_Skills))
				{
					bCrazyDot[victim]=true;
					CrazyBy[victim]=attacker;
					CrazyUntil[victim]=GetGameTime()+CrazyDuration[skilllevel];
				}
				else
				{
					War3_NotifyPlayerImmuneFromSkill(attacker, victim, SKILL_CRAZY);
				}
			}
			skilllevel=War3_GetSkillLevel(attacker,thisRaceID,SKILL_SENSE);
			if(skilllevel>0){
				if(FloatDiv(float(GetClientHealth(victim)),float(War3_GetMaxHP(victim)))<BloodSense[skilllevel]){
					if(!W3HasImmunity(victim,Immunity_Skills))
					{
						W3FlashScreen(victim,RGBA_COLOR_RED,0.3,_,FFADE_IN);
						War3_DamageModPercent(2.0);
						PrintToConsole(attacker,"Double Damage against low HP enemies!");
						War3_NotifyPlayerTookDamageFromSkill(victim, attacker, RoundToNearest(damage * 2), SKILL_SENSE);
					}
					else
					{
						War3_NotifyPlayerImmuneFromSkill(attacker, victim, SKILL_SENSE);
					}
				}
			}
		}
	}
}

public Gore(client){
	WriteParticle(client, "blood_spray_red_01_far");
	WriteParticle(client, "blood_impact_red_01");
}
WriteParticle(Ent, String:ParticleName[])
{

	//Declare:
	decl Particle;
	decl String:tName[64];

	//Initialize:
	Particle = CreateEntityByName("info_particle_system");

	//Validate:
	if(IsValidEdict(Particle))
	{

		//Declare:
		decl Float:Position[3], Float:Angles[3];

		//Initialize:
		Angles[0] = GetRandomFloat(0.0, 360.0);
		Angles[1] = GetRandomFloat(0.0, 15.0);
		Angles[2] = GetRandomFloat(0.0, 15.0);

		//Origin:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);
		Position[2] += GetRandomFloat(35.0, 65.0);
		TeleportEntity(Particle, Position, Angles, NULL_VECTOR);

		//Properties:
		GetEntPropString(Ent, Prop_Data, "m_iName", tName, sizeof(tName));
		StrCat(tName,63,"unambiguate");
		DispatchKeyValue(Particle, "targetname", "TF2Particle");
		DispatchKeyValue(Particle, "parentname", tName);
		DispatchKeyValue(Particle, "effect_name", ParticleName);

		//Spawn:
		DispatchSpawn(Particle);

		//Parent:
		//SetVariantString(tName);
		//AcceptEntityInput(Particle, "SetParent", -1, -1, 0);
		ActivateEntity(Particle);
		AcceptEntityInput(Particle, "start");

		//Delete:
		CreateTimer(6.0, DeleteParticle, Particle);
	}
}

//Delete:
public Action:DeleteParticle(Handle:Timer, any:Particle)
{

	//Validate:
	if(IsValidEntity(Particle))
	{

		//Declare:
		decl String:Classname[64];

		//Initialize:
		GetEdictClassname(Particle, Classname, sizeof(Classname));

		//Is a Particle:
		if(StrEqual(Classname, "info_particle_system", false))
		{

			//Delete:
			RemoveEdict(Particle);
		}
	}
}


//
#if (GGAMETYPE == GGAME_TF2)
public OnW3SupplyLocker(client)
{
	if(RaceDisabled)
		return;

	if(ValidPlayer(client))
	{
		clearvariables(client);
	}
}
#endif

public OnW3HealthPickup(const String:output[], caller, activator, Float:delay)
{
	if(RaceDisabled)
		return;

	if(ValidPlayer(activator))
	{
		clearvariables(activator);
	}
}
