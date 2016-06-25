// War3Source_Engine_Bank.sp

enum W3Bank
{
	bool:hasbank,
	W3Bank_gold,
	W3Bank_timestamp,
}

//new String:p_bank_steamid[MAXPLAYERSCUSTOM][64];

int p_bank[MAXPLAYERSCUSTOM][W3Bank];

Handle WithDrawTimeLimitCvar = INVALID_HANDLE;

public Plugin:myinfo=
{
	name="War3Source:EVO Engine Bank",
	author="El Diablo",
	description="War3Source:EVO Core Plugins",
	version="1.0",
	url="http://war3evo.info/"
};

public War3Source_Engine_Bank_OnPluginStart()
{
	WithDrawTimeLimitCvar = CreateConVar("sm_bank_withdraw_timelimit","2700","default 2700 = 45 minutes");
	CreateTimer(330.0,DoAutosave);
}

stock BankLog(const String:reason[]="", any:...)
{
	char szFile[256];

	decl String:LogThis[2048];
	VFormat(LogThis, sizeof(LogThis), reason, 2);

	BuildPath(Path_SM, szFile, sizeof(szFile), "logs/bank.log");
	LogToFile(szFile, LogThis);
}

public Clear_Variables(client)
{
	if (client > 0 && client <= MaxClients)
	{
		p_bank[client][W3Bank_gold]=0;
		p_bank[client][W3Bank_timestamp]=0;
		p_bank[client][hasbank]=false;
		//strcopy(p_bank_steamid[client], 63, "");
	}
}

public NWar3_BankWithdrawTimeLeft(Handle:plugin,numParams){
	int client=GetNativeCell(1);
	if (client > 0 && client <= MaxClients)
	{
		int maxlen=GetNativeCell(3);
		SetNativeString(2,withdrawalTime1(p_bank[client][W3Bank_timestamp]),maxlen);
	}
}

public NWar3_BankCanWithdraw(Handle:plugin,numParams){
	int client=GetNativeCell(1);
	if (client > 0 && client <= MaxClients)
	{
		return withdrawalTime0(p_bank[client][W3Bank_timestamp]);
	}
	return 0;
}

public NWar3_DepositGoldBank(Handle:plugin,numParams){
	int client=GetNativeCell(1);
	if (client > 0 && client <= MaxClients)
	{
		int amount=GetNativeCell(2);
		int currentgold=GetPlayerProp(client, PlayerGold);
		if (amount <= currentgold)
		{
			p_bank[client][W3Bank_gold]+=amount;
			currentgold-=amount;
			War3_SetGold(client,currentgold);
			return true;
		}
		else
		{
			War3_ChatMessage(client, "You don't have enough gold on hand.");
			return false;
		}
	}
	return false;
}

public NWar3_WithdrawGoldBank(Handle:plugin,numParams){
	int client=GetNativeCell(1);
	if (client > 0 && client <= MaxClients)
	{
		bool Bypass=GetNativeCell(3);
		if(!withdrawalTime0(p_bank[client][W3Bank_timestamp]) && !Bypass)
		{
			War3_ChatMessage(client,"On hand: {green}%d {default}Gold. !balance: {green}%d {default}Gold. Please wait %s to withdraw.",War3_GetGold(client),p_bank[client][W3Bank_gold],withdrawalTime1(p_bank[client][W3Bank_timestamp]));
			return false;
		}
		else
		{
			int playerGold=GetPlayerProp(client, PlayerGold);
			int maxGold=W3GetMaxGold(99);
			int amount=GetNativeCell(2);

			if(!Bypass)
			{
				if (amount > p_bank[client][W3Bank_gold])
				{
					War3_ChatMessage(client, "On hand: {green}%d {default}Gold. !balance: {green}%d {default}Gold. You don't have enough gold in the bank.",War3_GetGold(client),p_bank[client][W3Bank_gold]);
					return false;
				}
				else if ((playerGold+amount) > maxGold )
				{
					War3_ChatMessage(client, "That withdrawal would put you over the gold cap (%i).",maxGold);
					return false;
				}
				else if (amount <= p_bank[client][W3Bank_gold])
				{
					p_bank[client][W3Bank_gold]-=amount;
					playerGold+=amount;
					War3_SetGold(client,playerGold);
					p_bank[client][W3Bank_timestamp]=GetTime();
					return true;
				}
			}
			else
			{
				p_bank[client][W3Bank_gold]-=amount;
				playerGold+=amount;
				War3_SetGold(client,playerGold);
				//Bypass time stamp?  Probably so.  Used on tomes.
				//p_bank[client][W3Bank_timestamp]=GetTime();
				return true;
			}
		}
	}
	return false;
}

