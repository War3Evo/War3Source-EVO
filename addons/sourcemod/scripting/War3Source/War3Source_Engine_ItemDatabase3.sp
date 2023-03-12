// War3Source_Engine_ItemDatabase3.sp

// SHOP MENU 3 ISN'T USED ... NOT TRANSLATED

/* Plugin Template generated by Pawn Studio */

//#assert GGAMEMODE == MODE_WAR3SOURCE

new Handle:m_AutosaveTime3;
/*
public Plugin:myinfo =
{
	name = "War3Source:EVO Database for Shopmenu3",
	author = "El Diablo",
	description = "Database for Shopmenu3.",
	version = "1.0",
	url = "http://war3evo.info/"
}*/
new Handle:g_hDatabase3 = INVALID_HANDLE;
new g_iPlayerID[MAXPLAYERSCUSTOM + 2] = {-1, ...};
public War3Source_Engine_ItemDatabase3_OnPluginStart()
{
	m_AutosaveTime3=CreateConVar("war3_sh3_autosavetime","300.0");
	CreateTimer(GetConVarFloat(m_AutosaveTime3),database3_DoAutosave);


	// Added so i can reload and test... may need to remove later?
	// worried it may not work good on server restart?
	/*
	g_hDatabase3 = internal_W3GetVar(hDatabase);

	if (g_hDatabase3 != INVALID_HANDLE)
	{
		decl String:steamid[64];

		for(new i=1; i <= MaxClients; i++)
		{
			if(ValidPlayer(i) && !IsFakeClient(i) && GetClientAuthString(i,steamid,sizeof(steamid)))
			{
				new String:query[256];
				Format(query, sizeof(query), "SELECT `player_id` FROM `war3_shopmenu3_players` WHERE `player_steam` = '%s';", steamid);
				SQL_TQuery(g_hDatabase3, SQLCallback_PlayerJoin, query, GetClientUserId(i));
			}
		}
	}*/
	RegConsoleCmd("W3SaveXPsh3_666",War3Source_CmdSAVESH3);
}

public Action:War3Source_CmdSAVESH3(client,args)
{
	//W3SaveXPsh3();
	if(W3SaveEnabled())
	{
		for(new i=1; i <= MaxClients; i++)
		{
			if(ValidPlayer(i) && !IsFakeClient(i))
			{
				W3SaveXPsh3(i,GetRace(i));
			}
		}
	}
	return Plugin_Handled;
}


public bool:War3Source_Engine_ItemDatabase3_InitNatives()
{
	CreateNative("W3SaveXPsh3" ,NW3SaveXPsh3);
	return true;
}

/* ***************************  OnRaceChanged *************************************/
public War3Source_Engine_ItemDatabase3_OnRaceChanged(client,oldrace,newrace)
{
		if(newrace!=oldrace){
			if(oldrace>0&&ValidPlayer(client)){
				War3Source_EVO_SavePlayerData(client,oldrace);
			}
		}
}

public NW3SaveXPsh3(Handle:plugin,numParams)
{
	new client=GetNativeCell(1);
	new race=GetNativeCell(2);
	War3Source_EVO_SavePlayerData(client,race); //saves main also
}

public War3Source_Engine_ItemDatabase3_OnClientConnected(client)
{
	g_iPlayerID[client] = -1;
}
//public OnClientAuthorized(client, const String:auth[])
//{
	//if(!IsFakeClient(client))
	//{
		//new String:query[256];
		//Format(query, sizeof(query), "SELECT `player_id` FROM `war3_shopmenu3_players` WHERE `player_steam` = '%s';", auth);
		//SQL_TQuery(g_hDatabase3, SQLCallback_PlayerJoin, query, GetClientUserId(client));
	//}
//}

