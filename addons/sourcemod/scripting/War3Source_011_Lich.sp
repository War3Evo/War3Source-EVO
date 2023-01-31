#include <war3source>
#assert GGAMEMODE == MODE_WAR3SOURCE

#define RACE_ID_NUMBER 11

/**
 * File: War3Source_Lich.sp
 * Description: The Lich race for War3Source.
 * Author(s): [Oddity]TeacherCreature
 */

//#pragma semicolon 1

//#include <sourcemod>
//#include "W3SIncs/War3Source_Interface"
//#include <sdktools>
//#include <sdktools_functions>
//#include <sdktools_tempents>
//#include <sdktools_tempents_stocks>

new thisRaceID;

new SKILL_FROSTNOVA,SKILL_FROSTARMOR,SKILL_DARKRITUAL,ULT_DEATHDECAY;

//skill 1
new Float:FrostNovaArr[]={1.0,0.95,0.9,0.85,0.8,0.75};
new Float:FrostNovaRadius=500.0;
new FrostNovaLoopCountdown[MAXPLAYERSCUSTOM];
new bool:HitOnForwardTide[MAXPLAYERSCUSTOM][MAXPLAYERSCUSTOM]; //[VICTIM][ATTACKER]
new Float:FrostNovaOrigin[MAXPLAYERSCUSTOM][3];
new Float:AbilityCooldownTime=10.0;

//skill 2
new Float:FrostArmorAmount[]={0.0,1.0,2.0,3.0,4.0};

//skill 3
new DarkRitualAmt[]={0,1,2,3,4};

//ultimate
new Handle:ultCooldownCvar;
new Handle:ultRangeCvar;
new DeathDecayAmt[]={0,2,4,6,8};
new String:ultsnd[]="npc/antlion/attack_single2.wav";
new String:novasnd[]="npc/combine_gunship/ping_patrol.wav";
new BeamSprite,HaloSprite;

public Plugin:myinfo =
{
	name = "Race - Lich",
	author = "[Oddity]TeacherCreature",
	description = "The Lich race for War3Source.",
	version = "1.0.0.0",
	url = "warcraft-source.net"
}

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


public OnPluginStart()
{

	ultCooldownCvar=CreateConVar("war3_lich_deathdecay_cooldown","30","Cooldown between ultimate usage");
	ultRangeCvar=CreateConVar("war3_lich_deathdecay_range","99999","Range of death and decay ultimate");

	//LoadTranslations("w3s.race.lich_o.phrases");
}
public OnAllPluginsLoaded()
{
	War3_RaceOnPluginStart("lich_o");
}

public OnPluginEnd()
{
	if(LibraryExists("RaceClass"))
		War3_RaceOnPluginEnd("lich_o");
}

public OnWar3LoadRaceOrItemOrdered2(num,reloadrace_id,String:shortname[])
{
	if(num==RACE_ID_NUMBER||(reloadrace_id>0&&StrEqual("lich_o",shortname,false)))
	{
		thisRaceID=War3_CreateNewRace("Lich","lich_o",reloadrace_id,"Armor,slow enemy");
		SKILL_FROSTNOVA=War3_AddRaceSkill(thisRaceID,"Frost Nova","(+ability) Reduces your enemies' movespeed and attack speed \nSlows by 5-25%% and reduces attack speed by 5-25%%.\n500 range",false,4);
		SKILL_FROSTARMOR=War3_AddRaceSkill(thisRaceID,"Frost Armor","Increases your physical and magic armor by 1/2/3/4",false,4);
		SKILL_DARKRITUAL=War3_AddRaceSkill(thisRaceID,"Dark Ritual","You gain 1/2/3/4 heath from the sacrifice of teammates",false,4);
		ULT_DEATHDECAY=War3_AddRaceSkill(thisRaceID,"Death And Decay","Deals 2/4/6/8 magic damage to all enemies on map",true,4);
		War3_CreateRaceEnd(thisRaceID);

		War3_AddSkillBuff(thisRaceID, SKILL_FROSTARMOR, fArmorPhysical, FrostArmorAmount);
		War3_AddSkillBuff(thisRaceID, SKILL_FROSTARMOR, fArmorMagic, FrostArmorAmount);
	}

}

public OnMapStart()
{

	//War3_PrecacheSound(ultsnd);
	//War3_PrecacheSound(novasnd);
	BeamSprite=War3_PrecacheBeamSprite();
	HaloSprite=War3_PrecacheHaloSprite();
}

public OnAddSound(sound_priority)
{
	if(sound_priority==PRIORITY_MEDIUM)
	{
		War3_AddSound(ultsnd,STOCK_SOUND);
	}
	if(sound_priority==PRIORITY_TOP)
	{
		War3_AddSound(novasnd,STOCK_SOUND);
	}
}

