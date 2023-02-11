/**
 * File: war3source.inc
 * Description: The file to be included for creating races and whatnot.
 * Author(s): Anthony Iacono
 *
 *
 * LISTS NATIVES AND FORWARDS, BUT NOT ACTUALLY DEFINES THE CODE
 */

#if defined _War3Source_included
 #endinput
#endif
#define _War3Source_included

#pragma semicolon 1

#define W3GAMETITLE "War3Source:EVO"

//#undef REQUIRE_EXTENSIONS
#include <switchgamemode>
#include <steamIDconverter>
#include <sourcemod>

//#pragma newdecls optional

#include <sdkhooks>
#include <sdktools>
#include <sdktools_functions>

#if GGAMETYPE == GGAME_TF2
#include <tf2>
#include <tf2_stocks>
#include <morecolors>
#elseif (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO) 
#include <cstrike>
#include <colors>
#elseif GGAMETYPE == GGAME_FOF
#include <morecolors>
#else
#include <colors>
#endif

#include <keyvalues>

#include <DiabloStocks>
#include <war3source_paused>

//#pragma newdecls required

//#include "switchgamemode.inc"
#include "War3Source/include/War3Source_Constants"
#include "War3Source/include/War3Source_PlayerProp"
#include "War3Source/include/War3Source_Races"

// natives natives natives natives natives natives natives natives natives natives natives natives natives natives
// natives natives natives natives natives natives natives natives natives natives natives natives natives natives
// natives natives natives natives natives natives natives natives natives natives natives natives natives natives
// natives natives natives natives natives natives natives natives natives natives natives natives natives natives
// natives natives natives natives natives natives natives natives natives natives natives natives natives natives
// natives natives natives natives natives natives natives natives natives natives natives natives natives natives
// natives natives natives natives natives natives natives natives natives natives natives natives natives natives
// natives natives natives natives natives natives natives natives natives natives natives natives natives natives
// natives natives natives natives natives natives natives natives natives natives natives natives natives natives
// natives natives natives natives natives natives natives natives natives natives natives natives natives natives
// natives natives natives natives natives natives natives natives natives natives natives natives natives natives
// natives natives natives natives natives natives natives natives natives natives natives natives natives natives
// natives natives natives natives natives natives natives natives natives natives natives natives natives natives
// natives natives natives natives natives natives natives natives natives natives natives natives natives natives

native bool:War3_SetCollidable(client,bool:SetCollidable);

///NOTE: U NEED TO PASS 'YOUR' FACTION/RACE WHATEVER AS THE FIRST PARAM!!!
//Creates(or just returns the factionid) a (new) faction behavior
native W3Faction(raceid,String:strFactionName[],bool:bCreateIfNotExist=true);

//Changes(or just returns when using relation == ReturnValue) the relation of 2 factions (by id)
native any:W3FactionRelation(faction1,faction2,FactionBehavior:relation=ReturnValue);

//Changes(or just returns when using relation == ReturnValue) the relation of 2 factions (by name)
native any:W3FactionBehaviorByName(String:strFactionName1[],String:strFactionName2[],FactionBehavior:relation=ReturnValue);

//Compares 2 Races and returns the FacitonBehavior id
native any:W3FactionCompare(race1,race2);

//Returns the factionname of a race
native W3GetRaceFaction(race,String:strReturn[],maxsize);

native bool:War3_IsNewPlayer(client);

#if GGAMETYPE == GGAME_TF2
native War3_ToggleCyborgSkin(client,bool:toggle);
#endif

native bool:War3_AddCustomModel(client,String:weapon[],modelIndex,mdltype);
native bool:War3_RemoveCustomModel(client,String:weapon[],mdltype);

native W3GetW3Version(String:retstr[],maxlen);//str
native W3GetW3Revision();//int
native W3GetStatsVersion();//int

//Socket functions
native W3Socket(String:url[],Function:callback);
native W3Socket2(String:url[],String:postdata[],Function:callback);

//forces weapon drop, given a weapon entity
native W3DropWeapon(client, weaponent);

/**
 * Checks if we are in the freeze time. Certain games support this, like CS.
 * @return True if so, false if not.
 *
 */
#pragma deprecated
native bool:War3_InFreezeTime();

/* BEGIN GLOBAL VARS */
//retrieves specified values from the main war3 plugin, see W3Var enum in constants.inc, only those values are allowed
//this mostly used for accessing a variable without creating a special native just for it
//this returns any:, you should tag it if return value is not suppose to be normal integer. like Float:W3GetVar( or Handle:W3GetVar(
//most are temporary variables and this function should be called immidiately in the right functions
//examples W3GetVar(OldRace)   W3GetVar(DeathRace)
//See W3Var enum in constants to get a list
//Do not get/set vars arbitrarily unless you know what you are doing
native any:W3GetVar(W3Var:variabletoretrieve);
native any:W3SetVar(W3Var:variabletoretrieve,any:value);
/* END GLOBAL VARS */

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
native War3_TFSetItemClasses(itemid,any:...);
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
native War3_TFIsItemClass(itemid,TFClassType:iPlayerClass);

//native W3ExtShowShop2(client);

/**
 * Registers a help command with the War3Source:EVO plugin for war3help
 * @param name: The name of the command. (max 64)
 * @param desc: The description of the command. (max 256)
 * @noreturn
 */
native War3_CreateHelpCommand(String:name[],String:desc[]);

native W3GetLevelsSpent(client, race);
native W3ClearSkillLevels(client, race);


/**
 * When a player dies, this command record's their shopmenu1 items.
 * When you use this command, you are telling it to restore their items from death.
 * It does all the math as far as taking gold or cs money for items restored.
 * It will let the client know what items are discarded and/or bought.
 * It will also only buy until the client goes broke.
 * If the client already owns some items from the list from death, it will not charge them.
 * It only charges for the items that the client must buy to match the items from death.
 * It discards items that does not match from the previous death list.
 * Note: The no cost method still needs work.
 * @param client: Client index
 * @param payforit: false = no cost, true = charge
 * @param csmoney: true is cs money, false for gold.
 * @return The return value will be true if it is successful.
 */
native War3_RestoreItemsFromDeath(client,bool:payforit=true,bool:csmoney=false);

#if GGAMETYPE == GGAME_TF2
// Checks if a player is in steam group
// returns true if they are in steam group
native War3_IsInSteamGroup(client);
#endif

//native W3GetItem2ExpireTime(client, item);
//native W3SetItem2ExpireTime(client, item, time); //use full linux time , ie: NOW()+duration

native bool:W3BuyUseCSMoney();

/**
 * Finds the best target within a player's view cone
 * Can be limited by max distance
 * function perfers closer target over a target that has less degrees
 * @param client: Client index
 * @param max_distance: Optional, set to 0 to allow unlimited distance
 * @param include_friendlys: Optional, should we look for friendlys too?
 * @param cone_angle: Optional, view cone angle, SDK default is 23.0 degrees.
 * @param FilterFunction: Callback filter function, return false in this function to ignore entity.
 */
native War3_GetTargetInViewCone(client,Float:max_distance=0.0,bool:include_friendlys=false,Float:cone_angle=23.0,Function:FilterFunction=INVALID_FUNCTION,SkillID=0);

///traces from client to target and see if they are in view of each other (Line of Signt - LOS)
native W3LOS(client, target);

// MOVED TO W3PLAYERPROP.INC
/*
stock bool:ValidPlayer(client,bool:check_alive=false,bool:alivecheckbyhealth=false) {
	if(client>0 && client<=MaxClients && IsClientConnected(client) && IsClientInGame(client))
	{
		if(check_alive && !IsPlayerAlive(client))
		{
			return false;
		}
		if(alivecheckbyhealth&&GetClientHealth(client)<1) {
			return false;
		}
		return true;
	}
	return false;
} */

/**
 * Respawns a dead player.
 * @param client: Client's index.
 * @param ignore_dead_check: Optional, ignore dead checking.
 * @noreturn
 */
native War3_SpawnPlayer(client,bool:ignore_dead_check=false);

// THE FOLLOWING NATIVES RETRIEVE DATA CACHED ONGAMEFRAME!
// THE FUNCTIONS NAMED War3_CachedDead* ARE VALUES SET WHEN THE PLAYER DIES
// THESE ARE ADVANCED FUNCTIONS, CHANCES ARE IF U DON'T KNOW WHAT THEY MEAN
// YOU PROBABLY DON'T HAVE TO USE THEM

/**
 * Get last cached player eye angle.
 * @param client: Client index
 * @param angle[3]: Output array
 * @noreturn
 */
native War3_CachedAngle(client,Float:angle[3]);

/**
 * Get last cached player position.
 * @param client: Client index
 * @param position[3]: Output array
 * @noreturn
 */
native War3_CachedPosition(client,Float:position[3]);

/**
 * Get last cached player ducking state.
 * @param client: Client index
 * @return True or false.
 */
native bool:War3_CachedDucking(client);

/**
 * Get cached weapon entity based on iterator.
 * This function is usually called from a loop.
 * @param client: Client index
 * @param weapon_iterator: Number from 0-9.
 * @return Weapon entity, 0 if none.
 */
//native War3_CachedWeapon(client, weapon_iterator);

/**
 * Get cached weapon entity "clip1" based on iterator.
 * This function is usually called from a loop.
 * @param client: Client index
 * @param weapon_iterator: Number from 0-9.
 * @return Value of clip1.
 */
//native War3_CachedClip1(client, weapon_iterator);

/**
 * Get cached ammo of a player with a specific weapon ID.
 * This function is usually called from a loop.
 * @param client: Client index
 * @param game_weapon_id: Game specific weapon identifier, this is constant for each weapon.
 * @return Value of iAmmo.
 */
//native War3_CachedAmmo(client, game_weapon_id);

/**
 * Get cached weapon entity "clip1" of iterator, only changes when a player dies.
 * This function is usually called from a loop.
 * @param client: Client index
 * @param weapon_iterator: Number from 0-9.
 * @return Value of clip1 from last death.
 */
//native War3_CachedDeadClip1(client, weapon_iterator);

/**
 * Get cached ammo of a player with a specific weapon ID, only changes when a player dies.
 * This function is usually called from a loop.
 * @param client: Client index
 * @param game_weapon_id: Game specific weapon identifier, this is constant for each weapon.
 * @return Value of iAmmo from last death.
 */
//native War3_CachedDeadAmmo(client, game_weapon_id);

/**
 * Get cached weapon name of iterator, only changes when a player dies.
 * This function is usually called from a loop, sets output_buffer to "" if no weapon at iterator.
 * @param client: Client index
 * @param weapon_iterator: Number from 0-9.
 * @param output_buffer: Output buffer
 * @param output_size: Size of output buffer.
 * @noreturn
 */
//native War3_CachedDeadWeaponName(client,weapon_iterator,String:output_buffer[],output_size);

#if GGAMETYPE == GGAME_TF2
/**
 * Is player ubered (TF2)
 * @param client:
 * @return: true false
 */

native bool:War3_IsUbered(client);

/**
 * Is player carrying intellegence
 * @param client:
 * @return: true false
 */
native bool:War3_HasFlag(client);

/**
 * Is player cloaked
 * @param client:
 * @return: true false
 */

native bool:War3_IsCloaked(client);

#endif

//DELAY TRACKER
//DELAY TRACKER
//DELAY TRACKER
//DELAY TRACKER
//DELAY TRACKER
//DELAY TRACKER

