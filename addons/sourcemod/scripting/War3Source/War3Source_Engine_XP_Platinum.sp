// War3Source_Engine_XP_Platinum.sp

//
//
//
//
//
//
//				STILL NEEDS TRANSLATION BEFORE RELEASING SHOPMENU 3 !!!
//
//
//
//
//
//
//
//

//#assert GGAMEMODE == MODE_WAR3SOURCE

/*
public Plugin:myinfo=
{
	name="W3S Engine XP Platinum",
	author="El Diablo",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3evo.info/"
};*/

//new String:levelupSound[]="war3source/ItemLevelUp.mp3";

//new mySwitch=1;

///MAXLEVELXPDEFINED is in constants
//new REQXP[]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16};
//new KillXP[]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16};

//Requirement for next level is based on the item.



//Platinum
new Handle:MaxPlatinumCvar;

//new Handle:KillGoldCvar;
//new Handle:AssistGoldCvar;

// PLAYERS CAN ONLY GAIN XP FOR ITEMS ON REAL PEOPLE AND NOT BOTS
//
// NO BOTS ALLOWED ON PLATINUM SYSTEM

public War3Source_Engine_XP_Platinum_OnPluginStart()
{
	MaxPlatinumCvar=CreateConVar("war3_maxplatinum","1000000");

	//if(!HookEventEx("teamplay_round_win",War3Source_RoundOverEvent)) //usual win xp
	//{
		//PrintToServer("[War3Evo] Could not hook the teamplay_round_win event.");
	//}
}

//public OnMapStart()
//{
	//War3_PrecacheSound(levelupSound);
//}

//public War3Source_Engine_XP_Platinum_OnAddSound(sound_priority)
//{
	//if(sound_priority==PRIORITY_LOW)
	//{
		//War3_AddSound("War3Source_Engine_XP_Platinum",levelupSound);
	//}
//}

public bool:War3Source_Engine_XP_Platinum_InitNatives()
{
	//CreateNative("W3GetReqXP" ,NW3GetReqXP);
	//CreateNative("War3_ShowItemsXP",Native_War3_ShowXP);
	//CreateNative("W3GetKillXP",NW3GetKillXP);

	CreateNative("W3GetMaxPlatinum",NW3GetMaxPlatinum);
	//CreateNative("W3GetKillPlatinum",NW3GetKillGold);
	//CreateNative("W3GetAssistPlatinum",NW3GetAssistGold);
	CreateNative("W3GiveXP_Platinum",NW3GiveXP_Platinum);

	return true;
}
/*
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
*/
public NW3GetMaxPlatinum(Handle:plugin,numParams)
{
	return GetConVarInt(MaxPlatinumCvar);
}
//native W3GiveXP_Platinum(client,race,itemid,W3ItemSkills:itemskill=skill1,W3XPAwardedBy:awardreason=XPAwardByGeneric,xpamount=0,platinumamount=0,String:awardstringreason[]);
//W3GiveXP_Platinum(client,race,platinumamount=0,String:awardstringreason[],W3XPAwardedBy:awardreason=XPAwardByGeneric,itemid=-99,W3ItemSkills:itemskill=skill1,xpamount=0);
public NW3GiveXP_Platinum(Handle:plugin,args){
	new client=GetNativeCell(1);
	if(IsFakeClient(client))
		return;

	new race=GetNativeCell(2);
	new platinum=GetNativeCell(3);
	new String:strreason[64];
	GetNativeString(4,strreason,sizeof(strreason));
	new W3XPAwardedBy:awardby=W3XPAwardedBy:GetNativeCell(5);
	new item=GetNativeCell(6);
	new W3ItemSkills:itemskill=W3ItemSkills:GetNativeCell(7);
	new xp=GetNativeCell(8);


	TryToGiveXP_Platinum(client,race,item,itemskill,awardby,xp,platinum,strreason);
}

//	War3_GetCurrentItems(client,newrace,item1,item2,item3);



