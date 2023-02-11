// War3Source_Engine_WCX_Engine_Vampire.sp

//#include <sourcemod>
//#include "W3SIncs/War3Source_Interface"
//#assert GGAMEMODE == MODE_WAR3SOURCE

/*
public Plugin:myinfo =
{
		name = "War3Source:EVO - Warcraft Extended - Vampirism",
		author = "War3Source Team",
		description="Generic vampirism skill"
};
*/

//new Handle:h_ForwardOnWar3VampirismPre = INVALID_HANDLE;

//public Engine_WCX_Engine_Vampire_OnPluginStart()
//{
		//LoadTranslations("w3s.race.undead.phrases");
//}

//public bool:InitNativesForwards()
//{
		//h_ForwardOnWar3VampirismPre = CreateGlobalForward("OnWar3VampirismPre", ET_Hook, Param_Cell, Param_Cell, Param_Cell);

		//return true;
//}

LeechHP(victim, attacker, float damage, float percentage, bool bBuff)
{
		new leechhealth = RoundToFloor(damage * percentage);
		if(leechhealth > 40)
		{
				leechhealth = 40;
		}

		new iOldHP = GetClientHealth(attacker);

		//bBuff ? War3_HealToBuffHP(attacker, leechhealth) : War3_HealToMaxHP(attacker, leechhealth);

		new War3Immunity:ImmunityCheck = Immunity_None;
		internal_W3SetVar(EventArg1, ImmunityCheck);
		internal_W3SetVar(EventArg2, 0);

		DoFwd_War3_Event(VampireImmunityCheckPre,attacker);

		ImmunityCheck = War3Immunity:internal_W3GetVar(EventArg1);
		new SkillOrItem = internal_W3GetVar(EventArg2);

		if(ImmunityCheck==Immunity_Skills||ImmunityCheck==Immunity_Ultimates) // skills / ultimate
		{
			if(W3HasImmunity(victim,ImmunityCheck))
			{
				War3_NotifyPlayerImmuneFromSkill(attacker, victim, SkillOrItem);
				return;
			}
		}
		//else if(ImmunityCheck==Immunity_Items) // Item check
		//{
			//if(W3HasImmunity(victim,ImmunityCheck))
			//{
				//War3_NotifyPlayerImmuneFromItem(attacker, victim, SkillOrItem);
				//return;
			//}
		//}

		if(bBuff)
		{
			War3_HealToBuffHP(attacker, leechhealth);
		}
		else
		{
			War3_HealToMaxHP(attacker, leechhealth);
		}

		new iNewHP = GetClientHealth(attacker);

		//DP("old HP %i New HP %i",iOldHP,iNewHP);

		if (iOldHP != iNewHP)
		{
				//new Action:returnVal = Plugin_Continue;

				//Call_StartForward(h_ForwardOnWar3VampirismPre);
				//Call_PushCell(victim);
				//Call_PushCell(attacker);
				//Call_PushCell(iHealthLeeched);
				//Call_Finish(_:returnVal);

				//if(returnVal != Plugin_Continue)
				//{

				new iHealthLeeched = iNewHP - iOldHP;
				// from war3source 2.0:
				War3_VampirismEffect(victim, attacker, iHealthLeeched);
				W3FlashScreen(attacker,RGBA_COLOR_GREEN);

				W3CreateEvent(OnVampireBuff,attacker);
		}
}

// comes from War3Source_Engine_WCX_Engine_Crit.sp
public Engine_WCX_Engine_Vampire_OnWar3EventPostHurt(victim,attacker,float damage,char weapon[64],bool:isWarcraft)
{
		if(!isWarcraft && ValidPlayer(victim) && ValidPlayer(attacker, true) && attacker != victim && GetClientTeam(victim) != GetClientTeam(attacker))
		{
#if (GGAMETYPE == GGAME_TF2)
			if(!IsOwnerSentry(attacker))
			{
#endif
				new Float:fVampirePercentage = GetBuffSumFloat(attacker, fVampirePercent);
				new Float:fVampirePercentageNoBuff = GetBuffSumFloat(attacker, fVampirePercentNoBuff);
				//DP("line 69 OnWar3EventPostHurt");
				//DP("line 70 fVampirePercentage %.2f",fVampirePercentage);
				new Float:fMeleeVampirePercentage = 0.0;
				new Float:fMeleeVampireNoBuffPercentage = 0.0;

				//if(W3HasImmunity(victim, Immunity_Skills))
				//{
					//DP("victim has immunity");
				//}

				//if(Hexed(attacker))
				//{
					//DP("attacker is hexed");
				//}
				if (W3IsDamageFromMelee(weapon))
				{
					fMeleeVampirePercentage += GetBuffSumFloat(attacker, fMeleeVampirePercent);
					fMeleeVampireNoBuffPercentage += GetBuffSumFloat(attacker, fMeleeVampirePercentNoBuff);
				}

				fVampirePercentage += fMeleeVampirePercentage;
				fVampirePercentageNoBuff += fMeleeVampireNoBuffPercentage;

				if(!Hexed(attacker))
				{
						// This one runs first
						if(fVampirePercentageNoBuff > 0.0)
						{
								LeechHP(victim, attacker, damage, fVampirePercentageNoBuff, false);
						}

						if(fVampirePercentage > 0.0)
						{
								//DP("line 80 %.2f",fVampirePercentage);
								LeechHP(victim, attacker, damage, fVampirePercentage, true);
						}
				}
#if (GGAMETYPE == GGAME_TF2)
			}
#endif
		}
}


/*
public OnW3TakeDmgBullet(victim, attacker, Float:damage)
{
#if (GGAMETYPE == GGAME_TF2)
		if(!IsOwnerSentry(attacker))
		{
#endif
			if(W3GetDamageIsBullet() && ValidPlayer(victim) && ValidPlayer(attacker, true) && attacker != victim && GetClientTeam(victim) != GetClientTeam(attacker))
			{
				//DP("line 91 OnW3TakeDmgBullet W3GetDamageIsBullet");
				new Float:fVampirePercentage = 0.0;
				new Float:fVampireNoBuffPercentage = 0.0;

				//if(W3HasImmunity(victim, Immunity_Skills))
				//{
					//DP("victim has immunity");
				//}

				//if(Hexed(attacker))
				//{
					//DP("attacker is hexed");
				//}

				new inflictor = W3GetDamageInflictor();
				if (attacker == inflictor || !IsValidEntity(inflictor))
				{
						new String:weapon[64];
						GetClientWeapon(attacker, weapon, sizeof(weapon));

						if (W3IsDamageFromMelee(weapon))
						{
								fVampirePercentage += GetBuffSumFloat(attacker, fMeleeVampirePercent);
								fVampireNoBuffPercentage += GetBuffSumFloat(attacker, fMeleeVampirePercentNoBuff);
						}
				}

				if(!Hexed(attacker))
				{
						//DP("line 110 !W3HasImmunity(victim, Immunity_Skills) && !Hexed(attacker)");
						// This one runs first
						if(fVampireNoBuffPercentage > 0.0)
						{
								LeechHP(victim, attacker, RoundToCeil(damage), fVampireNoBuffPercentage, false);
						}

						if(fVampirePercentage > 0.0)
						{
								//DP("line 119 %.2f",fVampirePercentage);
								LeechHP(victim, attacker, RoundToCeil(damage), fVampirePercentage, true);
						}
				}
			}
#if (GGAMETYPE == GGAME_TF2)
		}
#endif
}
*/