///registers a tracker and returns an index that you must keep. usually do this for each each player or once if global
// Register once on plugin start please!
//returns -1 if tracker is full. LogErrors on Full
/*
 usage:

 register tracker
 create delay

 repeat:{
 expired?
 create delay
 }

 */
native War3_RegisterDelayTracker();

//create a delay
native War3_TrackDelay(trackerIndex,Float:delay);

//did the delay expire?
native War3_TrackDelayExpired(trackerIndex);

///PLAYER  TRACE
///PLAYER  TRACE
///PLAYER  TRACE
///PLAYER  TRACE
///PLAYER  TRACE

//get location of where the player is aiming (trace to the end of your crosshair)
native War3_GetAimEndPoint(client,Float:endpos[3]);

//get location of where the player is aiming (trace to the end of your crosshair) limited by distance
native War3_GetAimTraceMaxLen(client,Float:endpos[3],Float:maxdistance);

//simple weapon restriction:    pass "weapon_knife,weapon_hegrenade" to only allow these weapons, separated by comma.
//pass "" to allow all weapons again
//c4 etc is automatically allowed
//to override other restrictions, use a higher priority
//use 1 priorty for ur base race restrictions, USE AT OWN RISK!
native War3_WeaponRestrictTo(client,raceid,String:onlyallowedweaponsnames[],priority=1);

//get weaponlist
native War3_GetWeaponRestriction(client,raceid,String:buffer[],maxlength);

native Float:W3GetPhysicalArmorMulti(client); //damage multipler for client by accounting for physical armor (warcraft physical armor, not cs armor)
native Float:W3GetMagicArmorMulti(client); //damage multipler for client by accounting for magic armor

native W3GetCurrentWeaponEnt(client); //get the entity of the current (active) weapon


//force all supported war3 plugins into failed mode (pause plugin)
//native War3Failed(String:reason[]);

/**
 * Use this for getting a chance modifier in OnWar3TakeDamage!!
 * This is a cvar based value used for lowering chance of skill activation when a weapon such as flamethrower inflicts damage many times over a period of time.
 * If you are making a skill that has a high chance, example 1 in 10, it is advised to change it to something like 10 in 100 if using GetRandomInt, however if you are using GetRandomFloat with the chance modifier*original chance then it shouldn't be an issue.
 * @param attacker: Attacker's client index.
 * @param inflictor: Inflictor entity index. (ie sentry gun)
 * @param damagetype: Type of damage.
 * @return Float modifier, 1.0 for 100% chance otherwise percentage between 0.0 and 1.0
 */

/**
 * print via hint engine. format accepts translations
 *
 * W3HintPriority:
 * HINT_NORMAL, //things that are attached from non hint engine hints
 * HINT_SKILL_STATUS, //"TELEPORTED!"
 * HINT_DMG_DEALT,
 * HINT_DMG_RCVD,
 * HINT_COOLDOWN_NOTREADY,
 * HINT_COOLDOWN_EXPIRED,
 * HINT_COOLDOWN_COUNTDOWN,
 * HINT_LOWEST,
 * HINT_SIZE, //do not use this as priority
 *
*/
native W3Hint(client,W3HintPriority:type=HINT_LOWEST,Float:duration=5.0,String:format[],any:...);


native War3_SetLevel(client, race, level);
native War3_GetLevel(client, race);
native War3_GetLevelEx(client, race, bool:trueLevel=false);

native W3GetTotalLevels(client); //sum of  levels in each race

native W3GetLevelBank(client);
native W3SetLevelBank(client, newlevelbank);

/*
Gets the skill level of a generic skill
@client
@g_skill_id = generic skill id
@genericSkillData = array that the customer race passed to you (if any) when attaching itself to this generic skill
@customerRaceID = the matching race that is trying to use this generic skill
@customerSkillID = the matching skill id for the race trying to use this as generic skill

for example, if race 4 skill 3 is redirected as generic skill 2,
you should have passed 2 as g_skill_id
customerRaceID will be returned as 4
customerSkillID returns 3

*/
native W3_GenericSkillLevel(client,g_skill_id,&Handle:genericSkillData,&customerRaceID=0,&customerSkillID=0);

// MOVED TO W3PlayerProp.inc
//native W3SetPlayerProp(client,W3PlayerProp:property,any:value);
//native any:W3GetPlayerProp(client,W3PlayerProp:property);


//TKV = trie key value , a abstract data storage, emulates cvars for war3
///Creates internal war3 cvars. returns a id to your cvar, store it!
//cvarid of 0 is null null (filled auto)
//make sure native have binded (on plugin start is fine)
native W3CreateCvar(String:cvarstr[],String:cvarvalue[],String:cvardesc[],ReplaceCvar=0);
native W3GetCvar(cvarid,String:returnstr[],maxlen);
native W3SetCvar(cvarid,String:cvarvalue[]);

//returns -1 if not found, otherwise returns cvar id
native W3FindCvar(String:cvar[]);
native Handle:W3CvarList(); //returns a handle arraylist of cvar list (no values, names only. CLOSE THIS!!!

//get cvar value when you have the key
native W3GetCvarByString(String:cvarstr[],String:returnstr[],maxlen);

//get actual cvar name: undead_blah (the KEY)
native W3GetCvarActualString(cvarid,String:returnstr[],maxlen);


native W3IsDeveloper(client);
native W3IsHelper(client);

///use W3GetVar(hDatabase) to get the handle to the database which your xp is saved, so you dont have to connect again for your addon scipts

native bool:W3SaveEnabled();

native W3Log(const String:fmt[],any:...);
native W3LogError(const String:fmt[],any:...);
native W3LogNotError(const String:fmt[],any:...);

//Skills
native War3_SuicideBomber(client, Float:location[], Float:damage, race_skillid, Float:radius, bool:effect=true);

//disabled due to human race requirements..for now
//native bool:War3_Teleport(client, Float:distance);

//native War3_StringMath(String:equation[]);

native W3HasDiedThisFrame(client);

/**
 * Adds a dependency on a skill
 *
 * @param iRaceID		 Race ID
 * @param iSkill		 Skill on which the dependency should be added onto
 * @param iRequiredSkill Required Skill ID
 * @param iRequiredLevel Required Level Num
 * @return				 true on success, otherwhise false!
 * @error				 Thrown on invalid param num/race
 */
native bool:War3_SetDependency(iRaceID, iSkill, iRequiredSkill, iRequiredLevel);

/**
 * Removes any known dependency from a skill(if any)
 * NOTE: you should be able to call this safetly without having to bother about anything,
 * since no error will be thrown if there currently aren't any active dependencys on this
 *
 * @param iRaceID		 Race ID
 * @param iSkill		 Skill on which the dependency should be removed from
 * @noreturn
 * @error				 Thrown on invalid param num/race
 */
native War3_RemoveDependency(iRaceID, iSkill);

/**
 * Retrieves various informations about a depending skill
 * NOTE: This can be called to check if there is any dependency or not
 *
 * @param iRaceID		 Race ID
 * @param iSkill		 Target skill to get informations from
 * @param eInfo			 Type of information to retrieve
 * @return				 Retrieved information about the dependency
 * @error				 Thrown on invalid param num/race
 */
native War3_GetDependency(iRaceID, iSkill, SkillDependency:eInfo=ID);

// BOT THINGS!!

/**
 * Force a fake client to distribute his skillpoints
 *
 * @param client: client index
 */
native War3_bots_distribute_sp(client);
native War3_bots_pickrace(client);

/*create an error displayed in various places at runtime*/
native CreateWar3GlobalError(String:str[]);

native W3CreateEvent(W3EVENT:event,client);


// forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards
// forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards
// forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards
// forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards
// forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards
// forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards
// forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards
// forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards
// forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards
// forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards
// forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards
// forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards
// forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards
// forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards
// forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards
// forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards
// forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards
// forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards forwards


enum W3HookType
{
	W3Hook_OnW3TakeDmgAllPre, //p_OnW3TakeDmgAllPre
	W3Hook_OnW3TakeDmgBulletPre, //p_OnW3TakeDmgBulletPre
	W3Hook_OnW3TakeDmgAll, //p_OnW3TakeDmgAll
	W3Hook_OnW3TakeDmgBullet, //p_OnW3TakeDmgBullet
	W3Hook_OnWar3EventPostHurt, //p_OnWar3EventPostHurtFH

	W3Hook_OnWar3Event,

	W3Hook_OnUltimateCommand,
	W3Hook_OnAbilityCommand,
	W3Hook_OnUseItemCommand,

	W3Hook_OnWar3EventSpawn,

	W3Hook_OnWar3SkinChange,
	W3Hook_OnTalentsLoaded,

	W3Hook_OnWar3SkillSlotChange //p_OnWar3SkillSlotChange
	//W3Hook_,
};


typeset W3HookCB
{
	//W3Hook_OnWar3EventSpawn
	//W3Hook_OnTalentsLoaded
	function void (int client);

	//W3Hook_OnWar3Event
	function void (W3EVENT event, int client);

	//W3Hook_OnUseItemCommand
	function void (int client, int useitem, bool pressed);

	//W3Hook_FHOnW3TakeDmgAllPre
	//W3Hook_FHOnW3TakeDmgAll
	//W3Hook_FHOnW3TakeDmgBullet
	function Action (int victim, int attacker, float damage);

	//W3Hook_FHOnW3TakeDmgBulletPre
	function Action (int victim, int attacker, float damage, int damagecustom);

	//W3Hook_FHOnWar3EventPostHurtFH
	function Action (int victim, int attacker, float dmgamount, char weapon[32], bool isWarcraft, const float damageForce[3], const float damagePosition[3]);

	//W3Hook_OnAbilityCommand --> (int client, int ability, bool pressed, bool bypass)
	function void (int client, int ability, bool pressed, bool bypass);

	//W3Hook_OnUltimateCommand
	function void (int client, int race, bool pressed, bool bypass);

	//W3Hook_OnWar3SkinChange
	function void (int client, int newrace);

	//W3Hook_OnWar3SkillSlotChange
	function void (int client, int skillslot, int oldskillid, int newskillid);
};

/**
 * @brief Hooks for function
 *
 * @param		type					Type of function to hook
 * @param		callback				Function to call when hook is called
 * @param		AllowAutomaticHooking	Will Unhook/Rehook functions that are deemed not need for a round event.
 * 										Most likely will unload a function before round start, if is not a active boss
 * 										plugin, and rehook at round end.
 * @return		returns					nothing
 */
// possible future if sourcemod allows storing of functions:
//native void W3Hook(W3HookType type, W3HookCB callback, bool AllowAutomaticHooking = true);
native void W3Hook(W3HookType type, W3HookCB callback);

/**
 * @brief Hooks for function
 *
 * @param		type					Type of function to hook
 * @param		callback				Function to call when hook is called
 * @param		AllowAutomaticHooking	Will Unhook/Rehook functions that are deemed not need for a round event.
 * 										Most likely will unload a function before round start, if is not a active boss
 * 										plugin, and rehook at round end.
 * @return		returns					true if successful
 */
// possible future if sourcemod allows storing of functions:
//native bool W3HookEx(W3HookType type, W3HookCB callback, bool AllowAutomaticHooking = true);
native bool W3HookEx(W3HookType type, W3HookCB callback);

/**
 * @brief Unhooks a function
 * Removes a function from a private forward's call list.
 * Only removes one instance.
 * Functions will be removed automatically if their parent plugin is unloaded.
 *
 * @param		type		Type of function to unhook
 * @param		callback	Callback function to unhook
 * @return		returns		nothing
 */
