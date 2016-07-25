// War3Source_Engine_Race_KDR.sp

//#assert GGAMEMODE == MODE_WAR3SOURCE


//#assert GGAMETYPE == GGAME_TF2
//#assert GGAMETYPE2 == GGAME_TF2_NORMAL

//////////////////////////////////////////////////////////////////
// Declaring variables and handles
//////////////////////////////////////////////////////////////////

new String:sHostName[128];

new Deaths[MAXRACES];
new Kills[MAXRACES];

new bool:CanRecord=true;

//////////////////////////////////////////////////////////////////
// Plugin Info
//////////////////////////////////////////////////////////////////
/*
public Plugin:myinfo =
{
	name = "RACES KDR",
	author = "El Diablo",
	description = "Kill Death Ratio for RACES",
	version = PLUGIN_VERSION,
	url = "http://www.war3evo.info"
};*/

//new Handle:hDB = INVALID_HANDLE;

//////////////////////////////////////////////////////////////////
// Database
//////////////////////////////////////////////////////////////////

/*
CREATE  TABLE `war3raceskdr_v2` (
  `ip` VARCHAR(16) NOT NULL ,
  `hostname` TEXT NULL ,
  `raceshortname` VARCHAR(16) NOT NULL ,
  `kills` INT(11) NOT NULL DEFAULT 0 ,
  `deaths` INT(11) NOT NULL DEFAULT 0 ,
  PRIMARY KEY (`ip`) );
*/

public War3Source_Engine_Race_KDR_OnWar3Event(client)
{
	hDB=internal_W3GetVar(hDatabase);
	War3Source_Engine_Race_KDR_Initialize_SQLTable();
}

War3Source_Engine_Race_KDR_Initialize_SQLTable()
{
	PrintToServer("[War3Source:EVO] Initialize SQLTable RACE KDR");
	if(hDB!=INVALID_HANDLE)
	{

		SQL_LockDatabase(hDB); //non threading operations here, done once on plugin load only, not map change

		//main table
		Handle query=SQL_Query(hDB,"SELECT * from war3raceskdr_v2 LIMIT 1");


		if(query==INVALID_HANDLE)
		{
			char createtable[3000];
			if(War3SQLType==SQLType_MySQL)
			{
				Format(createtable,sizeof(createtable),
				"CREATE TABLE IF NOT EXISTS `war3raceskdr_v2` ( \
				`hostname` text, \
				`raceshortname` varchar(16) NOT NULL, \
				`kills` int(11) NOT NULL DEFAULT '0', \
				`deaths` int(11) NOT NULL DEFAULT '0' \
				) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci");
			}
			else if(War3SQLType==SQLType_SQLite)
			{
				Format(createtable,sizeof(createtable),
				"CREATE TABLE IF NOT EXISTS war3raceskdr_v2 ( \
				hostname TEXT, \
				raceshortname TEXT NOT NULL, \
				kills INTEGER NOT NULL DEFAULT 0, \
				deaths INTEGER NOT NULL DEFAULT 0 \
				)");
			}

			if(!SQL_FastQueryLogOnError(hDB,createtable))
			{
				SetFailState("[War3Source:EVO] ERROR in the creation of the SQL table war3raceskdr_v2.");
			}

			//may not work 3 lines below
			new String:myquery[1000];
			Format(myquery,sizeof(myquery),"SELECT * FROM `war3raceskdr_v2`");
			SQL_TQuery(hDB,generateRACESKDR_Callback, myquery, DBPrio_Low);
		}
		else
		{
			new String:myquery[1000];
			//Format(myquery,sizeof(myquery),"SELECT ip,hostname,raceshortname,kills,deaths FROM `war3raceskdr_v2` WHERE WHERE `ip`='%s'",theServerIP);
			Format(myquery,sizeof(myquery),"SELECT * FROM `war3raceskdr_v2`");
			SQL_TQuery(hDB,generateRACESKDR_Callback, myquery, DBPrio_Low);
		}

		CloseHandle(query);

		SQL_UnlockDatabase(hDB);
	}
}


