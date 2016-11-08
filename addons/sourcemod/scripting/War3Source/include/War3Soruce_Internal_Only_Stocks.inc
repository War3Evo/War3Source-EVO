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
