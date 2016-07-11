//=============================================================================
// Buff System SET
//=============================================================================

// THESE PERMAMENTLY links to the player's skill level and changes the buffs acordingly
// If player has race/skill, the value[] corresponding to the level is applied on the buff
// values = array (usually length 5, with 0th index included, zeroth index is ignored however, internally it calls a resetbuff function to restore default value)
// of values to set the buff as, CELLS please (int or float, determined by buff itself)
// MAX LENGTH of values is 32
// RECALL safe
// no return
/**
 *
 *
 * @param raceID						race id
 * @param skill_ID						skill id
 * @param buff							W3buff property from constants.inc
 * @param values						value depends on W3Buff property
 * @return 								no return
 *
 */
native War3_AddSkillBuff(raceID, skill_ID, W3Buff:buff, any:values[]);


/**
 * This does not set if War3_SetOwnsItem, you need to manually do that
 *
 * @param item_ID						item id
 * @param buff							W3buff property from constants.inc
 * @param values						value depends on W3Buff property
 * @return 								no return
 *
 */
native War3_AddItemBuff(item_ID, W3Buff:buff, any:value);

/**
 * This does not set if War3_SetOwnsItem, you need to manually do that
 *
 * @param race_ID						race id
 * @param skill_ID						skill id
 * @param buff							W3buff property from constants.inc
 * @param values						value depends on W3Buff property
 * @param auraShortName					create a aura name
 * @param distance						the distance is a float array [1.0,2.0,3.0,4.0]
 * @param DistanceArraySize				the distance array size
 * @param trackotherteam				should the aura track the other team?
 * @param ImmunityCheck					which immunity to auto check?
 * @return 								no return
 *
 */
native War3_AddAuraSkillBuff(race_ID, skill_ID, W3Buff:buff, any:values[],
							 String:auraShortName[], Float:distance[], DistanceArraySize,
							 bool:trackotherteam, War3Immunity:ImmunityCheck=Immunity_None);



/**
 * set a buff, identified as coming from a race
 * value can be int float bool, but has to be consistant, agreed upon by war3 main plugin
 *
 * @param client						client index
 * @param buffindex						W3Buff property found in constants.inc
 * @param value							value depends on W3Buff property
 * @param buffowner						owner whom applied the buff to the client
 * @return 								no return
 *
 */
//#pragma deprecated Use War3_SetBuffRace(int client,W3Buff buffindex,int raceid,any value,int buffowner=-1) instead
native War3_SetBuff(client,W3Buff:buffindex,raceid,any:value,buffowner=-1); //deprecated

/**
 * set a buff, identified as coming from a race
 * value can be int float bool, but has to be consistant, agreed upon by war3 main plugin
 *
 * @param client						client index
 * @param buffindex						W3Buff property found in constants.inc
 * @param value							value depends on W3Buff property
 * @param buffowner						owner whom applied the buff to the client
 * @return 								no return
 *
 */
native War3_SetBuffRace(int client,W3Buff buffindex,int raceid,any value,int buffowner=-1);

/**
 * set a buff, identified as coming from a skill created by War3_CreateNewSkill
 * value can be int float bool, but has to be consistant, agreed upon by war3 main plugin
 *
 * @param client						client index
 * @param buffindex						W3Buff property found in constants.inc
 * @param skillid						Skills created by War3_CreateNewSkill
 * @param value							value depends on W3Buff property
 * @param buffowner						owner whom applied the buff to the client
 * @return 								no return
 *
 */
native void War3_SetBuffSkill(int client,W3Buff buffindex,int skillid,any value,int buffowner=-1);

/**
 * set a buff, identified as coming from a item
 * value can be int float bool, but has to be consistant, agreed upon by war3 main plugin
 *
 * @param client						client index
 * @param buffindex						W3Buff property found in constants.inc
 * @param itemid						item id
 * @param value							value depends on W3Buff property
 * @param buffowner						owner whom applied the buff to the client
 * @return 								no return
 *
 */
native War3_SetBuffItem(client,W3Buff:buffindex,itemid,any:value,buffowner=-1);

/**
 * set a buff, identified as coming from a item
 * value can be int float bool, but has to be consistant, agreed upon by war3 main plugin
 *
 * @param client						client index
 * @param buffindex						W3Buff property found in constants.inc
 * @param itemid						item id
 * @param value							value depends on W3Buff property
 * @param buffowner						owner whom applied the buff to the client
 * @return 								no return
 *
 */
native War3_SetBuffItem2(client,W3Buff:buffindex,item2id,any:value,buffowner=-1);

