//War3Source_029_Martyr_EXTRA.sp

#include <war3source>

#assert GGAMEMODE == MODE_WAR3SOURCE

#define RACE_ID_NUMBER 290


int thisRaceID;

int AuraID;

bool TakeDamageAuraOwner[MAXPLAYERSCUSTOM];

float AuraDistance[5]={0.0,30.0,40.0,50.0,60.0};
float ModifyDamage[5]={0.0,0.85,0.70,0.55,0.40};

//float Renewal[5]={0.0,1.25,1.50,1.75,2.0};

float TakeMoreDamage[5]={0.0,-1.0,-2.0,-3.0,-4.0};

float Altruist[5]={0.0,0.03,0.06,0.09,0.12};

float Purification[5]={0.0,0.10,0.20,0.30,0.60};

int BloodPact[5]={0,10,20,30,40};

bool MyAura[MAXPLAYERSCUSTOM][MAXPLAYERSCUSTOM];

int PurificationTarget[MAXPLAYERSCUSTOM];

//new SKILL_SACRIFICE,ABILITY_BLOOD_PACT,SKILL_BLOOD_RENEWAL,SKILL_ALTRUIST,ULT_PURIFICATION;
int SKILL_SACRIFICE,ABILITY_BLOOD_PACT,SKILL_ALTRUIST,ULT_PURIFICATION;

public Plugin:myinfo =
{
	name = "Race - Halforc",
	author = "El Diablo",
	description = "Halforc",
	version = "1.0",
	url = "http://war3evo.info"
};

