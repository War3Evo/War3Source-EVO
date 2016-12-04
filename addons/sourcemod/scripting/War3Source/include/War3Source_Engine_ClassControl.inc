// War3Source_Engine_ClassControl.inc

/**
 * is this player under the influence of this aura?
 * it means player is within distance of an aura origin (ie a player)
 * level of the aura recieved is passed by reference and will be set
 *
 * @param client						client index
 * @param tClass						TFClassType
 * @param bSpecialEffects				true for special effects, false for not
 * @param bTryRemoveProblemEffects		try to remove effects harmful to instant class changing (true to try, false will not try and fail)
 * @return 								returns true if it was successful
 *
 */
native bool War3_SetClass(int client, TFClassType tClass, bool bSpecialEffects = true, bool bTryRemoveProblemEffects = true);
