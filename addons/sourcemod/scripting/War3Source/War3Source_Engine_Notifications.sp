// War3Source_Engine_Notifications.sp

//#assert GGAMEMODE == MODE_WAR3SOURCE

//new Float:MessageTimer[MAXPLAYERSCUSTOM];
//new W3Buff:MessageEventType[MAXPLAYERSCUSTOM];


//
//
//
//
//
//                  Test 4/5/2023 -- need to finish translations,
//                                   seems like SourceMod will atually tell you there's a missing translation now.
//
//
//
//					NotifyTranslateFunction replaces repeated code, but I'm unsure if it works
//
//					There's still stuff to translate.  I need to test this before translating the next set of files.
//
//					ONCE YOU FINISH TRNASLATENING THIS FILE, TEST IT TO MAKE SURE IT WORKS BY TESTING ON THE SERVER!
//
//
//	NotifyTranslateFunction is going to be tested on the server to make sure it works before continuing the translations.
//
//  	if (NotifyTranslateFunction(attacker,IsSkill,skillORitem,sSkillName,sSkillType) == 0) return 0;   returns 0 for errors / log
//
//
//
//
//
//
//
//
//
//
//
//
//
// NotifyTranslateFunction(iTarget,bool:IsSkill,skillORitem,String:sSkillName[32],String:sSkillType[32])

stock bool IsValidRace(raceid_)
{
	return (raceid_>0&&raceid_<=GetRacesLoaded())?true:false;
}

stock bool IsValidSkill(raceid_,skillid_)
{
	if(IsValidRace(raceid_))
		return (skillid_>0&&skillid_<=GetRaceSkillCount(raceid_))?true:false;
	else
		return false;
}
/*
public Plugin:myinfo =
{
	name = "War3Source - Engine - Notifications",
	author = "War3Source Team",
	description = "Centralize some notifications"
};*/

new Float:MessageTimer[MAXPLAYERSCUSTOM];
new MessageCount[MAXPLAYERSCUSTOM];
new String:MessageString1[MAXPLAYERSCUSTOM][256];
new String:MessageString_Immunities[MAXPLAYERSCUSTOM][256];
new Float:MessageTimer_Immunities[MAXPLAYERSCUSTOM];

public bool:War3Source_Engine_Notifications_InitNatives()
{
	CreateNative("War3_NotifyPlayerTookDamageFromSkill", Native_NotifyPlayerTookDamageFromSkill);
	CreateNative("War3_NotifyPlayerTookDamageFromItem", Native_NotifyPlayerTookDamageFromItem);
	CreateNative("War3_NotifyPlayerLeechedFromSkill", Native_NotifyPlayerLeechedFromSkill);
	CreateNative("War3_NotifyPlayerLeechedFromItem", Native_NotifyPlayerLeechedFromItem);
	CreateNative("War3_NotifyPlayerImmuneFromSkill", Native_NotifyPlayerImmuneFromSkill);
	CreateNative("War3_NotifyPlayerImmuneFromItem", Native_NotifyPlayerImmuneFromItem);
	CreateNative("War3_NotifyPlayerSkillActivated", Native_NotifyPlayerSkillActivated);
	CreateNative("War3_NotifyPlayerItemActivated", Native_NotifyPlayerItemActivated);

	return true;
}

//public OnPluginStart()
//{
	// Load Translations
//}

public War3Source_Engine_Notifications_OnWar3PlayerAuthed(client)
{
	MessageTimer[client]=0.0;
	MessageCount[client]=0;
	strcopy(MessageString1[client], 255, "");
}

MessageTimerFunction(victim,attacker)
{
	if(MessageTimer[attacker]<(GetGameTime()-5.0))
	{
		MessageCount[attacker]=0;
		MessageCount[victim]=0;
	}
	if(MessageTimer[victim]<(GetGameTime()-5.0))
	{
		MessageCount[victim]=0;
	}
}

public Native_NotifyPlayerSkillActivated(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	new skill = GetNativeCell(2);
	new bool:activated = bool:GetNativeCell(3);

	if (skill == 0)
	{
		return;
	}

	new String:sSkillName[32];
	new String:sSkillType[32];
	new race=GetRace(client);

	if(GetRaceSkillName(race, skill, sSkillName, sizeof(sSkillName))>0)
	{
		if(IsSkillUltimate(race, skill))
		{
			// was strcopy
			Format(sSkillType, sizeof(sSkillType), "%T", "ULTIMATE", client);
		}
		else
		{
			// was strcopy
			Format(sSkillType, sizeof(sSkillType), "%T", "SKILL", client);
		}

		if(activated)
		{
			War3_ChatMessage(client,"%T","[{sSkillType} {sSkillName} ACTIVATED]",client,sSkillType,sSkillName);
		}
		else
		{
			War3_ChatMessage(client,"%T","[{sSkillType} {sSkillName} DEACTIVATED]",client,sSkillType,sSkillName);
		}
	}
}

