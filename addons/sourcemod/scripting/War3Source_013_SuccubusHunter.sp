#include <war3source>

#assert GGAMEMODE == MODE_WAR3SOURCE

#define RACE_ID_NUMBER 130

/**
* vim: set ai et ts=4 sw=4 :
* File: War3Source_SuccubusHunter.sp
* Description: The Succubus Hunter race for SourceCraft.
* Author(s): DisturbeD
* Adapted to TF2 by: -=|JFH|=-Naris (Murray Wilson)
* Offcially ported to War3Source by Ownz (DarkEnergy)
*/

//#pragma semicolon 1
//#include <sourcemod>
//#include <sdktools_tempents>
//#include <sdktools_functions>
//#include <sdktools_tempents_stocks>
//#include <sdktools_entinput>
//#include <sdktools_sound>

//#include "W3SIncs/War3Source_Interface"
public W3ONLY(){} //unload this?

new thisRaceID, SKILL_HEADHUNTER, SKILL_TOTEM, SKILL_ASSAULT, ULT_TRANSFORM;
#if (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
//new m_iAccount = -1, m_vecVelocity_1, m_vecBaseVelocity; //offsets
new m_vecVelocity_1, m_vecBaseVelocity; //offsets
#endif
new m_vecVelocity_0;


//new bool:hurt_flag = true;
new bool:m_IsULT_TRANSFORMformed[MAXPLAYERSCUSTOM];
new skulls[MAXPLAYERSCUSTOM];
//Effects
//new BeamSprite;
new Laser;

new bool:lastframewasground[MAXPLAYERSCUSTOM];
new Handle:ultCooldownCvar;

new Float:assaultcooldown=10.0;

public Plugin:myinfo =
{
	name = "Race - Succubus Hunter",
	author = "DisturbeD",
	description = "",
	version = "2.0.6",
	url = "http://war3source.com/"
};

