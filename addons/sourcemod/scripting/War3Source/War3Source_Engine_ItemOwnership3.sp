// War3Source_Engine_ItemOwnership3.sp

//#assert GGAMEMODE == MODE_WAR3SOURCE

new Handle:g_OnItemSkillLevelChangedHandle;

new bool:playerOwnsItem3[MAXPLAYERSCUSTOM][MAXRACES][MAXITEMS3];
new Float:playerOwnsItem3_cooldown_time[MAXPLAYERSCUSTOM][MAXRACES][MAXITEMS3];
/*
enum W3ItemInfo
{
	//item1
	item1=0,
	item1level1,
	item1xp1,
	item1level2,
	item1xp2,
	//item2
	item2=0,
	item2level1,
	item2xp1,
	item2level2,
	item2xp2,
	//item3
	item3=0,
	item3level1,
	item3xp1,
	item3level2,
	item3xp2,
}
*/
new playerOwnsItem3info[MAXPLAYERSCUSTOM][MAXRACES][W3ItemInfo];

//new playerOwnsItem3level[MAXPLAYERSCUSTOM][MAXRACES][MAXITEMS3];
//new playerOwnsItem3xp[MAXPLAYERSCUSTOM][MAXRACES][MAXITEMS3];
//new playerOwnsItem3level2[MAXPLAYERSCUSTOM][MAXRACES][MAXITEMS3];
//new playerOwnsItem3xp2[MAXPLAYERSCUSTOM][MAXRACES][MAXITEMS3];

//new playerOwnsItemExpireTime[MAXPLAYERSCUSTOM][MAXITEMS];
Handle g_OnItemPurchaseHandle3;
Handle g_OnItemLostHandle3;

//new Handle:hitemRestrictionCvar3;
Handle hCvarMaxShopitems3;

/*
public Plugin:myinfo=
{
	name="W3S Engine Item3 Ownership",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};
*/


public War3Source_Engine_ItemOwnership3_OnPluginStart()
{
	//hitemRestrictionCvar3=CreateConVar("war3_item3_restrict","","Disallow items in shopmenu, shortname separated by comma only ie:'claw,orb'");
	hCvarMaxShopitems3=CreateConVar("war3_max_shopitems3","3");
}

public bool:War3Source_Engine_ItemOwnership3_InitNativesForwards()
{
	g_OnItemPurchaseHandle3=CreateGlobalForward("OnItem3Purchase",ET_Ignore,Param_Cell,Param_Cell,Param_Cell);
	g_OnItemLostHandle3=CreateGlobalForward("OnItem3Lost",ET_Ignore,Param_Cell,Param_Cell,Param_Cell);
	g_OnItemSkillLevelChangedHandle=CreateGlobalForward("OnItemSkillLevelChanged",ET_Ignore,Param_Cell,Param_Cell,Param_Cell,Param_Cell);

	return true;
}