public War3Source_Engine_XP_Platinum_OnWar3Event(W3EVENT:event,client)
{
	if(!ValidPlayer(client))
		return;

	if(event==DoLevelCheck){
		War3Source_Engine_XP_Platinum_LevelCheck(client);
	}

	if(event==OnPostGiveXPGold && !IsFakeClient(client))
	{
		new W3XPAwardedBy:awardevent = internal_W3GetVar(EventArg1);
		if(awardevent==XPAwardByFakeKill || awardevent==XPAwardByFakeAssist){
			return;
		}
		new xp = internal_W3GetVar(EventArg2);
		// add some randomness
		xp=xp-GetRandomInt(0,xp);
		//new gold=internal_W3GetVar(EventArg3);

		//new itemid1,itemid2,itemid3;
		new race=GetRace(client);

		// dontplaythis job has too many level / xp bonus
		// Don't reward to GEMS or platinum!
		new String:TmpStr[16];
		GetRaceShortname(race,TmpStr,sizeof(TmpStr));
		if(StrEqual(TmpStr,"dontplaythis")) return;

		//new item2;
		//new item3;

		//War3_GetCurrentItems(client,race,itemid1,itemid2,itemid3);
		new itemid1=War3_GetItemId1(client,race);
		new itemid2=War3_GetItemId2(client,race);
		new itemid3=War3_GetItemId3(client,race);

		//War3_ChatMessage(0,"client %d race %d item1 %d item2 %d item3 %d",client,race,itemid1,itemid2,itemid3);

		new randomnum=GetRandomInt(1,6);
		//War3_ChatMessage(0,"randomnum %d GetClientItems3Owned %d",randomnum,GetClientItems3Owned(client));

		//new W3ItemSkills:skillX=skill1;
		//new W3ItemSkills:skillXX=skill2;
		switch(randomnum)
		{
			case 1:
			{
				if(War3_GetOwnsItem3(client,race,itemid1) && W3GetItem3maxlevel1(itemid1)>0)
					TryToGiveXP_Platinum(client,race,itemid1,skill1,awardevent,xp,0,"");
				else if(War3_GetOwnsItem3(client,race,itemid2) && W3GetItem3maxlevel1(itemid2)>0)
					TryToGiveXP_Platinum(client,race,itemid2,skill1,awardevent,xp,0,"");
				else if(War3_GetOwnsItem3(client,race,itemid3) && W3GetItem3maxlevel1(itemid3)>0)
					TryToGiveXP_Platinum(client,race,itemid3,skill1,awardevent,xp,0,"");
			}
			case 2:
			{
				if(War3_GetOwnsItem3(client,race,itemid2) && W3GetItem3maxlevel1(itemid2)>0)
					TryToGiveXP_Platinum(client,race,itemid2,skill1,awardevent,xp,0,"");
				else if(War3_GetOwnsItem3(client,race,itemid3) && W3GetItem3maxlevel1(itemid3)>0)
					TryToGiveXP_Platinum(client,race,itemid3,skill1,awardevent,xp,0,"");
				else if(War3_GetOwnsItem3(client,race,itemid1) && W3GetItem3maxlevel1(itemid1)>0)
					TryToGiveXP_Platinum(client,race,itemid1,skill1,awardevent,xp,0,"");
			}
			case 3:
			{
				if(War3_GetOwnsItem3(client,race,itemid3) && W3GetItem3maxlevel1(itemid3)>0)
					TryToGiveXP_Platinum(client,race,itemid3,skill1,awardevent,xp,0,"");
				else if(War3_GetOwnsItem3(client,race,itemid1) && W3GetItem3maxlevel1(itemid1)>0)
					TryToGiveXP_Platinum(client,race,itemid1,skill1,awardevent,xp,0,"");
				else if(War3_GetOwnsItem3(client,race,itemid2) && W3GetItem3maxlevel1(itemid2)>0)
					TryToGiveXP_Platinum(client,race,itemid2,skill1,awardevent,xp,0,"");
			}
			case 4:
			{
				if(War3_GetOwnsItem3(client,race,itemid1) && W3GetItem3maxlevel2(itemid1)>0)
					TryToGiveXP_Platinum(client,race,itemid1,skill2,awardevent,xp,0,"");
				else if(War3_GetOwnsItem3(client,race,itemid2) && W3GetItem3maxlevel2(itemid2)>0)
					TryToGiveXP_Platinum(client,race,itemid2,skill2,awardevent,xp,0,"");
				else if(War3_GetOwnsItem3(client,race,itemid3) && W3GetItem3maxlevel2(itemid3)>0)
					TryToGiveXP_Platinum(client,race,itemid3,skill2,awardevent,xp,0,"");
			}
			case 5:
			{
				if(War3_GetOwnsItem3(client,race,itemid2) && W3GetItem3maxlevel2(itemid2)>0)
					TryToGiveXP_Platinum(client,race,itemid2,skill2,awardevent,xp,0,"");
				else if(War3_GetOwnsItem3(client,race,itemid3) && W3GetItem3maxlevel2(itemid3)>0)
					TryToGiveXP_Platinum(client,race,itemid3,skill2,awardevent,xp,0,"");
				else if(War3_GetOwnsItem3(client,race,itemid1) && W3GetItem3maxlevel2(itemid1)>0)
					TryToGiveXP_Platinum(client,race,itemid1,skill2,awardevent,xp,0,"");
			}
			case 6:
			{
				if(War3_GetOwnsItem3(client,race,itemid3) && W3GetItem3maxlevel2(itemid3)>0)
					TryToGiveXP_Platinum(client,race,itemid3,skill2,awardevent,xp,0,"");
				else if(War3_GetOwnsItem3(client,race,itemid1) && W3GetItem3maxlevel2(itemid1)>0)
					TryToGiveXP_Platinum(client,race,itemid1,skill2,awardevent,xp,0,"");
				else if(War3_GetOwnsItem3(client,race,itemid2) && W3GetItem3maxlevel2(itemid2)>0)
					TryToGiveXP_Platinum(client,race,itemid2,skill2,awardevent,xp,0,"");
			}
		}
	}
}

