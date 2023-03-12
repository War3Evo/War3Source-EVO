// War3Source_Engine_ItemOwnership.sp

//
//
//
//
//
//
//
//
//  START TRANSLATING HERE DOWN NEXT 3/12/2023
//
//
//
//
//
//
//
//
//

//#assert GGAMEMODE == MODE_WAR3SOURCE


new bool:playerOwnsItem[MAXPLAYERSCUSTOM][MAXITEMS];
new bool:RestoreItemsFromDeath_playerOwnsItem[MAXPLAYERSCUSTOM][MAXITEMS+1];
new Handle:g_OnItemPurchaseHandle;
new Handle:g_OnItemLostHandle;

new Handle:hitemRestrictionCvar;

new Handle:hCvarMaxShopitems;
/*
public Plugin:myinfo=
{
	name="W3S Engine Item Ownership",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};
*/

public War3Source_Engine_ItemOwnership_OnPluginStart()
{
	hitemRestrictionCvar=CreateConVar("war3_item_restrict","","Disallow items in shopmenu, shortname separated by comma only ie:'claw,orb'");
	hCvarMaxShopitems=CreateConVar("war3_max_shopitems","2");
}

public bool:War3Source_Engine_ItemOwnership_InitNativesForwards()
{
	g_OnItemPurchaseHandle=CreateGlobalForward("OnItemPurchase",ET_Ignore,Param_Cell,Param_Cell);
	g_OnItemLostHandle=CreateGlobalForward("OnItemLost",ET_Ignore,Param_Cell,Param_Cell);

	return true;
}

public bool:War3Source_Engine_ItemOwnership_InitNatives()
{
	CreateNative("War3_RestoreItemsFromDeath",NWar3_RestoreItemsFromDeath);

	CreateNative("War3_GetOwnsItem",NWar3_GetOwnsItem);
	CreateNative("War3_SetOwnsItem",NWar3_SetOwnsItem);

	CreateNative("W3IsItemDisabledGlobal",NW3IsItemDisabledGlobal);
	CreateNative("W3IsItemDisabledForRace",NW3IsItemDisabledForRace);

	CreateNative("GetMaxShopitemsPerPlayer",NGetMaxShopitemsPerPlayer);

	CreateNative("GetClientItemsOwned",NGetClientItemsOwned);

	return true;
}