public bool:War3Source_Engine_ItemOwnership3_InitNatives()
{
	CreateNative("War3_GetItemId1",NWar3_GetItemId1);
	CreateNative("War3_GetItemId2",NWar3_GetItemId2);
	CreateNative("War3_GetItemId3",NWar3_GetItemId3);

	CreateNative("War3_GetOwnsItem3",NWar3_GetOwnsItem3);
	CreateNative("War3_SetOwnsItem3",NWar3_SetOwnsItem3);

	CreateNative("War3_Item3CooldownMGR",NWar3_Item3CooldownMGR);
	CreateNative("War3_Item3NotInCooldown",NWar3_Item3NotInCooldown);
	CreateNative("War3_Item3CooldownTimeRemaining",NWar3_Item3CooldownTimeRemaining);

	CreateNative("War3_GetTotalItemLevels",NWar3_GetTotalItemLevels);

	CreateNative("War3_SetItemLevel",NWar3_SetItemLevel);
	CreateNative("War3_GetItemLevel",NWar3_GetItemLevel);
	CreateNative("War3_SetItemXP",NWar3_SetItemXP);
	CreateNative("War3_GetItemXP",NWar3_GetItemXP);

	CreateNative("War3_SetItemLevel2",NWar3_SetItemLevel2);
	CreateNative("War3_GetItemLevel2",NWar3_GetItemLevel2);
	CreateNative("War3_SetItemXP2",NWar3_SetItemXP2);
	CreateNative("War3_GetItemXP2",NWar3_GetItemXP2);



	CreateNative("W3IsItem3DisabledGlobal",NW3IsItem3DisabledGlobal);
	CreateNative("W3IsItem3DisabledForRace",NW3IsItem3DisabledForRace);

	//CreateNative("W3GetItem3ExpireTime",NW3GetItem3ExpireTime);
	//CreateNative("W3SetItem3ExpireTime",NW3SetItem3ExpireTime);


	CreateNative("GetClientItems3Owned",NGetClientItems3Owned);
	CreateNative("GetMaxShopitems3PerPlayer",NGetMaxShopitems3PerPlayer);

	return true;
}
////War3_CooldownMGR(client,Float:cooldownTime,raceid,item3Num, bool:resetOnSpawn=true,bool:printMsgOnExpireByTime=true);
//War3_Item3CooldownMGR
public NWar3_Item3CooldownMGR(Handle:plugin,numParams)
{
	new client = GetNativeCell(1);
	new Float:cooldownTime= GetNativeCell(2);
	new raceid = GetNativeCell(3);
	new item3Num = GetNativeCell(4); ///can use skill numbers
	playerOwnsItem3_cooldown_time[client][raceid][item3Num]=GetEngineTime()+cooldownTime;
}

bool:Interal_War3_Item3NotInCooldown(client,raceid,item)
{
	return GetEngineTime()>playerOwnsItem3_cooldown_time[client][raceid][item];
}

public NWar3_Item3CooldownTimeRemaining(Handle:plugin,numParams)
{
	new client = GetNativeCell(1);
	new raceid = GetNativeCell(2);
	new item = GetNativeCell(3);
	if(!Interal_War3_Item3NotInCooldown(client,raceid,item) && playerOwnsItem3_cooldown_time[client][raceid][item]>1.0)
	{
		return RoundToCeil(playerOwnsItem3_cooldown_time[client][raceid][item]-GetEngineTime());
	}
	else
	{
		return 0;
	}
}

public NWar3_Item3NotInCooldown(Handle:plugin,numParams)
{
	return Interal_War3_Item3NotInCooldown(GetNativeCell(1),GetNativeCell(2),GetNativeCell(3));
}

public NWar3_GetItemId1(Handle:plugin,numParams){
	new client = GetNativeCell(1);
	new race = GetNativeCell(2);
	return playerOwnsItem3info[client][race][item1];
}
public NWar3_GetItemId2(Handle:plugin,numParams){
	new client = GetNativeCell(1);
	new race = GetNativeCell(2);
	return playerOwnsItem3info[client][race][item2];
}
public NWar3_GetItemId3(Handle:plugin,numParams){
	new client = GetNativeCell(1);
	new race = GetNativeCell(2);
	return playerOwnsItem3info[client][race][item3];
}

// War3_SetItemXP(client, race, item, newxp);
public NWar3_SetItemXP(Handle:plugin,numParams){
	new client = GetNativeCell(1);
	new race = GetNativeCell(2);
	new item = GetNativeCell(3);
	new xp = GetNativeCell(4);
	//War3_ChatMessage(0,"before client>0 && etc checks");
	if (client > 0 && client <= MaxClients && race > 0 && race < MAXRACES && item < MAXITEMS3)
	{
		//playerOwnsItem3xp[client][race][item]=GetNativeCell(4);

		if(playerOwnsItem3info[client][race][item1]==item)
		{
			playerOwnsItem3info[client][race][item1xp1]=xp;
			//War3_ChatMessage(0,"playerOwnsItem3info[client][race][item1]==item");
			return true;
		}
		else if(playerOwnsItem3info[client][race][item2]==item)
		{
			playerOwnsItem3info[client][race][item2xp1]=xp;
			//War3_ChatMessage(0,"playerOwnsItem3info[client][race][item2]==item");
			return true;
		}
		else if(playerOwnsItem3info[client][race][item3]==item)
		{
			playerOwnsItem3info[client][race][item3xp1]=xp;
			//War3_ChatMessage(0,"playerOwnsItem3info[client][race][item3]==item");
			return true;
		}
	}
	//War3_ChatMessage(0,"playerOwnsItem3info[client][race][XXX] FALSE");
	return false;
}
// War3_GetItemXP(client, race, item);
public NWar3_GetItemXP(Handle:plugin,numParams){
	new client = GetNativeCell(1);
	new race = GetNativeCell(2);
	new item = GetNativeCell(3);
	if (client > 0 && client <= MaxClients && race > 0 && race < MAXRACES && item < MAXITEMS3)
	{
		if(playerOwnsItem3info[client][race][item1]==item)
		{
			return playerOwnsItem3info[client][race][item1xp1];
		}
		else if(playerOwnsItem3info[client][race][item2]==item)
		{
			return playerOwnsItem3info[client][race][item2xp1];
		}
		else if(playerOwnsItem3info[client][race][item3]==item)
		{
			return playerOwnsItem3info[client][race][item3xp1];
		}
	}
	return 0;
}

