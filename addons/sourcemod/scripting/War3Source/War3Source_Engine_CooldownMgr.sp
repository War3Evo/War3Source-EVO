// War3Source_Engine_CooldownMgr.sp

//Cooldown manager
//keeps track of all cooldowns

//Delay Tracker:
//setting an object's state to false for X seconds, manually retrieve the state

new bool:CooldownOnSpawn[MAXRACES][MAXSKILLCOUNT];
new bool:CdOnSpawnPrintOnExpire[MAXRACES][MAXSKILLCOUNT];
new Float:CooldownOnSpawnDuration[MAXRACES][MAXSKILLCOUNT];

new String:ultimateReadySound[256]; //="war3source/ult_ready.mp3";
new String:abilityReadySound[256]; //="war3source/ability_refresh.mp3";

Handle g_CooldownExpiredForwardHandle;
Handle g_CooldownStartedForwardHandle;


new CooldownPointer[MAXPLAYERSCUSTOM][MAXRACES][MAXSKILLCOUNT];

enum CooldownClass
{
	Float:cexpiretime,
	cclient,
	crace,
	cskill,
	bool:cexpireonspawn,
	bool:cprintmsgonexpire,
	cnext,
}

#define MAXCOOLDOWNS 64*2
new Cooldown[MAXCOOLDOWNS][CooldownClass];

#define MAXTHREADS 2000
new Float:expireTime[MAXTHREADS];
new threadsLoaded;

/*
public Plugin:myinfo=
{
	name="W3S Engine Cooldown Manager",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};*/


public War3Source_Engine_CooldownMgr_OnMapStart()
{
	for(new i=0;i<MAXTHREADS;i++){
		expireTime[i]=0.0;
	}

	ClearAllCooldowns();
}

public War3Source_Engine_CooldownMgr_OnAddSound(sound_priority)
{
	if(sound_priority==PRIORITY_LOW)
	{
		strcopy(ultimateReadySound,sizeof(ultimateReadySound),"war3source/ult_ready.mp3");
		strcopy(abilityReadySound,sizeof(abilityReadySound),"war3source/ability_refresh.mp3");
		War3_AddSound("War3Source_Engine_CooldownMgr","ui/hint.wav",STOCK_SOUND);
		War3_AddSound("War3Source_Engine_CooldownMgr",abilityReadySound,CUSTOM_SOUND);
		War3_AddSound("War3Source_Engine_CooldownMgr",ultimateReadySound,CUSTOM_SOUND);
	}
}

public bool:War3Source_Engine_CooldownMgr_InitNatives()
{

	///LIST ALL THESE NATIVES IN INTERFACE
	CreateNative("War3_CooldownMGR",Native_War3_CooldownMGR);
	CreateNative("War3_CooldownRemaining",Native_War3_CooldownRMN);
	CreateNative("War3_CooldownReset",Native_War3_CooldownReset);
	CreateNative("War3_SkillNotInCooldown",Native_War3_SkillNIC);
	CreateNative("War3_PrintSkillIsNotReady",Native_War3_PrintSkillINR);


	CreateNative("War3_RegisterDelayTracker",NWar3_RegisterDelayTracker);
	CreateNative("War3_TrackDelay",NWar3_TrackDelay);
	CreateNative("War3_TrackDelayExpired",NWar3_TrackDelayExpired);

	CreateNative("W3SkillCooldownOnSpawn",NW3SkillCooldownOnSpawn);
	return true;
}

public bool:War3Source_Engine_CooldownMgr_InitNativesForwards()
{
	g_CooldownExpiredForwardHandle=CreateGlobalForward("OnCooldownExpired",ET_Ignore,Param_Cell,Param_Cell,Param_Cell,Param_Cell);
	g_CooldownStartedForwardHandle=CreateGlobalForward("OnCooldownStarted",ET_Ignore,Param_Cell,Param_Cell,Param_Cell);
	return true;
}

public NWar3_RegisterDelayTracker(Handle:plugin,numParams)
{
	if(threadsLoaded<MAXTHREADS){
		return threadsLoaded++;
	}
	LogError("[W3S Engine 1] DELAY TRACKER MAXTHREADS LIMIT REACHED! return -1");
	return -1;
}
public NWar3_TrackDelay(Handle:plugin,numParams)
{
	new index=GetNativeCell(1);
	new Float:delay=GetNativeCell(2);
	expireTime[index]=GetEngineTime()+delay;
}
public NWar3_TrackDelayExpired(Handle:plugin,numParams)
{
	return GetEngineTime()>expireTime[GetNativeCell(1)];
}