native void W3Unhook(W3HookType type, W3HookCB callback);

/**
 * @brief Unhooks a function
 * Removes a function from a private forward's call list.
 * Only removes one instance.
 * Functions will be removed automatically if their parent plugin is unloaded.
 *
 * @param		type		Type of function to unhook
 * @param		callback	Callback function to unhook
 * @return		returns		true if successful
 */
native bool W3UnhookEx(W3HookType type, W3HookCB callback);

/**
 * @brief Unhooks a function
 * Removes all instances of a plugin from a private forward's call list.
 * Functions will be removed automatically if their parent plugin is unloaded.
 *
 * @param		type		Type of function to unhook
 * @param		callback	Callback function to unhook
 * @return		returns		nothing
 */
native void W3UnhookAll(W3HookType type);

/**
 * @brief Unhooks a function
 * Removes all instances of a plugin from a private forward's call list.
 * Functions will be removed automatically if their parent plugin is unloaded.
 *
 * @param		type		Type of function to unhook
 * @param		callback	Callback function to unhook
 * @return		returns		true if successful
 */
native bool W3UnhookAllEx(W3HookType type);




//Called for each category if the user opens the catted cr menu
forward Action:OnW3DrawCategory(client,categoryindex,String:categoryname[]);

/**********************
 * Implement this if you have natives/forwards
 */
forward bool:InitNativesForwards();

/**********************
 * Implement this if you need AskPluginLoad2Custom
 */
forward APLRes:AskPluginLoad2Custom(Handle:plugin,bool:late,String:error[],err_max);



//forwarded when someone calls CreateWar3GlobalError, store that string for yourself
forward OnWar3GlobalError(String:str[]);

//forward War3FailedSignal(String:str[]);
/* interface side implementation, do not use */
//public War3FailedSignal(String:str[]) {
	//LogError(str); //must be a non dependent native log error
	//SetFailState(str);
//}

/**
 * Called when the plugin is ready.
 * this is called many times, increasing num each time 0.0-float(MAXRACES)*10 in 1 increments
 * USED FOR OFFICIAL PLUGINS ONLY
 */
forward OnWar3LoadRaceOrItemOrdered(num);

/*
 * called when a player goes afk from the afk manager
*/
forward OnWar3PlayerAFK(client);

/**
 * Called when the plugin is ready. (after ordered)
 */
forward OnWar3PluginReady();


/**
 * Called to send id back to plugin if it changes (usually called on a plugin reload)
 */
//forward OnWar3PluginRaceId(String:plugin_shortname[16],reload_raceid);

/**
 * Gets called when after PutInServer, xp retrievcal has started, initial variables may have been set
 * @param client: The client's index.
 */
forward OnWar3PlayerAuthed(client);

/**
 * Gets called when the +ultimate or -ultimate command is called, IT ISNT ALWAYS FOR YOUR RACE, YOU NEED TO CHECK!!!
 * @param client: The client's index.
 * @param race: The race for which it was called.
 * @param pressed: If true, +ultimate, false, -ultimate.
 */
//forward OnUltimateCommand(client,race,bool:pressed,bool:bypass);

/**
 * Gets called when the +ability# or -ability# command is called.
 * If its +ability or -ability (without a number), 0 is passed to ability.
 * Isn't always for you, check War3_GetRace(client)==yourRace
 * @param client: The client's index.
 * @param ability: The ability number.
 * @param pressed: If true, +ability#, false, -ability#.
 * @param bypass: If true, a separate part of the program is requesting to bypass your race restrictions to use the ability.
 */
//forward OnAbilityCommand(client,ability,bool:pressed,bool:bypass);

/**
 * Gets called when the +ability# or -ability# command is called.
 * If its +ability or -ability (without a number), 0 is passed to ability.
 * Isn't always for you, check War3_GetRace(client)==yourRace
 * @param client: The client's index.
 * @param useitem: The useitem number.  (+useitem,+useitem1,+useitem2,etc)
 * @param pressed: If true, +ability#, false, -ability#.
 */
//forward OnUseItemCommand(client,useitem,bool:pressed);

/**
 * Gets called when a skill level is changed.
 */
forward void OnSkillLevelChanged(int client, int currentrace, int skill, int newskilllevel, int oldskilllevel);


///general events, see W3EVENT enum in constants
///client may not always matter
//forward void OnWar3Event(W3EVENT event, int client);

//when player spawns, fires only in war3 mode
//forward OnWar3EventSpawn(client);

//when player dies, fires only in war3 mode
//Distance in feet
//forward OnWar3EventDeath(victim, attacker, deathrace, distance, attacker_hpleft, String:weapon[32]);
forward OnWar3EventDeath(victim, attacker, deathrace, distance, attacker_hpleft);

//very generic damage event
//derrived from the game engine's posthurt event
//FRIENDLY FIRE IS NOT FILTERED
//forward OnWar3EventPostHurt(victim,attacker,dmgamount,const String:weapon[32],bool:isWarcraft,const Float:damageForce[3], const Float:damagePosition[3]);

//Fired after a player dodges, useful primarily for attaching effects
forward OnW3DodgePost(victim, attacker);

//Fired before a player dodges, you can edit the dodge chance here
forward OnW3DodgePre(victim,attacker,Float:chance);


// DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM
// DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM
// DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM
// DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM
// DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM
// DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM
// DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM
// DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM
// DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM
// DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM
// DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM
// DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM
// DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM
// DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM
// DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM
// DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM
// DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM
// DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM
// DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM
// DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM   DENY SYSTEM

//simple system for stopping actions, send a specific event with optinal player, those hooking can use W3Deny() to deny
forward OnW3Denyable(W3DENY:event,client);
native bool:W3Denied(W3DENY:event,client); //returns FALSE if NOT DENIED
stock bool:W3Denyable(W3DENY:event,client) {
	return !W3Denied(event,client);
}
native W3Deny();

/*
 * STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
 * STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
 * STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
 * STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
 * STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
 * STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
 * STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
 * STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
 * STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
 * STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
 * STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
 * STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
 * STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
 * STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
 * STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
 * STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
 * STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
 * STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
 * STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
 */

// FOF doesn't display hints correctly
stock W3PrintHint(int client, const char[] format, any ...)
{
	// for the format
	char buffer[254];
	VFormat(buffer, sizeof(buffer), format, 2);

	//halflife.inc
	//native void PrintHintText(int client, const char[] format, any ...);
#if GGAMETYPE == GGAME_FOF
	War3_ChatMessage(client, buffer);
#else
	PrintHintText(client, buffer);
#endif
}


#if GGAMETYPE == GGAME_CSGO
stock void CSGO_RADAR(int client,bool TurnON)
{
	if(ValidPlayer(client) && !IsFakeClient(client))
	{
		if(TurnON)
		{
			int hudflags = GetEntProp(client, Prop_Send, "m_iHideHUD");
			if(hudflags & HIDE_RADAR)
			{
				hudflags &= ~HIDE_RADAR;
				hudflags &= ~HIDEHUD_CHAT;
				SetEntProp(client, Prop_Send, "m_iHideHUD", hudflags);
			}
		}
		else
		{
			int hudflags = GetEntProp(client, Prop_Send, "m_iHideHUD");
			if(!(hudflags & HIDE_RADAR))
			{
				hudflags |= HIDE_RADAR;
				hudflags |= HIDEHUD_CHAT;
				SetEntProp(client, Prop_Send, "m_iHideHUD", hudflags);
			}
		}
	}
}
#endif

///check race limit and force re-choose race
stock CheckRaceTeamLimit(raceid,team)
{

	new Float:youngest=-1.0;
	new target=0;
	for(new i=1;i<=MaxClients;i++){
		if(ValidPlayer(i))
		{
			if(War3_GetRace(i)==raceid&&!W3IsDeveloper(i))
			{
				if(GetClientTeam(i)==team)
				{
					if(W3GetPlayerProp(i,LastChangeTeamTime)>youngest){
						target=i;
						youngest=W3GetPlayerProp(i,LastChangeTeamTime);
					}
				}
			}
		}
	}
	if(target>0)
	{
		War3_SetRace(target,0);
		char racename[64];
		War3_GetRaceName(raceid,racename,sizeof(racename));
		War3_ChatMessage(target,"%T","{race} race team limit has reached (MAX {amount}), please select a different job",target,racename,W3GetRaceMaxLimitTeam(raceid,team));
		PrintToConsole(target,"Your job has been set via raceutils.inc");
		int cvar=W3GetRaceMaxLimitTeamCvar(raceid,team);
		char cvarstr[64];
		if(cvar>-1){
			W3GetCvarActualString(cvar,cvarstr,sizeof(cvarstr));
		}
		cvar=W3FindCvar(cvarstr);
		char cvarvalue[64];
		if(cvar>-1){
			W3GetCvar(cvar,cvarvalue,sizeof(cvarvalue));
		}

		W3Log("job %s blocked on client %d due to restrictions limit %d (CheckRaceTeamLimit)  %s %s",racename,target,W3GetRaceMaxLimitTeam(raceid,team),cvarstr,cvarvalue);

		W3CreateEvent(DoShowChangeRaceMenu,target);
	}

}

stock CheckPendingRace(client)
{
	int pendingrace=W3GetPendingRace(client);
	if(pendingrace>0)
	{
		W3SetPendingRace(client,-1);

		/*GetConVarInt(W3GetVar(hRaceLimitEnabledCvar))>0&&
		GetRacesOnTeam(pendingrace,GetClientTeam(client))>=W3GetRaceMaxLimitTeam(pendingrace,GetClientTeam(client))*/
		if(	CanSelectRace(client,pendingrace)||W3IsDeveloper(client))
		{
			War3_SetRace(client,pendingrace);
		}
		else
		{   //already at limit
			//War3_ChatMessage(client,"%T","Race limit for your team has been reached, please select a different race. (MAX {amount})",GetTrans(),W3GetRaceMaxLimitTeam(pendingrace,GetClientTeam(client)));
			//W3Log("race %d blocked on client %d due to restrictions limit (CheckPendingRace)",pendingrace,client);
			W3CreateEvent(DoShowChangeRaceMenu,client);
		}

	}
	///wasnt pending
	else if(War3_GetRace(client)==0){
		W3CreateEvent(DoShowChangeRaceMenu,client);
	}
	else if(War3_GetRace(client)>0){
		if(!CanSelectRace(client,War3_GetRace(client))){
			War3_SetRace(client,0);
			PrintToConsole(client,"Your race is set to zero via gameevents.inc");
		}
	}
}

stock GetFlagCarrier(team)
{
	new ent = -1;
	while ((ent = FindEntityByClassname(ent, "item_teamflag")) != -1)
	{
		new owner = GetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity");
		if (owner > 0)
		{
			if (GetClientTeam(owner) == team)
				return owner;
		}
	}
	return -1;
}

stock Float:calcDistance(Float:x1,Float:x2,Float:y1,Float:y2,Float:z1,Float:z2){
	//Distance between two 3d points
	new Float:dx = x1-x2;
	new Float:dy = y1-y2;
	new Float:dz = z1-z2;

	return(SquareRoot(dx*dx + dy*dy + dz*dz));
}


stock bool:IsRaceFaction(raceid,String:faction[]) {
	if(raceid>0)
	{
		decl String:factionbuffer[FACTION_LENGTH];
		W3GetRaceFaction(raceid,factionbuffer,sizeof(factionbuffer));
		if(StrEqual(factionbuffer,faction,false)) {
			return true;
		}
	}
	return false;
}


