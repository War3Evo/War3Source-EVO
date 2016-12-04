// War3Soruce_Internal_Only_Stocks.inc

//War3Source_Engine_RaceClass

stock GetRaceMaxLimitTeamCvar(int raceid, int iTeam)
{
	if(raceid>0)
	{
		if(iTeam==TEAM_T||iTeam==TEAM_RED){
			return RestrictLimitCvar[raceid][0];
		}
		if(iTeam==TEAM_CT||iTeam==TEAM_BLUE){
			return RestrictLimitCvar[raceid][1];
		}
	}
	return -1;
}

//W3SetRaceCell(raceid,ENUM_RaceObject:property,any:somevalue);
stock int SetRaceCell(int raceid, ENUM_RaceObject property, any somevalue)
{
	raceCell[raceid][property]=somevalue;
}

//W3GetRaceCell(raceid,ENUM_RaceObject:property);
stock int GetRaceCell(int raceid, ENUM_RaceObject property)
{
	return raceCell[raceid][property];
}

stock GetRaceOrder(int raceid)
{
	//DP("getraceorder race %d cvar %d",raceid,RaceOrderCvar[raceid]);
	return GetCvarInt(RaceOrderCvar[raceid]);

}

//War3Source_Engine_TrieKeyValue
stock void GetCvar(int cvarid, char[] returnstr, int maxsize)
{
	char cvarstr[64];
	GetArrayString(Cvararraylist, cvarid,cvarstr,sizeof(cvarstr));
	char outstr[1024];
	if(!GetTrieString(Cvartrie, cvarstr, outstr, sizeof(outstr)))
	{
		ThrowError("Could not GET Cvar: cvarid %d",cvarid);
	}
	strcopy(returnstr, maxsize, outstr);
}

//native void War3_AddSound(char[] soundfile,int stocksound=0,int priority=PRIORITY_TAKE_FORWARD);
stock void Internal_War3_AddSound(char[] sSoundFile1, int stocksound=0,int priority=PRIORITY_TAKE_FORWARD)
{
	char sSoundFile[PLATFORM_MAX_PATH];
	strcopy(sSoundFile,sizeof(sSoundFile),sSoundFile1);
	if(FindStringInArray(g_hSoundFile, sSoundFile)==-1) // if not found, add
	{
		//PrintToServer("File adding/not found: %s | SIZE: %d",sSoundFile, GetArraySize(g_hSoundFile));
		PushArrayCell(g_hStockSound, stocksound);

		if(priority==PRIORITY_TAKE_FORWARD)
		{
			priority = Forward_Priority;
		}
		PushArrayCell(g_hPriority, priority);
		PushArrayString(g_hSoundFile, sSoundFile);

		/*
		if(numParams==4)
		{
			int iRaceID = GetNativeCell(4);
			PushArrayCell(g_hRaceIDSound, iRaceID);
		}
		else
		{
			PushArrayCell(g_hRaceIDSound, 0);
		}*/

	}
}

stock int GetPlayerProp(int client,W3PlayerProp property)
{
	if (client > 0 && client <= MaxClients)
	{
		return p_properties[client][property];
	}
	else
		return 0;
}

stock int Internal_War3_GetMaxHP(int client)
{
	//DP("add %d",W3GetBuffSumInt(client,iAdditionalMaxHealth));
	return GetPlayerProp(client, iMaxHP);//+ W3GetBuffSumInt(client,iAdditionalMaxHealth);
}