public War3Source_Engine_ItemDatabase3_OnWar3PlayerAuthed(client)
{
	char steamid[64];

	if(W3SaveEnabled() && g_hDatabase3 && !IsFakeClient(client) && GetClientAuthId(client,AuthId_Steam2,STRING(steamid),true)) // no bots and steamid
	{
		PrintToServer("War3Source_Engine_ItemDatabase3_OnWar3PlayerAuthed --> steamid = %s",steamid);

		new steamaccountid = GetSteamAccountID(client);

		PrintToServer("War3Source_Engine_ItemDatabase3_OnWar3PlayerAuthed --> steamaccountid = %d",steamaccountid);

		new String:query[256];
		if(steamaccountid>0)
		{
			Format(query, sizeof(query), "SELECT `player_id`,`accountid` FROM `war3_shopmenu3_players` WHERE `accountid`='%d' OR (`player_steam`='%s' AND accountid IS NULL) LIMIT 1;", steamaccountid, steamid);
		}
		else
		{
			Format(query, sizeof(query), "SELECT `player_id`,`accountid` FROM `war3_shopmenu3_players` WHERE `player_steam` = '%s';", steamid);
		}
		SQL_TQuery(g_hDatabase3, SQLCallback_PlayerJoin_ItemDatabase3, query, GetClientUserId(client), DBPrio_High);
	}
}


/////////////////////////// SAVE
War3Source_EVO_SavePlayerData(client, raceid)
{
	//if(g_hDatabase3 && !IsFakeClient(client)&& W3SaveEnabled() && GetPlayerProp(client,xpLoaded) && raceid>0)
	if(W3SaveEnabled() && g_hDatabase3 && !IsFakeClient(client) && W3SaveEnabled() && GetPlayerProp(client,xpLoaded) && raceid>0)
	{
		char steamid[64];
		if(GetClientAuthId(client,AuthId_Steam2,STRING(steamid),true))
		{
			if(g_iPlayerID[client] > -1 && (War3_GetItemId1(client,raceid)>0 || War3_GetItemId2(client,raceid)>0 || War3_GetItemId3(client,raceid)>0))
			{

				char item1name[16];
				char item2name[16];
				char item3name[16];
				int sql_items[W3ItemInfo];

				int sql_item1=War3_GetItemId1(client,raceid);
				int sql_item2=War3_GetItemId2(client,raceid);
				int sql_item3=War3_GetItemId3(client,raceid);

				if(War3_GetOwnsItem3(client,raceid,sql_item1))
				{
					W3GetItem3Shortname(sql_item1,item1name,15);
					//sql_items[item1]=
					sql_items[item1level1]=War3_GetItemLevel(client, raceid, sql_item1);
					sql_items[item1xp1]=War3_GetItemXP(client, raceid, sql_item1);
					sql_items[item1level2]=War3_GetItemLevel2(client, raceid, sql_item1);
					sql_items[item1xp2]= War3_GetItemXP2(client, raceid, sql_item1);
				}
				else
				{
					strcopy(item1name, 15, "");
					//sql_items[item1]=
					sql_items[item1level1]=0;
					sql_items[item1xp1]=0;
					sql_items[item1level2]=0;
					sql_items[item1xp2]=0;
				}

				if(War3_GetOwnsItem3(client,raceid,sql_item2))
				{
					W3GetItem3Shortname(sql_item2,item2name,15);
					//sql_items[item1]=
					sql_items[item2level1]=War3_GetItemLevel(client, raceid, sql_item2);
					sql_items[item2xp1]=War3_GetItemXP(client, raceid, sql_item2);
					sql_items[item2level2]=War3_GetItemLevel2(client, raceid, sql_item2);
					sql_items[item2xp2]= War3_GetItemXP2(client, raceid, sql_item2);
				}
				else
				{
					strcopy(item2name, 15, "");
					//sql_items[item1]=
					sql_items[item2level1]=0;
					sql_items[item2xp1]=0;
					sql_items[item2level2]=0;
					sql_items[item2xp2]=0;
				}

				if(War3_GetOwnsItem3(client,raceid,sql_item3))
				{
					W3GetItem3Shortname(sql_item3,item3name,15);
					//sql_items[item1]=
					sql_items[item3level1]=War3_GetItemLevel(client, raceid, sql_item3);
					sql_items[item3xp1]=War3_GetItemXP(client, raceid, sql_item3);
					sql_items[item3level2]=War3_GetItemLevel2(client, raceid, sql_item3);
					sql_items[item3xp2]= War3_GetItemXP2(client, raceid, sql_item3);
				}
				else
				{
					strcopy(item3name, 15, "");
					//sql_items[item1]=
					sql_items[item3level1]=0;
					sql_items[item3xp1]=0;
					sql_items[item3level2]=0;
					sql_items[item3xp2]=0;
				}
				new String:raceshortname[16];
				GetRaceShortname(raceid,raceshortname,sizeof(raceshortname));

				//PrintToServer("BEFORE SQL SAVING");

				if(!StrEqual(raceshortname, ""))
				{
					new String:query[5000];
					Format(query, sizeof(query), "INSERT INTO `war3_shopmenu3_items`(`player_id`, `race_name`, `item1name`, `item1level1`, `item1xp1`, \
					`item1level2`, `item1xp2`, `item2name`, `item2level1`, `item2xp1`, `item2level2`, `item2xp2`, `item3name`, `item3level1`, `item3xp1`, `item3level2`, \
					`item3xp2`) VALUES('%d', '%s', '%s', '%d', '%d', '%d', '%d', '%s', '%d', '%d', '%d', '%d', '%s', '%d', '%d', '%d', \
					'%d') ON DUPLICATE KEY UPDATE `item1name`='%s', `item1level1`='%d', `item1xp1`='%d', `item1level2`='%d', `item1xp2`='%d', \
					`item2name`='%s', `item2level1`='%d', `item2xp1`='%d', `item2level2`='%d', `item2xp2`='%d', \
					`item3name`='%s', `item3level1`='%d', `item3xp1`='%d', `item3level2`='%d', `item3xp2`='%d';", g_iPlayerID[client], raceshortname,
					item1name,sql_items[item1level1],sql_items[item1xp1],sql_items[item1level2],sql_items[item1xp2],
					item2name,sql_items[item2level1],sql_items[item2xp1],sql_items[item2level2],sql_items[item2xp2],
					item3name,sql_items[item3level1],sql_items[item3xp1],sql_items[item3level2],sql_items[item3xp2],
					// ON DUPLICATE KEY UPDATE:
					item1name,sql_items[item1level1],sql_items[item1xp1],sql_items[item1level2],sql_items[item1xp2],
					item2name,sql_items[item2level1],sql_items[item2xp1],sql_items[item2level2],sql_items[item2xp2],
					item3name,sql_items[item3level1],sql_items[item3xp1],sql_items[item3level2],sql_items[item3xp2]);
					SQL_TQuery(g_hDatabase3, SQLCallback_Void, query, sizeof(query));
					PrintToServer(query);
				}
			}
		}
	}
}