public generateRACESKDR_Callback(Handle:owner, Handle:hndl, const String:error[], any:data) {
	if (!(hDB == INVALID_HANDLE))
	{
		if (hndl == INVALID_HANDLE) {
			PrintToServer("VIP DB: Generate admins query failure! Admins not generated: %s",error);
			return;
		}
		else
		{
			new retrievals;
			new usefulretrievals;
			new bool:raceloaded[MAXRACES];
			while(SQL_MoreRows(hndl))
			{
				//PrintToServer("inside SQLCallback_LookupPlayer after while(SQL_MoreRows(hndl))");
				if(SQL_FetchRow(hndl)){ //SQLITE doesnt properly detect ending
					//PrintToServer("inside SQLCallback_LookupPlayer after if(SQL_FetchRow(hndl)){");
					new String:raceshortname[16];
					W3SQLPlayerString(hndl,"raceshortname",raceshortname,sizeof(raceshortname));
					new raceid=size16_GetRaceIDByShortname(raceshortname);
					if(raceid>0)
					{
						raceloaded[raceid]=true;
						//PrintToServer("inside SQLCallback_LookupPlayer after RACE_NAME");

						//PrintToServer("race_name: %s",raceshortname);

						//PrintToServer("race_name id: %d",raceid);

						Kills[raceid]=W3SQLPlayerInt(hndl,"kills");
						Deaths[raceid]=W3SQLPlayerInt(hndl,"deaths");

						usefulretrievals++;
					}
					retrievals++;
				}
			}
			if(retrievals>0){
				PrintToServer("[War3Source:EVO] Successfully retrieved kdr, total of %d races kdr were returned, %d races kdr used.",retrievals,usefulretrievals);
			}
			//new inserts;  ?? not sure if needed from War3Source_Engine_DatabaseSaveXP.sp .. removed the rest
			//War3_ChatMessage(client,"Successfully retrieved gems save data");

			int inserts;
			int RacesLoaded = GetRacesLoaded();
			char raceshortname[16];
			if(RacesLoaded>0)
			{
				for(int raceid=1;raceid<=RacesLoaded;raceid++)
				{
					if(raceloaded[raceid]==false)
					{
						//no record make one
						GetRaceShortname(raceid,raceshortname,sizeof(raceshortname));
						//size16_War3_GetRaceShortname(raceid,raceshortname);
						char query[3000];
						Format(query, sizeof(query),"INSERT INTO `war3raceskdr_v2`(`hostname`, `raceshortname`, `kills`, `deaths`) VALUES ('%s','%s','%d','%d')",
						sHostName,raceshortname,Kills[raceid],Deaths[raceid]);
						//PrintToServer("Race KDR Query: %s",query);
						SQL_TQuery(hDB, SQLCallback_Void, query, sizeof(query), DBPrio_Low);
					}
				}
				if(inserts>0)
				{
					PrintToServer("[War3Source:EVO] Inserting fresh data for %d jobs",inserts);
				}
			}
		}
	}
}
//////////////////////////////////////////////////////////////////
// Natives
//////////////////////////////////////////////////////////////////

public bool:War3Source_Engine_Race_KDR_InitNatives()
{
	CreateNative("War3_GetRaceKDR",Native_War3_GetRaceKDR);
	return true;
}

Float:fKDR(raceid,offset)
{
	new zDeaths = Deaths[raceid];
	new zFrags = Kills[raceid]+offset;

	if ((zDeaths == 0) && (zFrags != 0)) return float(zFrags);
	if (zFrags < 0) return float(0);

	if(zFrags<=0 && zDeaths<=0) return float(0);

	if(zDeaths<=0) return float(0);

	new Float:KDRate = FloatDiv(float(zFrags),float(zDeaths));
	//DP("%f",KDRate);

	return KDRate;
}
stock float GetRaceKDR(int raceid)
{
	int RacesLoaded=GetRacesLoaded();
	if(raceid>0 && raceid<=RacesLoaded)
	{
		return fKDR(raceid,0);
	}
	return 0.0;
}
public Native_War3_GetRaceKDR(Handle:plugin,numParams)
{
	int raceid = GetNativeCell(1);
	return GetRaceKDR(raceid);
}

