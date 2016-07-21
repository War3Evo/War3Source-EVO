//=============================================================================
// Races / Race Creation
//=============================================================================

methodmap War3Source_Races
{
	public War3Source_Races()
	{
	}
	public native int War3_CreateNewRace(char[] name, char[] shortname,int reload_race_id=0,char[] shortdesc="no description");
	public native int War3_CreateNewRaceT(String:shortname[],reload_race_id=0,String:shortdesc[]="no description");
	public native int War3_AddRaceSkill(int raceid,char[] tskillorultname,char[] tskillorultdescription,bool isult=false,int maxskilllevel=DEF_MAX_SKILL_LEVEL);
	public native int War3_AddRaceSkillT(int raceid,char[] SkillNameIdentifier,bool isult=false,int maxskilllevel=DEF_MAX_SKILL_LEVEL,any ...);
	public native void War3_CreateRaceEnd(int raceid);

	public native void War3_RaceOnPluginStart(char shortname[16]);
	public native void War3_RaceOnPluginEnd(char shortname[16]);
	public native bool War3_IsRaceReloading();

	public native void War3_GetRaceName(int raceid,char[] retstr,int maxlen);
	public native void War3_GetRaceShortname(int raceid,char[] retstr,int maxlen);
	public native void War3_GetRaceShortdesc(int raceid,char[] retstr,int maxlen);

	public native int War3_GetRacesLoaded();
	public native int W3GetRaceMaxLevel(int raceid);
	//public
	//public
	//public
	//public
	//public
	//public
	//public
	//public

	public native bool War3_IsSkillUltimate(int raceid, int skillnum);
	public native int War3_GetRaceSkillCount(raceid);
	public native void W3GetRaceSkillName(int raceid,int skillindex,char[] retstr,int maxlen);
	public native void W3GetRaceSkillDesc(int raceid,int skillindex,char[] retstr,int maxlen);
	public native int W3GetRaceSkillMaxLevel(int raceid, int skillnum);
	public native int W3GetRaceOrder(int raceid);

	public native int War3_GetSkillLevel(int client, int raceid, int skill);

	public native int War3_SetSkillLevelINTERNAL(int client, int raceid, int skill, int newlevel);
	public native int War3_GetSkillLevelINTERNAL(int client, int raceid, int skill);

	public native int W3GetMinUltLevel();

	public native float War3_GetRaceKDR(int raceid);

	public native bool W3RaceHasFlag(int raceid,char[] flag);

	public native void W3GetRaceAccessFlagStr(int raceid,char[] retstr,int maxlen);

	public native void W3GetRaceItemRestrictionsStr(int raceid,char[] retstr,int maxlen);

	public native int W3GetRaceList(int[] racelist);

	public native int W3GetRaceMaxLimitTeam(int raceid, int team);
	public native int W3GetRaceMaxLimitTeamCvar(int raceid, int team); //returns the internal cvar id (int not handle)
	public native int W3GetRaceMinLevelRequired(int raceid);
	public native bool W3IsRaceTranslated(int raceid);

	public native any W3GetRaceCell(int raceid,ENUM_RaceObject property);
	public native void W3SetRaceCell(int raceid,ENUM_RaceObject property,any somevalue);

	public native int War3_GetRace(int client);
	public native void War3_SetRace(int client, int raceid);

	public native int War3_GetRaceIDByShortname(char[] raceshortname);

	public native bool War3_SetRaceDependency(int iRaceID, int iRequiredRace, int iRequiredLevel);
	public native void War3_RemoveRaceDependency(int iRaceID, int iRequiredRace=0);
	public native int War3_FindRaceDependency(int iRaceID, int IRequiredID);
}

//creates a new race, returns the race id
//a valid race is >0
//native War3_CreateNewRace(String:name[],String:shortname[],reload_race_id=0,String:shortdesc[]="no description");

//translated
//creates a new race, returns the race id
//native War3_CreateNewRaceT(String:shortname[],reload_race_id=0,String:shortdesc[]="no description");

//adds a skill or a ultimate
//native War3_AddRaceSkill(raceid,String:tskillorultname[],String:tskillorultdescription[],bool:isult=false,maxskilllevel=DEF_MAX_SKILL_LEVEL);

