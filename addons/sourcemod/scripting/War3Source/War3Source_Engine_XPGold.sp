// War3Source_Engine_XPGold.sp

//#pragma tabsize 0     // doesn't mess with how you format your lines

//#assert GGAMEMODE == MODE_WAR3SOURCE

/*
public Plugin:myinfo=
{
	name="W3S Engine XP Gold",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};*/

//new String:levelupSound[]="war3source/levelupcaster.mp3";

new mySwitch=1;

///MAXLEVELXPDEFINED is in constants
new XPLongTermREQXP[MAXLEVELXPDEFINED+1]; //one extra for even if u reached max level
new XPLongTermKillXP[MAXLEVELXPDEFINED+1];
new XPShortTermREQXP[MAXLEVELXPDEFINED+1];
new XPShortTermKillXP[MAXLEVELXPDEFINED+1];


// not game specific
new Handle:RoundWinXPCvar;

#if (GGAMETYPE_JAILBREAK == JAILBREAK_OFF)
new Handle:BotIgnoreXPCvar;
new Handle:HeadshotXPCvar;
new Handle:MeleeXPCvar;
new Handle:AssistKillXPCvar;
#endif

new Handle:hLevelDifferenceBounus;
new Handle:minplayersXP;
//new Handle:NoSpendSkillsLimitCvar;

//gold
new Handle:MaxGoldCvar;
new Handle:KillGoldCvar;
new Handle:AssistGoldCvar;



public War3Source_Engine_XPGold_OnPluginStart()
{
	//CreateConVar("XPGold",PLUGIN_VERSION,"[War3Source:EVO] XP Gold system",FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);

#if (GGAMETYPE_JAILBREAK == JAILBREAK_OFF)
	BotIgnoreXPCvar=CreateConVar("war3_ignore_bots_xp","0","Set to 1 to not award XP for killing bots");
	HeadshotXPCvar=CreateConVar("war3_percent_headshotxp","20","Percent of kill XP awarded additionally for headshots");
	MeleeXPCvar=CreateConVar("war3_percent_meleexp","120","Percent of kill XP awarded additionally for melee/knife kills");
	AssistKillXPCvar=CreateConVar("war3_percent_assistkillxp","75","Percent of kill XP awarded for an assist kill.");
#endif
	RoundWinXPCvar=CreateConVar("war3_percent_roundwinxp","100","Percent of kill XP awarded for being on the winning team");

	hLevelDifferenceBounus=CreateConVar("war3_xp_level_difference_bonus","0","Bounus Xp awarded per level if victim has a higher level");
	minplayersXP=CreateConVar("war3_min_players_xp_gain","2","minimum amount of players needed on teams for people to gain xp");
	MaxGoldCvar=CreateConVar("war3_maxgold","100");

	KillGoldCvar=CreateConVar("war3_killgold","2");
	AssistGoldCvar=CreateConVar("war3_assistgold","1");

	ParseXPSettingsFile();
#if (GGAMETYPE == GGAME_TF2)
	if(!HookEventEx("teamplay_round_win",War3Source_Engine_XPGold_War3Source_RoundOverEvent)) //usual win xp
	{
		PrintToServer("[War3Source:EVO] Could not hook the teamplay_round_win event.");
	}
#elseif (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
	if(!HookEventEx("round_end",War3Source_Engine_XPGold_War3Source_RoundOverEvent)) //usual win xp
	{
		PrintToServer("[War3Source:EVO] Could not hook the teamplay_round_win event.");
	}
	if(!HookEventEx("round_freeze_end",War3Source_Engine_XPGold_War3Source_RoundOverEvent)) //usual win xp
	{
		PrintToServer("[War3Source:EVO] Could not hook the teamplay_round_win event.");
	}
	if(!HookEventEx("cs_win_panel_round",War3Source_Engine_XPGold_War3Source_RoundOverEvent)) //usual win xp
	{
		PrintToServer("[War3Source:EVO] Could not hook the teamplay_round_win event.");
	}
#endif
}

new String:meleeKiller[256];
new String:meleeKilled[256];
new String:headshotKiller[256];

