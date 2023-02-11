#include <war3source>
#assert GGAMEMODE == MODE_WAR3SOURCE
#assert GGAMETYPE_JAILBREAK == JAILBREAK_OFF

#define PLUGIN_VERSION "0.0.0.1 (1/30/2013) 4:40AM EST"
/* ============================================================================ */
/*										                                        */
/*   naix.sp									                                */
/*   (c) 2009 Stinkyfax								                            */
/*										                                        */
/*										                                        */
/* ============================================================================	*/

#define RACE_ID_NUMBER 120


public W3ONLY(){} //unload this?

// Colors
#define COLOR_DEFAULT 0x01
#define COLOR_LIGHTGREEN 0x03
//#define COLOR_GREEN 0x04 // DOD = Red //kinda already defiend in war3 interface

//Skills Settings

new Float:HPPercentHealPerKill[5] = { 0.0, 0.05,  0.10,  0.12,  0.15 }; //SKILL_INFEST settings
//Skill 1_1 really has 5 settings, so it's not a mistake
new HPIncrease[5]       = { 0, 10, 20, 25, 35 };     //Increases Maximum health

new Float:feastPercent[5] = { 0.0, 0.03,  0.05,  0.06,  0.08 };   //Feast ratio (leech based on current victim hp


new Float:RageAttackSpeed[5] = {1.0, 1.15,  1.25,  1.3334,  1.4001 };   //Rage Attack Rate
new Float:RageDuration[5] = {0.0, 2.0,  2.5,  3.0,  3.5 };   //Rage duration

new bool:bDucking[MAXPLAYERSCUSTOM];
//End of skill Settings

new Handle:ultCooldownCvar;

new thisRaceID, SKILL_INFEST, SKILL_BLOODBATH, SKILL_FEAST, ULT_RAGE;

new String:skill1snd[]="war3source/naix/predskill1.mp3";
new String:ultsnd[]="war3source/naix/predult.mp3";

public Plugin:myinfo =
{
	name = "Race - Lifestealer",
	author = "Stinkyfax and Ownz (DarkEnergy)",
	description = "N'aix - the embodiment of lust and greed,\nbent on stealing the life of every living creature he encounters.",
	version = "1.0",
	url = "war3source.com"//http://sugardas.lt/~jozh/
};