public Native_NotifyPlayerItemActivated(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	new item = GetNativeCell(2);
	new bool:activated = bool:GetNativeCell(3);

	if (item == 0)
	{
		return;
	}

	new String:sItemName[32];

	W3GetItemName(item, sItemName, sizeof(sItemName));

	if(activated)
	{
		War3_ChatMessage(client,"%T","[ITEM {sSkillName} ACTIVATED]",client,sItemName);
	}
	else
	{
		War3_ChatMessage(client,"%T","[ITEM {sSkillName} DEACTIVATED]",client,sItemName);
	}
}

NotifyTranslateFunction(iTarget,bool:IsSkill,skillORitem,String:sSkillName[32],String:sSkillType[32])
{
	new race=GetRace(iTarget);
	new String:TMPsSkillType[32];

	if(IsSkill)
	{
		if(!IsValidSkill(race,skillORitem)) return 0;

		if(GetRaceSkillName(race, skillORitem, sSkillName, sizeof(sSkillName))>0)
		{
			if(IsSkillUltimate(race, skillORitem))
			{
				//strcopy(sSkillType, sizeof(sSkillType), "ultimate");
				Format(TMPsSkillType, sizeof(TMPsSkillType), "%T", "ultimate", iTarget);
				strcopy(sSkillType, sizeof(sSkillType), TMPsSkillType);
			}
			else
			{
				//strcopy(sSkillType, sizeof(sSkillType), "skill");
				Format(TMPsSkillType, sizeof(TMPsSkillType), "%T", "skill", iTarget);
				strcopy(sSkillType, sizeof(sSkillType), TMPsSkillType);
			}
		}
		else
		{
			LogError("Notifications - NotifyPlayerTookDamageFunction - Lookup of GetRaceSkillName(%d,%d,%s,sizeof(%d))",race,skillORitem,sSkillName,sizeof(sSkillName));
			return 0;
		}
	}
	else
	{
		W3GetItemName(skillORitem, sSkillName, sizeof(sSkillName));
		Format(TMPsSkillType, sizeof(TMPsSkillType), "%T", "item", iTarget);
		strcopy(sSkillType, sizeof(sSkillType), TMPsSkillType);
	}
	return 1;	
}


