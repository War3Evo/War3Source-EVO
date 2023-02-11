#include <war3source>

#define PLUGIN_VERSION "0.0.0.2 (1/18/2013) 10:40pm EST"
/**
 * File: War3Source_Light_Bender.sp
* Description: The Light Bender race for SourceCraft.
* Author(s): xDr.HaaaaaaaXx
**/

#pragma semicolon 1
//#pragma tabsize 0
//#include <sourcemod>
//#include <sdktools>
//#include <sdktools_stocks>
//#include <sdktools_functions>
//#include <haaaxfunctions>
//#include <colors>

//#include "W3SIncs/War3Source_Interface"
#assert GGAMEMODE == MODE_WAR3SOURCE

#define RACE_ID_NUMBER 570

// War3Source stuff
//new thisRaceID, SKILL_RED, SKILL_GREEN, SKILL_BLUE, SKILL_YELLOW, ULT_DISCO;
int thisRaceID, SKILL_RED, SKILL_GREEN, SKILL_BLUE, ULT_DISCO;

bool HooksLoaded = false;
public void Load_Hooks()
{
	if(HooksLoaded) return;
	HooksLoaded = true;

	W3Hook(W3Hook_OnW3TakeDmgAll, OnW3TakeDmgAll);
	W3Hook(W3Hook_OnUltimateCommand, OnUltimateCommand);
}
public void UnLoad_Hooks()
{
	if(!HooksLoaded) return;
	HooksLoaded = false;

	W3UnhookAll(W3Hook_OnW3TakeDmgAll);
	W3UnhookAll(W3Hook_OnUltimateCommand);
}
bool RaceDisabled=true;
public OnWar3RaceEnabled(newrace)
{
	if(newrace==thisRaceID)
	{
		Load_Hooks();

		RaceDisabled=false;
	}
}
public OnWar3RaceDisabled(oldrace)
{
	if(oldrace==thisRaceID)
	{
		RaceDisabled=true;

		UnLoad_Hooks();
	}
}
//	if(RaceDisabled)
//		return;


//new Float:RGBChance[6] = { 0.00, 0.05, 0.10, 0.15, 0.20, 0.25 };
new Float:RGBChance[6] = { 0.00, 0.05, 0.10, 0.15, 0.20, 0.25 };
//new Float:ClientPos[64][3];
new ClientTarget[64];

const Maximum_Players_array=100;

new HaloSprite, BeamSprite;

public Plugin:myinfo =
{
	name = "War3Source Race - Light Bender",
	author = "xDr.HaaaaaaaXx",
	description = "The Light Bender race for War3Source.",
	version = "1.0.0.0",
	url = ""
};