/**
 * Stock, checks if a player is near any entity in a datapack of entities, again by name.
 * @param client: Client's index.
 * @param hEnts: Datapack of entity names.
 * @param pack_size: Size of datapack.
 * @param distance: Optional, how far is "near."
 * @return ADT array of results, otherwise INVALID_HANDLE.
 * DO NOT FORGET TO CloseHandle() the results if they don't equal INVALID_HANDLE!!!
 */
stock Handle:War3_NearEntsByName(client,Handle:hEnts,pack_size,Float:distance=150.0)
{
	new Handle:hResults=CreateArray();
	ResetPack(hEnts);
	for(new x=0;x<pack_size;x++)
	{
		new String:ent_name[128];
		ReadPackString(hEnts,ent_name,sizeof(ent_name));
		new Handle:result_found=War3_NearEntByName(client,ent_name,distance);
		if(result_found!=INVALID_HANDLE)
		{
			new size=GetArraySize(result_found);
			for(new y=0;y<size;y++)
			{
				PushArrayCell(hResults,GetArrayCell(result_found,y));
			}
			CloseHandle(result_found);
		}
	}
	if(GetArraySize(hResults)>0)
	return hResults;
	else
	{
		CloseHandle(hResults);
		return INVALID_HANDLE;
	}
}

stock Handle:War3_NearEntByName(client,String:ent_name[],Float:distance)
{
	if(distance<0.0)
	return INVALID_HANDLE; // wtf? lol
	if(client>0 && client<=MaxClients && IsClientConnected(client) && IsClientInGame(client) && IsPlayerAlive(client))
	{
		new Handle:hResults=CreateArray();
		new Float:curPos[3];
		GetClientAbsOrigin(client,curPos);
		new ent=0;
		while((ent=FindEntityByClassname(ent,ent_name))>0)
		{
			if(!IsValidEdict(ent)) continue;
			new Float:entPos[3];
			GetEntPropVector(ent,Prop_Send,"m_vecOrigin",entPos);
			new Float:dist=GetVectorDistance(curPos,entPos);
			if(dist<=distance)
			{
				PushArrayCell(hResults,ent);
			}
		}
		if(GetArraySize(hResults)>0)
		{
			return hResults;
		}
		else
		{
			CloseHandle(hResults);
		}
	}
	return INVALID_HANDLE;
}
#if GGAMETYPE == GGAME_TF2
/**
 * Stock, checks if a player is near an engineer building.
 * @param client: Client's index.
 * @param distance: Optional, how far is "near."
 * @return ADT array of results, otherwise INVALID_HANDLE
 * DO NOT FORGET TO CloseHandle() the results if they don't equal INVALID_HANDLE!!!
 */
stock Handle:War3_NearBuilding(client,Float:distance=150.0)
{
	new Handle:hEnts=CreateDataPack();
	WritePackString(hEnts,"obj_dispenser");
	WritePackString(hEnts,"obj_sentrygun");
	WritePackString(hEnts,"obj_teleporter_entrance");
	WritePackString(hEnts,"obj_teleporter_exit");
	new Handle:result=War3_NearEntsByName(client,hEnts,4,distance);
	CloseHandle(hEnts);
	return result;
}
#endif

stock W3Hint_Default(client, String:format[], any:...)
{
	decl String:sOutput[128];
	VFormat(sOutput, sizeof(sOutput), format, 3);
	return W3Hint(client, _, _, sOutput);
}

stock W3Hint_Skill(client, String:format[], any:...)
{
	decl String:sOutput[128];
	VFormat(sOutput, sizeof(sOutput), format, 3);
	return W3Hint(client, HINT_SKILL_STATUS, _, sOutput);
}

stock W3CreateCvarInt(String:cvarstr[],intval,String:cvardesc[]) {
	decl String:str[1024];
	Format(str,sizeof(str),"%d",intval);
	return W3CreateCvar(cvarstr,str,cvardesc);
}
stock W3GetCvarInt(cvarid) {
	decl String:ret[1024];
	W3GetCvar(cvarid, ret, sizeof(ret));
	//PrintToChatAll("%s %d",ret,StringToInt(ret));
	return StringToInt(ret);
}
stock W3SetCvarInt(cvarid, intval) {
	decl String:str[1024];
	Format(str, sizeof(str), "%d", intval);
	return W3SetCvar(cvarid, str);
}
stock W3CreateCvarFloat(String:cvarstr[],intval,String:cvardesc[]) {
	decl String:str[1024];
	Format(str,sizeof(str),"%f",intval);
	W3CreateCvar(cvarstr,str,cvardesc);
}
stock W3GetCvarFloat(cvarid) {
	decl String:ret[1024];
	W3GetCvar(cvarid, ret, sizeof(ret));
	return StringToFloat(ret);
}
stock W3SetCvarFloat(cvarid, intval) {
	decl String:str[1024];
	Format(str, sizeof(str), "%f", intval);
	W3SetCvar(cvarid, str);
}

stock War3_SetMaxHP_INTERNAL(client, maxhp) {
	//	DP("set to %d",maxhp);
	W3SetPlayerProp(client, iMaxHP, maxhp);
}
stock int War3_GetMaxHP(client)
{
	//DP("add %d",W3GetBuffSumInt(client,iAdditionalMaxHealth));
	return W3GetPlayerProp(client, iMaxHP);//+ W3GetBuffSumInt(client,iAdditionalMaxHealth);
}
// After a player is assigned a race in DatabaseXP
// This is the event that happens after the PlayerXPLoaded is assigned a variable.
stock bool:W3IsPlayerRaceLoaded(client) {
	return W3GetPlayerProp(client,dbRaceSelected);
}
stock W3GetPendingRace(client) {
	return W3GetPlayerProp(client, PendingRace);
}
stock W3SetPendingRace(client, pendrace) {
	W3SetPlayerProp(client, PendingRace, pendrace);
}
stock War3_SetGold(client, newgold) {
	W3SetPlayerProp(client, PlayerGold, newgold);
}
stock War3_GetGold(client) {
	return W3GetPlayerProp(client, PlayerGold);
}


stock War3_GetDiamonds(client) {
	return W3GetPlayerProp(client, PlayerDiamonds);
}
stock War3_SetDiamonds(client, newd) {
	W3SetPlayerProp(client, PlayerDiamonds, newd);
}


stock War3_GetPlatinum(client) {
	return W3GetPlayerProp(client, PlayerPlatinum);
}
stock War3_SetPlatinum(client, newd) {
	W3SetPlayerProp(client, PlayerPlatinum, newd);
}


stock bool:CanSelectRace(client,race,bool:silence=false) {
	W3SetVar(EventArg1,race);
	W3SetVar(EventArg2,silence);
	new bool:value=W3Denyable(DN_CanSelectRace,client);
	//DP("dp %d",value);
	if(value==false && W3IsDeveloper(client)) {
		//DP("dp2 %d",value);
		War3_ChatMessage(client,"You are normally not allowed to select this race, but since you are developer we will allow you to select this race");

		return true;
	}
	return value;
}

stock ShowChangeRaceMenu(client) {
	W3CreateEvent(DoShowChangeRaceMenu, client);
}

stock W3DoLevelCheck(client) {
	W3CreateEvent(DoLevelCheck, client);
}


//=======================================================================
//                                 CSS Stocks
//=======================================================================
#if (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
/**
 * Changes a clients armor value.
 *
 * @param client Client index
 * @param amount Armor value
 * @noreturn
 */
stock War3_SetCSArmor(client, amount) {
	// Revan: thoose armor properities for CS:GO are the same as in CS:Source
	if (amount > 125) {
		amount = 125;
	}
	SetEntProp(client, Prop_Send, "m_ArmorValue", amount);
}

/**
 * Retrieves a clients armor value.
 *
 * @param client Client index
 * @return Armor value
 */
stock War3_GetCSArmor(client) {
	return GetEntProp(client, Prop_Send, "m_ArmorValue");
}

/**
 * Returns whether the client is currently wearing a helmet or not.
 *
 * @param client Client index
 * @return True if client is wearing a helmet
 */
stock bool:War3_GetCSArmorHasHelmet(client) {
	return bool:GetEntProp(client, Prop_Send, "m_bHasHelmet");
}

/**
 * Gives or removes a helmet from the player.
 *
 * @param client Client index
 * @param hashelmet True to give helmet, false to remove
 * @noreturn
 */
stock War3_SetCSArmorHasHelmet(client,bool:hashelmet) {
	return SetEntProp(client, Prop_Send, "m_bHasHelmet",hashelmet? 1:0, 1);
}

/**
 * Restores players armor and helmet.
 *
 * @param client Client index
 * @noreturn
 */
native War3_RestoreCachedCSArmor(client);

// Create Effect for Counter Strike Source:
stock CSParticle(const client, const level)
{
	new particle = CreateEntityByName("env_smokestack");
	if(IsValidEdict(particle) && IsClientInGame(client))
	{
		decl String:Name[32], Float:fPos[3];
		Format(Name, sizeof(Name), "CSParticle_%i_%i", client, level);
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", fPos);
		fPos[2] += 28.0;
		new Float:fAng[3] = {0.0, 0.0, 0.0};

		// Set Key Values
		DispatchKeyValueVector(particle, "Origin", fPos);
		DispatchKeyValueVector(particle, "Angles", fAng);
		DispatchKeyValueFloat(particle, "BaseSpread", 15.0);
		DispatchKeyValueFloat(particle, "StartSize", 2.0);
		DispatchKeyValueFloat(particle, "EndSize", 6.0);
		DispatchKeyValueFloat(particle, "Twist", 0.0);

		DispatchKeyValue(particle, "Name", Name);
		DispatchKeyValue(particle, "SmokeMaterial", "effects/combinemuzzle2.vmt");
		DispatchKeyValue(particle, "RenderColor", "252 232 131");
		DispatchKeyValue(particle, "SpreadSpeed", "10");
		DispatchKeyValue(particle, "RenderAmt", "200");
		DispatchKeyValue(particle, "JetLength", "13");
		DispatchKeyValue(particle, "RenderMode", "0");
		DispatchKeyValue(particle, "Initial", "0");
		DispatchKeyValue(particle, "Speed", "10");
		DispatchKeyValue(particle, "Rate", "173");
		DispatchSpawn(particle);

		// Set Entity Inputs
		SetVariantString("!activator");
		AcceptEntityInput(particle, "SetParent", client, particle, 0);
		AcceptEntityInput(particle, "TurnOn");
		particle = EntIndexToEntRef(particle);
		SetVariantString("OnUser1 !self:Kill::3.5:-1");
		AcceptEntityInput(particle, "AddOutput");
		AcceptEntityInput(particle, "FireUser1");
	}
	else
	{
		LogError("Failed to create env_smokestack!");
	}
}
#endif

stock GetRealClientCount( bool:inGameOnly = true ) {
	new clients = 0;
	for(new i=1; i<GetMaxClients()+1; i++) {
		if(((inGameOnly) ? IsClientInGame(i): IsClientConnected(i)) && !IsFakeClient(i)){
			clients++;
		}
	}
	return clients;
}


/**
 * Returns the client's Score.
 *
 * @param client			Client's index.
 * @return					Score.
 */
stock War3_GetScore(client)
{
	return GetClientFrags(client);
}