public Action:database3_DoAutosave(Handle:timer,any:data)
{
	if(W3SaveEnabled() && !MapChanging)
	{
		for(new x=1;x<=MaxClients;x++)
		{
			if(ValidPlayer(x)&& W3IsPlayerXPLoaded(x))
			{
				War3Source_EVO_SavePlayerData(x,GetRace(x));
				//PrintToServer("Player Save Data Timer");
			}
		}
	}
	CreateTimer(GetConVarFloat(m_AutosaveTime3),database3_DoAutosave);
}
////////////////////////// END OF SAVE


/*
public SQLCallback_Void(Handle:db, Handle:hndl, const String:error[], any:userid)
{
	if(hndl == INVALID_HANDLE)
	{
		LogError("SQLCallback_Void: Error looking up player. %s.", error);
	}
}*/
public SQLCallback_PlayerJoin_ItemDatabase3(Handle:db, Handle:hndl, const String:error[], any:userid)
{
	if(hndl == INVALID_HANDLE)
	{
		LogError("SQLCallback_PlayerJoin: Error looking up player. %s.", error);
	}
	else
	{
		new client = GetClientOfUserId(userid);
		if(client == 0)
		{
			return;
		}
		if(SQL_GetRowCount(hndl) > 0)
		{

			//PrintToServer("SQLCallback_LookupPlayer");
			if(!SQL_FetchRow(hndl))
			{
				//This would be pretty fucked to occur here
				LogError("[War3Source:EVO] Unexpected error loading player shop item3 data, could not FETCH row. Check DATABASE settings!");
				PrintToServer("");
				PrintToServer("[War3Source:EVO] Unexpected error loading player  shop item3 data, could not FETCH row. Check DATABASE settings!");
				return;
			}
			else
			{
				g_iPlayerID[client] = SQL_FetchInt(hndl, 0);

				if(g_iPlayerID[client]>0)
				{
					if(W3SQL_ISNULL(hndl,"accountid"))
					{
						new steamaccountid = GetSteamAccountID(client);
						if(steamaccountid>0)
						{
							new String:shortquery[256];
							Format(shortquery,sizeof(shortquery),
							"UPDATE `war3_shopmenu3_players` SET accountid='%d' WHERE `player_id` = '%d';",steamaccountid,g_iPlayerID[client]);

							StringMap QueryCode = new StringMap();
							QueryCode.SetValue("client",client);
							QueryCode.SetString("query",shortquery);

							SQL_TQuery(hDB,T_CallbackACCOUNTID,shortquery,QueryCode);
							PrintToServer(shortquery);
						}
					}

					new String:query[256];
					Format(query, sizeof(query), "SELECT * FROM `war3_shopmenu3_items` WHERE `player_id` = '%d';", g_iPlayerID[client]);
					//DP("war3_shopmenu3_items g_iPlayerID[client] = %d",g_iPlayerID[client]);
					SQL_TQuery(g_hDatabase3, SQLCallback_LookupPlayer, query, GetClientUserId(client), DBPrio_High);
				}
			}
		}
		else // Dont comment out!  Needed for new players!
		{
			// becareful.. mysql is case sensitive!   Had max like max instead of MAX.
			new String:query[256];
			Format(query, sizeof(query), "SELECT MAX(`player_id`) FROM `war3_shopmenu3_players`;");
			//DP("SELECT MAX(`player_id`) FROM `war3_shopmenu3_players`;");
			SQL_TQuery(g_hDatabase3, SQLCallback_GetNextID, query, GetClientUserId(client), DBPrio_High);
			//DP("SQLCallback_GetNextID auth = %s",g_iPlayerID[client], auth);
			//SQL_TQuery(g_hDatabase3, SQLCallback_Void, query, sizeof(query));
		}
	}
}//STEAM_0:1:35173666

