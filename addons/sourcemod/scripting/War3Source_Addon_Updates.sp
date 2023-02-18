#include <war3source>
#include "War3Source/include/socket.inc"
#include "War3Source/include/War3Source_Version_Info.inc"

// Checks every ten minutes for an update to War3Source-EVO

#pragma semicolon 1

#define REQUIRE_EXTENSIONS

#define EXPLODE_COUNT_SIZE 10
#define EXPLODE_STRING_SIZE 100
char exploded[EXPLODE_COUNT_SIZE][EXPLODE_STRING_SIZE];
char receiveDataString[2048];

bool reportedOnce = false;

public Plugin:myinfo =
{
	name = "War3Source - Addon - Update Checker for W3S-EVO",
	author = "El Diablo",
	description = "Checks for War3Source-EVO updates",
	version = "1.0.0",
	url = "war3source.com"
};

public OnPluginStart()
{
	CreateTimer(600.0,TimerLoop,_,TIMER_REPEAT); // notify every 10 minutes

	// notify on plugin start
	new Handle:socket = SocketCreate(SOCKET_TCP, OnSocketError);
	SocketConnect(socket, OnSocketConnected, OnSocketReceive, OnSocketDisconnected, "107.191.126.142", 80);
}

public OnMapStart()
{
	// notify on map change start
	new Handle:socket = SocketCreate(SOCKET_TCP, OnSocketError);
	SocketConnect(socket, OnSocketConnected, OnSocketReceive, OnSocketDisconnected, "107.191.126.142", 80);
}
/*
public bool isAnyAdmin(int client)
{
	if(ValidPlayer(client))
	{
		new AdminId:admin = GetUserAdmin(client);
		if(admin != INVALID_ADMIN_ID)
		{
			return true;
		}
	}
	return false;
}*/


public OnSocketConnected(Handle:socket, any:arg)
{
	decl String:requestStr[100];
#if (GGAMETYPE == GGAME_FOF)
	Format(requestStr, sizeof(requestStr), "GET /%s HTTP/1.0\r\nHost: %s\r\nConnection: close\r\n\r\n", "fof.txt", "107.191.126.142");
#elseif (GGAMETYPE == GGAME_TF2)
	Format(requestStr, sizeof(requestStr), "GET /%s HTTP/1.0\r\nHost: %s\r\nConnection: close\r\n\r\n", "tf2.txt", "107.191.126.142");
#elseif (GGAMETYPE == GGAME_CSS)
	Format(requestStr, sizeof(requestStr), "GET /%s HTTP/1.0\r\nHost: %s\r\nConnection: close\r\n\r\n", "css.txt", "107.191.126.142");
#elseif (GGAMETYPE == GGAME_CSGO)
	Format(requestStr, sizeof(requestStr), "GET /%s HTTP/1.0\r\nHost: %s\r\nConnection: close\r\n\r\n", "csgo.txt", "107.191.126.142");
#endif
	SocketSend(socket, requestStr);
}

public OnSocketReceive(Handle:socket, String:receiveData[], const dataSize, any:hFile)
{
	TrimString(receiveData);
	strcopy(receiveDataString, sizeof(receiveDataString), receiveData);
}

public OnSocketDisconnected(Handle:socket, any:hFile)
{
	CloseHandle(socket);
	HandleData();
}

public OnSocketError(Handle:socket, const errorType, const errorNum, any:hFile)
{
	LogError("socket error %d (errno %d)", errorType, errorNum);
	CloseHandle(socket);
}

public HandleData()
{
	ExplodeString(receiveDataString, "*", exploded, 10, 100, true);
	strcopy(receiveDataString, 100, exploded[2]);
	if (strcmp(receiveDataString,VERSION_NUM)>0)
	{
		PrintToServer("!!!UPDATE FOUND!!!");
		PrintToServer("https://github.com/War3Evo/War3Source-EVO");
		PrintToServer("https://forums.alliedmods.net/showthread.php?t=284415");
		PrintToServer("War3Source-EVO New Version Available: %s",receiveDataString);

		for(new i = 1; i <= MaxClients; i++)
		{
			if(ValidPlayer(i))
			{
				if(!IsPlayerAlive(i))
				{
					War3_ChatMessage(i,"[War3Source:EVO] New Version Available: %s",receiveDataString);
				}
				else
				{
					PrintToConsole(i,"[War3Source:EVO] New Version Available: %s",receiveDataString);
				}
			}
		}
	}
	else if (strcmp(receiveDataString,VERSION_NUM)==0)
	{
		if(!reportedOnce)
		{
			PrintToServer("War3Source-EVO Current Version: %s",VERSION_NUM);
		}
		reportedOnce = true;
	}
	else if (strcmp(receiveDataString,VERSION_NUM)<0)
	{
		PrintToServer("!!!ERROR!!!  Unless your running a beta version?");
		PrintToServer("Reported War3Source-EVO version: %s",receiveDataString);
		PrintToServer("Your War3Source-EVO Version: %s",VERSION_NUM);
	}
}

//=============================================================================
// TimerLoop
//=============================================================================
public Action:TimerLoop(Handle:timer)
{
	new Handle:socket = SocketCreate(SOCKET_TCP, OnSocketError);
	SocketConnect(socket, OnSocketConnected, OnSocketReceive, OnSocketDisconnected, "107.191.126.142", 80);
}

public OnWar3PlayerAuthed(client)
{
	ExplodeString(receiveDataString, "*", exploded, 10, 100, true);
	strcopy(receiveDataString, 100, exploded[2]);
	if (strcmp(receiveDataString,VERSION_NUM)>0)
	{
		PrintToConsole(client,"[War3Source:EVO] New Version Available: %s",receiveDataString);
	}
}