public War3Source_Engine_XPGold_OnMapStart()
{
	//strcopy(meleeKiller,sizeof(meleeKiller),"war3source/gotchaknife.mp3");
	//strcopy(meleeKilled,sizeof(meleeKilled),"war3source/gotchaknife.mp3");
	//strcopy(headshotKiller,sizeof(headshotKiller),"war3source/bheadshot.mp3");
	//War3_PrecacheSound(meleeKiller);
	//War3_PrecacheSound(meleeKilled);
	//War3_PrecacheSound(headshotKiller);
	//War3_PrecacheSound(levelupSound);

	ParseXPSettingsFile();


}

public War3Source_Engine_XPGold_OnAddSound(sound_priority)
{
	if(sound_priority==PRIORITY_LOW)
	{
		strcopy(meleeKiller,sizeof(meleeKiller),"war3source/gotchaknife.mp3");
		strcopy(meleeKilled,sizeof(meleeKilled),"war3source/gotchaknife.mp3");
		strcopy(headshotKiller,sizeof(headshotKiller),"war3source/bheadshot.mp3");
		War3_AddSound("War3Source_Engine_XPGold",meleeKiller,CUSTOM_SOUND);
		War3_AddSound("War3Source_Engine_XPGold",meleeKilled,CUSTOM_SOUND);
		War3_AddSound("War3Source_Engine_XPGold",headshotKiller,CUSTOM_SOUND);
		//War3_AddSound("War3Source_Engine_XPGold",levelupSound);
	}
}

public bool:War3Source_Engine_XPGold_InitNatives()
{
	CreateNative("W3GetReqXP" ,NW3GetReqXP);
	CreateNative("War3_ShowXP",Native_War3_ShowXP);
	CreateNative("W3GetKillXP",NW3GetKillXP);

	CreateNative("W3GetMaxGold",NW3GetMaxGold);
	CreateNative("W3GetKillGold",NW3GetKillGold);
	CreateNative("W3GetAssistGold",NW3GetAssistGold);
	CreateNative("W3GiveXPGold",NW3GiveXPGold);
	CreateNative("W3GiveFakeXPGold",NW3GiveFakeXPGold);

	return true;
}
public NW3GetReqXP(Handle:plugin,numParams)
{
	new level=GetNativeCell(1);
	if(level>MAXLEVELXPDEFINED)
		level=MAXLEVELXPDEFINED;
	return IsShortTerm()?XPShortTermREQXP[level] :XPLongTermREQXP[level];
}
public NW3GetKillXP(Handle:plugin,numParams)
{
	new client=GetNativeCell(1);
	new race=GetRace(client);
	if(race>0){
		new level=War3_GetLevel(client,race);
		if(level>MAXLEVELXPDEFINED)
			level=MAXLEVELXPDEFINED;
		new leveldiff=	GetNativeCell(2);

		if(leveldiff<0) leveldiff=0;

		return (IsShortTerm()?XPShortTermKillXP[level] :XPLongTermKillXP[level]) + (GetConVarInt(hLevelDifferenceBounus)*leveldiff);
	}
	return 0;
}
public Native_War3_ShowXP(Handle:plugin,numParams)
{
	if(numParams>0)
		ShowXP(GetNativeCell(1));
}
public NW3GetMaxGold(Handle:plugin,numParams)
{
	new client = -1;
	if (numParams)
		client=GetNativeCell(1);
	if (client == -1)
	{
		return 100000;
	} else if (client == 99) {
		return GetConVarInt(MaxGoldCvar);
	} else if (GetPlayerProp(client, PlayerGold) <= GetConVarInt(MaxGoldCvar)) {
		return GetConVarInt(MaxGoldCvar);
	} else {
		return 100000;
	}
}
public NW3GiveXPGold(Handle:plugin,args){
	new client=GetNativeCell(1);
	// don't give a player gold/xp if they are the boss in EVENTS!

	//if(War3_IsPlayerBoss(client)) return;

	new W3XPAwardedBy:awardby=W3XPAwardedBy:GetNativeCell(2);
	new xp=GetNativeCell(3);
	new gold=GetNativeCell(4);
	new String:strreason[64];

	GetNativeString(5,strreason,sizeof(strreason));
	new temp=GetNativeCell(6);

	if (temp)
		mySwitch = 0;

	TryToGiveXPGold(client,awardby,xp,gold,strreason,false);

}