public void T_CallbackACCOUNTID(Handle owner,Handle query,const char[] error, StringMap QueryCode)
{
	SQLCheckForErrors(query,error,"T_CallbackACCOUNTID",QueryCode);
	if(QueryCode != null)
	{
		QueryCode.Close();
	}
	PrintToServer("POSSIBLE ERRORS? %s",error);
}

public SQLCallback_GetNextID(Handle:db, Handle:hndl, const String:error[], any:userid)
{
	if(hndl == INVALID_HANDLE)
	{
		LogError("Error getting next insert id. %s.", error);
	}
	else
	{
		new client = GetClientOfUserId(userid);
		if(client == 0)
		{
			return;
		}
		SQL_FetchRow(hndl);
		g_iPlayerID[client] = SQL_FetchInt(hndl, 0) + 1;
		char query[256];
		char auth[32];
		GetClientAuthId(client,AuthId_Steam2,STRING(auth),true);

		new steamaccountid = GetSteamAccountID(client);

		if(steamaccountid > 0)
		{
			Format(query, sizeof(query), "INSERT INTO `war3_shopmenu3_players`(`player_id`, `player_steam`, `accountid`) VALUES('%d', '%s', '%d');", g_iPlayerID[client], auth, steamaccountid);
		}
		else
		{
			Format(query, sizeof(query), "INSERT INTO `war3_shopmenu3_players`(`player_id`, `player_steam`, `accountid`) VALUES('%d', '%s');", g_iPlayerID[client], auth);
		}
		//DP("SQLCallback_GetNextID g_iPlayerID[client] = %d  auth = %s",g_iPlayerID[client], auth);
		SQL_TQuery(g_hDatabase3, SQLCallback_Void, query, sizeof(query), DBPrio_High);
	}
}


/*
public SQLCallback_LookupPlayer(Handle:db, Handle:hndl, const String:error[], any:userid)
{
	if(hndl == INVALID_HANDLE)
	{
		LogError("Error looking up player. %s.", error);
	}
	else
	{
		new client = GetClientOfUserId(userid);
		if(client == 0)
		{
			return;
		}
		new String:name[16];
		for(new i = 0; i < SQL_GetRowCount(hndl); i++)
		{
			SQL_FetchRow(hndl);
			SQL_FetchString(hndl, 0, name, sizeof(name));
			PushArrayString(g_hFavRaces[client], name);
		}
	}
}
*/