// War3_SetItemXP2(client, race, item, newxp);
public NWar3_SetItemXP2(Handle:plugin,numParams){
	new client = GetNativeCell(1);
	new race = GetNativeCell(2);
	new item = GetNativeCell(3);
	new xp = GetNativeCell(4);
	if (client > 0 && client <= MaxClients && race > 0 && race < MAXRACES && item < MAXITEMS3)
	{
		//playerOwnsItem3xp[client][race][item]=GetNativeCell(4);

		if(playerOwnsItem3info[client][race][item1]==item)
		{
			playerOwnsItem3info[client][race][item1xp2]=xp;
			return true;
		}
		else if(playerOwnsItem3info[client][race][item2]==item)
		{
			playerOwnsItem3info[client][race][item2xp2]=xp;
			return true;
		}
		else if(playerOwnsItem3info[client][race][item3]==item)
		{
			playerOwnsItem3info[client][race][item3xp2]=xp;
			return true;
		}
	}
	return false;
}
// War3_GetItemXP2(client, race, item);
public NWar3_GetItemXP2(Handle:plugin,numParams){
	new client = GetNativeCell(1);
	new race = GetNativeCell(2);
	new item = GetNativeCell(3);
	if (client > 0 && client <= MaxClients && race > 0 && race < MAXRACES && item < MAXITEMS3)
	{
		if(playerOwnsItem3info[client][race][item1]==item)
		{
			return playerOwnsItem3info[client][race][item1xp2];
		}
		else if(playerOwnsItem3info[client][race][item2]==item)
		{
			return playerOwnsItem3info[client][race][item2xp2];
		}
		else if(playerOwnsItem3info[client][race][item3]==item)
		{
			return playerOwnsItem3info[client][race][item3xp2];
		}
	}
	return 0;
}

InternalOnItemSkillLevelChanged(client,race,item,level)
{
	if(ValidPlayer(client))
	{
		Call_StartForward(g_OnItemSkillLevelChangedHandle);
		Call_PushCell(client);
		Call_PushCell(race);
		Call_PushCell(item);
		Call_PushCell(level);
		Call_Finish(dummy);
	}
}

public NWar3_SetItemLevel(Handle:plugin,numParams){
	new client = GetNativeCell(1);
	new race = GetNativeCell(2);
	new item = GetNativeCell(3);
	new level = GetNativeCell(4);
	if (client > 0 && client <= MaxClients && race > 0 && race < MAXRACES && item < MAXITEMS3)
	{
		//new String:name[32];
		//GetPluginFilename(plugin,name,sizeof(name));
		//DP("SETLEVEL %d %s",GetNativeCell(3),name);
		//playerOwnsItem3level[client][race][item]=GetNativeCell(4);
		if(playerOwnsItem3info[client][race][item1]==item)
		{
			// if oldlevel!=level
			if(playerOwnsItem3info[client][race][item1level1]!=level)
			{
				playerOwnsItem3info[client][race][item1level1]=level;
				InternalOnItemSkillLevelChanged(client,race,item,level);

			}
		}
		else if(playerOwnsItem3info[client][race][item2]==item)
		{
			// if oldlevel!=level
			if(playerOwnsItem3info[client][race][item2level1]!=level)
			{
				playerOwnsItem3info[client][race][item2level1]=level;
				InternalOnItemSkillLevelChanged(client,race,item,level);
			}
		}
		else if(playerOwnsItem3info[client][race][item3]==item)
		{
			// if oldlevel!=level
			if(playerOwnsItem3info[client][race][item3level1]!=level)
			{
				playerOwnsItem3info[client][race][item3level1]=level;
				InternalOnItemSkillLevelChanged(client,race,item,level);
			}
		}
	}
}


