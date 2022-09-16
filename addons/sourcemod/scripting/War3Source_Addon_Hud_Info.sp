#include <war3source>

/*
	Issues with CSGO that will take a lot more time to figure out.
	
L 09/16/2022 - 03:14:29: "Jon<5><BOT><>" entered the game
L 09/16/2022 - 03:14:29: "Gary<6><BOT><>" connected, address ""
[War3Source:EVO] OnClientPutInServer 5
L 09/16/2022 - 03:14:29: "Gary<6><BOT>" switched from team <Unassigned> to <TERRORIST>
[War3Source:EVO] War3Source_SavePlayerData()
L 09/16/2022 - 03:14:29: [War3Source.smx] bad race ID 0
[War3Source:EVO] DoForward_OnWar3EventSpawn()
[War3Source:EVO] War3Source_SavePlayerData()
[War3Source:EVO] DoForward_OnWar3EventSpawn()
L 09/16/2022 - 03:14:29: "Gary<6><BOT><>" entered the game
L 09/16/2022 - 03:14:29: [SM] Exception reported: Native is not bound
L 09/16/2022 - 03:14:29: [SM] Blaming: War3Source_Addon_Hud_Info.smx
L 09/16/2022 - 03:14:29: [SM] Call stack trace:
L 09/16/2022 - 03:14:29: [SM]   [0] BfWriteByte
L 09/16/2022 - 03:14:29: [SM]   [1] Line 139, /home/lucifer/War3Source-EVO/addons/sourcemod/scripting/War3Source_Addon_Hud_Info.sp$
L 09/16/2022 - 03:14:29: [SM]   [2] Line 396, /home/lucifer/War3Source-EVO/addons/sourcemod/scripting/War3Source_Addon_Hud_Info.sp$
L 
*/

#if GGAMETYPE != GGAME_TF2
	#endinput
#endif

#assert GGAMEMODE == MODE_WAR3SOURCE


/**
* File: War3Source_Addon_Hud_Info.sp
* Description: Shows an RPG style HUD with a whole lot of useful information
* Author(s): Remy Lebeau (based on [RUS] SenatoR's concept)
* Current functions:
*                   * Displays self or 1st person spec player
					* Can be toggled on/off through either console sm_hud, or in chat "hud"
					* Includes a native function to over-ride the HUD for custom game types
							* INCLUDE DETAILS OF HOW TO USE IT HERE
*/


//#include <sourcemod>
//#include "W3SIncs/War3Source_Interface"
//#include <smlib>
#pragma semicolon 1

public Plugin:myinfo =
{
	name = "War3Source - Engine - HUD Info",
	author = "Remy Lebeau (based on [RUS] SenatoR's concept)",
	description = "Show player information in Hud",
	version = "5.2.2",
	url = "war3source.com"
};

//new Re_killtimer;
new bool:g_bShowHUD[MAXPLAYERS];
//new MoneyOffsetCS;

//new bool:bRankCached[MAXPLAYERSCUSTOM];
//new iRank[MAXPLAYERSCUSTOM];
//new iTotalPlayersDB[MAXPLAYERSCUSTOM];
new bool:ShowOtherPlayerItemsCvar;
new String:HUD_Text_Buffer[MAXPLAYERS][500];
new String:HUD_Text_Add[MAXPLAYERS][500];
new bool:g_bCustomHUD = false;

/*
public APLRes:AskPluginLoad2Custom(Handle:myself, bool:late, String:error[], err_max)
{
   CreateNative("HUD_Message", Native_HUD_Message);
   CreateNative("HUD_Override", Native_HUD_Override);
   CreateNative("HUD_Add", Native_HUD_Add);
   return APLRes_Success;
}


public Native_HUD_Message(Handle:plugin, numParams)
{
	new client = GetClientOfUserId(GetNativeCell(1));

	if(ValidPlayer(client))
	{
		GetNativeString(2, HUD_Text_Buffer[client], 500);
		return 1;
	}
	return 0;
}

public Native_HUD_Add(Handle:plugin, numParams)
{
	new client = GetClientOfUserId(GetNativeCell(1));

	if(ValidPlayer(client))
	{
		GetNativeString(2, HUD_Text_Add[client], 500);
		return 1;
	}
	return 0;
}

public Native_HUD_Override(Handle:plugin, numParams)
{
	g_bCustomHUD = GetNativeCell(1);
	return 0;
}*/


//bool g_bCanEnumerateMsgType = false;
UserMsg g_umsgKeyHintText = INVALID_MESSAGE_ID;

