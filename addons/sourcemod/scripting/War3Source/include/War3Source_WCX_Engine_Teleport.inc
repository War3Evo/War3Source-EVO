/**
 * File: War3Source_WCX_Engine_Teleport.inc
 * Author(s): El Diablo
 *
 */

/**
 * Teleports client to target location within given distance
 * or just teleports forward a certain distance.
 *
 * @param client
 * @param target
 * @param Float:ScaleVectorDistance - deals with target distance
 * @param Float:distance
 *
 * If you want to reset the cooldowns for your race / skill, then supply those
 * numbers in the correct params
 *
 * This resets cooldown if the teleport was unsuccessful due to boundaries
 * like walls being in the way.
 *
 * @param raceid *resets race/skill cooldown on fail
 * @param skillid *resets race/skill cooldown on fail
 *
 * @param return - no return
 *
 * 
 * 
 */
native void War3_Teleport(int client,int target=-1,float ScaleVectorDistance=-1.0,float distance=1200.0,int raceid=-1,int skillid=-1);

/**
 * Teleports client to target location within given distance
 * or just teleports forward a certain distance.
 *
 * @param client client int.
 * @param origin New origin, or NULL_VECTOR for no change.
 * @param angles New angles, or NULL_VECTOR for no change.
 * @param velocity New velocity, or NULL_VECTOR for no change.
 *
 * @param return - no return
 * 
 */

native War3_TeleportEntity(int client, const float origin[3], const float angles[3], const float velocity[3]);

/**
 * Called right before GetAngleVectors Calculations.
 *
 * Currently this is the current Angle formula:
 *
 * GetClientEyeAngles(client,angle);
 *
 * If you want to use the target instead of the client and or
 * change the formula, you can do this here to change the angle
 * right before it calls GetAngleVectors.
 *
 * @param client
 * @param target
 * @param angle allows you to change the angle before the caluclations.
 *
*/
forward Action:OnW3TeleportGetAngleVectorsPre(client, target, Float:angle[3]);


/**
 * Called right before War3_Teleport triggers its own TeleportEntity.
 *
 * All checks have been made, as far a distances and stuff in the way.
 * This is the time it will teleport the entity.
 *
 * We had used this to change the angle of the entity whom is teleported
 * and is the reason this Custom Action was created.
 * You can use it how you wish.
 *
 * If you would like to teleport the entity yourself, then return
 * Plugin_Handled after you teleport the entity
 * otherwise, War3_Teleport will use this formula:
 * TeleportEntity(client,emptypos,NULL_VECTOR,NULL_VECTOR);
 * to teleport the entity.
 *
 * @param client
 * @param target
 *
 * @return Plugin_Handled if you plan to use this function to create a custom teleport
 * @return Plugin_Continue if okay
 * your own teleport entity function.
*/
forward Action:OnW3TeleportEntityCustom(client,target,Float:dir[3],Float:emptypos[3]);

/**
 * This is the location where the client will be teleporting to.
 *
 * Most races do immunity checking here.
 *
 * @return Plugin_Handled if this did NOT pass your checks and you will NOT allow the teleport to this location.
 * @return Plugin_Continue if okay
*/
forward Action:OnW3TeleportLocationChecking(client,Float:playerVec[3]);


/**
 * Called when there was a successful teleport
 *
 * @param client
 * @param target
 * @param distance - Actual distance traveled
 * @param raceid
 * @param skillid
 *
 * @param return - no return
 *
 */
forward OnW3Teleported(int client,int target,float distance,int raceid,int skillid);