public NWar3_SetItemLevel2(Handle:plugin,numParams){
	new client = GetNativeCell(1);
	new race = GetNativeCell(2);
	new item = GetNativeCell(3);
	new level = GetNativeCell(4);
	if (client > 0 && client <= MaxClients && race > 0 && race < MAXRACES && item < MAXITEMS3)
	{
		//new String:name[32];
		//GetPluginFilename(plugin,name,sizeof(name));
		//DP("SETLEVEL %d %s",GetNativeCell(3),name);
		//playerOwnsItem3level[client][race][item]=GetNativeCell(4);
		if(playerOwnsItem3info[client][race][item1]==item)
		{
			// if oldlevel!=level
			if(playerOwnsItem3info[client][race][item1level2]!=level)
			{
				playerOwnsItem3info[client][race][item1level2]=level;
				InternalOnItemSkillLevelChanged(client,race,item,level);
			}
		}
		else if(playerOwnsItem3info[client][race][item2]==item)
		{
			// if oldlevel!=level
			if(playerOwnsItem3info[client][race][item2level2]!=level)
			{
				playerOwnsItem3info[client][race][item2level2]=level;
				InternalOnItemSkillLevelChanged(client,race,item,level);
			}
		}
		else if(playerOwnsItem3info[client][race][item3]==item)
		{
			// if oldlevel!=level
			if(playerOwnsItem3info[client][race][item3level2]!=level)
			{
				playerOwnsItem3info[client][race][item3level2]=level;
				InternalOnItemSkillLevelChanged(client,race,item,level);
			}
		}
	}
}

public NWar3_GetTotalItemLevels(Handle:plugin,numParams){
	new client = GetNativeCell(1);
	new race = GetNativeCell(2);
	new item = GetNativeCell(3);
	return (Internal_NWar3_GetItemLevel1(client,race,item) + Internal_NWar3_GetItemLevel2(client,race,item));
}

public NWar3_GetItemLevel(Handle:plugin,numParams){
	new client = GetNativeCell(1);
	new race = GetNativeCell(2);
	new item = GetNativeCell(3);
	return Internal_NWar3_GetItemLevel1(client,race,item);
}


public NWar3_GetItemLevel2(Handle:plugin,numParams){
	new client = GetNativeCell(1);
	new race = GetNativeCell(2);
	new item = GetNativeCell(3);
	return Internal_NWar3_GetItemLevel2(client,race,item);
}


Internal_NWar3_GetItemLevel1(client,race,item)
{
	if (client > 0 && client <= MaxClients && race > 0 && race < MAXRACES && item < MAXITEMS3)
	{
		//DP("%d",p_level[client][race]);
		//new level=playerOwnsItem3level[client][race][item];
		//if(level>W3GetRaceMaxLevel(race))
			//level=W3GetRaceMaxLevel(race);
		if(playerOwnsItem3info[client][race][item1]==item)
		{
			return playerOwnsItem3info[client][race][item1level1];
		}
		else if(playerOwnsItem3info[client][race][item2]==item)
		{
			return playerOwnsItem3info[client][race][item2level1];
		}
		else if(playerOwnsItem3info[client][race][item3]==item)
		{
			return playerOwnsItem3info[client][race][item3level1];
		}
	}
	//else
	return 0;
}


Internal_NWar3_GetItemLevel2(client,race,item)
{
	if (client > 0 && client <= MaxClients && race > 0 && race < MAXRACES && item < MAXITEMS3)
	{
		//DP("%d",p_level[client][race]);
		//new level=playerOwnsItem3level[client][race][item];
		//if(level>W3GetRaceMaxLevel(race))
			//level=W3GetRaceMaxLevel(race);
		if(playerOwnsItem3info[client][race][item1]==item)
		{
			return playerOwnsItem3info[client][race][item1level2];
		}
		else if(playerOwnsItem3info[client][race][item2]==item)
		{
			return playerOwnsItem3info[client][race][item2level2];
		}
		else if(playerOwnsItem3info[client][race][item3]==item)
		{
			return playerOwnsItem3info[client][race][item3level2];
		}
	}
	//else
	return 0;
}



