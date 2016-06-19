// War3Source_Engine_RaceRestrictions.sp

//#assert GGAMEMODE == MODE_WAR3SOURCE

/*
public Plugin:myinfo=
{
	name="War3Source - Race Restrictions",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://ownageclan.com/ http://war3source.com"
};
*/
public War3Source_Engine_RaceRestrictions_OnPluginStart()
{
#if GGAMETYPE == GGAME_TF2
	HookEvent("player_changeclass", ItemRestrictions_PlayerChangeClassEvent, EventHookMode_Post);
#endif
}

#if GGAMETYPE == GGAME_TF2
public ItemRestrictions_PlayerChangeClassEvent(Handle:event,const String:name[],bool:dontBroadcast)
{
	new userid=GetEventInt(event,"userid");
	//new classid=GetEventInt(event,"class");
	//_:TF2_GetPlayerClass(i)==classid
	if(userid>0)
	{
		//new client=GetClientOfUserId(userid);
		CreateTimer(5.0, CheckItems, userid);
	}
}
#endif

public Action:CheckItems(Handle:Timer, any:userid)
{
	if(MapChanging || War3SourcePause) return Plugin_Stop;

	new client=GetClientOfUserId(userid);
	if(ValidPlayer(client))
	{
			new ItemsLoaded = W3GetItemsLoaded();
			// Remove Items Not allowed to have.
			for(new i;i<=ItemsLoaded;i++)
			{
				if(GetOwnsItem(client,i))
				{
					W3SetVar(EventArg1,i);
					if(W3Denyable(DN_CanBuyItem1,client)==false)
					{
						SetOwnsItem(client,i,false);
						War3_ChatMessage(client,"{red}Item Removed because of your new class/race combo.");
					}
				}
			}
	}

	return Plugin_Continue;
}

