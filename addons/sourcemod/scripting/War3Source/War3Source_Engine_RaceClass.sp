// War3Source_Engine_RaceClass.sp

//#assert GGAMEMODE == MODE_WAR3SOURCE

//#include "W3SIncs/forwards2"
/*
public Plugin:myinfo =
{
    name = "War3Source:EVO - Engine - Race Class",
    author = "War3Source:EVO Team",
    description = "Information about races"
};*/

/*  ** MOVED TO War3Source_Variables.inc
 *
new totalRacesLoaded=0;  ///USE raceid=1;raceid<=GetRacesLoaded();raceid++ for looping
///race instance variables
//RACE ID = index of [MAXRACES], raceid 1 is raceName[1][32]

new String:raceName[MAXRACES][32];
new String:raceShortname[MAXRACES][16];
new String:raceShortdesc[MAXRACES][32];
new bool:raceTranslated[MAXRACES];
new bool:ignoreRaceEnd; ///dont do anything on CreateRaceEnd cuz this its already done once

//zeroth skill is NOT  used
new raceSkillCount[MAXRACES];
new String:raceSkillName[MAXRACES][MAXSKILLCOUNT][32];
new String:raceSkillDescription[MAXRACES][MAXSKILLCOUNT][512];
new raceSkillDescReplaceNum[MAXRACES][MAXSKILLCOUNT];
new String:raceSkillDescReplace[MAXRACES][MAXSKILLCOUNT][5][64]; ///MAX 5 params for replacement //64 string length
new bool:skillTranslated[MAXRACES][MAXSKILLCOUNT];

//new String:raceString[MAXRACES][RaceString][512];  // not implemented or used anywhere
// not sure why this exists:
//new String:raceSkillString[MAXRACES][MAXSKILLCOUNT][SkillString][512];

enum SkillRedirect
{
	genericskillid,
}
new bool:SkillRedirected[MAXRACES][MAXSKILLCOUNT];
new SkillRedirectedToSkill[MAXRACES][MAXSKILLCOUNT];

new bool:skillIsUltimate[MAXRACES][MAXSKILLCOUNT];
new skillMaxLevel[MAXRACES][MAXSKILLCOUNT];
//new skillProp[MAXRACES][MAXSKILLCOUNT][W3SkillProp];        // not used anywhere

new MinLevelCvar[MAXRACES];
new AccessFlagCvar[MAXRACES];
new RaceOrderCvar[MAXRACES];
new RaceFlagsCvar[MAXRACES];
new RestrictItemsCvar[MAXRACES];
new RestrictLimitCvar[MAXRACES][2];

new Handle:m_MinimumUltimateLevel;

new bool:racecreationended=true;
new String:creatingraceshortname[16];

new raceCell[MAXRACES][ENUM_RaceObject];

new bool:ReloadRaces_Id[MAXRACES];
new ReloadRaces_Client_Race[MAXPLAYERSCUSTOM];
new String:ReloadRaces_Shortname[MAXRACES][16];
new String:ReloadRaces_longname[MAXRACES][32];*/

//END race instance variables


public War3Source_Engine_RaceClass_OnPluginStart()
{
//silence error
	//skillProp[0][0][0]=0; // not used anywhere
	m_MinimumUltimateLevel=CreateConVar("war3_minimumultimatelevel","10");
	//PrintToServer("W3E OnPluginStart Engine RaceClass");
	RegAdminCmd("getjoblist",Cmdjoblist,ADMFLAG_KICK);
	RegAdminCmd("war3_loadarace",Cmd_load_a_race,ADMFLAG_ROOT);
	RegAdminCmd("war3_crrloadraces",Cmdraceload,ADMFLAG_ROOT);

	RegAdminCmd("war3_assignrace",Cmdassignrace,ADMFLAG_ROOT);

}

new bool:load_a_race=false;

public Action:Cmd_load_a_race(client,args)
{
	if (args == 1)
	{
		decl String:arg[8];
		GetCmdArg(1, arg, sizeof(arg));
		new RaceIDNum = StringToInt(arg);

		if(RaceIDNum>0)
		{
			load_a_race = true;

			new res;

			Call_StartForward(g_OnWar3PluginReadyHandle2);
			Call_PushCell(RaceIDNum);
			Call_PushCell(-1);
			Call_PushString("");
			Call_Finish(res);

			load_a_race = false;
		}
	}
	else
	{
		War3_ChatMessage(client,"war3_loadarace <race id number>");
	}

	return Plugin_Handled;
}


public Action:Cmdraceload(client,args)
{
	new res;

	// Custom Race Load Races
	for(new i; i <= MAXRACES * 10; i++)
	{
		Call_StartForward(g_OnWar3PluginReadyHandle2);
		Call_PushCell(i);
		Call_PushCell(-1);
		Call_PushString("");
		Call_Finish(res);
	}

	return Plugin_Handled;
}