public NW3GiveFakeXPGold(Handle:plugin,args){
	new clientIndex=GetNativeCell(1);
#if (GGAMETYPE_JAILBREAK == JAILBREAK_OFF)
	new victimIndex=GetNativeCell(2);
	new assisterIndex=GetNativeCell(3);
#endif
	new W3XPAwardedBy:awardby=W3XPAwardedBy:GetNativeCell(4);
	new xp=GetNativeCell(5);
	new gold=GetNativeCell(6);
	new String:strreason[64];
	GetNativeString(7,strreason,sizeof(strreason));
#if (GGAMETYPE_JAILBREAK == JAILBREAK_OFF)
	new bool:extra1=bool:GetNativeCell(8); // is_hs
	new bool:extra2=bool:GetNativeCell(9); // is_melee
#endif
	if(awardby==XPAwardByFakeKill && gold==0 && xp==0)
	{
#if (GGAMETYPE_JAILBREAK == JAILBREAK_OFF)
		GiveKillXPCreds(clientIndex,victimIndex,extra1,extra2, true);
#endif
		return;
	}
	if(awardby==XPAwardByFakeAssist && gold==0 && xp==0)
	{
#if (GGAMETYPE_JAILBREAK == JAILBREAK_OFF)
		GiveAssistKillXP(assisterIndex, true);
#endif
		return;
	}
	TryToGiveXPGold(clientIndex,awardby,xp,gold,strreason,true);
}


public NW3GetKillGold(Handle:plugin,args){
	return GetConVarInt(KillGoldCvar);
}
public NW3GetAssistGold(Handle:plugin,args){
	return GetConVarInt(AssistGoldCvar);
}

