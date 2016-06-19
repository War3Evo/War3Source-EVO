//=============================================================================
// CoolDown Manager
//=============================================================================

//LO AND BEHOLD THE COOLDOWN MANAGER, YOUR LIFE SIMPLIFIED!!!
//we essentially move the cooldown system out of our races into our main plugin
/**
 * cooldown manager
 * basically self explainatory parameters, creates a cooldown for a skill (term skill used here is generic for skill/ability/ultimate)
 * printMsgOnExpireByTime prints message to client (if alive and same race) when this skill expires by time (will not print when expired by spawn or death or force reset)
 * The skill name of the skill will be in ready and not ready messages.
 * when a cooldown expires (by time, by death, by spawn, by force reset), it will forward to OnCooldownExpired(....) forward, use if u need to
 * @noreturn
 *
 * Usually the first 4 parameters are enough
 */
native War3_CooldownMGR(client,Float:cooldownTime,raceid,skillNum, bool:resetOnSpawn=true,bool:printMsgOnExpireByTime=true);

/**
 * Item3 Cooldown Manager
 *
 * @param client			Player's index.
 * @param cooldownTime		Time in seconds for shopmenu 3 item to cooldown
 * @param raceid			Race ID
 * @param item3Num			Item ID
 * @return 					no return
 */
native War3_Item3CooldownMGR(client,Float:cooldownTime,raceid,item3Num);

/**
 * Checks if item3 is in cooldown
 *
 * @param client			Player's index.
 * @param raceid			Race ID
 * @param item3Num			Item ID
 * @return 					true if not in cooldown
 */
native bool:War3_Item3NotInCooldown(client,raceid,item3Num);

/**
 * Cooldown Time Remaining
 *
 * @param client			Player's index.
 * @param raceid			Race ID
 * @param item3Num			Item ID
 * @return 					Rounded value.
 */
native War3_Item3CooldownTimeRemaining(client,raceid,item3Num);

/**
 * tells the cooldown manager to create a predefined cooldown time when player spawns with that race.
 * cooldown is created regardless of resetOnSpawn in War3_CooldownMGR(...) calls
 * only prints expired if client remains that race
 * set this ONCE when u register your skills
 *
 * @param raceid			Player's index.
 * @param skillnum			Race ID
 * @param cooldownTime		Item ID
 * @param printmsgonexpire	Item ID
 * @return 					no return
 */
native W3SkillCooldownOnSpawn(raceid,skillnum,Float:cooldownTime,bool:printmsgonexpire=true);

/**
 * how much time is left on this particular cooldown?
 * returns an int (rounted up from the float)
 */
native War3_CooldownRemaining(client, raceid, skillNum);

/**
 * basically make this cooldown expire, this expiration is not considered "by time"
 */
native War3_CooldownReset(client, raceid, skillNum);

/**
 * is this skill NOT in COOLDOWN? YOU NEED TO CHECK IF CLIENT HAS LEVELED THIS SKILL FIRST, THIS IS ONLY COOLDOWN RELATED
 * you would only do this if this skill has a cooldown and u called War3_CooldownMGR
 * printTextIfNotReady=true will print a "not ready" message
 */
native bool:War3_SkillNotInCooldown(client,raceid,skillNum,bool:printTextIfNotReady=false);

/**
 * prints Skill Is Not Ready
 */
native War3_PrintSkillIsNotReady(client, raceid, skillNum);

/**
 * A wrapper for War3_SkillNotInCooldown
 *
 */
stock bool:SkillAvailable(client,yourRaceID,skillnumber,bool:printCooldown=true,bool:checksilenced=true,bool:printSilenced=true) {
	return War3_SkillNotInCooldown(client,yourRaceID,skillnumber,printCooldown)&& (!checksilenced||!Silenced(client,printSilenced));
}

//=============================================================================
// Fowards
//=============================================================================

/**
 * Called when a cooldown expires (timed, death, or spawn)
 */
forward OnCooldownExpired(client,raceID,skillNum,bool:expiredByTime);

forward OnCooldownStarted(client,raceID,skillNum);