/**
 * Sets the client's Score.
 *
 * @param client			Client's index.
 * @param value				Score.
 * @noreturn
 */
stock War3_SetScore(client, value)
{
	SetEntProp(client, Prop_Data, "m_iFrags", value);
}


//who should the tanslated phrase be translated to, 0 = server default language
stock SetTrans(client) {
	W3SetVar(TransClient, client);
}
stock GetTrans() {
	return W3GetVar(TransClient);
}

stock bool:IS_PLAYER(x)
{
	if(x>0&&x<=MaxClients)
	return true;
	return false;
}

/*
 There are two ways to get admin
 //need
 //good if you need the string to admin flag like "o" -> number
 id= native bool:GetAdminFlag(AdminId:id, AdminFlag:flag, AdmAccessMode:mode=Access_Effective);
 Admin_RCON,
 Admin_Root,

 VS

 //good if u know the access level
 GetUserFlagBits(client)

 ADMFLAG_RCON
 ADMFLAG_ROOT
 */


/* is a normal engine cvar empty (zero length, "") ? */
stock bool:CvarEmpty(Handle:sourcemod_convar) {
	static String:zzstr[32];
	return (GetConVarString(sourcemod_convar, zzstr, sizeof(zzstr))&&strlen(zzstr)<1);

}

//returns true/false on a chance cast. 1.0=100%, 0.1 = 10% chance
stock bool:War3_Chance(Float:chancepercent=1.0) {
	return (GetRandomFloat(0.0,1.0)<=chancepercent);
}
stock bool:W3Chance(Float:chancepercent=1.0) {
	return (GetRandomFloat(0.0,1.0)<=chancepercent);
}

/**
 * Returns the amount of money you have in CS/CS:GO
 * When used in TF2 it returns the amount of money the player has in MVM
 */
stock GetCSMoney(client) {
#if (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
	return GetEntProp(client, Prop_Send, "m_iAccount");
#elseif GGAMETYPE == GGAME_TF2
	return GetEntProp(client, Prop_Send, "m_nCurrency");
#else
	return 0;
#endif
}

/**
 * Sets the amount of money the player has in CS/CS:GO
 * When used in TF2 it sets the amount of money the player has in MVM
 */
stock SetCSMoney(client, newamount) {
	if (newamount < 0)
		newamount = 0;
	if (newamount > 32767)
		newamount = 32767;
#if (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
	SetEntProp(client, Prop_Send, "m_iAccount", newamount);
#elseif GGAMETYPE == GGAME_TF2
	SetEntProp(client, Prop_Send, "m_nCurrency", newamount);
#endif
}

stock UTIL_Remove(entity) {
	if (IsValidEdict(entity))
		AcceptEntityInput(entity, "Kill");
}

stock W3ShowSkillsInfo(client)
{
	if (War3_GetRace(client) > 0) {
		W3SetVar(RaceinfoRaceToShow, War3_GetRace(client));
		W3CreateEvent(DoShowParticularRaceInfo, client);
	} else {
		War3_ChatMessage(client, "Select a race first!");
		W3CreateEvent(DoShowChangeRaceMenu, client);
	}
}

//get numver of players on the specified team (integer team)
stock PlayersOnTeam(team) {
	new num;
	for (new x = 1; x <= MaxClients; x++) {
		if (IsClientInGame(x) && GetClientTeam(x) == team) {
			num++;
		}
	}
	return num;
}

stock GetShortTeamName(team,String:retstr[],maxlen) {
	if(team==1) {
		Format(retstr,maxlen,"%t","TF Spec");
		return;
	}
	if(team==TEAM_RED) {
		Format(retstr,maxlen,"%t","TF RED");
		return;
	}
	if(team==TEAM_BLUE) {
		Format(retstr,maxlen,"%t","TF BLU");
		return;
	}

	Format(retstr,maxlen,"%t","Unknown Team");
	return;
}

stock GetTeamColor(client,String:retstr[],maxlen)
{
	new team = GetClientTeam(client);
	if(team==1) {
		Format(retstr,maxlen,"{default}");
		return;
	}
	if(team==TEAM_RED) {
		Format(retstr,maxlen,"{red}");
		return;
	}
	if(team==TEAM_BLUE) {
		Format(retstr,maxlen,"{blue}");
		return;
	}

	Format(retstr,maxlen,"{default}");
	return;
}

#if GGAMETYPE == GGAME_TF2
stock bool:TF2_HasTheFlag(client)
{
	new ent = -1;
	while ((ent = FindEntityByClassname(ent, "item_teamflag")) != -1)
	{
		if (GetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity")==client)
		return true;
	}
	return false;
}
#endif
stock TE_SetupKillPlayerAttachments(client) {
	TE_Start("KillPlayerAttachments");
	TE_WriteNum("m_nPlayer", client);
}

// Stocks
stock StrToken(const String:inputstr[],tokennum,String:outputstr[],maxlen)
{
	new String:buf[maxlen+1];
	new cur_idx;
	new idx;
	new curind;
	idx=BreakString(inputstr,buf,maxlen);
	if(tokennum==1)
	{
		strcopy(outputstr,maxlen,buf);
		return;
	}
	curind=1;
	while(idx!=-1)
	{
		cur_idx+=idx;
		idx=BreakString(inputstr[cur_idx],buf,maxlen);
		curind++;
		if(tokennum==curind)
		{
			strcopy(outputstr,maxlen,buf);
			break;
		}
	}
}

stock StrTokenCount(const String:input[])
{
	decl String:buf[32];
	new cur_idx;
	new idx;
	new curind;
	while(idx!=-1)
	{
		cur_idx+=idx;
		idx=BreakString(input[cur_idx],buf,sizeof(buf));
		curind++;
	}
	return curind;
}

stock Float:GetPlayerDistance(client1,client2) {
	static Float:vec1[3];
	static Float:vec2[3];
	GetClientAbsOrigin(client1,vec1);
	GetClientAbsOrigin(client2,vec2);
	return GetVectorDistance(vec1,vec2);
}
#if GGAMETYPE == GGAME_TF2
stock bool:Spying(client)
{
	// Can a class really be disguised if not SPY?  or cloaked if not spy??
	if(TF2_GetPlayerClass(client)==TFClass_Spy)
	{
		return (TF2_IsPlayerInCondition(client,TFCond_Disguising)||TF2_IsPlayerInCondition(client,TFCond_Disguised) || TF2_IsPlayerInCondition(client,TFCond_Cloaked));
	}
	return false;
}
//team 2 3 swapped if spying
stock GetApparentTeam(client) {
	new team = GetClientTeam(client);
	if (Spying(client)) {
		if (team == 2)
			team++;
		else if (team == 3)
			team--;
	}
	return team;
}
#endif
native W3IsBuffInvised(client); //returns true if client alpha is <50

//invisible or cloaked?
#if GGAMETYPE == GGAME_TF2
stock IsInvis(client) {
	return (TF2_IsPlayerInCondition(client, TFCond_Cloaked)
			|| W3IsBuffInvised(client));
}
#endif

stock PrintPlugin(Handle:plugin) {
	new String:str[100];
	GetPluginFilename(Handle:plugin, str, sizeof(str));
	W3LogNotError("%s",str);
}
stock PrintPluginError(Handle:plugin) {
	new String:str[100];
	GetPluginFilename(Handle:plugin, str, sizeof(str));
	LogError("%s",str);
	W3LogError("%s",str);
}

///find a "string" in a war3cvar that is delimited by commas "rubbish,string" = true
stock bool:W3FindStringInCvar(cvarid,String:findme[],max=9999) {
	decl String:cvarstr[100];
	decl String:exploded[32][32];

	W3GetCvar(cvarid,cvarstr,sizeof(cvarstr));

	new num;
	if(strlen(cvarstr)>0) {
		num=ExplodeString(cvarstr,",",exploded,256,256);
		for(new i=0;i<num && i<max;i++) {
			//PrintToServer("'%s' compared to: '%s' num%d",exploded[i],itemShort,num);
			if(StrEqual(exploded[i],findme,false)) {
				//PrintToServer("TRUE");
				return true;
			}
		}
	}
	return false;
}

// Picks a random player currently ingame.
stock W3GetRandomPlayer(team,bool:check_alive=false,War3Immunity:check_immunity=Immunity_None) {

	new clients[MaxClients+1], clientCount;
	for (new i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && (GetClientTeam(i) == team) && (!check_alive || IsPlayerAlive(i)) && (!W3HasImmunity(i,check_immunity)))
			clients[clientCount++] = i;
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)];
}

// Returns true if a and b are the same
stock bool:VectorEquals(const Float:a[3], const Float:b[3])
{
	if(a[0]==b[0] && a[1]==b[1] && a[2]==b[2]) {
		return true;
	}
	return false;
}

/**
 * Returns UNIX time (integer)
 */
stock NOW() {
	return GetTime();
}
/**
 * returns the larger integer of the two
 */
stock IntMax(one, two) {
	return one > two ? one : two;
}

//what we want is something that always increments even past map changes
//not intended to matter of game pauses or not (tick)
stock Float:AbsoluteTime() {
	return GetEngineTime();
}

#if GGAMETYPE == GGAME_TF2
stock bool:IsMvM(bool:forceRecalc = false)
{
//	new String:mapname[256];
	//GetCurrentMap(mapname, 255);
	//if(StrContains(mapname,"mvm",false))
		//return true;

	static bool:found = false;
	static bool:ismvm = false;
	if (forceRecalc)
	{
		found = false;
		ismvm = false;
	}
	if (!found)
	{
		new i = FindEntityByClassname(-1, "tf_logic_mann_vs_machine");
		if (i > MaxClients && IsValidEntity(i)) ismvm = true;
		found = true;
	}
	return ismvm;
}
#endif

/**
 * If the player does not have enough levels,
 * It will tell the player and return false,
 * otherwise it will say nothing and return true.
 *
 */
stock bool:HasLevels(client,SkillLevel,RequiredLevel=1)
{
	if(SkillLevel>=RequiredLevel)
	{
		return true;
	}
	if(ValidPlayer(client))
	{
		if(RequiredLevel>1)
		{
			new NeedLevels = RequiredLevel-SkillLevel;
			if(NeedLevels==1)
			{
				W3Hint(client,HINT_SKILL_STATUS,5.0,"You need %d more level!",NeedLevels);
			}
			else
			{
				W3Hint(client,HINT_SKILL_STATUS,5.0,"You need %d more levels!",NeedLevels);
			}
		}
		else
		{
			W3Hint(client,HINT_SKILL_STATUS,5.0,"You do not have enough levels!");
		}
	}
	return false;
}


stock void Directory_AddFileToDownloadsTable(char[] custom_path)
{
	char path[PLATFORM_MAX_PATH];
	FileType type;

	Handle dir = OpenDirectory(custom_path);
	if (dir == INVALID_HANDLE)
	{
		return;
	}
	char ThePath[PLATFORM_MAX_PATH];

	while (ReadDirEntry(dir, path, sizeof(path), type))
	{
		if (type == FileType_File)
		{
			Format(ThePath, sizeof(ThePath), "%s%s",custom_path,path);

			//if(StrContains(path,".mdl") != -1)
			//{
				//PrecacheModel(ThePath,true);
			//}

			if(FileExists(ThePath, true))
			{
				AddFileToDownloadsTable(ThePath);
				LogError(ThePath);
			}
		}
	}

	CloseHandle(dir);
}