/**
 * set a buff, identified as coming from a item
 * value can be int float bool, but has to be consistant, agreed upon by war3 main plugin
 *
 * @param client						client index
 * @param buffindex						W3Buff property found in constants.inc
 * @param itemid						item id
 * @param value							value depends on W3Buff property
 * @param buffowner						owner whom applied the buff to the client
 * @return 								no return
 *
 */
native War3_SetBuffItem3(client,W3Buff:buffindex,item3id,any:value,buffowner=-1);

/**
 * get offset for custom buff modifier indexes. use War3_SetBuffItem(client,buffindex,W3BuffCustomOFFSET() + NUMBER,value) (YES, ITEM)
 *
 * @return 								returns offset
 *
 */
native W3BuffCustomOFFSET();

/**
 * not implemented
 * simple buff application which the plugin does internal tracking so you don't have to
 * given a race, buffindex, and its value, applies that buff for a certain duration then calls buffReset
 * @allowReapplyToExtendDuration if true, means a new call to the same race-buff combination will renew its duration, otherwise it will be blocked and the existing duration is kept
 */
native W3ApplyBuffSimple(client,W3Buff:buffindex,raceid,any:appliedBuffValue,Float:duration,bool:allowReapplyToExtendDuration=true);

//=============================================================================
// Buff System RESET
//=============================================================================

/**
 * RESETS a particular buff from your race on this client
 *
 * @param client						client index
 * @param buffindex						W3Buff property found in constants.inc
 * @param raceid						race id
 * @return 								no return
 *
 */
native W3ResetBuffRace(client,W3Buff:buffindex,raceid);

/**
 * RESETS ALL BUFFS PERTAINGIN TO THIS CLIENT AND RACE, basically fully getting rid if all buffs attatched to this player from your race
 *
 * @param client						client index
 * @param raceid						race id
 * @return 								no return
 *
 */
native W3ResetAllBuffRace(client, raceid);

/**
 * Reset a particular buff from a item on thsi client
 *
 * @param client						client index
 * @param buffindex						W3Buff property found in constants.inc
 * @param itemid						item id
 * @return 								no return
 *
 */
native W3ResetBuffItem(client, W3Buff:buffindex, itemid);

//=============================================================================
// Buff System Misc
//=============================================================================

/**
 * Shows current buffs to a client
 *
 * @param client						client index
 * @return 								no return
 *
 */
native War3_ShowBuffs(client);

/**
 * Shows current speed to a client
 *
 * @param client						client index
 * @return 								no return
 *
 */
native War3_ShowSpeedBuff(client);

/**
 * is a buff index valid? X > 0 and X <  MaxBuffLoopLimitTemp
 *
 * @param buffindex						W3Buff property found in constants.inc
 * @return 								returns true if buff is valid / throws an error otherwise
 *
 */
stock bool ValidBuff(W3Buff buffindex)
{
	if(view_as<int>(buffindex)>=0&&view_as<int>(buffindex)<MaxBuffLoopLimit)
	{
		return true;
	}
	ThrowError("invalid buff index (%d)",buffindex);
	return false;
}

//=============================================================================
// Buff System Player Color
//=============================================================================

/**
 * set player shell glowish color (blood mage, shadow hunter), highest override priority takes effect, all integers
 *
 * @param client						client index
 * @param raceid						race id
 * @param r								red color
 * @param g								green color
 * @param b								blue color
 * @param a								alpha color
 * @param overridepriority				find the override priorities in constants.inc
 * @return 								no return
 *
 */
stock W3SetPlayerColor(client, raceid, r, g, b, a = 255,
		overridepriority = GLOW_DEFAULT) {
	War3_SetBuff(client, iGlowRed, raceid, r);
	War3_SetBuff(client, iGlowGreen, raceid, g);
	War3_SetBuff(client, iGlowBlue, raceid, b);
	War3_SetBuff(client, iGlowAlpha, raceid, a);
	War3_SetBuff(client, iGlowPriority, raceid, overridepriority);
	War3_SetBuff(client, fGlowSetTime, raceid, GetGameTime());
}

/**
 * resets a players color
 *
 * @param client						client index
 * @param raceid						race id
 * @return 								no return
 *
 */
stock W3ResetPlayerColor(client, raceid) {
	W3SetPlayerColor(client, raceid, 255, 255, 255, _, 0);
}

//=============================================================================
// Get Buffs System
//=============================================================================

//getting buffs
/**
 *
 * @return 								buff loop size , item count + race count + others, loop from 0 to <this return value
 *
 */
native W3GetBuffLoopLimit();

/**
 * Gets a Buff from either a race or item
 *
 * @param client						client index
 * @param buffindex						W3Buff property found in constants.inc
 * @param RaceIDorItemID				race, item, or skill
 * @param IPassedItemID					special purpose (you passed a item id) (adds total sh1 + RaceIDorItemID to check against)
 * @return 								no return
 */