NotifyPlayerTookDamageFunction(victim,attacker,damage,skillORitem,bool:IsSkill)
{
	MessageTimerFunction(victim,attacker);

	new race=GetRace(attacker);

	if(!IsValidRace(race)) return 0;

	//new race = GetRace(attacker);
	new String:sSkillName[32];
	new String:sSkillType[32];
	new String:sRaceName[32];

	GetRaceName(race,sRaceName,sizeof(sRaceName));

	new String:sAttackerName[32];
	GetClientName(attacker, sAttackerName, sizeof(sAttackerName));

	new String:sVictimName[32];
	GetClientName(victim, sVictimName, sizeof(sVictimName));

	//SetTrans(attacker);
	/*if(IsSkill)
	{
		if(!IsValidSkill(race,skillORitem)) return 0;

		if(GetRaceSkillName(race, skillORitem, sSkillName, sizeof(sSkillName))>0)
		{
			if(IsSkillUltimate(race, skillORitem))
			{
				//strcopy(sSkillType, sizeof(sSkillType), "ultimate");
				Format(sSkillType, sizeof(sSkillType), "%T", "ultimate", attacker);
			}
			else
			{
				//strcopy(sSkillType, sizeof(sSkillType), "skill");
				Format(sSkillType, sizeof(sSkillType), "%T", "skill", attacker);
			}
		}
		else
		{
			LogError("Notifications - NotifyPlayerTookDamageFunction - Lookup of GetRaceSkillName(%d,%d,%s,sizeof(%d))",race,skillORitem,sSkillName,sizeof(sSkillName));
			return 0;
		}
	}
	else
	{
		W3GetItemName(skillORitem, sSkillName, sizeof(sSkillName));
		strcopy(sSkillType, sizeof(sSkillType), "%T", "item", attacker);
	}*/
	if (NotifyTranslateFunction(attacker,IsSkill,skillORitem,sSkillName,sSkillType) == 0) return 0;

	decl String:sTmpString[256];
	Format(sTmpString,sizeof(sTmpString)," %s %s", sAttackerName, sSkillName);
	//DP(sTmpString);

	if(GetPlayerProp(attacker,iCombatMessages)==1)
	{
		if(StrContains(MessageString1[attacker], sTmpString)>-1)
		{
			MessageCount[attacker]+=damage;
			MessageTimer[attacker]=GetGameTime();

			// You did +%i damage to %s with %s
			W3Hint(attacker, HINT_DMG_DEALT, 0.5, "%T","You did +{iDamage} damage to {sVictimName} with {sSkillName}", attacker, damage, sVictimName, sSkillName);
			// [%d] You did +%i damage to %s with %s
			PrintToConsole(attacker,"%T","[{MessageCount} You did +{iDamage} damage to {sVictimName} with {sSkillName}", attacker, MessageCount[attacker], damage, sVictimName, sSkillName);
			// {default}[{red}%d{default}] You did [{green}+%d{default}] damage to [{green}%s{default}] with {green}%s{default} [{green}%s{default}]!
			War3_ChatMessage(attacker,"%T","[{MessageCount}] You did [+{iDamage}] damage to [{sVictimName}] with {sSkillType} [{sSkillName}]!", attacker, MessageCount[attacker], damage, sVictimName, sSkillType, sSkillName);
		}
		else
		{
			MessageCount[attacker]=damage;
			MessageTimer[attacker]=GetGameTime();
			strcopy(MessageString1[attacker], 255, sTmpString);

			// You did +%i damage to %s with %s
			W3Hint(attacker, HINT_DMG_DEALT, 0.5, "%T","You did +{iDamage} damage to {sTarget} with {sSkillName}", attacker, damage, sVictimName, sSkillName);
			// [%d] You did +%i damage to %s with %s
			PrintToConsole(attacker,"%T","[{MessageCount} You did +{iDamage} damage to {sTarget} with {sSkillName}", attacker, MessageCount[attacker], damage, sVictimName, sSkillName);
			// {default}[{red}%d{default}] You did [{green}+%d{default}] damage to [{green}%s{default}] with {green}%s{default} [{green}%s{default}]!
			War3_ChatMessage(attacker,"%T","[{MessageCount}] You did [+{iDamage}] damage to [{sTarget}] with {sSkillType} [{sSkillName}]!", attacker, MessageCount[attacker], damage, sVictimName, sSkillType, sSkillName);
		}
	}

	/*if(IsSkill)
	{
		if(!IsValidSkill(race,skillORitem)) return 0;

		if(GetRaceSkillName(race, skillORitem, sSkillName, sizeof(sSkillName))>0)
		{
			if(IsSkillUltimate(race, skillORitem))
			{
				//strcopy(sSkillType, sizeof(sSkillType), "ultimate");
				Format(sSkillType, sizeof(sSkillType), "%T", "ultimate", victim);
			}
			else
			{
				//strcopy(sSkillType, sizeof(sSkillType), "skill");
				Format(sSkillType, sizeof(sSkillType), "%T", "skill", victim);
			}
		}
		else
		{
			LogError("Notifications - NotifyPlayerTookDamageFunction - Lookup of GetRaceSkillName(%d,%d,%s,sizeof(%d))",race,skillORitem,sSkillName,sizeof(sSkillName));
			return 0;
		}
	}
	else
	{
		strcopy(sSkillType, sizeof(sSkillType), "%T", "item", victim);
	}*/
	if (NotifyTranslateFunction(victim,IsSkill,skillORitem,sSkillName,sSkillType) == 0) return 0;

	if(GetPlayerProp(victim,iCombatMessages)==1)
	{
		if(StrContains(MessageString1[victim], sTmpString)>-1 && attacker!=victim)
		{
			MessageCount[victim]+=damage;
			MessageTimer[victim]=GetGameTime();

			W3Hint(victim, HINT_DMG_RCVD, 0.5, "%T", "{sAttackerName} did {iDamage} damage to you with {sSkillName}", victim, sAttackerName, damage, sSkillName);
			PrintToConsole(victim, "%T", "[{MessageCount} {sAttackerName} did {iDamage} damage to you with {sSkillName}", victim, MessageCount[victim], sAttackerName, damage, sSkillName);
			War3_ChatMessage(victim,"%T","[{MessageCount}] [{sAttackerName}] did [+{iDamage}] damage to you with {sSkillType} [{sSkillName}] as a {sRaceName}!", victim, MessageCount[victim], sAttackerName, damage, sSkillType, sSkillName, sRaceName);
		}
		else if(attacker!=victim)
		{
			MessageCount[victim]=damage;
			MessageTimer[victim]=GetGameTime();
			strcopy(MessageString1[victim], 255, sTmpString);

			W3Hint(victim, HINT_DMG_RCVD, 0.5, "%T", "{sAttackerName} did {iDamage} damage to you with {sSkillName}", victim, sAttackerName, damage, sSkillName);
			PrintToConsole(victim, "%T", "[{MessageCount} {sAttackerName} did {iDamage} damage to you with {sSkillName}", victim, MessageCount[victim], sAttackerName, damage, sSkillName);
			War3_ChatMessage(victim,"%T","[{MessageCount}] [{sAttackerName}] did [+{iDamage}] damage to you with {sSkillType} [{sSkillName}] as a {sRaceName}!", victim, MessageCount[victim], sAttackerName, damage, sSkillType, sSkillName, sRaceName);
		}
	}
	return 1;
}


