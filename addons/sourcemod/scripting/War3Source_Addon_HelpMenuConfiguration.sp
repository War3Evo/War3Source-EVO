#include <war3source>

#pragma semicolon 1

public Plugin:myinfo =
{
	name = "War3Source - Addon - Help Menu Configuration",
	author = "El Diablo",
	description = "Allows server owner to change help menu",
	version = "1.0.0",
	url = "war3source.com"
};

#define iStringSize 100

char sQuestion[iStringSize];
char sFakeClientCommandEx[iStringSize];
char sChatMessage[iStringSize];
char sConsoleMessage[iStringSize];
char sServerCommand[iStringSize];

new Handle: array_question;
new Handle: array_fakeclientcommandex;
new Handle: array_chatmessage;
new Handle: array_consolemessage;
new Handle: array_servercommand;

new Handle: war3_help_menu_cfg;
new Handle: war3_help_menu_debug;
new Handle: war3_help_menu_title;

int Loaded = -1;

public bool War3_HelpMenu_Enabled()
{
	return GetConVarBool(war3_help_menu_cfg);
}

//=============================================================================
// AskPluginLoad2Custom
//=============================================================================
public APLRes:AskPluginLoad2Custom(Handle:myself,bool:late,String:error[],err_max)
{
	array_question = CreateArray(iStringSize);
	array_fakeclientcommandex = CreateArray(iStringSize);
	array_chatmessage = CreateArray(iStringSize);
	array_consolemessage = CreateArray(iStringSize);
	array_servercommand = CreateArray(iStringSize);
	if(Loaded == -1)
	{
		Loaded = LoadConfig();
	}
	return APLRes_Success;
}

public OnAllPluginsLoaded()
{
	W3Hook(W3Hook_OnWar3Event, OnWar3Event);
}
public OnPluginEnd()
{
	W3UnhookAll(W3Hook_OnWar3Event);
}

public OnPluginStart()
{
	RegAdminCmd("printhelpmenu", printhelpmenu, ADMFLAG_ROOT);

	war3_help_menu_title = CreateConVar("war3_help_menu_title", "[War3Source-EVO] Help Menu", "Custom Help Menu Title");

	war3_help_menu_cfg = CreateConVar("war3_help_menu_cfg", "0", "Enable/Disable Custom Help Menu");
	war3_help_menu_debug = CreateConVar("war3_help_menu_debug", "0", "Enable/Disable Help Menu Debug Messages");

	if(Loaded != 666)
	{
		if(array_question == null)
		{
			array_question = CreateArray(iStringSize);
		}
		if(array_fakeclientcommandex == null)
		{
			array_fakeclientcommandex = CreateArray(iStringSize);
		}
		if(array_chatmessage == null)
		{
			array_chatmessage = CreateArray(iStringSize);
		}
		if(array_consolemessage == null)
		{
			array_consolemessage = CreateArray(iStringSize);
		}
		if(array_servercommand == null)
		{
			array_servercommand = CreateArray(iStringSize);
		}
		Loaded = LoadConfig();
	}
}

public bool DebugOn()
{
	return GetConVarBool(war3_help_menu_debug);
}

public Action printhelpmenu(int client, int args)
{
	char cQT[iStringSize];
	for(new i=0; i <= GetArraySize(array_question)-1; i++)
	{
		GetArrayString(array_question, i, cQT, sizeof(cQT));
		ReplyToCommand(client, "QUESTION: %i %s",i,cQT);

		GetArrayString(array_fakeclientcommandex, i, cQT, sizeof(cQT));
		ReplyToCommand(client, "Fake Client Command: %i %s",i,cQT);

		GetArrayString(array_chatmessage, i, cQT, sizeof(cQT));
		ReplyToCommand(client, "Chat Message: %i %s",i,cQT);

		GetArrayString(array_consolemessage, i, cQT, sizeof(cQT));
		ReplyToCommand(client, "Console Message: %i %s",i,cQT);

		GetArrayString(array_servercommand, i, cQT, sizeof(cQT));
		ReplyToCommand(client, "Server Command: %i %s",i,cQT);
	}
	return Plugin_Handled;
}