public NWar3_SetGoldBank(Handle:plugin,numParams){
	int client=GetNativeCell(1);
	if (client > 0 && client <= MaxClients)
	{
		p_bank[client][W3Bank_gold]=GetNativeCell(2);
	}
}
public NWar3_GetGoldBank(Handle:plugin,numParams){
	int client=GetNativeCell(1);
	if (client > 0 && client <= MaxClients)
	{
		return p_bank[client][W3Bank_gold];
	}
	else
		return -1;
}

///////////////////// DATABASE: SAVE ////////////////////////////
///////////////////// DATABASE: SAVE ////////////////////////////
///////////////////// DATABASE: SAVE ////////////////////////////
///////////////////// DATABASE: SAVE ////////////////////////////
///////////////////// DATABASE: SAVE ////////////////////////////
public Internal_SaveBank(client)
{
	if(W3SaveEnabled() && g_hDatabase)
	{
		char steamid[64];
		if(ValidPlayer(client) && !IsFakeClient(client) && GetClientAuthId(client,AuthId_Steam2,STRING(steamid),true))
		{
			if(p_bank[client][hasbank])
			{
				char query[400];
				Format(query,sizeof(query),"UPDATE %s SET gold='%i', withdraw_stamp='%i' WHERE sid='%s';",DATABASENAME,p_bank[client][W3Bank_gold],p_bank[client][W3Bank_timestamp],steamid);
				SQL_TQuery(g_hDatabase,SQLCallback_Void,query,sizeof(query));
			}
			else
			{
				// Only Create new, if gold is enough (Why fill up database?)
				if(p_bank[client][W3Bank_gold]>0)
				{
					char query[400];
					int buffer_len=strlen(steamid) * 2 + 1;
					char[] newshortname = new char[buffer_len];
					SQL_EscapeString(g_hDatabase,steamid,newshortname,buffer_len);
					Format(query,sizeof(query),"INSERT INTO %s (sid,gold,withdraw_stamp) VALUES ('%s','%d','0')",DATABASENAME,newshortname,p_bank[client][W3Bank_gold],p_bank[client][W3Bank_timestamp]);
					SQL_TQuery(g_hDatabase,SQLCallback_Void,query,sizeof(query));
				}
			}
		}
	}
}

public SQLCallback_Void(Handle:db, Handle:hndl, const String:error[], any:userid)
{
	if(hndl == INVALID_HANDLE)
	{
		BankLog("SQLCallback_Void: Error %s", error);
	}
}


public Action:DoAutosave(Handle:timer,any:data)
{
	if(W3SaveEnabled() && CanLoadDataBase && !MapChanging)
	{
		for(int x=1;x<=MaxClients;x++)
		{
			if(ValidPlayer(x))
			{
				Internal_SaveBank(x);
			}
		}
	}
	CreateTimer(300.0,DoAutosave);
}

///////////////////// DATABSE: PLAYERJOIN ////////////////////////////
///////////////////// DATABSE: PLAYERJOIN ////////////////////////////
///////////////////// DATABSE: PLAYERJOIN ////////////////////////////
///////////////////// DATABSE: PLAYERJOIN ////////////////////////////
///////////////////// DATABSE: PLAYERJOIN ////////////////////////////

