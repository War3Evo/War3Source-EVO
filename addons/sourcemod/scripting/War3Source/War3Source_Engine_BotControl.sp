// War3Source_Engine_BotControl.sp

#include <war3source>

/*
#pragma semicolon 1

public Plugin:myinfo =
{
	name = "War3Source - Addon - Bot Control",
	author = "Glider & El Diablo",
	description = "Various tweaks regarding bots in War3Source",
	version = "1.3",
};
*/
// ########################## BOT EVASION ################################
new Handle:botEvasionCvar = INVALID_HANDLE;

#if GGAMETYPE == GGAME_TF2
new bool:IsMVMmap=false;
#endif
// ########################## BOT RACE/LEVEL SCRAMBLER ###################
//new g_bEnabled;
//new const MAX_RACE_PICK_ATTEMPTS = 3;

new Handle:botLevelCvar = INVALID_HANDLE;
new Handle:botSrambleSpawn = INVALID_HANDLE;
new Handle:botScrambleRound = INVALID_HANDLE;
new Handle:botAnnounce = INVALID_HANDLE;
new Handle:botLevelRandom = INVALID_HANDLE;

new Handle:MVM_SUPER_BOTS_cvar = INVALID_HANDLE;
new g_bMVM_superbots_Enabled;

// ########################## BOT ITEM CONFIG ############################
new Handle:botBuysItems = INVALID_HANDLE;
new Handle:botBuysRandom = INVALID_HANDLE;
new Handle:botBuysRandomChance = INVALID_HANDLE;
new Handle:botBuysRandomMultipleChance = INVALID_HANDLE;
//new Handle:botsetraces = INVALID_HANDLE;

new Handle:default_race_Cvar = INVALID_HANDLE;

public War3Source_Engine_BotControl_OnPluginStart()
{
	//CreateConVar("botcontrol",PLUGIN_VERSION,"War3Source:EVO Bot Control",FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_DONTRECORD);
	//SetFailState("BROKEN");

	// ########################## BOT EVASION ################################
	botEvasionCvar = CreateConVar("war3_bots_invisibility_gives_evasion","1","Should invisibility give evasion against bots?", _, true, 0.0, true, 1.0);

	// ########################## BOT RACE/LEVEL SCRAMBLER ###################
	RegAdminCmd("war3_botscramble", RaceScrambler, ADMFLAG_SLAY, "war3_botscramble - Scrambles the bots races.");

	default_race_Cvar=CreateConVar("bot_default_race","apple","default race of long name");
	RegAdminCmd("sm_setbot", SetTestBotRace, ADMFLAG_SLAY, "SetTestBotRace.");

	botsetraces = CreateConVar("war3_bots_use_races", "1", "Enable/Disable races for bots");

	MVM_SUPER_BOTS_cvar = CreateConVar("war3_bots_mvm_super_bots", "0", "Enable/Disable mvm super bots");
	g_bMVM_superbots_Enabled=GetConVarBool(MVM_SUPER_BOTS_cvar);
	HookConVarChange(MVM_SUPER_BOTS_cvar, ConVarChange_MVM_SUPER_BOTS_cvar);

	botLevelCvar = CreateConVar("war3_bots_scramble_level", "-1", "The level the bots should be scrambled to.");
	botSrambleSpawn = CreateConVar("war3_bots_scramble_onspawn", "1", "The bots scramble on spawn.");
	botLevelRandom = CreateConVar("war3_bots_scramble_random", "1", "Assign bots a random level up to war3_bots_scramble_level or just the defined level?");
	botScrambleRound = CreateConVar("war3_bots_scramble_on_round", "1", "Scramble bots each round?", _, true, 0.0, true, 1.0);
	botAnnounce = CreateConVar("war3_bots_scramble_announce", "1", "Announce the scrambling?", _, true, 0.0, true, 1.0);

	//g_bEnabled = GetConVarBool(botsetraces);
	//HookConVarChange(botsetraces, ConVarChange_GiveBotsRaces);
#if GGAMETYPE == GGAME_TF2
	HookEvent("teamplay_round_win", Event_ScrambleNow);
#elseif (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
	HookEvent("round_start", Event_ScrambleNow);
#endif

	// ########################## BOT ITEM CONFIG ############################
	botBuysItems = CreateConVar("war3_bots_buy_items", "1", "Can bots buy items?", _, true, 0.0, true, 1.0);
	botBuysRandom = CreateConVar("war3_bots_buy_random","1","Bots buy random items when they spawn (Loadout Mode currently disabled!)", _, true, 1.0, true, 1.0);
	botBuysRandomChance = CreateConVar("war3_bots_buy_random_chance","100","Chance a bot will buy an item on spawn.", _, true, 0.0, true, 100.0);
	botBuysRandomMultipleChance = CreateConVar("war3_bots_buy_random_multiple_chance","0.95","Chance modifier that is applied each time a bot buys a item.", _, true, 0.0, true, 100.0);

	LoadTranslations ("w3s.addon.botcontrol.phrases");
}
#if GGAMETYPE == GGAME_TF2
public War3Source_Engine_BotControl_OnMapStart()
{
	new String:mapName[128];
	GetCurrentMap(mapName, sizeof(mapName));
	if (StrContains(mapName, "mvm", false)>-1)
	{
		IsMVMmap=true;
	}
}
#endif
public bool:War3Source_Engine_BotControl_InitNatives()
{
	///LIST ALL THESE NATIVES IN INTERFACE
	CreateNative("War3_bots_distribute_sp", Native_DistributeSkillpoints);
	CreateNative("War3_bots_pickrace", Native_PickRace);

	RegPluginLibrary("W3BotControl");

	return true;
}

