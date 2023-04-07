// War3Source_Engine_SteamTools.sp

// TRANSLATED 4/7/2023

#if (GGAMETYPE != GGAME_CSGO)



//#include <war3source>
/* ========================================================================== */
/*             steamtools (check if user in steam group)                     */
/*   (c) 2012 El Diablo                                                       */
/*                                                                            */
/* ========================================================================== */
//#pragma semicolon 1

//#pragma semicolon 1    ///WE RECOMMEND THE SEMICOLON
//#include <sourcemod>
//#undef REQUIRE_EXTENSIONS

#include <steamtools>

//#define REQUIRE_EXTENSIONS
//#include "W3SIncs/cssclantags"
//#include "W3SIncs/War3Source_Interface"
//#assert GGAMEMODE == MODE_WAR3SOURCE

public W3ONLY(){} //unload this?

Handle g_hClanID = INVALID_HANDLE;

bool g_bSteamTools = false;
//new bool:bIsInSteamGroup[MAXPLAYERSCUSTOM] = false; // see War3Source_Variables.inc

//#define PLUGIN_VERSION "0.0.1"
/*
public Plugin:myinfo = {
	name        = "SteamTools Group Checker Addon",
	author      = "El Diablo",
	description = "SteamTools Group checker for races.",
	version     = PLUGIN_VERSION,
	url         = "http://www.war3evo.info/"
};*/
new myChecker[MAXPLAYERSCUSTOM+1];
public War3Source_Engine_SteamTools_OnPluginStart()
{
	// War3Evo's GroupID
	g_hClanID = CreateConVar("war3_clan_id","4174523","If GroupID is non-zero the plugin will use steamtools to identify clan players(Overrides 'war3_bonusclan_name')");
	// tells if steamtools is loaded and(if used from a client console) if you're member of the war3_bonusclan_id group
	RegConsoleCmd("war3_bonusclan", Command_TellStatus);
	// refreshes groupcache
	RegServerCmd("war3_bonusclan_refresh", Command_Refresh);
}

public bool:War3Source_Engine_SteamTools_InitNatives()
{
	MarkNativeAsOptional("Steam_RequestGroupStatus");
	CreateNative("War3_IsInSteamGroup",NWar3_isingroup);
	return true;  // prevents log errors
}

public War3Source_Engine_SteamTools_OnClientConnected(client)
{
	myChecker[client]=0;
}
public NWar3_isingroup(Handle:plugin,numParams)
{
	new client=GetNativeCell(1);
	return bIsInSteamGroup[client];

}

public Action:Command_Refresh(args)
{
	for(new client=1;client<=MaxClients;client++)
	{
		if(ValidPlayer(client,false) && !IsFakeClient(client))
		{
			if(LibraryExists("SteamTools"))
			{
				Steam_RequestGroupStatus(client, GetConVarInt(g_hClanID));
			}
		}
	}
	PrintToServer("[W3E] Repolling groupstatus...");
}

public Action:Command_TellStatus(client,args)
{
	if(g_bSteamTools) {
		ReplyToCommand(client,"[W3E] %T","Steamtools detected!",client);
	}
	else {
		ReplyToCommand(client,"[W3E] %T","Steamtools wasn't recognized!",client);
	}
	if(IS_PLAYER(client)) {
		ReplyToCommand(client,"[W3E] %T","Membership status of Group({g_hClanID}) is: {SteamGroupStatus}",client,GetConVarInt(g_hClanID),(bIsInSteamGroup[client]?"member":"non-member"));
	}
	return Plugin_Handled;
}

public War3Source_Engine_SteamTools_OnClientPutInServer(client)
{
	if (IsFakeClient(client))
	return;

	if(ValidPlayer(client))
	{
		CreateTimer (30.0, WelcomeAdvertTimer, client);

		// reset cached group status
		bIsInSteamGroup[client] = false;
		// repoll
		if(check_steamtools()) {
			new iGroupID = GetConVarInt(g_hClanID);
			if(iGroupID != 0) {
				if(LibraryExists("SteamTools"))
				{
					Steam_RequestGroupStatus(client, iGroupID);
				}
			}
		}
	}
}

public Action:WelcomeAdvertTimer (Handle:timer, any:client)
{
	for(new x=1;x<=MaxClients;x++)
	{
		if(ValidPlayer(x,false) && !IsFakeClient(x))
		{
			if(LibraryExists("SteamTools"))
			{
				Steam_RequestGroupStatus(x, GetConVarInt(g_hClanID));
			}
		}
	}
	//PrintToServer("[W3E] Repolling groupstatus...");

	decl String:ClientName[64] = "";
	if (ValidPlayer(client) && !IsFakeClient(client))
	{
		GetClientName (client, ClientName, sizeof (ClientName));
		//decl String:buffer2[32] = "[War3Source:EVO]";

		Format(ClientName, sizeof(ClientName), "\x01\x03%s\x01", ClientName);
		//Format(buffer2, sizeof(buffer2), "\x01\x04%s\x01", buffer2);
		if(bIsInSteamGroup[client])
		{
			War3_ChatMessage(client, "%T","Welcome to the -W3E- Steam Group! Bonus races and items have been unlocked!",client);
		}
		else
		{
			War3_ChatMessage(client, "%T","Welcome {clientname}! Please join our steam group for bonus races and items.",client,ClientName);
			//PrintToChat(client, "\x01\x04[War3Source:EVO]\x01 Type !join to join");
		}
		//PrintToChat (client, "\x01\x04[War3Source:EVO]\x01 Welcome! Please join our Steam Group ");
	}

	return Plugin_Stop;
}



/* SteamTools */


public Steam_FullyLoaded()
{
	g_bSteamTools = true;
}

public Steam_Shutdown()
{
	g_bSteamTools = false;
}

public Steam_GroupStatusResult(client, groupID, bool:bIsMember, bool:bIsOfficer)
{
	if(groupID == GetConVarInt(g_hClanID)) {
		if(ValidPlayer(client) && !IsFakeClient(client))
		{
			bIsInSteamGroup[client] = bIsMember;
			if(!bIsMember)
			{
				War3_ChatMessage(client, "%T","Please join our steam group for bonus races and items.",client);
			}
			else
			{
				if (myChecker[client] == 0) {
					War3_ChatMessage(client, "%T","Thanks for joining our steam group! Bonus races and items have been unlocked!",client);
					myChecker[client] = 1;
				}
			}
		}
	}
}

// Checks if steamtools is currently running properly
stock bool:check_steamtools()
{
	/*if(HAS_STEAMTOOLS()) {
		if(!g_bSteamTools) {
			LogError("SteamTools was detected but not properly loaded");
			return false;
		}
		return true;
	}
	return false;*/
	return g_bSteamTools;
}

#endif
