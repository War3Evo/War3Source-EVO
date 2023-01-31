#include <war3source>
#assert GGAMEMODE == MODE_WAR3SOURCE

#define RACE_ID_NUMBER 6

/**
 *
 * Description:   SR FROM HON
 * Author(s): Ownz (DarkEnergy) and pimpjuice
 */

//#pragma semicolon 1

//#include <sourcemod>
//#include "W3SIncs/War3Source_Interface"
//#include <sdktools>
//#include <sdktools_functions>
//#include <sdktools_tempents>
//#include <sdktools_tempents_stocks>
//#include <cstrike>

public W3ONLY(){} //unload this?
new thisRaceID;
new Handle:ultCooldownCvar;

new SKILL_JUDGE, SKILL_PRESENCE,SKILL_INHUMAN, ULT_EXECUTE;


// Chance/Data Arrays
new JudgementAmount[5]={0,10,20,30,40};
new Float:JudgementCooldownTime=10.0;
new Float:JudgementRange=400.0;

new Float:PresenseAmount[5]={0.0,0.5,1.0,1.5,2.0};
new Float:PresenceRange[5]={0.0,100.0,200.0,300.0,400.0};

new InhumanAmount[5]={0,5,10,15,20};
new Float:InhumanRange=400.0;

new Float:ultRange=300.0;
new Float:ultiDamageMulti[5]={0.0,0.4,0.6,0.8,1.0};

new String:judgesnd[]="war3source/sr/judgement.mp3";
new String:ultsnd[]="war3source/sr/ult.mp3";

new AuraID;

public Plugin:myinfo =
{
	name = "Race - Soul Reaper",
	author = "Ownz (DarkEnergy)",
	description = "Soul Reaper for War3Source.",
	version = "1.0",
	url = "War3Source.com"
};

ResetDecay()
{
	for(new client=1;client<=MaxClients;client++)
	{
		if(ValidPlayer(client))
		{
			War3_SetBuff(client,fHPDecay,thisRaceID,0.0);
		}
	}
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
	HookEvent("player_death",PlayerDeathEvent);

	ultCooldownCvar=CreateConVar("war3_sr_ult_cooldown","20","Cooldown time for CD ult overload.");

	//LoadTranslations("w3s.race.sr.phrases");
}
public OnAllPluginsLoaded()
{
	War3_RaceOnPluginStart("sr");
}

public OnPluginEnd()
{
	if(LibraryExists("RaceClass"))
		War3_RaceOnPluginEnd("sr");
}

public OnWar3LoadRaceOrItemOrdered2(num,reloadrace_id,String:shortname[])
{
	if(num==RACE_ID_NUMBER||(reloadrace_id>0&&StrEqual("sr",shortname,false)))
	{
		thisRaceID=War3_CreateNewRace("Soul Reaper","sr",reloadrace_id,"Judgement,Execution");
		SKILL_JUDGE=War3_AddRaceSkill(thisRaceID,"Judgement","[+ability] Heals teammates around you, damages enemies around you",false,4);
		SKILL_PRESENCE=War3_AddRaceSkill(thisRaceID,"Withering Presence","Enemies take non-lethal damage just by being within 10/20/30/40 feet of you.",false,4);
		SKILL_INHUMAN=War3_AddRaceSkill(thisRaceID,"Inhuman Nature","You heal when anyone around you dies",false,4);
		ULT_EXECUTE=War3_AddRaceSkill(thisRaceID,"Demonic Execution","(+ultimate) Deals a large amount of damage based on how much of the enemy's health is missing",true,4);
		War3_CreateRaceEnd(thisRaceID);

		AuraID=W3RegisterChangingDistanceAura("witheringpresense",true);

		// Possible replacement if needed?
		//War3_AddAuraSkillBuff(thisRaceID, SKILL_PRESENCE, fHPDecay, PresenseAmount,
		//					  "witheringpresense", PresenceRange,
		//					  true);
	}
}

//public OnMapStart()
//{
	//War3_PrecacheSound(judgesnd);
	//War3_PrecacheSound(ultsnd);
//}

public OnAddSound(sound_priority)
{
	if(sound_priority==PRIORITY_MEDIUM)
	{
		War3_AddSound(judgesnd);
		War3_AddSound(ultsnd);
	}
}


public void OnAbilityCommand(int client, int ability, bool pressed, bool bypass)
{
	if(RaceDisabled)
		return;

	if(War3_GetRace(client)==thisRaceID && ability==0 && pressed && IsPlayerAlive(client))
	{
		new skill_level=War3_GetSkillLevel(client,thisRaceID,SKILL_JUDGE);
		if(skill_level>0)
		{

			if(!Silenced(client)&&(bypass||War3_SkillNotInCooldown(client,thisRaceID,SKILL_JUDGE,true)))
			{
				new amount=JudgementAmount[skill_level];

				new Float:playerOrigin[3];
				GetClientAbsOrigin(client,playerOrigin);

				new team = GetClientTeam(client);
				new Float:otherVec[3];
				for(new i=1;i<=MaxClients;i++){
					if(ValidPlayer(i,true)){
						GetClientAbsOrigin(i,otherVec);
						if(GetVectorDistance(playerOrigin,otherVec)<JudgementRange)
						{
							if(GetClientTeam(i)==team){
								War3_HealToMaxHP(i,amount);
							}
							else{
								if(War3_DealDamage(i,amount,client,DMG_BURN,"judgement",W3DMGORIGIN_SKILL))
								{
									War3_NotifyPlayerTookDamageFromSkill(i, client, War3_GetWar3DamageDealt(), SKILL_JUDGE);
								}
								else
								{
									War3_NotifyPlayerImmuneFromSkill(client, i, SKILL_JUDGE);
								}
							}

						}
					}
				}
				PrintHintText(client,"+/- %d HP",amount);
				War3_EmitSoundToAll(judgesnd,client);
				//War3_EmitSoundToAll(judgesnd,client);
				War3_CooldownMGR(client,JudgementCooldownTime,thisRaceID,SKILL_JUDGE,true,true);

			}
		}
	}
}