public SQLCallback_PlayerJoin(Handle:db, Handle:hndl, const String:error[], any:userid)
{
	int client = GetClientOfUserId(userid);

	if(client<=0 || client>MaxClients || !IsClientConnected(client) || !IsClientInGame(client) || IsFakeClient(client))
	{
		return;
	}

	if(hndl == INVALID_HANDLE)
	{
		//BankLog("SQLCallback_PlayerJoin: Error looking up player gold,withdraw stamp. %s.", error);

		//Bank Does not exists .. create one
		char longquery2[4000];
		if(War3SQLType==SQLType_MySQL)
		{
			Format(longquery2,sizeof(longquery2),"\
			CREATE TABLE `bank` ( \
			  `sid` varchar(64) NOT NULL, \
			  `gold` bigint(20) NOT NULL, \
			  `withdraw_stamp` bigint(20) NOT NULL, \
			  PRIMARY KEY (`sid`), \
			  UNIQUE KEY `sid` (`sid`) \
			) ENGINE=InnoDB DEFAULT CHARSET=latin1;");
		}
		else
		{
			//sqlite3
			Format(longquery2,sizeof(longquery2),"\
			CREATE TABLE bank ( \
			  sid TEXT NOT NULL, \
			  gold INT NOT NULL, \
			  withdraw_stamp INT NOT NULL, \
			  PRIMARY KEY (sid), \
			  CONSTRAINT sid UNIQUE (sid) \
			)");
		}

		if(!SQL_FastQueryLogOnError(g_hDatabase,longquery2))
		{
			SetFailState("[War3Source:EVO] SQL_FastQueryLogOnError longquery2 ERROR in the creation of the SQL table bank");
			return;
		}
		else
		{
			// try again
			char steamid[64];
			if(g_hDatabase && ValidPlayer(client) && !IsFakeClient(client) && GetClientAuthId(client,AuthId_Steam2,STRING(steamid),true))
			{
				char query[256];
				Format(query, sizeof(query), "SELECT gold,withdraw_stamp FROM `%s` WHERE `sid` = '%s';",DATABASENAME,steamid);
				SQL_TQuery(g_hDatabase, SQLCallback_PlayerJoin, query, GetClientUserId(client));
				PrintToServer("hope this doesn't loop... SELECT gold,withdraw_stamp FROM `%s` WHERE `sid` = '%s';",DATABASENAME,steamid);
				return;
			}
		}
	}

	int retrievals;
	while(SQL_MoreRows(hndl))
	{
		if(SQL_FetchRow(hndl))
		{
			p_bank[client][W3Bank_gold]=W3SQLPlayerInt(hndl,"gold");

			p_bank[client][W3Bank_timestamp]=W3SQLPlayerInt(hndl,"withdraw_stamp");

			retrievals++;
		}
	}
	if(retrievals>0)
	{
		p_bank[client][hasbank]=true;
		Call_StartForward(g_OnWar3_BANK_PlayerLoadData);
		Call_PushCell(client);
		Call_Finish(dummy);
	}
	//new inserts;  ?? not sure if needed from War3Source_Engine_DatabaseSaveXP.sp .. removed the rest
	//War3_ChatMessage(client,"Successfully retrieved gems save data");
}

public withdrawalTime0(time)
{
	int withdrawnumber=GetConVarInt(WithDrawTimeLimitCvar);
	return (time-GetTime() < -withdrawnumber);
}

stock String:withdrawalTime1(time)
{
	int withdrawnumber=GetConVarInt(WithDrawTimeLimitCvar);
	time=time+withdrawnumber-GetTime();
	int hours=RoundToFloor((time % 86400 )/3600.0) ;
	int minutes=RoundToFloor((time % 86400 % 3600) / 60.0);
	int seconds=time % 86400 % 3600 % 60;

	char buffer[256];
	if (time < 0)
	{
		hours=0;
		minutes=0;
		seconds=0;
	}

	Format(buffer, sizeof(buffer),"%i hours, %i minutes, %i seconds",hours,minutes,seconds);

	return buffer;
}