native any W3GetBuff(int client,W3Buff buffindex,int RaceIDorItemID,bool IPassedItemID=false);

/**
 * W3GetBuffHasTrue
 *
 * @param client						client index
 * @param buffindex						W3Buff property found in constants.inc
 * @return 								does this buff have one true (activated?)
 */
native bool:W3GetBuffHasTrue(client,W3Buff:buffindex);

/**
 * W3GetBuffSumInt
 *
 * @param client						client index
 * @param buffindex						W3Buff property found in constants.inc
 * @return 								the int of a buff
 */
native W3GetBuffSumInt(client,W3Buff:buffindex);

/**
 * W3GetBuffStackedFloat
 *
 * @param client						client index
 * @param buffindex						W3Buff property found in constants.inc
 * @return 								get buff stacked value of an buff, use appropriately
 */
native Float:W3GetBuffStackedFloat(client,W3Buff:buffindex);

/**
 * W3GetBuffSumFloat
 *
 * @param client						client index
 * @param buffindex						W3Buff property found in constants.inc
 * @return 								get buff sum float value of an buff, use appropriately
 */
native Float:W3GetBuffSumFloat(client,W3Buff:buffindex);

/**
 * W3GetBuffMinFloat
 *
 * @param client						client index
 * @param buffindex						W3Buff property found in constants.inc
 * @return 								get buff min float value of an buff, use appropriately
 */
native Float:W3GetBuffMinFloat(client,W3Buff:buffindex);

/**
 * W3GetBuffMaxFloat
 *
 * @param client						client index
 * @param buffindex						W3Buff property found in constants.inc
 * @return 								get buff max float value of an buff, use appropriately
 */
native Float:W3GetBuffMaxFloat(client,W3Buff:buffindex);

/**
 * W3GetBuffLastValue
 *
 * @param client						client index
 * @param buffindex						W3Buff property found in constants.inc
 * @return 								get buff last value of an buff, use appropriately
 */
native W3GetBuffLastValue(client,W3Buff:buffindex);

/**
 * W3GetBuffMinInt
 *
 * @param client						client index
 * @param buffindex						W3Buff property found in constants.inc
 * @return 								get buff min int value of an buff, use appropriately
 */
native W3GetBuffMinInt(client,W3Buff:buffindex);

/**
 * W3ReapplySpeed
 *
 * @param client						client index
 * @return 								calculate player speed next frame
 */
native W3ReapplySpeed(client);

/**
 * W3GetSpeedMulti
 *
 * @param client						client index
 * @return 								get the effective speed multipler for TF
 */
native W3GetSpeedMulti(client);

//=============================================================================
// Buff System Immunities
//=============================================================================

/**
 * W3HasImmunity
 *
 * @param client						client index
 * @param immunityindex					find War3Immunity in constants.inc
 * @return 								true if the player has immunity
 */
stock bool:W3HasImmunity(client,War3Immunity:immunityindex) {
										 //Immunity_Ability
	//add magic immunity etc later
	if(immunityindex==Immunity_Abilities) {
		return W3GetBuffHasTrue(client,bImmunityAbilities);
	}
	//else if(immunityindex==Immunity_Items) {
		//return W3GetBuffHasTrue(client,bImmunityItems);
	//}
	else if(immunityindex==Immunity_Skills) {
		return W3GetBuffHasTrue(client,bImmunitySkills);
	}
	else if(immunityindex==Immunity_Ultimates) {
		return W3GetBuffHasTrue(client,bImmunityUltimates);
	}
	else if(immunityindex==Immunity_Wards) {
		//return W3GetBuffHasTrue(client,bImmunityWards)||W3GetBuffHasTrue(client,bImmunitySkills);
		return W3GetBuffHasTrue(client,bImmunityWards);
	}
	else if(immunityindex==Immunity_Poison) {
		return W3GetBuffHasTrue(client,bImmunityPoison);
	}
	else if(immunityindex==Immunity_Hacks) {
		return W3GetBuffHasTrue(client,bImmunityHacks);
	}
	else if(immunityindex==Immunity_ArmorPiercing) {
		return W3GetBuffHasTrue(client,bImmunityPiercing);
	}
	else if(immunityindex==Immunity_Extra2) {
		return W3GetBuffHasTrue(client,bImmunityExtra2);
	}
	else if(immunityindex==Immunity_Extra3) {
		return W3GetBuffHasTrue(client,bImmunityExtra3);
	}

	return false;

}

/**
 * IsSkillImmune
 *
 * @param client						client index
 * @return 								true if client is immune to skills
 */