public Native_NotifyPlayerTookDamageFromSkill(Handle:plugin, numParams)
{
	new victim = GetNativeCell(1);
	new attacker = GetNativeCell(2);
	new damage = GetNativeCell(3);
	new skill = GetNativeCell(4);

	if (skill == 0)
	{
		return;
	}

	if(!ValidPlayer(attacker) || !ValidPlayer(victim)) return;

	NotifyPlayerTookDamageFunction(victim,attacker,damage,skill,true);
}

public Native_NotifyPlayerTookDamageFromItem(Handle:plugin, numParams)
{
	new victim = GetNativeCell(1);
	new attacker = GetNativeCell(2);
	new damage = GetNativeCell(3);
	new item = GetNativeCell(4);

	if (item == 0)
	{
		return;
	}

	if(!ValidPlayer(attacker) || !ValidPlayer(victim)) return;

	NotifyPlayerTookDamageFunction(victim,attacker,damage,item,false);
}


NotifyPlayerLeechedHealthFunction(victim,attacker,health,skillORitem,bool:IsSkill)
{
	MessageTimerFunction(attacker,victim);

	new String:sAttackerName[32];
	GetClientName(attacker, sAttackerName, sizeof(sAttackerName));

	new String:sVictimName[32];
	GetClientName(victim, sVictimName, sizeof(sVictimName));

	new String:sSkillName[32];
	new String:sSkillType[32];
	new String:sRaceName[32];

	new race = GetRace(attacker);
	GetRaceName(race,sRaceName,sizeof(sRaceName));

	//SetTrans(attacker);
	/*if(IsSkill)
	{
		if(GetRaceSkillName(race, skillORitem, sSkillName, sizeof(sSkillName))>0)
		{
			if(IsSkillUltimate(race, skillORitem))
			{
				strcopy(sSkillType, sizeof(sSkillType), "ultimate");
			}
			else
			{
				strcopy(sSkillType, sizeof(sSkillType), "skill");
			}
		}
		else
		{
			LogError("Notifications - NotifyPlayerLeechedHealthFunction - Lookup of GetRaceSkillName(%d,%d,%s,sizeof(%d))",race,skillORitem,sSkillName,sizeof(sSkillName));
			return 0;
		}
	}
	else
	{
		W3GetItemName(skillORitem, sSkillName, sizeof(sSkillName));
		strcopy(sSkillType, sizeof(sSkillType), "item");
	}*/
	if (NotifyTranslateFunction(attacker,IsSkill,skillORitem,sSkillName,sSkillType) == 0) return 0;


	decl String:sTmpString[256];
	Format(sTmpString,sizeof(sTmpString)," %s %s", sAttackerName, sSkillName);
	//DP(sTmpString);

	if(GetPlayerProp(attacker,iCombatMessages)==1)
	{
		if(StrContains(MessageString1[attacker], sTmpString)>-1)
		{
			MessageCount[attacker]+=health;
			MessageTimer[attacker]=GetGameTime();

			W3Hint(attacker, HINT_DMG_DEALT, 0.5, "%T", "You leeched +{iHealth} health from {sVictimName} with {sSkillName}", attacker, health, sVictimName, sSkillName);
			PrintToConsole(attacker, "%T", "[{MessageCount}] You leeched +{iHealth} health from {sVictimName} with {sSkillName}", attacker, MessageCount[attacker], health, sVictimName, sSkillName);
			War3_ChatMessage(attacker, "%T", "[{MessageCount}] You leeched [+{iHealth}] health from [{sVictimName}] with {sSkillType} [{sSkillName}]!", attacker, MessageCount[attacker], health, sVictimName, sSkillType, sSkillName);
		}
		else
		{
			MessageCount[attacker]=health;
			MessageTimer[attacker]=GetGameTime();
			strcopy(MessageString1[attacker], 255, sTmpString);

			W3Hint(attacker, HINT_DMG_DEALT, 0.5, "%T", "You leeched +{iHealth} health from {sVictimName} with {sSkillName}", attacker, health, sVictimName, sSkillName);
			PrintToConsole(attacker, "%T", "[{MessageCount}] You leeched +{iHealth} health from {sVictimName} with {sSkillName}", attacker, MessageCount[attacker], health, sVictimName, sSkillName);
			War3_ChatMessage(attacker, "%T", "[{MessageCount}] You leeched [+{iHealth}] health from [{sVictimName}] with {sSkillType} [{sSkillName}]!", attacker, MessageCount[attacker], health, sVictimName, sSkillType, sSkillName);
		}
	}

	if (NotifyTranslateFunction(victim,IsSkill,skillORitem,sSkillName,sSkillType) == 0) return 0;

	if(GetPlayerProp(victim,iCombatMessages)==1)
	{
		if(StrContains(MessageString1[victim], sTmpString)>-1 && attacker!=victim)
		{
			MessageCount[victim]+=health;
			MessageTimer[victim]=GetGameTime();

			W3Hint(victim, HINT_DMG_RCVD, 0.5, "%T", "{sAttackerName} leeched {iHealth} health from you with {sSkillName}", victim, sAttackerName, health, sSkillName);
			PrintToConsole(victim, "%T", "[{MessageCount}] {sAttackerName} leeched {iHealth} health from you with {sSkillName}", victim, MessageCount[victim], sAttackerName, health, sSkillName);
			War3_ChatMessage(victim, "%T", "[{MessageCount}] [{sAttackerName}] leeched [+{iHealth}] health from you with {sSkillType} [{sSkillName}] as a {sRaceName}!", victim, MessageCount[victim], sAttackerName, health, sSkillType, sSkillName, sRaceName);
		}
		else if(attacker!=victim)
		{
			MessageCount[victim]=health;
			MessageTimer[victim]=GetGameTime();
			strcopy(MessageString1[victim], 255, sTmpString);

			W3Hint(victim, HINT_DMG_RCVD, 0.5, "%T", "{sAttackerName} leeched {iHealth} health from you with {sSkillName}", victim, sAttackerName, health, sSkillName);
			PrintToConsole(victim, "%T", "[{MessageCount}] {sAttackerName} leeched {iHealth} health from you with {sSkillName}", victim, MessageCount[victim], sAttackerName, health, sSkillName);
			War3_ChatMessage(victim, "%T", "[{MessageCount}] [{sAttackerName}] leeched [+{iHealth}] health from you with {sSkillType} [{sSkillName}] as a {sRaceName}!", victim, MessageCount[victim], sAttackerName, health, sSkillType, sSkillName, sRaceName);
		}
	}

	War3_VampirismEffect(victim, attacker, health);
	return 1;
}