public void OnUltimateCommand(int client, int race, bool pressed, bool bypass)
{
	if(RaceDisabled)
		return;

	if(race==thisRaceID && pressed && IsPlayerAlive(client))
	{
		//if(

		new skill=War3_GetSkillLevel(client,race,ULT_EXECUTE);
		if(skill>0)
		{
			if(!Silenced(client)&&(bypass||War3_SkillNotInCooldown(client,thisRaceID,ULT_EXECUTE,true)))
			{
				new target=War3_GetTargetInViewCone(client,ultRange,false);
				if(ValidPlayer(target,true))
				{
					if(!W3HasImmunity(target,Immunity_Ultimates))
					{
						new hpmissing=War3_GetMaxHP(target)-GetClientHealth(target);

						new dmg=RoundFloat(FloatMul(float(hpmissing),ultiDamageMulti[skill]));

						if(War3_DealDamage(target,dmg,client,_,"demonicexecution"))
						{
							//PrintToConsole(client,"Executed for %d damage",War3_GetWar3DamageDealt());
							War3_NotifyPlayerTookDamageFromSkill(target, client, War3_GetWar3DamageDealt(), ULT_EXECUTE);
							War3_CooldownMGR(client,GetConVarFloat(ultCooldownCvar),thisRaceID,ULT_EXECUTE,true,true);

							War3_EmitSoundToAll(ultsnd,client);

							War3_EmitSoundToAll(ultsnd,target);
						}
					}
					else
					{
						War3_NotifyPlayerImmuneFromSkill(client, target, ULT_EXECUTE);
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
	}
}



CheckAura(client){
	new level=War3_GetSkillLevel(client,thisRaceID,SKILL_PRESENCE);
	if(level>0)
	{
		W3SetPlayerAura(AuraID,client,PresenceRange[level],level);
	}
	else
	{
		W3RemovePlayerAura(AuraID,client);
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
	CheckAura(client);
}

public RemovePassiveSkills(client)
{
	//War3_SetBuff(client,fArmorPhysical,thisRaceID,0.0);
	ResetDecay();
	W3RemovePlayerAura(AuraID,client);
}

public void OnSkillLevelChanged(int client, int currentrace, int skill, int newskilllevel, int oldskilllevel)
{
	if(RaceDisabled)
		return;

	if(currentrace==thisRaceID)
	{
		if(skill==SKILL_PRESENCE) //1
		{
			if(newskilllevel>0)
			{
				W3SetPlayerAura(AuraID,client,PresenceRange[newskilllevel],newskilllevel);
			}
			else
			{
				W3RemovePlayerAura(AuraID,client);
			}
		}
	}
}

public PlayerDeathEvent(Handle:event,const String:name[],bool:dontBroadcast)
{
	if(RaceDisabled)
		return;

	new userid=GetEventInt(event,"userid");
	new victim=GetClientOfUserId(userid);

	if(victim>0)
	{
		new Float:deathvec[3];
		GetClientAbsOrigin(victim,deathvec);

		new Float:gainhpvec[3];

		for(new client=1;client<=MaxClients;client++)
		{
			if(ValidPlayer(client,true)&&War3_GetRace(client)==thisRaceID){
				GetClientAbsOrigin(client,gainhpvec);
				if(GetVectorDistance(deathvec,gainhpvec)<InhumanRange){
					new skilllevel=War3_GetSkillLevel(client,thisRaceID,SKILL_INHUMAN);
					if(skilllevel>0&&!Hexed(client)){
						War3_HealToMaxHP(client,InhumanAmount[skilllevel]);
					}
				}
			}
		}
		//new deathFlags = GetEventInt(event, "death_flags");
	// where is the list of flags? idksee firefox
		//if (deathFlags & 32)
		//{
		   //PrintToChat(client,"war3 debug: dead ringer kill");
		//}


	}
}

public OnW3PlayerAuraStateChanged(client,aura,bool:inAura,level,AuraStack,AuraOwner)
{
	if(RaceDisabled)
		return;

	if(aura==AuraID)
	{
		/*
		if(inAura)
		{
			new String:StrOwner[128];
			GetClientName(AuraOwner,StrOwner,sizeof(StrOwner));
			new String:Strclient[128];
			GetClientName(client,Strclient,sizeof(Strclient));
			DP("Client %s is in Aura - true - Aura Owner %s",Strclient,StrOwner);
		}
		else
		{
			new String:StrOwner[128];
			GetClientName(AuraOwner,StrOwner,sizeof(StrOwner));
			new String:Strclient[128];
			GetClientName(client,Strclient,sizeof(Strclient));
			DP("Client %s is Not in Aura - false - Aura Owner %s",Strclient,StrOwner);
		}*/
		if(AuraStack>0 && inAura)
		{
			if(!W3HasImmunity(client,Immunity_Skills))
			{
				new Float:StackBuff=FloatMul(float(AuraStack),PresenseAmount[level]);
				War3_SetBuff(client,fHPDecay,thisRaceID,StackBuff,AuraOwner);
			}
			else
			{
				War3_SetBuff(client,fHPDecay,thisRaceID,0.0);
				War3_NotifyPlayerImmuneFromSkill(AuraOwner, client, SKILL_PRESENCE);
			}
		}
		else
		{
			War3_SetBuff(client,fHPDecay,thisRaceID,0.0);
		}
	}
}