public OnPluginStart()
{
	CreateConVar("war3evo_LightBender",PLUGIN_VERSION,"Light Bender",FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
}


public OnMapStart()
{
	UnLoad_Hooks();

	HaloSprite = PrecacheModel( "materials/sprites/halo01.vmt" );
	BeamSprite = PrecacheModel( "materials/sprites/laser.vmt" );
/*  for(new i;i<Maximum_Players_array;i++)
   {
   if( War3_GetRace(i) == thisRaceID )
	 {
	   Restrict_weapon_Class(i);
	 }
   }*/
}
public OnAllPluginsLoaded()
{

	War3_RaceOnPluginStart("lightbender");
}

public OnPluginEnd()
{
	if(LibraryExists("RaceClass"))
		War3_RaceOnPluginEnd("lightbender");
}


//public OnWar3PluginReady()
//{
public OnWar3LoadRaceOrItemOrdered2(num,reloadrace_id,String:shortname[])
{
	if(num==RACE_ID_NUMBER||(reloadrace_id>0&&StrEqual("lightbender",shortname,false)))
	{
	thisRaceID = War3_CreateNewRace( "Light Bender", "lightbender",reloadrace_id,"Pyros favorite race");

	SKILL_RED = War3_AddRaceSkill( thisRaceID, "Red Laser: Burn", "Burn your targets", false, 5 );
	SKILL_GREEN = War3_AddRaceSkill( thisRaceID, "Green Laser: Hex", "Hex your Targets for 1.0 second (1.25 second cooldown)\nHexing makes players skills not work.", false, 5);
	SKILL_BLUE = War3_AddRaceSkill( thisRaceID, "Blue Laser: Freeze", "Freeze your Targets for 0.75 seconds (10 second cooldown)", false, 5 );
	//SKILL_YELLOW = War3_AddRaceSkill( thisRaceID, "Yellow Laser: ", "Silence your Targets for 1.0 second (1.25 second cooldown)\nSilence makes players unable to cast spells.", false, 5 );
	ULT_DISCO = War3_AddRaceSkill( thisRaceID, "Flash", "Teleport a random ally!", true, 1 );

	//W3SkillCooldownOnSpawn( thisRaceID, ULT_DISCO, 35.0, false );

	War3_CreateRaceEnd( thisRaceID );
	}
}


public OnRaceChanged(client,oldrace,newrace)
{
	if( newrace == thisRaceID )
	{
		//W3ResetAllBuffRace( client, thisRaceID );
		//TF2_RemoveCondition(client, TFCond_RestrictToMelee);
		//War3_WeaponRestrictTo(client,thisRaceID,"",0);
	}
	else
	{
		W3ResetAllBuffRace( client, thisRaceID );
		//War3_WeaponRestrictTo(client,raceid,String:onlyallowedweaponsnames[],priority=1);
		//War3_WeaponRestrictTo(client,thisRaceID,Restrict_Weapons,1);
		//TF2_AddCondition(client,TFCond_RestrictToMelee,-1.0);
	}
}

public OnWar3EventDeath( victim, attacker )
{
	W3ResetAllBuffRace( victim, thisRaceID );
}

//public OnWar3EventPostHurt( victim, attacker, damage )
public Action OnW3TakeDmgAll(int victim,int attacker, float damage)
{
	if(RaceDisabled)
		return;
#if (GGAMETYPE == GGAME_TF2)
	if(!W3IsOwnerSentry(attacker))
	{
#endif
		if(W3GetDamageIsBullet() && ValidPlayer( victim, true ) && ValidPlayer( attacker, true ) && GetClientTeam( victim ) != GetClientTeam( attacker ) )
		{
			if( War3_GetRace( attacker ) == thisRaceID )
			{
				new skill_red = War3_GetSkillLevel( attacker, thisRaceID, SKILL_RED );
				if( !Hexed( attacker, false ) && skill_red > 0 && GetRandomFloat( 0.0, 1.0 ) <= RGBChance[skill_red] )
				{
					if(!W3HasImmunity(victim,Immunity_Skills))
					{
						IgniteEntity( victim, 1.0 );
						//IgniteEntity( victim, 5.0 );

						//CPrintToChat( victim, "{red}Red Laser{default} :  Burn" );
						//CPrintToChat( attacker, "{red}Red Laser{default} :  Burn" );

						new Float:StartPos[3];
						new Float:EndPos[3];

						GetClientAbsOrigin( victim, StartPos );

						GetClientAbsOrigin( victim, EndPos );

						EndPos[0] += GetRandomFloat( -100.0, 100.0 );
						EndPos[1] += GetRandomFloat( -100.0, 100.0 );
						EndPos[2] += GetRandomFloat( -100.0, 100.0 );

						TE_SetupBeamPoints( StartPos, EndPos, BeamSprite, HaloSprite, 0, 1, 4.0, 20.0, 2.0, 0, 0.0, { 255, 11, 15, 255 }, 1 );
						TE_SendToAll();

						GetClientAbsOrigin( victim, EndPos );

						EndPos[0] += GetRandomFloat( -100.0, 100.0 );
						EndPos[1] += GetRandomFloat( -100.0, 100.0 );
						EndPos[2] += GetRandomFloat( -100.0, 100.0 );

						TE_SetupBeamPoints( StartPos, EndPos, BeamSprite, HaloSprite, 0, 1, 4.0, 20.0, 2.0, 0, 0.0, { 255, 11, 15, 255 }, 1 );
						TE_SendToAll();

						GetClientAbsOrigin( victim, EndPos );

						EndPos[0] += GetRandomFloat( -100.0, 100.0 );
						EndPos[1] += GetRandomFloat( -100.0, 100.0 );
						EndPos[2] += GetRandomFloat( -100.0, 100.0 );

						TE_SetupBeamPoints( StartPos, EndPos, BeamSprite, HaloSprite, 0, 1, 4.0, 20.0, 2.0, 0, 0.0, { 255, 11, 15, 255 }, 1 );
						TE_SendToAll();
					}
					else
					{
						War3_NotifyPlayerImmuneFromSkill(attacker, victim, SKILL_RED);
					}
				}

				new skill_green = War3_GetSkillLevel( attacker, thisRaceID, SKILL_GREEN );
				if( !Hexed( attacker, false ) && skill_green > 0 && GetRandomFloat( 0.0, 1.0 ) <= RGBChance[skill_green] && War3_SkillNotInCooldown(attacker, thisRaceID, SKILL_GREEN, true))
				{
					if(!W3HasImmunity(victim,Immunity_Skills))
					{
						//War3_ShakeScreen( victim );
						War3_SetBuff( victim, bHexed, thisRaceID, true, attacker );
						CreateTimer( 1.0, StopHex, victim );
						War3_CooldownMGR( attacker, 1.25, thisRaceID, SKILL_GREEN, true, true);

						//CPrintToChat( victim, "{green}Green Laser{default} :  Hex" );
						//CPrintToChat( attacker, "{green}Green Laser{default} :  Hex" );

						new Float:StartPos[3];
						new Float:EndPos[3];

						GetClientAbsOrigin( victim, StartPos );

						GetClientAbsOrigin( victim, EndPos );

						EndPos[0] += GetRandomFloat( -100.0, 100.0 );
						EndPos[1] += GetRandomFloat( -100.0, 100.0 );
						EndPos[2] += GetRandomFloat( -100.0, 100.0 );

						TE_SetupBeamPoints( StartPos, EndPos, BeamSprite, HaloSprite, 0, 1, 4.0, 20.0, 2.0, 0, 0.0, { 11, 255, 15, 255 }, 1 );
						TE_SendToAll();

						GetClientAbsOrigin( victim, EndPos );

						EndPos[0] += GetRandomFloat( -100.0, 100.0 );
						EndPos[1] += GetRandomFloat( -100.0, 100.0 );
						EndPos[2] += GetRandomFloat( -100.0, 100.0 );

						TE_SetupBeamPoints( StartPos, EndPos, BeamSprite, HaloSprite, 0, 1, 4.0, 20.0, 2.0, 0, 0.0, { 11, 255, 15, 255 }, 1 );
						TE_SendToAll();

						GetClientAbsOrigin( victim, EndPos );

						EndPos[0] += GetRandomFloat( -100.0, 100.0 );
						EndPos[1] += GetRandomFloat( -100.0, 100.0 );
						EndPos[2] += GetRandomFloat( -100.0, 100.0 );

						TE_SetupBeamPoints( StartPos, EndPos, BeamSprite, HaloSprite, 0, 1, 4.0, 20.0, 2.0, 0, 0.0, { 11, 255, 15, 255 }, 1 );
						TE_SendToAll();
					}
					else
					{
						War3_NotifyPlayerImmuneFromSkill(attacker, victim, SKILL_GREEN);
					}
				}

				new skill_blue = War3_GetSkillLevel( attacker, thisRaceID, SKILL_BLUE );
				if(!Hexed( attacker, false ) && skill_blue > 0 && GetRandomFloat( 0.0, 1.0 ) <= RGBChance[skill_blue] && War3_SkillNotInCooldown(attacker, thisRaceID, SKILL_BLUE, true))
				{
					if(!W3HasImmunity(victim,Immunity_Skills))
					{
						War3_SetBuff( victim, bNoMoveMode, thisRaceID, true, attacker );
						//CreateTimer( 3.0, StopFreeze, victim );
						CreateTimer( 0.75, StopFreeze, victim );
						War3_CooldownMGR( attacker, 10.0, thisRaceID, SKILL_BLUE, true, true);

						//CPrintToChat( victim, "{blue}Blue Laser{default} :  Freeze" );
						//CPrintToChat( attacker, "{blue}Blue Laser{default} :  Freeze" );

						new Float:StartPos[3];
						new Float:EndPos[3];

						GetClientAbsOrigin( victim, StartPos );
						GetClientAbsOrigin( victim, EndPos );

						EndPos[0] += GetRandomFloat( -100.0, 100.0 );
						EndPos[1] += GetRandomFloat( -100.0, 100.0 );
						EndPos[2] += GetRandomFloat( -100.0, 100.0 );

						TE_SetupBeamPoints( StartPos, EndPos, BeamSprite, HaloSprite, 0, 1, 4.0, 20.0, 2.0, 0, 0.0, { 15, 11, 255, 255 }, 1 );
						TE_SendToAll();

						GetClientAbsOrigin( victim, EndPos );

						EndPos[0] += GetRandomFloat( -100.0, 100.0 );
						EndPos[1] += GetRandomFloat( -100.0, 100.0 );
						EndPos[2] += GetRandomFloat( -100.0, 100.0 );

						TE_SetupBeamPoints( StartPos, EndPos, BeamSprite, HaloSprite, 0, 1, 4.0, 20.0, 2.0, 0, 0.0, { 15, 11, 255, 255 }, 1 );
						TE_SendToAll();

						GetClientAbsOrigin( victim, EndPos );

						EndPos[0] += GetRandomFloat( -100.0, 100.0 );
						EndPos[1] += GetRandomFloat( -100.0, 100.0 );
						EndPos[2] += GetRandomFloat( -100.0, 100.0 );

						TE_SetupBeamPoints( StartPos, EndPos, BeamSprite, HaloSprite, 0, 1, 4.0, 20.0, 2.0, 0, 0.0, { 15, 11, 255, 255 }, 1 );
						TE_SendToAll();
					}
					else
					{
						War3_NotifyPlayerImmuneFromSkill(attacker, victim, SKILL_BLUE);
					}
				}

				//Yellow Laser
				/*
				new skill_yellow = War3_GetSkillLevel( attacker, thisRaceID, SKILL_YELLOW );
				if(!Hexed( attacker, false ) && skill_yellow > 0 && GetRandomFloat( 0.0, 1.0 ) <= RGBChance[skill_yellow] && War3_SkillNotInCooldown(attacker, thisRaceID, SKILL_YELLOW, true))
				{
					if(!W3HasImmunity(victim,Immunity_Skills))
					{
						War3_SetBuff( victim, bSilenced, thisRaceID, true, attacker );
						//CreateTimer( 3.0, StopFreeze, victim );
						CreateTimer( 1.0, StopSilence, victim );
						War3_CooldownMGR( attacker, 1.25, thisRaceID, SKILL_YELLOW, true, true);

						//CPrintToChat( victim, "{blue}Blue Laser{default} :  Freeze" );
						//CPrintToChat( attacker, "{blue}Blue Laser{default} :  Freeze" );

						new Float:StartPos[3];
						new Float:EndPos[3];

						GetClientAbsOrigin( victim, StartPos );
						GetClientAbsOrigin( victim, EndPos );

						EndPos[0] += GetRandomFloat( -100.0, 100.0 );
						EndPos[1] += GetRandomFloat( -100.0, 100.0 );
						EndPos[2] += GetRandomFloat( -100.0, 100.0 );

						TE_SetupBeamPoints( StartPos, EndPos, BeamSprite, HaloSprite, 0, 1, 4.0, 20.0, 2.0, 0, 0.0, { 255, 255, 25, 255 }, 1 );
						TE_SendToAll();

						GetClientAbsOrigin( victim, EndPos );

						EndPos[0] += GetRandomFloat( -100.0, 100.0 );
						EndPos[1] += GetRandomFloat( -100.0, 100.0 );
						EndPos[2] += GetRandomFloat( -100.0, 100.0 );

						TE_SetupBeamPoints( StartPos, EndPos, BeamSprite, HaloSprite, 0, 1, 4.0, 20.0, 2.0, 0, 0.0, { 255, 255, 25, 255 }, 1 );
						TE_SendToAll();

						GetClientAbsOrigin( victim, EndPos );

						EndPos[0] += GetRandomFloat( -100.0, 100.0 );
						EndPos[1] += GetRandomFloat( -100.0, 100.0 );
						EndPos[2] += GetRandomFloat( -100.0, 100.0 );

						TE_SetupBeamPoints( StartPos, EndPos, BeamSprite, HaloSprite, 0, 1, 4.0, 20.0, 2.0, 0, 0.0, { 255, 255, 25, 255 }, 1 );
						TE_SendToAll();
					}
					else
					{
						War3_NotifyPlayerImmuneFromSkill(attacker, victim, SKILL_YELLOW);
					}
				}*/
			}
		}
#if (GGAMETYPE == GGAME_TF2)
	}
#endif
}

public Action:StopSilence( Handle:timer, any:client )
{
	if( ValidPlayer( client ) )
	{
		War3_SetBuff( client, bSilenced, thisRaceID, false );
	}
}

public Action:StopFreeze( Handle:timer, any:client )
{
	if( ValidPlayer( client ) )
	{
		War3_SetBuff( client, bNoMoveMode, thisRaceID, false );
	}
}

public Action:StopHex( Handle:timer, any:client )
{
	if( ValidPlayer( client ) )
	{
		War3_SetBuff( client, bHexed, thisRaceID, false );
	}
}

public void OnUltimateCommand(int client, int race, bool pressed, bool bypass)
{
	if(RaceDisabled)
		return;

	if( race == thisRaceID && pressed && ValidPlayer( client, true ) )
	{
		new ult_level = War3_GetSkillLevel( client, race, ULT_DISCO );
		if( ult_level > 0)
		{
			if( War3_SkillNotInCooldown( client, thisRaceID, ULT_DISCO, true ) )
			{
				Disco( client );
			}
		}
		else
		{
			PrintHintText( client, "Level Your Ultimate First" );
		}
	}
}

stock Disco( client )
{
	// changing so that the client goes to a random ally player
	if( GetClientTeam( client ) == TEAM_T )
		ClientTarget[client] = War3_GetRandomPlayer( "#t", true, true );
	if( GetClientTeam( client ) == TEAM_CT )
		ClientTarget[client] = War3_GetRandomPlayer( "#ct", true, true );

	if( ClientTarget[client] == 0 || ClientTarget[client] == client )
	{
		PrintHintText( client, "No Target Found" );
	}
	else
	{
		//GetClientAbsOrigin( ClientTarget[client], ClientPos[client] );
		CreateTimer( 3.0, myTeleport, client );

		new String:NameAttacker[64];
		GetClientName( client, NameAttacker, 64 );

		new String:NameVictim[64];
		GetClientName( ClientTarget[client], NameVictim, 64 );

		PrintToChat( ClientTarget[client], "\x05: \x4%s \x03will teleport to you and to aid you in your \x04fight \x03in \x043 \x03seconds", NameAttacker );
		PrintToChat( client, "\x05: \x03You will teleport to \x04%s \x03and aid him/her in thier \x04fight \x03in \x043 \x03seconds", NameVictim );

		War3_CooldownMGR( client, 20.0, thisRaceID, ULT_DISCO, true, true);
	}
}

public Action:myTeleport( Handle:timer, any:client )
{
	if( ValidPlayer( ClientTarget[client], true ) )
	{
		//new Float:ang[3];
		//new Float:ClientPos[3];
		//GetClientAbsOrigin( ClientTarget[client], ClientPos );
		//GetClientEyeAngles( ClientTarget[client], ang);
		//ClientPos[1] -= 50;
		// lightbender teleports to his allly
		//TeleportEntity( client, ClientPos, ang, NULL_VECTOR );
		War3Teleport(client,ClientTarget[client],-1.0,999999.0,thisRaceID,ULT_DISCO);
	}
	else
	{
		War3_CooldownReset(client, thisRaceID, ULT_DISCO);
		PrintHintText( client, "Your Target Died!" );
	}
}

public War3_GetRandomPlayer( const String:type[], bool:check_alive, bool:check_immunity )
{
	new targettable[MaxClients];
	new target = 0;
	new bool:all;
	new x = 0;
	new team;
	if( StrEqual( type, "#t" ) )
	{
		team = TEAM_T;
		all = false;
	}
	else if( StrEqual( type, "#ct" ) )
	{
		team = TEAM_CT;
		all = false;
	}
	else if( StrEqual( type, "#a" ) )
	{
		team = 0;
		all = true;
	}
	for( new i = 1; i <= MaxClients; i++ )
	{
		if( i > 0 && i <= MaxClients && IsClientConnected( i ) && IsClientInGame( i ) )
		{
			if( check_alive && !IsPlayerAlive( i ) )
	continue;
			if( check_immunity && W3HasImmunity( i, Immunity_Ultimates ) )
	continue;
			if( !all && GetClientTeam( i ) != team )
	continue;
			targettable[x] = i;
			x++;
		}
	}
	for( new y = 0; y <= x; y++ )
	{
		if( target == 0 )
		{
			target = targettable[GetRandomInt( 0, x - 1 )];
		}
		else if( target != 0 && target > 0 )
		{
			return target;
		}
	}
	return 0;
}
