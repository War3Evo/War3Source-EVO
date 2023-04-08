// War3Source_Engine_DatabaseSaveXP.sp

// TRANSLATED

//#define PLUGIN_VERSION "0.0.0.1"

//#assert GGAMEMODE == MODE_WAR3SOURCE

#if (GGAMETYPE_JAILBREAK == JAILBREAK_OFF)
#define XP_GOLD_DATABASENAME "war3source_evo"
//#define XP_GOLD_DATABASENAME_WAR3SOURCE_RACES "war3sourceraces"
#define XP_GOLD_DATABASENAME_RACEDATA1 "war3source_evo_racedata1"
#elseif (GGAMETYPE_JAILBREAK == JAILBREAK_ON)
#define XP_GOLD_DATABASENAME "TF2Jail_war3source_evo"
//#define XP_GOLD_DATABASENAME_WAR3SOURCE_RACES "TF2Jail_war3source_evo_races"
#define XP_GOLD_DATABASENAME_RACEDATA1 "TF2Jail_war3source_evo_racedata1"
#endif

//new Handle:hDB;

//new War3SQLType:g_SQLType;

// ConVar definitions
new Handle:m_SaveXPConVar;
new Handle:hSetRaceOnJoinCvar;

new Handle:m_AutosaveTime;
new Handle:hCvarPrintOnSave;

new Handle:g_OnWar3PlayerAuthedHandle;
new desiredRaceOnJoin[MAXPLAYERSCUSTOM];

new bool:SelectPDataMainSteamIDLookUp[MAXPLAYERSCUSTOM];
new bool:SelectPDataRaceSteamIDLookUp[MAXPLAYERSCUSTOM];

/*
public Plugin:myinfo=
{
	name="W3S Engine Database save xp",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};*/

// happens on disconnect
public DatabaseClearPlayerVars(client)
{
	SelectPDataMainSteamIDLookUp[client]=false;
	SelectPDataRaceSteamIDLookUp[client]=false;
}

// happens on connect
public DatabaseInitPlayerVariables(client)
{
	SelectPDataMainSteamIDLookUp[client]=false;
	SelectPDataRaceSteamIDLookUp[client]=false;
}

public bool:War3Source_Engine_DatabaseSaveXP_InitNatives()
{
	PrintToServer("W3 MODE");
	CreateNative("W3SaveXP" ,NW3SaveXP);
	CreateNative("W3SaveEnabled" ,NW3SaveEnabled);

	return true;
}

public War3Source_Engine_DatabaseSaveXP_OnPluginStart()
{
	PrintToServer("[War3Source:EVO] %T","War3Source_Engine_DatabaseSaveXP_OnPluginStart Start",LANG_SERVER);
	//CreateConVar("DataBaseSaveXP",PLUGIN_VERSION,"[War3Source:EVO] DataBase Save XP",FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);

	m_SaveXPConVar=CreateConVar("war3_savexp","1");
	internal_W3SetVar(hSaveEnabledCvar,m_SaveXPConVar);

	hSetRaceOnJoinCvar=CreateConVar("war3_set_job_on_join","1");

	m_AutosaveTime=CreateConVar("war3_autosavetime","60");
	hCvarPrintOnSave=CreateConVar("war3_print_on_autosave","0","Print a message to chat when xp is auto saved?");

	g_OnWar3PlayerAuthedHandle=CreateGlobalForward("OnWar3PlayerAuthed",ET_Ignore,Param_Cell,Param_Cell);

	CreateTimer(GetConVarFloat(m_AutosaveTime),Database_DoAutosave);
	PrintToServer("[War3Source:EVO] %T","War3Source_Engine_DatabaseSaveXP_OnPluginStart END",LANG_SERVER);
}

public NW3SaveXP(Handle:plugin,numParams)
{
	new client=GetNativeCell(1);
	new race=GetNativeCell(2);
//	DP("SAVEXP CALLED");
	War3Source_SavePlayerData(client,race); //saves main also
}
public NW3SaveEnabled(Handle:plugin,numParams)
{
	return GetConVarInt(m_SaveXPConVar);
}




// may not need this anymore if we keep the war3source compressed
// the database connect handles this
public War3Source_Engine_DatabaseSaveXP_OnWar3Event(client)
{
	PrintToServer("[War3Source:EVO] %T","War3Source_Engine_DatabaseSaveXP_OnWar3Event()",LANG_SERVER);
	hDB=internal_W3GetVar(hDatabase);
	War3SQLType=internal_W3GetVar(hDatabaseType);
	Initialize_SQLTable();
	//DP("EVENT %d",event);
}




