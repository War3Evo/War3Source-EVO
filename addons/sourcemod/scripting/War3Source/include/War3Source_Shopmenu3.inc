// War3Source_Shopmenu3.inc

//=============================================================================
// Shop Items 3
//=============================================================================

//Shopmenu 3 item class
/**
 * Registers a shop item with the War3Source plugin
 * @param name: The name of the item.
 * @param shortname: the shortname of the item, must be unique
 * @param desc: The description of the item.
 * @param cost: The cost of the item
 * @param category: The Category of the item
 * @param maxlevel1: the items max level left side
 * @param maxlevel2: optional max level right side
 * @return The return value will be the item index or -1 if there was a problem.
 */
native War3_CreateShopItem3(String:name[],String:shortname[],String:desc[],costgold,String:titemcategory[],String:itemlevelname1[],maxlevel1=1,String:itemlevelname2[],maxlevel2=0);
//translated
//native War3_CreateShopItem3T(String:shortname[],costgold);

/*
 War3_TFSetItemClasses(itemid, and then use ItemClassString separted by comma )

 example:

 War3_TFSetItemClasses(itemid,sniper,medic,scout)

if you want all classes then don't assign anything OR you can use:
War3_TFSetItemClasses(itemid,all)

 As many classes that you want this item to have access to.

enum ItemClassString
{
	all = TFClass_Unknown,
	scout = TFClass_Scout,
	sniper = TFClass_Sniper,
	soldier = TFClass_Soldier,
	demoman = TFClass_DemoMan,
	medic = TFClass_Medic,
	heavy = TFClass_Heavy,
	pyro = TFClass_Pyro,
	spy = TFClass_Spy,
	engineer = TFClass_Engineer
}
*/
#if GGAMETYPE == GGAME_TF2
native War3_TFSetItem3Classes(itemid,any:...);
// If TFClassType is set for TFClass_Unknown, then all classes have access to this item.
// use  War3_TFIsItemClass(itemid,TF2_GetPlayerClass(client));
/*
01: enum TFClassType
02: {
03:     TFClass_Unknown = 0,
04:     TFClass_Scout,
05:     TFClass_Sniper,
06:     TFClass_Soldier,
07:     TFClass_DemoMan,
08:     TFClass_Medic,
09:     TFClass_Heavy,
10:     TFClass_Pyro,
11:     TFClass_Spy,
12:     TFClass_Engineer
13: };*/
native War3_TFIsItem3Class(itemid,TFClassType:iPlayerClass);
#endif

//=============================================================================
// Shop Items 3 Save XP
//=============================================================================

native W3SaveXPsh3(client, race);

//=============================================================================
// Shop Items 3 Property
//=============================================================================

//see W3ItemProp enum for available properties
native War3_SetItem3Property(itemid,W3ItemProp:ITEM_PROPERTY,value);
native War3_GetItem3Property(itemid,W3ItemProp:ITEM_PROPERTY);

//=============================================================================
// Shop Items 3 Item Details
//=============================================================================

//remember itemid that is valid is more than 0
//returns -1 if not found
native War3_GetItem3IdByShortname(String:itemshortname[]);

native W3GetItem3Name(itemid,String:ret[],maxlen);
native W3GetItem3Shortname(itemid,String:ret[],maxlen);
//native W3GetItem3Description(itemid,String:ret[],maxlen);

native W3GetItem3Desc(itemid,String:ret[],maxlen);

native W3GetItem3Cost(itemid);
native W3GetItem3Order(itemid);
native W3Item3HasFlag(itemid,String:flagsearch[]);
native W3GetItem3Category(itemid,String:retcatagorystr[],maxlen);

//=============================================================================
// Shop Items 3 Functions
//=============================================================================

// returns true if they are the same
// compares the item to the other items.
native bool:W3CompareTwoItemCategories(item1,item2);

native bool:W3ItemCategoryExist(client,race,item);


//native W3GetItems3Loaded(); //how many items are loaded?

native bool:W3IsItem3DisabledGlobal(itemid);
native bool:W3IsItem3DisabledForRace(race,itemid);

//=============================================================================
// Shop Items 3 Save Items
//=============================================================================

//Forces a save into database of when the item expires
//client must own item already
native W3SaveItem3(client, itemid);

native GetClientItems3Owned(client);
native GetMaxShopitems3PerPlayer();

//=============================================================================
// Shop Items 3 Ownership
//=============================================================================

/**
 * Gets if the player owns a specific item3 Gems and Trinkets.
 * @param client: Client index
 * @param item: The item ID returned from War3_CreateShopItem
 * @param race: The race that owns the item.
 * @return The return value will be 1 if they own it, if 0 they don't, if -1 then it failed.
 */
native War3_GetOwnsItem3(client,race,item);
native War3_SetOwnsItem3(client,race,item,bool:ownsitem);

//native W3GetItem3(client, item);
//native W3SetItem2ExpireTime(client, item, time); //use full linux time , ie: NOW()+duration

//native War3_GetCurrentItems(client,race,item1,item2,item3);
native War3_GetItemId1(client,race);
native War3_GetItemId2(client,race);
native War3_GetItemId3(client,race);

native W3GetItems3Loaded(); //how many items are loaded?

//=============================================================================
// Shop Items 3 Platinum
//=============================================================================
native W3GiveXP_Platinum(client,race,platinumamount=0,String:awardstringreason[],W3XPAwardedBy:awardreason=XPAwardByGeneric,itemid=-99,W3ItemSkills:itemskill=skill1,xpamount=0);

native W3GetItem3levelName(itemid,String:ret[],maxlen,W3ItemSkills:sidenum);

/**
 * Gets called when a skill level is changed.
 */
forward OnItemSkillLevelChanged(client, race, item, level);

// full item information
native War3_GetTotalItemLevels(client,race,item);  // player total levels
native W3GetItem3maxtotallevels(item); // shopmenu3 total levels

// The first half of the item

native bool:War3_SetItemXP(client, race, item, newxp);
native War3_GetItemXP(client, race, item);
native War3_SetItemLevel(client, race, item, level);
native War3_GetItemLevel(client, race, item);
native W3GetItem3maxlevel1(item);
// The second half of the item

native bool:War3_SetItemXP2(client, race, item, newxp);
native War3_GetItemXP2(client, race, item);
native War3_SetItemLevel2(client, race, item, level);
native War3_GetItemLevel2(client, race, item);
native W3GetItem3maxlevel2(item);

//max platinum a player can have (cvar read)
native W3GetMaxPlatinum();

/*
enum W3ItemProp
{
	bool:bPutInServer,
	CurrentRace,
	PendingRace,
	PlayerGold,
	PlayerDiamonds,//REMOVE PlayerDiamonds, //DRPECE
	iMaxHP,
	bIsDucking,

	bool:xpLoaded,
	Float:RaceChosenTime,
	bool:RaceSetByAdmin,
	bool:SpawnedOnce, //if player has spawned once
	Float:sqlStartLoadXPTime,

	bool:isDeveloper,
	Float:LastChangeTeamTime,
	bool:bStatefulSpawn, //set true if spawn is a non repeated spawn. set to true on join and death, set false after spawn forward is finished.
	iGoldDiamondHud,
	bool:dbRaceSelected, //used in spawn camper.
	PlayerPlatinum,
}
	*/