public Native_NotifyPlayerLeechedFromSkill(Handle:plugin, numParams)
{
	new victim = GetNativeCell(1);
	new attacker = GetNativeCell(2);
	new health = GetNativeCell(3);
	new skill = GetNativeCell(4);

	if (skill == 0)
	{
		return;
	}

	if(!ValidPlayer(attacker) || !ValidPlayer(victim)) return;

	NotifyPlayerLeechedHealthFunction(victim,attacker,health,skill,true);
}
public Native_NotifyPlayerLeechedFromItem(Handle:plugin, numParams)
{
	new victim = GetNativeCell(1);
	new attacker = GetNativeCell(2);
	new health = GetNativeCell(3);
	new item = GetNativeCell(4);

	if (item == 0)
	{
		return;
	}

	if(!ValidPlayer(attacker) || !ValidPlayer(victim)) return;

	NotifyPlayerLeechedHealthFunction(victim,attacker,health,item,false);
}


//=============================================================================
// Notify immune from skill
//=============================================================================

NotifyPlayerImmuneFromSkillOrItem(attacker,victim,skillORitem,bool:IsSkill)
{
	if(MessageTimer_Immunities[attacker]<(GetGameTime()-5.0))
	{
		strcopy(MessageString_Immunities[attacker], 255, "");
	}
	if(MessageTimer_Immunities[victim]<(GetGameTime()-5.0))
	{
		strcopy(MessageString_Immunities[victim], 255, "");
	}


	new race = GetRace(attacker);

	if(!IsValidRace(race)) return 0;

	new String:sAttackerName[32];
	GetClientName(attacker, sAttackerName, sizeof(sAttackerName));

	new String:sVictimName[32];
	GetClientName(victim, sVictimName, sizeof(sVictimName));

	//new race = GetRace(attacker);
	new String:sSkillName[32];
	new String:sSkillType[32];

	//SetTrans(attacker);
	//if(skillORitem==0)
	//{
		//if(IsSkill)
		//{
			//strcopy(sSkillName, sizeof(sSkillName), "unknown");
			//strcopy(sSkillType, sizeof(sSkillType), "skill/ultimate");
		//}
		//else
		//{
			//strcopy(sSkillName, sizeof(sSkillName), "unknown");
			//strcopy(sSkillType, sizeof(sSkillType), "item");
		//}
	//}
	//else
	//{
	/*if(IsSkill)
	{
		if(!IsValidSkill(race,skillORitem)) return 0;

		if(GetRaceSkillName(race, skillORitem, sSkillName, sizeof(sSkillName))>0)
		{
			if(IsSkillUltimate(race, skillORitem))
			{
				strcopy(sSkillType, sizeof(sSkillType), "ultimate");
			}
			else
			{
				strcopy(sSkillType, sizeof(sSkillType), "skill");
			}
		}
		else
		{
			LogError("Notifications - NotifyPlayerImmuneFromSkillOrItem - Lookup of GetRaceSkillName(%d,%d,%s,sizeof(%d))",race,skillORitem,sSkillName,sizeof(sSkillName));
			return 0;
		}
	}
	else
	{
		W3GetItemName(skillORitem, sSkillName, sizeof(sSkillName));
		strcopy(sSkillType, sizeof(sSkillType), "item");
	}*/
	if (NotifyTranslateFunction(victim,IsSkill,skillORitem,sSkillName,sSkillType) == 0) return 0;

	//}

	//new health=1;

	decl String:sTmpString[256];
	Format(sTmpString,sizeof(sTmpString)," %s %s", sAttackerName, sSkillName);
	//DP(sTmpString);

	if(GetPlayerProp(victim,iCombatMessages)==1)
	{
		/*if(StrContains(MessageString1[victim], sTmpString)>-1)
		{
			MessageCount[victim]+=health;
			MessageTimer[victim]=GetGameTime();

			W3Hint(victim, HINT_DMG_DEALT, 0.5, "You are immune to %s from %s", sSkillName, sAttackerName);
			PrintToConsole(victim, "[%d] You are immune to %s from %s", MessageCount[victim], sSkillName, sVictimName);
			War3_ChatMessage(victim,"{default}[{blue}%d{default}] You are immune to %s [{green}%s{default}] from [{green}%s{default}]!", MessageCount[victim], sSkillType, sSkillName, sAttackerName);
		}
		else
		*/

		//MessageTimer[attacker]<(GetGameTime()-5.0)
		if(MessageTimer_Immunities[victim]<(GetGameTime()-1.0) && StrContains(MessageString_Immunities[victim], sTmpString)==-1)
		{
			//MessageCount[victim]=health;
			//MessageTimer[victim]=GetGameTime();
			MessageTimer_Immunities[victim]=GetGameTime();
			strcopy(MessageString_Immunities[victim], 255, sTmpString);

			W3Hint(victim, HINT_DMG_DEALT, 0.5, "%T", "You are immune to {sSkillName} from {sAttackerName}", victim, sSkillName, sAttackerName);
			PrintToConsole(victim, "%T", "You are immune to {sSkillName} from {sAttackerName}", victim, sSkillName, sVictimName);
			War3_ChatMessage(victim, "%T", "You are immune to {sSkillType} [{sSkillName}] from [{sAttackerName}]!", victim, sSkillType, sSkillName, sAttackerName);
		}
	}

	if (NotifyTranslateFunction(attacker,IsSkill,skillORitem,sSkillName,sSkillType) == 0) return 0;


	if(GetPlayerProp(attacker,iCombatMessages)==1)
	{
		/*if(StrContains(MessageString1[attacker], sTmpString)>-1 && attacker!=victim)
		{
			MessageCount[attacker]+=health;
			MessageTimer[attacker]=GetGameTime();

			W3Hint(attacker, HINT_DMG_RCVD, 0.5, "%s is immune to %s", sVictimName, sSkillName);
			PrintToConsole(attacker, "[%d] %s is immune to %s", MessageCount[attacker], sVictimName, sSkillName);
			War3_ChatMessage(attacker,"{default}[{blue}%d{default}] [{green}%s{default}] is immune to {green}%s{default} [{green}%s{default}]!", MessageCount[attacker], sVictimName, sSkillType, sSkillName);
		}
		else*/
		if(MessageTimer_Immunities[attacker]<(GetGameTime()-1.0) && StrContains(MessageString_Immunities[attacker], sTmpString)==-1 && attacker!=victim)
		{
			//MessageCount[attacker]=health;
			//MessageTimer[attacker]=GetGameTime();
			MessageTimer_Immunities[attacker]=GetGameTime();
			strcopy(MessageString_Immunities[attacker], 255, sTmpString);

			W3Hint(attacker, HINT_DMG_RCVD, 0.5, "%T", "{sVictimName} is immune to {sSkillName}", attacker, sVictimName, sSkillName);
			PrintToConsole(attacker, "%T", "{sVictimName} is immune to {sSkillName}", attacker, sVictimName, sSkillName);
			War3_ChatMessage(attacker, "%T", "[{sVictimName}] is immune to {sSkillType} [{sSkillName}]!", attacker, sVictimName, sSkillType, sSkillName);
		}
	}
	return 1;
}