public OnPluginStart()
{
	//if(GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available)
	//{
		//g_bCanEnumerateMsgType = true;
	//}

	// Lookup message id's and cache them.
	g_umsgKeyHintText = GetUserMessageId("KeyHintText");
	if (g_umsgKeyHintText == INVALID_MESSAGE_ID)
	{
		LogError("This game doesn't support KeyHintText!");
		//PrintToServer("This game doesn't support KeyHintText!");
	}

	//HookEvent("player_spawn", Event_PlayerSpawn);
	//HookEvent("round_start", Event_RoundStart);
	//HookEvent("round_end", Event_RoundEnd);

	RegConsoleCmd("sm_hud", Command_ToggleHUD, "Toggles the HUD on/off");
	RegConsoleCmd("say hud", Command_ToggleHUD, "Toggles the HUD on/off");
	RegConsoleCmd("say_team hud", Command_ToggleHUD, "Toggles the HUD on/off");
#if GGAMETYPE == GGAME_TF2
	CreateTimer(1.0, HudInfo_Timer, _, TIMER_REPEAT);
#elseif (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
	CreateTimer(0.3, HudInfo_Timer, _, TIMER_REPEAT);
#endif
	ShowOtherPlayerItemsCvar = true;
}

stock Handle StartMessageExOne(UserMsg msg, int client, int flags=0)
{
	int players[1];
	players[0] = client;
	return StartMessageEx(msg, players, 1, flags);
}

stock bool stockKeyHintText(int client, char format[254])
{
	if (ValidPlayer(client,true) && !IsFakeClient(client))
	{
		Handle userMessage = StartMessageExOne(g_umsgKeyHintText, client);
		if(userMessage != INVALID_HANDLE)
		{
			SetGlobalTransTarget(client);

			//if (g_bCanEnumerateMsgType && GetUserMessageType() == UM_Protobuf)
			//{
				//PbSetString(userMessage, "hints", format);
			//}
			//else
			//{
			BfWriteByte(userMessage, 1);
			BfWriteString(userMessage, format);
			//}
			EndMessage();
		}
		return true;
	}
	return false;
}

//public OnMapStart()
//{
	//new bool:ShowOtherPlayerItemsCvar = true;
//}

public OnClientPutInServer(client)
{
	g_bShowHUD[client] = false;
	//GetRank(client);
}

public Action:Command_ToggleHUD(client, args)
{
	if(ValidPlayer(client))
	{
		if (g_bShowHUD[client] == false)
		{
			g_bShowHUD[client] = true;
			War3_ChatMessage(client,"hud is on");
		}
		else
		{
			g_bShowHUD[client] = false;
			War3_ChatMessage(client,"hud is off");
		}
	}
	return Plugin_Handled;
}



//public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
//{
	//Re_killtimer = 0;

//}
//public Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
//{
	//Re_killtimer = 1;
//}
//public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
//{
	//new client = GetClientOfUserId(GetEventInt(event, "userid"));
	//CreateTimer(1.0, HudInfo_Timer, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