Initialize_SQLTable()
{
	PrintToServer("[War3Source:EVO] %T","Initialize SQLTable Main Table START",LANG_SERVER);
	if(hDB!=INVALID_HANDLE)
	{

		SQL_LockDatabase(hDB); //non threading operations here, done once on plugin load only, not map change

		char shortquery[512];

/*
		//war3sourceraces
		Format(shortquery,sizeof(shortquery),"SELECT * from %s LIMIT 1",XP_GOLD_DATABASENAME_WAR3SOURCE_RACES);
		new Handle:query=SQL_Query(hDB,shortquery);
		if(query!=INVALID_HANDLE) //table exists
		{
			PrintToServer("[War3Source:EVO] Dropping TABLE %s and recreating it (normal)",XP_GOLD_DATABASENAME_WAR3SOURCE_RACES) ;
			Format(shortquery,sizeof(shortquery),"DROP TABLE %s",XP_GOLD_DATABASENAME_WAR3SOURCE_RACES);
			SQL_FastQueryLogOnError(hDB,shortquery);
		}

		//always create new table
		new String:longquery[4000];
		Format(longquery,sizeof(longquery),"CREATE TABLE %s (",XP_GOLD_DATABASENAME_WAR3SOURCE_RACES);
		Format(longquery,sizeof(longquery),"%s %s",longquery,"shortname varchar(16) UNIQUE,");
		Format(longquery,sizeof(longquery),"%s %s",longquery,"name  varchar(32)");

		for(new i=1;i<MAXSKILLCOUNT;i++){
			Format(longquery,sizeof(longquery),"%s, skill%d varchar(32)",longquery,i);
			Format(longquery,sizeof(longquery),"%s, skilldesc%d varchar(2000)",longquery,i);
		}

		Format(longquery,sizeof(longquery),"%s ) %s",longquery,War3SQLType:internal_W3GetVar(hDatabaseType)==SQLType_MySQL?"DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci":"");

		SQL_FastQueryLogOnError(hDB,longquery);*/




		Handle query;
		//main table
		Format(shortquery,sizeof(shortquery),"SELECT * from %s LIMIT 1",XP_GOLD_DATABASENAME);
		query=SQL_Query(hDB,shortquery);


		if(query==INVALID_HANDLE)
		{
			char createtable[3000];
			Format(createtable,sizeof(createtable),
			"CREATE TABLE %s (steamid varchar(64) UNIQUE, accountid int, name varchar(64), currentrace varchar(16), gold int, diamonds int, platinum int, total_level int, total_xp int, levelbankV2 int, last_seen int, join_date int) %s",
			XP_GOLD_DATABASENAME,
			War3SQLType==SQLType_MySQL?"DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci":"" );

			if(!SQL_FastQueryLogOnError(hDB,createtable))
			{
				SetFailState("[War3Source:EVO] ERROR in the creation of the SQL table %s.",XP_GOLD_DATABASENAME);
			}
		}
		else
		{

			if(!SQL_FieldNameToNum(query, "join_date", dummy))
			{
				AddColumn(hDB,"join_date","int",XP_GOLD_DATABASENAME);
			}
			if(!SQL_FieldNameToNum(query, "accountid", dummy))
			{
				AddColumn(hDB,"accountid","int",XP_GOLD_DATABASENAME);
			}
			if(!SQL_FieldNameToNum(query, "levelbankV2", dummy))
			{
				AddColumn(hDB,"levelbankV2","int",XP_GOLD_DATABASENAME);
			}
			if(!SQL_FieldNameToNum(query, "gold", dummy))
			{
				if(War3SQLType==SQLType_SQLite){
					//sqlite cannot rename column
					AddColumn(hDB,"gold","int",XP_GOLD_DATABASENAME);
				}
				else{
					Format(shortquery,sizeof(shortquery),"ALTER TABLE %s CHANGE credits gold INT",XP_GOLD_DATABASENAME);
					SQL_FastQueryLogOnError(hDB,shortquery);
					PrintToServer("[War3Source:EVO] %T","Tried to change column from 'credits' to 'gold'",LANG_SERVER);
				}
			}
			if(!SQL_FieldNameToNum(query, "diamonds", dummy))
			{
				AddColumn(hDB,"diamonds","int",XP_GOLD_DATABASENAME);
			}
			if(!SQL_FieldNameToNum(query, "platinum", dummy))
			{
				AddColumn(hDB,"platinum","int",XP_GOLD_DATABASENAME);
			}

			CloseHandle(query);
		}//


		///NEW DATABASE STRUCTURE
		Format(shortquery,sizeof(shortquery),"SELECT * from %s LIMIT 1",XP_GOLD_DATABASENAME_RACEDATA1);
		query=SQL_Query(hDB,shortquery);
		if(query==INVALID_HANDLE)
		{
			PrintToServer("[War3Source:EVO] %T","{database} doesnt exist, creating!!!",LANG_SERVER,XP_GOLD_DATABASENAME_RACEDATA1);
			new String:longquery2[4000];
			Format(longquery2,sizeof(longquery2),"CREATE TABLE %s (steamid varchar(64), accountid int, raceshortname varchar(16), level int,  xp int, last_seen int)  %s",XP_GOLD_DATABASENAME_RACEDATA1,War3SQLType==SQLType_MySQL?"DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci":"");

			Format(shortquery,sizeof(shortquery),"CREATE UNIQUE INDEX steamid ON %s (steamid,raceshortname)",XP_GOLD_DATABASENAME_RACEDATA1);

			if(!SQL_FastQueryLogOnError(hDB,longquery2)
			||
			!SQL_FastQueryLogOnError(hDB,shortquery)
			)
			{
				SetFailState("[War3Source:EVO] %T","ERROR in the creation of the SQL table {tablename}",LANG_SERVER,XP_GOLD_DATABASENAME_RACEDATA1);
			}
			Format(shortquery,sizeof(shortquery),"SELECT * from %s LIMIT 1",XP_GOLD_DATABASENAME_RACEDATA1);
			query=SQL_Query(hDB,shortquery); //get a nother handle for next table check
		}

		//do another check for handle, cuz we may have just created database
		if(query==INVALID_HANDLE)
		{
			SetFailState("[War3Source:EVO] %T","invalid handle to data, ",LANG_SERVER);
		}
		else
		{	//table exists by now, add skill columns if not exists

			char columnname[16];
			int dummyfield;

			if(!SQL_FieldNameToNum(query, "accountid", dummyfield))
			{
				AddColumn(hDB,"accountid","int",XP_GOLD_DATABASENAME_RACEDATA1);
			}

			for(int i=1;i<MAXSKILLCOUNT;i++)
			{
				Format(columnname,sizeof(columnname),"skill%d",i);

				if(!SQL_FieldNameToNum(query, columnname , dummyfield))
				{
					AddColumn(hDB,columnname,"int",XP_GOLD_DATABASENAME_RACEDATA1);
				}
			}

			CloseHandle(query);
		}


		SQL_UnlockDatabase(hDB);
	}
	else
		PrintToServer("hDB invalid 123");

	PrintToServer("[War3Source:EVO] %T","Initialize SQLTable Main Table END",LANG_SERVER);
}


public Action:Database_DoAutosave(Handle:timer,any:data)
{
	PrintToServer("[War3Source:EVO] %T","Database_DoAutosave()",LANG_SERVER);
	if(W3SaveEnabled() && !MapChanging)
	{
		for(new x=1;x<=MaxClients;x++)
		{
			if(ValidPlayer(x)&& W3IsPlayerXPLoaded(x))
			{
				War3Source_SavePlayerData(x,GetRace(x));
			}
		}
		if(GetConVarInt(hCvarPrintOnSave)>0){
			War3_ChatMessage(0,"%t","Saving all player XP and updating stats");
		}
	}
	CreateTimer(GetConVarFloat(m_AutosaveTime),Database_DoAutosave);
}




//SAVING SECTION



War3Source_SavePlayerData(client,race)
{
	PrintToServer("[War3Source:EVO] %T","War3Source_SavePlayerData()",LANG_SERVER);
	if(hDB && W3SaveEnabled() && !IsFakeClient(client)&&W3IsPlayerXPLoaded(client))
	{
		War3_SavePlayerRace(client,race); //only save their current race
		War3_SavePlayerMainData(client);//main data
	}
}