public NW3IsItem3DisabledGlobal(Handle:plugin,numParams)
{
	return false;
	/*
	new itemid=GetNativeCell(1);
	decl String:itemShort[16];
	W3GetItem3Shortname(itemid,itemShort,16);

	decl String:cvarstr[100];
	decl String:exploded[MAXITEMS][16];
	decl num;
	GetConVarString(hitemRestrictionCvar3,cvarstr,sizeof(cvarstr));
	if(strlen(cvarstr)>0){
		num=ExplodeString(cvarstr,",",exploded,MAXITEMS,16);
		for(new i=0;i<num;i++){
			//PrintToServer("'%s' compared to: '%s' num%d",exploded[i],itemShort,num);
			if(StrEqual(exploded[i],itemShort,false)){
				//PrintToServer("TRUE");
				return true;
			}
		}
	}
	return false;
	*/
}
public NW3IsItem3DisabledForRace(Handle:plugin,numParams)
{
	return false;
	/*
	new raceid=GetNativeCell(1);
	new itemid=GetNativeCell(2);
	if(raceid>0){
		decl String:itemShort[16];
		W3GetItem3Shortname(itemid,itemShort,sizeof(itemShort));

		decl String:cvarstr[100];
		decl String:exploded[MAXITEMS][16];

		W3GetRaceItem3RestrictionsStr(raceid,cvarstr,sizeof(cvarstr));

		new num;
		if(strlen(cvarstr)>0){
			num=ExplodeString(cvarstr,",",exploded,MAXITEMS,16);
			for(new i=0;i<num;i++){
				//PrintToServer("'%s' compared to: '%s' num%d",exploded[i],itemShort,num);
				if(StrEqual(exploded[i],itemShort,false)){
					//PrintToServer("TRUE");
					return true;
				}
			}
		}
	}
	return false;*/
}

/*
public NW3GetItem3ExpireTime(Handle:plugin,numParams)
{

	return _:playerOwnsItemExpireTime[GetNativeCell(1)][GetNativeCell(2)];

}
public NW3SetItem3ExpireTime(Handle:plugin,numParams)
{
	new client=GetNativeCell(1);
	new item=GetNativeCell(2);
	new time=GetNativeCell(3);
	//new Handle:hDB=W3GetDBHandle();
	//if(hDB){

	playerOwnsItemExpireTime[client][item]=time;
}

*/













public War3Source_Engine_ItemOwnership3_OnWar3Event(W3EVENT:event,client)
{
	if(event==DoForwardClientBoughtItem3){
		new itemid=W3GetVar(TheItemBoughtOrLost);
		new race=W3GetVar(TheRaceItemBoughtOrLost);
		War3_SetOwnsItem3(client,race,itemid,true);

		Call_StartForward(g_OnItemPurchaseHandle3);
		Call_PushCell(client);
		Call_PushCell(race);
		Call_PushCell(itemid);
		Call_Finish(dummy);


	}
	if(event==DoForwardClientLostItem3){
		new itemid=W3GetVar(TheItemBoughtOrLost);
		new race=W3GetVar(TheRaceItemBoughtOrLost);
		//DP("NO LONGER OWNS %d",itemid);

		War3_SetItemLevel(client, race, itemid, 0);
		War3_SetItemLevel2(client, race, itemid, 0);
		War3_SetItemXP(client, race, itemid, 0);
		War3_SetItemXP2(client, race, itemid, 0);

		War3_SetOwnsItem3(client,race,itemid,false);

		Call_StartForward(g_OnItemLostHandle3);
		Call_PushCell(client);
		Call_PushCell(race);
		Call_PushCell(itemid);
		Call_Finish(dummy);
	}
	if(event==DoCheckRestrictedItems){
		CheckForRestrictedItemsOnRace3(client);
	}
}