public void OnAbilityCommand(int client, int ability, bool pressed, bool bypass)
{
	if(RaceDisabled)
		return;

	if(War3_GetRace(client)==thisRaceID && ability==0 && pressed && IsPlayerAlive(client))
	{
		new skill_level=War3_GetSkillLevel(client,thisRaceID,SKILL_FROSTNOVA);
		if(skill_level>0)
		{
			if(!Silenced(client)&&(bypass||War3_SkillNotInCooldown(client,thisRaceID,SKILL_FROSTNOVA,true)))
				{

					War3_EmitSoundToAll(novasnd,client);
					GetClientAbsOrigin(client,FrostNovaOrigin[client]);
					FrostNovaOrigin[client][2]+=15.0;
					FrostNovaLoopCountdown[client]=20;

					for(new i=1;i<=MaxClients;i++){
						HitOnForwardTide[i][client]=false;
					}

					TE_SetupBeamRingPoint(FrostNovaOrigin[client], 1.0, 650.0, BeamSprite, HaloSprite, 0, 5, 1.0, 50.0, 1.0, {0,0,255,255}, 50, 0);
					War3_TE_SendToAll();

					CreateTimer(0.1,BurnLoop,client); //damage
					CreateTimer(0.13,BurnLoop,client); //damage
					CreateTimer(0.17,BurnLoop,client); //damage


					War3_CooldownMGR(client,AbilityCooldownTime,thisRaceID,SKILL_FROSTNOVA,_,_);
					//War3_EmitSoundToAll(taunt1,client);//,_,SNDLEVEL_TRAIN);
					//War3_EmitSoundToAll(taunt1,client);//,_,SNDLEVEL_TRAIN);
					//War3_EmitSoundToAll(taunt2,client);

					PrintHintText(client,"Frost Nova!");

			}
		}
	}
}

public Action:BurnLoop(Handle:timer,any:attacker)
{

	if(ValidPlayer(attacker) && FrostNovaLoopCountdown[attacker]>0)
	{
		new team = GetClientTeam(attacker);
		//War3_DealDamage(victim,damage,attacker,DMG_BURN);
		CreateTimer(0.1,BurnLoop,attacker);

		new Float:hitRadius=(1.0-FloatAbs(float(FrostNovaLoopCountdown[attacker])-10.0)/10.0)*FrostNovaRadius;

		//PrintToChatAll("distance to damage %f",hitRadius);

		FrostNovaLoopCountdown[attacker]--;

		new Float:otherVec[3];
		for(new i=1;i<=MaxClients;i++)
		{
			if(ValidPlayer(i,true)&&GetClientTeam(i)!=team)
			{
					if(HitOnForwardTide[i][attacker]==true){
						continue;
					}


					GetClientAbsOrigin(i,otherVec);
					//otherVec[2]+=30.0;
					new Float:victimdistance=GetVectorDistance(FrostNovaOrigin[attacker],otherVec);
					if(victimdistance<FrostNovaRadius&&FloatAbs(otherVec[2]-FrostNovaOrigin[attacker][2])<50)
					{
						if(FloatAbs(victimdistance-hitRadius)<(FrostNovaRadius/10.0))
						{
							if(!W3HasImmunity(i,Immunity_Skills))
							{

								HitOnForwardTide[i][attacker]=true;
								//War3_DealDamage(i,RoundFloat(FrostNovaMaxDamage[War3_GetSkillLevel(attacker,thisRaceID,SKILL_FROSTNOVA)]*victimdistance/FrostNovaRadius/2.0),attacker,DMG_ENERGYBEAM,"FrostNova");
								War3_SetBuff(i,fSlow,thisRaceID,FrostNovaArr[War3_GetSkillLevel(attacker,thisRaceID,SKILL_FROSTNOVA)],attacker);
								War3_SetBuff(i,fAttackSpeed,thisRaceID,FrostNovaArr[War3_GetSkillLevel(attacker,thisRaceID,SKILL_FROSTNOVA)],attacker);
								CreateTimer(5.0,RemoveFrostNova,i);
								PrintHintText(i,"You were slowed by frost nova!");
							}
							else
							{
								War3_NotifyPlayerImmuneFromSkill(attacker, i, SKILL_FROSTNOVA);
							}
						}
					}
			}
		}
	}
}


public Action:RemoveFrostNova(Handle:t,any:client){
	War3_SetBuff(client,fSlow,thisRaceID,1.0);
	War3_SetBuff(client,fAttackSpeed,thisRaceID,1.0);
}