bool HooksLoaded = false;
public void Load_Hooks()
{
	if(HooksLoaded) return;
	HooksLoaded = true;

	W3Hook(W3Hook_OnW3TakeDmgAll, OnW3TakeDmgAll);
	W3Hook(W3Hook_OnUltimateCommand, OnUltimateCommand);
	W3Hook(W3Hook_OnWar3EventSpawn, OnWar3EventSpawn);
}
public void UnLoad_Hooks()
{
	if(!HooksLoaded) return;
	HooksLoaded = false;

	W3UnhookAll(W3Hook_OnW3TakeDmgAll);
	W3UnhookAll(W3Hook_OnUltimateCommand);
	W3UnhookAll(W3Hook_OnWar3EventSpawn);
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

public OnMapStart()
{
	UnLoad_Hooks();

	//PrecacheSound("npc/fast_zombie/claw_strike1.wav");
	PrecacheModel("models/gibs/hgibs.mdl", true);
	//BeamSprite=PrecacheModel("materials/sprites/purpleglow1.vmt");
	Laser=PrecacheModel("materials/sprites/laserbeam.vmt");
}
public OnW3Denyable(W3DENY:event,client)
{
	if(RaceDisabled)
		return;

	if(War3_GetRace(client)==thisRaceID)
	{
		if((event == DN_CanBuyItem1) && (W3GetVar(EventArg1) == War3_GetItemIdByShortname("gauntlet")))
		{
			W3Deny();
			War3_ChatMessage(client, "The gauntlet is too heavy ...");
		}
	}
	if(War3_GetRace(client)==thisRaceID)
	{
		if((event == DN_CanBuyItem1) && (W3GetVar(EventArg1) == War3_GetItemIdByShortname("claw")))
		{
			W3Deny();
			War3_ChatMessage(client, "Your claws are already sharpened...");
		}
	}
}
public OnWar3LoadRaceOrItemOrdered2(num,reloadrace_id,String:shortname[])
{
	if(num==RACE_ID_NUMBER||(reloadrace_id>0&&StrEqual("succubus",shortname,false)))
	{
		thisRaceID=War3_CreateNewRace("Succubus Hunter","succubus",reloadrace_id,"Collect Skulls");

		SKILL_HEADHUNTER = War3_AddRaceSkill(thisRaceID, "Head Hunter","Deal extra 0-20% damage, proportional\nto the number of skulls you have. \nYou gain your victim's SKULLs on kill", false);
		SKILL_TOTEM = War3_AddRaceSkill(thisRaceID, "Totem Incantation","You gain 1-3 HP, 25-50$ or some credits and 1-5XP on spawn for each skull you collected. You lose 3 skulls on spawn.", false);
		SKILL_ASSAULT = War3_AddRaceSkill(thisRaceID, "Assault Tackle","Gives you a boost of speed when you jump.", false);
		ULT_TRANSFORM = War3_AddRaceSkill(thisRaceID, "Deamonic Transformation","Get More speed, and more HP. Costs 1/2/3/4 SKULLs", true);
		War3_CreateRaceEnd(thisRaceID);

	}
}

public OnPluginStart()
{
	//m_vecVelocity_0 = FindSendPropOffs("CBasePlayer","m_vecVelocity[0]");
	m_vecVelocity_0 = FindSendPropInfo("CBasePlayer","m_vecVelocity[0]");

	//HookEvent("player_hurt",PlayerHurtEvent);
	//HookEvent("player_death",PlayerDeathEvent);

	AddCommandListener(SayCommand, "say");
	AddCommandListener(SayCommand, "say_team");
#if (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
	HookEvent("player_jump",PlayerJumpEvent);
	//m_iAccount = FindSendPropOffs("CCSPlayer", "m_iAccount");
	m_vecVelocity_1 = FindSendPropOffs("CBasePlayer","m_vecVelocity[1]");
	m_vecBaseVelocity = FindSendPropOffs("CBasePlayer","m_vecBaseVelocity");
#endif

	ultCooldownCvar=CreateConVar("war3_succ_ult_cooldown","20","Cooldown for succubus ultimate");

	//LoadTranslations("w3s.race.succubus.phrases");
}

public OnAllPluginsLoaded()
{
	War3_RaceOnPluginStart("succubus");
}
public OnPluginEnd()
{
	if(LibraryExists("RaceClass"))
		War3_RaceOnPluginEnd("succubus");
}

public OnRaceChanged(client,oldrace,newrace)
{
	if(newrace==thisRaceID)
	{
		InitPassiveSkills(client);
	}
	else // if(oldrace==thisRaceID)
	{
		RemovePassiveSkills(client);
	}
}

public InitPassiveSkills(client)
{
	// Natural Armor Buff
	//War3_SetBuff(client,fArmorPhysical,thisRaceID,3.0);
}

public RemovePassiveSkills(client)
{
	//War3_SetBuff(client,fArmorPhysical,thisRaceID,0.0);
	War3_SetBuff(client,iAdditionalMaxHealth,thisRaceID,0);
}


public void OnWar3EventSpawn (int client)
{
	if(RaceDisabled)
		return;

	new race=War3_GetRace(client);
	if (race==thisRaceID)
	{
		m_IsULT_TRANSFORMformed[client]=false;
		War3_SetBuff(client,fMaxSpeed,thisRaceID,1.0);
		//War3_SetBuff(client,fLowGravitySkill,thisRaceID,1.0);



		new skillleveltotem=War3_GetSkillLevel(client,race,SKILL_TOTEM);
		if (skillleveltotem )
		{
			//new maxhp = War3_GetMaxHP(client);
			new hp, dollar, xp;
			switch(skillleveltotem)
			{
				case 1:
				{
					//hp=RoundToNearest(float(maxhp) * 0.01);
					hp=1;
					dollar=25;
					xp=1;
				}
				case 2:
				{
					//hp=RoundToNearest(float(maxhp) * 0.01);
					hp=1;
					dollar=30;
					xp=2;
				}
				case 3:
				{
					//hp=RoundToNearest(float(maxhp) * 0.02);
					hp=2;
					dollar=35;
					xp=3;
				}
				case 4:
				{
					//hp=RoundToNearest(float(maxhp) * 0.02);
					hp=3;
					dollar=50;
					xp=5;
				}
			}

			hp *= skulls[client];
			dollar *= skulls[client];
			xp *= skulls[client];

//#if GGAMETYPE == GGAME_CSS
	//		new old_health=GetClientHealth(client);
		//	SetEntityHealth(client,old_health+hp);
//#endif
// SetBuf for TF2 only?
//#elseif
			War3_SetBuff(client,iAdditionalMaxHealth,thisRaceID,hp);
//#endif

			new old_XP = War3_GetXP(client,thisRaceID);
			new kill_XP = W3GetKillXP(client);
			if (xp > kill_XP)
				xp = kill_XP;

			if(W3GetPlayerProp(client,bStatefulSpawn)){
				War3_SetXP(client,thisRaceID,old_XP+xp);
			}

			//if (m_iAccount>0) //game with money
			//{
				//new old_cash=GetEntData(client, m_iAccount);
				//SetEntData(client, m_iAccount, old_cash + dollar);
				//if(W3GetPlayerProp(client,bStatefulSpawn)){
					//PrintToChat(client,"\0x04[Totem Incanation] \0x01You gained %i HP, %i dollars and %i XP",hp,dollar,xp);
				//}
			//}
			else
			{
				new max=W3GetMaxGold(client);

				new old_credits=War3_GetGold(client);
				//PrintToChat(client,"dollar %d",dollar);
				// orignal war3source was 100 gold max.. so.. 100/6 = 17 rounded up
				dollar /= 16; // was dollar /= (max/6);
				//PrintToChat(client,"dollar %d",dollar);
				new new_credits = old_credits + dollar;
				if (new_credits > max)
				new_credits = max;
				//PrintToChat(client,"new_credits %d",new_credits);
				if(W3GetPlayerProp(client,bStatefulSpawn)){
					War3_SetGold(client,new_credits);
				}
				new_credits = War3_GetGold(client);

				if (new_credits > 0){
					dollar = new_credits-old_credits;
				}
				if(W3GetPlayerProp(client,bStatefulSpawn)){
					PrintToChat(client,"\0x04[Totem Incanation] \0x01You gained %i HP, %i credits and %i XP",hp,dollar,xp);
				}
			}
		}
		skulls[client]=skulls[client]-3;
		if(skulls[client]<0)
			skulls[client]=0;
	}
}
// use? OnW3TakeDmgAll
/*
Trying to resolve:  I think we should try OnW3TakeDmgAll because it allows damage.
[SM] Displaying call stack trace for plugin "war3source/War3Source_Engine_DamageSystem.smx":
L 12/08/2012 - 02:58:58: [SM]   [0]  Line 455, War3Source_Engine_DamageSystem.sp::Native_War3_DealDamage()
L 12/08/2012 - 02:58:58: [SM] Plugin encountered error 25: Call was aborted
L 12/08/2012 - 02:58:58: [SM] Native "War3_DealDamage" reported: Error encountered while processing a dynamic native
L 12/08/2012 - 02:58:58: [SM] Displaying call stack trace for plugin "war3source/War3Source_013_SuccubusHunter.smx":
L 12/08/2012 - 02:58:58: [SM]   [0]  Line 213, War3Source_013_SuccubusHunter.sp::OnWar3EventPostHurt()
L 12/08/2012 - 03:06:15: Error log file session closed.
*/
//public OnWar3EventPostHurt(victim,attacker,damage){
public Action OnW3TakeDmgAll(int victim,int attacker, float damage)
{
	if(RaceDisabled)
		return;

	if(W3GetDamageIsBullet()&&ValidPlayer(victim,true,true)&&ValidPlayer(attacker,true)&&victim!=attacker){
		//DP("bullet succ vic alive %d",ValidPlayer(victim,true));
		new skilllevelheadhunter = War3_GetSkillLevel(attacker,thisRaceID,SKILL_HEADHUNTER);
		if (skilllevelheadhunter > 0 &&!Hexed(attacker))
		{
			if(!W3HasImmunity(victim,Immunity_Skills))
			{
				//DP("health %d",GetClientHealth(victim));
				//new xdamage= RoundFloat(0.2*float(damage) * skulls[attacker]/20 );
				new xdamage= RoundFloat(0.2*damage * skulls[attacker]/20 );
				War3_DealDamage(victim,xdamage,attacker,_,"headhunter",W3DMGORIGIN_SKILL,W3DMGTYPE_PHYSICAL);

				//W3PrintSkillDmgConsole(victim,attacker,War3_GetWar3DamageDealt(),SKILL_HEADHUNTER);
				if(xdamage>0)
				{
					War3_NotifyPlayerTookDamageFromSkill(victim, attacker, xdamage, SKILL_HEADHUNTER);
				}
				//DP("deal %d",xdamage);
			}
			else
			{
				War3_NotifyPlayerImmuneFromSkill(attacker, victim, SKILL_HEADHUNTER);
			}
		}

	}
}
/*
public PlayerHurtEvent(Handle:event,const String:name[],bool:dontBroadcast)
{
	if (hurt_flag == false)
	{
		hurt_flag=true; //for skipping your own damage?
		return;
	}

	new victim = GetClientOfUserId(GetEventInt(event,"userid"));
	new attacker = GetClientOfUserId(GetEventInt(event,"attacker"));
	if (victim && attacker && victim!=attacker) // &&hurt_flag==true)
	{

		new race=War3_GetRace(attacker);
		if (race==thisRaceID)
		{
			new dmgamount;
			switch (g_GameType)
			{
				case Game_CS: dmgamount = GetEventInt(event,"dmg_health");
				case Game_TF: dmgamount = GetEventInt(event,"damageamount");
				case Game_DOD: dmgamount = GetEventInt(event,"damage");
			}

			new totaldamage = dmgamount;

			// Head Hunter
			new skilllevelheadhunter = War3_GetSkillLevel(attacker,race,SKILL_HEADHUNTER);
			if (skilllevelheadhunter > 0 && dmgamount > 0 && !W3HasImmunity(victim,Immunity_Skills)&&!Hexed(attacker))
			{
				decl String: weapon[MAX_NAME_LENGTH+1];
				new bool:is_equipment=GetWeapon(event,attacker,weapon,sizeof(weapon));
				new bool:is_melee=IsMelee(weapon, is_equipment, attacker, victim);

				new damage;
				if (is_melee)
				{
					new Float:percent;
					switch(skilllevelheadhunter)
					{
						case 1:
						percent=0.50;
						case 2:
						percent=0.75;
						case 3:
						percent=0.90;
						case 4:
						percent=1.00;
					}
					damage= RoundFloat(float(dmgamount) * percent);
					totaldamage += damage;

					new Float:vec[3];
					GetClientAbsOrigin(attacker,vec);
					vec[2]+=50.0;
					TE_SetupGlowSprite(vec, BeamSprite, 2.0, 10.0, 5);
					TE_SendToAll();
					W3PrintSkillDmgConsole(victim,attacker,damage,SKILL_HEADHUNTER);
					//PrintToConsole(attacker,"%T","[Daemonic Knife] You inflicted +{amount} Damage",attacker,0x04,0x01,damage);
				}
				else
				{
					new percent;
					switch (skilllevelheadhunter)
					{
						case 1:
						percent=10;
						case 2:
						percent=15;
						case 3:
						percent=20;
						case 4:
						percent=30;
					}
					if(GetRandomInt(1,100)<=percent)
					{
						damage= RoundFloat(dmgamount * GetRandomFloat(0.20,0.40)); // 1.20-1.00,1.40-1.00
						totaldamage += damage;
						W3PrintSkillDmgConsole(victim,attacker,damage,SKILL_HEADHUNTER);
						//PrintToConsole(attacker,"%T","[Head Hunter] You inflicted +{amount} Damage",attacker,0x04,0x01,damage);
					}
				}

				if (damage>0)
				{

					hurt_flag = false;
					War3_DealDamage(victim,damage,attacker,_,"headhunter",W3DMGORIGIN_SKILL,W3DMGTYPE_PHYSICAL);
				}
			}
		}
	}
}
*/
public OnWar3EventDeath(victim,attacker){
	if(RaceDisabled)
		return;

	new skilllevelheadhunter=War3_GetSkillLevel(attacker,thisRaceID,SKILL_HEADHUNTER);
	if (skilllevelheadhunter &&!Hexed(attacker)&&victim!=attacker)
	{
		if (skulls[attacker]<(5*skilllevelheadhunter))
		{
			skulls[attacker]++;
			War3_ChatMessage(attacker,"You gained a SKULL [%i/%i]",skulls[attacker],(5*skilllevelheadhunter));
		}
		decl Float:Origin[3], Float:Direction[3];
		GetClientAbsOrigin(victim, Origin);
		Direction[0] = GetRandomFloat(-100.0, 100.0);
		Direction[1] = GetRandomFloat(-100.0, 100.0);
		Direction[2] = 300.0;
		Gib(Origin, Direction, "models/gibs/hgibs.mdl");
	}
}
/*
public PlayerDeathEvent(Handle:event,const String:name[],bool:dontBroadcast)
{
DP("death");
//W3GetVar(SmEvent)
	#define DF_FEIGNDEATH   32
	#define DMG_CRITS       1048576    //crits = DAMAGE_ACID

	static const String:tf2_decap_weapons[][] = { "sword",   "club",      "axtinguisher",
	"fireaxe", "battleaxe", "tribalkukri"};

	new victim = GetClientOfUserId(GetEventInt(event,"userid"));

	if (victim > 0)
	{
		//if (War3_GetRace(victim) == thisRaceID){
		//	if(skulls[victim]>0){
		//		skulls[victim]--;
		//		PrintToConsole(victim,"You lost your own skull");
		//	}
		//}

		new client = GetClientOfUserId(GetEventInt(event,"attacker"));
		if (client > 0 && client != victim)
		{
			if (War3_GetRace(client) == thisRaceID )
			{
				new bool:headshot;
				switch (g_GameType)
				{
					case Game_CS:
					{
						headshot = GetEventBool(event, "headshot");
					}
					case Game_TF:
					{
						// Don't count dead ringer fake deaths
						if ((GetEventInt(event, "death_flags") & DF_FEIGNDEATH) == 0)
						{
							// Check for headshot or backstab
							new customkill = GetEventInt(event, "customkill");
							headshot = (customkill == 1 || customkill == 2);
						}
					}
					case Game_DOD:
					{
						headshot = false;
					}
				}

				// Head Hunter
				new skilllevelheadhunter=War3_GetSkillLevel(client,thisRaceID,SKILL_HEADHUNTER);
				if (skilllevelheadhunter &&!Hexed(client))
				{
					new bool:decap = false;
					if (g_GameType == Game_TF)
					{
						decl String:weapon[128];
						GetEventString(event, "weapon", weapon, sizeof(weapon));

						for (new i = 0; i < sizeof(tf2_decap_weapons); i++)
						{
							if (StrEqual(weapon,tf2_decap_weapons[i],false))
							{
								decap = ((GetEventInt(event, "damagebits") & DMG_CRITS) != 0);
								break;
							}
						}
					}
					else
					decap = false;

					if(!decap&&!headshot){
						decl String:weapon[128];
						GetEventString(event, "weapon", weapon, sizeof(weapon));
						if(StrEqual(weapon,"headhunter",false)){
							decap=true;
						}
					}

					///FORCE ALWAYS GET SKULL
					headshot=true;

					if (headshot || decap )
					{
						if (skulls[client]<(5*skilllevelheadhunter))
						{
							skulls[client]++;
							//War3_ChatMessage(client,"%T","You gained a SKULL [{amount}/{amount}]",client,skulls[client],(5*skilllevelheadhunter));
						}
						decl Float:Origin[3], Float:Direction[3];
						GetClientAbsOrigin(victim, Origin);
						Direction[0] = GetRandomFloat(-100.0, 100.0);
						Direction[1] = GetRandomFloat(-100.0, 100.0);
						Direction[2] = 300.0;
						Gib(Origin, Direction, "models/gibs/hgibs.mdl");
					}
				}
			}
		}
	}
}
*/
public PlayerJumpEvent(Handle:event,const String:name[],bool:dontBroadcast)
{
	if(RaceDisabled)
		return;

	new client=GetClientOfUserId(GetEventInt(event,"userid"));
	new race=War3_GetRace(client);
	if (race==thisRaceID)
	{

		new skill_SKILL_ASSAULT=War3_GetSkillLevel(client,race,SKILL_ASSAULT);

		if (skill_SKILL_ASSAULT){
			//assaultskip[client]--;
			//if(assaultskip[client]<1||
			if(War3_SkillNotInCooldown(client,thisRaceID,SKILL_ASSAULT)&&!Hexed(client))
			{
				//assaultskip[client]+=2;
				new Float:velocity[3]={0.0,0.0,0.0};
				velocity[0]= GetEntDataFloat(client,m_vecVelocity_0);
				velocity[0]*=float(skill_SKILL_ASSAULT)*0.25;
#if (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
				velocity[1]= GetEntDataFloat(client,m_vecVelocity_1);
				velocity[1]*=float(skill_SKILL_ASSAULT)*0.25;
#endif

				//new Float:len=GetVectorLength(velocity,false);
				//if(len>100.0){
				//	velocity[0]*=100.0/len;
				//	velocity[1]*=100.0/len;
				//}
				//PrintToChatAll("speed vector length %f cd %d",len,War3_SkillNotInCooldown(client,thisRaceID,SKILL_ASSAULT)?0:1);
				/*len=GetVectorLength(velocity,false);
				PrintToChatAll("speed vector length %f",len);
				*/
#if (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
				SetEntDataVector(client,m_vecBaseVelocity,velocity,true);
#endif
				War3_CooldownMGR(client,assaultcooldown,thisRaceID,SKILL_ASSAULT,_,_);

				new String:wpnstr[32];
				GetClientWeapon(client, wpnstr, 32);
				for(new slot=0;slot<10;slot++){

					new wpn=GetPlayerWeaponSlot(client, slot);
					if(wpn>0){
						//PrintToChatAll("wpn %d",wpn);
						new String:comparestr[32];
						GetEdictClassname(wpn, comparestr, 32);
						//PrintToChatAll("%s %s",wpn, comparestr);
						if(StrEqual(wpnstr,comparestr,false)){

							TE_SetupKillPlayerAttachments(wpn);
							War3_TE_SendToAll();

							new color[4]={0,25,255,200};
							if(GetClientTeam(client)==TEAM_T||GetClientTeam(client)==TEAM_RED){
								color[0]=255;
								color[2]=0;
							}
							TE_SetupBeamFollow(wpn,Laser,0,0.5,2.0,7.0,1,color);
							War3_TE_SendToAll();
							break;
						}
					}
				}
			}
		}
	}
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if(RaceDisabled)
		return Plugin_Continue;

	if(W3Paused()) return Plugin_Continue;

	if (buttons & IN_JUMP) //assault for non CS games
	{
		if (War3_GetRace(client) == thisRaceID)
		{
			new skill_SKILL_ASSAULT=War3_GetSkillLevel(client,thisRaceID,SKILL_ASSAULT);
			if (skill_SKILL_ASSAULT)
			{
				//assaultskip[client]--;
				//if(assaultskip[client]<1&&
				new bool:lastwasgroundtemp=lastframewasground[client];
				lastframewasground[client]=bool:(GetEntityFlags(client) & FL_ONGROUND);
				if(War3_SkillNotInCooldown(client,thisRaceID,SKILL_ASSAULT) &&  lastwasgroundtemp &&   !(GetEntityFlags(client) & FL_ONGROUND) &&!Hexed(client) )
				{
					//assaultskip[client]+=2;

#if GGAMETYPE == GGAME_TF2
					if (TF2_HasTheFlag(client))
						return Plugin_Continue;
#endif


					decl Float:velocity[3];
					GetEntDataVector(client, m_vecVelocity_0, velocity); //gets all 3

					/*if he is not in speed ult
					if (!(GetEntityFlags(client) & FL_ONGROUND))
					{
						new Float:absvel = velocity[0];
						if (absvel < 0.0)
							absvel *= -1.0;

						if (velocity[1] < 0.0)
							absvel -= velocity[1];
						else
							absvel += velocity[1];

						new Float:maxvel = m_IsULT_TRANSFORMformed[client] ? 1000.0 : 500.0;
						if (absvel > maxvel)
							return Plugin_Continue;
					}*/


					new Float:oldz=velocity[2];
					velocity[2]=0.0; //zero z
					new Float:len=GetVectorLength(velocity);
					if(len>3.0){
						new Float:amt = 1.2 + (float(skill_SKILL_ASSAULT)*0.20);
						velocity[0]*=amt;
						velocity[1]*=amt;
						//ScaleVector(velocity,700.0/len);
						velocity[2]=oldz;
						W3TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
						//SetEntDataVector(client,m_vecBaseVelocity,velocity,true); //CS
					}





					//new Float:amt = 1.0 + (float(skill_SKILL_ASSAULT)*0.2);
					//velocity[0]*=amt;
					//velocity[1]*=amt;
					//TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);

					War3_CooldownMGR(client,assaultcooldown,thisRaceID,SKILL_ASSAULT,_,_);
					//new color[4] = {255,127,0,255};

#if GGAMETYPE == GGAME_TF2
					if (!War3_IsCloaked(client))
					{
#endif
						new String:wpnstr[32];
						GetClientWeapon(client, wpnstr, 32);
						for(new slot=0;slot<10;slot++){

							new wpn=GetPlayerWeaponSlot(client, slot);
							if(wpn>0){
								//PrintToChatAll("wpn %d",wpn);
								new String:comparestr[32];
								GetEdictClassname(wpn, comparestr, 32);
								//PrintToChatAll("%s %s",wpn, comparestr);
								if(StrEqual(wpnstr,comparestr,false)){

									TE_SetupKillPlayerAttachments(wpn);
									War3_TE_SendToAll();

									new color[4]={0,25,255,200};
									if(GetClientTeam(client)==TEAM_T||GetClientTeam(client)==TEAM_RED){
										color[0]=255;
										color[2]=0;
									}
									TE_SetupBeamFollow(wpn,Laser,0,0.5,2.0,7.0,1,color);
									War3_TE_SendToAll();
									break;
								}
							}
						}
#if GGAMETYPE == GGAME_TF2
					}
#endif
				}
			}
		}
	}
	return Plugin_Continue;
}

public OnClientPutInServer(client)
{
	skulls[client] = 0;
	m_IsULT_TRANSFORMformed[client]=false;

	War3_SetBuff(client,fMaxSpeed,thisRaceID,1.0);
	//War3_SetBuff(client,fLowGravitySkill,thisRaceID,1.0);
}


public void OnUltimateCommand(int client, int race, bool pressed, bool bypass)
{
	if(ValidPlayer(client,true)&&pressed && race==thisRaceID)
	{
		new skill_trans=War3_GetSkillLevel(client,race,ULT_TRANSFORM);
		if (skill_trans>0)
		{
			if (War3_SkillNotInCooldown(client,thisRaceID,ULT_TRANSFORM,true)&&!Silenced(client))
			{

				if (skulls[client] < skill_trans)
				{
					new required = skill_trans - skulls[client];
					PrintToChat(client,"\0x04[Daemonic transformation] \0x01You do not have enough skulls: %i more required",required);
				}
				else
				{
					skulls[client]-=skill_trans;

					m_IsULT_TRANSFORMformed[client]=true;


					War3_SetBuff(client,fMaxSpeed,thisRaceID,float(skill_trans)/5.00+1.00);
					//War3_SetBuff(client,fLowGravitySkill,thisRaceID,1.00-float(skill_trans)/5.00);

					new old_health=GetClientHealth(client);
					SetEntityHealth(client,old_health+skill_trans*10);

					PrintToChat(client,"\0x04[Daemonic transformation] \0x01Your daemonic powers boost your strength");
					CreateTimer(10.0,Finishtrans,client);
					War3_CooldownMGR(client,GetConVarFloat(ultCooldownCvar),thisRaceID,ULT_TRANSFORM,_,_);
				}
			}
		}
		else{
			W3MsgUltNotLeveled(client);
		}
	}
}

public Action:Finishtrans(Handle:timer,any:client)
{

	if(m_IsULT_TRANSFORMformed[client]){
		War3_SetBuff(client,fMaxSpeed,thisRaceID,1.0);
		//War3_SetBuff(client,fLowGravitySkill,thisRaceID,1.0);
		if(ValidPlayer(client,true)){
			PrintToChat(client,"\0x04[Daemonic transformation] \0x01You transformed back to normal");
		}
	}
}













































































stock Gib(Float:Origin[3], Float:Direction[3], String:Model[])
{
	if (!IsMYEntLimitReached(.message="unable to create gibs"))
	{
		new Ent = CreateEntityByName("prop_physics");
		DispatchKeyValue(Ent, "model", Model);
		SetEntProp(Ent, Prop_Send, "m_CollisionGroup", 1);
		DispatchSpawn(Ent);
		TeleportEntity(Ent, Origin, Direction, Direction);
		CreateTimer(GetRandomFloat(15.0, 30.0), RemoveGib,EntIndexToEntRef(Ent));
	}
}

public Action:RemoveGib(Handle:Timer, any:Ref)
{
	new Ent = EntRefToEntIndex(Ref);
	if (Ent > 0 && IsValidEdict(Ent))
	{
		RemoveEdict(Ent);
	}
}



/**
* Detect when changing classes in TF2
*/




public Action:SayCommand(client, const String:command[], argc)
{
	if(RaceDisabled)
		return Plugin_Continue;

	if (client > 0 && IsClientInGame(client))
	{
		decl String:text[128];
		GetCmdArg(1,text,sizeof(text));

		decl String:arg[2][64];
		ExplodeString(text, " ", arg, 2, 64);

		new String:firstChar[] = " ";
		firstChar{0} = arg[0]{0};
		if (StrContains("!/\\",firstChar) >= 0)
			strcopy(arg[0], sizeof(arg[]), arg[0]{1});

		if (StrEqual(arg[0],"skulls",false))
		{
			new skilllevelheadhunter = (War3_GetRace(client)==thisRaceID) ? War3_GetSkillLevel(client,thisRaceID,SKILL_HEADHUNTER) : 0;
			if (skilllevelheadhunter)
				War3_ChatMessage(client,"You have (%i/%i) SKULLs",skulls[client],(5*skilllevelheadhunter));
			else
			War3_ChatMessage(client,"You have %i \0x04SKULL\0x01s",skulls[client]);

			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

/**
* Weapons related functions.
*/
#tryinclude <sc/weapons>
#if !defined _weapons_included
stock bool:GetWeapon(Handle:event, index,
String:buffer[], buffersize)
{
	new bool:is_equipment;

	buffer[0] = 0;
	GetEventString(event, "weapon", buffer, buffersize);

	if (buffer[0] == '\0' && index && IsPlayerAlive(index))
	{
		is_equipment = true;
		GetClientWeapon(index, buffer, buffersize);
	}
	else
	is_equipment = false;

	return is_equipment;
}

stock bool:IsEquipmentMelee(const String:weapon[])
{
		return (StrEqual(weapon,"tf_weapon_knife") ||
		StrEqual(weapon,"tf_weapon_shovel") ||
		StrEqual(weapon,"tf_weapon_wrench") ||
		StrEqual(weapon,"tf_weapon_bat") ||
		StrEqual(weapon,"tf_weapon_bat_wood") ||
		StrEqual(weapon,"tf_weapon_bonesaw") ||
		StrEqual(weapon,"tf_weapon_bottle") ||
		StrEqual(weapon,"tf_weapon_club") ||
		StrEqual(weapon,"tf_weapon_fireaxe") ||
		StrEqual(weapon,"tf_weapon_fists") ||
		StrEqual(weapon,"tf_weapon_sword"));
	return false;
}


stock bool:IsMelee(const String:weapon[], bool:is_equipment, index, victim, Float:range=100.0)
{
	if (is_equipment)
	{
		if (IsEquipmentMelee(weapon))
			return IsInRange(index,victim,range);
		else
		return false;
	}
	else
	return W3IsDamageFromMelee(weapon);
}
#endif

/**
* Range and Distance functions and variables
*/
#tryinclude <range>
#if !defined _range_included
stock Float:TargetRange(client,index)
{
	new Float:start[3];
	new Float:end[3];
	GetClientAbsOrigin(client,start);
	GetClientAbsOrigin(index,end);
	return GetVectorDistance(start,end);
}

stock bool:IsInRange(client,index,Float:maxdistance)
{
	return (TargetRange(client,index)<maxdistance);
}
#endif


/**
* Description: Function to check the entity limit.
*              Use before spawning an entity.
*/
#tryinclude <entlimit>
#if !defined _entlimit_included
stock IsMYEntLimitReached(warn=20,critical=16,client=0,const String:message[]="")
{
	new max = GetMaxEntities();
	new count = GetEntityCount();
	new remaining = max - count;
	if (remaining <= warn)
	{
		if (count <= critical)
		{
			PrintToServer("Warning: Entity limit is nearly reached! Please switch or reload the map!");
			LogError("Entity limit is nearly reached: %i/%i (%i):%s", count, max, remaining, message);   // could be integer?

			if (client > 0)
			{
				PrintToConsole(client,"Entity limit is nearly reached: %d/%d (%d):%s",
				count, max, remaining, message);
			}
		}
		else
		{
			PrintToServer("Caution: Entity count is getting high!");
			LogMessage("Entity count is getting high: %i/%i (%i):%s", count, max, remaining, message);

			if (client > 0)
			{
				PrintToConsole(client,"Entity count is getting high: %i/%i (%i):%s",
				count, max, remaining, message);
			}
		}
		return count;
	}
	else
	return 0;
}
#endif