bool HooksLoaded = false;
public void Load_Hooks()
{
	if(HooksLoaded) return;
	HooksLoaded = true;

	//PrintToChatAll("Naxi W3Hook OnW3TakeDmgAllPre");
	//PrintToChatAll("Naxi W3Hook OnW3TakeDmgAll");
	W3Hook(W3Hook_OnW3TakeDmgAllPre, OnW3TakeDmgAllPre);
	W3Hook(W3Hook_OnW3TakeDmgAll, OnW3TakeDmgAll);
	W3Hook(W3Hook_OnUltimateCommand, OnUltimateCommand);
}
public void UnLoad_Hooks()
{
	if(!HooksLoaded) return;
	HooksLoaded = false;

	//PrintToChatAll("Naxi W3UnhookAll");
	//PrintToServer("Naxi W3UnhookAll");
	//PrintToServer("Naxi W3UnhookAll");
	//PrintToServer("Naxi W3UnhookAll");
	//PrintToServer("Naxi W3UnhookAll");
	//PrintToServer("Naxi W3UnhookAll");
	//PrintToServer("Naxi W3UnhookAll");
	W3UnhookAll(W3Hook_OnW3TakeDmgAllPre);
	W3UnhookAll(W3Hook_OnW3TakeDmgAll);
	W3UnhookAll(W3Hook_OnUltimateCommand);
}
public void OnMapStart()
{
	UnLoad_Hooks();
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


/**
 * heals with the limit of your specified HP
 * @noreturn
 */

bool:War3HealToHP(client, addhp, maximumHP) {
	if(addhp<=0) return false;
	if(maximumHP<=0) return false;

	new currenthp = GetClientHealth(client);

	if(currenthp<=0) return false;

	new newhp = currenthp + addhp;

	if (newhp > maximumHP)
	{
		newhp = maximumHP;
	}

	if (currenthp < newhp)
	{
		SetEntityHealth(client, newhp);
		War3_TFHealingEvent(client, newhp - currenthp);
		return true;
	}
	return false;
}

public OnPluginStart()
{
	CreateConVar("Naix",PLUGIN_VERSION,"War3Source:EVO Job Naix",FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);

	ultCooldownCvar=CreateConVar("war3_succ_ult_cooldown","20","Cooldown time for Rage.");

	//LoadTranslations("w3s.race.naix.phrases");
}
public OnAllPluginsLoaded()
{
	War3_RaceOnPluginStart("naix");
}
public OnPluginEnd()
{
	if(LibraryExists("RaceClass"))
		War3_RaceOnPluginEnd("naix");
}
public OnWar3LoadRaceOrItemOrdered2(num,reloadrace_id,String:shortname[])
{
	if(num==RACE_ID_NUMBER||(reloadrace_id>0&&StrEqual("naix",shortname,false)))
	{
		thisRaceID=War3_CreateNewRace("Naix - Lifestealer","naix",reloadrace_id,"Gain health from dmg");


		SKILL_INFEST = War3_AddRaceSkill(thisRaceID, "Infest","Regains 5-20% health upon killing an enemy.\nYou teleport to victim location if you are ducking\n(only once every 10 seconds(heavy only))\n(All Katanas do 25% damage)", false,4);
		SKILL_BLOODBATH = War3_AddRaceSkill(thisRaceID, "Blood Bath","Increases leechable health of the Naix by 10-40,\nmaking all his other skills worthy\n(All Katanas do 25% damage)",false,4);
		SKILL_FEAST = War3_AddRaceSkill(thisRaceID, "Feast","Regenerates 3-8% percent of enemy's current HP chance on hit.\n(All Katanas do 25% damage)",false,4);
		ULT_RAGE = War3_AddRaceSkill(thisRaceID, "Rage","Naix goes into a maddened Rage, gaining 15-40% attack speed for 2-5 seconds", true,4);

		War3_CreateRaceEnd(thisRaceID);
	}
}

public Action OnW3TakeDmgAllPre(int victim, int attacker, float damage)
{
	if(RaceDisabled)
		return;

	//PrintToChatAll("Naxi OnW3TakeDmgAllPre");

	if(ValidPlayer(victim,true)&&ValidPlayer(attacker)&&attacker!=victim&&War3_GetRace(attacker)==thisRaceID)
	{
		new vteam=GetClientTeam(victim);
		new ateam=GetClientTeam(attacker);
		if(vteam!=ateam)
		{
			new wpnent = W3GetCurrentWeaponEnt(attacker);
			if(wpnent>0&&IsValidEdict(wpnent)){
				decl String:WeaponName[32];
				GetEdictClassname(wpnent, WeaponName, 32);
				//if(W3IsDamageFromMelee(WeaponName)){
				if(StrEqual(WeaponName, "tf_weapon_katana")){

					//PrintToChatAll("[Debug] Naix Melee katana: %.2f",damage);
					War3_DamageModPercent(0.25);
				}
			}
		}
	}
}


public OnW3Denyable(W3DENY:event,client)
{
	if(RaceDisabled)
		return;

	if((event == DN_CanBuyItem1) && (W3GetVar(EventArg1) == War3_GetItemIdByShortname("gauntlet")))
	{
		if(War3_GetRace(client)==thisRaceID)
		{
			W3Deny();
			War3_ChatMessage(client, "{lightgreen}The gauntlet is too heavy ...");
		}
	}
	if((event == DN_CanBuyItem1) && (W3GetVar(EventArg1) == War3_GetItemIdByShortname("mask")))
	{
		if(War3_GetRace(client)==thisRaceID)
		{
			W3Deny();
			War3_ChatMessage(client, "{lightgreen}The mask would suffocate me!");
		}
	}
}

//public OnMapStart() { //some precaches
  //PrecacheSound("npc/zombie/zombie_pain2.wav");
	//War3_PrecacheSound(skill1snd);
	//War3_PrecacheSound(ultsnd);
//}

public OnAddSound(sound_priority)
{
	if(sound_priority==PRIORITY_LOW)
	{
		War3_AddSound(ultsnd);
	}
	if(sound_priority==PRIORITY_BOTTOM)
	{
		War3_AddSound(skill1snd);
	}
}

public Action OnW3TakeDmgAll(int victim,int attacker, float damage)
{
	if(RaceDisabled)
		return;

	//PrintToChatAll("Naxi OnW3TakeDmgAll");

	new amount=RoundToCeil(damage);
	//DP("W3ChanceModifier(attacker) %.2f",W3ChanceModifier(attacker));
	//DP("W3Chance(W3ChanceModifier(attacker)) %.2f",W3Chance(W3ChanceModifier(attacker)));
	//DP("W3ChanceModifier(victim) %.2f",W3ChanceModifier(victim));
	//DP("W3Chance(W3ChanceModifier(victim)) %.2f",W3Chance(W3ChanceModifier(victim)));
	if(ValidPlayer(victim)&&W3Chance(W3ChanceModifier(attacker))&&ValidPlayer(attacker)&&War3_GetRace(attacker)==thisRaceID  && victim!=attacker && GetClientTeam(victim)!=GetClientTeam(attacker)){
		new level = War3_GetSkillLevel(attacker, thisRaceID, SKILL_FEAST);
		if(level>0&&!Hexed(attacker,false)&&W3Chance(W3ChanceModifier(attacker))){
			if(!W3HasImmunity(victim,Immunity_Skills)){
				new CurrentTargetHP = GetClientHealth(victim);
				if(CurrentTargetHP<0) CurrentTargetHP=0;
				new targetHp = CurrentTargetHP+amount;
				if(targetHp>0)
				{
					new restore = RoundToNearest( float(targetHp) * feastPercent[level] );

					War3HealToHP(attacker,restore,War3_GetMaxHP(attacker)+HPIncrease[War3_GetSkillLevel(attacker,thisRaceID,SKILL_BLOODBATH)]);

					//PrintToConsole(attacker,"Feast + %i HP",restore);
					//War3_ChatMessage(attacker,"{default}You leeched [{green}+%d{default}] health!", restore);
					War3_NotifyPlayerLeechedFromSkill(victim, attacker, restore, SKILL_FEAST);
				}
			}
			else
			{
				War3_NotifyPlayerImmuneFromSkill(attacker, victim, SKILL_FEAST);
			}
		}
	}
}
//public void OnWar3EventSpawn (int client)
//{
	//if(IsOurRace(client)){
		//new level = War3_GetSkillLevel(client, thisRaceID, SKILL_BLOODBATH);
		//if(level>=0){ //zeroth level passive
			//War3_SetBuff(client,iAdditionalMaxHealth,thisRaceID,HPIncrease[level]);

			//War3_SetMaxHP(client, War3_GetMaxHP(client) + HPIncrease[level]);
			//War3_ChatMessage(client,"Your Maximum HP Increased by %i",HPIncrease[level]);
		//}
	//}
//}

public OnRaceChanged(client,oldrace,newrace)
{
	if(newrace==thisRaceID)
	{
		InitPassiveSkills(client);
	}
	else //if(oldrace==thisRaceID)
	{
		RemovePassiveSkills(client);
	}
}

public InitPassiveSkills(client)
{
	// Natural Armor Buff
	//War3_SetBuff(client,fArmorPhysical,thisRaceID,1.0);
	new level = War3_GetSkillLevel(client, thisRaceID, SKILL_BLOODBATH);
	War3_SetBuff(client,iAdditionalMaxHealth,thisRaceID,HPIncrease[level]);
}

public RemovePassiveSkills(client)
{
	//War3_SetBuff(client,fArmorPhysical,thisRaceID,0.0);
	War3_SetBuff(client,iAdditionalMaxHealth,thisRaceID,0);
}


public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if(RaceDisabled)
		return Plugin_Continue;

	bDucking[client]=(buttons & IN_DUCK)?true:false;
	return Plugin_Continue;
}
//new Float:teleportTo[66][3];
public OnWar3EventDeath(victim,attacker){
	if(RaceDisabled)
		return;

	if(victim!=attacker && ValidPlayer(victim)&&ValidPlayer(attacker)&&War3_GetRace(attacker)==thisRaceID && GetClientTeam(victim)!=GetClientTeam(attacker)){
		new iSkillLevel=War3_GetSkillLevel(attacker,thisRaceID,SKILL_INFEST);
		if (iSkillLevel>0)
		{

			if (Hexed(attacker,false))
			{
				//decl String:name[50];
				//GetClientName(victim, name, sizeof(name));
				PrintHintText(attacker,"Could not infest, you are hexed");
			}
			else if (W3HasImmunity(victim,Immunity_Skills))
			{
				//decl String:name[50];
				//GetClientName(victim, name, sizeof(name));
				//PrintHintText(attacker,"Could not infest, enemy immunity");
				War3_NotifyPlayerImmuneFromSkill(attacker, victim, SKILL_FEAST);
			}
			else{


				if(bDucking[attacker] && SkillAvailable(attacker,thisRaceID,SKILL_INFEST,true)){
					decl Float:location[3];
					GetClientAbsOrigin(victim,location);
					//.PrintToChatAll("%f %f %f",teleportTo[attacker][0],teleportTo[attacker][1],teleportTo[attacker][2]);
					War3_CachedPosition(victim,location);
					//PrintToChatAll("%f %f %f",teleportTo[attacker][0],teleportTo[attacker][1],teleportTo[attacker][2]);


					//CreateTimer(0.1,setlocation,attacker);

					//TeleportEntity(attacker, location, NULL_VECTOR, NULL_VECTOR);
					//new bool:success = !War3_IsInSpawn(victim,true,location) && Teleport(attacker,location);
					
					
					
					//new bool:success = !War3_IsInSpawn(victim) && Teleport(attacker,location);
					if(!War3_IsInSpawn(victim))
					{
						War3_TeleportEntity(attacker,location,NULL_VECTOR,NULL_VECTOR);

#if GGAMETYPE == GGAME_TF2
						if(TF2_GetPlayerClass(attacker)==TFClass_Heavy)
						{
							War3_CooldownMGR(attacker,10.0,thisRaceID,SKILL_INFEST,true,true);
						}
#endif
					}
					//War3_CooldownMGR(attacker,10.0,thisRaceID,SKILL_INFEST,true,true);
				}

				new addHealth = RoundFloat(FloatMul(float(War3_GetMaxHP(victim)),HPPercentHealPerKill[iSkillLevel]));

				War3HealToHP(attacker,addHealth,War3_GetMaxHP(attacker)+HPIncrease[War3_GetSkillLevel(attacker,thisRaceID,SKILL_BLOODBATH)]);
				//War3_ChatMessage(attacker,"{default}You leeched [{green}+%d{default}] health!", addHealth);
				War3_NotifyPlayerLeechedFromSkill(victim, attacker, addHealth, SKILL_INFEST);

				//Effects?
				//War3_EmitAmbientSound("npc/zombie/zombie_pain2.wav",location);
				War3_EmitSoundToAll(skill1snd,attacker);
			}
		}
	}
}
/*
public Action:setlocation(Handle:t,any:attacker){
	TeleportEntity(attacker, teleportTo[attacker], NULL_VECTOR, NULL_VECTOR);
}*/