bool HooksLoaded = false;
public void Load_Hooks()
{
	if(HooksLoaded) return;
	HooksLoaded = true;

	W3Hook(W3Hook_OnW3TakeDmgAllPre, OnW3TakeDmgAllPre);
	W3Hook(W3Hook_OnW3TakeDmgBullet, OnW3TakeDmgBullet);
	W3Hook(W3Hook_OnUltimateCommand, OnUltimateCommand);
	W3Hook(W3Hook_OnAbilityCommand, OnAbilityCommand);
}
public void UnLoad_Hooks()
{
	if(!HooksLoaded) return;
	HooksLoaded = false;

	W3UnhookAll(W3Hook_OnW3TakeDmgAllPre);
	W3UnhookAll(W3Hook_OnW3TakeDmgBullet);
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

public OnAllPluginsLoaded()
{
	War3_RaceOnPluginStart("martyr");
}

public OnPluginEnd()
{
	if(LibraryExists("RaceClass"))
		War3_RaceOnPluginEnd("martyr");
}

//GetPlayerDistance(client1,client2)

public OnWar3LoadRaceOrItemOrdered2(num,reloadrace_id,String:shortname[])
{
	if(num==RACE_ID_NUMBER||(reloadrace_id>0&&StrEqual("martyr",shortname,false)))
	{
		thisRaceID=War3_CreateNewRace("Martyr","martyr","Suffers Persecution",reloadrace_id);

		SKILL_SACRIFICE=War3_AddRaceSkill(thisRaceID,"Sacrifice Aura",
		"When a teammate near you takes damage\nand the modified damage is greater than 5 then\nyou have a 50% chance to take the damage instead.\nYou take 85/70/55/40% percent of the damage.",false,4);

		ABILITY_BLOOD_PACT=War3_AddRaceSkill(thisRaceID,"Blood Pact",
		"(+ability) Sacrifice 10/20/30/40 health.\nNearby teammates are healed for that amount.",false,4);

		//SKILL_BLOOD_RENEWAL=War3_AddRaceSkill(thisRaceID,"Blood Renewal",
		//"Regenerate Health. Increases with level.",false,4);

		SKILL_ALTRUIST=War3_AddRaceSkill(thisRaceID,"Altruist",
		"You take more damage per level. Your teammates around you take 3/6/9/12% less damage.",false,4);

		ULT_PURIFICATION=War3_AddRaceSkill(thisRaceID,"Purification",
		"For a few seconds,\nyour attacks also deal 10/20/40/60% of the damage dealt to all enemies near the target.\nSmall radius.",true,4);

		War3_CreateRaceEnd(thisRaceID);

		//War3_AddSkillBuff(thisRaceID, SKILL_BLOOD_RENEWAL, fHPRegen, Renewal);
		War3_AddSkillBuff(thisRaceID, SKILL_ALTRUIST, fArmorPhysical, TakeMoreDamage);

		War3_SetDependency(thisRaceID, SKILL_ALTRUIST, SKILL_SACRIFICE, 4);

		AuraID=W3RegisterChangingDistanceAura("sacrifice_aura");
	}
}

public OnRaceChanged(client,oldrace,newrace)
{
	TakeDamageAuraOwner[client]=false;
}

public void OnSkillLevelChanged(int client, int currentrace, int skill, int newskilllevel, int oldskilllevel)
{
	if(RaceDisabled)
		return;

	if(currentrace==thisRaceID)
	{
		if(skill==SKILL_SACRIFICE)
		{
			if(newskilllevel>0)
			{
				W3SetPlayerAura(AuraID,client,AuraDistance[newskilllevel],newskilllevel);
			}
			else
			{
				W3RemovePlayerAura(AuraID,client);
			}
		}
	}
}

public OnW3PlayerAuraStateChanged(client,aura,bool:inAura,level,AuraStack,AuraOwner)
{
	if(aura==AuraID)
	{
		if(level>0)
		{
			if(AuraStack>0)
			{
				MyAura[AuraOwner][client]=true;
			}
			else
			{
				MyAura[AuraOwner][client]=false;
			}
		}
	}
}

AuraCheck(client)
{
	for(new i=1;i<=MaxClients;i++)
	{
		if(i==client)
		{
			continue;
		}
		if(!MyAura[i][client])
		{
			continue;
		}
		if(War3_GetRace(i)==thisRaceID)
		{
			return i;
		}
	}
	return -1;
}

DamageOthers(client,target,dmgamount,level)
{
	for(new i=1;i<=MaxClients;i++)
	{
		if(i==client)
		{
			continue;
		}
		if(i==target)
		{
			continue;
		}
		if(!ValidPlayer(i,true))
		{
			continue;
		}
		if(GetClientTeam(i)!=GetClientTeam(client))
		{
			if(GetPlayerDistance(i,target)<=AuraDistance[level])
			{
				if(War3_DealDamage(i,dmgamount,client,DMG_GENERIC,"purification", W3DMGORIGIN_ULTIMATE , W3DMGTYPE_MAGIC))
				{
					War3_NotifyPlayerTookDamageFromSkill(i, client, dmgamount, ULT_PURIFICATION);
				}
			}
		}
	}
}

public Action OnW3TakeDmgAllPre(int victim, int attacker, float damage)
{
	if(RaceDisabled)
		return;

	if(victim==attacker)
		return;

	if(ValidPlayer(victim,true))
	{
		int AuraOwner=AuraCheck(victim);
		if(AuraOwner>-1 && ValidPlayer(AuraOwner,true))
		{
			if(W3Chance(0.50))
			{
				int skill_level=War3_GetSkillLevel(AuraOwner,thisRaceID,SKILL_ALTRUIST);
				if(skill_level>0)
				{
					int DamageMod = RoundToFloor(ModifyDamage[skill_level] * damage);
					if(DamageMod>5)
					{
						TakeDamageAuraOwner[AuraOwner]=true;
						float ModPDamage=1.0-Altruist[skill_level];
						ModPDamage-=0.50;
						War3_DamageModPercent(ModPDamage);
					}
				}
			}
		}
	}
}


public Action OnW3TakeDmgBullet(int victim, int attacker, float damage)
{
	if(RaceDisabled)
		return;

	if(ValidPlayer(victim,true))
	{
		if(ValidPlayer(attacker,true) && War3_GetRace(attacker)==thisRaceID && PurificationTarget[attacker]==victim)
		{
			int skill_level=War3_GetSkillLevel(attacker,thisRaceID,ULT_PURIFICATION);
			if(skill_level>0)
			{
				int oDamage=RoundToFloor(damage*Purification[skill_level]);
				DamageOthers(attacker,victim,oDamage,skill_level);
			}
		}
		int AuraOwner=AuraCheck(victim);

		if(AuraOwner>-1)
		{
			if(TakeDamageAuraOwner[AuraOwner])
			{
				int skill_level=War3_GetSkillLevel(AuraOwner,thisRaceID,SKILL_ALTRUIST);
				if(skill_level>0)
				{
					if(ValidPlayer(AuraOwner,true))
					{
						new DamageMod = RoundToFloor(ModifyDamage[skill_level] * damage);
						if(War3_DealDamage(AuraOwner,DamageMod,AuraOwner,DMG_GENERIC,"sacrifice_aura", W3DMGORIGIN_SKILL , W3DMGTYPE_MAGIC , false))
						{
							char TmpName[32];
							GetClientName(victim,TmpName,sizeof(TmpName));
							//War3_NotifyPlayerTookDamageFromSkill(AuraOwner, victim, DamageMod, SKILL_SACRIFICE);
							War3_ChatMessage(AuraOwner,"{default}[{green}%s{default}] did [{green}+%d{default}] damage to you via your {green}Sacrifice Aura{default}!", TmpName, DamageMod);
						}
					}
				}
				TakeDamageAuraOwner[AuraOwner]=false;
			}
		}
	}
}

bool:HealInRange(client,HealAmount,level)
{
	char sName[128];
	char sTempName[128];
	bool healedplayers=false;
	GetClientName(client,sName,sizeof(sName));

	for(new i=1;i<=MaxClients;i++)
	{
		if(i==client)
		{
			continue;
		}
		if(ValidPlayer(i,true) && GetClientTeam(i)==GetClientTeam(client))
		{
			if(GetPlayerDistance(i,client)<=AuraDistance[level])
			{
				War3_HealToMaxHP(i, HealAmount);
				GetClientName(i,sTempName,sizeof(sTempName));
				War3_ChatMessage(i,"{blue}%s healed you for {cyan}%d{blue} via {red}Blood Pact{blue}!",sName,HealAmount);
				War3_ChatMessage(client,"{blue}You healed %s for {cyan}%d{blue} via {red}Blood Pact{blue}!",sTempName,HealAmount);
				healedplayers=true;
			}
		}
	}
	return healedplayers;
}

public void OnAbilityCommand(int client, int ability, bool pressed, bool bypass)
{
	if(RaceDisabled)
		return;

	if(ValidPlayer(client,true) && War3_GetRace(client)==thisRaceID && ability==0 && pressed)
	{
		new skill_level=War3_GetSkillLevel(client,thisRaceID,ABILITY_BLOOD_PACT);
		if(skill_level>0)
		{
			if(War3_SkillNotInCooldown(client,thisRaceID,ABILITY_BLOOD_PACT,true))
			{
				War3_NotifyPlayerSkillActivated(client,ABILITY_BLOOD_PACT,true);

				if(GetClientHealth(client)>=BloodPact[skill_level])
				{
					if(War3_DealDamage(client,BloodPact[skill_level],client,DMG_GENERIC,"bloodpact", W3DMGORIGIN_SKILL , W3DMGTYPE_MAGIC , false))
					{
						if(HealInRange(client,BloodPact[skill_level],skill_level))
						{
							War3_NotifyPlayerTookDamageFromSkill(client, client, BloodPact[skill_level], ABILITY_BLOOD_PACT);
							War3_NotifyPlayerSkillActivated(client,ABILITY_BLOOD_PACT,false);
							War3_CooldownMGR(client,10.0,thisRaceID,ABILITY_BLOOD_PACT,_,_);
						}
						else
						{
							War3_ChatMessage(client,"Nobody to use Blood Pact on.");
						}
					}
				}
				else
				{
					War3_ChatMessage(client,"{blue}You do not have enough health to use Blood Pact!");
					return;
				}
			}
		}
		else
		{
			PrintHintText(client,"Level Your Ability First");
		}
	}
}

// BUG -- NEED TO ADD A TIMER FOR PURIFICATION TARGET SO THAT IT DOESN'T LAST ALL DAY
// BUG -- NEED TO ADD A TIMER FOR PURIFICATION TARGET SO THAT IT DOESN'T LAST ALL DAY
// BUG -- NEED TO ADD A TIMER FOR PURIFICATION TARGET SO THAT IT DOESN'T LAST ALL DAY
// BUG -- NEED TO ADD A TIMER FOR PURIFICATION TARGET SO THAT IT DOESN'T LAST ALL DAY
// BUG -- NEED TO ADD A TIMER FOR PURIFICATION TARGET SO THAT IT DOESN'T LAST ALL DAY
// BUG -- NEED TO ADD A TIMER FOR PURIFICATION TARGET SO THAT IT DOESN'T LAST ALL DAY
// BUG -- NEED TO ADD A TIMER FOR PURIFICATION TARGET SO THAT IT DOESN'T LAST ALL DAY
// BUG -- NEED TO ADD A TIMER FOR PURIFICATION TARGET SO THAT IT DOESN'T LAST ALL DAY
// BUG -- NEED TO ADD A TIMER FOR PURIFICATION TARGET SO THAT IT DOESN'T LAST ALL DAY

public void OnUltimateCommand(int client, int race, bool pressed, bool bypass)
{
	if(RaceDisabled)
		return;

	if(race==thisRaceID && pressed && IsPlayerAlive(client))
	{
		int skill=War3_GetSkillLevel(client,race,ULT_PURIFICATION);
		if(skill>0)
		{

			if((bypass||War3_SkillNotInCooldown(client,thisRaceID,ULT_PURIFICATION,true))&&!Silenced(client))
			{
				int target=War3_GetTargetInViewCone(client,0.0,false,23.0,UltFilter,ULT_PURIFICATION);
				PurificationTarget[client]=target;
				War3_NotifyPlayerSkillActivated(client,ULT_PURIFICATION,true);
				CreateTimer(3.0, StopPurification, client);
				War3_CooldownMGR(client,20.0,thisRaceID,ULT_PURIFICATION,_,_);
			}
		}
		else
		{
			W3MsgUltNotLeveled(client);
		}
	}
}

public Action:StopPurification(Handle:Timer, any:client)
{
	PurificationTarget[client]=-1;
	War3_NotifyPlayerSkillActivated(client,ULT_PURIFICATION,false);
}