ParseXPSettingsFile(){
	new Handle:keyValue=CreateKeyValues("War3SourceSettings");

	decl String:path[1024];
#if (GGAMETYPE == GGAME_TF2)
	if (!IsMvM(true))
		BuildPath(Path_SM,path,sizeof(path),"configs/war3source.ini");
	else
		BuildPath(Path_SM,path,sizeof(path),"configs/war3sourceMVM.ini");
#else
	BuildPath(Path_SM,path,sizeof(path),"configs/war3source.ini");
#endif

	//decl String:path2[1024];


	FileToKeyValues(keyValue,path);
	// Load level configuration
	KvRewind(keyValue);



	if(!KvJumpToKey(keyValue,"levels"))
		SetFailState("error, key value for levels configuration not found");


	decl String:read[2048];
	if(!KvGotoFirstSubKey(keyValue))
		SetFailState("sub key failed");




	// required xp, long term
	KvGetString(keyValue,"required_xp",read,sizeof(read));
	new tokencount=StrTokenCount(read);

	if(tokencount!=MAXLEVELXPDEFINED+1)
	{
		LogError("required xp, long term config improperly formatted, not enought or too much levels defined?");
		new maxleveldff=MAXLEVELXPDEFINED+1;
		new CopyLastNum=1;
		decl String:temp_iter[16];
		for(new x=1;x<=maxleveldff;x++)
		{
			if(x>tokencount)
			{
				// create it (it does not exist)
				XPLongTermREQXP[x-1]=CopyLastNum*2;    // Maybe should test for copylastnum to be zero??
			}
			else
			{
				// store it
				StrToken(read,x,temp_iter,15);
				XPLongTermREQXP[x-1]=StringToInt(temp_iter);
				CopyLastNum=XPLongTermREQXP[x-1];
			}
		}
	}
	else
	{
		decl String:temp_iter[16];
		for(new x=1;x<=tokencount;x++)
		{
			// store it
			StrToken(read,x,temp_iter,15);
			XPLongTermREQXP[x-1]=StringToInt(temp_iter);
		}
	}




	// kill xp, long term
	KvGetString(keyValue,"kill_xp",read,sizeof(read));
	tokencount=StrTokenCount(read);

	if(tokencount!=MAXLEVELXPDEFINED+1)
	{
		LogError("kill xp, long term config improperly formatted, not enought or too much levels defined?");
		new maxleveldff=MAXLEVELXPDEFINED+1;
		new CopyLastNum=1;
		decl String:temp_iter[16];
		for(new x=1;x<=maxleveldff;x++)
		{
			if(x>tokencount)
			{
				// create it (it does not exist)
				XPLongTermKillXP[x-1]=CopyLastNum*2;
			}
			else
			{
				// store it
				StrToken(read,x,temp_iter,15);
				XPLongTermKillXP[x-1]=StringToInt(temp_iter);
				CopyLastNum=XPLongTermKillXP[x-1];
			}
		}
	}
	else
	{
		decl String:temp_iter[16];
		for(new x=1;x<=tokencount;x++)
		{
			// store it
			StrToken(read,x,temp_iter,15);
			XPLongTermKillXP[x-1]=StringToInt(temp_iter);
		}
	}






	if(!KvGotoNextKey(keyValue))
		SetFailState("XP No Next key");

	// required xp, short term
	KvGetString(keyValue,"required_xp",read,sizeof(read));
	tokencount=StrTokenCount(read);
	//if(tokencount!=MAXLEVELXPDEFINED+1)
		//return SetFailState("XP config improperly formatted, not enought or too much levels defined?");
	//for(new x=1;x<=tokencount;x++)
	//{
		// store it
		//StrToken(read,x,temp_iter,15);
		//XPShortTermREQXP[x-1]=StringToInt(temp_iter);
	//}

	if(tokencount!=MAXLEVELXPDEFINED+1)
	{
		LogError("required xp, short term config improperly formatted, not enought or too much levels defined?");
		new maxleveldff=MAXLEVELXPDEFINED+1;
		new CopyLastNum=1;
		decl String:temp_iter[16];
		for(new x=1;x<=maxleveldff;x++)
		{
			if(x>tokencount)
			{
				// create it (it does not exist)
				XPShortTermREQXP[x-1]=CopyLastNum*2;
			}
			else
			{
				// store it
				StrToken(read,x,temp_iter,15);
				XPShortTermREQXP[x-1]=StringToInt(temp_iter);
				CopyLastNum=XPShortTermREQXP[x-1];
			}
		}
	}
	else
	{
		decl String:temp_iter[16];
		for(new x=1;x<=tokencount;x++)
		{
			// store it
			StrToken(read,x,temp_iter,15);
			XPShortTermREQXP[x-1]=StringToInt(temp_iter);
		}
	}






	// kill xp, short term
	KvGetString(keyValue,"kill_xp",read,sizeof(read));
	tokencount=StrTokenCount(read);
	//if(tokencount!=MAXLEVELXPDEFINED+1)
		//return SetFailState("XP config improperly formatted, not enought or too much levels defined?");


	//for(new x=1;x<=tokencount;x++)
	//{
		// store it
		//StrToken(read,x,temp_iter,15);
		//XPShortTermKillXP[x-1]=StringToInt(temp_iter);
	//}
	if(tokencount!=MAXLEVELXPDEFINED+1)
	{
		LogError("kill xp, short term config improperly formatted, not enought or too much levels defined?");
		new maxleveldff=MAXLEVELXPDEFINED+1;
		new CopyLastNum=1;
		decl String:temp_iter[16];
		for(new x=1;x<=maxleveldff;x++)
		{
			if(x>tokencount)
			{
				// create it (it does not exist)
				XPShortTermKillXP[x-1]=CopyLastNum*2;
			}
			else
			{
				// store it
				StrToken(read,x,temp_iter,15);
				XPShortTermKillXP[x-1]=StringToInt(temp_iter);
				CopyLastNum=XPShortTermKillXP[x-1];
			}
		}
	}
	else
	{
		decl String:temp_iter[16];
		for(new x=1;x<=tokencount;x++)
		{
			// store it
			StrToken(read,x,temp_iter,15);
			XPShortTermKillXP[x-1]=StringToInt(temp_iter);
		}
	}


	return true;
}



new tooRecent[33];