//retrieve
public War3Source_Engine_DatabaseSaveXP_OnClientPutInServer(client)
{
	PrintToServer("[War3Source:EVO] %T","OnClientPutInServer {clientnumber}",LANG_SERVER,client);
	//DP("PUTIN");
	//DP("PUTINW3");
	SetPlayerProp(client,xpLoaded,false); //set race 0 may trigger unwanted behavior, block it first
	SetPlayerProp(client,bPutInServer,true); //stateful entry
	DoFwd_War3_Event(InitPlayerVariables,client);
	SetPlayerProp(client,xpLoaded,false);

//		W3CreateEvent(ClearPlayerVariables,client);


	if(IsFakeClient(client)){
		SetPlayerProp(client,xpLoaded,true);
	}
	else
	{
		if(W3SaveEnabled())
		{
			//War3_ChatMessage(client,"%T","Loading player data...",client);
			War3Source_LoadPlayerData(client);
		}
		else{
			DoForwardOnWar3PlayerAuthed(client);
		}
		if(!W3SaveEnabled() || hDB==INVALID_HANDLE)
			SetPlayerProp(client,xpLoaded,true); // if db failed , or no save xp
	}
}
public War3Source_Engine_DatabaseSaveXP_OnClientDisconnect(client)
{
	PrintToServer("[War3Source:EVO] %T","OnClientDisconnect {clientnumber}",LANG_SERVER,client);
	if(GetPlayerProp(client,bPutInServer)){ //he must have joined (not just connected) server already
		if(W3SaveEnabled() && W3IsPlayerXPLoaded(client)){
#if SHOPMENU3 == MODE_ENABLED
			W3SaveXPsh3(client,GetRace(client));
#endif
			War3Source_SavePlayerData(client,GetRace(client));
		}

		DoFwd_War3_Event(ClearPlayerVariables,client);
		SetPlayerProp(client,bPutInServer,false);
		desiredRaceOnJoin[client]=0;
	}
}

//SELECT STATEMENTS HERE
War3Source_LoadPlayerData(client) //war3source calls this
{
	PrintToServer("[War3Source:EVO] %T","LoadPlayerData {clientnumber}",LANG_SERVER,client);
	PrintToServer("");
	PrintToServer("%t","War3Source_LoadPlayerData(client)");

		//DP("LOAD");
	//need space for steam id
	//decl String:steamid[64];

	if(hDB) // no bots and steamid
	{
		//new bool:SteamIDExists = GetClientAuthString(client,steamid,sizeof(steamid));
//#if (GGAMETYPE == GGAME_CSGO)
	//	Convert_CSGO_ID_TO_TF2_SteamID(steamid,sizeof(steamid));
//#else
	//	Convert_UniqueID_TO_SteamID(steamid,sizeof(steamid));
//#endif
	//	PrintToServer("steamid = %s",steamid);

		new steamaccountid = GetSteamAccountID(client);

		PrintToServer("[War3Source:EVO] %T","steamaccountid = {steamaccountid}",LANG_SERVER,steamaccountid);

		new String:longquery[4000];
		//Prepare select query for main data
		Format(longquery,sizeof(longquery),"SELECT accountid,currentrace,gold,diamonds,platinum,levelbankV2,join_date FROM %s WHERE accountid='%d' LIMIT 1",XP_GOLD_DATABASENAME,steamaccountid);

		//Pass off to threaded call back at normal prority

		StringMap QueryCode = new StringMap();
		QueryCode.SetValue("client",client);
		QueryCode.SetString("query",longquery);

		SQL_TQuery(hDB,T_CallbackSelectPDataMain,longquery,QueryCode,DBPrio_High);

		PrintToServer(longquery);

		PrintToConsole(client,"[War3Source:EVO] %T","XP retrieval query: sending MAIN and load all races request! Time: {GetGameTime}",client,GetGameTime());
		SetPlayerProp(client,sqlStartLoadXPTime,GetGameTime());

		//Lets get race data too

		Format(longquery,sizeof(longquery),"SELECT * FROM %s WHERE accountid='%d'",XP_GOLD_DATABASENAME_RACEDATA1,steamaccountid);

		StringMap QueryCode2 = new StringMap();
		QueryCode2.SetValue("client",client);
		QueryCode2.SetString("query",longquery);

		SQL_TQuery(hDB,T_CallbackSelectPDataRace,longquery,QueryCode2,DBPrio_High);

		PrintToServer(longquery);

	}
}