stock void RemoveCosmetics(iClient)
{
	int ent=-1;
	while ( ( ent = FindEntityByClassname( ent, "tf_wearable*" ) ) != -1 )
	{
		int owner = GetEntPropEnt( ent, Prop_Send, "m_hOwnerEntity" );
		if ( owner == iClient )
		{
			int iItemDefinitionIndex = GetEntProp(ent, Prop_Send, "m_iItemDefinitionIndex");
			if (iItemDefinitionIndex!=133)
				TF2_RemoveWearable(iClient,ent);
		}
	}
}


//stock CreateTimer_DEBUG(any:f=0,any:ff=0,any:fff=0,any:ffff=0) {}


// OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS ||||
// OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS ||||
// OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS ||||
// OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS ||||
// OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS ||||
// OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS ||||
// OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS ||||
// OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS ||||
// OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS ||||
// OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS ||||
// OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS ||||
// OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS ||||
// OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS ||||
// OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS ||||
// OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS ||||
// OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS ||||
// OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS ||||
// OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS ||||
// OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS ||||
// OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS ||||
// OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS ||||
// OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS ||||
// OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS ||||
// OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS ||||
// OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS ||||
// OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS |||| OTHER STOCKS NATIVES AND FORWARDS ||||


// Stocks, Natives, and Forwards:
#include "War3Source/include/War3Source_Aura.inc"
#include "War3Source/include/War3Source_Effects.inc"
#include "War3Source/include/War3Source_Wards.inc"
#include "War3Source/include/War3Source_Logging.inc"
#include "War3Source/include/War3Source_Damage.inc"
#include "War3Source/include/War3Source_Notifications.inc"
#include "War3Source/include/War3Source_Buffs.inc"
// Stocks, Natives, and Forwards:
#include "War3Source/include/War3Source_stocks_precache.inc"
#include "War3Source/include/War3Source_stocks_misc.inc"

#if SHOPMENU3 == MODE_ENABLED
#include "War3Source/include/War3Source_Shopmenu3.inc"
#endif

#include "War3Source/include/War3Source_SkillEffects.inc"
#include "War3Source/include/War3Source_Engine_Download_Control.inc"
#include "War3Source/include/War3Source_XP_Gold.inc"
#include "War3Source/include/War3Source_Health.inc"
#include "War3Source/include/War3Soruce_CoolDown_Manager.inc"
#include "War3Source/include/War3Source_Messages.inc"
#include "War3Source/include/War3Source_SQL.inc"
#include "War3Source/include/War3Source_ShopItems.inc"
#include "War3Source/include/War3Source_ShopItems2.inc"

#include "War3Source/include/War3Source_Addon_Bank.inc"

#include "War3Source/include/War3Source_WardChecking"
#include "War3Source/include/War3Source_WCX_Engine_Teleport.inc"
#include "War3Source/include/War3Source_Casting.inc"

#include "War3Source/include/War3Source_OnW3SupplyLocker.inc"
#include "War3Source/include/War3Source_OnW3HealthPickup.inc"

#include "War3Source/include/War3Source_Engine_SkillsClass.inc"

// not included for now
//#include "War3Source/include/War3Source_Talents.inc"

// METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS
// METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS
// METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS
// METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS
// METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS
// METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS
// METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS
// METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS
// METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS METHODMAPS

methodmap W3player
{
	public W3player(int playerindex) //constructor
	{
		if(!ValidPlayer(playerindex)) return view_as<W3player>(0);
		return view_as<W3player>(playerindex); //make sure you do validity check on players
	}
	 property int index
	{
		public get() { return view_as<int>(this); }
	}
	 property int idx
	{
		public get() { return view_as<int>(this); }
	}
	 property bool alive
	{
		public get() { return ValidPlayer(this.index,true); }
	}
	 property bool trulyalive
	{
		public get() { return ValidPlayer(this.index,true,true); }
	}
	 property int team
	{
		public get() { return GetClientTeam(this.index); }
	}
	property int maxhp
	{
		public get() { return W3GetPlayerProp(this.index, iMaxHP); }
		public set( int value ) { W3SetPlayerProp(this.index, iMaxHP, value); }
	}
	property int gold
	{
		public get() { return W3GetPlayerProp(this.index, PlayerGold); }
		public set( int value ) { W3SetPlayerProp(this.index, PlayerGold, value); }
	}
	property int bankgold
	{
		public get() { return War3_GetGoldBank(this.index); }
		public set( int value ) { War3_SetGoldBank(this.index,value); }
	}
	property int diamonds
	{
		public get() { return W3GetPlayerProp(this.index, PlayerDiamonds); }
		public set( int value ) { W3SetPlayerProp(this.index, PlayerDiamonds, value); }
	}
	property int platinum
	{
		public get() { return W3GetPlayerProp(this.index, PlayerPlatinum); }
		public set( int value ) { W3SetPlayerProp(this.index, PlayerPlatinum, value); }
	}
	property int raceid
	{
		public get()
		{
			return War3_GetRace(this.index);
		}
		public set( int value )
		{
			War3_SetRace(this.index, value);
		}
	}
	property bool inspawn
	{
		public get() { return view_as<bool>(War3_IsInSpawn(this.index)); }
	}
	property bool thirdperson
	{
		public get() { return War3_IsThirdPerson(this.index); }
		public set( bool value ) { War3_ForceThirdPerson(this.index,value); }
	}

	property bool stunned
	{
		public get() { return W3GetBuffHasTrue(this.index,bStunned); }
	}
	property bool silenced
	{
		public get() { return W3GetBuffHasTrue(this.index,bSilenced); }
	}
	property bool hexed
	{
		public get() { return W3GetBuffHasTrue(this.index,bHexed); }
	}
	property bool perplexed
	{
		public get() { return W3GetBuffHasTrue(this.index,bPerplexed); }
	}

	property int speed
	{
		public get() { return W3GetSpeedMulti(this.index); }
	}

	property int hastalents
	{
		public get() { return W3GetPlayerProp(this.index,talentsLoaded); }
	}
#if GGAMETYPE == GGAME_TF2
	property TFClassType class
	{
		public get() {
				if(!this.index) return TFClass_Unknown;
				return TF2_GetPlayerClass(this.index);
			}
	}
#endif
	property bool bankcanwithdraw
	{
		public get() { return War3_BankCanWithdraw(this.index); }
	}

	public void teleport(int target=-1, float ScaleVectorDistance=-1.0, float distance=1200.0, int raceid=-1, int skillid=-1)
	{
		War3_Teleport(this.index,target,ScaleVectorDistance,distance,raceid,skillid);
	}
	// Notify Player of the below:
	public void skillactivated(int skill,bool activated)
	{
		War3_NotifyPlayerSkillActivated(this.index,skill,activated);
	}
	public void itemactivated(int skill,bool activated)
	{
		War3_NotifyPlayerItemActivated(this.index,skill,activated);
	}
	public void immunefromskill(int victim,int skill)
	{
		// assumes this.index is attacker
		War3_NotifyPlayerImmuneFromSkill(this.index, victim, skill);
	}
	public void immunefromitem(int victim,int skill)
	{
		// assumes this.index is attacker
		War3_NotifyPlayerImmuneFromItem(this.index, victim, skill);
	}
	public void leechedfromskill(int victim,int health, int skill)
	{
		// assumes this.index is attacker
		War3_NotifyPlayerLeechedFromSkill(victim, this.index, health, skill);
	}
	public void leechedfromitem(int victim,int health, int item)
	{
		// assumes this.index is attacker
		War3_NotifyPlayerLeechedFromItem(victim, this.index, health, item);
	}
	public void damagefromskill(int victim,int damage, int skill)
	{
		// assumes this.index is attacker
		War3_NotifyPlayerTookDamageFromSkill(victim, this.index, damage, skill);
	}
	public void damagefromitem(int victim,int damage, int item)
	{
		// assumes this.index is attacker
		War3_NotifyPlayerTookDamageFromSkill(victim, this.index, damage, item);
	}
	//

	public bool castspell(int target, W3SpellEffects spelleffect, char SpellColor[20], int SkillID, float duration)
	{
		return War3_CastSpell(this.index, target, spelleffect, SpellColor, this.raceid, SkillID, duration);
	}
	public bool cancelspell(int target, int castingid=0)
	{
		// if castingid = 0, then it will bring up a menu for the person wanting to cancel a spell.
		return War3_CancelSpell(this.index, target, castingid);
	}
	//buff
	//RESETS ALL BUFFS PERTAINGIN TO THIS CLIENT AND RACE, basically fully getting rid if all buffs attatched to this player from your race
	public void resetallbuffs(int raceid)
	{
		W3ResetAllBuffRace(this.index, raceid);
	}
	public void resetbuff(W3Buff buffindex, int raceid)
	{
		W3ResetBuffRace(this.index,buffindex,raceid);
	}

	public bool immunity(War3Immunity immunityindex)
	{
		return W3HasImmunity(this.index, immunityindex);
	}

	public void setbuff(W3Buff buffindex, int raceid, any value, int buffowner=-1)
	{
		War3_SetBuff(this.index,buffindex,raceid,value,buffowner);
	}
	public any getbuff(W3Buff buffindex, int raceid)
	{
		return W3GetBuff(this.index,buffindex,raceid);
	}
	public void resetbuffrace(W3Buff buffindex, int raceid)
	{
		// in War3Source_Engine_BuffSystem.sp
		//ResetBuffParticularRaceOrItem(client,W3Buff:buffindex,totalItemsLoaded+race);
		W3ResetBuffRace(this.index,buffindex,raceid);
	}
	public void resetbuffitem(W3Buff buffindex, int itemid)
	{
		// in War3Source_Engine_BuffSystem.sp
		//ResetBuffParticularRaceOrItem(client,W3Buff:buffindex,item);
		W3ResetBuffRace(this.index,buffindex,itemid);
	}

	//public void setaura( int tAuraID, int level )
	//{
		//W3HasAura(tAuraID,this.index,level);
	//}
	public void removeaura( int tAuraID )
	{
		W3RemovePlayerAura(tAuraID,this.index);
	}
	public bool hasaura( int tAuraID, int &level )
	{
		return W3HasAura(tAuraID,this.index,level);
	}

	public bool depositgold( int Amount=0 )
	{
		return War3_DepositGoldBank(this.index,Amount);
	}
	public bool withdrawgold( int Amount=0, bool Bypass=false )
	{
		return War3_WithdrawGoldBank(this.index,Amount,Bypass);
	}

	public void setcooldown(float cooldownTime, int raceid, int skillNum, bool resetOnSpawn=true, bool printMsgOnExpireByTime=true)
	{
		War3_CooldownMGR(this.index,cooldownTime,raceid,skillNum,resetOnSpawn,printMsgOnExpireByTime);
	}

	public int getskilllevel( int raceid, int skill )
	{
		return War3_GetSkillLevel(this.index,raceid,skill);
	}

	public bool skillnotcooldown( int raceid, int skillNum, bool printTextIfNotReady=false )
	{
		return War3_SkillNotInCooldown(this.index,raceid,skillNum,printTextIfNotReady);
	}
	public bool skillcooldown( int raceid, int skillNum, bool printTextIfNotReady=false )
	{
		return !War3_SkillNotInCooldown(this.index,raceid,skillNum,printTextIfNotReady);
	}

	public void respawn()
	{
		War3_SpawnPlayer(this.index);
	}

	//War3_HealToMaxHP
	public void HealToMaxHP( int HealTheAmount)
	{
		War3_HealToMaxHP(this.index,HealTheAmount);
	}
	//War3_TFHealingEvent
	public void TFHealingEvent( int HealTheAmount2)
	{
		War3_TFHealingEvent(this.index,HealTheAmount2);
	}

	public void flashscreen( int color[4], float holdduration=0.1, float fadeduration=0.2, int flags=FFADE_IN)
	{
		W3FlashScreen(this.index,color,holdduration,fadeduration,flags);
	}

	public void message( char szMessage[MAX_MESSAGE_LENGTH], any ... )
	{
		if (this.index == 0)
		{
			char szBuffer[MAX_MESSAGE_LENGTH];
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && !IsFakeClient(i))
				{
					SetGlobalTransTarget(i);
					VFormat(szBuffer, sizeof(szBuffer), szMessage, 3);
					Format(szBuffer, sizeof(szBuffer), "{green}[War3Source:EVO]{default} %s", szBuffer);
					CPrintToChat(i, szBuffer);
				}
			}
		}
		else
		{
			char szBuffer[MAX_MESSAGE_LENGTH];
			SetGlobalTransTarget(this.index);
			VFormat(szBuffer, sizeof(szBuffer), szMessage, 3);
			Format(szBuffer, sizeof(szBuffer), "{green}[War3Source:EVO]{default} %s", szBuffer);

			if(ValidPlayer(this.index) && !IsFakeClient(this.index))
			{
				CPrintToChat(this.index, szBuffer);
			}
		}
	}