public Native_NotifyPlayerImmuneFromSkill(Handle:plugin, numParams)
{
	if(numParams != 3) {
		return ThrowNativeError(SP_ERROR_NATIVE,"numParams is invalid!");
	}

	new skill = GetNativeCell(3);

	if(skill < 1)
	{
		return 0;
	}

	new attacker = GetNativeCell(1);
	new victim = GetNativeCell(2);

	if(!ValidPlayer(attacker) || !ValidPlayer(victim)) return 0;

	return NotifyPlayerImmuneFromSkillOrItem(attacker,victim,skill,true);
}

public Native_NotifyPlayerImmuneFromItem(Handle:plugin, numParams)
{
	if(numParams != 3) {
		return ThrowNativeError(SP_ERROR_NATIVE,"numParams is invalid!");
	}

	new item = GetNativeCell(3);

	if (item < 1)
	{
		return 0;
	}

	new attacker = GetNativeCell(1);
	new victim = GetNativeCell(2);

	if(!ValidPlayer(attacker) || !ValidPlayer(victim)) return 0;

	return NotifyPlayerImmuneFromSkillOrItem(attacker,victim,item,false);
}
//=============================================================================
// Buff Notifications
//=============================================================================

// Internally forwarded via War3's on EVENT process:
//	internal_W3SetVar(EventArg1,buffindex); //generic war3event arguments
//	internal_W3SetVar(EventArg2,itemraceindex);
//	internal_W3SetVar(EventArg3,value);
//	W3CreateEvent(W3EVENT:OnBuffChanged,client);
//
// You'll need to capture the event example:


//I want to create a new War3Buff system where you tell war3buff that the person giving the buff is the attacker or
//is a person whom is not the client or store the OWNER of the buff into the information for OnBuffChanged..
//Then this can compare values and stuff to find out if the OWNER and client is friendly or the buff is good or not to
//give proper warnings.


public War3Source_Engine_Notifications_OnWar3Event(client){
		if(GetPlayerProp(client,iCombatMessages)==0)
		{
			return;
		}
		//internal_W3SetVar(EventArg1,buffindex); //generic war3event arguments
		//internal_W3SetVar(EventArg2,itemraceindex);
		//internal_W3SetVar(EventArg3,value);
		//internal_W3SetVar(EventArg4,buffowner);
		//W3CreateEvent(W3EVENT:OnBuffChanged,client);

		// Client is the person being affected by the buff,
		// where as the buffowner is the one whom created the buff
		new W3Buff:buffindex=W3Buff:internal_W3GetVar(EventArg1);
		//new itemraceindex=internal_W3GetVar(EventArg2);
		new any:value=internal_W3GetVar(EventArg3);
		new buffowner=internal_W3GetVar(EventArg4);

		// if both validplayers and alive
		//&& (MessageTimer[client]<(GetGameTime()-0.1))
		if((buffowner>-1) && ValidPlayer(client,true) && ValidPlayer(buffowner,true))
		{
			if(client!=buffowner)
			{
				// Record buff, so not to repeat itself.
				//MessageEventType[client]=buffindex;
				if(GetClientTeam(client)!=GetClientTeam(buffowner))
				{
					if(buffindex==fSlow)
					{
						new String:OwnerName[64];
						GetClientName(buffowner,OwnerName,sizeof(OwnerName));
						War3_ChatMessage(client,"%T","[SLOW SKILL] You're being slowed by {OwnerName}!",client,OwnerName);
						W3Hint(client,HINT_SKILL_STATUS,0.5,"%T","[SLOW] You are slowed by {OwnerName}!",client,OwnerName);
					}
					else if(buffindex==fHPDecay)
					{
						new String:OwnerName[64];
						GetClientName(buffowner,OwnerName,sizeof(OwnerName));
						War3_ChatMessage(client,"%T","[HPDECAY SKILL] Your health is being drained by {OwnerName}!",client,OwnerName);
						W3Hint(client,HINT_SKILL_STATUS,0.5,"%T","[HP DECAY] Health is drained by {OwnerName}!",client,OwnerName);
					}
					else if(buffindex==bStunned)
					{
						new String:OwnerName[64];
						GetClientName(buffowner,OwnerName,sizeof(OwnerName));
						War3_ChatMessage(client,"%T","[STUN] You are stunned by {OwnerName}!",client,OwnerName);
						W3Hint(client,HINT_SKILL_STATUS,0.5,"%T","[STUN] You are stunned!",client);
					}
					else if(buffindex==bBashed)
					{
						new String:OwnerName[64];
						GetClientName(buffowner,OwnerName,sizeof(OwnerName));
						War3_ChatMessage(client,"%T","[BASHED] You are bashed by {OwnerName}!",client,OwnerName);
						W3Hint(client,HINT_SKILL_STATUS,0.5,"%T","[BASHED] You are bashed!",client);
					}
					else if(buffindex==bDisarm)
					{
						new String:OwnerName[64];
						GetClientName(buffowner,OwnerName,sizeof(OwnerName));
						War3_ChatMessage(client,"%T","[DISARM] You are disarmed by {OwnerName}!",client,OwnerName);
						W3Hint(client,HINT_SKILL_STATUS,0.5,"%T","[DISARM] You are disarmed!",client);
					}
					else if(buffindex==bSilenced)
					{
						new String:OwnerName[64];
						GetClientName(buffowner,OwnerName,sizeof(OwnerName));
						War3_ChatMessage(client,"%T","[SILENCED] You are silenced by {OwnerName}!",client,OwnerName);
						W3Hint(client,HINT_SKILL_STATUS,0.5,"%T","[SILENCED] You are silenced!",client);
					}
					else if(buffindex==bHexed)
					{
						new String:OwnerName[64];
						GetClientName(buffowner,OwnerName,sizeof(OwnerName));
						War3_ChatMessage(client,"%T","[HEXED] You are hexed by {OwnerName}!",client,OwnerName);
						W3Hint(client,HINT_SKILL_STATUS,0.5,"%T","[HEXED] You are hexed!",client);
					}
					else if(buffindex==bPerplexed)
					{
						new String:OwnerName[64];
						GetClientName(buffowner,OwnerName,sizeof(OwnerName));
						War3_ChatMessage(client,"%T","[PERPLEXED] You are perplexed by {OwnerName}!",client,OwnerName);
						W3Hint(client,HINT_SKILL_STATUS,0.5,"%T","[PERPLEXED] You are perplexed!",client);
					}
					else if(buffindex==bNoMoveMode)
					{
						new String:OwnerName[64];
						GetClientName(buffowner,OwnerName,sizeof(OwnerName));
						War3_ChatMessage(client,"%T","[NO MOVE] You are unable to move by {OwnerName}!",client,OwnerName);
						W3Hint(client,HINT_SKILL_STATUS,0.5,"%T","[NO MOVE] You are unable to move!",client);
					}
				}
				else
				{
					if(buffindex==fArmorPhysical && float(value)>0.0)
					{
						new String:OwnerName[64];
						GetClientName(buffowner,OwnerName,sizeof(OwnerName));
						War3_ChatMessage(client,"%T","[ARMOR BUFF({iValue})] You're being buffed by {OwnerName}!",client,float:value,OwnerName);
						W3Hint(client,HINT_SKILL_STATUS,0.5,"%T","[ARMOR BUFF] You are buffed by {OwnerName}!",client,OwnerName);
					}
				}
				/*
				else if(TF2_GetPlayerClass(buffowner) == TFClass_Medic)
				{
					if(buffindex==fMaxSpeed2)
					{
						//War3_ChatMessage(client,"{default}[{blue}EXTRA SPEED{default}] Medic's Medi Beam is giving you extra speed!");
						W3Hint(client,HINT_SKILL_STATUS,0.5,"[EXTRA SPEED] You move faster!");
						//MessageTimer[client]=GetGameTime();
					}
					else if(buffindex==fHPRegen)
					{
						//War3_ChatMessage(client,"{default}[{blue}EXTRA REGEN{default}] Medic's Medi Beam is giving you extra regeneration!");
						W3Hint(client,HINT_SKILL_STATUS,0.5,"[EXTRA REGEN] You regen faster!");
						//MessageTimer[client]=GetGameTime();
					}
					else if(buffindex==iAdditionalMaxHealth)
					{
						//War3_ChatMessage(client,"{default}[{blue}EXTRA REGEN{default}] Medic's Medi Beam is giving you extra health!");
						W3Hint(client,HINT_SKILL_STATUS,0.5,"[EXTRA HEALTH] You have more health!");
						//MessageTimer[client]=GetGameTime();
					}
				}*/
			}
			else
			{
				if(GetClientTeam(client)==GetClientTeam(buffowner))
				{
					if(buffindex==fArmorPhysical && float(value)>0.0)
					{
						new String:OwnerName[64];
						GetClientName(buffowner,OwnerName,sizeof(OwnerName));
						War3_ChatMessage(client, "%T", "[ARMOR BUFF({iValue})] You ({OwnerName}) are being buffed!",client,float:value,OwnerName);
						W3Hint(client,HINT_SKILL_STATUS,0.5,"%T","[ARMOR BUFF] You ({OwnerName}) are buffed!",client,OwnerName);
					}
				}
			}
		}
		//DP("EVENT OnBuffChanged",event);
	//DP("EVENT %d",event);
}