War3Source_Engine_XP_Platinum_LevelCheck(client){
	new race=GetRace(client);

	if(race>0){
		//new skilllevel;

		if(ValidPlayer(client))
		{

			//new itemid1=War3_GetItemId1(client,race);
			//new itemid2=War3_GetItemId2(client,race);
			//new itemid3=War3_GetItemId3(client,race);

			new ItemsLoaded = W3GetItems3Loaded();
			new curlevel;
			new bool:keepchecking=true;

			decl String:ItemLevelName[32];
			decl String:CategoryName[32];
			decl String:ItemName[64];

			for(new itemnum=1;itemnum<=ItemsLoaded;itemnum++)
			{
				if(War3_GetOwnsItem3(client,race,itemnum))
				{
					// Category Name
					W3GetItem3Category(itemnum,CategoryName,31);
					W3GetItem3Name(itemnum,ItemName,63);

					// ITEM SKILL 1
					if(W3GetItem3maxlevel1(itemnum)>0)
					{
						W3GetItem3levelName(itemnum,ItemLevelName,31,skill1);
						///seting xp or level recurses!!! SET XP FIRST!! or you will have a cascading level increment
						keepchecking=true;
						while(keepchecking)
						{
							curlevel=War3_GetItemLevel(client,race,itemnum);
							if(curlevel<W3GetItem3maxlevel1(itemnum))
							{
								if(War3_GetItemXP(client,race,itemnum)>=W3GetReqXP(curlevel+1))
								{
									//PrintToChatAll("LEVEL %d xp %d reqxp=%d",curlevel,War3_GetXP(client,race),ReqLevelXP(curlevel+1));

									//War3_ChatMessage(client,"[%s] %s is now level %d",CategoryName,ItemLevelName,War3_GetItemLevel(client,race,itemnum)+1);

									new newxp=War3_GetItemXP(client,race,itemnum)-W3GetReqXP(curlevel+1);
									War3_SetItemXP(client,race,itemnum,newxp); //set xp first, else infinite level!!! else u set level xp is same and it tries to use that xp again

									War3_SetItemLevel(client,race,itemnum,War3_GetItemLevel(client,race,itemnum)+1);
									//PrintToChatAll("LEVEL %d  xp2 %d",War3_GetXP(client,race),ReqLevelXP(curlevel+1));
									if(IsPlayerAlive(client)){
										War3_EmitSoundToAll(levelupSound,client);
									}
									else{
										War3_EmitSoundToClient(client,levelupSound);
									}
									PlayerLeveledUpGem(client,ItemName,CategoryName,ItemLevelName,War3_GetItemLevel(client,race,itemnum)+1);
									//W3CreateEvent(PlayerLeveledUp,client);
								}
								else{
									keepchecking=false;
								}
							}
							else{
								keepchecking=false;
							}
						} // end of Keepchecking while statement  FOR SKILL 1
					} // end of W3GetItem3maxlevel1(itemnum)

					// ITEM SKILL 2
					if(W3GetItem3maxlevel2(itemnum)>0)
					{

						W3GetItem3levelName(itemnum,ItemLevelName,31,skill2);
						///seting xp or level recurses!!! SET XP FIRST!! or you will have a cascading level increment
						keepchecking=true;
						while(keepchecking)
						{
							curlevel=War3_GetItemLevel2(client,race,itemnum);
							if(curlevel<W3GetItem3maxlevel2(itemnum))
							{
								if(War3_GetItemXP2(client,race,itemnum)>=W3GetReqXP(curlevel+1))
								{
									//PrintToChatAll("LEVEL %d xp %d reqxp=%d",curlevel,War3_GetXP(client,race),ReqLevelXP(curlevel+1));

									//War3_ChatMessage(client,"[%s] %s is now level %d",CategoryName,ItemLevelName,War3_GetItemLevel2(client,race,itemnum)+1);

									new newxp=War3_GetItemXP2(client,race,itemnum)-W3GetReqXP(curlevel+1);
									War3_SetItemXP2(client,race,itemnum,newxp); //set xp first, else infinite level!!! else u set level xp is same and it tries to use that xp again

									War3_SetItemLevel2(client,race,itemnum,War3_GetItemLevel2(client,race,itemnum)+1);
									//PrintToChatAll("LEVEL %d  xp2 %d",War3_GetXP(client,race),ReqLevelXP(curlevel+1));
									if(IsPlayerAlive(client)){
										War3_EmitSoundToAll(levelupSound,client);
									}
									else{
										War3_EmitSoundToClient(client,levelupSound);
									}
									PlayerLeveledUpGem(client,ItemName,CategoryName,ItemLevelName,War3_GetItemLevel(client,race,itemnum)+1);
									//W3CreateEvent(PlayerLeveledUp,client);
								}
								else{
									keepchecking=false;
								}
							}
							else{
								keepchecking=false;
							}
						} // end of Keepchecking while statement  SKILL 2
					} // end of W3GetItem3maxlevel2(itemnum)
				} // end of GetOwnsItem3
			} // end of for loop
		} // end of ValidPlayer
	} // end of if race > 0
} // end of LevelCheck(client)