public War3Source_Engine_RaceRestrictions_OnW3Denyable(client)
{
		//if(W3IsDeveloper(client)) {
			//DP("dp2 %d",value);
			//War3_ChatMessage(client,"You are normally not allowed to select this race, but since you are developer we will allow you to select this race");
			// returning "true" isn't part of the deny() system, it is just allowing this to return without changing the current true to false via W3Deny();
			// This sytem uses a forwarding.. the system is setup on true, and W3Deny() changes it to false.
			// returning allows an exit to exist.
			//return true;
		//}
		new race_selected=W3GetVar(EventArg1);
		new bool:No_Message=W3GetVar(EventArg2);
		if(race_selected<=0)
		{
			ThrowError(" DN_CanSelectRace CALLED WITH INVALID RACE [%d]",race_selected);
			return W3Deny();
		}
		//MIN LEVEL CHECK
		new total_level=0;
		new RacesLoaded = internal_GetRacesLoaded();
		new bool:DenyNow=false;
		for(new x=1;x<=RacesLoaded;x++)
		{
			total_level+=War3_GetLevel(client,x);
			//RACE DEPENDENCY CHECK
			if(War3_FindRaceDependency(race_selected,x)>War3_GetLevel(client,x))
			{
				new String:tName[32];
				GetRaceName(x,tName,sizeof(tName));
				//DP("Found race dependency %s",tName);
				War3_ChatMessage(client,"Race requires {green}%s {default}with a minimum level of {green}%d",tName,War3_FindRaceDependency(race_selected,x));
				DenyNow=true;
				//return W3Deny();
			}
		}

		if(DenyNow)
			return W3Deny();

		new min_level=W3GetRaceMinLevelRequired(race_selected);
		if(min_level<0) min_level=0;

		//Check for Races Developer:
		//El Diablo: Adding myself as a races developer so that I can double check for any errors
		//in the races content of any server.  This allows me to have all races enabled.
		//I do not have any other access other than all races to make sure that
		//all races work correctly with war3source.
		char steamid[32];
		GetClientAuthId(client,AuthId_Steam2,STRING(steamid),true);
		//if(!StrEqual(steamid,"STEAM_0:1:35173666",false))

		new AdminId:admin = GetUserAdmin(client);
		if(!W3IsDeveloper(client) || (W3IsDeveloper(client)&&!GetConVarBool(gh_AllowDeveloperPowers)))
		{
			new bool:PassFlagCheck=false;
			//FLAG CHECK
			new String:requiredflagstr[32];
			W3GetRaceAccessFlagStr(race_selected,requiredflagstr,sizeof(requiredflagstr));  ///14 = index, see races.inc
			//DP("Race Access Flag of Selected: %s",requiredflagstr);
			if(!StrEqual(requiredflagstr, "0", false)&&!StrEqual(requiredflagstr, "", false))
			{

				//new AdminId:admin = GetUserAdmin(client);
				if(admin == INVALID_ADMIN_ID && War3_GetLevel(client, race_selected) != W3GetRaceMaxLevel(race_selected) ) //flag is required and this client is not admin
				{
					if(No_Message==false)
					{
						War3_ChatMessage(client,"VIP time required. Type !trial or !donate. Once a VIP race is max level, no time is required to use it! If you have active VIP time, please contact an Admin.");
						PrintToConsole(client,"No Admin ID found");
					}
					return W3Deny();
				}
				else
				{
					new AdminFlag:flag;
					if (!FindFlagByChar(requiredflagstr[0], flag)) //this gets the flag class from the string
					{
						if(No_Message==false)
						{
							War3_ChatMessage(client,"ERROR on admin flag check {flag}",requiredflagstr);
						}
						return W3Deny();
					}
					else
					{
						if (!GetAdminFlag(admin, flag)  && War3_GetLevel(client, race_selected) != W3GetRaceMaxLevel(race_selected) )
						{
							if(No_Message==false)
							{
								War3_ChatMessage(client,"VIP time required. Type !trial or !donate. Once a VIP race is max level, no time is required to use it! If you have active VIP time, please contact an Admin.");
								PrintToConsole(client,"Admin ID found, but no required flag");
							}
							return W3Deny();
						}
					}
				}

				PassFlagCheck=true;
			}

			// root access deny everyone not root
			if(!GetAdminFlag(admin, Admin_Root) && War3_GetLevel(client, race_selected) == W3GetRaceMaxLevel(race_selected))
			{
				if(StrEqual(requiredflagstr, "z", false))
				{
					PassFlagCheck=false;
					return W3Deny();
				}
			}


			if(admin != INVALID_ADMIN_ID&&!PassFlagCheck)
			{
				PassFlagCheck=true;
			}

			// Level Check after admin flag check
			if(min_level!=0&&min_level>total_level&&!PassFlagCheck)
			{
				if(No_Message==false)
				{
					War3_ChatMessage(client,"You need %d more total levels to use this race.",min_level-total_level);
				}
				return W3Deny();
			}

			///MAX PER TEAM CHECK
			if(GetConVarInt(W3GetVar(hRaceLimitEnabledCvar))>0)
			{
				//if player is already this race, this is not what it does and its up to gameevents to kick the player
				if(GetRace(client)!=race_selected&&GetRacesOnTeam(race_selected,GetClientTeam(client))>=W3GetRaceMaxLimitTeam(race_selected,GetClientTeam(client))) //already at limit
				{
					//if(!W3IsDeveloper(client)){
					//	DP("racerestricitons.sp");
					if(No_Message==false)
					{
						War3_ChatMessage(client,"Job limit for your team has been reached, please select a different race. (MAX {amount})",W3GetRaceMaxLimitTeam(race_selected,GetClientTeam(client)));
					}

					new cvar=W3GetRaceMaxLimitTeamCvar(race_selected,GetClientTeam(client));
					new String:cvarstr[64];
					if(cvar>-1)
					{
						W3GetCvarActualString(cvar,cvarstr,sizeof(cvarstr));
					}
					cvar=W3FindCvar(cvarstr);
					new String:cvarvalue[64];
					if(cvar>-1)
					{
						W3GetCvar(cvar,cvarvalue,sizeof(cvarvalue));
					}

					//W3Log("race %d blocked on client %d due to restrictions limit %d  %s %s",race_selected,client,W3GetRaceMaxLimitTeam(race_selected,GetClientTeam(client)),cvarstr,cvarvalue);
					return W3Deny();
				//}

				}
			}

			if (W3RaceHasFlag(race_selected, "botsonly"))
			{
				War3_ChatMessage(client,"This is a bots only race.  Select another race!");
				return W3Deny();
			}

/*
enum TFClassType
{
	TFClass_Unknown = 0,
	TFClass_Scout,
	TFClass_Sniper,
	TFClass_Soldier,
	TFClass_DemoMan,
	TFClass_Medic,
	TFClass_Heavy,
	TFClass_Pyro,
	TFClass_Spy,
	TFClass_Engineer
};*/
#if GGAMETYPE == GGAME_TF2
			new String:classlist[][32]={"unknown","scout","sniper","soldier","demoman","medic","heavy","pyro","spy","engineer"};
			new class=_:TF2_GetPlayerClass(client);
			new String:classstring[32];
			strcopy(classstring,sizeof(classstring),classlist[class]);

			new cvarid=W3GetRaceCell(race_selected,ClassRestrictionCvar);
			//DP("cvar %d %s",cvarid,cvarstring);

			if(W3FindStringInCvar(cvarid,classstring,9)) // was max of 2 --> if(W3FindStringInCvar(cvarid,classstring,2))
			{
				//DP("deny");
				if(No_Message==false)
				{
					War3_ChatMessage(client,"Race restricted due to class restriction: %s",classstring);
				}
				return W3Deny();
			}
#endif

		//DP("passed");

		}
	return false;
}