public void T_CallbackSelectPDataMain(Handle owner,Handle hndl,const char[] error, StringMap QueryCode)
{
	PrintToServer("[War3Source:EVO] %T","T_CallbackSelectPDataMain()",LANG_SERVER);
	int client;

	QueryCode.GetValue("client", client);

	SQLCheckForErrors(hndl,error,"T_CallbackSelectPDataMain",QueryCode);
	PrintToServer("[War3Source:EVO] %T","T_CallbackSelectPDataMain ERRORS? {errormessage}",LANG_SERVER,error);

	if(QueryCode != null)
	{
		QueryCode.Close();
	}

	if(!ValidPlayer(client))
	{
		//PrintToConsole(client,"[War3Source:EVO] T_CallbackSelectPDataMain !ValidPlayer(%d)",client);
		return;
	}

	if(hndl==INVALID_HANDLE)
	{
		if(!SelectPDataMainSteamIDLookUp[client])
		{
			SelectPDataMainSteamIDLookUp[client]=true;
			//Well the database is fucked up
			//TODO: add retry for select query
			LogError("[War3Source:EVO] %T","ERROR: SELECT player data failed! Check DATABASE settings!",LANG_SERVER);

			PrintToConsole(client,"[War3Source:EVO] %T","CAN NOT FIND YOUR ACCOUNT ID... Please wait while we look for your STEAMID instead...",client);

			decl String:steamid[64];

			// check for STEAMID
			if(hDB)
			{
				if(GetClientAuthId(client,AuthId_Steam2,STRING(steamid),true))
				{
					PrintToConsole(client,"[War3Source:EVO] %T","Please wait while we look up your steamid account information for",client);
					PrintToServer("[War3Source:EVO] %T","couldn't find account id, looking for steamid = {steamid}",LANG_SERVER,steamid);

					new String:longquery[4000];
					Format(longquery,sizeof(longquery),"SELECT accountid,currentrace,gold,diamonds,platinum,levelbankV2,join_date FROM %s WHERE steamid='%s'",XP_GOLD_DATABASENAME,steamid);

					//Pass off to threaded call back at normal prority
					StringMap QueryCode2 = new StringMap();
					QueryCode2.SetValue("client",client);
					QueryCode2.SetString("query",longquery);

					SQL_TQuery(hDB,T_CallbackSelectPDataMain,longquery,QueryCode2,DBPrio_High);

					PrintToServer(longquery);
				}
				else
				{
					PrintToConsole(client,"[War3Source:EVO] %T","ERROR RETRIEVING YOUR STEAM ID!",client);
					PrintToConsole(client,"[War3Source:EVO] %T","ERROR RETRIEVING YOUR STEAM ID!",client);
					PrintToConsole(client,"[War3Source:EVO] %T","ERROR RETRIEVING YOUR STEAM ID!",client);
					LogError("[War3Source:EVO] %T","ERROR: could not retrieve steam id {steamid} (after not finding accountid)",LANG_SERVER,steamid);
				}
			}
		}
	}
	else
	{
		if(SQL_GetRowCount(hndl) == 1)
		{
			PrintToServer("SQL_GetRowCount(hndl) == 1"); //debug info
			SQL_Rewind(hndl);

			if(!SQL_FetchRow(hndl))
			{
				//This would be pretty fucked to occur here
				LogError("[War3Source:EVO] %T","Unexpected error loading player data, could not FETCH row. Check DATABASE settings!",LANG_SERVER);
				PrintToServer("");
				PrintToServer("[War3Source:EVO] %T","Unexpected error loading player data, could not FETCH row. Check DATABASE settings!",LANG_SERVER);
				return;
			}
			else{
				PrintToServer("[War3Source:EVO] %T","GETTING PLAYER INFO",LANG_SERVER);
				PrintToServer("[War3Source:EVO] %T","GETTING PLAYER INFO",LANG_SERVER);
				PrintToServer("[War3Source:EVO] %T","GETTING PLAYER INFO",LANG_SERVER);

				char ssteamid[64];
				new bool:SteamIDExists = GetClientAuthId(client,AuthId_Steam2,STRING(ssteamid),true);

				if(W3SQL_ISNULL(hndl,"accountid"))
				{
					PrintToServer("[War3Source:EVO] %T","ACCOUNT ID IS NULL",LANG_SERVER);
					PrintToServer("[War3Source:EVO] %T","ACCOUNT ID IS NULL",LANG_SERVER);
					new steamaccountid = GetSteamAccountID(client);
					if(steamaccountid>0 && SteamIDExists)
					{
						PrintToServer("[War3Source:EVO] %T","ACCOUNT {account} STEAMID {steamid}",LANG_SERVER,steamaccountid,ssteamid);

						new String:shortquery[256];
						Format(shortquery,sizeof(shortquery),
						"UPDATE %s SET accountid='%d' WHERE steamid='%s'",XP_GOLD_DATABASENAME,steamaccountid,ssteamid);

						StringMap QueryCode3 = new StringMap();
						QueryCode3.SetValue("client",client);
						QueryCode3.SetString("query",shortquery);

						SQL_TQuery(hDB,T_CallbackInsertPDataMain,shortquery,QueryCode3,DBPrio_High);

						PrintToServer(shortquery);
					}
				}

				new TheJoinDate=W3SQLPlayerInt(hndl,"join_date");
				SetPlayerProp(client,JoinDate,TheJoinDate);
				PrintToServer("[War3Source:EVO] %T","Setting join_date {joindate}",LANG_SERVER,TheJoinDate);

				//Get the gold from the query
				new cred=W3SQLPlayerInt(hndl,"gold");
				//Set the gold for player
				PrintToServer("[War3Source:EVO] %T","Setting Gold {gold}",cred);
				PrintToConsole(client,"[War3Source:EVO] %T","Setting Gold {gold}",client,cred);
				War3_SetGold(client,cred);


				new diamonds=W3SQLPlayerInt(hndl,"diamonds");
				//Set the gold for player
				PrintToConsole(client,"[War3Source:EVO] %T","Setting Diamonds {diamonds}",client,diamonds);
				PrintToServer("[War3Source:EVO] %T","Setting Diamonds {diamonds}",LANG_SERVER,diamonds);
				War3_SetDiamonds(client,diamonds);


				new platinum=W3SQLPlayerInt(hndl,"platinum");
				PrintToConsole(client,"[War3Source:EVO] %T","Setting Platinum {platinum}",client,platinum);
				PrintToServer("[War3Source:EVO] %T","Setting Platinum {platinum}",LANG_SERVER,platinum);
				War3_SetPlatinum(client,platinum);

				new levelbankamount=W3SQLPlayerInt(hndl,"levelbankV2");

				if(W3GetLevelBank(client)>levelbankamount){ //whichever is higher
					levelbankamount=W3GetLevelBank(client);
				}
				PrintToConsole(client,"[War3Source:EVO] %T","Setting levelbank {levelbank}",client,levelbankamount);
				PrintToServer("[War3Source:EVO] %T","Setting levelbank {levelbank}",LANG_SERVER,levelbankamount);
				W3SetLevelBank(client,levelbankamount);


				//Get the short race string
				new String:currentrace[16];
				if(!W3SQLPlayerString(hndl,"currentrace",currentrace,sizeof(currentrace)))
				{
					LogError("[War3Source:EVO] %T","Unexpected error loading player currentrace. Check DATABASE settings!",LANG_SERVER);
					return;
				}
				PrintToConsole(client,"[War3Source:EVO] %T","War3 MAIN retrieval: gold {gold} Time {time}",client,cred,GetGameTime());
				PrintToConsole(client,"[War3Source:EVO] %T","Diamonds {diamonds}",client,diamonds);
				PrintToConsole(client,"[War3Source:EVO] %T","Platinum {platinum}",client,platinum);

				PrintToServer("[War3Source:EVO] %T","War3 MAIN retrieval: gold {gold} Time {time}",LANG_SERVER,cred,GetGameTime());
				PrintToServer("[War3Source:EVO] %T","Diamonds {diamonds}",LANG_SERVER,diamonds);
				PrintToServer("[War3Source:EVO] %T","Platinum {platinum}",LANG_SERVER,platinum);

				new raceFound=0; // worst case senario set player to race 0 <<-- changed to 1 so that they must have a race
				if(GetConVarInt(hSetRaceOnJoinCvar)>0)
				{
					//Scan all the races
					int RacesLoaded = GetRacesLoaded();
					if(RacesLoaded>0)
					{
						raceFound=1;  //Change default to 1 since races do exist
					}
					for(int x=1;x<=RacesLoaded;x++)
					{
						char short[16];
						GetRaceShortname(x,short,sizeof(short));

						//compare their short names to the one loaded
						if(StrEqual(currentrace,short,false))
						{
							raceFound=x;
							break;
						}
					}
					desiredRaceOnJoin[client]=raceFound;

				}
			}
		}
		else if(SQL_GetRowCount(hndl) == 0) //he or she doesnt exist
		{
			// look for STEAMID (since account id doesn't exist)
			if(hDB && !SelectPDataMainSteamIDLookUp[client])
			{
				SelectPDataMainSteamIDLookUp[client]=true;

				char ssteamid[64];

				if(GetClientAuthId(client,AuthId_Steam2,STRING(ssteamid),true))
				{
					PrintToConsole(client,"%T [War3Source:EVO]","Please wait while we look up your steamid account information for",client);

					PrintToServer("[War3Source:EVO] %T","couldn't find account id, looking for steamid = {steamid}",LANG_SERVER,ssteamid);

					new String:longquery[4000];
					Format(longquery,sizeof(longquery),"SELECT accountid,currentrace,gold,diamonds,platinum,levelbankV2,join_date FROM %s WHERE steamid='%s'",XP_GOLD_DATABASENAME,ssteamid);

					//Pass off to threaded call back at normal prority

					StringMap QueryCode4 = new StringMap();
					QueryCode4.SetValue("client",client);
					QueryCode4.SetString("query",longquery);

					SQL_TQuery(hDB,T_CallbackSelectPDataMain,longquery,QueryCode4,DBPrio_High);

					PrintToServer(longquery);
					return;
				}
			}

			///////////////////////////////////////////
			///////////////////////////////////////////
			///////////////////////////////////////////
			/////////IN THIS AREA IS///////////////////
			/////////WHERE THE NEW PLAYER DATA/////////
			/////////IS CREATED!///////////////////////
			///////////////////////////////////////////
			/////////CREATE A WAR3 EVENT///////////////
			///////////////////////////////////////////

			PrintToServer("[War3Source:EVO] %T","NEW PLAYER SETUP",LANG_SERVER);
			PrintToServer("[War3Source:EVO] %T","NEW PLAYER SETUP",LANG_SERVER);
			PrintToServer("[War3Source:EVO] %T","NEW PLAYER SETUP",LANG_SERVER);

			//Not in database so add
			decl String:steamid[64];
			decl String:name[64];
			//get their name and steamid
			if(GetClientAuthId(client,AuthId_Steam2,STRING(steamid),true) && GetClientName(client,name,sizeof(name))) // steamid
			{
				ReplaceString(name,sizeof(name), "'","", true);//REMOVE IT//double escape because \\ turns into -> \  after the %s insert into sql statement

				new String:szSafeName[(sizeof(name)*2)-1];
				SQL_EscapeString( hDB, name, szSafeName, sizeof(szSafeName));

				int total_level=GetTotalLevels(client);
				int total_xp=0;

				// Get data from the player vector I guess this allows the player to play before the queries are
				// done but it is probably zero all the time
				int RacesLoaded = GetRacesLoaded();
				for(int z=1;z<=RacesLoaded;z++)
				{
					total_xp+=GetXP(client,z);
				}

				char short_name[16];
				GetRaceShortname(GetRace(client),short_name,sizeof(short_name));

				char longquery[4000];
				// Main table query
				int steamaccountid = GetSteamAccountID(client);


				int joindate=GetTime();

				Format(longquery,sizeof(longquery),"INSERT INTO %s (steamid,accountid,name,currentrace,total_level,total_xp,join_date) VALUES ('%s','%d','%s','%s','%d','%d','%d')",XP_GOLD_DATABASENAME,steamid,steamaccountid,szSafeName,short_name,total_level,total_xp,joindate);

				//new Handle:querytrie=CreateTrie();
				//StringMap querytrie = new StringMap();
				//querytrie.SetString("query",longquery);
				//SetTrieString(querytrie,"query",longquery);
				StringMap QueryCode5 = new StringMap();
				QueryCode5.SetValue("client",client);
				QueryCode5.SetString("query",longquery);

				SQL_TQuery(hDB,T_CallbackInsertPDataMain,longquery,QueryCode5,DBPrio_Low);

				// Set New Player Job
				//War3_SetRace(client,1);

				new newrace = 0;
				if(NewPlayerIsEnabled==true)
				{
					if(NewPlayerRandomRaceEnabled==true)
					{
						new String:requiredflagstr[32];
						new racesloaded = GetRacesLoaded();
						newrace = GetRandomInt(1, racesloaded);
						new countit=0;
						GetRaceAccessFlagStr(newrace,requiredflagstr,sizeof(requiredflagstr));
						//while ((W3RaceHasFlag(newrace, "hidden")||W3RaceHasFlag(newrace, "steamgroup"))&&(!StrEqual(requiredflagstr, "0", false)||!StrEqual(requiredflagstr, "", false)))
						GetRaceShortname(newrace,short_name,sizeof(short_name));
		#if (GGAMETYPE_JAILBREAK == JAILBREAK_OFF)
						new String:RandomRacesStrDB[512];
						if(StrEqual(NewPlayerRandomRaces,""))
						{
							strcopy(RandomRacesStrDB, 500, "warden, undead, mage, nightelf, crypt, bh, naix, succubus, chronos, luna, lightbender,");
						}
						else
						{
							strcopy(RandomRacesStrDB, sizeof(NewPlayerRandomRaces), NewPlayerRandomRaces);
						}
						while(StrContains(RandomRacesStrDB,short_name) == -1)
		#elseif (GGAMETYPE_JAILBREAK == JAILBREAK_ON)
						new String:RandomRacesStrDB[512];
						if(StrEqual(NewPlayerRandomRaces,""))
						{
							strcopy(RandomRacesStrDB, 500, "crypt, bh, succubus, luna");
						}
						else
						{
							strcopy(RandomRacesStrDB, sizeof(NewPlayerRandomRaces), NewPlayerRandomRaces);
						}
						while(StrContains(RandomRacesStrDB,short_name) == -1)
	    #else
						new String:RandomRacesStrDB[512];
						if(StrEqual(NewPlayerRandomRaces,""))
						{
							strcopy(RandomRacesStrDB, 500, "warden, undead, mage, nightelf, crypt, bh, naix, succubus, chronos, luna, lightbender,");
						}
						else
						{
							strcopy(RandomRacesStrDB, sizeof(NewPlayerRandomRaces), NewPlayerRandomRaces);
						}
						while(StrContains(RandomRacesStrDB,short_name) == -1)
		#endif
						{
							PrintToServer("%s",short_name);
							countit++;
							newrace = GetRandomInt(1, racesloaded);
							GetRaceShortname(newrace,short_name,sizeof(short_name));
							//W3GetRaceAccessFlagStr(newrace,requiredflagstr,sizeof(requiredflagstr));
							if(countit>22)
							{
								newrace=1;
								//requiredflagstr="0";
								break;
							}
						}
						SetRace(client,newrace);
					}
					else
					{
						newrace = 0;
						SetRace(client,0);
					}

					War3_SetGold(client,NewPlayerStartingGold);

					// New First race will be MAX level race: (added 10 april 2015)

					int SetRaceLevel = GetRaceMaxLevel(newrace);
					//if(W3GetRaceMaxLevel(newrace)>10)
					//{
					if(NewPlayerStartingLevel==-999) // set race max level
					{
						SetLevel(client, newrace, SetRaceLevel);
					}
					else if(NewPlayerStartingLevel>SetRaceLevel) // set race max level
					{
						SetLevel(client, newrace, SetRaceLevel);
					}
					else if(NewPlayerStartingLevel>0) // set desired race level
					{
						SetLevel(client, newrace, NewPlayerStartingLevel);
					}
					else
					{
						SetLevel(client, newrace, 0);
					}
					//}
				}
				else
				{
					SetRace(client,0);
					SetLevel(client, newrace, 0);
					War3_SetGold(client,0);
				}
			}
		}
		else if(SQL_GetRowCount(hndl) >1)
		{
			// this is a WTF moment here
			//should probably purge these records and get the player to rejoin but I'm lazy
			//and don't want to write that
			LogError("[War3Source:EVO] %T","Returned more than 1 record, primary or UNIQUE keys are screwed (main, rows: {rows})",LANG_SERVER,SQL_GetRowCount(hndl));
			PrintToServer("[War3Source:EVO] %T","Returned more than 1 record, primary or UNIQUE keys are screwed (main, rows: {rows})",LANG_SERVER,SQL_GetRowCount(hndl));
		}
	}
}