//native War3_RestoreItemsFromDeath(client,bool:payforit,bool:csmoney);
public NWar3_RestoreItemsFromDeath(Handle:plugin,numParams)
{
	int client=GetNativeCell(1);
	bool payforit=GetNativeCell(2);
	bool csmoney=GetNativeCell(3);
	int ItemsLoaded = totalItemsLoaded;
	if (ValidPlayer(client))
		{
			int counter;
			int maxitemsallowed = iGetMaxShopitemsPerPlayer(client);
			char String_itemName[64];
			// Remove Items Not allowed to have.
			for(int i;i<=ItemsLoaded;i++)
			{
				if(playerOwnsItem[client][i]==true||RestoreItemsFromDeath_playerOwnsItem[client][i]==true)
				{
					internal_W3SetVar(EventArg1,i);
					if(W3Denyable(DN_CanBuyItem1,client)==false)
					{
						RestoreItemsFromDeath_playerOwnsItem[client][i]=false;
						SetOwnsItem(client,i,false);
					}
				}
			}


			//payforit
			if(payforit==true)
			{
				int numTotalCost = 0;
				int War3_Temp_ItemCost;
				// Check to see if they already have exact a copy of these items
				bool checkit = false;
				for(int i;i<=ItemsLoaded;i++)
				{
					if((playerOwnsItem[client][i]==RestoreItemsFromDeath_playerOwnsItem[client][i]) && (playerOwnsItem[client][i]==true))
					{
						checkit=true;
						counter++;
					}
					else checkit=false;
				}
				if(counter>maxitemsallowed)
				{
					War3_ChatMessage(client,"{red}<<buyprevious>>{default}You have more items than allowed by server.\n{green}<<buyprevious>>{default}Correct adjustments will be made.");
				}
				if(checkit==true)
				{
					War3_ChatMessage(client,"{red}<<buyprevious>>{default}You already{red} own{default} these items{default}.");
					return false;
				}
				counter = 0;
				// Figure out if its gold or cs money
				int GoldMoney;
				bool SkipBuying = false;
				if(csmoney==true)
					GoldMoney = GetCSMoney(client);
				else
					GoldMoney = GetPlayerProp(client, PlayerGold);
				// Remove Items that are not part of list from when user died last
				for(int i;i<=ItemsLoaded;i++)
				{
					if(GetOwnsItem(client,i) && !RestoreItemsFromDeath_playerOwnsItem[client][i])
					{
						GetItemName(i,String_itemName,64);
						SetOwnsItem(client,i,false);
						War3_ChatMessage(client,"{red}<<buyprevious>>{default}Item Discarded: {green}%s{default} (You didn't own this item on death).",String_itemName);
					}
				}
				// Find the Items
				counter = 0;
				for(int i;i<=ItemsLoaded;i++)
				{
					if(counter>=maxitemsallowed)
					{
						SkipBuying = true;
					}
					if(SkipBuying == false)
					{
						if(RestoreItemsFromDeath_playerOwnsItem[client][i])
						{
							if(!GetOwnsItem(client,i))
							{
								//How much does the item cost?
								War3_Temp_ItemCost = W3GetItemCost(client,i,GetNativeCell(3));
								// if I can afford it, buy it:
								if(GoldMoney>=War3_Temp_ItemCost)
								{
									GoldMoney = GoldMoney - War3_Temp_ItemCost;
									numTotalCost = numTotalCost + War3_Temp_ItemCost;
									SetOwnsItem(client,i,true);
									GetItemName(i,String_itemName,64);
									War3_ChatMessage(client,"{red}<<buyprevious>>{default}You bought {green}%s{default}.",String_itemName);
									counter++;
								}
								else
								{
									War3_ChatMessage(client,"{red}<<buyprevious>>{default}You can not afford {green}%s{default}.",String_itemName);
								}
							}
							else
							{
								GetItemName(i,String_itemName,64);
								War3_ChatMessage(client,"{red}<<buyprevious>>{default}You already own it! Skipping: {green}%s{default}.",String_itemName);
								counter++;
							}
						}
					}
					// For Debug:
					//War3_ChatMessage(client,"{red}<<buyprevious>>{default}Counter: {green}%d{default}.",counter);
				}
				// Do the math
				// Charge them for CSMoney or Gold?
				if(csmoney==true)
					SetCSMoney(client,GoldMoney);
				else
					SetPlayerProp(client, PlayerGold, GoldMoney);
				// Tell them the total cost
				// To do: if cost == 0 then tell them they didn't buy anything.
				if(csmoney==true)
					War3_ChatMessage(client,"{red}<<buyprevious>>{default}Total cost ${green}%i {default}.",numTotalCost);
				else
					War3_ChatMessage(client,"{red}<<buyprevious>>{default}Total cost {green}%i {default}gold.",numTotalCost);
			}
			else
			{
			//no cost
			// NEEDS WORK ... BECAUSE ABOVE HAS BEEN CHANGED
			counter = 0;
			for(new i;i<=ItemsLoaded;i++)
			{
				//playerOwnsItem[client][i]=RestoreItemsFromDeath_playerOwnsItem[client][i];
				if(RestoreItemsFromDeath_playerOwnsItem[client][i]==true)
				{
					SetOwnsItem(client,i,true);
					GetItemName(i,String_itemName,64);
					War3_ChatMessage(client,"{red}<<buyprevious>>{default}You receive {green}%s{default}.",String_itemName);
					counter++;
				}
				if(RestoreItemsFromDeath_playerOwnsItem[client][i]==false && GetOwnsItem(client,i))
				{
					SetOwnsItem(client,i,false);
					GetItemName(i,String_itemName,64);
					War3_ChatMessage(client,"{red}<<buyprevious>>{default}Item Discarded: {green}%s{default} (You didn't own this item on death).",String_itemName);
				}
				if(counter>=maxitemsallowed)
					break;
			}
			}
			return true;
		}
	else
		return false;
}

stock bool:GetOwnsItem(client, item)
{
	if (ValidPlayer(client))
	{
		if(item>totalItemsLoaded || item<0)
		{
			return false;
		}
		return playerOwnsItem[client][item];
	}
	else
		return false;
}

public NWar3_GetOwnsItem(Handle:plugin,numParams)
{
	return GetOwnsItem(GetNativeCell(1), GetNativeCell(2));
}

stock SetOwnsItem(client,itemid,bool:ownsitem)
{
	new bool:old=playerOwnsItem[client][itemid];
	playerOwnsItem[client][itemid]=ownsitem;
	if(old!=playerOwnsItem[client][itemid]){
		switch(playerOwnsItem[client][itemid]){
			case false:{
				Call_StartForward(g_OnItemLostHandle);
				Call_PushCell(client);
				Call_PushCell(itemid);
				Call_Finish(dummy);
			}
			case true:{
				Call_StartForward(g_OnItemPurchaseHandle);
				Call_PushCell(client);
				Call_PushCell(itemid);
				Call_Finish(dummy);
			}
			default: {
				ThrowNativeError(0,"set owns item is not true or false");
			}
		}
	}
}