public NW3SkillCooldownOnSpawn(Handle:plugin,numParams)
{
	new raceid=GetNativeCell(1);
	new skillid=GetNativeCell(2);
	new Float:cooldowntime=GetNativeCell(3);
	new bool:print=GetNativeCell(4);
	CooldownOnSpawn[raceid][skillid]=true;
	CdOnSpawnPrintOnExpire[raceid][skillid]=print;
	CooldownOnSpawnDuration[raceid][skillid]=cooldowntime;
}

public Native_War3_CooldownMGR(Handle:plugin,numParams)
{
		new client = GetNativeCell(1);
		new Float:cooldownTime= GetNativeCell(2);
		new raceid = GetNativeCell(3);
		new skillNum = GetNativeCell(4); ///can use skill numbers
		new bool:resetOnSpawn = GetNativeCell(5);
		new bool:printMsgOnExpireByTime = GetNativeCell(6);

		internal_W3SetVar(EventArg1,cooldownTime); //float
		DoFwd_War3_Event(OnWar3_CooldownMGR,client); //fire event

		cooldownTime=Float:internal_W3GetVar(EventArg1);

		Internal_CreateCooldown(client,cooldownTime,raceid,skillNum,resetOnSpawn,printMsgOnExpireByTime);
}
public Native_War3_CooldownRMN(Handle:plugin,numParams) //cooldown remaining time
{
	if(numParams==3){
		new client = GetNativeCell(1);
		new raceid = GetNativeCell(2);
		new skillNum = GetNativeCell(3); ///can use skill numbers

		new index=GetCooldownIndexByCRS(client,raceid,skillNum);
		if(index>0){
			return RoundToCeil(Cooldown[index][cexpiretime]-GetEngineTime());
		}
		return _:0.0;
	}
	return -1;
}
public Native_War3_CooldownReset(Handle:plugin,numParams)
{
	if(numParams==3){
		new client = GetNativeCell(1);
		new raceid = GetNativeCell(2);
		new skillNum = GetNativeCell(3); ///can use skill numbers
		CooldownResetByCRS(client,raceid,skillNum);
	}
	return -1;
}
public Native_War3_SkillNIC(Handle:plugin,numParams) //NOT IN COOLDOWN , skill available
{
	if(numParams>=3){
		new client = GetNativeCell(1);
		new raceid = GetNativeCell(2);
		new skillNum = GetNativeCell(3); ///can use skill numbers
		new bool:printTextIfNotReady=false;
		if(numParams>3){
			printTextIfNotReady=GetNativeCell(4);
		}
		new bool:result= InternalIsSkillNotInCooldown(client,raceid,skillNum);
		if(result==false&&printTextIfNotReady){
			Internal_PrintSkillNotAvailable(GetCooldownIndexByCRS(client,raceid,skillNum));
		}
		return result;
	}
	return -1;
}
public Native_War3_PrintSkillINR(Handle:plugin,numParams)
{
	if(numParams==3){
		new client = GetNativeCell(1);
		new raceid = GetNativeCell(2);
		new skillNum = GetNativeCell(3); ///can use skill numbers


		Internal_PrintSkillNotAvailable(GetCooldownIndexByCRS(client,raceid,skillNum)); //cooldown inc
	}
	return -1;
}

ClearAllCooldowns()
{

			///we just dump the entire linked list
	for(new i=0;i<MAXCOOLDOWNS;i++){
		//we need to "unenable" aka free each cooldown
		Cooldown[i][cexpiretime]=0.0;

	}
	Cooldown[0][cnext]=0;


	for(new i=1;i<=MaxClients;i++)
	{
		for(new raceid=0;raceid< MAXRACES;raceid++)
		{
			for(new skillNum=0;skillNum<MAXSKILLCOUNT;skillNum++) //strart from zero anyway
			{
				CooldownPointer[i][raceid][skillNum]=0;
			}
		}
	}
}


