//=============================================================================
// Shop Items 2
//=============================================================================

//=============================================================================
// Shop Item Creation
//=============================================================================

//Shopmenu 2 item class
native War3_CreateShopItem2(String:name[],String:shortname[],String:shortdesc[],String:desc[],cost);
native War3_CreateShopItem2T(String:shortname[],String:shortdesc[],cost);

//native W3CreateShopItem2(String:name[],String:shortname[],String:desc[],cost,translated=false);
//translated
//stock W3CreateShopItem2T(String:shortname[],cost) {
//	return W3CreateShopItem2("",shortname,"",cost,true);
//}

//=============================================================================
// Shop Items Owner
//=============================================================================
/**
 * Sets if the player owns a specific item.
 * @param client: Client index
 * @param item: The item ID returned from War3_CreateShopItem
 * @param owns: 1 if you want them to own it, 0 if you want them not to own it 
 * @noreturn
 * 
 *	ITEM IS NOT LOST AUTOMATICALLY ON DEATH  
 */
native War3_GetOwnsItem2(client, item);
native War3_SetOwnsItem2(client,item,bool:ownsitem);

native GetClientItems2Owned(client);
native GetMaxShopitems2PerPlayer(client);

native War3_SetItem2Property(itemid,W3ItemProp:ITEM_PROPERTY,value);
native War3_GetItem2Property(itemid,W3ItemProp:ITEM_PROPERTY);

//=============================================================================
// Shop Items Information / ID
//=============================================================================

//returns -1 if not found
//valid itemid if > 0
native War3_GetItem2IdByShortname(String:itemshortname[]);

native W3GetItem2Name(itemid,String:ret[],maxlen);
native W3GetItem2Shortname(itemid,String:ret[],maxlen);
native W3GetItem2Shortdesc(itemid,String:ret[],maxlen);
native W3GetItem2Desc(itemid,String:ret[],maxlen);

native W3GetItem2Cost(itemid);
native W3GetItem2Order(itemid);
native W3Item2HasFlag(itemid,String:flagsearch[]);
native W3GetItem2Catagory(itemid,String:retcatagorystr[],maxlen);
native W3GetItems2Loaded();

//=============================================================================
// Shop Items Get Restrictions
//=============================================================================

native bool:W3IsItem2DisabledGlobal(itemid);
native bool:W3IsItem2DisabledForRace(race,itemid);

//=============================================================================
// Shop Items Misc
//=============================================================================

//Forces a save into database of when the item expires
//client must own item already
native W3SaveItem2ExpireTime(client, itemid);

//=============================================================================
// Shop Items Forwards
//=============================================================================

/**
 * Gets called when a player loses an item. (after death (ownership to false) or traded it back..)
 * @param client: The client's index.
 * @param item: The item that was purchased.
 * PLAYER ALREADY HAS LOST OWNERSHIP BY THIS POINT   
 */
forward OnItem2Lost(client, item);

/**
 * Gets called when a player purchases an item.
 * @param client: The client's index.
 * @param item: The item that was purchased.
 * PLAYER ALREADY HAS OWNERSHIP BY THIS POINT  
 */
forward OnItem2Purchase(client, item);