public ShowXP(client)
{
	if(!ValidPlayer(client))
		return;
	SetTrans(client);
	new race=GetRace(client);
	if(race==0)
	{
		//if(bXPLoaded[client])
		War3_ChatMessage(client,"%T","You must first select a race with changerace!",client);
		return;
	}
	new level=War3_GetLevel(client,race);
	decl String:racename[32];
	GetRaceName(race,racename,sizeof(racename));

	if (tooRecent[client] - GetTime() > -30)
		return;

	tooRecent[client]=GetTime();

	if(level<GetRaceMaxLevel(race))
		War3_ChatMessage(client,"%T","{racename} - Level {amount} - {amount} XP / {amount} XP",client,racename,level,GetXP(client,race),W3GetReqXP(level+1));
	else
		War3_ChatMessage(client,"%T","{racename} - Level {amount} - {amount} XP",client,racename,level,GetXP(client,race));
}
//main plugin forwards this, does not forward on spy dead ringer, blocks double forward within same frame of same victim
#if (GGAMETYPE_JAILBREAK == JAILBREAK_OFF)
public War3Source_Engine_XPGold_OnWar3EventDeath(victim,attacker)
{
	Handle event=internal_W3GetVar(SmEvent);
	//DP("get event %d",event);
	int assister=GetClientOfUserId(GetEventInt(event,"assister"));

	if(victim!=attacker&&ValidPlayer(attacker))
	{

		if(GetClientTeam(attacker)!=GetClientTeam(victim))
		{
			if(ValidPlayer(attacker))
			{
				decl String:weapon[64];
				GetEventString(event,"weapon",weapon,sizeof(weapon));
				bool is_hs,is_melee;
				if(IsFakeClient(victim) && GetConVarBool(BotIgnoreXPCvar))
					return;
				is_hs=(GetEventInt(event,"customkill")==1);
				//DP("wep %s",weapon);
				is_melee=W3IsDamageFromMelee(weapon);
				//DP("me %d",is_melee);
				/*(StrEqual(weapon,"bat",false) ||
						StrEqual(weapon,"bat_wood",false) ||
						StrEqual(weapon,"bonesaw",false) ||
						StrEqual(weapon,"bottle",false) ||
						StrEqual(weapon,"club",false) ||
						StrEqual(weapon,"fireaxe",false) ||
						StrEqual(weapon,"fists",false) ||
						StrEqual(weapon,"knife",false) ||
						StrEqual(weapon,"lunchbox",false) ||
						StrEqual(weapon,"shovel",false) ||
						StrEqual(weapon,"wrench",false));

						is_melee=StrEqual(weapon,"knife");*/

				if(assister>=0 && GetRace(assister)>0)
				{
					GiveAssistKillXP(assister, false);
				}

				GiveKillXPCreds(attacker,victim,is_hs,is_melee, false);
			}
		}
	}
	if(victim!=attacker&&ValidPlayer(victim))
	{
		new String:sDescription[64];
		Format(sDescription,sizeof(sDescription),"%T","dying bravely in combat!",victim);
		W3GiveXPGold(victim,XPAwardByGeneric,0,1,sDescription);
	}
}
#endif

public War3Source_Engine_XPGold_War3Source_RoundOverEvent(Handle:event,const String:name[],bool:dontBroadcast)
{

// cs - int winner
// tf2 - int team
	new team=-1;
	team=GetEventInt(event,"team");
	if(team>-1)
	{
		for(new i=1;i<=MaxClients;i++)
		{

			if(ValidPlayer(i)&&  GetClientTeam(i)==team)
			{
				new addxp=((  W3GetKillXP(i)*GetConVarInt(RoundWinXPCvar)  )/100);

				new String:teamwinaward[64];
				Format(teamwinaward,sizeof(teamwinaward),"%T","being on the winning team",i);
				W3GiveXPGold(i,XPAwardByWin,addxp,0,teamwinaward);

			}
		}
	}
}