/*
public Action OnW3TakeDmgBullet(int victim, int attacker, float damage)
{

	if(War3_GetRace(victim)==thisRaceID&&ValidPlayer(attacker,true))
	{
		if(GetClientTeam(victim)!=GetClientTeam(attacker))
		{
			new Float:chance_mod=W3ChanceModifier(attacker);
			new skill_frostarmor=War3_GetSkillLevel(victim,thisRaceID,SKILL_FROSTARMOR);
			if(skill_frostarmor>0)
			{
				if(GetRandomFloat(0.0,1.0)<=FrostArmorChance[skill_frostarmor]*chance_mod && !W3HasImmunity(attacker,Immunity_Skills))
				{
					War3_SetBuff(attacker,fAttackSpeed,thisRaceID,0.5);
					PrintHintText(attacker,"Frost Armor slows you");
					PrintHintText(victim,"Frost Armor slows your attacker");
					W3FlashScreen(attacker,RGBA_COLOR_BLUE,0.5,0.4,FFADE_IN);
					CreateTimer(2.0,farmor,attacker);
				}
			}
		}
	}
}

public Action: farmor(Handle:timer,any:attacker)
{
	War3_SetBuff(attacker,fAttackSpeed,thisRaceID,1.0);
}
*/
public OnWar3EventDeath(victim,attacker)
{
	new team;
	if(ValidPlayer(victim)){
		team=GetClientTeam(victim);
	}
	for(new i=1;i<=MaxClients;i++)
	{
		if(War3_GetRace(i)==thisRaceID)
		{

			if(ValidPlayer(i,true)&&GetClientTeam(i)==team)
			{
				new skill=War3_GetSkillLevel(i,thisRaceID,SKILL_DARKRITUAL);
				if(skill>0 && !Silenced(i))
				{
					new hpadd=DarkRitualAmt[skill];
#if GGAMETYPE == GGAME_TF2
					SetEntityHealth(i,GetClientHealth(i)+hpadd);
#elseif (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
					War3_HealToMaxHP(i,hpadd);
#endif
					//War3_HealToMaxHP(i,RoundFloat(FloatMul(float(War3_GetMaxHP(i)),float(DarkRitualAmt[skill]))));
					W3FlashScreen(i,RGBA_COLOR_GREEN,0.5,0.5,FFADE_IN);
					PrintHintText(i,"Dark Ritual heals you");
				}
			}
		}
	}
}

public void OnUltimateCommand(int client, int race, bool pressed, bool bypass)
{
	if(RaceDisabled)
		return;

	new userid=GetClientUserId(client);
	if(race==thisRaceID && pressed && userid>1 && IsPlayerAlive(client) )
	{
		new ult_level=War3_GetSkillLevel(client,race,ULT_DEATHDECAY);
		if(ult_level>0)
		{
			if(bypass||War3_SkillNotInCooldown(client,thisRaceID,ULT_DEATHDECAY,true))
			{
				if(!Silenced(client))
				{
					new Float:posVec[3];
					GetClientAbsOrigin(client,posVec);
					new Float:otherVec[3];
					new team = GetClientTeam(client);
					new maxtargets=15;
					new targetlist[MAXPLAYERSCUSTOM];
					new targetsfound=0;
					new Float:ultmaxdistance=GetConVarFloat(ultRangeCvar);
					for(new i=1;i<=MaxClients;i++)
					{
						if(ValidPlayer(i,true)&&GetClientTeam(i)!=team)
						{
							GetClientAbsOrigin(i,otherVec);
							new Float:dist=GetVectorDistance(posVec,otherVec);
							if(dist<ultmaxdistance)
							{
								if(!W3HasImmunity(i,Immunity_Ultimates))
								{
									targetlist[targetsfound]=i;
									targetsfound++;
									if(targetsfound>=maxtargets){
										break;
									}
								}
								else
								{
									War3_NotifyPlayerImmuneFromSkill(client, i, ULT_DEATHDECAY);
								}
							}
						}
					}
					if(targetsfound==0)
					{
						W3MsgNoTargetFound(client,ultmaxdistance);
					}
					else
					{
						new damage=DeathDecayAmt[ult_level];
						new damagedealt;
						for(new i=0;i<targetsfound;i++)
						{
							new victim=targetlist[i];
							if(War3_DealDamage(victim,damage,client,DMG_BULLET,"Death and Decay")) //default magic
							{
								damagedealt+=War3_GetWar3DamageDealt();
								W3FlashScreen(victim,RGBA_COLOR_RED);
								//PrintHintText(victim,"Attacked by Death and Decay");
								War3_NotifyPlayerTookDamageFromSkill(victim, client, War3_GetWar3DamageDealt(), ULT_DEATHDECAY);
							}
						}
						PrintHintText(client,"Death and Decay attacked for %i total damage!",damage*targetsfound);
						War3_CooldownMGR(client,GetConVarFloat(ultCooldownCvar),thisRaceID,ULT_DEATHDECAY,false,_);
						War3_EmitSoundToAll(ultsnd,client);
					}
				}

			}
		}
		else
		{
			W3MsgUltNotLeveled(client);
		}
	}
}