//////////////////////////////////////////////////////////////////
// Stocks
//////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////
// Start Plugin
//////////////////////////////////////////////////////////////////

public War3Source_Engine_Race_KDR_OnPluginStart()
{
	// Get Database late load?
	//if(hDB==INVALID_HANDLE)
	//{
		//hDB=internal_W3GetVar(hDatabase);
		//Initialize_SQLTable();
	//}

#if GGAMETYPE == GGAME_TF2
	HookEvent("teamplay_round_start", War3Source_Engine_Race_KDR_HookRoundStart, EventHookMode_Post);
	HookEvent("teamplay_waiting_begins", War3Source_Engine_Race_KDR_HookRoundStart, EventHookMode_Post);
	HookEvent("teamplay_round_win", War3Source_Engine_Race_KDR_HookRoundEnd, EventHookMode_Post);
	HookEvent("teamplay_waiting_ends", War3Source_Engine_Race_KDR_HookRoundEnd, EventHookMode_Post);
#elseif (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
	HookEvent("round_start", War3Source_Engine_Race_KDR_HookRoundStart, EventHookMode_Post);
	HookEvent("cs_win_panel_round", War3Source_Engine_Race_KDR_HookRoundEnd, EventHookMode_Post);
	HookEvent("round_freeze_end", War3Source_Engine_Race_KDR_HookRoundEnd, EventHookMode_Post);
	HookEvent("round_end", War3Source_Engine_Race_KDR_HookRoundEnd, EventHookMode_Post);
#endif

	CreateTimer(230.0, War3Source_Engine_Race_KDR_DoAutosave, _, TIMER_REPEAT);
}

public Action:War3Source_Engine_Race_KDR_DoAutosave(Handle:timer,any:data)
{
	int RacesLoaded = GetRacesLoaded();
	for(int raceid=1;raceid<=RacesLoaded;raceid++)
	{
		if(hDB)
		{
			War3Source_EVO_SaveData(raceid);
		}
	}
	War3_ChatMessage(0,"Saved all race kdr stats");

	//CreateTimer(300.0,DoAutosave);
}


public War3Source_Engine_Race_KDR_OnMapStart()
{
	// Get Database late load?
	//if(hDB==INVALID_HANDLE)
	//{
		//hDB=internal_W3GetVar(hDatabase);
		//Initialize_SQLTable();
	//

	new Handle:cvHostname = INVALID_HANDLE;

	if (cvHostname == INVALID_HANDLE) {
		cvHostname = FindConVar("hostname");
	}

	if (cvHostname == INVALID_HANDLE) {
		sHostName[0]='\0';
	} else {
		GetConVarString(cvHostname, sHostName, sizeof(sHostName));
	}

}

public War3Source_Engine_Race_KDR_HookRoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	CanRecord = true;
}

public War3Source_Engine_Race_KDR_HookRoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	CanRecord = false;
}

//////////////////////////////////////////////////////////////////
// Action: Event Player Die
//////////////////////////////////////////////////////////////////

// Does not count deadringers
public War3Source_Engine_Race_KDR_OnWar3EventDeath(victim, attacker, deathrace, distance, attacker_hpleft)
{
	if(CanRecord==false) return;

	//if(IsKDREnabled != 1) return;

	// Self kills don't count!
	if(victim==attacker) return;

	if(!ValidPlayer(victim)) return;
	if(!ValidPlayer(attacker)) return;


#if GGAMETYPE2 == GGAME_TF2_NORMAL
	// BOTS DONT COUNT IN KDR FOR RACES
	if(IsFakeClient(victim)) return;
	if(IsFakeClient(attacker)) return;

	new numofplayers=GetRealClientCount(true);

	// Must be at least 2 real players
	if(numofplayers<2) return;
#endif

	new VictimRace=GetRace(victim);
	new AttackerRace=GetRace(attacker);
	if(VictimRace>0)
		Deaths[VictimRace]++;
	if(AttackerRace>0)
		Kills[AttackerRace]++;
}


//////////////////////////////////////////////////////////////////
// Function: Is client a bot
//////////////////////////////////////////////////////////////////