//fire event and allow addons to modify xp and platinum
bool:TryToGiveXP_Platinum(client,race,item,W3ItemSkills:itemskill,W3XPAwardedBy:awardedfromevent,xp,platinum,String:awardedprintstring[]){
	if(race>0 && !IsFakeClient(client)){

		//OnPreGiveXP_Platinum, //client, arg1,2,3=W3XPAwardedBy , xp, gold
		//OnPostGiveXP_Platinum, ///xp gold already given, same args as pre

		if(item!=-99 && ((itemskill==skill1 && W3GetItem3maxlevel1(item)<=0) || (itemskill==skill2 && W3GetItem3maxlevel2(item)<=0)))
			return false;

		internal_W3SetVar(EventArg1,awardedfromevent); //set event vars
		internal_W3SetVar(EventArg2,xp);
		internal_W3SetVar(EventArg3,platinum);
		DoFwd_War3_Event(OnPreGiveXP_Platinum,client); //fire event


		new addxp=internal_W3GetVar(EventArg2); //retrieve possibly modified vars
		new addplatinum=internal_W3GetVar(EventArg3);

		//War3_ChatMessage(0,"TryToGiveXP_Platinum itemskill %d",itemskill);
		//War3_SetItemXP(client,race,item,War3_GetItemXP(client,race,item)+1);
		//War3_SetItemXP2(client,race,item,War3_GetItemXP2(client,race,item)+10);
		new bool:DidXpSet=false;
		new String:ItemmName[32];
		strcopy(ItemmName,31,"");
		if(item!=-99)
		{
			if(itemskill==skill1)
			{
					if(W3GetItem3maxlevel1(item)==War3_GetItemLevel(client,race,item))
					{
						War3_SetItemXP(client,race,item,0);
					}
					else
					{
						new ItemXPstuff=War3_GetItemXP(client,race,item);
						if(addxp<0&&ItemXPstuff+addxp<0){ //negative xp?
							addxp=-1*ItemXPstuff;
						}
						ItemXPstuff=ItemXPstuff+addxp;
						DidXpSet=War3_SetItemXP(client,race,item,ItemXPstuff);
					}
			}
			else if(itemskill==skill2)
			{
					if(W3GetItem3maxlevel2(item)==War3_GetItemLevel2(client,race,item))
					{
						War3_SetItemXP2(client,race,item,0);
					}
					else
					{
						new ItemXPstuff=War3_GetItemXP2(client,race,item);
						if(addxp<0&&ItemXPstuff+addxp<0){  //negative xp?
						addxp=-1*ItemXPstuff;
						}
						ItemXPstuff=ItemXPstuff+addxp;
						DidXpSet=War3_SetItemXP2(client,race,item,ItemXPstuff);
					}
			}
			W3GetItem3Name(item,ItemmName,31);
		}

		new oldplatinum=War3_GetPlatinum(client);
		new newplatinum=oldplatinum+addplatinum;
		new maxplatinum=GetConVarInt(MaxPlatinumCvar);
		if(newplatinum>maxplatinum)
		{
			newplatinum=maxplatinum;
			addplatinum=newplatinum-oldplatinum;
		}
		War3_SetPlatinum(client,oldplatinum+addplatinum);
		if(addxp>0&&addplatinum>0&&DidXpSet)
			War3_ChatMessage(client,"[%s] gained %d XP and %d platinum %s",ItemmName,addxp,addplatinum,awardedprintstring);
		else if(addxp>0&&DidXpSet)
			War3_ChatMessage(client,"[%s] gained %d XP %s",ItemmName,addxp,awardedprintstring);
		else if(addplatinum>0&&DidXpSet){
			War3_ChatMessage(client,"[%s] gained %d platinum %s",ItemmName,addplatinum,awardedprintstring);
		}
		else if(addplatinum>0&&!DidXpSet){
			War3_ChatMessage(client,"You gained %d platinum %s",addplatinum,awardedprintstring);
		}

		else if(addxp<0&&addplatinum<0&&DidXpSet)
			War3_ChatMessage(client,"[%s] lost %d XP and %d platinum %s",ItemmName,addxp,addplatinum,awardedprintstring);
		else if(addxp<0&&DidXpSet)
			War3_ChatMessage(client,"[%s] lost %d XP %s",ItemmName,addxp,awardedprintstring);
		else if(addplatinum<0&&DidXpSet){
			War3_ChatMessage(client,"[%s] lost %d platinum %s",ItemmName,addplatinum,awardedprintstring);
		}
		else if(addplatinum<0&&!DidXpSet){
			War3_ChatMessage(client,"You lost %d platinum %s",addplatinum,awardedprintstring);
		}

		//if(War3_GetLevel(client,race)!=W3GetRaceMaxLevel(race))
		W3DoLevelCheck(client); //in case they didnt level any skills

		DoFwd_War3_Event(OnPostGiveXP_Platinum,client);

		return true;
	}
	return false;
}

