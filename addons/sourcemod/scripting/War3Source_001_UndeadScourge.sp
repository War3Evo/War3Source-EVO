//UPDATED FOR WAR3SOURCE EVOLUTION

#include <war3source>
#assert GGAMEMODE == MODE_WAR3SOURCE
#assert GGAMETYPE_JAILBREAK == JAILBREAK_OFF

#define RACE_ID_NUMBER 10
#define RACE_LONGNAME "Undead Scourge"
#define RACE_SHORTNAME "undead"


/**
* File: War3Source_UndeadScourge.sp
* Description: The Undead Scourge race for War3Source.
* Author(s): Anthony Iacono, Necavi, El Diablo
*/

int thisRaceID;

float CritDamageIncrease = 0.25;

#if (GGAMETYPE == GGAME_TF2)
float Reincarnation[5]={0.0,60.0,50.0,40.0,30.0};
float UnholySpeed[5]={1.0,1.05,1.10,1.15,1.24};
float VampirePercent[5]={0.0,0.02,0.06,0.08,0.10};
#else
float Reincarnation[5]={0.0,60.0,50.0,40.0,30.0};
float UnholySpeed[5]={1.0,1.05,1.10,1.15,1.24};
float VampirePercent[5]={0.0,0.02,0.06,0.08,0.10};
#endif

bool RESwarn[MAXPLAYERSCUSTOM];
#if (GGAMETYPE == GGAME_TF2)
Handle ClientInfoMessage;
#endif

// Team switch checker
bool Can_Player_Revive[MAXPLAYERSCUSTOM+1];

// Methodmap inherits W3player methodmap from war3source.inc
methodmap ThisRacePlayer < W3player
{
	// constructor
	public ThisRacePlayer(int playerindex) //constructor
	{
		if(!ValidPlayer(playerindex)) return view_as<ThisRacePlayer>(0);
		return view_as<ThisRacePlayer>(playerindex); //make sure you do validity check on players
	}
	property bool canrevive
	{
		public get() { return Can_Player_Revive[this.index]; }
		public set( bool value ) { Can_Player_Revive[this.index] =  value; }
	}
	property bool RESwarn
	{
		public get() { return RESwarn[this.index]; }
		public set( bool value ) { RESwarn[this.index] =  value; }
	}
#if (GGAMETYPE == GGAME_TF2)
	public void hudmessage( char szMessage[MAX_MESSAGE_LENGTH], any ... )
	{
		char szBuffer[MAX_MESSAGE_LENGTH];
		SetGlobalTransTarget(this.index);
		VFormat(szBuffer, sizeof(szBuffer), szMessage, 3);
		SetHudTextParams(-1.0, -1.0, 0.1, 255, 255, 0, 255);
		ShowSyncHudText(this.index, ClientInfoMessage, szBuffer);
	}
#endif
}


int SKILL_LEECH,SKILL_SPEED,SKILL_LOWGRAV,SKILL_SUICIDE;

public Plugin:myinfo =
{
	name = RACE_LONGNAME,
	author = "PimpinJuice, Necavi, and El Diablo",
	description = "The Undead Scourge race for War3Source:EVO.",
	version = "1.0",
	url = "http://war3source.com"
};

bool HooksLoaded = false;
public void Load_Hooks()
{
	if(HooksLoaded) return;
	HooksLoaded = true;

	W3Hook(W3Hook_OnWar3Event, OnWar3Event);
	W3Hook(W3Hook_OnWar3EventSpawn, OnWar3EventSpawn);
}
public void UnLoad_Hooks()
{
	if(!HooksLoaded) return;
	HooksLoaded = false;

	W3UnhookAll(W3Hook_OnWar3Event);
	W3UnhookAll(W3Hook_OnWar3EventSpawn);
}
bool RaceDisabled=true;
public void OnWar3RaceEnabled(newrace)
{
	if(newrace==thisRaceID)
	{
		Load_Hooks();

		RaceDisabled=false;
	}
}
public void OnWar3RaceDisabled(oldrace)
{
	if(oldrace==thisRaceID)
	{
		RaceDisabled=true;

		UnLoad_Hooks();
	}
}
// War3Source Functions
public OnPluginStart()
{
	//LoadTranslations("w3s.race.undead.phrases");
#if (GGAMETYPE == GGAME_TF2)
	ClientInfoMessage = CreateHudSynchronizer();
#endif

	HookEvent("player_team",PlayerTeamEvent);

	CreateTimer(0.1,ResWarning,_,TIMER_REPEAT);

}
public OnAllPluginsLoaded()
{
	War3_RaceOnPluginStart(RACE_SHORTNAME);
}
public OnMapStart()
{
	// Reset Can Player Revive
	for(int i=1;i<=MaxClients;i++)    // was MAXPLAYERSCUSTOM
	{
		Can_Player_Revive[i]=true;
	}
}