//we just tried inserting main data
public void T_CallbackInsertPDataMain(Handle owner,Handle query,const char[] error, StringMap QueryCode)
{
	SQLCheckForErrors(query,error,"T_CallbackInsertPDataMain",QueryCode);
	if(QueryCode != null)
	{
		QueryCode.Close();
	}
	PrintToServer("[War3Source:EVO] %T","POSSIBLE ERRORS? {errormessages}",LANG_SERVER,error);
}







///callback retrieved individual race xp!!!!!
public void T_CallbackSelectPDataRace(Handle owner,Handle hndl,const char[] error, StringMap QueryCode)
{
	PrintToServer("T_CallbackSelectPDataRace");

	int client;

	QueryCode.GetValue("client",client);

	SQLCheckForErrors(hndl,error,"T_CallbackSelectPDataRace",QueryCode);
	if(QueryCode != null)
	{
		QueryCode.Close();
	}

	PrintToServer("[War3Source:EVO] %T","T_CallbackSelectPDataRace POSSIBLE ERRORS? {errormessages}",LANG_SERVER,error);

	if(!ValidPlayer(client))
		return;

	if(hndl!=INVALID_HANDLE)
	{
		int retrievals;
		int usefulretrievals;
		bool raceloaded[MAXRACES];

		int steamaccountid = GetSteamAccountID(client);

		char ssteamid[64];
		bool SteamIDExists = GetClientAuthId(client,AuthId_Steam2,STRING(ssteamid),true);

		while(SQL_MoreRows(hndl))
		{
			if(SQL_FetchRow(hndl)){ //SQLITE doesnt properly detect ending
				// Load up the data from a successful query
				// level,xp,skill1,skill2,skill3,ultimate

				char raceshortname[16];
				W3SQLPlayerString(hndl,"raceshortname",raceshortname,sizeof(raceshortname));
				int raceid=size16_GetRaceIDByShortname(raceshortname);
				if(raceid>0) //this race was loaded in war3
				{
					if(W3SQL_ISNULL(hndl,"accountid"))
					{
						if(steamaccountid>0 && SteamIDExists)
						{
							char shortquery[1024];
							Format(shortquery,sizeof(shortquery),
							"UPDATE %s SET accountid='%d' WHERE steamid='%s' AND raceshortname='%s'",XP_GOLD_DATABASENAME_RACEDATA1,steamaccountid,ssteamid,raceshortname);

							StringMap QueryCode6 = new StringMap();
							QueryCode6.SetValue("client",client);
							QueryCode6.SetString("query",shortquery);

							SQL_TQuery(hDB,T_CallbackInsertPDataRace,shortquery,QueryCode6,DBPrio_High);

							PrintToServer(shortquery);
						}
					}

					raceloaded[raceid]=true;
					int level=W3SQLPlayerInt(hndl,"level");

					// REMOVED.. causes races of different levels not to save the highest level
					//if(level>W3GetRaceMaxLevel(raceid)){
						//level=W3GetRaceMaxLevel(raceid);
					//}

					SetLevel(client,raceid,level);
					int pxp=W3SQLPlayerInt(hndl,"xp");
					SetXP(client,raceid,pxp);


					char printstr[500];
					Format(printstr,sizeof(printstr),"[War3Source:EVO] %T","XP Ret: Race {raceshortname} Level {level} XP {pxp} Time {GameTime}...",client,raceshortname,level,pxp,GetGameTime());



					char column[32];
					int skilllevel;
					int RacesSkillCount = GetRaceSkillCount(raceid);
					for(int skillid=1;skillid<=RacesSkillCount;skillid++){
						Format(column,sizeof(column),"skill%d",skillid);
						skilllevel=W3SQLPlayerInt(hndl,column);
						//Prevent Future Problems when we remove skill levels from certain races
						int SkillMaxLevel=GetRaceSkillMaxLevel(raceid,skillid);
						if(skilllevel>SkillMaxLevel)
						{
							skilllevel=SkillMaxLevel;
						}
						SetSkillLevelINTERNAL(client,raceid,skillid,skilllevel);

						Format(printstr,sizeof(printstr),"%s skill%d=%d",printstr,skillid,skilllevel);
					}

					usefulretrievals++;
					PrintToServer(printstr);
				}
				retrievals++;
			}
		}
		if(retrievals>0){
			PrintToConsole(client,"[War3Source:EVO] %T","Successfully retrieved data races, total of {numofraces} races were returned, {totalracesnum} are running on this server",client,retrievals,usefulretrievals);
		}
		else if(retrievals<=0&&GetRacesLoaded()>0)
		{//no xp record

			// Check for STEAM ID
			if(!SelectPDataRaceSteamIDLookUp[client])
			{
				//Well the database is fucked up
				//TODO: add retry for select query
				LogError("[War3Source:EVO] %T","ERROR: SELECT player data failed! Check DATABASE settings!",LANG_SERVER);

				War3_ChatMessage(client,"[War3Source:EVO] {red} %T","CAN NOT FIND YOUR ACCOUNT ID... Please wait while we look for your STEAMID instead...",client);

				char steamid[64];

				// check for STEAMID
				if(hDB && GetClientAuthId(client,AuthId_Steam2,STRING(steamid),true))
				{
					SelectPDataRaceSteamIDLookUp[client]=true;

					PrintToServer("[War3Source:EVO] %T","couldn't find account id, looking for steamid = {steamid}",LANG_SERVER,steamid);
					LogError("[War3Source:EVO] %T","couldn't find account id, looking for steamid = {steamid}",LANG_SERVER,steamid);

					new String:longquery[4000];
					Format(longquery,sizeof(longquery),"SELECT * FROM %s WHERE steamid='%s'",XP_GOLD_DATABASENAME_RACEDATA1,steamid);

					//Pass off to threaded call back at normal prority
					StringMap QueryCode7 = new StringMap();
					QueryCode7.SetValue("client",client);
					QueryCode7.SetString("query",longquery);

					SQL_TQuery(hDB,T_CallbackSelectPDataRace,longquery,QueryCode7,DBPrio_High);

					PrintToServer(longquery);
					return;
				}
			}

			DoFwd_War3_Event(PlayerIsNewToServer,client);
			//PrintToServer("W3CreateEvent(PlayerIsNewToServer,client)");
		}
		new inserts;
		new RacesLoaded = GetRacesLoaded();
		for(new raceid=1;raceid<=RacesLoaded;raceid++)
		{

			if(raceloaded[raceid]==false)
			{

				//no record make one
				char steamid[64];
				char name[64];
				if(GetClientAuthId(client,AuthId_Steam2,STRING(steamid),true) && steamaccountid>0 && GetClientName(client,name,sizeof(name)) )
				{
					// don't even use name... why have it?

					//ReplaceString(name,sizeof(name), "'","", true);//REMOVE IT //double escape because \\ turns into -> \  after the %s insert into sql statement

					//new String:szSafeName[(sizeof(name)*2)-1];
					//SQL_EscapeString( hDB, name, szSafeName, sizeof(szSafeName));

					new String:longquery[4000];
					new String:short[16];
					GetRaceShortname(raceid,short,sizeof(short));

					new last_seen=GetTime();
					Format(longquery,sizeof(longquery),"INSERT INTO %s (steamid,accountid,raceshortname,level,xp,last_seen) VALUES ('%s','%d','%s','%d','%d','%d');",
					XP_GOLD_DATABASENAME_RACEDATA1,steamid,steamaccountid,short,War3_GetLevelEx(client,raceid,true),GetXP(client,raceid),last_seen);

					StringMap QueryCode8 = new StringMap();
					QueryCode8.SetValue("client",client);
					QueryCode8.SetString("query",longquery);

					SQL_TQuery(hDB,T_CallbackInsertPDataRace,longquery,QueryCode8,DBPrio_Low);
					inserts++;

					PrintToServer(longquery);
				}
			}

		}
		if(inserts>0){

			PrintToConsole(client,"[War3Source:EVO] %T","Inserting fresh level xp data for {inserts} races",client,inserts);
		}


		SetPlayerProp(client,xpLoaded,true);
		//War3_ChatMessage(client,"Successfully retrieved save data");
		PrintToConsole(client,"[War3Source:EVO] %T","XP RETRIEVED IN {seconds} seconds",client,(GetGameTime()-Float:GetPlayerProp(client,sqlStartLoadXPTime)));

		if(GetRace(client)<=0 && desiredRaceOnJoin[client]>0){

			if(CanSelectRace(client,desiredRaceOnJoin[client])){
				SetPlayerProp(client,RaceSetByAdmin,false);
				SetRace(client,desiredRaceOnJoin[client]);
			}
			else{
				DoFwd_War3_Event(DoShowChangeRaceMenu,client);
			}
		//PrintToServer("shoudl set race? %d client %d",raceDesiredOnJoin,client);
		/*	new bool:doset=true;
			if(GetConVarInt(internal_W3GetVar(hRaceLimitEnabledCvar))>0){
				if(!CanSelectRace(client,desiredRaceOnJoin[client])){
					doset=false;
				}
				else if(GetRacesOnTeam(desiredRaceOnJoin[client],GetClientTeam(client))>=W3GetRaceMaxLimitTeam(desiredRaceOnJoin[client],GetClientTeam(client)))
				{
					doset=false;
					War3_ChatMessage(client,"%T","Race limit for your team has been reached, please select a different race. (MAX {amount})",client,W3GetRaceMaxLimitTeam(desiredRaceOnJoin[client],GetClientTeam(client)));
					W3Log("race %d blocked on client %d due to restrictions limit %d (set race on join)",desiredRaceOnJoin[client],client,W3GetRaceMaxLimitTeam(desiredRaceOnJoin[client],GetClientTeam(client)));
					DoFwd_War3_Event(DoShowChangeRaceMenu,client);

				}

			}
			if(doset){ ///player race was set on join,
				SetPlayerProp(client,RaceSetByAdmin,false);
				SetRace(client,desiredRaceOnJoin[client]);
			}*/
			//else{  ///player race NOT was set on join, show menu
			//	W3CreateEvent(DoShowChangeRaceMenu,client);
			//}
		}
		// After Race is setup in database.
		SetPlayerProp(client,dbRaceSelected,true);
		DoForwardOnWar3PlayerAuthed(client);
	}
	else
	{
		if(!SelectPDataRaceSteamIDLookUp[client])
		{
			//Well the database is fucked up
			//TODO: add retry for select query
			LogError("[War3Source:EVO] %T","ERROR: SELECT player data failed! Check DATABASE settings!",LANG_SERVER);

			War3_ChatMessage(client,"[War3Source:EVO] {red} %T","CAN NOT FIND YOUR ACCOUNT ID... Please wait while we look for your STEAMID instead...",client);

			char steamid[64];

			// check for STEAMID
			if(hDB && GetClientAuthId(client,AuthId_Steam2,STRING(steamid),true))
			{
				SelectPDataRaceSteamIDLookUp[client]=true;

				PrintToServer("[War3Source:EVO] %T","couldn't find account id, looking for steamid = {steamid}",LANG_SERVER,steamid);
				LogError("[War3Source:EVO] %T","couldn't find account id, looking for steamid = {steamid}",LANG_SERVER,steamid);

				new String:longquery[4000];
				Format(longquery,sizeof(longquery),"SELECT * FROM %s WHERE steamid='%s'",XP_GOLD_DATABASENAME_RACEDATA1,steamid);

				//Pass off to threaded call back at normal prority
				StringMap QueryCode9 = new StringMap();
				QueryCode9.SetValue("client",client);
				QueryCode9.SetString("query",longquery);

				SQL_TQuery(hDB,T_CallbackSelectPDataRace,longquery,QueryCode9,DBPrio_High);

				PrintToServer(longquery);
			}
		}
	}
}