//translated
//adds a skill or a ultimate
//additional parameters replaces #1# #2# ... in the translation string (max 5)
// % does not need to be escaped
//native War3_AddRaceSkillT(raceid,String:SkillNameIdentifier[],bool:isult=false,maxskilllevel=DEF_MAX_SKILL_LEVEL,any:...);

//ends race creation!!! MUST CALL THIS!!!
//native War3_CreateRaceEnd(raceid);

//=============================================================================
// Races Reloading
//=============================================================================

// Makes it so that your races are reloadable
//native War3_RaceOnPluginStart(String:shortname[16]);
//native War3_RaceOnPluginEnd(String:shortname[16]);
//native bool:War3_IsRaceReloading();

//=============================================================================
// Races Information / name, shortname, etc.
//=============================================================================

//native War3_GetRaceName(raceid,String:retstr[],maxlen);
//native War3_GetRaceShortname(raceid,String:retstr[],maxlen);

//native War3_GetRaceShortdesc(raceid,String:retstr[],maxlen);

//#pragma deprecated Not Fully Implemented, possibly in the future
//native W3GetRaceString(raceid,RaceString:property,String:retstr[],maxlen); // not implemented
//#pragma deprecated Not Fully Implemented, possibly in the future
//native W3GetRaceSkillString(raceid,skillnum,SkillString:property,String:retstr[],maxlen);


/*
 * SHOULD PROBABLY REMOVE THIS, AS I HAVE NEVER USED IT IN MY 6 YEARS OF PROGRAMMING
 * WAR3SOURCE: GENERIC SKILLS
 *
 */
//native War3_CreateGenericSkill(String:gskillname[]);
//genericSkillData is an array or trie that modifies behavior of that generic skill
//if NEW HANDLE is passed, OLD one will be closed (i e during create race call after race has been created like on a map change)
//this means you CAN recreate new handles and pass them, the old one will be closed
//native War3_UseGenericSkill(raceid,String:gskillname[],Handle:genericSkillData,String:yourskillname[],String:untranslatedSkillDescription[]="ERR: No Skill Description Entered.",bool:translated=false,bool:isUltimate=false,maxskilllevel=DEF_MAX_SKILL_LEVEL,any:...);

//=============================================================================
// Get Total number of races loaded
//=============================================================================

//native War3_GetRacesLoaded();

//=============================================================================
// Get Race Max Level
//=============================================================================

//native W3GetRaceMaxLevel(race);

//=============================================================================
// RACE Skills Information
//=============================================================================
/*
native War3_IsSkillUltimate(raceid, skillnum);
native War3_GetRaceSkillCount(raceid);
native W3GetRaceSkillName(raceid,skillindex,String:retstr[],maxlen);
native W3GetRaceSkillDesc(raceid,skillindex,String:retstr[],maxlen);
native W3GetRaceSkillMaxLevel(raceid, skillnum);
native W3GetRaceOrder(raceid);
*/

//native War3_SetSkillLevel(client,race,skill,newlevel);
/*
native War3_GetSkillLevel(client, race, skill);

native War3_SetSkillLevelINTERNAL(client, race, skill, newlevel);
native War3_GetSkillLevelINTERNAL(client, race, skill);

native W3GetMinUltLevel();

native Float:War3_GetRaceKDR(raceid);
*/

//=============================================================================
// RACE Flags
//=============================================================================
//Flag is a generic string. We compare the race_flags cvar to the string you passed
/*
native bool:W3RaceHasFlag(raceid,String:flag[]);

native W3GetRaceAccessFlagStr(raceid,String:ret[],maxlen);

native W3GetRaceItemRestrictionsStr(raceid,String:ret[],maxlen);
*/

//=============================================================================
// RACE Misc
//=============================================================================

//returns a simple array of race IDs, sorted properly.
//Does not include "hidden" races
//pass array of MAXRACES, returns number of races in the array. starts at 0
//ordered properly
//returns the size of the array
/*
native W3GetRaceList(racelist[]);

native W3GetRaceMaxLimitTeam(raceid, team);
native W3GetRaceMaxLimitTeamCvar(raceid, team); //returns the internal cvar id (int not handle)
native W3GetRaceMinLevelRequired(raceid);
native W3IsRaceTranslated(raceid);

native W3GetRaceCell(raceid,ENUM_RaceObject:property);
native W3SetRaceCell(raceid,ENUM_RaceObject:property,any:somevalue);
*/

