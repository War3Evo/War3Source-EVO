// War3Source_Engine_Dependency.sp

/* War3Source Skill Dependency Engine
 * Authors  : Vulpone & DonRevan
 * Version  : 1.0 Public
 */


/*
public Plugin:myinfo=
{
	name="War3Source Engine Skill Dependency",
	author="Vulpone & DonRevan updated by El Diablo",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};
*/


// holds informations about the skill dependency id(0) and required level(1)
new skillDependency[MAXRACES][MAXSKILLCOUNT][2];

//RaceDependency
//new raceDependency[MAXRACES][2];

public bool:War3Source_Engine_Dependency_InitNatives()
{
	// Adds an dependency on the given skill
	CreateNative("War3_SetDependency",NWar3_AddDependency);
	// Removes all dependencys from a skill
	CreateNative("War3_RemoveDependency",NWar3_RemDependency);
	// Returns various informations about the dependency
	CreateNative("War3_GetDependency",NWar3_GetDependency);

	// Adds an dependency on the given skill
	CreateNative("War3_SetRaceDependency",NWar3_SetRaceDependency);
	// Removes all dependencys from a skill
	CreateNative("War3_RemoveRaceDependency",NWar3_RemoveRaceDependency);
	// Returns various informations about the dependency
	//CreateNative("War3_GetRaceDependency",NWar3_GetRaceDependency);
	CreateNative("War3_FindRaceDependency",NWar3_FindRaceDependency);

	RegPluginLibrary("RaceDependency");

	return true;
}

// RACE DEPENDENCY
//new Handle:g_hRaceDependencies = INVALID_HANDLE; // Holds the W3Buff
new Handle:g_hRaceID = INVALID_HANDLE; // Holds the race id
new Handle:g_hRequiredRace = INVALID_HANDLE; // Holds the race id
new Handle:g_hRequiredLevel = INVALID_HANDLE; // Holds the skill id

public War3Source_Engine_Dependency_OnPluginStart()
{
	g_hRaceID = CreateArray(1);
	g_hRequiredRace = CreateArray(1);
	g_hRequiredLevel = CreateArray(1);
}

AddRaceDependency(iRace,iRequiredRace,iRequiredLevel)
{
	for(new i = 0; i < GetArraySize(g_hRaceID); i++)
	{
		if(GetArrayCell(g_hRaceID, i) == iRace &&
		   GetArrayCell(g_hRequiredRace, i) == iRequiredRace &&
		   GetArrayCell(g_hRequiredLevel, i) == iRequiredLevel)
		{
			return 0;
		}
	}
	PushArrayCell(g_hRaceID, iRace);
	PushArrayCell(g_hRequiredRace, iRequiredRace);
	PushArrayCell(g_hRequiredLevel, iRequiredLevel);

	return 1;
}

FindRaceDependency(iRace,iFindRace)
{
	for(new i = 0; i < GetArraySize(g_hRaceID); i++)
	{
		if(GetArrayCell(g_hRaceID, i) == iRace &&
		   GetArrayCell(g_hRequiredRace, i) == iFindRace)
		{
			return GetArrayCell(g_hRequiredLevel, i);
		}
	}
	return 0;
}

RemoveRaceDependency(iRace,iRequiredRace)
{
	// Remove all races that Match
	if(iRequiredRace==0)
	{
		for(new i = 0; i < GetArraySize(g_hRaceID); i++)
		{
			if(GetArrayCell(g_hRaceID, i) == iRace)
			{
				RemoveFromArray(g_hRaceID, i);
				RemoveFromArray(g_hRequiredRace, i);
				RemoveFromArray(g_hRequiredLevel, i);
				i=0;
			}
		}
	}
	else // Remove certain races w/ required race id
	{
		for(new i = 0; i < GetArraySize(g_hRaceID); i++)
		{
			if(GetArrayCell(g_hRaceID, i) == iRace &&
			   GetArrayCell(g_hRequiredRace, i) == iRequiredRace)
			{
				RemoveFromArray(g_hRaceID, i);
				RemoveFromArray(g_hRequiredRace, i);
				RemoveFromArray(g_hRequiredLevel, i);
				i=0;
			}
		}
	}
}


