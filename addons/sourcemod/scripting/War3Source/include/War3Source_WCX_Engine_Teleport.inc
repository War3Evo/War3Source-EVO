/**
 * File: WCX_Engine_Teleport.inc
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
 */
native W3Teleport(client,target=-1,Float:ScaleVectorDistance=-1.0,Float:distance=1200.0,raceid=-1,skillid=-1);

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
 * Called right before W3Teleport triggers its own TeleportEntity.
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
 * otherwise, W3Teleport will use this formula:
 * TeleportEntity(client,emptypos,NULL_VECTOR,NULL_VECTOR);
 * to teleport the entity.
 *
 * @param client
 * @param target
 *
 * @return Plugin_Handled if you plan to use this function to create
 * your own teleport entity function.
*/
forward Action:OnW3TeleportEntityCustom(client,target,Float:dir[3],Float:emptypos[3]);

/**
 * This is the location where the client will be teleporting to.
 *
 * Most races do immunity checking here.
 *
 * @return Plugin_Handled if this did NOT pass your checks and you will NOT allow the teleport to this location.
*/
forward Action:OnW3TeleportLocationChecking(client,Float:playerVec[3]);


/**
 * Called when there was a successful teleport
 *
 * @param client
 * @param target
 * @param raceid
 * @param skillid
 *
 * @param return - no return
 *
 */
forward OnW3Teleported(client,target,distance,raceid,skillid);