stock bool ValidRace(int raceid_)
{
	return bool:(raceid_>0&&raceid_<=War3_GetRacesLoaded());
}
// internal engine only
stock bool eValidRace(int raceid_)
{
	return bool:(raceid_>0&&raceid_<=GetRacesLoaded());
}

//=============================================================================
// RACE ID Information
//=============================================================================
/*
native War3_GetRace(client);
native War3_SetRace(client, race);

//a valid race is >0
native War3_GetRaceIDByShortname(String:raceshortname[]);
*/

//=============================================================================
// RACE DEPENDENCIES
//=============================================================================
/**
 * Adds a dependency on a race
 *
 * @param iRaceID			 Race ID
 * @param iRequiredRace		 Required Skill ID
 * @param iRequiredLevel	 Required Level Num
 * @return					 true on success, otherwhise false!
 * @error					 Thrown on invalid param num/race
 */
//native bool:War3_SetRaceDependency(iRaceID, iRequiredRace, iRequiredLevel);

/**
 * Removes any known dependency from a race(if any)
 * NOTE: you should be able to call this safetly without having to bother about anything,
 * since no error will be thrown if there currently aren't any active dependencys on this
 *
 * @param iRaceID		 Race ID
 * @noreturn
 * @error				 Thrown on invalid param num/race
 */
//native War3_RemoveRaceDependency(iRaceID, iRequiredRace=0);

/**
 * Retrieves various informations about a depending skill
 * NOTE: This can be called to check if there is any dependency or not
 *
 * @param iRaceID		 Race ID
 * @param IRequiredID	 Find Required Race ID
 * @return				 returns required level
 * @error				 Thrown on invalid param num/race
 */
//native War3_FindRaceDependency(iRaceID, IRequiredID);



//=============================================================================
// RACE Forwards
//=============================================================================
/**
 * Gets called when someone changes their race.
 * @param client: The client's index.
 * @param newrace: The player's new race.
 */
//#pragma deprecated Use OnRaceChanged(client,oldrace,newrace);
//forward OnRaceSelected(client, newrace); //to be removed

//client is not check if valid or not, still forwarded if client is not present, so you can disable buffs etc
forward OnRaceChanged(client, oldrace, newrace);

forward void OnWar3RaceEnabled(int newrace);
forward void OnWar3RaceDisabled(int oldrace);


/**
 * Called when the plugin is ready.
 * this is called many times, increasing num each time 0.0-float(MAXRACES)*10 in 1 increments
 * this is called after all default races have been loaded (OnWar3LoadRaceOrItemOrdered finished)
 *
 * reloadrace_id used by War3_ReloadRace(), can only reload 1 race at a time.
 */
forward OnWar3LoadRaceOrItemOrdered2(num,reloadrace_id,String:shortname[]);


//=============================================================================
// RACE Misc Stocks
//=============================================================================

// Internal Engine Only!
stock GetRacesOnTeam(raceid, team, ignoreIfAdminSetRace = false)
{
	int num;
	for (int y = 1; y <= MaxClients; y++)
	{
		if (ValidPlayer(y, false))
		{
			if (GetRace(y) == raceid)
			{
				if (GetClientTeam(y) == team)
				{
					if (ignoreIfAdminSetRace&&W3GetPlayerProp(y,RaceSetByAdmin))
					{
					} else
					{
						num++;
					}
				}
			}
		}
	}
	return num;
}

/*
HasRaceAccess(client,Handle:hRace)
{
	new String:flag_str[8];
	new Handle:cvarCheck=GetArrayCell(hRace,14);
	GetConVarString(cvarCheck,flag_str,8);
	new first_char=_:flag_str[0];
	if(StrEqual(flag_str,"0",false) || first_char<(_:'a') || first_char>(_:'z'))
		return true; // no valid cvar value, give them access
	new AdminFlag:flag_check;
	if(!FindFlagByChar(first_char,flag_check))
		return true; // bad flag provided
	new AdminId:admin = GetUserAdmin(client);
	if((admin!=INVALID_ADMIN_ID)&&(GetAdminFlag(admin,flag_check,Access_Effective)==true))
		return true; // user has flag



	//return IsDeveloper(client); // must not have proper flag if it got all the way down here.
	return false;
}
*/