stock bool:IsSkillImmune(client) {
	return W3GetBuffHasTrue(client,bImmunitySkills);
}

/**
 * IsUltImmune
 *
 * @param client						client index
 * @return 								true if client is immune to ultimates
 */
stock bool:IsUltImmune(client) {
	return W3GetBuffHasTrue(client,bImmunityUltimates);
}


/**
 * generic immunity filter for ultimate
 * used with War3_GetTargetInViewCone
 *
 * @param client						client index
 * @param target						target index
 * @param SkillID						unltimate id
 * @return 								if player has immunity returns false
 */
public bool:UltFilter(client,target,SkillID)
{
	if(W3HasImmunity(target,Immunity_Ultimates))
	{
		War3_NotifyPlayerImmuneFromSkill(client, target, SkillID);
		return false;
	}
	return true;
	//return (!W3HasImmunity(client,Immunity_Ultimates));
}

/**
 * generic immunity filter for skills
 * used with War3_GetTargetInViewCone
 *
 * @param client						client index
 * @param target						target index
 * @param SkillID						skill id
 * @return 								if player has immunity returns false
 */
public bool:SkillFilter(client,target,SkillID)
{
	if(W3HasImmunity(target,Immunity_Skills))
	{
		War3_NotifyPlayerImmuneFromSkill(client, target, SkillID);
		return false;
	}
	return true;
	//return (!W3HasImmunity(client,Immunity_Skills));
}

//=============================================================================
// Buff System Statuses
//=============================================================================

/**
 * Is client stunned?
 *
 * @param client						client index
 * @return 								true if client is stunned
 */
stock bool:Stunned(client) {
	return W3GetBuffHasTrue(client,bStunned);
}

/**
 * Is client silenced?
 *
 * @param client						client index
 * @param printSilenced					if true, print to client if they are silenced or not
 * @return 								true if silenced
 */
stock bool:Silenced(client,printSilenced=true) {
	new bool:silenced=(W3GetBuffHasTrue(client,bSilenced)||Stunned(client));
	if(silenced&&printSilenced) {
		if(IsPlayerAlive(client)) {
			if(Stunned(client))
			{
				PrintHintText(client,"You are stunned");
			}
			else
			{
				PrintHintText(client,"You are silenced");
			}
		}
		if(Stunned(client))
		{
			PrintToConsole(client,"You are stunned, cannot activate skill");
		}
		else
		{
			PrintToConsole(client,"You are silenced, cannot activate skill");
		}
	}
	return silenced;
}

/**
 * Is client hexed?
 *
 * @param client						client index
 * @param printmsg						if true, print to client if they are hexed or not
 * @return 								true if hexed
 */
stock bool:Hexed(client,printmsg=true) {
	new bool:status=(W3GetBuffHasTrue(client,bHexed)||W3GetBuffHasTrue(client,bStunned));
	if(status&&printmsg) {

		if(Stunned(client))
		{
			PrintToConsole(client,"You are stunned, cannot proc skill");
		}
		else
		{
			PrintToConsole(client,"You are hexed, cannot proc skill");
		}
	}
	return status;
}

/**
 * Is client Perplexed?
 *
 * @param client						client index
 * @param printmsg						if true, print to client if they are Perplexed or not
 * @return 								true if Perplexed
 */
stock bool:Perplexed(client,printmsg=true) {
	new bool:perplexed=(W3GetBuffHasTrue(client,bPerplexed)||W3GetBuffHasTrue(client,bStunned));
	if(perplexed&&printmsg) {

		if(Stunned(client))
		{
			PrintToConsole(client,"You are stunned, cannot activate item");
		}
		else
		{
			PrintToConsole(client,"You are perplexed, cannot activate item");
		}
	}
	return perplexed;
}

//=============================================================================
// Buff Forwards
//=============================================================================

// Internally forwarded via War3's on EVENT process:
//	internal_W3SetVar(EventArg1,buffindex); //generic war3event arguments
//	internal_W3SetVar(EventArg2,itemraceindex);
//	internal_W3SetVar(EventArg3,value);
//	W3CreateEvent(W3EVENT:OnBuffChanged,client);
//
// You'll need to capture the event example:

//public OnWar3Event(W3EVENT:event,client){
//	if(event==OnBuffChanged)
//	{
//		if(internal_W3GetVar(EventArg1)==iAdditionalMaxHealth&&ValidPlayer(client,true)){
//			if(mytimer2[client]==INVALID_HANDLE){
//				mytimer2[client]=CreateTimer(0.1,CheckHPBuffChange,client);
//			}
//		}
//		//DP("EVENT OnBuffChanged",event);
//	}
//	//DP("EVENT %d",event);
//}