Internal_CreateCooldown(client,Float:cooldownTime,raceid,skillNum,bool:resetOnSpawn,bool:printMsgOnExpireByTime){

	new indextouse=-1;
	new bool:createlinks=true;
	if(CooldownPointer[client][raceid][skillNum]>0){ //already has a cooldown
		indextouse=CooldownPointer[client][raceid][skillNum];
		createlinks=false;
	}
	else{
		for(new i=1;i<MAXCOOLDOWNS;i++){
			if(Cooldown[i][cexpiretime]<1.0){ //consider this one empty
				indextouse=i;
				break;
			}
		}
	}
	/**********************
	 * this isliked a linked list
	 */
	if(indextouse==-1){
		LogError("ERROR, UNABLE TO CREATE COOLDOWN");
	}
	else{
		if(createlinks){ //if u create links again and u are already link from the prevous person, u will infinite loop

			Cooldown[indextouse][cnext]=Cooldown[indextouse-1][cnext]; //this next is the previous guy's next
			Cooldown[indextouse-1][cnext]=indextouse; //previous guy points to you
		}

		Cooldown[indextouse][cexpiretime]=GetEngineTime()+cooldownTime;
		Cooldown[indextouse][cclient]=client;
		Cooldown[indextouse][crace]=raceid;
		Cooldown[indextouse][cskill]=skillNum;
		Cooldown[indextouse][cexpireonspawn]=resetOnSpawn;
		Cooldown[indextouse][cprintmsgonexpire]=printMsgOnExpireByTime;

		CooldownPointer[client][raceid][skillNum]=indextouse;

		Call_StartForward(g_CooldownStartedForwardHandle);
		Call_PushCell(client);
		Call_PushCell(raceid);
		Call_PushCell(skillNum);
		int result;
		Call_Finish(result); //this will be returned to ?

	}
}
public War3Source_Engine_CooldownMgr_DeciSecondTimer()
{
	if(MapChanging || War3SourcePause) return 0;

	CheckCooldownsForExpired(false);

	return 1;
}
CheckCooldownsForExpired(bool:expirespawn,clientthatspawned=0)
{

	new Float:currenttime=GetEngineTime();
	new tempnext;
	new skippedfrom;

	new Handle:arraylist[MAXPLAYERSCUSTOM]; //hint messages will be attached to an arraylist

	for(new i=0;i<MAXCOOLDOWNS;i++){
		if(Cooldown[i][cexpiretime]>1.0) //enabled
		{
			new bool:expired;
			new bool:bytime;
			if(currenttime>Cooldown[i][cexpiretime]){
				expired=true;
				bytime=true;
			}
			else if(expirespawn&&Cooldown[i][cclient]==clientthatspawned&&Cooldown[i][cexpireonspawn]){
				expired=true;
			}


			if(expired)
			{
				//PrintToChatAll("EXPIRED");
				CooldownExpired(i, bytime);
				Cooldown[i][cexpiretime]=0.0;

				if(i>0){ //not front do some pointer changes, shouldnt be front anyway
					Cooldown[skippedfrom][cnext]=Cooldown[i][cnext];
					//PrintToChatAll("changing next at %d to %d",skippedfrom,Cooldown[i][cnext]);
				}
				//PrintToChatAll("CD expired %d %d %d",Cooldown[i][cclient],Cooldown[i][crace],Cooldown[i][cskill]);
				i=skippedfrom;
			}
			else{
				new client=Cooldown[i][cclient];
				new race=Cooldown[i][crace];
				new skill=Cooldown[i][cskill];
				new timeremaining=RoundToCeil(Cooldown[i][cexpiretime]-GetEngineTime());
				if(GetRace(client)==Cooldown[i][crace] && GetSkillLevel(client,race,skill)>0&& timeremaining<=5 && Cooldown[i][cprintmsgonexpire]==true){ //is this race, and has this skill

					if(arraylist[client]==INVALID_HANDLE){
						arraylist[client]=CreateArray(ByteCountToCells(128));
					}
					new String:str[128];
					SetTrans(client);
					new String:skillname[32];
					if(GetRaceSkillName(Cooldown[i][crace],Cooldown[i][cskill],skillname,sizeof(skillname))>0)
					{
						Format(str,sizeof(str),"%s%s: %d",GetArraySize(arraylist[client])>0?"\n":"",skillname,timeremaining);
						PushArrayString(arraylist[client],str);
					}
					else
					{
						Format(str,sizeof(str),"%s%s: %d",GetArraySize(arraylist[client])>0?"\n":"","unknown",timeremaining);
						PushArrayString(arraylist[client],str);
						LogError("CoolDownMgr CheckCooldownsForExpired - War3Source Lookup of GetRaceSkillName(%d,%d,%s,sizeof(%d))",Cooldown[i][crace],Cooldown[i][cskill],skillname,sizeof(skillname));
					}
				}
			}
		}
		tempnext=Cooldown[i][cnext];

		if(tempnext==0){
			//PrintToChatAll("DeciSecondTimer4 break because next is zero at index %d",i);
			break;
		}
		skippedfrom=i;
		i=tempnext-1; //i will increment, decremet it first here
	}
	static bool:cleared[MAXPLAYERSCUSTOM];
	for(new client=1;client<=MaxClients;client++){

		if(arraylist[client]){
			new Handle:array=arraylist[client];
			new String:str[128];
			new String:newstr[128];
			new size=GetArraySize(array);
			for(new i=0;i<size;i++){
				GetArrayString(array,i,newstr,sizeof(newstr));
				StrCat(str,sizeof(str),newstr);
			}
			W3Hint(client,HINT_COOLDOWN_COUNTDOWN,4.0,str);
			CloseHandle(arraylist[client]);
			arraylist[client]=INVALID_HANDLE;
			cleared[client]=false;
		}
		else{
			if(cleared[client]==false){
				cleared[client]=true;
				W3Hint(client,HINT_COOLDOWN_COUNTDOWN,0.0,"");//CLEAR IT , so we dont have "ready" and "cooldown" of same skill at same time
			}
		}
	}
}


