//War3Source_Addon_2ndGenerationRacesBackwardsCompatible_OPT.sp

#include "W3SIncs/War3Source_Interface"

#assert GGAMEMODE == MODE_WAR3SOURCE

ValveGameEnum tValveGame;

int dummyresult;

Handle g_War3GlobalEventFH;
Handle g_OnWar3EventSpawnFH;

Handle g_OnUltimateCommandHandle;
Handle g_OnAbilityCommandHandle;

Handle FHOnW3TakeDmgAllPre;
Handle FHOnW3TakeDmgBulletPre;
Handle FHOnW3EnemyTakeDmgBulletPre;
Handle FHOnW3TakeDmgAll;
Handle FHOnW3TakeDmgBullet;

Handle g_OnWar3EventPostHurtFH;

public Plugin:myinfo=
{
	name="War3Source 2nd Gen Race Compatibility",
	author="El Diablo",
	description="War3Source Optional Addon",
	version="1.0",
	url="http://war3evo.info/"
};

//=============================================================================
// AskPluginLoad2
//=============================================================================
public APLRes:AskPluginLoad2(Handle:plugin,bool:late,String:error[],err_max)
{
	//DetermineGameMode();
	char game[64];
	GetGameFolderName(game, sizeof(game));
#if GGAMETYPE == GGAME_TF2
	if (strncmp(game, "tf", 2, false) != 0)
	{
		tValveGame = Game_TF;
		strcopy(error, err_max, "War3Source:EVO is currently built for TF2. Look for a compiled version for your game mode.");
		return APLRes_Failure;
	}
#elseif GGAMETYPE == GGAME_CSS
	if (strncmp(game, "cstrike", 7, false) != 0)
	{
		tValveGame = Game_CS;
		strcopy(error, err_max, "War3Source:EVO is currently built for CSS. Look for a compiled version for your game mode.");
		return APLRes_Failure;
	}
#elseif GGAMETYPE == GGAME_FOF
	if (strncmp(game, "fof", 3, false) != 0)
	{
		tValveGame = Game_FOF;
		strcopy(error, err_max, "War3Source:EVO is currently built for FOF. Look for a compiled version for your game mode.");
		return APLRes_Failure;
	}
#elseif GGAMETYPE == GGAME_CSGO
	if (strncmp(game, "csgo", 4, false) != 0)
	{
		tValveGame = Game_CSGO;
		strcopy(error, err_max, "War3Source:EVO is currently built for CSGO. Look for a compiled version for your game mode.");
		return APLRes_Failure;
	}
#endif

	g_War3GlobalEventFH=CreateGlobalForward("OnWar3Event",ET_Ignore,Param_Cell,Param_Cell);

	g_OnWar3EventSpawnFH = CreateGlobalForward("OnWar3EventSpawn", ET_Ignore, Param_Cell);

	g_OnUltimateCommandHandle=CreateGlobalForward("OnUltimateCommand",ET_Ignore,Param_Cell,Param_Cell,Param_Cell,Param_Cell);
	g_OnAbilityCommandHandle=CreateGlobalForward("OnAbilityCommand",ET_Ignore,Param_Cell,Param_Cell,Param_Cell);

	FHOnW3TakeDmgAllPre=CreateGlobalForward("OnW3TakeDmgAllPre",ET_Hook,Param_Cell,Param_Cell,Param_Cell);
	FHOnW3TakeDmgBulletPre=CreateGlobalForward("OnW3TakeDmgBulletPre",ET_Hook,Param_Cell,Param_Cell,Param_Cell);
	FHOnW3EnemyTakeDmgBulletPre=CreateGlobalForward("OnW3EnemyTakeDmgBulletPre",ET_Hook,Param_Cell,Param_Cell,Param_Cell);
	FHOnW3TakeDmgAll=CreateGlobalForward("OnW3TakeDmgAll",ET_Hook,Param_Cell,Param_Cell,Param_Cell);
	FHOnW3TakeDmgBullet=CreateGlobalForward("OnW3TakeDmgBullet",ET_Hook,Param_Cell,Param_Cell,Param_Cell);

	g_OnWar3EventPostHurtFH = CreateGlobalForward("OnWar3EventPostHurt", ET_Ignore, Param_Cell, Param_Cell, Param_Float, Param_String, Param_Cell);

	CreateNative("War3_GetGame",Native_War3_GetGame);

	return APLRes_Success;
}