//native bool:War3_SetRaceDependency(iRaceID, iRequiredRace, iRequiredLevel);
public NWar3_SetRaceDependency(Handle:plugin,numParams)
{
	if(numParams != 3) {
		return ThrowNativeError(SP_ERROR_NATIVE,"numParams is invalid!");
	}
	new iRace = GetNativeCell(1);
	if(iRace>0) {
		new iRequiredRace = GetNativeCell(2);
		if(iRequiredRace>0)
		{
			new iRequiredLevel = GetNativeCell(3);
			if(iRequiredLevel>0) {
				return AddRaceDependency(iRace,iRequiredRace,iRequiredLevel);
			}
			return 0;
		}
		else return ThrowNativeError(SP_ERROR_NATIVE,"required race is invalid!");
	}
	else return ThrowNativeError(SP_ERROR_NATIVE,"race is invalid!");
}

//native War3_RemoveRaceDependency(iRaceID);
public NWar3_RemoveRaceDependency(Handle:plugin,numParams)
{
	if(numParams != 2) {
		return ThrowNativeError(SP_ERROR_NATIVE,"numParams is invalid!");
	}
	new iRace = GetNativeCell(1);
	new iRequiredRace = GetNativeCell(1);
	// the iRequiredRace is correctly put as -1
	if(iRace>0 && iRequiredRace>-1) {
		RemoveRaceDependency(iRace,iRequiredRace);
		return 1;
	}
	else return ThrowNativeError(SP_ERROR_NATIVE,"race is invalid!");
}

//native War3_GetRaceDependency(iRaceID, RaceDependency:eInfo=ID);
public NWar3_FindRaceDependency(Handle:plugin,numParams)
{
	if(numParams != 2) {
		return ThrowNativeError(SP_ERROR_NATIVE,"numParams is invalid!");
	}
	new iRace = GetNativeCell(1);
	if(iRace>0) {
		new iFindRace = GetNativeCell(2);
		if(iFindRace>0) {
			return FindRaceDependency(iRace,iFindRace);
		}
		else return ThrowNativeError(SP_ERROR_NATIVE,"iFindRace is invalid!");
	}
	else return ThrowNativeError(SP_ERROR_NATIVE,"iRace is invalid!");
}


// SKILL DEPENDENCY

public NWar3_AddDependency(Handle:plugin,numParams)
{
	if(numParams != 4) {
		return ThrowNativeError(SP_ERROR_NATIVE,"numParams is invalid!");
	}
	new iRace = GetNativeCell(1);
	if(iRace>0) {
		new iSkill = GetNativeCell(2);
		new iOtherId = GetNativeCell(3);
		new iOtherLevel = GetNativeCell(4);
		if(iOtherLevel>0) {
			skillDependency[iRace][iSkill][SkillDependency:ID] = iOtherId;
			skillDependency[iRace][iSkill][SkillDependency:LVL] = iOtherLevel;
			return 1;
		}
		return 0;
	}
	else return ThrowNativeError(SP_ERROR_NATIVE,"race is invalid!");
}

public NWar3_RemDependency(Handle:plugin,numParams)
{
	if(numParams != 2) {
		return ThrowNativeError(SP_ERROR_NATIVE,"numParams is invalid!");
	}
	new iRace = GetNativeCell(1);
	if(iRace>0) {
		new iSkill = GetNativeCell(2);
		for(new x=0;x<2;x++)
		{
			skillDependency[iRace][iSkill][x] = INVALID_DEPENDENCY;
		}
		return 1;
	}
	else return ThrowNativeError(SP_ERROR_NATIVE,"race is invalid!");
}

public NWar3_GetDependency(Handle:plugin,numParams)
{
	if(numParams != 3) {
		return ThrowNativeError(SP_ERROR_NATIVE,"numParams is invalid!");
	}
	new iRace = GetNativeCell(1);
	if(iRace>0) {
		new iSkill = GetNativeCell(2);
		new iIndex = GetNativeCell(3);
		return skillDependency[iRace][iSkill][iIndex];
	}
	else return ThrowNativeError(SP_ERROR_NATIVE,"race is invalid!");
}
