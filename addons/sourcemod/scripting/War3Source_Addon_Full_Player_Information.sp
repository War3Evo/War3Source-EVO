
#include <war3source>

float MessageTimer[MAXPLAYERSCUSTOM];

public Plugin:myinfo=
{
	name="War3Source:EVO Addon - Full Player Information",
	author="El Diablo",
	description="War3Source:EVO Addon Plugin",
	version="1.0",
};

public OnPluginStart()
{
	RegConsoleCmd("sm_getdetails",War3Source_DetailsCommand);

	LoadTranslations("common.phrases");
}

public void OnClientPutInServer(int client)
{
	MessageTimer[client]=0.0;
}

public Action War3Source_DetailsCommand(int client, int args)
{
	char command[32];
	if(GetCmdArg(1,command,sizeof(command))>0)
	{
		//PrintToChatAll(command);

		// FindTarget must have LoadTranslations("common.phrases"); with it.
		int target = FindTarget(client, command, false, false);

		if(target>0)
		{
			//PrintToChatAll("target %d",target);
			War3_playertargetConsole(client,target);
			return Plugin_Handled;
		}
		//else
		//{
			//PrintToChatAll("error");
		//}
	}
	else
	{
		//PrintToChatAll("no command");
		Handle hMenu=CreateMenu(War3_playerinfoSelected1);
		SetMenuExitButton(hMenu,true);
		SetMenuTitle(hMenu,"[War3Source:EVO] Select a player to print to console",client);
		// Iteriate through the players and print them out
		char playername[32];
		char war3playerbuf[4];
		char menuitem[100] ;
		LoopIngameClients(clientindex)
		{
			Format(war3playerbuf,sizeof(war3playerbuf),"%d",clientindex);  //target index
			GetClientName(clientindex,playername,sizeof(playername));

			Format(menuitem,sizeof(menuitem),"%s",playername);

			AddMenuItem(hMenu,war3playerbuf,menuitem);

		}
		DisplayMenu(hMenu,client,120);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}



public War3_playerinfoSelected1(Handle:menu,MenuAction:action,client,selection)
{
	if(action==MenuAction_Select)
	{
		decl String:SelectionInfo[4];
		decl String:SelectionDispText[256];
		new SelectionStyle;
		GetMenuItem(menu,selection,SelectionInfo,sizeof(SelectionInfo),SelectionStyle, SelectionDispText,sizeof(SelectionDispText));
		new target=StringToInt(SelectionInfo);
		if(ValidPlayer(target))
			War3_playertargetConsole(client,target);
		else
			War3_ChatMessage(client,"Player has left the server");
	}
	if(action==MenuAction_End)
	{
		CloseHandle(menu);
	}
}

/*

enum W3Buff
{
	buffdummy=0,
	bBuffDenyAll, //DENY=not allowed to have any buffs, aka "purge" //1

	// REMOVED GRAVITY VIA War3Source_Engine_BuffSpeedGravGlow.sp line 104-124 was commented out
	fLowGravitySkill, //0.4 ish? //2
	fLowGravityItem, //0.4 ish? //3
	bLowGravityDenyAll, //4

	fInvisibilitySkill, //0.4 ish? //5
	fInvisibilityItem, //0.4 ish? //6
	bInvisibilityDenyAll, //7
	bInvisibilityDenySkill, //needed for orc //8
	bDoNotInvisWeapon, //9
	bInvisWeaponOverride, //set true to use override amount, ONLY 1 RACE SHALL USE THIS AT A TIME PER CLIENT //10
	iInvisWeaponOverrideAmount, ///amolunt of 0-255 , do not have to set back to 255, just set bInvisWeaponOverride to false
	//11

	fMaxSpeed, //for increasing speeds only! MUST BE MORE THAN 1.0
	fMaxSpeed2, //for increasing speeds only!, added onto fMaxSpeed buff, MUST BE MORE THAN 1.0
	//13

	fSlow, //for decreeasing speeds only! MUST BE LESS THAN 1.0
	fSlow2, //for decreeasing speeds only! MUST BE LESS THAN 1.0. allows a race to have stacking slows
	bSlowImmunity, //immune to slow?
	//16

	bImmunitySkills, //is immune to skills
	bImmunityUltimates, // is immune to ultimates
	bImmunityWards, // is immune to wards, skill immunity includes ward immunity
	bImmunityPiercing, // is immune to Piercing
	bImmunityAbilities, // is immune to abilities
	//21

	fAttackSpeed, //attack speed multipler!    // does not stack, keeps maximum (used to be fStacked)
	//22

	bStunned, //cannot shoot, cannot cast, cannot move, basically everything below
	bBashed, //cannot move
	bDisarm,//cannot shoot
	bSilenced,  //cannot cast
	bHexed,  // no skill proc
	bPerplexed, //cannot use items / proc items
	//28

	bNoMoveMode,//move type none! overrrides all other movestypes
	bFlyMode,   //fly mode
	bFlyModeDeny,
	bNoClipMode,
	//32

	fArmorPhysical, // does stack
	bfArmorPhysicalDenyAll,
	fArmorMagic, // does stack
	bArmorMagicDenyAll,
	//36

	//DO NOT USE GLOW FOR INVIS
	iGlowRed, //glowing the player 0-255
	iGlowGreen,
	iGlowBlue,
	iGlowAlpha, //careful this is like invisiblity
	iGlowPriority, //highest priority takes effect
	fGlowSetTime, //time is recorded, those with same prioirty will compete via time. not something u set
	//42

	fHPRegen, ///float sum! NO NEGATIVES! MINIM regin rate is 0.5 / second ( 1 hp per 2 seconds)
	fHPDecay, //float sum, NO NEGATIVES, postive means lose this much HP / second, same requirements as fHPRegen
	fHPRegenDeny, //set true to deny hp regen
	iAdditionalMaxHealth,   ///increase / decrease in maxhp
	fMaxHealth,   // Set percentage of max health after bonuses of iAdditionalMaxHealth
				// if 300 max health after all bonuses * 0.50 = 150 max health
	//46

	// DODGE MELEE ONLY
	fDodgeChance, //Registers a chance to dodge, (Note: 0.7 would equal a 70% chance to dodge)
	bDodgeMode, //Set 0 for Pre, 1 for post (quick regen)
	//49

	fVampirePercent, //Sets a % of damage done to give back as health
	fVampirePercentNoBuff, // Same as fVampirePercent, but doesn't overheal
	fMeleeVampirePercent, // Sets a % of damage done to give back as health when the damage was caused by melee
	fMeleeVampirePercentNoBuff, // Same as fMeleeVampirePercent, but doesn't overheal
	//53

	fBashChance, //Registers a chance to bash, (Note: 0.7 would equal a 70% chance to bash)
	iBashDamage, //Does a certain amount of damage when you bash an enemy (more similar to warcraft 3's bash, default 0)
	fBashDuration, //Sets the duration of bash's stun
	//56

	fCritChance, //Registers a chance to crit, (Note: 0.7 would equal a 70% chance to crit)
	iCritMode, //Default 0 (0 is off / none) -- (all damage qualifies for crit) = 1 (bullet damage crit) = 2 (grenade damage crit) = 3 (melee damage crit) = 4 (melee and bullet crit) = 5 (melee and grenade crit) = 6 (bullet and grenade crit) = 7
	fCritModifier, //Sets the critical strike modifer, default 1.0
	//59

	iDamageMode, //Default (none) 0 (all damage qualifies for damage increase) 1 (bullet damage damage increase) 2 (grenade damage damage increase) 3 (melee damage damage increase) 4 (melee and bullet damage increase) 5 (melee and grenade damage increase) 6 (bullet and grenade damage increase)
	//60

	iDamageBonus, //Gives a direct increase to damage done
	fDamageModifier, //Gives a % increase to damage done
	//62

	iAdditionalMaxHealthNoHPChange,   ///increase / decrease in maxhp. NO AUTOMATIC HP CHANGE WHEN BUFF IS CHANGED
	//63

	bImmunityPoison,   // immunity to poisons
	//64

	// DODGE RANGED ONLY
	fDodgeChanceRanged, //Registers a chance to dodge ranged attacks, (Note: 0.7 would equal a 30% chance to dodge)
	//65

	bImmunityHacks,  // immunity to hacks

	bImmunityExtra, // immunity to something?  This is Extra just in case we need to add another immunity
	bImmunityExtra2, // immunity to something?  This is Extra2 just in case we need to add another immunity
	bImmunityExtra3, // immunity to something?  This is Extra3 just in case we need to add another immunity

	MaxBuffLoopLimitTemp, //this is a variable that is for loops, this number is automatically generated from the enum.
}
*/

public void fPTC(int client, char[] MyString,float MyFloat)
{
	PrintToConsole(client,"%s = %.2f",MyString,MyFloat);
	LogPlayerDetails("%s = %.2f",MyString,MyFloat);
}

public void iPTC(int client, char[] MyString,int MyInt)
{
	PrintToConsole(client,"%s = %d",MyString,MyInt);
	LogPlayerDetails("%s = %d",MyString,MyInt);
}

public void sPTC(int client, char[] MyString,char[] MyString2)
{
	PrintToConsole(client,"%s = %s",MyString,MyString2);
	LogPlayerDetails("%s = %s",MyString,MyString2);
}

public void bPTC(int client, char[] MyString,bool MyBoolean)
{
	PrintToConsole(client,"%s = %s",MyString,MyBoolean?"TRUE":"FALSE");
	LogPlayerDetails("%s = %s",MyString,MyBoolean?"TRUE":"FALSE");
}

public void W3GetBuffHasTrueLocal(int client, int target, char[] MyString, W3Buff buffIndex)
{
	W3GetBuffHasTrue(target,buffIndex)==true?bPTC(client,MyString,true):bPTC(client,MyString,false);
}

public void W3GetBuffMinFloatLocal(int client, int target, char[] MyString, W3Buff buffIndex)
{
	fPTC(client,MyString,W3GetBuffMinFloat(target,buffIndex));
}

public void W3GetBuffMaxFloatLocal(int client, int target, char[] MyString, W3Buff buffIndex)
{
	fPTC(client,MyString,W3GetBuffMaxFloat(target,buffIndex));
}

public void W3GetBuffMinIntLocal(int client, int target, char[] MyString, W3Buff buffIndex)
{
	iPTC(client,MyString,W3GetBuffMinInt(target,buffIndex));
}

public void W3GetBuffStackedFloatLocal(int client, int target, char[] MyString, W3Buff buffIndex)
{
	fPTC(client,MyString,W3GetBuffStackedFloat(target,buffIndex));
}

public void W3GetBuffSumFloatLocal(int client, int target, char[] MyString, W3Buff buffIndex)
{
	fPTC(client,MyString,W3GetBuffSumFloat(target,buffIndex));
}

public void W3GetBuffSumIntLocal(int client, int target, char[] MyString, W3Buff buffIndex)
{
	iPTC(client,MyString,W3GetBuffSumInt(target,buffIndex));
}

public void W3GetBuffLastValueLocal(int client, int target, char[] MyString, W3Buff buffIndex)
{
	iPTC(client,MyString,W3GetBuffLastValue(target,buffIndex));
}


stock LogPlayerDetails(const String:logMsg[],any:...)
{
	new String:myFormattedString[4096];
	VFormat(myFormattedString, sizeof(myFormattedString), logMsg, 2 );
	PrintToServer("%s",myFormattedString);

	decl String:date[32];
	FormatTime(date, sizeof(date), "%m_%d_%y");

	new String:path[256];
	BuildPath(Path_SM, path, sizeof(path), "logs/Player_Details_%s.log",date);

	LogToFileEx(path, "%s",myFormattedString);
}


War3_playertargetConsole(client,target)
{
	if(!ValidPlayer(client) || !ValidPlayer(target)) return;

	AdminId admin = GetUserAdmin(client);
	if(admin==INVALID_ADMIN_ID)
	{
		if(MessageTimer[client]>GetGameTime())
		{
			War3_ChatMessage(client,"You must wait before you can use this command again.");
			return;
		}
	}

	MessageTimer[client]=GetGameTime()+30.0;

	char targetname[32];
	char clientname[32];
	char buffer[32];
	GetClientName(client,clientname,sizeof(clientname));
	GetClientName(target,targetname,sizeof(targetname));

	PrintToConsole(client,"-------------------- START OF DETAILS LIST -------------------"); //iLastValue
	LogPlayerDetails("--------------------------------------------------------------"); //iLastValue
	LogPlayerDetails("-------------------- START OF DETAILS LIST -------------------"); //iLastValue

	char steamid[32];
	GetClientAuthId(client,AuthId_Steam2,STRING(steamid),true);
	LogPlayerDetails("Client Name: %s",clientname);
	LogPlayerDetails("Client STEAMID: %s",steamid);

	PrintToConsole(client,"Target Name: %s",targetname);

	GetClientAuthId(target,AuthId_Steam2,STRING(steamid),true);
	LogPlayerDetails("Target Name: %s",targetname);
	LogPlayerDetails("Target STEAMID: %s",steamid);

	int RaceID = War3_GetRace(target);

	if(RaceID>0)
	{
		War3_GetRaceName(RaceID,buffer,sizeof(buffer));

		PrintToConsole(client,"Target Race: %s",buffer);
		LogPlayerDetails("Target Race: %s",buffer);

		PrintToConsole(client,"Target Race Level: %d",War3_GetLevel(target,RaceID));
		LogPlayerDetails("Target Race Level: %d",War3_GetLevel(target,RaceID));
	}
	else
	{
		PrintToConsole(client,"Target Race: NONE");
		LogPlayerDetails("Target Race: NONE");
	}

	PrintToConsole(client,"W3GetBuffHasTrue:");
	LogPlayerDetails("W3GetBuffHasTrue:");

	W3GetBuffHasTrueLocal(client,target,"bBuffDenyAll",bBuffDenyAll);
	W3GetBuffHasTrueLocal(client,target,"bLowGravityDenyAll",bLowGravityDenyAll);
	W3GetBuffHasTrueLocal(client,target,"bInvisibilityDenyAll",bInvisibilityDenyAll);
	W3GetBuffHasTrueLocal(client,target,"bInvisibilityDenySkill",bInvisibilityDenySkill);
	W3GetBuffHasTrueLocal(client,target,"bDoNotInvisWeapon",bDoNotInvisWeapon);
	W3GetBuffHasTrueLocal(client,target,"bInvisWeaponOverride",bInvisWeaponOverride);
	W3GetBuffHasTrueLocal(client,target,"bSlowImmunity",bSlowImmunity);
	W3GetBuffHasTrueLocal(client,target,"bImmunitySkills",bImmunitySkills);
	W3GetBuffHasTrueLocal(client,target,"bImmunityWards",bImmunityWards);
	W3GetBuffHasTrueLocal(client,target,"bImmunityUltimates",bImmunityUltimates);
	W3GetBuffHasTrueLocal(client,target,"bImmunityPiercing",bImmunityPiercing);
	W3GetBuffHasTrueLocal(client,target,"bImmunityAbilities",bImmunityAbilities);
	W3GetBuffHasTrueLocal(client,target,"bStunned",bStunned);
	W3GetBuffHasTrueLocal(client,target,"bBashed",bBashed);
	W3GetBuffHasTrueLocal(client,target,"bDisarm",bDisarm);
	W3GetBuffHasTrueLocal(client,target,"bSilenced",bSilenced);
	W3GetBuffHasTrueLocal(client,target,"bPerplexed",bPerplexed);
	W3GetBuffHasTrueLocal(client,target,"bHexed",bHexed);
	W3GetBuffHasTrueLocal(client,target,"bNoMoveMode",bNoMoveMode);
	W3GetBuffHasTrueLocal(client,target,"bFlyMode",bFlyMode);
	W3GetBuffHasTrueLocal(client,target,"bFlyModeDeny",bFlyModeDeny);
	W3GetBuffHasTrueLocal(client,target,"bNoClipMode",bNoClipMode);
	W3GetBuffHasTrueLocal(client,target,"bfArmorPhysicalDenyAll",bfArmorPhysicalDenyAll);
	W3GetBuffHasTrueLocal(client,target,"bArmorMagicDenyAll",bArmorMagicDenyAll);
	W3GetBuffHasTrueLocal(client,target,"fHPRegenDeny",fHPRegenDeny);
	W3GetBuffHasTrueLocal(client,target,"bDodgeMode",bDodgeMode);
	W3GetBuffHasTrueLocal(client,target,"bImmunityPoison",bImmunityPoison);
	W3GetBuffHasTrueLocal(client,target,"bImmunityHacks",bImmunityHacks);
	W3GetBuffHasTrueLocal(client,target,"bImmunityExtra2",bImmunityExtra2);
	W3GetBuffHasTrueLocal(client,target,"bImmunityExtra3",bImmunityExtra3);

	PrintToConsole(client,"W3GetBuffMinFloat:"); //fMinimum
	LogPlayerDetails("W3GetBuffMinFloat:"); //fMinimum

	W3GetBuffMinFloatLocal(client,target,"fLowGravitySkill",fLowGravitySkill);
	W3GetBuffMinFloatLocal(client,target,"fLowGravityItem",fLowGravityItem);
	W3GetBuffMinFloatLocal(client,target,"fInvisibilitySkill",fInvisibilitySkill);
	W3GetBuffMinFloatLocal(client,target,"fInvisibilityItem",fInvisibilityItem);

	PrintToConsole(client,"W3GetBuffMinInt:"); //iMinimum
	LogPlayerDetails("W3GetBuffMinInt:"); //iMinimum

	W3GetBuffMinIntLocal(client,target,"iInvisWeaponOverrideAmount",iInvisWeaponOverrideAmount);

	PrintToConsole(client,"W3GetBuffMaxFloat:"); //fMaximum
	LogPlayerDetails("W3GetBuffMaxFloat:"); //fMaximum

	W3GetBuffMaxFloatLocal(client,target,"fMaxSpeed",fMaxSpeed);
	W3GetBuffMaxFloatLocal(client,target,"fMaxSpeed2",fMaxSpeed2);
	W3GetBuffMaxFloatLocal(client,target,"fAttackSpeed",fAttackSpeed);

	PrintToConsole(client,"W3GetBuffStackedFloat:"); //fStacked
	LogPlayerDetails("W3GetBuffStackedFloat:"); //fStacked

	W3GetBuffStackedFloatLocal(client,target,"fSlow",fSlow);
	W3GetBuffStackedFloatLocal(client,target,"fSlow2",fSlow2);
	W3GetBuffStackedFloatLocal(client,target,"fMaxHealth",fMaxHealth);

	PrintToConsole(client,"W3GetBuffSumFloat:"); //fAbsolute
	LogPlayerDetails("W3GetBuffSumFloat:"); //fAbsolute

	W3GetBuffSumFloatLocal(client,target,"fArmorPhysical",fArmorPhysical);
	W3GetBuffSumFloatLocal(client,target,"fArmorMagic",fArmorMagic);
	W3GetBuffSumFloatLocal(client,target,"fHPRegen",fHPRegen);
	W3GetBuffSumFloatLocal(client,target,"fDodgeChance",fDodgeChance);
	W3GetBuffSumFloatLocal(client,target,"fVampirePercent",fVampirePercent);
	W3GetBuffSumFloatLocal(client,target,"fMeleeVampirePercent",fMeleeVampirePercent);
	W3GetBuffSumFloatLocal(client,target,"fMeleeVampirePercentNoBuff",fMeleeVampirePercentNoBuff);
	W3GetBuffSumFloatLocal(client,target,"fBashChance",fBashChance);
	W3GetBuffSumFloatLocal(client,target,"fBashDuration",fBashDuration);
	W3GetBuffSumFloatLocal(client,target,"fCritChance",fCritChance);
	W3GetBuffSumFloatLocal(client,target,"fCritModifier",fCritModifier);
	W3GetBuffSumFloatLocal(client,target,"fDamageModifier",fDamageModifier);
	W3GetBuffSumFloatLocal(client,target,"fDodgeChanceRanged",fDodgeChanceRanged);

	PrintToConsole(client,"W3GetBuffSumInt:"); //iAbsolute
	LogPlayerDetails("W3GetBuffSumInt:"); //iAbsolute

	W3GetBuffSumIntLocal(client,target,"iAdditionalMaxHealth",iAdditionalMaxHealth);
	W3GetBuffSumIntLocal(client,target,"iBashDamage",iBashDamage);
	W3GetBuffSumIntLocal(client,target,"iDamageBonus",iDamageBonus);
	W3GetBuffSumIntLocal(client,target,"iAdditionalMaxHealthNoHPChange",iAdditionalMaxHealthNoHPChange);

	PrintToConsole(client,"W3GetBuffLastValue:"); //iLastValue
	LogPlayerDetails("W3GetBuffLastValue:"); //iLastValue

	W3GetBuffLastValueLocal(client,target,"iCritMode",iCritMode);
	W3GetBuffLastValueLocal(client,target,"iDamageMode",iDamageMode);

	PrintToConsole(client,"SHOPMENU 1 ITEMS:");
	LogPlayerDetails("SHOPMENU 1 ITEMS:");

	char itemname[64];

	int ItemsLoaded = W3GetItemsLoaded();
	for(int itemid=1;itemid<=ItemsLoaded;itemid++)
	{
		if(War3_GetOwnsItem(target,itemid))
		{
			W3GetItemName(itemid,itemname,sizeof(itemname));
			PrintToConsole(client,"%s",itemname);
			LogPlayerDetails("%s",itemname);
		}
	}

	PrintToConsole(client,"SHOPMENU 2 ITEMS:");
	LogPlayerDetails("SHOPMENU 2 ITEMS:");

	int Items2Loaded = W3GetItems2Loaded();
	for(int itemid=1;itemid<=Items2Loaded;itemid++)
	{
		if(War3_GetOwnsItem2(target,itemid))
		{
			W3GetItem2Name(itemid,itemname,sizeof(itemname));
			PrintToConsole(client,"%s",itemname);
			LogPlayerDetails("%s",itemname);
		}
	}

#if SHOPMENU3 == MODE_ENABLED
	if(RaceID>0)
	{
		PrintToConsole(client,"SHOPMENU 3 ITEMS:");
		LogPlayerDetails("SHOPMENU 3 ITEMS:");

		int Items3Loaded = W3GetItems3Loaded();
		for(int itemid=1;itemid<=Items3Loaded;itemid++)
		{
			if(War3_GetOwnsItem3(target,RaceID,itemid))
			{
				W3GetItem3Name(itemid,itemname,sizeof(itemname));
				PrintToConsole(client,"%s",itemname);
				LogPlayerDetails("%s",itemname);
			}
		}
	}
#endif

	PrintToConsole(client,"-------------------- END OF DETAILS LIST -------------------"); //iLastValue
	LogPlayerDetails("-------------------- END OF DETAILS LIST -------------------"); //iLastValue

	War3_ChatMessage(client,"{cyan}CHECK YOUR CONSOLE TO SEE DETAILED LIST OF {yellow}%s",targetname);

}