//fire event and allow addons to modify xp and gold
TryToGiveXPGold(client,W3XPAwardedBy:awardedfromevent,xp,gold,String:awardedprintstring[],bool:IsFake){
	new race=GetRace(client);
	if(race>0){
		if(GetConVarInt(minplayersXP)>PlayersOnTeam(2)+PlayersOnTeam(3))
		{
			War3_ChatMessage(client,"%T","No XP is given when less than {amount} players are playing",client,GetConVarInt(minplayersXP));
			return;
		}

		internal_W3SetVar(EventArg1,awardedfromevent); //set event vars
		internal_W3SetVar(EventArg2,xp);
		internal_W3SetVar(EventArg3,gold);
		DoFwd_War3_Event(OnPreGiveXPGold,client); //fire event

		new addxp=	internal_W3GetVar(EventArg2); //retrieve possibly modified vars
		new addgold=internal_W3GetVar(EventArg3);

		if(addxp<0&&GetXP(client,GetRace(client)) +addxp<0){ //negative xp?
			addxp=-1*GetXP(client,GetRace(client));
		}


		new oldgold=War3_GetGold(client);
		if(oldgold >= W3GetMaxGold(99))
			addgold=0;
		new newgold=oldgold+addgold;
		new maxgold=W3GetMaxGold(client);
		if(newgold>maxgold)
		{
			newgold=maxgold;
			addgold=newgold-oldgold;
		}

		if(!IsFake)
		{
			SetXP(client,race,War3_GetXP(client,GetRace(client))+addxp);
			War3_SetGold(client,oldgold+addgold);
		}

		if(addxp>0&&addgold>0)
			War3_ChatMessage(client,"%T","You have gained {amount} XP and {amount} gold for {award}",client,addxp,addgold,awardedprintstring);
		else if(addxp>0)
			War3_ChatMessage(client,"%T","You have gained {amount} XP for {award}",client,addxp,awardedprintstring);
		else if(addgold>0){
			War3_ChatMessage(client,"%T","You have gained {amount} gold for {award}",client,addgold,awardedprintstring);
		}

		else if(addxp<0&&addgold<0)
			War3_ChatMessage(client,"%T","You have lost {amount} XP and {amount} gold for {award}",client,addxp,addgold,awardedprintstring);
		else if(addxp<0)
			War3_ChatMessage(client,"%T","You have lost {amount} XP for {award}",client,addxp,awardedprintstring);
		else if(addgold<0){
			War3_ChatMessage(client,"%T","You have lost {amount} gold for {award}",client,addgold,awardedprintstring);
		}

		//if(War3_GetLevel(client,race)!=W3GetRaceMaxLevel(race))
		W3DoLevelCheck(client); //in case they didnt level any skills

		DoFwd_War3_Event(OnPostGiveXPGold,client);
	}
	else{
		ShowChangeRaceMenu(client);
	}
	return;
}









#if (GGAMETYPE_JAILBREAK == JAILBREAK_OFF)
GiveKillXPCreds(client,playerkilled,bool:headshot,bool:melee,bool:IsFake)
{
	//PrintToChatAll("1");
	new race=GetRace(client);
	if(race>0){
		new killerlevel=War3_GetLevel(client,GetRace(client));
		new victimlevel=War3_GetLevel(playerkilled,GetRace(playerkilled));

		new killxp; //=W3GetKillXP(client,victimlevel-killerlevel);

		new String:RaceStr[16];
		GetRaceShortname(GetRace(playerkilled),RaceStr,sizeof(RaceStr));
		if(StrEqual(RaceStr, "dontplaythis"))
			killxp=W3GetKillXP(client);
		else
			killxp=W3GetKillXP(client,victimlevel-killerlevel);

		new addxp=killxp;
		if(headshot) {
			addxp+=((killxp*GetConVarInt(HeadshotXPCvar))/100);
			War3_EmitSoundToClient(client,headshotKiller);
			War3_EmitSoundToClient(client,headshotKiller);
		}
		if(melee) {
			addxp+=((killxp*GetConVarInt(MeleeXPCvar))/100);
			War3_EmitSoundToClient(client,meleeKiller);
			War3_EmitSoundToClient(client,meleeKiller);
			War3_EmitSoundToClient(playerkilled,meleeKilled);
			War3_EmitSoundToClient(playerkilled,meleeKilled);
		}

		new String:killaward[64];
		Format(killaward,sizeof(killaward),"%T","a kill",client);
		mySwitch=0;
		//W3GiveXPGold(client,XPAwardByKill,addxp,W3GetKillGold(),killaward,IsFake);
		TryToGiveXPGold(client,XPAwardByKill,addxp,W3GetKillGold(),killaward,IsFake);
	}
}

GiveAssistKillXP(client, bool:IsFake)
{
	if(ValidPlayer(client))
	{
		new addxp=((W3GetKillXP(client)*GetConVarInt(AssistKillXPCvar))/100);

		new String:helpkillaward[64];
		Format(helpkillaward,sizeof(helpkillaward),"%T","assisting a kill",client);
		mySwitch=0;
		//W3GiveXPGold(client,XPAwardByAssist,addxp,W3GetAssistGold(),helpkillaward,IsFake);
		TryToGiveXPGold(client,XPAwardByAssist,addxp,W3GetAssistGold(),helpkillaward,IsFake);
	}
}
#endif