// ########################## CONVARS ######################################

//public ConVarChange_GiveBotsRaces(Handle:convar, const String:oldValue[], const String:newValue[])
//{
	//	g_bEnabled = StringToInt(newValue);
//}
public ConVarChange_MVM_SUPER_BOTS_cvar(Handle:convar, const String:oldValue[], const String:newValue[])
{
		g_bMVM_superbots_Enabled = StringToInt(newValue);
}

// ########################## SetTestBotRace ######################################

public Action:SetTestBotRace(client, args)
{
	new oldCvarNumber;

	new Handle:FindCvar=FindConVar("war3_bots_use_races");
	if(FindCvar!=INVALID_HANDLE)
	{
		oldCvarNumber=GetConVarInt(FindCvar);
		SetConVarInt(FindCvar, 0);
	}
	else
	{
		War3_ChatMessage(0,"{cyan}Error could not find war3_bots_use_races (stopped)");
		return Plugin_Handled;
	}

	new target=War3_GetTargetInViewCone(client,0.0,true,23.0);

	new String:DefaultRaceName[64];
	GetConVarString(default_race_Cvar, DefaultRaceName, sizeof(DefaultRaceName));

	new String:CompareStr[64];
	strcopy(CompareStr,sizeof(CompareStr),DefaultRaceName);
	//War3_ChatMessage(client,"Searching: %s",CompareStr);
	int RacesLoaded = GetRacesLoaded();
	char sRaceName[32];
	int x;
	bool foundit=false;
	for(x=1;x<=RacesLoaded;x++)
	{
		GetRaceName(x,sRaceName,sizeof(sRaceName));
		//War3_ChatMessage(0,"{green}Job: %d  Name: {cyan}%s",x,sRaceName);
		if(StrContains(sRaceName,CompareStr,false)>-1)
		{
			//War3_ChatMessage(client,"FOUND IT! %i",x);
			foundit=true;
			break;
		}
	}
	if(foundit)
	{
		bool allowChooseRace=CanSelectRace(target,x);
		if(allowChooseRace==true)
		{
			SetRace(target,x);
			SetLevel(target, x, W3GetRaceMaxLevel(x));
			War3_bots_distribute_sp(target);
		}
		else
		{
			War3_ChatMessage(0,"{cyan}Bot can not select that job.");
		}
	}
	else
	{
		War3_ChatMessage(0,"{cyan}Bot could not find job.");
	}

	//War3_bots_distribute_sp(target);

	if(FindCvar!=INVALID_HANDLE)
	{
		SetConVarInt(FindCvar, oldCvarNumber);
	}

	return Plugin_Handled;
}