//War3_ChatMessage(client,"[%s] %s is now level %d",CategoryName,ItemLevelName,War3_GetItemLevel(client,race,itemnum)+1);
//PlayerLeveledUpGem(CategoryName,ItemLevelName,War3_GetItemLevel(client,race,itemnum)+1)
PlayerLeveledUpGem(client,String:TheItemName[64],String:CatName[32],String:ItemName[32],ItemLevel)
{
		new String:name[32];
		GetClientName(client, name, sizeof(name));
		new String:racename[32];
		new race = GetRace(client);

		//new level = War3_GetLevel(client, race);

#if (GGAMETYPE == GGAME_TF2)
#if (GGAMETYPE2 == GGAME_TF2_NORMAL)
		AttachThrowAwayParticle(client, "achieved", NULL_VECTOR, "partyhat", 5.0);
		AttachThrowAwayParticle(client, "bday_1balloon", NULL_VECTOR, "partyhat", 5.0);
		AttachThrowAwayParticle(client, "bday_balloon01", NULL_VECTOR, "partyhat", 5.0);
		AttachThrowAwayParticle(client, "bday_balloon02", NULL_VECTOR, "partyhat", 5.0);
#elseif (GGAMETYPE2 == GGAME_PVM)
		if(!IsFakeClient(client))
		{
			AttachThrowAwayParticle(client, "achieved", NULL_VECTOR, "partyhat", 5.0);
			AttachThrowAwayParticle(client, "bday_1balloon", NULL_VECTOR, "partyhat", 5.0);
			AttachThrowAwayParticle(client, "bday_balloon01", NULL_VECTOR, "partyhat", 5.0);
			AttachThrowAwayParticle(client, "bday_balloon02", NULL_VECTOR, "partyhat", 5.0);
		}
#elseif (GGAMETYPE2 == GGAME_MVM)
		if(!IsFakeClient(client))
		{
			AttachThrowAwayParticle(client, "achieved", NULL_VECTOR, "partyhat", 5.0);
			AttachThrowAwayParticle(client, "bday_1balloon", NULL_VECTOR, "partyhat", 5.0);
			AttachThrowAwayParticle(client, "bday_balloon01", NULL_VECTOR, "partyhat", 5.0);
			AttachThrowAwayParticle(client, "bday_balloon02", NULL_VECTOR, "partyhat", 5.0);
		}
#endif
#endif

#if (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
		new level = War3_GetLevel(client, race);
		CSParticle(client, level);
#endif
		for(new i=1;i<=MaxClients;i++){
			if(ValidPlayer(i)){
				GetRaceName(race, racename, sizeof(racename));
				War3_ChatMessage(i,"%s leveled {lightgreen}%s|%s|%s{default} to {lightgreen}%d",name,CatName,TheItemName,ItemName,ItemLevel);
			}
		}
}