CheckForRestrictedItemsOnRace3(client)
{
	client=client+0; //silence warning
	/*new ItemsLoaded = W3GetItems3Loaded();
	for(new itemid=1;itemid<=ItemsLoaded;itemid++){
		if(War3_GetOwnsItem3(client,itemid)){
			new race=War3_GetRace(client);
			if(W3IsItemDisabledForRace(race,itemid)){

				new String:racename[32];
				GetRaceName(race,racename,sizeof(racename));

				new String:itemname[64];
				W3GetItemName(itemid,itemname,sizeof(itemname));   //FAKE
				War3_ChatMessage(client,"%T","{itemname} is restricted on race {racename}, item has been removed",client,itemname,racename);

				W3SetVar(TheItemBoughtOrLost,itemid);
				DoFwd_War3_Event(DoForwardClientLostItem,client); //old item

			}

		}
	}*/
}


// This needs to be revised to include ALL races:
public NGetClientItems3Owned(Handle:h,n){
	new client=GetNativeCell(1);
	new num=0;
	new ItemsLoaded = W3GetItems3Loaded();
	new race=GetRace(client);
	for(new i=1;i<=ItemsLoaded;i++){
		if(War3_GetOwnsItem3(client,race,i)){
			num++;
		}
	}
	//DP("ret %d loaded %d",num,W3GetItems3Loaded());
	return num;
}
public NGetMaxShopitems3PerPlayer(Handle:h,n){
	return GetConVarInt(hCvarMaxShopitems3);
}

//native War3_GetOwnsItem3(client,race,item);
public NWar3_GetOwnsItem3(Handle:plugin,numParams)
{
	if (ValidPlayer(GetNativeCell(1)))
	{
		return _:playerOwnsItem3[GetNativeCell(1)][GetNativeCell(2)][GetNativeCell(3)];
	}
	else
		return false;

}

CyclethrutheItems(client,race)
{
	//War3_ChatMessage(0,"CycleThruTheItems");
	playerOwnsItem3info[client][race][item1]=0;
	playerOwnsItem3info[client][race][item2]=0;
	playerOwnsItem3info[client][race][item3]=0;
	new ItemsLoaded = W3GetItems3Loaded();
	new num=1;
	for(new i=1;i<=ItemsLoaded;i++){
		if(War3_GetOwnsItem3(client,race,i)){
			PushTheItem(client,race,i);
			num++;
		}
		if(num>3)
			break;
	}
}

bool:PushTheItem(client,race,itemidd)
{
	//War3_ChatMessage(0,"pushTheItem");
	if(playerOwnsItem3info[client][race][item1]==0)
	{
		playerOwnsItem3info[client][race][item1]=itemidd;
		return true;
	} else if(playerOwnsItem3info[client][race][item2]==0)
	{
		playerOwnsItem3info[client][race][item2]=itemidd;
		return true;
	} else if(playerOwnsItem3info[client][race][item3]==0)
	{
		playerOwnsItem3info[client][race][item3]=itemidd;
		return true;
	}
	return false;
}


public NWar3_SetOwnsItem3(Handle:plugin,numParams)
{
	new client=GetNativeCell(1);
	new race=GetNativeCell(2);
	new itemid=GetNativeCell(3);
	new bool:old=playerOwnsItem3[client][race][itemid];
	playerOwnsItem3[client][race][itemid]=bool:GetNativeCell(4);
	if(old!=playerOwnsItem3[client][race][itemid]){

	// having this if statement may make it push the same item 2 or 3 times.. causing doubles / triples.
	//if(PushTheItem(client,race,itemid)==false)
	CyclethrutheItems(client,race);

	switch(playerOwnsItem3[client][race][itemid]){
			case false:{
				Call_StartForward(g_OnItemLostHandle3);
				Call_PushCell(client);
				Call_PushCell(race);
				Call_PushCell(itemid);
				Call_Finish(dummy);
			}
			case true:{
				Call_StartForward(g_OnItemPurchaseHandle3);
				Call_PushCell(client);
				Call_PushCell(race);
				Call_PushCell(itemid);
				Call_Finish(dummy);
			}
			default: {
				ThrowNativeError(0,"set owns item3 is not true or false");
			}
		}
	}
}