// ########################## BOT EVASION ################################
// Invisibility = Evasion
public War3Source_Engine_BotControl_OnW3TakeDmgAllPre(victim, attacker, Float:damage)
{
	if(MapChanging || War3SourcePause) return 0;

	if(ValidPlayer(victim, true) && ValidPlayer(attacker) && IsFakeClient(attacker) &&
	   GetConVarBool(botEvasionCvar) && GetClientTeam(victim) != GetClientTeam(attacker) &&
	   !GetBuffHasOneTrue(victim, bInvisibilityDenyAll) && !IsFakeClient(victim))
	{
		// Get the actual values
		new Float: fSkillVisibility = GetBuffMinFloat(victim, W3Buff:fInvisibilitySkill);
		new Float: fItemVisibility = GetBuffMinFloat(victim, W3Buff:fInvisibilityItem);
		new Float: fVictimVisibility;

		// Skill denied?
		if(GetBuffHasOneTrue(victim, bInvisibilityDenySkill))
			fSkillVisibility = 1.0;

		// Find the better value
		if (fSkillVisibility < fItemVisibility)
			fVictimVisibility = fSkillVisibility;
		else
			fVictimVisibility = fItemVisibility;

		// 1.0 = Total Visibility
		// 0.0 = Total Invisibility

		// I feel like you should get half your transparency as evasion
		// so 40% Alpha (= 60% "invisibility") should be 30% evasion.

		if(fVictimVisibility < 1.0)
		{
			new Float: fEvasion = (1.0 - fVictimVisibility) / 2;
			if(GetRandomFloat(0.0, 1.0) <= fEvasion)
			{
				W3FlashScreen(victim, RGBA_COLOR_BLUE);
				DamageModPercent(0.0);
				W3MsgEvaded(victim, attacker);
#if GGAMETYPE == GGAME_TF2
				decl Float:pos[3];
				GetClientEyePosition(victim, pos);
				pos[2] += 4.0;
				TE_ParticleToClient(0, "miss_text", pos);
#endif
			}
		}
	}
	return 0;
}

// ########################## BOT RACE/LEVEL SCRAMBLER ###################
public Event_ScrambleNow(Handle:event, const String:name[], bool:dontBroadcast)
{
	new bool:BotsExist=false;
	for(new players = 1; players <= MaxClients; ++players)
	{
		if(ValidPlayer(players))
		{
			if(IsFakeClient(players))
				BotsExist=true;
		}
	}

	//Why scramblebots that doesn't exist?
	//lets scramble bots if they do exist.
	if(GetConVarBool(botScrambleRound)&&BotsExist)
		ScrambleBots();
}

public Action:RaceScrambler(client, args)
{
	ScrambleBots();
	return Plugin_Handled;
}

public void War3Source_BotControl_LoadRacesAndItems()
{
	CreateBotList();
}

// from 0 to maxraces -1 == race
int BotRace[MAXRACES];
int BotMaxLevel[MAXRACES];
int BotRaceCount = 0;

/**
 * Create Bot list
 */
public void CreateBotList()
{
	//LogMessage("--------------CREATE BOT LIST ----------------");
	//clear variables
	for(int x=0;x<MAXRACES;x++)
	{
		BotRace[x] = 0;
		BotMaxLevel[x] = 0;
	}

	// load list
	int RacesLoaded = GetRacesLoaded();
	//LogMessage("RacesLoaded %d",RacesLoaded);
	BotRaceCount = 0;

	int level = 0;
	int race_max_level = 0;
	int bot_level_allowed = GetConVarInt(botLevelCvar);

	for(int x=1;x<=RacesLoaded;x++)
	{
		if (W3RaceHasFlag(x, "nobots"))
		{
				continue;
		}

		race_max_level = GetRaceMaxLevel(x);

		if(bot_level_allowed == -1) // Give him max level?
		{
				level = race_max_level;
		}
		else
		{
				if (bot_level_allowed > race_max_level) // cvar higher than max for this race?
				{
						level = race_max_level;
				}
				else // use cvar value
				{
						level = bot_level_allowed;
				}
		}

		if(GetConVarInt(botLevelRandom) == 1)
		{
				level = GetRandomInt(0, level);
		}

		BotRace[BotRaceCount] = x;
		BotMaxLevel[BotRaceCount] = level;

		BotRaceCount++;
	}
	//LogMessage("------------------------------");
}

/**
 * Makes the bot attempt to pick a race
 */