#if defined _War3Source_Talents_included
	public int getpoint(TFClassType ClassType, eTree TheTree, eBox TheBox)
	{
		return War3_GetTalentBox(this.index, ClassType, TheTree, TheBox);
	}
	public void setpoint(TFClassType ClassType, eTree TheTree, eBox TheBox, int TheValue)
	{
		War3_SetTalentBox(this.index, ClassType, TheTree, TheBox, TheValue);
	}
	public void loadpoints()
	{
		War3_LoadTalents(this.index);
	}
#endif

/*  Already exists else where except Captial G instead of lowercase g
	public int getSkillslot( int skillid )
	{
		return War3_GetSkillSlot(this.index,skillid);
	}*/
	public void setSkillslot( int skillslot, int skillid )
	{
		War3_SetSkillSlot(this.index,skillslot,skillid);
	}
	public int hasSkillslot( int skillslot, int skillid )
	{
		return War3_HasSkillSlot(this.index,skillid);
	}
}


// MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS
// MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS
// MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS
// MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS
// MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS
// MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS
// MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS
// MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS
// MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS
// MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS
// MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS
// MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS
// MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS
// MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS
// MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS
// MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS
// MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS
// MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS
// MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS
// MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS
// MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS
// MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS MACROS

// make sure you "new thisRaceID;" in your race
#define IsThisRaceID(%1) War3_GetRace(%1)==thisRaceID








