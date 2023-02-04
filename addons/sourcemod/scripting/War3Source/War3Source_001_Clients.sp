// War3Source_000_Clients.sp

public bool:OnClientConnect(client,String:rejectmsg[], maxlen)
{
	new bool:Return_OnClientConnect=true;

	//Return_OnClientConnect = War3Source_Engine_Statistics_OnClientConnect();

	return Return_OnClientConnect;
}
public OnClientConnected(client)
{
#if SHOPMENU3 == MODE_ENABLED
	War3Source_Engine_ItemDatabase3_OnClientConnected(client);
#endif

	War3Source_Engine_Wards_Engine_OnClientConnected(client);
#if GGAMETYPE != GGAME_CSGO
	War3Source_Engine_SteamTools_OnClientConnected(client);
#endif
}

public OnClientPutInServer(client)
{
	LastLoadingHintMsg[client]=GetGameTime();
	//DatabaseSaveXP now handles clearing of vars and triggering retrieval

	War3Source_Engine_DatabaseSaveXP_OnClientPutInServer(client);
#if GGAMETYPE != GGAME_FOF
	War3Source_Engine_BuffMaxHP_OnClientPutInServer(client);
#endif
	War3Source_Engine_BuffSystem_OnClientPutInServer(client);
#if CYBORG_SKIN == MODE_ENABLED
#if GGAMETYPE == GGAME_TF2
	War3Source_Engine_Cyborg_OnClientPutInServer(client);
#endif
#endif
	War3Source_Engine_DamageSystem_OnClientPutInServer(client);
	War3Source_Engine_ItemOwnership_OnClientPutInServer(client);
	//War3Source_Engine_Statistics_OnClientPutInServer(client);
	War3Source_Engine_Weapon_OnClientPutInServer(client);
#if GGAMETYPE != GGAME_CSGO
	War3Source_Engine_SteamTools_OnClientPutInServer(client);
#endif
	//disabled
	//War3Source_Engine_Talents_OnClientPutInServer(client);
#if GGAMETYPE == GGAME_CSGO
	War3Source_Engine_BuffSpeedGravGlow_OnClientPutInServer(client);
	War3Source_Engine_CSGO_Radar_OnClientChange(client);
#endif
}

public OnClientDisconnect(client)
{
	// War3Source_Engine_Bank
	if (client > 0 && client <= MaxClients)
	{
		Internal_SaveBank(client);
		Clear_Variables(client);
	}
#if GGAMETYPE == GGAME_TF2
	War3Source_Engine_BuffMaxHP_OnClientDisconnect(client);
#if CYBORG_SKIN == MODE_ENABLED
	War3Source_Engine_Cyborg_OnClientDisconnect(client);
#endif
#endif
	War3Source_Engine_DamageSystem_OnClientDisconnect(client);

	War3Source_Engine_DatabaseSaveXP_OnClientDisconnect(client);

	War3Source_Engine_NewPlayers_OnClientDisconnect(client);

	War3Source_Engine_Wards_Engine_OnClientDisconnect(client);

	War3Source_Engine_Weapon_OnClientDisconnect(client);

	War3Source_Engine_Casting_OnClientDisconnect(client);

#if GGAMETYPE == GGAME_CSGO
	War3Source_Engine_CSGO_Radar_OnClientChange(client);
#endif
}

public OnClientDisconnect_Post(client)
{
	War3Source_Engine_Download_Control_OnClientDisconnect_Post(client);
}


public OnWar3PlayerAuthed(client)
{
#if SHOPMENU3 == MODE_ENABLED
	War3Source_Engine_ItemDatabase3_OnWar3PlayerAuthed(client);
#endif

	War3Source_Engine_Notifications_OnWar3PlayerAuthed(client);

	War3Source_Engine_Wards_Wards_OnWar3PlayerAuthed(client);

//=============================
// War3Source_Engine_Bank
//=============================
	// Send call to database for gold information
	char steamid[64];

	if(g_hDatabase) // no bots and steamid
	{
		if(ValidPlayer(client) && !IsFakeClient(client) && GetClientAuthId(client,AuthId_Steam2,STRING(steamid),true))
		{
			CanLoadDataBase = true;

			//strcopy(p_bank_steamid[client], 63, steamid);

			char query[256];
			Format(query, sizeof(query), "SELECT gold,withdraw_stamp FROM `%s` WHERE `sid` = '%s';",DATABASENAME,steamid);
			SQL_TQuery(g_hDatabase, SQLCallback_PlayerJoin, query, GetClientUserId(client));
			return;
		}
	}
	else
	{
		g_hDatabase = internal_W3GetVar(hDatabase);
	}

	// Try one more time?
	if(g_hDatabase) // no bots and steamid
	{
		if(ValidPlayer(client) && !IsFakeClient(client) && GetClientAuthId(client,AuthId_Steam2,STRING(steamid),true))
		{
			CanLoadDataBase = true;

			//strcopy(p_bank_steamid[client], 63, steamid);

			char query[256];
			Format(query, sizeof(query), "SELECT gold,withdraw_stamp FROM `%s` WHERE `sid` = '%s';",DATABASENAME,steamid);
			SQL_TQuery(g_hDatabase, SQLCallback_PlayerJoin, query, GetClientUserId(client));
		}
	}
	else
	{
		BankLog("OnWar3PlayerAuthed() War3Source_Engine_Bank Database Invalid!");
	}

	//War3Source_Engine_Statistics_OnWar3PlayerAuthed(client);

}

//public OnClientPostAdminCheck(client)
//{
//}