public void OnUltimateCommand(int client, int race, bool pressed, bool bypass)
{
	if(RaceDisabled)
		return;

	if(race==thisRaceID && pressed && ValidPlayer(client,true))
	{
		new ultLevel=War3_GetSkillLevel(client,thisRaceID,ULT_RAGE);
		if(ultLevel>0)
		{
			//PrintToChatAll("level %d %f %f",ultLevel,RageDuration[ultLevel],RageAttackSpeed[ultLevel]);
			if(!Silenced(client)&&War3_SkillNotInCooldown(client,thisRaceID,ULT_RAGE,true ))
			{
				War3_ChatMessage(client,"{green}[Rage Started]{default} You rage for {lightgreen}%.2f{default} seconds, {lightgreen}%.2f{default} percent attack speed",
				RageDuration[ultLevel],
				(RageAttackSpeed[ultLevel]-1.0)*100.0);

				War3_SetBuff(client,fAttackSpeed,thisRaceID,RageAttackSpeed[ultLevel]);

				CreateTimer(RageDuration[ultLevel],stopRage,client);
				War3_EmitSoundToAll(ultsnd,client);
				War3_EmitSoundToAll(ultsnd,client);
				War3_CooldownMGR(client,GetConVarFloat(ultCooldownCvar),thisRaceID,ULT_RAGE,_,_);

			}


		}
		else
		{
			PrintHintText(client,"No Ultimate Leveled");
		}
	}
}
public Action:stopRage(Handle:t,any:client){
	War3_SetBuff(client,fAttackSpeed,thisRaceID,1.0);
	if(ValidPlayer(client,true)){
		PrintHintText(client,"You are no longer in rage mode");
		War3_ChatMessage(client,"{green}[Rage Ended]{default} Attack speed back to normal.");
	}
}