bool:IsShortTerm(){
	if(GetConVarInt(Handle:internal_W3GetVar(hSaveEnabledCvar))==1)
		return false;
	else
		return true;
	//return GetConVarInt(Handle:War3_CreateNewSkill(hSaveEnabledCvar))?false:true;
	// not sure why the above does not work.. im going to temporary solve it.
	//return true;
}















public War3Source_Engine_XPGold_OnWar3Event(client)
{
	LevelCheck(client);
}


LevelCheck(client){
	new race=GetRace(client);
	if(race>0){
		new skilllevel;

		new ultminlevel=GetMinUltLevel();

		///skill or ult is more than what he can be? ie level 4 skill when he is only level 4...
		new curlevel=War3_GetLevel(client,race);
		new SkillCount = GetRaceSkillCount(race);
		for(new i=1;i<=SkillCount;i++){
			skilllevel=GetSkillLevelINTERNAL(client,race,i);
			if(!IsSkillUltimate(race,i))
			{
			// El Diablo: I want to be able to allow skills to reach maximum skill level via skill points.
			//            I do not want to put a limit on skill points because of the
			//            direction I'm going with my branch of the war3source.
				//NoSpendSkillsLimitCvar=FindConVar("war3_no_spendskills_limit");
				if (!GetConVarBool(NoSpendSkillsLimitCvar))
				{
					if(skilllevel*2>curlevel+1)
					{
						ClearSkillLevels(client,race);
						War3_ChatMessage(client,"%T","A skill is over the maximum level allowed for your current level, please reselect your skills",client);
						DoFwd_War3_Event(DoShowSpendskillsMenu,client);
					}
				}
			}
			else
			{
			// El Diablo: Currently keeping the limit on the ultimates
				if(skilllevel>0&&skilllevel*2+ultminlevel-1>curlevel+1)
				{
					ClearSkillLevels(client,race);
					War3_ChatMessage(client,"%T","A ultimate is over the maximum level allowed for your current level, please reselect your skills",client);
					DoFwd_War3_Event(DoShowSpendskillsMenu,client);
				}
			}
		}



		///seting xp or level recurses!!! SET XP FIRST!! or you will have a cascading level increment
		new keepchecking=true;
		while(keepchecking)
		{
			curlevel=War3_GetLevel(client,race);
			if(curlevel<GetRaceMaxLevel(race))
			{

				if(GetXP(client,race)>=W3GetReqXP(curlevel+1))
				{
					//PrintToChatAll("LEVEL %d xp %d reqxp=%d",curlevel,War3_GetXP(client,race),ReqLevelXP(curlevel+1));

					War3_ChatMessage(client,"%T","You are now level {amount}",client,War3_GetLevel(client,race)+1);

					new newxp=GetXP(client,race)-W3GetReqXP(curlevel+1);
					SetXP(client,race,newxp); //set xp first, else infinite level!!! else u set level xp is same and it tries to use that xp again

					SetLevel(client,race,War3_GetLevel(client,race)+1);



					//War3Source_SkillMenu(client);

					//PrintToChatAll("LEVEL %d  xp2 %d",War3_GetXP(client,race),ReqLevelXP(curlevel+1));
					if(IsPlayerAlive(client))
					{
						War3_EmitSoundToAll(levelupSound,client);
					}
					else{
						War3_EmitSoundToClient(client,levelupSound);
					}
					DoFwd_War3_Event(PlayerLeveledUp,client);
				}
				else{
					keepchecking=false;
				}
			}
			else{
				keepchecking=false;
			}

		}
		//  Don't bother players during game to level up. ???
		//  Request they level up after they die
		// some reason you can only level for every time you type spendskills..
		// doesnt level  you up on spawn.
		if(GetLevelsSpent(client,race)<War3_GetLevel(client,race))
		{
			if(!(IsPlayerAlive(client)))
				mySwitch=1;
			//DP("%i",mySwitch);
			if (mySwitch)
				DoFwd_War3_Event(DoShowSpendskillsMenu,client);

		}
	}
	mySwitch=1;
}


ClearSkillLevels(client,race)
{
	new SkillCount =GetRaceSkillCount(race);
	for(new i=1;i<=SkillCount;i++)
	{
		SetSkillLevelINTERNAL(client,race,i,0);
	}
}








