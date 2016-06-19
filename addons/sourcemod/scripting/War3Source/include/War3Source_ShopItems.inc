//=============================================================================
// Shop Items 1
//=============================================================================

//=============================================================================
// Shop Item Creation
//=============================================================================
/**
 * Registers a shop item with the War3Source plugin
 * @param name: The name of the item.
 * @param shortname: the shortname of the item, must be unique
 * @param desc: The description of the item.
 * @param cost: The cost of the item
 * @param isgold: Does the item cost gold?
 * @param usecsmoney: set to 1 for item to use the csmoney number
 * @return The return value will be the item index or -1 if there was a problem.
 */
native War3_CreateShopItem(String:name[],String:shortname[],String:shortdesc[],String:desc[],costgold,costmoney,usecsmoney=0);
//translated
native War3_CreateShopItemT(String:shortname[],String:shortdesc[],costgold,costmoney,usecsmoney=0);

//=============================================================================
// Shop Items Owner
//=============================================================================

/**
 * Gets if the player owns a specific item.
 * @param client: Client index
 * @param item: The item ID returned from War3_CreateShopItem
 * @return The return value will be true if they own it, if false they don't.
 */
native bool:War3_GetOwnsItem(client, item);
native War3_SetOwnsItem(client,item,bool:ownsitem);

native GetClientItemsOwned(client);
native GetMaxShopitemsPerPlayer(client);

//see W3ItemProp enum for available properties
native War3_SetItemProperty(itemid,W3ItemProp:ITEM_PROPERTY,value);
native War3_GetItemProperty(itemid,W3ItemProp:ITEM_PROPERTY);

//=============================================================================
// Shop Items Information / ID
//=============================================================================

//remember itemid that is valid is more than 0
//returns -1 if not found
native War3_GetItemIdByShortname(String:itemshortname[]);

native W3GetItemName(itemid,String:ret[],maxlen);
native W3GetItemShortname(itemid,String:ret[],maxlen);
native W3GetItemShortdesc(itemid,String:ret[],maxlen);
native W3GetItemDescription(itemid,String:ret[],maxlen);
native W3GetItemOrder(itemid);

//=============================================================================
// Shop Items cost
//=============================================================================
/**
 * Gets the item cost.
 *
 * @param client: The client's index. (sends a event to shop 3 item and requires client id)
 * @param itemid: The item that you want the cost of.
 * @param return: the cost of the item
 */
native W3GetItemCost(client,itemid,bool:csmoney=false);

/**
 * does the item require cs money?
 *
 * @param itemid: item index
 * @param return: if item requires use of cs money
 */
native bool:W3IsItemCSmoney(itemid);

//=============================================================================
// Shop Items Flags
//=============================================================================

native W3ItemHasFlag(itemid,String:flagsearch[]);
native W3GetItemCategory(itemid,String:retcatagorystr[],maxlen);

//=============================================================================
// Number of Shop Items
//=============================================================================
//how many items are loaded?
native W3GetItemsLoaded();

//=============================================================================
// Shop Items Get Restrictions
//=============================================================================
native bool:W3IsItemDisabledGlobal(itemid);
native bool:W3IsItemDisabledForRace(race,itemid);


//=============================================================================
// Shop Items Forwards
//=============================================================================
/**
 * Gets called when a player loses an item. (after death (ownership to false) or traded it back..)
 * @param client: The client's index.
 * @param item: The item that was purchased.
 * PLAYER ALREADY HAS LOST OWNERSHIP BY THIS POINT
 */
forward OnItemLost(client, item);

/**
 * Gets called when a player purchases an item.
 * @param client: The client's index.
 * @param item: The item that was purchased.
 * PLAYER ALREADY HAS OWNERSHIP BY THIS POINT
 */
forward OnItemPurchase(client, item);