public OnWar3PlayerAuthed(client)
{
	Can_Player_Revive[client]=true;
}

public OnPluginEnd()
{
	if(LibraryExists("RaceClass"))
	{
		//War3Source_Races race = War3Source_Races();
		War3_RaceOnPluginEnd(RACE_SHORTNAME);
	}
}
public OnWar3LoadRaceOrItemOrdered2(num,reloadrace_id,String:shortname[])
{
	// Allows us to be backwards compatibile
	//War3Source_Races race = War3Source_Races();

	if(num==RACE_ID_NUMBER||(reloadrace_id>0&&StrEqual(RACE_SHORTNAME,shortname,false)))
	{
		//thisRaceID=War3_CreateNewRace(RACE_LONGNAME,RACE_SHORTNAME,reloadrace_id,"Suicidal,fast,leech hp");
		//SKILL_LEECH=War3_AddRaceSkill(thisRaceID,"Vampiric Aura","Leech Health\nYou recieve up to 10% of your damage dealt as Health\nCan not buy item mask any level",false,4);
		//SKILL_SPEED=War3_AddRaceSkill(thisRaceID,"Unholy Aura","You run 20% faster",false,4);
		//SKILL_LOWGRAV=War3_AddRaceSkill(thisRaceID,"Blood Lust","When you gain health from Vampiric Aura,\nyour crit chance increases slowly.\nCrit Chance resets on death.\nCrits count as 25% damage increase.",false,4);
		//SKILL_SUICIDE=War3_AddRaceSkill(thisRaceID,"Reincarnation","When you die, you revive on the spot.\nHas a 60/50/40/30 second cooldown.",true,4);
		//War3_CreateRaceEnd(thisRaceID);

		thisRaceID=War3_CreateNewRace(RACE_LONGNAME,RACE_SHORTNAME,reloadrace_id,"Suicidal,fast,leech hp");
		SKILL_LEECH=War3_AddRaceSkill(thisRaceID,"Vampiric Aura","Leech Health\nYou recieve up to 10% of your damage dealt as Health\nCan not buy item mask any level",false,4);
		SKILL_SPEED=War3_AddRaceSkill(thisRaceID,"Unholy Aura","You run 20% faster",false,4);
		SKILL_LOWGRAV=War3_AddRaceSkill(thisRaceID,"Blood Lust","When you gain health from Vampiric Aura,\nyour crit chance increases slowly.\nCrit Chance resets on death.\nCrits count as 25% damage increase.",false,4);
		SKILL_SUICIDE=War3_AddRaceSkill(thisRaceID,"Reincarnation","When you die, you revive on the spot.\nHas a 60/50/40/30 second cooldown.",true,4);
		War3_CreateRaceEnd(thisRaceID);

		War3_AddSkillBuff(thisRaceID, SKILL_LEECH, fVampirePercent, VampirePercent);
		War3_AddSkillBuff(thisRaceID, SKILL_SPEED, fMaxSpeed, UnholySpeed);
		//War3_AddSkillBuff(thisRaceID, SKILL_LOWGRAV, fLowGravitySkill, LevitationGravity);
		War3_SetDependency(thisRaceID, SKILL_LOWGRAV, SKILL_LEECH, 4);
	}
}

/* ***************************  OnRaceChanged *************************************/