public bool:IsClientBot(client)
{
	char SteamID[64];
	// Get Steam ID
	GetClientAuthId(client,AuthId_Steam2,STRING(SteamID),true);

	//Check if BOT
	if (!IsFakeClient(client) && !StrEqual(SteamID, "BOT") && !StrEqual(SteamID, "STEAM_ID_PENDING")) return false;

	return true;
}

//////////////////////////////////////////////////////////////////
// End Plugin
//////////////////////////////////////////////////////////////////

public War3Source_Engine_Race_KDR_OnPluginEnd()
{
#if GGAMETYPE == GGAME_TF2
	UnhookEvent("teamplay_round_start", War3Source_Engine_Race_KDR_HookRoundStart, EventHookMode_Post);
	UnhookEvent("teamplay_waiting_begins", War3Source_Engine_Race_KDR_HookRoundStart, EventHookMode_Post);
	UnhookEvent("teamplay_round_win", War3Source_Engine_Race_KDR_HookRoundEnd, EventHookMode_Post);
	UnhookEvent("teamplay_waiting_ends", War3Source_Engine_Race_KDR_HookRoundEnd, EventHookMode_Post);
#elseif (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
	UnhookEvent("round_start", War3Source_Engine_Race_KDR_HookRoundStart, EventHookMode_Post);
	UnhookEvent("cs_win_panel_round", War3Source_Engine_Race_KDR_HookRoundEnd, EventHookMode_Post);
	UnhookEvent("round_freeze_end", War3Source_Engine_Race_KDR_HookRoundEnd, EventHookMode_Post);
	UnhookEvent("round_end", War3Source_Engine_Race_KDR_HookRoundEnd, EventHookMode_Post);
#endif
}


//////////////////////////////////////////////////////////////////
// Save Database
//////////////////////////////////////////////////////////////////
/*
CREATE  TABLE `war3raceskdr_v2` (
  `ip` VARCHAR(16) NOT NULL ,
  `hostname` TEXT NULL ,
  `raceshortname` VARCHAR(16) NOT NULL ,
  `kills` INT(11) NOT NULL DEFAULT 0 ,
  `deaths` INT(11) NOT NULL DEFAULT 0 ,
  PRIMARY KEY (`ip`) );
*/

War3Source_EVO_SaveData(raceid)
{
	//if(g_hDatabase && !IsFakeClient(client)&& W3SaveEnabled() && W3GetPlayerProp(client,xpLoaded) && raceid>0)
	if(hDB && raceid>0)
	{
		//PrintToServer("BEFORE SQL SAVING");

		new String:RaceShortName[16];
		GetRaceShortname(raceid,RaceShortName,sizeof(RaceShortName));

		if(StrEqual(RaceShortName, "", false))
		{
			PrintToServer("CAN'T SAVE WAR3 RACES KDR DATA!  RACE DOES NOT HAVE SHORTNAME");
			return;
		}

		new Handle:cvHostname = INVALID_HANDLE;

		if (cvHostname == INVALID_HANDLE) {
			cvHostname = FindConVar("hostname");
		}

		if (cvHostname == INVALID_HANDLE) {
			sHostName[0]='\0';
		} else {
			GetConVarString(cvHostname, sHostName, sizeof(sHostName));
		}

		new String:query[3000];
		Format(query, sizeof(query),"UPDATE war3raceskdr_v2 SET hostname='%s',raceshortname='%s',kills='%d',deaths='%d' WHERE raceshortname='%s';",
		sHostName,RaceShortName,Kills[raceid],Deaths[raceid],RaceShortName);
		//PrintToServer("Race KDR Query: %s",query);
		SQL_TQuery(hDB, War3Source_Engine_Race_KDR_SQLCallback_Void, query, sizeof(query), DBPrio_Low);
	}
}
public War3Source_Engine_Race_KDR_SQLCallback_Void(Handle:db, Handle:hndl, const String:error[], any:userid)
{
	if(hndl == INVALID_HANDLE)
	{
		LogError("SQLCallback_Void: Error War3Source_EVO_SaveData: %s.", error);
	}
}