///////////////////// LOAD FROM SAVED DATA

// maybe SQLCallback_LookupPlayer replacement:
///callback retrieved individual race xp!!!!!
public SQLCallback_LookupPlayer(Handle:owner,Handle:hndl,const String:error[],any:userid)
{
	//SQLCheckForErrors(hndl,error,"T_CallbackSelectPDataRace");
	//PrintToServer("inside SQLCallback_LookupPlayer");

	new client = GetClientOfUserId(userid);

	//if(!ValidPlayer(client))
	//{
		//return;
	//}
	if(client<0 && client>MaxClients && !IsFakeClient(client) && !IsClientConnected(client) && !IsClientInGame(client))
	{
		//PrintToServer("INVALID CLIENT SQLCallback_LookupPlayer");
		return;
	}

	//PrintToServer("inside SQLCallback_LookupPlayer after valid player");


	if(hndl == INVALID_HANDLE)
	{
		LogError("SQLCallback_LookupPlayer: Error looking up player. %s.", error);
	}
	else
	{
		//PrintToServer("inside SQLCallback_LookupPlayer after hndl");
		new retrievals;
		new usefulretrievals;
		while(SQL_MoreRows(hndl))
		{
			//PrintToServer("inside SQLCallback_LookupPlayer after while(SQL_MoreRows(hndl))");
			if(SQL_FetchRow(hndl)){ //SQLITE doesnt properly detect ending
				//PrintToServer("inside SQLCallback_LookupPlayer after if(SQL_FetchRow(hndl)){");
				new String:raceshortname[16],String:itemname[16];
				if(W3SQLPlayerString(hndl,"race_name",raceshortname,sizeof(raceshortname)))
				{
					//PrintToServer("inside SQLCallback_LookupPlayer after RACE_NAME");

					//PrintToServer("race_name: %s",raceshortname);

					new raceid=size16_GetRaceIDByShortname(raceshortname);

					//PrintToServer("race_name id: %d",raceid);

					if(raceid>0) //this race was loaded in war3
					{
						//PrintToServer("Player Loading GEMS for race %s",raceshortname);
						// ITEM 1
						//W3SQLPlayerString(hndl,"item1name",itemname,sizeof(itemname));
						new sql_item; //=War3_GetItem3IdByShortname(itemname);
						new sql_itemlevel1,sql_itemxp1,sql_itemlevel2,sql_itemxp2;

						W3SQLPlayerString(hndl,"item1name",itemname,sizeof(itemname));

						//PrintToServer("item1name: %s",itemname);

						sql_item=War3_GetItem3IdByShortname(itemname);

						if(sql_item>0)
						{
							sql_itemlevel1=W3SQLPlayerInt(hndl,"item1level1");
							sql_itemxp1=W3SQLPlayerInt(hndl,"item1xp1");
							sql_itemlevel2=W3SQLPlayerInt(hndl,"item1level2");
							sql_itemxp2=W3SQLPlayerInt(hndl,"item1xp2");

							War3_SetOwnsItem3(client,raceid,sql_item,true);
							War3_SetItemLevel(client, raceid, sql_item, sql_itemlevel1);
							War3_SetItemXP(client, raceid, sql_item, sql_itemxp1);
							War3_SetItemLevel2(client, raceid, sql_item, sql_itemlevel2);
							War3_SetItemXP2(client, raceid, sql_item, sql_itemxp2);
						}
						sql_item=0;
						strcopy(itemname, 15, "");

						// ITEM 2
						W3SQLPlayerString(hndl,"item2name",itemname,sizeof(itemname));
						sql_item=War3_GetItem3IdByShortname(itemname);

						//PrintToServer("item2name: %s",itemname);

						if(sql_item>0)
						{
							sql_itemlevel1=W3SQLPlayerInt(hndl,"item2level1");
							sql_itemxp1=W3SQLPlayerInt(hndl,"item2xp1");
							sql_itemlevel2=W3SQLPlayerInt(hndl,"item2level2");
							sql_itemxp2=W3SQLPlayerInt(hndl,"item2xp2");

							War3_SetOwnsItem3(client,raceid,sql_item,true);
							War3_SetItemLevel(client, raceid, sql_item, sql_itemlevel1);
							War3_SetItemXP(client, raceid, sql_item, sql_itemxp1);
							War3_SetItemLevel2(client, raceid, sql_item, sql_itemlevel2);
							War3_SetItemXP2(client, raceid, sql_item, sql_itemxp2);
						}
						sql_item=0;
						strcopy(itemname, 15, "");

						// ITEM 3
						W3SQLPlayerString(hndl,"item3name",itemname,sizeof(itemname));
						sql_item=War3_GetItem3IdByShortname(itemname);

						//PrintToServer("item3name: %s",itemname);


						if(sql_item>0)
						{
							sql_itemlevel1=W3SQLPlayerInt(hndl,"item3level1");
							sql_itemxp1=W3SQLPlayerInt(hndl,"item3xp1");
							sql_itemlevel2=W3SQLPlayerInt(hndl,"item3level2");
							sql_itemxp2=W3SQLPlayerInt(hndl,"item3xp2");

							War3_SetOwnsItem3(client,raceid,sql_item,true);
							War3_SetItemLevel(client, raceid, sql_item, sql_itemlevel1);
							War3_SetItemXP(client, raceid, sql_item, sql_itemxp1);
							War3_SetItemLevel2(client, raceid, sql_item, sql_itemlevel2);
							War3_SetItemXP2(client, raceid, sql_item, sql_itemxp2);
						}

						//new String:printstr[500];
						//Format(printstr,sizeof(printstr),"[War3Source:EVO] Job %s Loaded Gems Time %f...",raceshortname,GetGameTime());
						usefulretrievals++;
					}
				}
				retrievals++;
			}
		}
		if(retrievals>0){
			PrintToConsole(client,"[War3Source:EVO] Successfully retrieved data gems, total of %d gems were returned, %d gems are running on this server for one player.",retrievals,usefulretrievals);
		}
		//new inserts;  ?? not sure if needed from War3Source_Engine_DatabaseSaveXP.sp .. removed the rest
		//War3_ChatMessage(client,"Successfully retrieved gems save data");
	}
}