public OnRaceChanged(client,oldrace,newrace)
{
	if(newrace==thisRaceID)
	{
		InitPassiveSkills(client);
	}
	else //if(newrace==oldrace)
	{
		RemovePassiveSkills(client);
	}
}
/* ****************************** InitPassiveSkills ************************** */
public InitPassiveSkills(client)
{
}
/* ****************************** RemovePassiveSkills ************************** */
public RemovePassiveSkills(client)
{
	ThisRacePlayer player = ThisRacePlayer(client);
	player.setbuff(fCritChance, thisRaceID, 0.0);
	player.setbuff(iCritMode, thisRaceID, 0,client);
	player.setbuff(fCritModifier, thisRaceID, 1.0,client);
	player.RESwarn = false;
}


public PlayerTeamEvent(Handle:event,const String:name[],bool:dontBroadcast)
{
	if(RaceDisabled)
		return;

// Team Switch checker
	int userid=GetEventInt(event,"userid");
	int client=GetClientOfUserId(userid);
	ThisRacePlayer player = ThisRacePlayer(client);
	if(player)
	{
		player.setbuff(fCritChance, thisRaceID, 0.0);
		player.setbuff(iCritMode, thisRaceID, 0,client);
		player.setbuff(fCritModifier, thisRaceID, 1.0,client);

		player.canrevive = false;
		player.RESwarn = false;

		int skilllevel=player.getskilllevel(thisRaceID,SKILL_SUICIDE);
		CreateTimer(Reincarnation[skilllevel],PlayerCanRevive,userid);

		player.setcooldown(Reincarnation[skilllevel],thisRaceID,SKILL_SUICIDE,false,true);
	}
}

public Action:PlayerCanRevive(Handle:timer,any:userid)
{
// Team Switch checker
	int client=GetClientOfUserId(userid);
	ThisRacePlayer player = ThisRacePlayer(client);
	if(player)
	{
		player.canrevive=true;
	}
}
public OnW3Denyable(W3DENY:event,client)
{
	if(RaceDisabled)
		return;

	if((event == DN_CanBuyItem1) && (W3GetVar(EventArg1) == War3_GetItemIdByShortname("mask")))
	{
		ThisRacePlayer player = ThisRacePlayer(client);
		if(player.raceid==thisRaceID)
		{
			W3Deny();
			player.message("{lightgreen}The mask would suffocate me!");
		}
	}
}

public void OnWar3Event(W3EVENT event,int client)
{
	if(RaceDisabled)
		return;

	ThisRacePlayer player = ThisRacePlayer(client);

	if(event==VampireImmunityCheckPre)
	{
		if(player && player.raceid==thisRaceID)
		{
			W3SetVar(EventArg1, Immunity_Skills);
			W3SetVar(EventArg2, SKILL_LEECH);
			return;
		}
	}
	else if(event==OnVampireBuff)
	{
		if(player)
		{
			if(player.raceid==thisRaceID)
			{
				int skill_level=player.getskilllevel( thisRaceID, SKILL_LOWGRAV );
				if(skill_level>0)
				{
					float CurrentCritChance = player.getbuff(fCritChance,thisRaceID);
					//DP("Crit before %f",CurrentCritChance);
					if(CurrentCritChance<1.0)
					{
						CurrentCritChance+=0.01 * skill_level;
						player.setbuff(fCritChance,thisRaceID,CurrentCritChance,client);
						player.setbuff(iCritMode,thisRaceID,1,client);
						player.setbuff(fCritModifier,thisRaceID,CritDamageIncrease,client);
						player.message("{blue}BloodLust increases crit chance by %f",CurrentCritChance);
					}
					else if(CurrentCritChance>1.0)
					{
						CurrentCritChance=1.0;
						player.setbuff(fCritChance,thisRaceID,CurrentCritChance,client);
						player.setbuff(iCritMode,thisRaceID,1,client);
						player.setbuff(fCritModifier,thisRaceID,CritDamageIncrease,client);
					}
					//DP("Crit after %f",CurrentCritChance);
				}
			}
		}
	}
}

public void OnWar3EventSpawn (int client)
{
	ThisRacePlayer player = ThisRacePlayer(client);
	if(player.raceid==thisRaceID)
	{
		RemovePassiveSkills(client);
	}
}

