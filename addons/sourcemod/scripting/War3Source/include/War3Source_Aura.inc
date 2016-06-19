// War3Source_Aura.inc

/**
 * AURA SYSTEM, keeps track of players aura via distance
 * This function registers an aura, returns an number, save it as your AuraID
 * by default tracks teammates only
 * Track other team will track other team only, if you want to track both teams, use two different auras
 * aura not does take account of line of sight
 *
 * @param auraShortName					create a name for the aura
 * @param distance						distance of the aura
 * @param trackotherteam				should the aura track the other team
 * @param raceid						race id
 * @return 								aura id
 *
 */
native W3RegisterAura(String:auraShortName[],Float:distance,bool:trackotherteam=false,raceid=0);

/**
 * set and unset a player if he has or no longer has the origin of the aura
 * removed if player disconnects
 * level (optional) is a integer for a priority system, such as teammate has level 1 heal wave and another teammate has level 4 heal wave
 * the player recieves the level 4 heal wave and does not stack with level 1 heal wave
 *
 * @param tAuraID						the id of the aura
 * @param client						client index
 * @param auraOriginatesFromPlayer		should the aura track the other team
 * @param level							the higher level aura takes more priority
 * @return 								no return
 *
 */
native W3SetAuraFromPlayer(tAuraID,client,bool:auraOriginatesFromPlayer=true,level=1);

/**
 * is this player under the influence of this aura?
 * it means player is within distance of an aura origin (ie a player)
 * level of the aura recieved is passed by reference and will be set
 *
 * @param tAuraID						the id of the aura
 * @param client						client index
 * @param level							the aura level
 * @return 								returns true if client has aura
 *
 */
native bool:W3HasAura(tAuraID,client,&level);

/**
 * forward when a player's aura state changes, ie leaves the area, or dies
 * however player may be dead while the aura lingers, always check for alive in your function
 *
 * @param client						client index
 * @param tAuraID						the id of the aura
 * @param inAura						the number of auras
 * @param level							the aura level
 * @param AuraStack						how many auras of this auraid does the client have?
 * @param AuraOwner						the aura owner
 * @return 								returns true if client has aura
 *
 * Note: inAura is checking for if your in AuraOwner's Aura or not.
 *
 * The new way to check if you want to use a on/off feature.  Check if AuraStack is greater than 0.
 *
 */
forward void OnW3PlayerAuraStateChanged(int client, int tAuraID, bool inAura, int level, int AuraStack, int AuraOwner);

/**
 * Advanced Aura System can handle multiple distances
 * If you want to be able to setup your race with a aura system that uses multiple
 * distances based on skill level, then use the system below
 *
 * Use below to register, set, and remove your auras for the new system.
 * you can "reregister the aura to switch the trackotherteam" using this system
 *
 * @param auraShortName					create a name for the aura
 * @param trackotherteam				should the aura track the other team
 * @return 								returns id of aura
 *
 */
native W3RegisterChangingDistanceAura(String:auraShortName[],bool:trackotherteam=false);

/**
 * removed if player disconnects
 * level (optional) is a integer for a priority system, such as teammate has level 1 heal wave and another teammate has level 4 heal wave
 * the player recieves the level 4 heal wave and does not stack with level 1 heal wave
 * the distance for the aura of the client
 *
 * @param tAuraID						the id of the aura
 * @param client						client index
 * @param distance						distance of the aura
 * @param level							the higher level aura takes more priority
 * @return 								no return
 *
 */
native void W3SetPlayerAura(int tAuraID, int client, float distance, int level=0);

/**
 * A Simple Way to remove an aura from the player you had used SetAuraFromPlayer
 *
 * @param tAuraID						the id of the aura
 * @param client						client index
 * @return 								no return
 *
 */
native W3RemovePlayerAura(tAuraID,client);