//public OnWar3Event(W3EVENT:event,client){
//	if(event==DoLevelCheck){
//		LevelCheck(client);
//	}
//}



/*
LevelCheck(client){
	new race=War3_GetRace(client);
	if(race>0){
		new skilllevel;

		new ultminlevel=W3GetMinUltLevel();

		///skill or ult is more than what he can be? ie level 4 skill when he is only level 4...
		new curlevel=War3_GetLevel(client,race);
		new SkillCount = War3_GetRaceSkillCount(race);
		for(new i=1;i<=SkillCount;i++){
			skilllevel=GetSkillLevelINTERNAL(client,race,i);
			if(!IsSkillUltimate(race,i))
			{
			// El Diablo: I want to be able to allow skills to reach maximum skill level via skill points.
			//            I do not want to put a limit on skill points because of the
			//            direction I'm going with my branch of the war3source.
				NoSpendSkillsLimitCvar=FindConVar("war3_no_spendskills_limit");
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
				if(skilllevel>0&&skilllevel*2+ultminlevel-1>curlevel+1){
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
			if(curlevel<W3GetRaceMaxLevel(race))
			{

				if(War3_GetXP(client,race)>=W3GetReqXP(curlevel+1))
				{
					//PrintToChatAll("LEVEL %d xp %d reqxp=%d",curlevel,War3_GetXP(client,race),ReqLevelXP(curlevel+1));

					War3_ChatMessage(client,"%T","You are now level {amount}",client,War3_GetLevel(client,race)+1);

					new newxp=War3_GetXP(client,race)-W3GetReqXP(curlevel+1);
					War3_SetXP(client,race,newxp); //set xp first, else infinite level!!! else u set level xp is same and it tries to use that xp again

					SetLevel(client,race,War3_GetLevel(client,race)+1);



					//War3Source_SkillMenu(client);

					//PrintToChatAll("LEVEL %d  xp2 %d",War3_GetXP(client,race),ReqLevelXP(curlevel+1));
					if(IsPlayerAlive(client)){
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
		if(W3GetLevelsSpent(client,race)<War3_GetLevel(client,race)){
			if(!(IsPlayerAlive(client)))
				mySwitch=1;
			//DP("%i",mySwitch);
			if (mySwitch)
				DoFwd_War3_Event(DoShowSpendskillsMenu,client);

		}
	}
	mySwitch=1;
}


ClearSkillLevels(client,race){
	new SkillCount =War3_GetRaceSkillCount(race);
	for(new i=1;i<=SkillCount;i++){
		SetSkillLevelINTERNAL(client,race,i,0);
	}
}
*/