public NWar3_SetOwnsItem(Handle:plugin,numParams)
{
	SetOwnsItem(GetNativeCell(1),GetNativeCell(2),bool:GetNativeCell(3));
}
stock bool internal_W3IsItemDisabledGlobal(int itemid)
{
	char itemShort[16];
	W3GetItemShortname(itemid,itemShort,16);

	char cvarstr[100];
	char exploded[MAXITEMS][16];
	int num;
	GetConVarString(hitemRestrictionCvar,cvarstr,sizeof(cvarstr));
	if(strlen(cvarstr)>0)
	{
		num=ExplodeString(cvarstr,",",exploded,MAXITEMS,16);
		for(int i=0;i<num;i++){
			//PrintToServer("'%s' compared to: '%s' num%d",exploded[i],itemShort,num);
			if(StrEqual(exploded[i],itemShort,false))
			{
				//PrintToServer("TRUE");
				return true;
			}
		}
	}
	return false;
}
public NW3IsItemDisabledGlobal(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);
	return internal_W3IsItemDisabledGlobal(itemid);
}
public NW3IsItemDisabledForRace(Handle:plugin,numParams)
{
	new raceid=GetNativeCell(1);
	new itemid=GetNativeCell(2);
	if(raceid>0){
		char itemShort[16];
		W3GetItemShortname(itemid,itemShort,sizeof(itemShort));

		char cvarstr[100];
		char exploded[MAXITEMS][16];

		GetRaceItemRestrictionsStr(raceid,cvarstr,sizeof(cvarstr));

		int num;
		if(strlen(cvarstr)>0){
			num=ExplodeString(cvarstr,",",exploded,MAXITEMS,16);
			for(int i=0;i<num;i++){
				//PrintToServer("'%s' compared to: '%s' num%d",exploded[i],itemShort,num);
				if(StrEqual(exploded[i],itemShort,false)){
					//PrintToServer("TRUE");
					return true;
				}
			}
		}
	}
	return false;
}



public NGetClientItemsOwned(Handle:h,n){
	new client=GetNativeCell(1);
	new num=0;
	new ItemsLoaded = totalItemsLoaded;
	for(new i=1;i<=ItemsLoaded;i++){
		if(GetOwnsItem(client,i)){
			num++;
		}
	}
	return num;
}

stock iGetMaxShopitemsPerPlayer(client)
{
#if SHOPMENU3 == MODE_ENABLED
	//new client=GetNativeCell(1);
	new raceid=GetRace(client);
	new item_black_pearl=War3_GetItem3IdByShortname("blkpearl");
	// one extra pocket
	if(War3_GetOwnsItem3(client,raceid,item_black_pearl))
	{
		if(War3_GetTotalItemLevels(client,raceid,item_black_pearl)>0)
		{
			return GetConVarInt(hCvarMaxShopitems)+1;
		}
	}
#endif
	return GetConVarInt(hCvarMaxShopitems);
}

public NGetMaxShopitemsPerPlayer(Handle:h,n)
{
	return iGetMaxShopitemsPerPlayer(GetNativeCell(1));
}

// WAR3EVENT
//new bool:BuyPrevious1_playerOwnsItem[MAXPLAYERSCUSTOM][MAXITEMS];
public War3Source_Engine_ItemOwnership_OnWar3Event(W3EVENT:event,client){
	if(event==DoForwardClientBoughtItem){
		new itemid=internal_W3GetVar(TheItemBoughtOrLost);
		SetOwnsItem(client,itemid,true);

	}
	if(event==DoForwardClientLostItem){
		new itemid=internal_W3GetVar(TheItemBoughtOrLost);
		SetOwnsItem(client,itemid,false);

	}
	if(event==DoCheckRestrictedItems){
		CheckForRestrictedItemsOnRace(client);
	}
	// Record Items before death
	if(event==OnDeathPre)
	{
		//Check to see if Player owns any items, if so.. record those items,
		// otherwise keep the current record.
		if(GetClientItemsOwned(client)>0 && !IsFakeClient(client))
		{
			new ItemsLoaded = totalItemsLoaded;
			for(new i2;i2<=ItemsLoaded;i2++)
			{
					RestoreItemsFromDeath_playerOwnsItem[client][i2]=playerOwnsItem[client][i2];
			}
		}
	}
}

//Clear Buyprevious items from previous connetion
public War3Source_Engine_ItemOwnership_OnClientPutInServer(client)
{
	if(!IsFakeClient(client))
		ResetArrayVals(client);
}

// Players only use this:
ResetArrayVals(client)
{
	new ItemsLoaded = totalItemsLoaded;
	for(new i;i<=ItemsLoaded;i++)
	{
		RestoreItemsFromDeath_playerOwnsItem[client][i]=false;
	}
}

CheckForRestrictedItemsOnRace(client)
{
	new ItemsLoaded = totalItemsLoaded;
	for(new itemid=1;itemid<=ItemsLoaded;itemid++){
		if(GetOwnsItem(client,itemid)){
			new race=GetRace(client);
			if(W3IsItemDisabledForRace(race,itemid)){

				new String:racename[32];
				GetRaceName(race,racename,sizeof(racename));

				new String:itemname[64];
				W3GetItemName(itemid,itemname,sizeof(itemname));
				War3_ChatMessage(client,"%T","{itemname} is restricted on job {racename}, item has been removed",client,itemname,racename);

				internal_W3SetVar(TheItemBoughtOrLost,itemid);
				DoFwd_War3_Event(DoForwardClientLostItem,client); //old item

			}

		}
	}
}
