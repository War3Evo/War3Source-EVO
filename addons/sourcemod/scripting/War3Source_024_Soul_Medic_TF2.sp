#include <war3source>

#if (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
	#endinput
#endif


#pragma semicolon 1

//#include "W3SIncs/War3Source_Interface"

#if GGAMETYPE != GGAME_TF2
	#endinput
#endif

#if GGAMEMODE != MODE_WAR3SOURCE
	#endinput
#endif

//#assert GGAMEMODE == MODE_WAR3SOURCE
//#assert GGAMETYPE == GGAME_TF2

#define RACE_ID_NUMBER 24

//#include <tf2_stocks>

public Plugin:myinfo =
{
	name = "War3Source Race - Soul Medic",
	author = "Glider",
	description = "The Soul Medic race for War3Source.",
	version = "1.0",
};

//=======================================================================
//                             VARIABLES
//=======================================================================

new thisRaceID;

bool HooksLoaded = false;
public void Load_Hooks()
{
	if(HooksLoaded) return;
	HooksLoaded = true;

	W3Hook(W3Hook_OnW3TakeDmgBulletPre, OnW3TakeDmgBulletPre);
	W3Hook(W3Hook_OnW3TakeDmgBullet, OnW3TakeDmgBullet);
	W3Hook(W3Hook_OnUltimateCommand, OnUltimateCommand);
}
public void UnLoad_Hooks()
{
	if(!HooksLoaded) return;
	HooksLoaded = false;

	W3UnhookAll(W3Hook_OnW3TakeDmgBulletPre);
	W3UnhookAll(W3Hook_OnW3TakeDmgBullet);
	W3UnhookAll(W3Hook_OnUltimateCommand);
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


new SKILL_SHARED_PAIN, SKILL_BOOST_BEAM, SKILL_SOUL_BOUND, ULT_SOUL_SWAP;

// Amount of Damage to reflect onto your healing buddy
new Float:fSharedPainPercentage[5] = {0.0, 0.1, 0.2, 0.3, 0.4};

// Percentage of how to boost your buddys damage
new Float:fDamageBoost[5] = {1.0, 1.02, 1.04, 1.06, 1.10};

// How long ubercharge lasts from ultimate
//new Float:fFreeUberTime[5] = {0.0, 1.0, 2.0, 3.0, 4.0};
new Float:fFreeUberTime[5] = {0.0, 2.0, 3.0, 4.0, 5.0};

// Soul Bound
//new Float:fUberTime[5] = {0.0, 1.0, 2.0, 2.0, 3.0};
new Float:fUberTime[5] = {0.0, 2.0, 3.0, 4.0, 5.0};
new Float:fPriceMedicPays[5] = {1.0, 0.8, 0.6, 0.4, 0.2};

new const Float:SOULBOUND_COOLDOWN = 30.0; // was 30.0
new const Float:ULT_COOLDOWN = 60.0;  // was 60.0

//=======================================================================
//                                 INIT
//=======================================================================

public OnWar3LoadRaceOrItemOrdered2(num,reloadrace_id,String:shortname[])
{
	if(num==RACE_ID_NUMBER||(reloadrace_id>0&&StrEqual("soulmedic",shortname,false)))
	{
		thisRaceID = War3_CreateNewRace("Soul Medic", "soulmedic",reloadrace_id,"(Medics only)");
		SKILL_SHARED_PAIN = War3_AddRaceSkill(thisRaceID, "Shared Pain", "The person you're healing takes 10/20/30/40% of your damage (unless its more than 200 damage)", false, 4);
		SKILL_BOOST_BEAM = War3_AddRaceSkill(thisRaceID, "Boost Beam", "The person you're healing deals 2%/4%/6%/10% more damage", false, 4);
		SKILL_SOUL_BOUND = War3_AddRaceSkill(thisRaceID, "Soul Bound", "If the person you're healing takes lethal damage you will give him uber for 2/3/4/5 seconds costing you 80/60/40/20% HP CD: 30s", false, 4);
		ULT_SOUL_SWAP = War3_AddRaceSkill(thisRaceID, "Soul Swap", "You swap HP with your partner. You become ubered for 2/3/4/5 seconds. CD: 60s", false, 4);
		War3_CreateRaceEnd(thisRaceID);
	}
}

public OnAllPluginsLoaded()
{
	War3_RaceOnPluginStart("soulmedic");
}

public OnPluginEnd()
{
	if(LibraryExists("RaceClass"))
		War3_RaceOnPluginEnd("soulmedic");
}


//=======================================================================
//                        Shared Pain/Boost Beam/Soul Bound
//=======================================================================
public Action OnW3TakeDmgBullet(int victim, int attacker, float damage)
{
	if(RaceDisabled)
		return;

	if(W3GetDamageIsBullet() && ValidPlayer(victim, true) && (War3_GetRace(victim) == thisRaceID))
	{
		new skill = War3_GetSkillLevel(victim, thisRaceID, SKILL_SHARED_PAIN);
		if(skill >= 0 && damage > 0.0)
		{
			if (TF2_GetPlayerClass(victim) == TFClass_Medic)
			{
				new HealVictim = TF2_GetHealingTarget(victim);
				if (ValidPlayer(HealVictim, true))
				{
					float fMedicDamagePercentage = 1.0 - fSharedPainPercentage[skill];
					int damageForBuddy = RoundToFloor(damage * fMedicDamagePercentage);

					if (damageForBuddy< 200)
					{
						new String:buddyname[64];
						GetClientName(HealVictim, buddyname, sizeof(buddyname));

						new String:healername[64];
						GetClientName(victim, healername, sizeof(healername));

						War3_DealDamage(HealVictim, damageForBuddy, attacker, W3GetDamageType(), "sharedpain", _, _, _, true);

						W3Hint(victim, HINT_COOLDOWN_COUNTDOWN, 1.0, "%s takes %i points of damage for you!", buddyname, damageForBuddy);
						W3Hint(HealVictim, HINT_COOLDOWN_COUNTDOWN, 1.0, "%s passed on %i points of damage to you!", healername, damageForBuddy);
					}
				}
			}
		}
	}
}

public Action OnW3TakeDmgBulletPre(int victim, int attacker, float damage, int damagecustom)
{
	if(RaceDisabled)
		return;

	if(ValidPlayer(victim, true) && (War3_GetRace(victim) == thisRaceID))
	{
		new skill = War3_GetSkillLevel(victim, thisRaceID, SKILL_SHARED_PAIN);
		if(skill >= 0 && damage > 0.0)
		{
			if (damage < 200.0)
			{
				if (TF2_GetPlayerClass(victim) == TFClass_Medic)
				{
					new HealVictim = TF2_GetHealingTarget(victim);
					if (ValidPlayer(HealVictim, true))
					{
						new Float:fMedicDamagePercentage = 1.0 - fSharedPainPercentage[skill];

						new String:buddyname[64];
						GetClientName(HealVictim, buddyname, sizeof(buddyname));

						new String:healername[64];
						GetClientName(victim, healername, sizeof(healername));

						War3_DamageModPercent(fMedicDamagePercentage);
					}
				}
			}
		}
	}
	// Fixes being triggered because your teammate does a kill taunt on your healing target.
	if(ValidPlayer(attacker, true) && ValidPlayer(attacker) && (GetClientTeam(attacker)!=GetClientTeam(victim)))
	{
		for(new healer=1; healer <= MaxClients; healer++)
		{
			if(ValidPlayer(healer, true) && (War3_GetRace(healer) == thisRaceID) && (TF2_GetPlayerClass(healer) == TFClass_Medic))
			{
				new skill = War3_GetSkillLevel(healer, thisRaceID, SKILL_BOOST_BEAM);
				if(skill > 0)
				{
					new HealVictim = TF2_GetHealingTarget(healer);
					if (HealVictim == attacker)
					{
						War3_DamageModPercent(fDamageBoost[skill]);
						//new String:attackerName[128],String:HealerName[128];
						//GetClientName(healer,HealerName,sizeof(HealerName));
						//GetClientName(HealVictim,attackerName,sizeof(attackerName));
						//new Float:predamage = damage * fDamageBoost[skill];
						//DP("[Healer %s] Damage boost damage for %s.  Damage mod %.2f. pre damage %.2f",HealerName,attackerName,fDamageBoost[skill],predamage);
					}
				}
			}
		}
	}

	if(ValidPlayer(victim, true))
	{
		for(new healer=1; healer <= MaxClients; healer++)
		{
			if(ValidPlayer(healer, true) && (War3_GetRace(healer) == thisRaceID) && (TF2_GetPlayerClass(healer) == TFClass_Medic))
			{
				new skill = War3_GetSkillLevel(healer, thisRaceID, SKILL_SOUL_BOUND);
				if(skill > 0)
				{
					new HealVictim = TF2_GetHealingTarget(healer);
					if (HealVictim == victim)
					{
						if (damage + 10 >= GetClientHealth(victim))
						{
							new HealerMaxHP = War3_GetMaxHP(healer);
							new PriceToPay = RoundToCeil(HealerMaxHP * fPriceMedicPays[skill]);

							new String:buddyname[64];
							GetClientName(victim, buddyname, sizeof(buddyname));

							new String:healername[64];
							GetClientName(healer, healername, sizeof(healername));

							new HealerCurHP = GetClientHealth(healer);
							if (HealerCurHP < PriceToPay || !War3_SkillNotInCooldown(healer, thisRaceID, SKILL_SOUL_BOUND, true))
							{
								War3_ChatMessage(victim, "{green}%s{default} couldn't pay the price to save you.", healername);
								War3_ChatMessage(healer, "You couldn't pay the price to save {green}%s{default}", buddyname);
							}
							else
							{
								War3_DamageModPercent(0.0);
								TF2_AddCondition(victim, TFCond_Ubercharged, fUberTime[skill]);

								War3_ChatMessage(victim, "{green}%s{default} paid some HP to save you", healername);
								War3_ChatMessage(healer, "You paid some HP to save {green}%s{default}'s life!", buddyname);

								SetEntityHealth(healer, HealerCurHP - PriceToPay);

								War3_CooldownMGR(healer, SOULBOUND_COOLDOWN, thisRaceID, SKILL_SOUL_BOUND);
							}
						}
					}
				}
			}
		}
	}
}

//=======================================================================
//                               Soul Swap
//=======================================================================

public void OnUltimateCommand(int client, int race, bool pressed, bool bypass)
{
	if(RaceDisabled)
		return;

	if(ValidPlayer(client, true) &&
		race == thisRaceID &&
		pressed &&
		War3_SkillNotInCooldown(client, thisRaceID, ULT_SOUL_SWAP, true) &&
		!Silenced(client))
	{
		if (TF2_GetPlayerClass(client) == TFClass_Medic)
		{
			new skill = War3_GetSkillLevel(client, thisRaceID, ULT_SOUL_SWAP);
			if (skill > 0)
			{
				new HealVictim = TF2_GetHealingTarget(client);
				if (ValidPlayer(HealVictim, true))
				{
					new fVictimCurHP = GetClientHealth(HealVictim);
					//new fVictimMaxHP = War3_GetMaxHP(HealVictim);
					//new fVictimPercentageHP = fVictimCurHP / fVictimMaxHP;

					new fHealerCurHP = GetClientHealth(client);
					//new fHealerMaxHP = War3_GetMaxHP(client);
					//new fHealerPercentageHP = fHealerCurHP / fHealerMaxHP;

					//if(fVictimPercentageHP < fHealerPercentageHP)
					//{
					//new HealerNewHP = (fHealerMaxHP * fVictimPercentageHP);
					//new VictimNewHP = (fVictimMaxHP * fHealerPercentageHP);

					new HealerNewHP = fVictimCurHP;
					new VictimNewHP = fHealerCurHP;

					if (VictimNewHP <= 0)
						VictimNewHP = 1;

					if (HealerNewHP <= 0)
						HealerNewHP = 1;

					SetEntityHealth(HealVictim, VictimNewHP);
					SetEntityHealth(client, HealerNewHP);

					new String:buddyname[64];
					GetClientName(HealVictim, buddyname, sizeof(buddyname));

					new String:healername[64];
					GetClientName(client, healername, sizeof(healername));

					War3_ChatMessage(client, "You swapped your health with {green}%s{default} (%i -> %i)", buddyname, (fHealerCurHP), HealerNewHP);
					War3_ChatMessage(HealVictim, "{green}%s{default} swapped his health with you (%i -> %i)", healername, (fVictimCurHP), VictimNewHP);

					TF2_AddCondition(client, TFCond_Ubercharged, fFreeUberTime[skill]);

					War3_CooldownMGR(client, ULT_COOLDOWN, thisRaceID, ULT_SOUL_SWAP);
					//}
					//else
					//{
					//	War3_ChatMessage(client, "You cannot swap with someone who has more HP than you!");
					//}
				}
				else
				{
					War3_ChatMessage(client, "You are not healing anyone!");
				}
			}
		}
		else
		{
			War3_ChatMessage(client, "You are not a medic, you are doing it WRONG!");
		}

	}
}