CooldownResetByCRS(client,raceid,skillnum){
	if(CooldownPointer[client][raceid][skillnum]>0){
		Cooldown[CooldownPointer[client][raceid][skillnum]][cexpiretime]=GetEngineTime(); ///lol
	}
}
CooldownExpired(i,bool:expiredByTimer)
{
	new client=Cooldown[i][cclient];
	new raceid=Cooldown[i][crace];
	new skillNum=Cooldown[i][cskill];
	CooldownPointer[client][raceid][skillNum]=-1;

	if(expiredByTimer){
		if(ValidPlayer(client,true)&&Cooldown[i][cprintmsgonexpire]&&(GetRace(client)==raceid)){ //if still the same race and alive
			if(GetSkillLevel(client,raceid,skillNum)>0){

				new String:skillname[64];
				SetTrans(client);
				if(GetRaceSkillName(raceid,skillNum,skillname,sizeof(skillname))>0)
				{
					//{ultimate} is just an argument, we fill it in with skillname
					new String:str[128];
					Format(str,sizeof(str),"%T","{ultimate} Is Ready",client,skillname);
					W3Hint(client,HINT_COOLDOWN_EXPIRED,4.0,str);
					W3Hint(client,HINT_COOLDOWN_NOTREADY,0.0,""); //if something is ready, force erase the not ready

					War3_EmitSoundToAll( IsSkillUltimate(raceid,skillNum)?ultimateReadySound:abilityReadySound , client);
				}
				else
				{
					//{ultimate} is just an argument, we fill it in with skillname
					new String:str[128];
					Format(str,sizeof(str),"Ultimate Is Ready");
					W3Hint(client,HINT_COOLDOWN_EXPIRED,4.0,str);
					W3Hint(client,HINT_COOLDOWN_NOTREADY,0.0,""); //if something is ready, force erase the not ready

					War3_EmitSoundToAll( IsSkillUltimate(raceid,skillNum)?ultimateReadySound:abilityReadySound , client);

					LogError("CoolDownMgr CooldownExpired - War3Source Lookup of GetRaceSkillName(%d,%d,%s,sizeof(%d))",raceid,skillNum,skillname,sizeof(skillname));
				}
			}
		}
	}

	Call_StartForward(g_CooldownExpiredForwardHandle);
	Call_PushCell(client);
	Call_PushCell(raceid);
	Call_PushCell(skillNum);
	Call_PushCell(expiredByTimer);
	new result;
	Call_Finish(result); //this will be returned to ?
}


public bool:InternalIsSkillNotInCooldown(client,raceid,skillNum)
{
	new index=GetCooldownIndexByCRS(client,raceid,skillNum);
	if(index>0){
		return false; //has record = in cooldown
	}
	return true; //no cooldown record
}
GetCooldownIndexByCRS(client,raceid,skillNum)
{
	return CooldownPointer[client][raceid][skillNum];
}

public Internal_PrintSkillNotAvailable(cooldownindex)
{
	new client=Cooldown[cooldownindex][cclient];
	new race=Cooldown[cooldownindex][crace];
	new skill=Cooldown[cooldownindex][cskill];
	if(ValidPlayer(client,true)){
		new String:skillname[64];
		SetTrans(client);
		if(GetRaceSkillName(race,skill,skillname,sizeof(skillname))>0)
		{
			W3Hint(client,HINT_COOLDOWN_NOTREADY,2.5,"%T","{skill} Is Not Ready. {amount} Seconds Remaining",client,skillname,War3_CooldownRemaining(client,race,skill));
		}
		else
		{
			LogError("CoolDownMgr Is Not Ready - War3Source Lookup of GetRaceSkillName(%d,%d,%s,sizeof(%d))",race,skill,skillname,sizeof(skillname));
		}

	}
}

public War3Source_Engine_CooldownMgr_OnWar3EventSpawn(client)
{
	CheckCooldownsForExpired(true,client);
	new race=GetRace(client);
	if(race > 0)
	{
		for(new i=1;i<MAXSKILLCOUNT;i++){
			if(CooldownOnSpawn[race][i]){ //only his race
				Internal_CreateCooldown(client,CooldownOnSpawnDuration[race][i],race,i,false,CdOnSpawnPrintOnExpire[race][i]);
			}
		}
	}
}