public int LoadConfig()
{
	if (DebugOn() == true) { PrintToServer("1-LOADING HELP CONFIG..."); }

	new Handle: kv = CreateKeyValues("war3sourcehelpmenu");

	FileToKeyValues(kv, "addons/sourcemod/configs/war3source_help_menu.cfg");
	KvRewind(kv);

// auto grabs for game mode:
#if (GGAMETYPE == GGAME_CSS)
	if(!KvJumpToKey(kv,"CSS"))
		SetFailState("error, key value for levels configuration not found");
#elseif (GGAMETYPE == GGAME_CSGO)
	if(!KvJumpToKey(kv,"CSGO"))
		SetFailState("error, key value for levels configuration not found");
#elseif (GGAMETYPE == GGAME_FOF)
	if(!KvJumpToKey(kv,"FOF"))
		SetFailState("error, key value for levels configuration not found");
#elseif (GGAMETYPE == GGAME_TF2)
	if(!KvJumpToKey(kv,"TF2"))
		SetFailState("error, key value for levels configuration not found");
#else
	ThrowNativeError(80070666, "ERROR: UNSUPPORTED GAME MODE");
#endif

	if (!KvGotoFirstSubKey(kv))
	{
		return ThrowNativeError(80070066, "Unable to load addons/sourcemod/configs/war3source_help_menu.cfg for this game.");
	}
	if (DebugOn() == true) { PrintToServer("2-LOADING CONFIG..."); }

	// clear array and reload for every map change
	// just in case server admin wants to change sound

	ClearArray(array_question);
	ClearArray(array_fakeclientcommandex);
	ClearArray(array_chatmessage);
	ClearArray(array_consolemessage);
	ClearArray(array_servercommand);

	int find_index = -1;

	do {
		KvGetString(kv, "question", sQuestion, sizeof(sQuestion));
		KvGetString(kv, "fakeclientcommand", sFakeClientCommandEx, sizeof(sFakeClientCommandEx));
		KvGetString(kv, "chatmessage", sChatMessage, sizeof(sChatMessage));
		KvGetString(kv, "consolemessage", sConsoleMessage, sizeof(sConsoleMessage));
		KvGetString(kv, "servercommand", sConsoleMessage, sizeof(sConsoleMessage));

		// prevent duplicates
		find_index = FindStringInArray(array_question, sQuestion);
		if(find_index == -1) // if not found, add
		{
			//Store data in array
			PushArrayString(array_question, sQuestion);
			if (DebugOn() == true) { PrintToServer("Question: %s", sQuestion); }
			if (DebugOn() == true) { PrintToServer("***************GetArrayBlockSize: %i", GetArraySize(array_question)); }

			PushArrayString(array_fakeclientcommandex, sFakeClientCommandEx);
			if (DebugOn() == true) { PrintToServer("Fake Client CommandEx: %s", sFakeClientCommandEx); }
			if (DebugOn() == true) { PrintToServer("***************GetArrayBlockSize: %i", GetArraySize(array_fakeclientcommandex)); }

			PushArrayString(array_chatmessage, sChatMessage);
			if (DebugOn() == true) { PrintToServer("Chat Message: %s", sChatMessage); }
			if (DebugOn() == true) { PrintToServer("***************GetArrayBlockSize: %i", GetArraySize(array_chatmessage)); }

			PushArrayString(array_consolemessage, sConsoleMessage);
			if (DebugOn() == true) { PrintToServer("Console Message: %s", sConsoleMessage); }
			if (DebugOn() == true) { PrintToServer("***************GetArrayBlockSize: %i", GetArraySize(array_consolemessage)); }

			PushArrayString(array_servercommand, sServerCommand);
			if (DebugOn() == true) { PrintToServer("Server Command: %s", sServerCommand); }
			if (DebugOn() == true) { PrintToServer("***************GetArrayBlockSize: %i", GetArraySize(array_servercommand)); }
		}

	} while (KvGotoNextKey(kv));

	CloseHandle(kv);

	return 666;
}

public void OnWar3Event(W3EVENT event,int client)
{
	if(War3_HelpMenu_Enabled()==false) return;

	if(event==DoShowWar3Menu)
	{
		ShowWar3Menu(client);	
	}
}

ShowWar3Menu(client)
{
	new Handle:war3Menu=CreateMenu(War3Source_War3Menu_Select);
	new String:menutitle[100];
	GetConVarString(war3_help_menu_title, menutitle, sizeof(menutitle));
	SetMenuTitle(war3Menu,menutitle);
	//new limit=9;
	//new String:transbuf[32];
	new String:menustr[100];
	new String:numstr[4];

	char cQT[iStringSize];
	for(new i=0; i <= GetArraySize(array_question)-1; i++)
	{
		GetArrayString(array_question, i, cQT, sizeof(cQT));
		Format(menustr,sizeof(menustr),cQT);
		Format(numstr,sizeof(numstr),"%d",i);

		AddMenuItem(war3Menu,numstr,menustr);
	}

	//W3CreateEvent(DoShowItemsInfoMenu,client);

	DisplayMenu(war3Menu,client,MENU_TIME_FOREVER);
}


public War3Source_War3Menu_Select(Handle:menu,MenuAction:action,client,selection)
{
	if(action==MenuAction_Select)
	{
		decl String:SelectionInfo[4];
		decl String:SelectionDispText[256];
		new SelectionStyle;
		GetMenuItem(menu,selection,SelectionInfo,sizeof(SelectionInfo),SelectionStyle, SelectionDispText,sizeof(SelectionDispText));
		if(ValidPlayer(client))
		{
			if(selection<0)
			{
				PrintToServer("help menu selection error < 0");
				CloseHandle(menu);
			}
			if(selection>(GetArraySize(array_question)-1))
			{
				PrintToServer("help menu selection error > GetArraySize(array_question)-1");
				CloseHandle(menu);
			}

			// FakeClientCommandEx
			char cCommandStr[iStringSize];
			GetArrayString(array_fakeclientcommandex, selection, cCommandStr, sizeof(cCommandStr));
			if(!StrEqual(cCommandStr, ""))
			{
				FakeClientCommandEx(client,cCommandStr);
			}
			
			// War3_ChatMessage
			GetArrayString(array_chatmessage, selection, cCommandStr, sizeof(cCommandStr));
			if(!StrEqual(cCommandStr, ""))
			{
				War3_ChatMessage(client,cCommandStr);
			}

			// PrintToConsole
			GetArrayString(array_consolemessage, selection, cCommandStr, sizeof(cCommandStr));
			if(!StrEqual(cCommandStr, ""))
			{
				PrintToConsole(client,cCommandStr);
			}

			// ServerCommand
			GetArrayString(array_servercommand, selection, cCommandStr, sizeof(cCommandStr));
			if(!StrEqual(cCommandStr, ""))
			{
				ServerCommand(cCommandStr);
			}
		}
	}
	if(action==MenuAction_End)
	{
		CloseHandle(menu);
	}
}