public void PickRace(client)
{
		if (!IsFakeClient(client))
		{
			return;
		}
		if((IsFakeClient(client) && GetConVarInt(botsetraces)<=0))
		{
			SetRace(client, 0);
			return;
		}

		int variableRace = GetRandomInt(0, BotRaceCount);

		int race = BotRace[variableRace];

		int level = BotMaxLevel[variableRace];


#if GGAMETYPE2 == GGAME_PVM
		if (!W3RaceHasFlag(race, "botsonly"))
		{
			//DP("bots only not found");
			race=size16_GetRaceIDByShortname("terminator1");
		}
		if(race<1)
			race=1;
#elseif GGAMETYPE2 == GGAME_MVM
		if (!W3RaceHasFlag(race, "botsonly"))
		{
			//DP("bots only not found");
			race=size16_GetRaceIDByShortname("terminator1");
		}
		if(race<1)
			race=1;
#elseif GGAMETYPE2 == GGAME_TF2_NORMAL
		// MVM was returning bad race id -1 .. so here is a patch:
		if(race<1)
			race=1;
#endif

		//if(IsMVMmap && g_bMVM_superbots_Enabled)
		if(g_bMVM_superbots_Enabled)
		{
			SetBuffRace(client,fArmorPhysical,race,7.0);
			SetBuffRace(client,fArmorMagic,race,7.0);
			SetBuffRace(client,fVampirePercent,race,0.25);
			SetBuffRace(client,fHPRegen,race,5.0);
		}

		SetRace(client, race);
		SetLevel(client, race, level);
		DistributeSkillPoints(client,race);
}
#if GGAMETYPE == GGAME_TF2
public War3Source_Engine_BotControl_OnWar3EventDeath(victim, attacker, deathrace, distance, attacker_hpleft)
{
		if(MapChanging || War3SourcePause) return 0;

		if (!IsFakeClient(victim))
		{
			return 0;
		}
		if((IsFakeClient(victim) && GetConVarInt(botsetraces)<=0))
		{
			SetRace(victim, 0);
			return 0;
		}
		if(IsMVMmap && g_bMVM_superbots_Enabled)
		{
			if(ValidPlayer(victim))
			{
				new race=GetRace(victim);
				if(race>0)
				{
					SetBuffRace(victim,fArmorPhysical,race,0.0);
					SetBuffRace(victim,fArmorMagic,race,0.0);
					SetBuffRace(victim,fVampirePercent,race,0.0);
					SetBuffRace(victim,fHPRegen,race,0.0);
				}
			}
		}

		return 1;
}
#endif
ScrambleBots()
{
	//new bot_level_allowed = GetConVarInt(botLevelCvar);
	//new level;
	//new race_max_level;
	//new race;

	if(GetConVarInt(botsetraces)>0){
		if(GetConVarBool(botAnnounce))
		{
			//PrintToChatAll("\x01\x04[War3Source:EVO]\x01 %T","The bots races and levels have been scrambled.",LANG_SERVER);

			for(new players = 1; players <= MaxClients; ++players)
			{
				if (IsClientConnected(players) && IsClientInGame(players)&& !IsFakeClient(players))
				{
					//PrintToChat(players,"\x01\x04[War3Source:EVO]\x01 %T","The bots jobs and levels have been scrambled.",players);
				}
			}
		}

		for(new client=1; client <= MaxClients; client++)
		{
			if(ValidPlayer(client) && IsFakeClient(client))
			{
				int variableRace = GetRandomInt(0, BotRaceCount);

				int race = BotRace[variableRace];

				int level = BotMaxLevel[variableRace];

#if GGAMETYPE2 == GGAME_PVM
				if (!W3RaceHasFlag(race, "botsonly"))
				{
					//DP("bots only not found");
					race=size16_GetRaceIDByShortname("terminator1");
				}
				if(race<1)
					race=1;
#elseif GGAMETYPE2 == GGAME_MVM
				if (!W3RaceHasFlag(race, "botsonly"))
				{
					//DP("bots only not found");
					race=size16_GetRaceIDByShortname("terminator1");
				}
				if(race<1)
					race=1;
#elseif GGAMETYPE2 == GGAME_TF2_NORMAL
				// MVM was returning bad race id -1 .. so here is a patch:
				if(race<1)
					race=1;
#endif

				SetRace(client, race);
				SetLevel(client, race, level);
				DistributeSkillPoints(client, race);
			}
		}
	}
}