/*
public T_CallbackInsertPDataRace(Handle:owner,Handle:query,const String:error[],any:data)
{
	SQLCheckForErrors(query,error,"T_CallbackInsertPDataRace");
}*/




public War3Source_Engine_ItemDatabase3_OnWar3Event(client)
{
	g_hDatabase3 = internal_W3GetVar(hDatabase);
	new String:query[600];
	Format(query, sizeof(query), "CREATE TABLE IF NOT EXISTS `war3_shopmenu3_players` ( \
		`player_id` INT UNSIGNED NOT NULL, \
		`player_steam` VARCHAR(64) NULL, \
		`accountid` INT(11) NULL, \
		PRIMARY KEY (`player_id`), \
		UNIQUE KEY `player_steam` (`player_steam`));" \
		);
	SQL_TQuery(g_hDatabase3, SQLCallback_CreatePlayerTable, query, sizeof(query), DBPrio_High);
}


public SQLCallback_CreatePlayerTable(Handle:db, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogError("Error creating player table. %s.", error);
	}
	else
	{
		new String:query[600];
		Format(query, sizeof(query), "CREATE TABLE IF NOT EXISTS `war3_shopmenu3_items` ( \
			`player_id` INT NOT NULL , \
			`race_name` VARCHAR(16) NULL , \
			`item1name` VARCHAR(16) NULL , \
			`item1level1` INT , \
			`item1xp1` INT , \
			`item1level2` INT , \
			`item1xp2` INT , \
			`item2name` VARCHAR(16) NULL , \
			`item2level1` INT , \
			`item2xp1` INT , \
			`item2level2` INT , \
			`item2xp2` INT , \
			`item3name` VARCHAR(16) NULL , \
			`item3level1` INT , \
			`item3xp1` INT , \
			`item3level2` INT , \
			`item3xp2` INT , \
			PRIMARY KEY (`race_name`, `player_id`) );"\
			);
		SQL_TQuery(g_hDatabase3, SQLCallback_CreateRaceTable, query, sizeof(query), DBPrio_High);
	}
}


public SQLCallback_CreateRaceTable(Handle:db, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogError("Error creating race table. %s.", error);
	}
}