public Action:Cmdassignrace(client,args)
{
	if (args < 2)
	{
		ReplyToCommand(client, "[War3Source:EVO] Usage: war3_assignrace <#userid|name> <part of race name>");
		return Plugin_Handled;
	}

	decl String:arg[65];
	GetCmdArg(1, arg, sizeof(arg));

	decl String:arg2[32];
	GetCmdArg(2, arg2, sizeof(arg2));

	new RaceID=RaceNameSearch(arg2);

	if(RaceID<=0)
	{
		ReplyToCommand(client, "[War3Source:EVO] could not find race name.");
		return Plugin_Handled;
	}

	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;

	if ((target_count = ProcessTargetString(
			arg,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_CONNECTED,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	decl String:sClientName[128];
	decl String:sRaceName[32];
	GetRaceName(RaceID,sRaceName,sizeof(sRaceName));
	for (new i = 0; i < target_count; i++)
	{
		if(ValidPlayer(target_list[i]))
		{
			SetRace(target_list[i],RaceID);
			GetClientName(target_list[i],sClientName,sizeof(sClientName));
			War3_ChatMessage(client,"%s set to %s",sClientName,sRaceName);
		}
	}
	return Plugin_Handled;
}


public Action:Cmdjoblist(client,args){
	new RacesLoaded = internal_GetRacesLoaded();
	new String:LongRaceName[32];
	for(new x=1;x<=RacesLoaded;x++)
	{
		GetRaceName(x,LongRaceName,sizeof(LongRaceName));
		War3_ChatMessage(client,"JobList [Debug] Job: %s Job ID: %i",LongRaceName,x);
	}
	return Plugin_Handled;
}


public bool War3Source_Engine_RaceClass_InitNatives()
{
	//War3Source_InitForwards2();

	// Reloading Races does not seem to work for translated races.
	CreateNative("War3_RaceOnPluginStart",NWar3_RaceOnPluginStart);
	CreateNative("War3_RaceOnPluginEnd",NWar3_RaceOnPluginEnd);
	CreateNative("War3_IsRaceReloading",NWar3_IsRaceReloading);

	CreateNative("War3_CreateNewRace",NWar3_CreateNewRace);
	CreateNative("War3_AddRaceSkill",NWar3_AddRaceSkill);

	CreateNative("War3_CreateNewRaceT",NWar3_CreateNewRaceT);

	// NO LONGER USED:  PROBABLY SHOULD REMOVE OR COMMENT OUT
	CreateNative("War3_AddRaceSkillT",NWar3_AddRaceSkillT);

	//CreateNative("War3_CreateGenericSkill",NWar3_CreateGenericSkill);
	//CreateNative("War3_UseGenericSkill",NWar3_UseGenericSkill);
	//CreateNative("W3_GenericSkillLevel",NW3_GenericSkillLevel);

	CreateNative("War3_CreateRaceEnd",NWar3_CreateRaceEnd);




	CreateNative("War3_GetRaceName",Native_War3_GetRaceName);
	CreateNative("War3_GetRaceShortname",Native_War3_GetRaceShortname);
	CreateNative("War3_GetRaceShortdesc",Native_War3_GetRaceShortdesc);
	//CreateNative("W3GetRaceString",NW3GetRaceString);  // not implemented


	CreateNative("War3_GetRaceIDByShortname",NWar3_GetRaceIDByShortname);
	CreateNative("War3_GetRacesLoaded",NWar3_GetRacesLoaded);
	CreateNative("W3GetRaceMaxLevel",NW3GetRaceMaxLevel);

	CreateNative("War3_GetRaceSkillCount",NWar3_GetRaceSkillCount);
	CreateNative("War3_IsSkillUltimate",NWar3_IsSkillUltimate);
	CreateNative("W3GetRaceSkillName",NW3GetRaceSkillName);
	CreateNative("W3GetRaceSkillDesc",NW3GetRaceSkillDesc);

	CreateNative("W3GetRaceOrder",NW3GetRaceOrder);
	CreateNative("W3RaceHasFlag",NW3RaceHasFlag);

	CreateNative("W3GetRaceAccessFlagStr",NW3GetRaceAccessFlagStr);
	CreateNative("W3GetRaceItemRestrictionsStr",NW3GetRaceItemRestrictionsStr);
	CreateNative("W3GetRaceMinLevelRequired",NW3GetRaceMinLevelRequired);
	CreateNative("W3GetRaceMaxLimitTeam",NW3GetRaceMaxLimitTeam);
	CreateNative("W3GetRaceMaxLimitTeamCvar",NW3GetRaceMaxLimitTeamCvar);
	CreateNative("W3GetRaceSkillMaxLevel",NW3GetRaceSkillMaxLevel);

	CreateNative("W3GetRaceList",NW3GetRaceList);

	CreateNative("W3GetMinUltLevel",NW3GetMinUltLevel);

	CreateNative("W3IsRaceTranslated",NW3IsRaceTranslated);

	CreateNative("W3GetRaceCell",NW3GetRaceCell);
	CreateNative("W3SetRaceCell",NW3SetRaceCell);

	RegPluginLibrary("RaceClass");

	return true;
}


public NWar3_IsRaceReloading(Handle:plugin,numParams){

	return Internal_NWar3_IsRaceReloading()==1?true:false;
}

Internal_NWar3_IsRaceReloading()
{
	new RacesLoaded = internal_GetRacesLoaded();
	new bool:findtherace=false;
	for(new x=1;x<=RacesLoaded;x++)
	{
		// ReloadRaces_Shortname[x]==
		if(ReloadRaces_Id[x]==true)
			{
				//PrintToServer("NWar3_IsRaceReloading shortname %s Job %i id",ReloadRaces_Shortname[x],x);
				findtherace=true;
				break;
			}
	}
	return findtherace?1:0;
}


public NWar3_RaceOnPluginEnd(Handle:plugin,numParams){

	new String:shortname[16];
	GetNativeString(1,shortname,sizeof(shortname));
	if(StrEqual(shortname,"",false))
		return;

	new RaceOnPluginEndID=size16_GetRaceIDByShortname(shortname);

	//PrintToServer("STARTED:NWar3_RaceOnPluginEnd raceid %i racename %s",RaceOnPluginEndID,shortname);

	if(RaceOnPluginEndID>0)
	{
		new String:LongRaceName[32];
		GetRaceName(RaceOnPluginEndID,LongRaceName,sizeof(LongRaceName));

		for(new i=1;i<MaxClients;i++){
			if(ValidPlayer(i))
			{
				if(GetRace(i)==RaceOnPluginEndID)
				{
					ReloadRaces_Client_Race[i]=RaceOnPluginEndID;
					PrintCenterText(i,"%s is being reloaded!",LongRaceName);
					W3Hint(i,HINT_NORMAL,5.0,"%s is being reloaded!",LongRaceName);
				}
			}
		}


		ReloadRaces_Id[RaceOnPluginEndID]=true;

		strcopy(ReloadRaces_longname[RaceOnPluginEndID], 32, raceName[RaceOnPluginEndID]);
		strcopy(ReloadRaces_Shortname[RaceOnPluginEndID], 16, raceShortname[RaceOnPluginEndID]);

		strcopy(raceName[RaceOnPluginEndID], 32, "");
		strcopy(raceShortname[RaceOnPluginEndID], 16, "");
		// erase races skill info here
		for(new i=0;i<MAXSKILLCOUNT;i++){
			//PrintToServer("STARTED:NWar3_RaceOnPluginEnd i= %i",i);
			strcopy(raceSkillName[RaceOnPluginEndID][i], 32, "");
			strcopy(raceSkillDescription[RaceOnPluginEndID][i], 512, "");
			skillIsUltimate[RaceOnPluginEndID][i]=false;
			skillMaxLevel[RaceOnPluginEndID][i]=0;
			raceSkillDescReplaceNum[RaceOnPluginEndID][i]=0;
			skillTranslated[RaceOnPluginEndID][i]=false;
			//raceSkillString[RaceOnPluginEndID][i][SkillString][512]; //not used
			SkillRedirected[RaceOnPluginEndID][i]=false;
			SkillRedirectedToSkill[RaceOnPluginEndID][i]=0;
			skillIsUltimate[RaceOnPluginEndID][i]=false;
			//skillProp[RaceOnPluginEndID][i][W3SkillProp]; //not used

			// may ened to increase 4 to 5??
			for(new arg=0;arg<4;arg++){
				strcopy(raceSkillDescReplace[RaceOnPluginEndID][i][arg], 64, "");
			}
		}

		if(LibraryExists("RaceDependency"))
		{
			War3_RemoveDependency(RaceOnPluginEndID,raceSkillCount[RaceOnPluginEndID]);
			War3_RemoveRaceDependency(RaceOnPluginEndID);
		}
		raceSkillCount[RaceOnPluginEndID]=0;

		//W3Log("add race %s %s",name,shortname);
		//PrintToServer("ENDED:NWar3_RaceOnPluginEnd raceid %i racename %s",RaceOnPluginEndID,shortname);

		for(new i=1;i<MaxClients;i++){
			if(ValidPlayer(i))
			{
				if(ReloadRaces_Client_Race[i]==RaceOnPluginEndID)
				{
					SetRace(i,0);
					PrintToServer("[Race Loading] Client %i SetRace to 0",i);
				}
			}
		}

		CreateBotList();
	}
}

// TO: try to get reloading races to work with translated races.
public NWar3_RaceOnPluginStart(Handle:plugin,numParams){

	new String:shortname[16];
	GetNativeString(1,shortname,sizeof(shortname));
	if(!StrEqual(shortname,"",false))
	{
		new RacesLoaded = internal_GetRacesLoaded();
		new x;
		new bool:findtherace=false;
		for(x=1;x<=RacesLoaded;x++)
		{
			// ReloadRaces_Shortname[x]==
			if(StrEqual(shortname,ReloadRaces_Shortname[x],false))
				{
					//PrintToServer("Reloading shortname %s Job %i id",ReloadRaces_Shortname[x],x);
					findtherace=true;
					break;
				}
		}
		// x = raceid
		new res;

		if(!findtherace)
			return false;

		//racecreationended=true;
		//ignoreRaceEnd=false;

		// Important (erase skill count):
		raceSkillCount[x]=0;

		for(new i=0;i<MAXSKILLCOUNT;i++){
			//PrintToServer("STARTED:NWar3_RaceOnPluginStart i= %i",i);
			raceSkillDescReplaceNum[x][i]=0;
		}

		Call_StartForward(g_OnWar3PluginReadyHandle2);
		Call_PushCell(-1);
		Call_PushCell(x);
		Call_PushString(shortname);
		Call_Finish(res);

		//PrintToServer("NWar3_RaceOnPluginStart raceid %i racename %s",x,shortname);

		CreateBotList();

	}
	//W3Log("add race %s %s",name,shortname);

	return true;
}

Race_Finished_Reload(raceid)
{
	new String:LongRaceName[32];
	GetRaceName(raceid,LongRaceName,sizeof(LongRaceName));

	PrintToChatAll("%s has been updated!",LongRaceName);

	for(new i=1;i<MaxClients;i++){
		if(ValidPlayer(i))
		{
			if(ReloadRaces_Client_Race[i]==raceid)
			{
				PrintCenterText(i,"%s has been updated.",LongRaceName);
				W3Hint(i,HINT_NORMAL,5.0,"%s has been updated.",LongRaceName);
				SetRace(i,raceid);
				ReloadRaces_Client_Race[i]=0;
				PrintToServer("[Race Reloaded] Client %i SetRace to %i",i,raceid);
				War3_ChatMessage(i,"[Race Reloaded] Client %i SetRace to %i",i,raceid);
			}
		}
	}
}

public NWar3_CreateNewRace(Handle:plugin,numParams){


	decl String:name[64],String:shortname[16],String:shortdesc[32];
	GetNativeString(1,name,sizeof(name));
	GetNativeString(2,shortname,sizeof(shortname));
	int ReloadRaceId_info=GetNativeCell(3);
	GetNativeString(4,shortdesc,sizeof(shortdesc));

	//W3Log("add race %s %s",name,shortname);

	return CreateNewRace(name,shortname,shortdesc,ReloadRaceId_info);

}


public NWar3_AddRaceSkill(Handle:plugin,numParams){



	new raceid=GetNativeCell(1);
	if(raceid>0){
		new String:skillname[32];
		new String:skilldesc[2001];
		GetNativeString(2,skillname,sizeof(skillname));
		GetNativeString(3,skilldesc,sizeof(skilldesc));
		new bool:isult=GetNativeCell(4);
		new tmaxskilllevel=GetNativeCell(5);

		//W3Log("add skill %s %s",skillname,skilldesc);

		return AddRaceSkill(raceid,skillname,skilldesc,isult,tmaxskilllevel);
	}
	return 0;
}

//translated
public NWar3_CreateNewRaceT(Handle:plugin,numParams)
{
	char name[64],shortname[16],shortdesc[32];
	GetNativeString(1,shortname,sizeof(shortname));
	int ReloadRaceId_info=GetNativeCell(2);
	GetNativeString(3,shortdesc,sizeof(shortdesc));

	int newraceid=CreateNewRace(name,shortname,shortdesc,ReloadRaceId_info);
	if(newraceid>0)
	{
		raceTranslated[newraceid]=true;
		char buf[64];
		Format(buf,sizeof(buf),"w3s.race.%s.phrases",shortname);
		LoadTranslations(buf);
		PrintToServer(buf);
	}
	return newraceid;

}
//translated
public NWar3_AddRaceSkillT(Handle:plugin,numParams){


	new raceid=GetNativeCell(1);
	if(raceid>0)
	{
		new String:skillname[32];
		new String:skilldesc[1]; //DUMMY
		GetNativeString(2,skillname,sizeof(skillname));
		new bool:isult=GetNativeCell(3);
		new tmaxskilllevel=GetNativeCell(4);


		//W3Log("add skill T %d %s",raceid,skillname);

		new newskillnum=AddRaceSkill(raceid,skillname,skilldesc,isult,tmaxskilllevel);
		skillTranslated[raceid][newskillnum]=true;

		if(ignoreRaceEnd==false){
			for(new arg=5;arg<=numParams;arg++){

				GetNativeString(arg,raceSkillDescReplace[raceid][newskillnum][raceSkillDescReplaceNum[raceid][newskillnum]],64);
				raceSkillDescReplaceNum[raceid][newskillnum]++;
			}
		}

		return newskillnum;
	}
	return 0;//failed
}

public NWar3_CreateRaceEnd(Handle:plugin,numParams){
	//W3Log("race end %d",GetNativeCell(1));
	CreateRaceEnd(GetNativeCell(1));
}
///this is get raceid, not NAME!
public Native_War3_GetRaceByShortname(Handle:plugin,numParams)
{
	new String:short_lookup[16];
	GetNativeString(1,short_lookup,sizeof(short_lookup));
	new RacesLoaded = internal_GetRacesLoaded();
	for(new x=1;x<=RacesLoaded;x++)
	{

		new String:short_name[16];
		GetRaceShortname(x,short_name,sizeof(short_name));
		if(StrEqual(short_name,short_lookup,false))
		{
			return x;
		}
	}
	return 0;
}
public Native_War3_GetRaceName(Handle:plugin,numParams)
{
	new race=GetNativeCell(1);
	new bufsize=GetNativeCell(3);
	if(race>-1 && race<=internal_GetRacesLoaded()) //allow "No Race"
	{
		new String:race_name[32];
		GetRaceName(race,race_name,sizeof(race_name));
		SetNativeString(2,race_name,bufsize);
	}
}
public Native_War3_GetRaceShortname(Handle:plugin,numParams)
{
	new race=GetNativeCell(1);
	new bufsize=GetNativeCell(3);
	if(race>=1 && race<=internal_GetRacesLoaded())
	{
		new String:race_shortname[16];
		GetRaceShortname(race,race_shortname,sizeof(race_shortname));
		SetNativeString(2,race_shortname,bufsize);
	}
}
GetRaceShortdesc(raceid,String:retstr[],maxlen){
	new num=strcopy(retstr, maxlen, raceShortdesc[raceid]);
	return num;
}
public Native_War3_GetRaceShortdesc(Handle:plugin,numParams)
{
	new race=GetNativeCell(1);
	new bufsize=GetNativeCell(3);
	if(race>=1 && race<=internal_GetRacesLoaded())
	{
		new String:race_shortdesc[32];
		GetRaceShortdesc(race,race_shortdesc,sizeof(race_shortdesc));
		SetNativeString(2,race_shortdesc,bufsize);
	}
}
public NWar3_GetRacesLoaded(Handle:plugin,numParams)
{
	return GetRacesLoaded();
}

public NW3GetRaceMaxLevel(Handle:plugin,numParams)
{
	return GetRaceMaxLevel(GetNativeCell(1));
}


public NWar3_GetRaceSkillCount(Handle:plugin,numParams)
{
	return GetRaceSkillCount(GetNativeCell(1));
}
public NWar3_IsSkillUltimate(Handle:plugin,numParams)
{
	return IsSkillUltimate(GetNativeCell(1),GetNativeCell(2));
}


/*  not implemented / not used anywhere
public NW3GetRaceString(Handle:plugin,numParams)
{
	new race=GetNativeCell(1);
	new RaceString:racestringid=GetNativeCell(2);

	new String:longbuf[1000];
	Format(longbuf,sizeof(longbuf),raceString[race][RaceString:racestringid]);
	SetNativeString(3,longbuf,GetNativeCell(4));
} */

/*
public NW3GetRaceSkillString(Handle:plugin,numParams)
{
	new race=GetNativeCell(1);
	new skill=GetNativeCell(2);
	new SkillString:raceskillstringid=GetNativeCell(3);


	new String:longbuf[1000];
	Format(longbuf,sizeof(longbuf),raceSkillString[race][skill][raceskillstringid]);
	SetNativeString(4,longbuf,GetNativeCell(5));
}
*/
public NW3GetRaceSkillName(Handle:plugin,numParams)
{
	new race=GetNativeCell(1);
	new skill=GetNativeCell(2);
	new maxlen=GetNativeCell(4);

	if(race<1||race>internal_GetRacesLoaded()){
		ThrowNativeError(1,"bad race %d",race);
	}
	if(skill<1||skill>GetRaceSkillCount(race)){
		ThrowNativeError(1,"bad skillid %d",skill);
	}
	new String:buf[32];
	GetRaceSkillName(race,skill,buf,sizeof(buf));
	SetNativeString(3,buf,maxlen);
}
public NW3GetRaceSkillDesc(Handle:plugin,numParams)
{
	new race=GetNativeCell(1);
	new skill=GetNativeCell(2);
	new maxlen=GetNativeCell(4);

	new String:longbuf[1000];
	GetRaceSkillDesc(race,skill,longbuf,sizeof(longbuf));
	SetNativeString(3,longbuf,maxlen);
}
public NWar3_GetRaceIDByShortname(Handle:plugin,numParams)
{
	new String:shortname[16];
	GetNativeString(1,shortname,sizeof(shortname));
	return size16_GetRaceIDByShortname(shortname);
}
stock void GetRaceAccessFlagStr(int raceid, char[] returnstr, int maxsize)
{
	char buf[32];
	GetCvar(AccessFlagCvar[raceid],buf,sizeof(buf));
	StrCopy(returnstr, maxsize, buf);
}
public NW3GetRaceAccessFlagStr(Handle:plugin,numParams)
{
	int raceid=GetNativeCell(1);
	char buf[32];
	GetRaceAccessFlagStr(raceid, buf, GetNativeCell(3));

	SetNativeString(2,buf,GetNativeCell(3));
}
public NW3GetRaceOrder(Handle:plugin,numParams)
{
	new raceid=GetNativeCell(1);
	//DP("getraceorder race %d cvar %d",raceid,RaceOrderCvar[raceid]);
	return W3GetCvarInt(RaceOrderCvar[raceid]);

}
stock bool RaceHasFlag(int raceid, char flagsearch[32])
{
	char buf[1000];
	GetCVar(RaceFlagsCvar[raceid],buf,sizeof(buf));

	return (StrContains(buf,flagsearch)>-1);
}
public NW3RaceHasFlag(Handle:plugin,numParams)
{
	int raceid=GetNativeCell(1);
	char buf[1000];
	W3GetCvar(RaceFlagsCvar[raceid],buf,sizeof(buf));

	char flagsearch[32];
	GetNativeString(2,flagsearch,sizeof(flagsearch));
	return RaceHasFlag(raceid,flagsearch);
}
public NW3GetRaceList(Handle:plugin,numParams){

	new listcount=0;
	new RacesLoaded = internal_GetRacesLoaded();
	new Handle:hdynamicarray=CreateArray(1); //1 cell

	for(new raceid=1;raceid<=RacesLoaded;raceid++){

		if(!W3RaceHasFlag(raceid,"hidden")){
		//	DP("not hidden %d",raceid);
			PushArrayCell(hdynamicarray, raceid);
			listcount++;
		}
		else{
		//	DP("hidden %d",raceid);
		}
	}
	new racelist[MAXRACES];
	new Handle:result=MergeSort(hdynamicarray); //closes hdynamicarray
	for(new i=0;i<listcount;i++){
		racelist[i]=GetArrayCell(result, i);
	}
	//printArray("",result);
	//PrintToServer("result array size %d/%d", GetArraySize(result),War3_GetRacesLoaded());
	CloseHandle(result);

	SetNativeArray(1, racelist, MAXRACES);
	return listcount;
}
public NW3GetRaceItemRestrictionsStr(Handle:plugin,numParams)
{

	new raceid=GetNativeCell(1);
	new String:buf[64];
	W3GetCvar(RestrictItemsCvar[raceid],buf,sizeof(buf));
	SetNativeString(2,buf,GetNativeCell(3));
}

stock int GetRaceMaxLimitTeam(int raceid, int team)
{
	if(raceid>0)
	{
		if(team==TEAM_T||team==TEAM_RED)
		{
			return internal_W3GetCvarInt(RestrictLimitCvar[raceid][0]);
		}
		if(team==TEAM_CT||team==TEAM_BLUE)
		{
			return internal_W3GetCvarInt(RestrictLimitCvar[raceid][1]);
		}
	}
	return 99;

}
public NW3GetRaceMaxLimitTeam(Handle:plugin,numParams)
{
	int raceid=GetNativeCell(1);
	int team=GetNativeCell(2);
	return GetRaceMaxLimitTeam(raceid,team);
}
public NW3GetRaceMaxLimitTeamCvar(Handle:plugin,numParams)
{
	new raceid=GetNativeCell(1);
	if(raceid>0){

		new team=GetNativeCell(2);
		if(team==TEAM_T||team==TEAM_RED){
			return RestrictLimitCvar[raceid][0];
		}
		if(team==TEAM_CT||team==TEAM_BLUE){
			return RestrictLimitCvar[raceid][1];
		}
	}
	return -1;
}
public NW3GetRaceMinLevelRequired(Handle:plugin,numParams){
	return W3GetCvarInt(MinLevelCvar[GetNativeCell(1)]);
}
public NW3GetRaceSkillMaxLevel(Handle:plugin,numParams){
	return GetRaceSkillMaxLevel(GetNativeCell(1),GetNativeCell(2));
}
public NW3GetMinUltLevel(Handle:plugin,numParams){
	return GetConVarInt(m_MinimumUltimateLevel);
}
public NW3IsRaceTranslated(Handle:plugin,numParams){
	return raceTranslated[GetNativeCell(1)];
}
public NW3SetRaceCell(Handle:plugin,numParams){
	return raceCell[GetNativeCell(1)][GetNativeCell(2)]=GetNativeCell(3);
}
public NW3GetRaceCell(Handle:plugin,numParams){
	return raceCell[GetNativeCell(1)][GetNativeCell(2)];
}









new genericskillcount=0;

//how many skills can use a generic skill, limited for memory
#define MAXCUSTOMERRACES 32
enum GenericSkillClass
{
	String:cskillname[32],
	redirectedfromrace[MAXCUSTOMERRACES], //theset start from 0!!!!
	redirectedfromskill[MAXCUSTOMERRACES],
	redirectedcount, //how many races are using this generic skill, first is 1, loop from 1 to <=redirected count
	Handle:raceskilldatahandle[MAXCUSTOMERRACES], //handle the customer races passed us
}
//55 generic skills
/*
new GenericSkill[55][GenericSkillClass];
public NWar3_CreateGenericSkill(Handle:plugin,numParams){
	new String:tempgenskillname[32];
	GetNativeString(1,tempgenskillname,32);

	//find existing
	for(new i=1;i<=genericskillcount;i++){

		if(StrEqual(tempgenskillname,GenericSkill[i][cskillname])){
			return i;
		}
	}

	//no existing found, add
	genericskillcount++;
	GetNativeString(1,GenericSkill[genericskillcount][cskillname],32);
	return genericskillcount;
}
public NWar3_UseGenericSkill(Handle:plugin,numParams){
	new raceid=GetNativeCell(1);
	new String:genskillname[32];
	GetNativeString(2,genskillname,sizeof(genskillname));
	new Handle:genericSkillData=Handle:GetNativeCell(3);
	//start from 1
	for(new i=1;i<=genericskillcount;i++){
		DP("1 %s %s ]",genskillname,GenericSkill[i][cskillname]);
		if(StrEqual(genskillname,GenericSkill[i][cskillname])){
			DP("2");
			if(raceid>0){



				DP("3");
				new String:raceskillname[2001];
				new String:raceskilldesc[2001];
				GetNativeString(4,raceskillname,sizeof(raceskillname));
				GetNativeString(5,raceskilldesc,sizeof(raceskilldesc));

				new bool:istranaslated=GetNativeCell(6);

				//native War3_UseGenericSkill(raceid,String:gskillname[],Handle:genericSkillData,String:yourskillname[],String:untranslatedSkillDescription[],bool:translated=false,bool:isUltimate=false,maxskilllevel=DEF_MAX_SKILL_LEVEL,any:...);

				new bool:isult=GetNativeCell(7);
				new tmaxskilllevel=GetNativeCell(8);

				//W3Log("add skill %s %s",skillname,skilldesc);

				new newskillnum;
				newskillnum	= AddRaceSkill(raceid,raceskillname,raceskilldesc,isult,tmaxskilllevel);
				if(istranaslated){
					skillTranslated[raceid][newskillnum]=true;
				}

				//check that the data handle isnt leaking
				new genericcustomernumber=GenericSkill[i][redirectedcount];
				for(new j=0;j<=genericcustomernumber;j++){
					if(
					GenericSkill[i][redirectedfromrace][j]==raceid
					&&
					GenericSkill[i][redirectedfromskill][j]==newskillnum
					){
						if(GenericSkill[i][raceskilldatahandle][j]!=INVALID_HANDLE && GenericSkill[i][raceskilldatahandle][j] !=genericSkillData){
							//DP("ERROR POSSIBLE HANDLE LEAK, NEW GENERIC SKILL DATA HANDLE PASSED, CLOSING OLD GENERIC DATA HANDLE");
							CloseHandle(GenericSkill[i][raceskilldatahandle][j]);
							GenericSkill[i][raceskilldatahandle][j]=genericSkillData;
						}
					}

				}


				//first time creating the race
				if(ignoreRaceEnd==false)
				{
					//variable args start at 8
					for(new arg=9;arg<=numParams;arg++){

						GetNativeString(arg,raceSkillDescReplace[raceid][newskillnum][raceSkillDescReplaceNum[raceid][newskillnum]],64);
						raceSkillDescReplaceNum[raceid][newskillnum]++;
					}

					SkillRedirected[raceid][newskillnum]=true;
					SkillRedirectedToSkill[raceid][newskillnum]=i;


					GenericSkill[i][raceskilldatahandle][genericcustomernumber]=genericSkillData;
					GenericSkill[i][redirectedfromrace][GenericSkill[i][redirectedcount]]=raceid;

					GenericSkill[i][redirectedfromskill][GenericSkill[i][redirectedcount]]=newskillnum;
					GenericSkill[i][redirectedcount]++;
					//DP("FOUND GENERIC SKILL %d, real skill id for race %d",i,newskillnum);
				}

				return newskillnum;

			}
		}
	}
	W3LogError("NO GENERIC SKILL FOUND");
	return 0;
}
public NW3_GenericSkillLevel(Handle:plugin,numParams){

	new client=GetNativeCell(1);
	new genericskill=GetNativeCell(2);
	new count=GenericSkill[genericskill][redirectedcount];
	new found=0;
	new level=0;
	new reallevel=0;
	new customernumber=0;
	new clientrace=GetRace(client);
	//DP("customer count %d genericskill %d",count,genericskill);
	for(new i=0;i<count;i++){
		if(clientrace==GenericSkill[genericskill][redirectedfromrace][i]){
			level = War3_GetSkillLevel( client, GenericSkill[genericskill][redirectedfromrace][i], GenericSkill[genericskill][redirectedfromskill][i]);
			//DP("real skill %d %d %d",GenericSkill[genericskill][redirectedfromrace][i], GenericSkill[genericskill][redirectedfromskill][i],level);
			if(level){
				found++;
				reallevel=level;
				customernumber=i;
			}
		}
	}
	if(found>1){
		W3LogError("ERR FOUND MORE THAN 1 GERNIC SKILL MATCH");
		return 0;
	}
	if(found){
		SetNativeCellRef(3,GenericSkill[genericskill][raceskilldatahandle][customernumber]);
		if(numParams>=4){
			SetNativeCellRef(4, GenericSkill[genericskill][redirectedfromrace][customernumber]);
		}
		if(numParams>=5){
			SetNativeCellRef(5, GenericSkill[genericskill][redirectedfromskill][customernumber]);
		}
	}
	return reallevel;

}
*/




































CreateNewRace(String:tracename[],String:traceshortname[],String:traceshortdesc[],TheReloadRaceId){

	if(RaceExistsByShortname(traceshortname)&&TheReloadRaceId<=0){
		new oldraceid=size16_GetRaceIDByShortname(traceshortname);
		PrintToServer("Race already exists: %s, returning old raceid %d",traceshortname,oldraceid);
		ignoreRaceEnd=true;
		return oldraceid;
	}

	if(totalRacesLoaded+1==MAXRACES&&TheReloadRaceId<=0){ //make sure we didnt reach our race capacity limit
		LogError("MAX RACES REACHED, CANNOT REGISTER %s %s",tracename,traceshortname);
		return 0;
	}

	if(racecreationended==false){
		new String:error[512];
		Format(error,sizeof(error),"CreateNewRace was called before previous race creation was ended!!! first race not ended: %s second race: %s ",creatingraceshortname,traceshortname);
		SetFailState(error);
		//War3Failed(error);
	}

	racecreationended=false;
	Format(creatingraceshortname,sizeof(creatingraceshortname),"%s",traceshortname);

	//first race registering, fill in the  zeroth race along
	if(totalRacesLoaded==0){
		for(new i=0;i<MAXSKILLCOUNT;i++){
			Format(raceSkillName[totalRacesLoaded][i],31,"ZEROTH RACE SKILL");
			Format(raceSkillDescription[totalRacesLoaded][i],2000,"ZEROTH RACE SKILL DESCRIPTION");

		}
		Format(raceName[totalRacesLoaded],31,"No Race");
	}


	new traceid;
	if(TheReloadRaceId>0)
	{
		traceid=TheReloadRaceId;
		strcopy(raceName[traceid], 31, tracename);
		strcopy(raceShortname[traceid], 16, traceshortname);
		strcopy(raceShortdesc[traceid], 255, traceshortdesc);

		//make all skills zero so we can easily debug
		for(new i=0;i<MAXSKILLCOUNT;i++){
			Format(raceSkillName[traceid][i],31,"NO SKILL DEFINED %d",i);
			Format(raceSkillDescription[traceid][i],2000,"NO SKILL DESCRIPTION DEFINED %d",i);
		}
	}
	else
	{
		totalRacesLoaded++;
		traceid=totalRacesLoaded;
		strcopy(raceName[traceid], 31, tracename);
		strcopy(raceShortname[traceid], 16, traceshortname);
		strcopy(raceShortdesc[traceid], 255, traceshortdesc);

		//make all skills zero so we can easily debug
		for(new i=0;i<MAXSKILLCOUNT;i++){
			Format(raceSkillName[traceid][i],31,"NO SKILL DEFINED %d",i);
			Format(raceSkillDescription[traceid][i],2000,"NO SKILL DESCRIPTION DEFINED %d",i);
		}
	}

	if(load_a_race)
	{
		War3_ChatMessage(0,"Race Now Loading %s %s ID: %d",tracename,traceshortname,TheReloadRaceId);
	}

	return traceid; //this will be the new race's id / index
}







////we add skill or ultimate here, but we have to define if its a skill or ultimate we are adding
AddRaceSkill(raceid,String:skillname[],String:skilldescription[],bool:isUltimate,tmaxskilllevel){
	if(raceid>0){
		//ok is it an existing skill?
		//new String:existingskillname[64];
		new SkillCount = GetRaceSkillCount(raceid);
		for(new i=1;i<=SkillCount;i++){
			//GetRaceSkillName(raceid,i,existingskillname,sizeof(existingskillname));
			if(StrEqual(skillname,raceSkillName[raceid][i],false)){ ////need raw skill name, because of translations
				PrintToServer("Skill exists %s, returning old skillid %d",skillname,i);

				return i;
			}
		}
		//if(ignoreRaceEnd){
		//	W3Log("%s skill not found, REadding for race %d",skillname,raceid);
		//}

		//not existing, will it exceeded maximum?
		if(raceSkillCount[raceid]+1==MAXSKILLCOUNT){
			LogError("SKILL LIMIT FOR RACE %d reached!",raceid);
			return -1;
		}


		raceSkillCount[raceid]++;

		strcopy(raceSkillName[raceid][raceSkillCount[raceid]], 32, skillname);
		//PrintToServer("AddRaceSkill: Skill %s skillid %d",skillname,raceSkillCount[raceid]);

		if(ReloadRaces_Id[raceid]==true)
		{
			new String:LongRaceName[32];
			GetRaceName(raceid,LongRaceName,sizeof(LongRaceName));
			PrintToServer("Reloading %s: AddRaceSkill: Skill %s skillid %d",LongRaceName,skillname,raceSkillCount[raceid]);

			for(new i=0;i<MaxClients;i++){    // was MAXPLAYERSCUSTOM
				if(GetRace(i)==raceid)
					{
						PrintToConsole(i,"Reloading %s: AddRaceSkill: Skill %s skillid %d",LongRaceName,skillname,raceSkillCount[raceid]);
					}
			}
		}


		strcopy(raceSkillDescription[raceid][raceSkillCount[raceid]], 2000, skilldescription);
		skillIsUltimate[raceid][raceSkillCount[raceid]]=isUltimate;

		skillMaxLevel[raceid][raceSkillCount[raceid]]=tmaxskilllevel;

		//We remove all dependencys(atm there aren't any but we need to call this to apply our default value)
		War3_RemoveDependency(raceid,raceSkillCount[raceid]);

		if(load_a_race)
		{
			War3_ChatMessage(0,"Loading... Race ID: %d Skill: %s",raceid,skillname);
		}

		return raceSkillCount[raceid]; //return their actual skill number

	}
	return 0;
}


CreateRaceEnd(raceid){
	if(raceid>0){
		racecreationended=true;
		Format(creatingraceshortname,sizeof(creatingraceshortname),"");
		///now we put shit into the database and create cvars
		if(!ignoreRaceEnd&&raceid>0 && ReloadRaces_Id[raceid]==false)  // Dont let reload races over write these variables.
		{
			new String:shortname[16];
			GetRaceShortname(raceid,shortname,sizeof(shortname));

			new String:cvarstr[64];
			Format(cvarstr,sizeof(cvarstr),"%s_minlevel",shortname);
			MinLevelCvar[raceid]=W3CreateCvar(cvarstr,"0","Minimum level for race",Internal_NWar3_IsRaceReloading());

			Format(cvarstr,sizeof(cvarstr),"%s_accessflag",shortname);
			AccessFlagCvar[raceid]=W3CreateCvar(cvarstr,"0","Admin access flag required for race",Internal_NWar3_IsRaceReloading());

			Format(cvarstr,sizeof(cvarstr),"%s_raceorder",shortname);
			new String:buf[16];
			Format(buf,sizeof(buf),"%d",raceid*100);
			RaceOrderCvar[raceid]=W3CreateCvar(cvarstr,buf,"This race's Race Order on changerace menu",Internal_NWar3_IsRaceReloading());

			Format(cvarstr,sizeof(cvarstr),"%s_flags",shortname);
			RaceFlagsCvar[raceid]=W3CreateCvar(cvarstr,"","This race's flags, ie 'hidden,etc",Internal_NWar3_IsRaceReloading());

			Format(cvarstr,sizeof(cvarstr),"%s_restrict_items",shortname);
			RestrictItemsCvar[raceid]=W3CreateCvar(cvarstr,"","Which items to restrict for people on this race. Separate by comma, ie 'claw,orb'",Internal_NWar3_IsRaceReloading());

			Format(cvarstr,sizeof(cvarstr),"%s_team%d_limit",shortname,1);
			RestrictLimitCvar[raceid][0]=W3CreateCvar(cvarstr,"99","How many people can play this race on team 1 (RED/T)",Internal_NWar3_IsRaceReloading());
			Format(cvarstr,sizeof(cvarstr),"%s_team%d_limit",shortname,2);
			RestrictLimitCvar[raceid][1]=W3CreateCvar(cvarstr,"99","How many people can play this race on team 2 (BLU/CT)",Internal_NWar3_IsRaceReloading());

			new temp;
			Format(cvarstr,sizeof(cvarstr),"%s_restrictclass",shortname);
			temp=W3CreateCvar(cvarstr,"","Which classes are not allowed to play this race? Separate by comma. MAXIMUM OF 2!! list: scout,sniper,soldier,demoman,medic,heavy,pyro,spy,engineer",Internal_NWar3_IsRaceReloading());
			W3SetRaceCell(raceid,ClassRestrictionCvar,temp);

			Format(cvarstr,sizeof(cvarstr),"%s_category",shortname);
			W3SetRaceCell(raceid,RaceCategorieCvar,W3CreateCvar(cvarstr,"default","Determines in which Category the race should be displayed(if cats are active)",Internal_NWar3_IsRaceReloading()));

			if(load_a_race)
			{
				War3_ChatMessage(0,"Race Finished Loading: Race ID: %d %s",raceid,shortname);
			}
		}
		if(ReloadRaces_Id[raceid]==true)
		{
			Race_Finished_Reload(raceid);
		}
		ReloadRaces_Id[raceid]=false;
		strcopy(ReloadRaces_longname[raceid], 32, "");
		strcopy(ReloadRaces_Shortname[raceid], 16, "");
		ignoreRaceEnd=false;
	}
}




Handle:MergeSort(Handle:array){

	new len=GetArraySize(array);
	if(len==1){
		return array;
	}
	new cut=len/2;

	new Handle:smallerarrayleft=CreateArray(1,cut);
	new Handle:smallerarrayright=CreateArray(1,len-cut);

	for(new i=0;i<cut;i++){
		SetArrayCell(smallerarrayleft, i, GetArrayCell(array, i));

	}
	for(new i=cut;i<len;i++){
		SetArrayCell(smallerarrayright, i-cut, GetArrayCell(array, i ));

	}
	CloseHandle(array);


	new Handle:leftresult=	MergeSort(smallerarrayleft);
	new Handle:rightresult=	MergeSort(smallerarrayright);

	new Handle:resultarray=CreateArray(1,0);
	new index=0;
	while(GetArraySize(leftresult)>0&&GetArraySize(rightresult)>0){
		new leftval=W3GetRaceOrder( GetArrayCell(leftresult, 0));
		new rightval=W3GetRaceOrder( GetArrayCell(rightresult, 0));
		//PrintToServer("left %d vs right %d",leftval,rightval);

		if(leftval<=rightval){
			PushArrayCell(resultarray,-1); //add index
			SetArrayCell(resultarray, index, GetArrayCell(leftresult, 0));

			RemoveFromArray(leftresult, 0);

			//printArray("took left" ,resultarray);
		}
		else{
			PushArrayCell(resultarray,-1); //add index
			SetArrayCell(resultarray, index, GetArrayCell(rightresult, 0));

			RemoveFromArray(rightresult, 0);
			//printArray("took right" ,resultarray);
		}
		index++;
	}

	new bool:closeleft,bool:closeright;
	if(GetArraySize(leftresult)>0){
		resultarray=append(resultarray,leftresult);
		closeright=true;
	}
	else if(GetArraySize(rightresult)>0){
		resultarray=append(resultarray,rightresult);
		closeleft=true;
	}


	if(closeleft){
		CloseHandle(leftresult);
	}
	if(closeright){
		CloseHandle(rightresult);
	}

	return resultarray;

}
Handle:append(Handle:leftarr,Handle:rightarr){
	new leftindex=GetArraySize(leftarr);
	new rigthlen=GetArraySize(rightarr);

	for(new i=0;i<rigthlen;i++){
		//append right
		PushArrayCell(leftarr,-1); //add index to left
		SetArrayCell(leftarr, leftindex, GetArrayCell(rightarr, 0));

		RemoveFromArray(rightarr, 0);
		leftindex++;
	}
	CloseHandle(rightarr);
	//printArray("appended" ,leftarr);
	return leftarr;
}

// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
stock bool IsSkillUltimate(int raceid,int skill)
{
	return skillIsUltimate[raceid][skill];
}
stock bool GetRaceSkillMaxLevel(int raceid,int skill)
{
	return skillMaxLevel[raceid][skill];
}

stock GetRaceSkillName(raceid,skillindex,String:retstr[],maxlen)
{
	if(raceid<1||raceid>internal_GetRacesLoaded()){
		//ThrowNativeError(1,"bad race %d",race);
		return -1;
	}
	if(skillindex<1||skillindex>GetRaceSkillCount(raceid)){
		//ThrowNativeError(1,"bad skillid %d",skill);
		return -1;
	}

	if(skillTranslated[raceid][skillindex]){
		new String:buf[64];
		new String:longbuf[512];

		Format(buf,sizeof(buf),"%s_skill_%s",raceShortname[raceid],raceSkillName[raceid][skillindex]);
		Format(longbuf,sizeof(longbuf),"%T",buf,GetTrans());
		return strcopy(retstr, maxlen,longbuf);
	}

	new num=strcopy(retstr, maxlen, raceSkillName[raceid][skillindex]);
	return num;
}

stock GetRaceSkillDesc(raceid,skillindex,String:retstr[],maxlen){
	if(skillTranslated[raceid][skillindex]){
		new String:buf[64];
		new String:longbuf[512];
		Format(buf,sizeof(buf),"%s_skill_%s_desc",raceShortname[raceid],raceSkillName[raceid][skillindex]);
		Format(longbuf,sizeof(longbuf),"%T",buf,GetTrans());

		new strreplaces=raceSkillDescReplaceNum[raceid][skillindex];
		for(new i=0;i<strreplaces;i++){
			new String:find[10];
			Format(find,sizeof(find),"#%d#",i+1);
			ReplaceString(longbuf,sizeof(longbuf),find,raceSkillDescReplace[raceid][skillindex][i]);
		}

		return strcopy(retstr, maxlen,longbuf);
	}

	new num=strcopy(retstr, maxlen, raceSkillDescription[raceid][skillindex]);
	return num;
}

stock int GetRaceSkillCount(int raceid)
{
	if(raceid>0){
		return raceSkillCount[raceid];
	}
	else{
		LogError("bad race ID %d",raceid);
		return -1;
	}
}

//gets max level based on the max levels of its skills
stock GetRaceMaxLevel(raceid){
	new num=0;
	new SkillCount = GetRaceSkillCount(raceid);
	for(new skill=1;skill<=SkillCount;skill++){
		num+=skillMaxLevel[raceid][skill];
	}
	return num;
}

stock bool:RaceExistsByShortname(String:shortname[]){
	new String:buffer[16];

	new RacesLoaded = internal_GetRacesLoaded();
	for(new raceid=1;raceid<=RacesLoaded;raceid++){
		GetRaceShortname(raceid,buffer,sizeof(buffer));
		if(StrEqual(shortname, buffer, false)){
			return true;
		}
	}
	return false;
}


stock GetRaceSkillNonUltimateCount(raceid){
	new num;
	new skillcount = GetRaceSkillCount(raceid);
	for(new i=1;i<=skillcount;i++){
		if(!IsSkillUltimate(raceid,i)) //regular skill
		{
			num++;
		}
	}
	return num;
}

stock GetRaceSkillIsUltimateCount(raceid){
	new num;
	new SkillCount = GetRaceSkillCount(raceid);
	for(new i=1;i<=SkillCount;i++){
		if(IsSkillUltimate(raceid,i)) //regular skill
		{
			num++;
		}
	}
	return num;
}

stock printArray(String:prepend[]="",Handle:arr){
	new len=GetArraySize(arr);
	new String:print[100];
	Format(print,sizeof(print),"%s {",prepend);
	for(new i=0;i<len;i++){
		Format(print,sizeof(print),"%s %d",print,GetArrayCell(arr,i));
	}
	Format(print,sizeof(print),"%s}",print);
	PrintToServer(print);
}

stock RaceNameSearch(String:changeraceArg[32])
{
		new String:sRaceName[32];
		new RacesLoaded=internal_GetRacesLoaded();
		new race=0;
		//full name
		for(race=1;race<=RacesLoaded;race++)
		{
			GetRaceName(race,sRaceName,sizeof(sRaceName));
			if(StrContains(sRaceName,changeraceArg,false)>-1){
				return race;
			}
		}
		//shortname // checks inside of for() for raceFound==
		new String:sShortRaceName[16];
		for(race=1;race<=RacesLoaded;race++)
		{
			GetRaceShortname(race,sShortRaceName,sizeof(sShortRaceName));
			if(StrContains(sShortRaceName,changeraceArg,false)>-1){
				return race;
			}
		}
		return -1;
}

stock GetRaceShortname(raceid,String:retstr[],maxlen)
{
	if(raceid>=1 && raceid<=internal_GetRacesLoaded())
	{
		new num=strcopy(retstr, maxlen, raceShortname[raceid]);
		return num;
	}
	return -1;
}

stock GetRaceName(raceid,String:retstr[],maxlen){
	if(raceid>=1 && raceid<=internal_GetRacesLoaded())
	{

		if(raceTranslated[raceid]){
			new String:buf[64];
			new String:longbuf[1000];
			Format(buf,sizeof(buf),"%s_RaceName",raceShortname[raceid]);
			Format(longbuf,sizeof(longbuf),"%T",buf,GetTrans());
			return strcopy(retstr, maxlen,longbuf);
		}
		new num=strcopy(retstr, maxlen, raceName[raceid]);
		return num;
	}
	return -1;
}


//stock size16_War3_GetRaceShortname(raceid,String:retstr[])

//stock size32_War3_GetRaceName(raceid,String:retstr[])

stock GetRacesLoaded()
{
	return  totalRacesLoaded;
}

stock size16_GetRaceIDByShortname(String:shortname[])
{
	char buffer[16];

	int RacesLoaded = GetRacesLoaded();
	for(int raceid=1;raceid<=RacesLoaded;raceid++){
		GetRaceShortname(raceid,buffer,sizeof(buffer));
		if(StrEqual(shortname, buffer, false)){
			return raceid;
		}
	}
	return -1;
}