public DistributeSkillPoints(client,race)
{
	bool isClientFake = IsFakeClient(client);
	int level = War3_GetLevel(client, race);
	int skillpoints = level;
	int ultLevel = W3GetMinUltLevel();

	// Subtract already spent skillpoints
	for(int i=0; i < GetRaceSkillCount(race); i++)
		skillpoints -= GetSkillLevel(client, race, i);

	if(skillpoints < 0)
	{
		for(int i=0; i < GetRaceSkillCount(race); i++)
			SetSkillLevelINTERNAL(client, race, i, 0); 	// Reset all skill points to zero
		DistributeSkillPoints(client,race); // Start over
		return;
	}
	else
	{
		int skill;
		int skill_level;
		int skill_max_level;

		/* TODO: PUT INTO CVAR */
		int max_attempts = isClientFake?2:15;
		int attempts = 0;
		int dependencyID=0;
		while skillpoints > 0 && attempts <= max_attempts do
		{
			//PrintToChatAll("Applying skill points to bot (Attempt %i)", attempts);

			skill = GetRandomInt(0, GetRaceSkillCount(race));
			skill_level = GetSkillLevel(client, race, skill);
			skill_max_level = GetRaceSkillMaxLevel(race, skill);
			attempts++;

			//PrintToServer("Skill: %i, Level: %i, Max Level: %i", skill, skill_level, skill_max_level);

			dependencyID = War3_GetDependency(race, skill, SkillDependency:ID);
			if(dependencyID != INVALID_DEPENDENCY)
			{
				int requiredLVL=War3_GetDependency(race, skill, SkillDependency:LVL);
				if(requiredLVL > 0)
				{
					new currentLVL = GetSkillLevelINTERNAL(client,race,dependencyID);
					if(currentLVL >= requiredLVL)
					{
						if((IsSkillUltimate(race, skill)) && (level < ultLevel))
						{
							//PrintToServer("STOPPING BECAUSE 1");
							continue;
						}
						else if(skill_level == skill_max_level)
						{
							//PrintToServer("STOPPING BECAUSE 2");
							continue;
						}
						else if(skill_level * 2 > level + 1)
						{
							//PrintToServer("STOPPING BECAUSE 3");
							continue;
						}
						else if(IsSkillUltimate(race, skill) && (skill_level > 0) && ((skill_level * 2 + ultLevel -1) > (level + 1)))
						{
							//PrintToServer("STOPPING BECAUSE 4");
							continue;
						}
						else
						{
							SetSkillLevelINTERNAL(client, race, skill, skill_level + 1);
							skillpoints--;
							if(!isClientFake) attempts = 0;
						}
					}
				}
			}
			else
			{
						if((IsSkillUltimate(race, skill)) && (level < ultLevel))
						{
							//PrintToServer("STOPPING BECAUSE 1");
							continue;
						}
						else if(skill_level == skill_max_level)
						{
							//PrintToServer("STOPPING BECAUSE 2");
							continue;
						}
						else if(skill_level * 2 > level + 1)
						{
							//PrintToServer("STOPPING BECAUSE 3");
							continue;
						}
						else if(IsSkillUltimate(race, skill) && (skill_level > 0) && ((skill_level * 2 + ultLevel -1) > (level + 1)))
						{
							//PrintToServer("STOPPING BECAUSE 4");
							continue;
						}
						else
						{
							SetSkillLevelINTERNAL(client, race, skill, skill_level + 1);
							skillpoints--;
							if(!isClientFake) attempts = 0;
						}
			}
		}
	}
}

public War3Source_Engine_BotControl_OnWar3Event(client)
{
	if(IsFakeClient(client))
	{
		int race = GetRace(client);
		if(eValidRace(race))
		{
			DistributeSkillPoints(client,race);
		}
	}
}

// ########################## BOT ITEM CONFIG ############################
AmountOfItems(client)
{
	new amount = 0;

	for(new x=1; x <= W3GetItemsLoaded(); x++)
	{
		if(GetOwnsItem(client, x))
		{
			amount++;
		}
	}

	return amount;
}

Handle war3_max_shopitems = null;

public War3Source_Engine_BotControl_OnWar3EventSpawn(client)
{
	if(MapChanging || War3SourcePause) return 0;

	if(!ValidPlayer(client)) return 0;

	if(!IsFakeClient(client)) return 0;

	if(GetConVarBool(botBuysItems) && GetConVarBool(botBuysRandom))
	{
		float chance = GetConVarFloat(botBuysRandomChance);
		float multipleChance = GetConVarFloat(botBuysRandomMultipleChance);

		if(war3_max_shopitems == null)
		{
			war3_max_shopitems = FindConVar("war3_max_shopitems");
		}
		int maxItems = GetConVarInt(war3_max_shopitems);
		int items_holding = AmountOfItems(client);

		// added in attempts to make the server less laggy
		int attempts = 0;

		while ( (GetRandomFloat(0.0, 100.0) <= chance) && (items_holding < maxItems) && (attempts < maxItems))
		{
			int item = GetRandomInt(0, totalItemsLoaded);

			// Set the event so the engine can still refuse the purchase
			// based on the bots gold or another addon
			//internal_W3SetVar(EventArg1, item);
			internal_W3SetVar(EventArg1, item);
			internal_W3SetVar(EventArg2, 0);
			DoFwd_War3_Event(DoTriedToBuyItem, client);
			War3Source_Engine_MenuShopmenu_OnWar3Event(DoTriedToBuyItem,client); //internal function instead of native

			chance *= multipleChance;
			attempts++;
		}

	}
	if(GetConVarInt(botSrambleSpawn))
	{
		PickRace(client);
	}
	return 0;
}

// ########################## NATIVES ############################

public Native_DistributeSkillpoints(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	DistributeSkillPoints(client,GetRace(client));
}

public Native_PickRace(Handle:plugin, numParams)
{
		new client = GetNativeCell(1);
		PickRace(client);
}