//}
public Action:HudInfo_Timer(Handle:timer, any:whatclient)
{
	for(new client = 1; client <= MaxClients; client++)
	{
		//if (ValidPlayer(client) && Re_killtimer == 0)
		if (ValidPlayer(client,true))
		{
#if GGAMETYPE == GGAME_TF2
			if(g_bShowHUD[client] == true)
			{
#elseif (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
			if(W3GetPlayerProp(client,iGoldDiamondHud)==1)
			{
#endif
				new display = client;
				//new observed = -1;
				if(!g_bCustomHUD)
				{
					//if(!IsPlayerAlive(display))
					//{
						//if(OBS_MODE_IN_EYE == Client_GetObserverMode(display))
							//observed = Client_GetObserverTarget(display);
						//if(ValidPlayer(observed, true))
							//client = observed;
					//}

					new race=War3_GetRace(client);
					if (race > 0)
					{
						decl String:HUD_Text[254];
						new String:racename[64];
						War3_GetRaceName(race,racename,sizeof(racename));
						new level=War3_GetLevel(client, race);

						Format(HUD_Text, sizeof(HUD_Text), "Race: %s\nLevel: %i/%i - XP: %i/%i\nTotal Level: %d",
							racename,
							level,
							W3GetRaceMaxLevel(race),
							War3_GetXP(client, race),
							W3GetReqXP(level+1),
							GetClientTotalLevels(client));
							//War3_GetGold(client));
#if (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
						Format(HUD_Text, sizeof(HUD_Text), "%s - G: %i",
							HUD_Text,
							War3_GetGold(client));

						Format(HUD_Text, sizeof(HUD_Text), "%s - D: %i",
							HUD_Text,
							War3_GetDiamonds(client));

						Format(HUD_Text, sizeof(HUD_Text), "%s - P: %i\n",
							HUD_Text,
							War3_GetPlatinum(client));

						Format(HUD_Text, sizeof(HUD_Text), "%sHP: %i MAXHP: %i",
							HUD_Text,
							GetClientHealth(client),War3_GetMaxHP(client));

#endif
						//Format(HUD_Text, sizeof(HUD_Text), "%s - Diamonds: %i",
							//HUD_Text,
							//War3_GetDiamonds(client));

						//if(iRank[client]>0)
						//{
							//Format(HUD_Text, sizeof(HUD_Text), "%s\nWar3rank: %d",HUD_Text, iRank[client]);
						//}
						new Float:speedmulti=1.0;

						if(!W3GetBuffHasTrue(client,bBuffDenyAll)){
							speedmulti=W3GetBuffMaxFloat(client,fMaxSpeed)+W3GetBuffMaxFloat(client,fMaxSpeed2)-1.0;
						}
						if(W3GetBuffHasTrue(client,bStunned)||W3GetBuffHasTrue(client,bBashed)){
							speedmulti=0.0;
						}
						if(!W3GetBuffHasTrue(client,bSlowImmunity)){
							speedmulti=FloatMul(speedmulti,W3GetBuffStackedFloat(client,fSlow));
							speedmulti=FloatMul(speedmulti,W3GetBuffStackedFloat(client,fSlow2));
						}

						if(speedmulti != 1.0)
						{
							Format(HUD_Text, sizeof(HUD_Text), "%s\nSpd: %.2f",HUD_Text, speedmulti);
						}
						/*
						if(W3GetBuffMinFloat(client,fLowGravitySkill) != 1.0)
						{
							Format(HUD_Text, sizeof(HUD_Text), "%s\nGrav: %.2f",HUD_Text, W3GetBuffMinFloat(client,fLowGravitySkill));
						}*/

						new Float:falpha=1.0;
						if(!W3GetBuffHasTrue(client,bInvisibilityDenySkill))
						{
							falpha=FloatMul(falpha,W3GetBuffMinFloat(client,fInvisibilitySkill));

						}
						new Float:itemalpha=W3GetBuffMinFloat(client,fInvisibilityItem);
						if(falpha!=1.0){
							//PrintToChatAll("has skill invis");
							//has skill, reduce stack
							itemalpha=Pow(itemalpha,0.75);
						}
						falpha=FloatMul(falpha,itemalpha);

						if(falpha != 1.0  )
						{
							Format(HUD_Text, sizeof(HUD_Text), "%s\nInv: %.2f",HUD_Text, falpha);
						}

						if(W3GetBuffSumFloat(client, fDodgeChance) != 0.0)
						{
							Format(HUD_Text, sizeof(HUD_Text), "%s\nEvde: %.2f", HUD_Text,W3GetBuffSumFloat(client, fDodgeChance));
						}

						if(W3GetBuffMaxFloat(client,fAttackSpeed) != 1.0)
						{
							Format(HUD_Text, sizeof(HUD_Text), "%s\nAttk: %.2f", HUD_Text,W3GetBuffMaxFloat(client,fAttackSpeed));
						}

						if(W3GetBuffSumFloat(client, fDamageModifier) != 0.0)
						{
							Format(HUD_Text, sizeof(HUD_Text), "%s\n+Dmg: %.2f",HUD_Text, FloatMul(W3GetBuffSumFloat(client, fDamageModifier), 100.0));
						}

						if(W3GetBuffSumFloat(client, fHPRegen) != 0.0)
						{
							Format(HUD_Text, sizeof(HUD_Text), "%s\nRgen: %.2f",HUD_Text, W3GetBuffSumFloat(client, fHPRegen));
						}

						if(W3GetBuffSumFloat(client, fVampirePercent) != 0.0)
						{
							Format(HUD_Text, sizeof(HUD_Text), "%s\nVamp: %.2f",HUD_Text, W3GetBuffSumFloat(client, fVampirePercent));
						}


						if(W3GetBuffHasTrue(client,bSlowImmunity) || W3GetBuffHasTrue(client,bImmunitySkills) || W3GetBuffHasTrue(client,bImmunityUltimates) || W3GetBuffHasTrue(client,bImmunityWards))
						{
							StrCat(HUD_Text, sizeof(HUD_Text), "\nImmune: ");
							if(W3GetBuffHasTrue(client,bSlowImmunity))
								StrCat(HUD_Text, sizeof(HUD_Text), "Sl|");
							if(W3GetBuffHasTrue(client,bImmunitySkills))
								StrCat(HUD_Text, sizeof(HUD_Text), "Sk|");
							if(W3GetBuffHasTrue(client,bImmunityWards))
								StrCat(HUD_Text, sizeof(HUD_Text), "W|");
							if(W3GetBuffHasTrue(client,bImmunityUltimates))
								StrCat(HUD_Text, sizeof(HUD_Text), "U|");

						}



						if(ShowOtherPlayerItemsCvar&&client!=display)
						{
							new bool:itemsonce = true;
							new String:itemname[64];
							new ItemsLoaded = W3GetItemsLoaded();
							for(new itemid=1;itemid<=ItemsLoaded;itemid++)
							{
								if(War3_GetOwnsItem(client,itemid))
								{
									if(itemsonce)
									{
										StrCat(HUD_Text, sizeof(HUD_Text), "\nI: ");
										itemsonce = false;
									}
									W3GetItemShortname(itemid,itemname,sizeof(itemname));
									Format(HUD_Text,sizeof(HUD_Text),"%s%s | ",HUD_Text,itemname);
								}
							}
						}
						else if(client==display)
						{
							new bool:itemsonce = true;

							new String:itemname[64];
							new ItemsLoaded = W3GetItemsLoaded();
							for(new itemid=1;itemid<=ItemsLoaded;itemid++)
							{
								if(War3_GetOwnsItem(client,itemid))
								{
									if(itemsonce)
									{
										StrCat(HUD_Text, sizeof(HUD_Text), "\nI: ");
										itemsonce = false;
									}
									W3GetItemShortname(itemid,itemname,sizeof(itemname));
									Format(HUD_Text,sizeof(HUD_Text),"%s%s | ",HUD_Text,itemname);
								}
							}
						}

						//if(!IsPlayerAlive(display) && observed == -1)
						//{

						//}
						//else
						//{
						StrCat(HUD_Text, sizeof(HUD_Text), HUD_Text_Add[display]);
						//War3_KeyHintText(display, HUD_Text);

						//PrintHintText(display, HUD_Text);
						stockKeyHintText(display, HUD_Text);

						DP(HUD_Text);

						//}
					}
				}
				else
				{
					char HUD_Text[254];
					strcopy(HUD_Text, sizeof(HUD_Text), HUD_Text_Buffer[client]);
					//War3_KeyHintText(client, HUD_Text);
					//PrintHintText(client, HUD_Text);
					stockKeyHintText(client, HUD_Text);
					DP(HUD_Text);
				}
			}
		}
		//else
		//{
			//return Plugin_Stop;
		//}
	}
	return Plugin_Continue;
}


//stock GetMoney(player)
//{
	//return GetEntData(player,MoneyOffsetCS);
//}

/*
GetRank(client)
{

	new Handle:hDB=W3GetVar(hDatabase);
	SQL_TQuery(hDB,T_RetrieveRankCache,"SELECT steamid FROM war3source ORDER BY total_level DESC,total_xp DESC",GetClientUserId(client));

}

public T_RetrieveRankCache(Handle:owner,Handle:query,const String:error[],any:userid)
{
	new client=GetClientOfUserId(userid);
	if(client<=0)
		return; // fuck it, the player left
	new String:client_steamid[64];
	if(!GetClientAuthString(client,client_steamid,sizeof(client_steamid)))
		return; // invalid auth string, probably a fake steam account
	if(IsFakeClient(client))
		return; // why the fuck is a bot requesting their rank?
	if(query!=INVALID_HANDLE)
	{
		SQL_Rewind(query);
		new iCurRank=0;
		iTotalPlayersDB[client]=0;
		while(SQL_FetchRow(query))
		{
			++iCurRank;
			new String:steamid[64];
			if(!W3SQLPlayerString(query,"steamid",steamid,sizeof(steamid)))
				continue;
			if(StrEqual(steamid,client_steamid,false))
			{
				iRank[client]=iCurRank;
			}
			++iTotalPlayersDB[client];
		}
		CloseHandle(query);
		if(iRank[client]>0)
		{
			bRankCached[client]=true;
		}
	}
}
*/


GetClientTotalLevels(client)
{
  new total_level=0;
  new RacesLoaded = War3_GetRacesLoaded();
  for(new r=1;r<=RacesLoaded;r++)
  {
	total_level+=War3_GetLevel(client,r);
  }
  return  total_level;
}