public SharedPlugin:__pl_War3Source =
{
	name = "War3Source",
	file = "War3Source.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_War3Source_SetNTVOptional()
{
	MarkNativeAsOptional("W3GetReqXP");

	MarkNativeAsOptional("War3_ShowXP");

	MarkNativeAsOptional("W3SaveXP");

	//MarkNativeAsOptional("War3Failed");

	MarkNativeAsOptional("OurTestNative");
	MarkNativeAsOptional("OurTestNative2");
	MarkNativeAsOptional("W3ExtVersion");
	MarkNativeAsOptional("W3ExtTestFunc");
	MarkNativeAsOptional("W3GetW3Version");
	MarkNativeAsOptional("W3GetW3Revision");
	MarkNativeAsOptional("W3GetStatsVersion");
	MarkNativeAsOptional("W3Socket");
	MarkNativeAsOptional("W3Socket2");
	MarkNativeAsOptional("W3DropWeapon");
	MarkNativeAsOptional("War3_InFreezeTime");
	MarkNativeAsOptional("War3_CreateNewRace");
	MarkNativeAsOptional("War3_AddRaceSkill");
	MarkNativeAsOptional("War3_CreateNewRaceT");
	MarkNativeAsOptional("War3_AddRaceSkillT");
	MarkNativeAsOptional("War3_CreateRaceEnd");
	MarkNativeAsOptional("War3_GetRaceName");
	MarkNativeAsOptional("War3_GetRaceShortname");
	//MarkNativeAsOptional("W3GetRaceString"); // not implemented
	//MarkNativeAsOptional("W3GetRaceSkillString");
	MarkNativeAsOptional("War3_GetRacesLoaded");
	MarkNativeAsOptional("W3GetRaceMaxLevel");
	MarkNativeAsOptional("War3_IsSkillUltimate");
	MarkNativeAsOptional("War3_GetRaceSkillCount");
	MarkNativeAsOptional("W3GetRaceSkillName");
	MarkNativeAsOptional("W3GetRaceSkillDesc");
	MarkNativeAsOptional("W3GetRaceSkillMaxLevel");
	MarkNativeAsOptional("W3GetRaceOrder");
	MarkNativeAsOptional("W3RaceHasFlag");
	MarkNativeAsOptional("W3GetRaceList");
	MarkNativeAsOptional("War3_GetRaceIDByShortname");
	MarkNativeAsOptional("W3GetRaceAccessFlagStr");
	MarkNativeAsOptional("W3GetRaceItemRestrictionsStr");
	MarkNativeAsOptional("W3GetRaceMaxLimitTeam");
	MarkNativeAsOptional("W3GetRaceMaxLimitTeamCvar");
	MarkNativeAsOptional("W3GetRaceMinLevelRequired");
	MarkNativeAsOptional("W3IsRaceTranslated");
	MarkNativeAsOptional("W3GetVar");
	MarkNativeAsOptional("W3SetVar");
	// Shopmenu
	MarkNativeAsOptional("War3_CreateShopItem");
	MarkNativeAsOptional("War3_CreateShopItemT");
#if GGAMETYPE == GGAME_TF2
	MarkNativeAsOptional("War3_TFSetItemClasses");
	MarkNativeAsOptional("War3_TFIsItemClass");
#endif
	MarkNativeAsOptional("War3_SetItemProperty");
	MarkNativeAsOptional("War3_GetItemProperty");
	MarkNativeAsOptional("War3_GetItemIdByShortname");
	MarkNativeAsOptional("W3GetItemName");
	MarkNativeAsOptional("W3GetItemShortname");
	MarkNativeAsOptional("W3GetItemShortdesc");
	MarkNativeAsOptional("W3GetItemDescription");
	MarkNativeAsOptional("W3GetItemCost");
	MarkNativeAsOptional("W3GetItemOrder");
	MarkNativeAsOptional("W3ItemHasFlag");
	MarkNativeAsOptional("W3GetItemCategory");
	MarkNativeAsOptional("W3GetItemsLoaded");
	MarkNativeAsOptional("W3IsItemDisabledGlobal");
	MarkNativeAsOptional("W3IsItemDisabledForRace");
	// Shopmenu 2
	MarkNativeAsOptional("War3_CreateShopItem2");
	MarkNativeAsOptional("War3_CreateShopItem2T");
	MarkNativeAsOptional("War3_SetItem2Property");
	MarkNativeAsOptional("War3_GetItem2Property");
	MarkNativeAsOptional("War3_GetItem2IdByShortname");
	//MarkNativeAsOptional("W3CreateShopItem2");
	MarkNativeAsOptional("W3GetItem2Name");
	MarkNativeAsOptional("W3GetItem2Shortname");
	MarkNativeAsOptional("W3GetItem2Desc");
	MarkNativeAsOptional("W3GetItem2Cost");
	MarkNativeAsOptional("W3GetItem2Order");
	MarkNativeAsOptional("W3Item2HasFlag");
	MarkNativeAsOptional("W3GetItem2Catagory");
	MarkNativeAsOptional("W3GetItems2Loaded");
	MarkNativeAsOptional("W3IsItem2DisabledGlobal");
	MarkNativeAsOptional("W3IsItem2DisabledForRace");
	MarkNativeAsOptional("W3SaveItem2ExpireTime");
	// Shopmenu3
	MarkNativeAsOptional("W3CreateShopItem3");
	MarkNativeAsOptional("W3CreateShopItem3T");
#if GGAMETYPE == GGAME_TF2
	MarkNativeAsOptional("War3_TFSetItem3Classes");
	MarkNativeAsOptional("War3_TFIsItem3Class");
#endif
	MarkNativeAsOptional("War3_SetItem3Property");
	MarkNativeAsOptional("War3_GetItem3Property");
	MarkNativeAsOptional("War3_GetItem3IdByShortname");
	MarkNativeAsOptional("W3CreateShopItem3");
	MarkNativeAsOptional("W3GetItem3Name");
	MarkNativeAsOptional("W3GetItem3Shortname");
	MarkNativeAsOptional("W3GetItem3Desc");
	MarkNativeAsOptional("W3GetItem3Cost");
	MarkNativeAsOptional("W3GetItem3Order");
	MarkNativeAsOptional("W3Item3HasFlag");
	MarkNativeAsOptional("W3GetItem3Category");
	//MarkNativeAsOptional("W3GetItems3Loaded");
	MarkNativeAsOptional("W3IsItem3DisabledGlobal");
	MarkNativeAsOptional("W3IsItem3DisabledForRace");
	MarkNativeAsOptional("W3SaveItem3");

	MarkNativeAsOptional("War3_CreateHelpCommand");
	MarkNativeAsOptional("W3GetLevelsSpent");
	MarkNativeAsOptional("W3ClearSkillLevels");
	MarkNativeAsOptional("W3GetKillXP");
	MarkNativeAsOptional("W3GetReqXP");
	MarkNativeAsOptional("War3_ShowXP");
	MarkNativeAsOptional("W3GetMaxGold");
	MarkNativeAsOptional("War3_RestoreItemsFromDeath");
#if GGAMETYPE == GGAME_TF2
	MarkNativeAsOptional("War3_IsInSteamGroup");
#endif
	MarkNativeAsOptional("War3_GetOwnsItem");
	MarkNativeAsOptional("War3_GetOwnsItem2");
	MarkNativeAsOptional("War3_GetOwnsItem3");
	MarkNativeAsOptional("War3_SetItemXP");
	MarkNativeAsOptional("War3_GetItemXP");
	MarkNativeAsOptional("War3_SetItemLevel");
	MarkNativeAsOptional("War3_GetItemLevel");//W3GetItems3Loaded
	MarkNativeAsOptional("W3GetItems3Loaded");

//	MarkNativeAsOptional("W3GetItem2ExpireTime");
//	MarkNativeAsOptional("W3SetItem2ExpireTime");
	MarkNativeAsOptional("War3_SetOwnsItem");
	MarkNativeAsOptional("War3_SetOwnsItem2");
	MarkNativeAsOptional("War3_SetOwnsItem3");
	MarkNativeAsOptional("War3_GetTargetInViewCone");
	MarkNativeAsOptional("W3LOS");
	MarkNativeAsOptional("War3_DealDamage");
	MarkNativeAsOptional("War3_GetWar3DamageDealt");
	MarkNativeAsOptional("W3GetDamageIsBullet");
	MarkNativeAsOptional("W3ForceDamageIsBullet");
	MarkNativeAsOptional("W3GetDamageStack");
	MarkNativeAsOptional("W3FlashScreen");
	MarkNativeAsOptional("War3_ShakeScreen");
	MarkNativeAsOptional("War3_SpawnPlayer");
	MarkNativeAsOptional("War3_CachedAngle");
	MarkNativeAsOptional("War3_CachedPosition");
	MarkNativeAsOptional("War3_CachedDucking");
	/*
	MarkNativeAsOptional("War3_CachedWeapon");
	MarkNativeAsOptional("War3_CachedClip1");
	MarkNativeAsOptional("War3_CachedAmmo");
	MarkNativeAsOptional("War3_CachedDeadClip1");
	MarkNativeAsOptional("War3_CachedDeadAmmo");
	MarkNativeAsOptional("War3_CachedDeadWeaponName");
	*/
	MarkNativeAsOptional("War3_DamageModPercent");
#if GGAMETYPE == GGAME_TF2
	MarkNativeAsOptional("War3_IsUbered");
	MarkNativeAsOptional("War3_HasFlag");
	MarkNativeAsOptional("War3_IsCloaked");
	MarkNativeAsOptional("War3_TF_ParticleToClient");
#endif
	MarkNativeAsOptional("War3_HealToMaxHP");
	MarkNativeAsOptional("War3_HealToBuffHP");
	MarkNativeAsOptional("War3_DecreaseHP");
	MarkNativeAsOptional("War3_CooldownMGR");
	MarkNativeAsOptional("W3SkillCooldownOnSpawn");
	MarkNativeAsOptional("War3_CooldownRemaining");
	MarkNativeAsOptional("War3_CooldownReset");
	MarkNativeAsOptional("War3_SkillNotInCooldown");
	MarkNativeAsOptional("War3_PrintSkillIsNotReady");
	MarkNativeAsOptional("War3_SetBuff");
	MarkNativeAsOptional("War3_SetBuffItem");
	MarkNativeAsOptional("War3_SetBuffItem2");
	MarkNativeAsOptional("War3_SetBuffItem3");
	MarkNativeAsOptional("W3ApplyBuffSimple");
	MarkNativeAsOptional("W3ResetBuffRace");
	MarkNativeAsOptional("W3ResetBuffItem");
	MarkNativeAsOptional("W3ResetAllBuffRace");

	MarkNativeAsOptional("War3_AddSkillBuff");
	MarkNativeAsOptional("War3_AddAuraSkillBuff");
	MarkNativeAsOptional("War3_AddItemBuff");

	MarkNativeAsOptional("W3GetBuff");
	MarkNativeAsOptional("W3GetBuffHasTrue");
	MarkNativeAsOptional("W3GetBuffStackedFloat");
	MarkNativeAsOptional("W3GetBuffSumFloat");
	MarkNativeAsOptional("W3GetBuffMinFloat");
	MarkNativeAsOptional("W3GetBuffMaxFloat");
	MarkNativeAsOptional("W3GetBuffLastValue");
	MarkNativeAsOptional("W3GetBuffMinInt");
	MarkNativeAsOptional("War3_RegisterDelayTracker");
	MarkNativeAsOptional("War3_TrackDelay");
	MarkNativeAsOptional("War3_TrackDelayExpired");
	MarkNativeAsOptional("War3_GetAimEndPoint");
	MarkNativeAsOptional("War3_GetAimTraceMaxLen");
	MarkNativeAsOptional("War3_WeaponRestrictTo");
	MarkNativeAsOptional("War3_GetWeaponRestriction");
	MarkNativeAsOptional("W3GetPhysicalArmorMulti");
	MarkNativeAsOptional("W3GetMagicArmorMulti");
	MarkNativeAsOptional("W3GetCurrentWeaponEnt");
	MarkNativeAsOptional("W3GetMinUltLevel");
	//MarkNativeAsOptional("War3Failed");
	MarkNativeAsOptional("W3GetDamageType");
	MarkNativeAsOptional("W3GetDamageInflictor");
	MarkNativeAsOptional("W3ChanceModifier");
#if GGAMETYPE == GGAME_TF2
	MarkNativeAsOptional("W3IsOwnerSentry");
#endif
	MarkNativeAsOptional("W3Hint");
	MarkNativeAsOptional("War3_GetRace");
	MarkNativeAsOptional("War3_SetRace");
	MarkNativeAsOptional("War3_SetLevel");
	MarkNativeAsOptional("War3_GetLevel");
	MarkNativeAsOptional("W3GetTotalLevels");
	MarkNativeAsOptional("W3GetLevelBank");
	MarkNativeAsOptional("W3SetLevelBank");
	MarkNativeAsOptional("War3_SetXP");
	MarkNativeAsOptional("War3_GetXP");
	MarkNativeAsOptional("War3_SetSkillLevel");
	MarkNativeAsOptional("War3_GetSkillLevel");
	MarkNativeAsOptional("War3_SetSkillLevelINTERNAL");
	MarkNativeAsOptional("War3_GetSkillLevelINTERNAL");
	MarkNativeAsOptional("W3SetPlayerProp");
	MarkNativeAsOptional("W3GetPlayerProp");
	MarkNativeAsOptional("W3GiveXPGold");
	MarkNativeAsOptional("W3CreateCvar");
	MarkNativeAsOptional("W3GetCvar");
	MarkNativeAsOptional("W3SetCvar");
	MarkNativeAsOptional("W3FindCvar");
	MarkNativeAsOptional("W3CvarList");
	MarkNativeAsOptional("W3GetCvarByString");
	MarkNativeAsOptional("W3GetCvarActualString");
	MarkNativeAsOptional("W3IsDeveloper");
	MarkNativeAsOptional("W3IsHelper");
	MarkNativeAsOptional("W3SaveEnabled");
	MarkNativeAsOptional("W3SaveXP");
	MarkNativeAsOptional("W3Log");
	MarkNativeAsOptional("W3LogError");
	MarkNativeAsOptional("W3LogNotError");
	MarkNativeAsOptional("CreateWar3GlobalError");
	MarkNativeAsOptional("W3CreateEvent");

	//MarkNativeAsOptional("War3_SetDiamondsEXT");
	//MarkNativeAsOptional("War3_GetDiamondsEXT");
	//MarkNativeAsOptional("War3_GetOwnsItem2EXT");
	//MarkNativeAsOptional("War3_SetOwnsItem2EXT");
	//MarkNativeAsOptional("W3ExtShowShop2");

	// Skills
	MarkNativeAsOptional("War3_SuicideBomber");
	MarkNativeAsOptional("War3_Teleport");
	MarkNativeAsOptional("War3_TeleportEntity");
	// Ward stuff
	MarkNativeAsOptional("War3_CreateWardBehavior");
	MarkNativeAsOptional("War3_GetWardBehaviorsLoaded");
	MarkNativeAsOptional("War3_GetWardBehaviorName");
	MarkNativeAsOptional("War3_GetWardBehaviorShortname");
	MarkNativeAsOptional("War3_GetWardBehaviorDesc");
	MarkNativeAsOptional("War3_GetWardBehaviorByShortname");

	MarkNativeAsOptional("War3_CreateWard");
	MarkNativeAsOptional("War3_CreateWardMod");
	MarkNativeAsOptional("War3_GetWardBehavior");
	MarkNativeAsOptional("War3_GetWardLocation");
	MarkNativeAsOptional("War3_IsWardDistanceTooClose");
	MarkNativeAsOptional("War3_GetWardInterval");
	MarkNativeAsOptional("War3_GetWardRadius");
	MarkNativeAsOptional("War3_GetWardOwner");
	MarkNativeAsOptional("War3_GetWardData");
	MarkNativeAsOptional("War3_GetWardUseDefaultColor");
	MarkNativeAsOptional("War3_GetWardColor2");
	MarkNativeAsOptional("War3_GetWardColor3");
	MarkNativeAsOptional("War3_GetWardSkill");
	MarkNativeAsOptional("War3_GetWardCount");
	MarkNativeAsOptional("War3_RemoveWard");

	//String Math
	//MarkNativeAsOptional("War3_StringMath");

	//Factions
	MarkNativeAsOptional("W3Faction");
	MarkNativeAsOptional("W3FactionBehavior");
	MarkNativeAsOptional("W3FactionBehaviorByName");
	MarkNativeAsOptional("W3FactionCompare");
	MarkNativeAsOptional("W3GetRaceFaction");

	// Dependency Engine
	MarkNativeAsOptional("War3_SetDependency");
	MarkNativeAsOptional("War3_RemoveDependency");
	MarkNativeAsOptional("War3_GetDependency");
	MarkNativeAsOptional("War3_SetRaceDependency");
	MarkNativeAsOptional("War3_RemoveRaceDependency");
	MarkNativeAsOptional("War3_GetRaceDependency");

	//Custom Models (CS:S only)
	MarkNativeAsOptional("War3_AddCustomModel");
	MarkNativeAsOptional("War3_RemoveCustomModel");

	MarkNativeAsOptional("War3_RaceBeforePluginStart");
	MarkNativeAsOptional("War3_RaceOnPluginEnd");
	MarkNativeAsOptional("War3_IsRaceReloading");

	MarkNativeAsOptional("War3_GetLevelEx");

	//MarkNativeAsOptional("War3_ToggleCyborgSkin");

	MarkNativeAsOptional("W3SaveXPsh3");

	MarkNativeAsOptional("War3_EvadeDamage");
	MarkNativeAsOptional("War3_EffectReturnDamage");
	MarkNativeAsOptional("War3_VampirismEffect");
	MarkNativeAsOptional("War3_BashEffect");
	MarkNativeAsOptional("War3_WardVisualEffect");
	MarkNativeAsOptional("War3_WardZapVisualEffect");

	MarkNativeAsOptional("War3_AddSound");

	MarkNativeAsOptional("War3_NotifyPlayerTookDamageFromSkill");
	MarkNativeAsOptional("War3_NotifyPlayerTookDamageFromItem");
	MarkNativeAsOptional("War3_NotifyPlayerLeechedFromSkill");
	MarkNativeAsOptional("War3_NotifyPlayerLeechedFromItem");
	MarkNativeAsOptional("War3_NotifyPlayerImmuneFromSkill");
	MarkNativeAsOptional("War3_NotifyPlayerImmuneFromItem");
	MarkNativeAsOptional("War3_NotifyPlayerSkillActivated");
	MarkNativeAsOptional("War3_NotifyPlayerItemActivated");

	//MarkNativeAsOptional("War3_IsNewPlayer");
	MarkNativeAsOptional("War3_GetKDR_Score");
	MarkNativeAsOptional("War3_GetKDR_Kills");
	MarkNativeAsOptional("War3_GetKDR_Deaths");
	MarkNativeAsOptional("War3_GetKDR_Enabled");
	MarkNativeAsOptional("War3_Set_KDR");
	MarkNativeAsOptional("War3_SetKDR_Kills");
	MarkNativeAsOptional("War3_SetKDR_Deaths");

	MarkNativeAsOptional("War3_GetRaceKDR");

	MarkNativeAsOptional("War3_BankCanWithdraw");

	MarkNativeAsOptional("War3_DepositGoldBank");
	MarkNativeAsOptional("War3_WithdrawGoldBank");
	MarkNativeAsOptional("War3_SetGoldBank");
	MarkNativeAsOptional("War3_GetGoldBank");

	MarkNativeAsOptional("War3_ToggleCyborgSkin");


	MarkNativeAsOptional("War3_SetCollidable");

	MarkNativeAsOptional("War3_TE_SendToAll");
	MarkNativeAsOptional("War3_TE_SendToClient");

	MarkNativeAsOptional("OnW3SupplyLocker");
	MarkNativeAsOptional("OnW3HealthPickup");
}
#endif