float djAngle[MAXPLAYERSCUSTOM][3];
float djPos[MAXPLAYERSCUSTOM][3];

public OnWar3EventDeath(victim, attacker)
{
	if(RaceDisabled)
		return;

	ThisRacePlayer pVictim = ThisRacePlayer(victim);
	//ThisRacePlayer pAttacker = ThisRacePlayer(attacker);

	pVictim.setbuff(fCritChance, thisRaceID, 0.0);
	pVictim.setbuff(iCritMode, thisRaceID, 0);
	pVictim.setbuff(fCritModifier, thisRaceID, 1.0);

	if(victim==attacker)
		return;

	int race=W3GetVar(DeathRace);
	int skill=pVictim.getskilllevel(thisRaceID,SKILL_SUICIDE);
//#if (GGAMETYPE == GGAME_TF2)
	//if(!Spying(victim))
	//{
//#endif
	if(race==thisRaceID && skill>0 && !pVictim.hexed && pVictim.skillnotcooldown(thisRaceID,SKILL_SUICIDE,true))
	{
		pVictim.RESwarn = true;
		float VecPos[3];
		float Angles[3];
		War3_CachedAngle(victim,Angles);
		War3_CachedPosition(victim,VecPos);
		djAngle[victim]=Angles;
		djPos[victim]=VecPos;
		CreateTimer(2.5,DoDeathReject,GetClientUserId(victim));

		/*
		if(!War3_IsNewPlayer(victim))
		{
			decl Float:location[3];
			GetClientAbsOrigin(victim,location);
			War3_SuicideBomber(victim, location, SuicideBomberDamageTF[skill], SKILL_SUICIDE, SuicideBomberRadius[skill]);
		}
		else
		{
			W3MsgNewbieProjectBlocked(victim,"Suicide Bomber",
			"You would have\nbeen killed by Undead Scourge's Suicide Bomber,\nbut because you are new\nyou are immune",
			"When your newbie protection wears out,\nyou will need to type lace in chat in order to be immune.");
		}*/
	}
	else if(pVictim.skillcooldown(thisRaceID,SKILL_SUICIDE,true))
	{
		pVictim.message("{blue}Your Reincarnation skill is on cooldown.");
	}
//#if (GGAMETYPE == GGAME_TF2)
	//}
//#endif
}

/* ****************************** DoDeathReject ************************** */

public Action:DoDeathReject(Handle:timer,any:userid)
{
	int client=GetClientOfUserId(userid);
	ThisRacePlayer player = ThisRacePlayer(client);
	if(player)
	{
		if(player.canrevive==false)
		{
			return Plugin_Handled;
		}
		int skilllevel=player.getskilllevel(thisRaceID,SKILL_SUICIDE);
		player.respawn();
		//nsEntity_SetHealth(client, death_reject_health[skilllevel]);
		//War3_EmitSoundToAll(DeathRejectSound,client);
		War3_TeleportEntity(client, djPos[client], djAngle[client], NULL_VECTOR);
		player.RESwarn=false;
		player.setcooldown(Reincarnation[skilllevel],thisRaceID,SKILL_SUICIDE,false,true);
	}
	return Plugin_Continue;
}

public Action:ResWarning(Handle:timer,any:userid)
{
	if(RaceDisabled)
		return;

	ThisRacePlayer player;

	for(int client=1;client<=MaxClients;client++)
	{
		player = ThisRacePlayer(client);
		if(player && player.RESwarn)
		{
#if (GGAMETYPE == GGAME_TF2)
			player.hudmessage("PREPARE TO REVIVE!");
			//SetHudTextParams(-1.0, -1.0, 0.1, 255, 255, 0, 255);
			//ShowSyncHudText(client, ClientInfoMessage, "PREPARE TO REVIVE!");
#else
			player.message("PREPARE TO REVIVE!");
#endif
		}
	}
}
public OnClientPutInServer(client)
{
	ThisRacePlayer player = ThisRacePlayer(client);
	player.RESwarn=false;
}

public OnClientDisconnect(client)
{
	ThisRacePlayer player = ThisRacePlayer(client);
	player.RESwarn=false;
}