public void T_CallbackInsertPDataRace(Handle owner,Handle query,const char[] error, StringMap QueryCode)
{
	SQLCheckForErrors(query,error,"T_CallbackInsertPDataRace",QueryCode);
	if(QueryCode != null)
	{
		QueryCode.Close();
	}
	PrintToServer("T_CallbackInsertPDataRace ERRORS? %s",error);
}

//SAVE
//SAVE
//SAVE
//SAVE
//SAVE
//SAVE
//SAVE
//SAVE
//SAVE

//saveing section
//save a race using new db style
War3_SavePlayerRace(client,race)
{
	PrintToServer("[War3Source:EVO] %T","SavePlayerRace client {client} race {race}",LANG_SERVER,client,race);
	//DP("save");
	if(hDB && W3SaveEnabled() && GetPlayerProp(client,xpLoaded)&&race>0)
	{
		//DP("save2");
		//PrintToServer("race %d client %d",race,client);
		char steamid[64];

		if(GetClientAuthId(client,AuthId_Steam2,STRING(steamid),true))
		{
			int steamaccountid = GetSteamAccountID(client);

			int level=War3_GetLevelEx(client,race,true);
			int xp=GetXP(client,race);

			//DP("%d,%d,",level,xp);
			char raceshortname[16];
			GetRaceShortname(race,raceshortname,sizeof(raceshortname));


			char longquery[4000];
			Format(longquery,sizeof(longquery),"UPDATE %s SET level='%d',xp='%d' ",XP_GOLD_DATABASENAME_RACEDATA1,level,xp);

			int SkillCount = GetRaceSkillCount(race);
			for(int skillid=1;skillid<=SkillCount;skillid++){
				Format(longquery,sizeof(longquery),"%s, skill%d=%d ",longquery,skillid,GetSkillLevelINTERNAL(client,race,skillid));
			}

			int last_seen=GetTime();
			if(steamaccountid>0)
			{
				Format(longquery,sizeof(longquery),"%s , last_seen='%d' WHERE (accountid='%d' AND raceshortname='%s') OR (steamid='%s' AND raceshortname='%s')",longquery,last_seen,steamaccountid,raceshortname,steamid,raceshortname);
			}
			else
			{
				Format(longquery,sizeof(longquery),"%s , last_seen='%d' WHERE steamid='%s' AND raceshortname='%s'",longquery,last_seen,steamid,raceshortname);
			}

			char racename[32];
			GetRaceName(race,racename,sizeof(racename));
			PrintToConsole(client,"[War3Source:EVO] %T","Saving XP for race {racename}: LVL {level} XP {xp}",client,racename,level,xp);

			//XP safety?
			//	new level=War3_GetLevel(client,x);
			//	if(level<W3GetRaceMaxLevel(x)){
			//		Format(longquery,sizeof(longquery),"%s AND level<='%d'",query_buffer,templevel); //only level restrict if not max, iif max or over do not restrict
			//	}

			//new Handle:querytrie=CreateTrie();
			//SetTrieString(querytrie,"query",longquery);

			StringMap QueryCode = new StringMap();
			QueryCode.SetValue("client",client);
			QueryCode.SetString("query",longquery);

			SQL_TQuery(hDB,T_CallbackSavePlayerRace,longquery,QueryCode,DBPrio_Low);
			//DP("%s",longquery);
			//ThrowError("END SAVE");
		}
	}
}
public void T_CallbackSavePlayerRace(Handle owner,Handle hndl,const char[] error, StringMap QueryCode)
{
	SQLCheckForErrors(hndl,error,"T_CallbackSavePlayerRace",QueryCode);
	if(QueryCode != null)
	{
		QueryCode.Close();
	}
}