public void OnAllPluginsLoaded()
{
	W3Hook(W3Hook_OnWar3Event, War3Source_EVO_OnWar3Event);

	W3Hook(W3Hook_OnWar3EventSpawn, War3Source_EVO_OnWar3EventSpawn);

	W3Hook(W3Hook_OnW3TakeDmgAllPre, War3Source_EVO_OnW3TakeDmgAllPre);
	W3Hook(W3Hook_OnW3TakeDmgBulletPre, War3Source_EVO_OnW3TakeDmgBulletPre);
	W3Hook(W3Hook_OnW3TakeDmgAll, War3Source_EVO_OnW3TakeDmgAll);
	W3Hook(W3Hook_OnW3TakeDmgBullet, War3Source_EVO_OnW3TakeDmgBullet);
	W3Hook(W3Hook_OnWar3EventPostHurt, War3Source_EVO_OnWar3EventPostHurt);

	W3Hook(W3Hook_OnUltimateCommand, War3Source_EVO_OnUltimateCommand);
	W3Hook(W3Hook_OnAbilityCommand, War3Source_EVO_OnAbilityCommand);

}

public void War3Source_EVO_OnWar3Event(W3EVENT event,int client)
{
	Call_StartForward(g_War3GlobalEventFH);
	Call_PushCell(event);
	Call_PushCell(client);
	Call_Finish(dummyresult); //this will be returned to
}

public void War3Source_EVO_OnWar3EventSpawn (int client)
{
	Call_StartForward(g_OnWar3EventSpawnFH);
	Call_PushCell(client);
	Call_Finish(dummyresult); //this will be returned to
}

public Action War3Source_EVO_OnW3TakeDmgAllPre(int victim,int attacker, float damage)
{
	Call_StartForward(FHOnW3TakeDmgAllPre);
	Call_PushCell(victim);
	Call_PushCell(attacker);
	Call_PushCell(damage);
	Call_Finish(dummyresult);
}
public Action War3Source_EVO_OnW3TakeDmgAll(int victim,int attacker, float damage)
{
	Call_StartForward(FHOnW3TakeDmgAll);
	Call_PushCell(victim);
	Call_PushCell(attacker);
	Call_PushCell(damage);
	Call_Finish(dummyresult); //this will be returned to
}
public Action War3Source_EVO_OnW3TakeDmgBullet(int victim,int attacker, float damage)
{
	Call_StartForward(FHOnW3TakeDmgBullet);
	Call_PushCell(victim);
	Call_PushCell(attacker);
	Call_PushCell(damage);
	Call_Finish(dummyresult);
}

public Action War3Source_EVO_OnW3TakeDmgBulletPre(int victim, int attacker, float damage, int damagecustom)
{
	Call_StartForward(FHOnW3TakeDmgBulletPre);
	Call_PushCell(victim);
	Call_PushCell(attacker);
	Call_PushCell(damage);
	Call_Finish(dummyresult);
	// Not sure why War3Source 2nd Generation added this to their damage instead of just checking inside their race.
	// Feel Free to remove this if only blood hunter race is using it,
	// then modify their blood hunter race for the below if check:
	if(ValidPlayer(victim, true) && ValidPlayer(attacker) && victim != attacker && GetClientTeam(victim) != GetClientTeam(attacker))
	{
		Call_StartForward(FHOnW3EnemyTakeDmgBulletPre);
		Call_PushCell(victim);
		Call_PushCell(attacker);
		Call_PushCell(damage);
		Call_Finish(dummyresult);
	}
}

public Action War3Source_EVO_OnWar3EventPostHurt(int victim, int attacker, float dmgamount, char weapon[32], bool isWarcraft, const float damageForce[3], const float damagePosition[3])
{
	Call_StartForward(g_OnWar3EventPostHurtFH);
	Call_PushCell(victim);
	Call_PushCell(attacker);
	Call_PushFloat(dmgamount);
	Call_PushString(weapon);
	Call_PushCell(isWarcraft);
	Call_Finish(dummyresult);
}

public void War3Source_EVO_OnUltimateCommand(int client, int race, bool pressed, bool bypass)
{
	Call_StartForward(g_OnUltimateCommandHandle);
	Call_PushCell(client);
	Call_PushCell(race);
	Call_PushCell(pressed);
	Call_Finish(dummyresult);
}
public void War3Source_EVO_OnAbilityCommand(int client, int ability, bool pressed, bool bypass)
{
	Call_StartForward(g_OnAbilityCommandHandle);
	Call_PushCell(client);
	Call_PushCell(ability);
	Call_PushCell(pressed);
	Call_Finish(dummyresult);
}

public int Native_War3_GetGame(Handle plugin, int numParams)
{
	return view_as<int>(tValveGame);
}
