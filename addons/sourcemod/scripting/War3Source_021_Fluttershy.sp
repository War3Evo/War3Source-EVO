#include <war3source>

#assert GGAMEMODE == MODE_WAR3SOURCE
#assert GGAMETYPE_JAILBREAK == JAILBREAK_OFF

#define RACE_ID_NUMBER 210

//#pragma semicolon 1

//#include <sourcemod>
//#include <tf2>
//#include <tf2_stocks>
//#include "W3SIncs/War3Source_Interface"


new thisRaceID;
public Plugin:myinfo =
{
	name = "Race - Fluttershy",
	author = "OwnageOwnz - RainbowDash",
	description = "",
	version = "0",
	url = "ownageclan.com"
};

bool HooksLoaded = false;
public void Load_Hooks()
{
	if(HooksLoaded) return;
	HooksLoaded = true;

	W3Hook(W3Hook_OnW3TakeDmgBulletPre, OnW3TakeDmgBulletPre);
	W3Hook(W3Hook_OnUltimateCommand, OnUltimateCommand);
	W3Hook(W3Hook_OnAbilityCommand, OnAbilityCommand);
}
public void UnLoad_Hooks()
{
	if(!HooksLoaded) return;
	HooksLoaded = false;

	W3UnhookAll(W3Hook_OnW3TakeDmgBulletPre);
	W3UnhookAll(W3Hook_OnUltimateCommand);
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

new SKILL_STARE,SKILL_TOLERATE,SKILL_KINDNESS,ULTIMATE_YOUBEGENTLE;
new AuraID;
new Float:HealingWaveDistance[5]={0.0,75.0,100.0,125.0,150.0};
new Float:starerange=300.0;
new Float:StareDuration[5]={0.0,1.5,2.0,2.5,3.0};
new Float:ArmorPhysical[5]={0.0,0.5,1.0,1.5,2.0};

new Float:HealAmount[5]={0.0,2.0,4.0,6.0,8.0};

bool AuraOwnerPlayer[MAXPLAYERSCUSTOM][MAXPLAYERSCUSTOM];

new Float:NotBadDuration[5]={0.0,1.0,1.3,1.6,1.8};
new bNoDamage[MAXPLAYERSCUSTOM];
public OnWar3LoadRaceOrItemOrdered2(num,reloadrace_id,String:shortname[])
{
	if(num==RACE_ID_NUMBER||(reloadrace_id>0&&StrEqual("fluttershy",shortname,false)))
	{
		thisRaceID=War3_CreateNewRace("[MLP:FIM] Fluttershy","fluttershy",reloadrace_id,"Armor,stare master");
		SKILL_STARE=War3_AddRaceSkill(thisRaceID,"Stare Master","Stare at target, 300 range, disarms and immobilizes you and target for 1.5-3 seconds\nCan not taunt kill on cooldown.",false,4);
		SKILL_TOLERATE=War3_AddRaceSkill(thisRaceID,"Tolerate","To 2 physical armor",false,4);
		SKILL_KINDNESS=War3_AddRaceSkill(thisRaceID,"Kindness","Heals you and your teammates when both of you are very close, up to 8HP per sec",false,4);

		ULTIMATE_YOUBEGENTLE=War3_AddRaceSkill(thisRaceID,"BeGentle","Target cannot deal damage for 1-1.8 seconds",true,4);
		War3_CreateRaceEnd(thisRaceID); ///DO NOT FORGET THE END!!!


		AuraID=W3RegisterChangingDistanceAura("fluttershy_healwave");
	}
}

public OnAllPluginsLoaded()
{
	//Load_Hooks();
	//LoadTranslations("w3s.race.fluttershy.phrases");
	War3_RaceOnPluginStart("fluttershy");
}

public OnPluginEnd()
{
	if(LibraryExists("RaceClass"))
		War3_RaceOnPluginEnd("fluttershy");
}

public void OnUltimateCommand(int client, int race, bool pressed, bool bypass)
{
	if(RaceDisabled)
		return;

	if(race==thisRaceID && pressed && ValidPlayer(client,true) )
	{
		new ult_level=War3_GetSkillLevel(client,race,ULTIMATE_YOUBEGENTLE);
		if(ult_level>0)
		{
			if(!Silenced(client)&&War3_SkillNotInCooldown(client,thisRaceID,ULTIMATE_YOUBEGENTLE,true))
			{
				new Float:breathrange=0.0;
				//War3_GetTargetInViewCone(client,Float:max_distance=0.0,bool:include_friendlys=false,Float:cone_angle=23.0,Function:FilterFunction=INVALID_FUNCTION);
				new target = War3_GetTargetInViewCone(client,breathrange,false,23.0,UltFilter,ULTIMATE_YOUBEGENTLE);
				//new Float:duration = DarkorbDuration[ult_level];
				if(target>0)
				{
					bNoDamage[target]=true;
					CreateTimer(NotBadDuration[ult_level],EndNotBad,target);
					PrintHintText(client,"You be gentle!");
					PrintHintText(target,"You be gentle!\nCannot deal bullet damage");
					War3_CooldownMGR(client,20.0,thisRaceID,ULTIMATE_YOUBEGENTLE);
				}
				else{
					W3MsgNoTargetFound(client,breathrange);
				}
			}
		}
	}
}
public Action:EndNotBad(Handle:t,any:client){
	bNoDamage[client]=false;
}
public Action OnW3TakeDmgBulletPre(int victim, int attacker, float damage, int damagecustom)
{
	//if(RaceDisabled)
		//return;

	if(ValidPlayer(attacker)&&bNoDamage[attacker]){
		War3_DamageModPercent(0.0);
	}

#if (GGAMETYPE == GGAME_TF2)
	//if(ValidPlayer(attacker) && War3_GetRace(attacker) && ValidPlayer(victim) && (W3GetBuffHasTrue(victim,bStunned)||W3GetBuffHasTrue(victim,bBashed)))
	if(ValidPlayer(attacker) && ValidPlayer(victim) && (War3_GetRace(attacker)==thisRaceID||War3_GetRace(victim)==thisRaceID) && (!War3_SkillNotInCooldown(attacker,thisRaceID,SKILL_STARE,false)||!War3_SkillNotInCooldown(victim,thisRaceID,SKILL_STARE,false)))
	{
		switch (damagecustom)
		{
			case TF_CUSTOM_TAUNT_HADOUKEN, TF_CUSTOM_TAUNT_HIGH_NOON, TF_CUSTOM_TAUNT_GRAND_SLAM, TF_CUSTOM_TAUNT_FENCING,
			TF_CUSTOM_TAUNT_ARROW_STAB, TF_CUSTOM_TAUNT_GRENADE, TF_CUSTOM_TAUNT_BARBARIAN_SWING,
			TF_CUSTOM_TAUNT_UBERSLICE, TF_CUSTOM_TAUNT_ENGINEER_SMASH, TF_CUSTOM_TAUNT_ENGINEER_ARM, TF_CUSTOM_TAUNT_ARMAGEDDON:
			{
				War3_DamageModPercent(0.0);
				//PrintToChatAll("taunt killer %d victim %d",attacker, victim);
				CreateTimer(0.1,EndTauntkill,attacker);
			}
		}
	}
#endif
}

public Action:EndTauntkill(Handle:t,any:client)
{
	FakeClientCommand(client, "kill");
}

new StareVictim[MAXPLAYERSCUSTOM];

public void OnAbilityCommand(int client, int ability, bool pressed, bool bypass)
{
	if(RaceDisabled)
		return;

	if(ValidPlayer(client,true),War3_GetRace(client)==thisRaceID && ability==0 && pressed )
	{
		if(!Silenced(client)&&War3_SkillNotInCooldown(client,thisRaceID,SKILL_STARE,true))
		{
			new skilllvl = War3_GetSkillLevel(client,thisRaceID,SKILL_STARE);
			if(skilllvl > 0)
			{
				//stare
				new target=War3_GetTargetInViewCone(client,starerange,_,_,SkillFilter,SKILL_STARE);
				if(ValidPlayer(target,true)){
					////
					//bash both players
					War3_SetBuff(client,bBashed,thisRaceID,true,client);
					War3_SetBuff(client,bDisarm,thisRaceID,true,client);
					War3_SetBuff(target,bBashed,thisRaceID,true,client);
					War3_SetBuff(target,bDisarm,thisRaceID,true,client);
					PrintHintText(client,"STOP AND STARE");
					PrintHintText(target,"You are being stared at.\nDon't look at her in the eye!!!");
					CreateTimer(StareDuration[skilllvl],EndStare,client);
					StareVictim[client]=target;
					War3_CooldownMGR(client,15.0,thisRaceID,SKILL_STARE);
				}
				else{
					W3MsgNoTargetFound(client,starerange);
				}
			}
		}
	}
}

public Action:EndStare(Handle:t,any:client){
	War3_SetBuff(client,bBashed,thisRaceID,false);
	War3_SetBuff(client,bDisarm,thisRaceID,false);
	War3_SetBuff(StareVictim[client],bBashed,thisRaceID,false);
	War3_SetBuff(StareVictim[client],bDisarm,thisRaceID,false);
	StareVictim[client]=0;
}

// May wish to revise this below to use StareVictim[client] to check and see if that person was affected
// then call it manually.

public OnWar3EventDeath(client){ //end stare if fluttershy dies
	if(ValidPlayer(client))
	{
		War3_SetBuff(client,bBashed,thisRaceID,false);
		War3_SetBuff(client,bDisarm,thisRaceID,false);
		War3_SetBuff(StareVictim[client],bBashed,thisRaceID,false);
		War3_SetBuff(StareVictim[client],bDisarm,thisRaceID,false);
		StareVictim[client]=0;
	}

	LoopMaxClients(target)
	{
		if(AuraOwnerPlayer[client][target])
		{
			AuraOwnerPlayer[client][target]=false;
			War3_SetBuff(target,fHPRegen,thisRaceID,0.0);
		}
	}
}





/* ***************************  OnRaceChanged *************************************/

public OnRaceChanged(client,oldrace,newrace)
{
		if(newrace==thisRaceID)
		{
			//InitPassiveSkills(client);
			int skill_level=War3_GetSkillLevel(client,thisRaceID,SKILL_TOLERATE);
			if(skill_level>0)
			{
				War3_SetBuff(client,fArmorPhysical,thisRaceID,ArmorPhysical[skill_level]);
			}
			skill_level=War3_GetSkillLevel(client,thisRaceID,SKILL_KINDNESS);
			if(skill_level>0)
			{
				W3SetPlayerAura(AuraID,client,HealingWaveDistance[skill_level],skill_level);
			}
			else
			{
				W3RemovePlayerAura(AuraID,client);
				War3_SetBuff(client,fHPRegen,thisRaceID,0.0);
			}
		}
		else
		{
			W3RemovePlayerAura(AuraID,client);
			War3_SetBuff(client,fHPRegen,thisRaceID,0.0);
		}
}


public void OnSkillLevelChanged(int client, int currentrace, int skill, int newskilllevel, int oldskilllevel)
{
	if(RaceDisabled)
		return;

	if(currentrace==thisRaceID)
	{
		if(skill==SKILL_TOLERATE)
		{
			War3_SetBuff(client,fArmorPhysical,thisRaceID,ArmorPhysical[newskilllevel]);
		}
		if(skill==SKILL_KINDNESS) //1
		{
			if(newskilllevel>0)
			{
				W3SetPlayerAura(AuraID,client,HealingWaveDistance[newskilllevel],newskilllevel);
			}
			else
			{
				W3RemovePlayerAura(AuraID,client);
				War3_SetBuff(client,fHPRegen,thisRaceID,0.0);
			}
		}
	}
}

public OnClientDisconnect(client)
{
	LoopMaxClients(target)
	{
		if(AuraOwnerPlayer[client][target])
		{
			AuraOwnerPlayer[client][target]=false;
			War3_SetBuff(target,fHPRegen,thisRaceID,0.0);
		}
	}
}

public OnW3PlayerAuraStateChanged(client,aura,bool:inAura,level,AuraStack,AuraOwner)
{
	if(aura==AuraID)
	{
		if(inAura)
		{
			if(AuraStack>0)
			{
				//float StackBuff=FloatMul(float(AuraStack),HealAmount[level]);
				char iClientName1[32];
				GetClientName(client,iClientName1,sizeof(iClientName1));
				//PrintToChatAll("%s now has regen from aura of %.2f",iClientName1,HealAmount[level]);
				War3_SetBuff(client,fHPRegen,thisRaceID,HealAmount[level]);
				AuraOwnerPlayer[AuraOwner][client]=true;
			}
			else
			{
				char iClientName1[32];
				GetClientName(client,iClientName1,sizeof(iClientName1));
				//PrintToChatAll("%s now has no regen from aura.",iClientName1);
				War3_SetBuff(client,fHPRegen,thisRaceID,0.0);
				AuraOwnerPlayer[AuraOwner][client]=false;
			}
		}
		else
		{
			char iClientName1[32];
			GetClientName(client,iClientName1,sizeof(iClientName1));
			//PrintToChatAll("%s now has no regen from aura.",iClientName1);
			War3_SetBuff(client,fHPRegen,thisRaceID,0.0);
			AuraOwnerPlayer[AuraOwner][client]=false;
		}
	}
}
/*
public void OnWar3Event(W3EVENT event,int client){
	if(event==OnAuraCalculationFinished){
		RecalculateHealing();
	//	DP("re");
	}
}
RecalculateHealing(){
	new level;
	new playerlist[66];
	new auralevel[66];
	new auraactivated[66];
	new playercount=0;

	for(new client=1;client<=MaxClients;client++)
	{
		if(ValidPlayer(client,true)&&W3HasAura(AuraID,client,level)){
			for(new i=0;i<playercount;i++){
				if(GetPlayerDistance(playerlist[i],client)<HealingWaveDistance){
					auraactivated[playercount]++;
					auraactivated[i]++;
				}
			}

			playerlist[playercount]=client;
			auralevel[playercount]=level;
			playercount++;
		}

	}
	for(new i=0;i<playercount;i++){
		if(auraactivated[i]){
			//DP("client %d %f",playerlist[i],HealAmount[auralevel[i]]);
			War3_SetBuff(playerlist[i],fHPRegen,thisRaceID,HealAmount[auralevel[i]]);
		}
		else{
			//DP("client %d disabled due to no neighbords",playerlist[i]);
			War3_SetBuff(playerlist[i],fHPRegen,thisRaceID,0.0);
		}
	}
}
*/