War3_SavePlayerMainData(client)
{
	PrintToServer("[War3Source:EVO] %T","SavePlayerMainData client {clientnumber}",LANG_SERVER,client);
	if(hDB &&W3IsPlayerXPLoaded(client))
	{
		//PrintToServer("client %d mainxp",client);
		char steamid[64];
		char name[64];
		if(GetClientAuthId(client,AuthId_Steam2,STRING(steamid),true) && GetClientName(client,name,sizeof(name)))
		{
			ReplaceString(name,sizeof(name), "'","", true);//REMOVE IT //double escape because \\ turns into -> \  after the %s insert into sql statement

			//int SizeOfName = (sizeof(name)*2)-1;
			char szSafeName[128];
			SQL_EscapeString( hDB, name, STRING(szSafeName));


			char longquery[4000];
			int total_level=GetTotalLevels(client);
			int total_xp=0;
			int RacesLoaded = GetRacesLoaded();
			for(int z=1;z<=RacesLoaded;z++)
			{
				total_xp+=GetXP(client,z);
			}

			int last_seen=GetTime();

			int steamaccountid = GetSteamAccountID(client);

			char short[16];
			GetRaceShortname(GetRace(client),short,sizeof(short));
			if(steamaccountid>0)
			{
				Format(longquery,sizeof(longquery),"UPDATE %s SET name='%s',currentrace='%s',gold='%d',diamonds='%d',platinum='%d',total_level='%d',total_xp='%d',last_seen='%d',levelbankV2='%d' WHERE accountid='%d' OR steamid = '%s'",XP_GOLD_DATABASENAME,szSafeName,short,War3_GetGold(client),War3_GetDiamonds(client),War3_GetPlatinum(client),total_level,total_xp,last_seen,W3GetLevelBank(client),steamaccountid,steamid);
			}
			else
			{
				Format(longquery,sizeof(longquery),"UPDATE %s SET name='%s',currentrace='%s',gold='%d',diamonds='%d',platinum='%d',total_level='%d',total_xp='%d',last_seen='%d',levelbankV2='%d' WHERE steamid = '%s'",XP_GOLD_DATABASENAME,szSafeName,short,War3_GetGold(client),War3_GetDiamonds(client),War3_GetPlatinum(client),total_level,total_xp,last_seen,W3GetLevelBank(client),steamid);
			}
			//new Handle:querytrie=CreateTrie();
			//SetTrieString(querytrie,"query",longquery);

			StringMap QueryCode = new StringMap();
			QueryCode.SetValue("client",client);
			QueryCode.SetString("query",longquery);

			SQL_TQuery(hDB,T_CallbackUpdatePDataMain,longquery,QueryCode,DBPrio_Low);
		}
	}
}

//we just tried inserting main data
public void T_CallbackUpdatePDataMain(Handle owner,Handle query,const char[] error, StringMap QueryCode)
{
	SQLCheckForErrors(query,error,"T_CallbackUpdatePDataMain",QueryCode);
	if(QueryCode != null)
	{
		QueryCode.Close();
	}
}

DoForwardOnWar3PlayerAuthed(client)
{
	PrintToServer("[War3Source:EVO] %T","DoForwardOnWar3PlayerAuthed client {clientnumber}",LANG_SERVER,client);
	Internal_Engine_NewPlayers_OnWar3PlayerAuthedHandle(client);

	Call_StartForward(g_OnWar3PlayerAuthedHandle);
	Call_PushCell(client);
	Call_Finish(dummy);
}

