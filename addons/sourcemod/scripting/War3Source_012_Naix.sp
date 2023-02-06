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

new ClientTracer;
new Float:emptypos[3];
new Float:oldpos[MAXPLAYERSCUSTOM][3];
new Float:teleportpos[MAXPLAYERSCUSTOM][3];
new bool:inteleportcheck[MAXPLAYERSCUSTOM];


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

	ultCooldownCvar=CreateConVar("war3_naix_ult_cooldown","20","Cooldown time for Rage.");

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
						//native W3Teleport(client,target=-1,Float:ScaleVectorDistance=-1.0,Float:distance=1200.0,raceid=-1,skillid=-1);
		fdsfdsf				W3Teleport(client,_,location,NULL_VECTOR,NULL_VECTOR);

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

//Teleportation


//bool:Teleport(client,Float:distance){
bool:Teleport(client,Float:endpos[3]){
	if(!inteleportcheck[client])
	{
		inteleportcheck[client]=false;
		new Float:angle[3];
		GetClientEyeAngles(client,angle);
		//new Float:endpos[3];
		new Float:startpos[3];
		GetClientEyePosition(client,startpos);
		//new Float:dir[3];
		//GetAngleVectors(angle, dir, NULL_VECTOR, NULL_VECTOR);

		//ScaleVector(dir, distance);

		//AddVectors(startpos, dir, endpos);

		GetClientAbsOrigin(client,oldpos[client]);


		ClientTracer=client;
		//TR_TraceRayFilter(startpos,endpos,MASK_ALL,RayType_EndPoint,AimTargetFilter);
		//TR_GetEndPosition(endpos);
/*
		if(enemyImmunityInRange(client,endpos)){
			W3MsgEnemyHasImmunity(client);
			return false;
		}
*/
		//new Float:distanceteleport=GetVectorDistance(startpos,endpos);
		//if(distanceteleport<200.0){
			//new String:buffer[100];
			//Format(buffer, sizeof(buffer), "%T", "Distance too short.", client);
			//PrintHintText(client,buffer);
		//	return false;
		//}
		//GetAngleVectors(angle, dir, NULL_VECTOR, NULL_VECTOR);///get dir again
		//ScaleVector(dir, distanceteleport-33.0);

		//AddVectors(startpos,dir,endpos);


	/*
		emptypos[0]=0.0;
		emptypos[1]=0.0;
		emptypos[2]=0.0;

		endpos[2]-=30.0;
		getEmptyLocationHull(client,endpos);

		if(GetVectorLength(emptypos)<1.0){
			new String:buffer[100];
			Format(buffer, sizeof(buffer), "No empty location found");
			PrintHintText(client,buffer);
			return false; //it returned 0 0 0
		}*/

		//TeleportEntity(client,emptypos,NULL_VECTOR,NULL_VECTOR);
		TeleportEntity(client,endpos,NULL_VECTOR,NULL_VECTOR);
		//TeleportEntity(client,endpos,NULL_VECTOR,NULL_VECTOR);
		//War3_EmitSoundToAll(teleportSound,client);
		//War3_EmitSoundToAll(teleportSound,client);

		teleportpos[client][0]=emptypos[0];
		teleportpos[client][1]=emptypos[1];
		teleportpos[client][2]=emptypos[2];

		inteleportcheck[client]=true;
		CreateTimer(0.14,checkTeleport,client);

		return true;
	}

	return false;
}
public Action:checkTeleport(Handle:h,any:client){
	inteleportcheck[client]=false;
	new Float:pos[3];

	GetClientAbsOrigin(client,pos);

	if(GetVectorDistance(teleportpos[client],pos)<0.001)//he didnt move in this 0.1 second
	{
		TeleportEntity(client,oldpos[client],NULL_VECTOR,NULL_VECTOR);
		PrintHintText(client,"Can't Teleport Here");
		//War3_CooldownReset(client,TPFailCDResetToRace[client],TPFailCDResetToSkill[client]);
	}
	else{
		PrintHintText(client,"Teleported");
	}
}

public bool:AimTargetFilter(entity,mask)
{
	return !(entity==ClientTracer);
}


new absincarray[]={0,4,-4,8,-8,12,-12,18,-18,22,-22,25,-25};//,27,-27,30,-30,33,-33,40,-40}; //for human it needs to be smaller

public bool:getEmptyLocationHull(client,Float:originalpos[3]){


	new Float:mins[3];
	new Float:maxs[3];
	GetClientMins(client,mins);
	GetClientMaxs(client,maxs);

	new absincarraysize=sizeof(absincarray);

	new limit=5000;
	for(new x=0;x<absincarraysize;x++){
		if(limit>0){
			for(new y=0;y<=x;y++){
				if(limit>0){
					for(new z=0;z<=y;z++){
						new Float:pos[3]={0.0,0.0,0.0};
						AddVectors(pos,originalpos,pos);
						pos[0]+=float(absincarray[x]);
						pos[1]+=float(absincarray[y]);
						pos[2]+=float(absincarray[z]);

						TR_TraceHullFilter(pos,pos,mins,maxs,MASK_SOLID,CanHitThis,client);
						//new ent;
						if(!TR_DidHit(_))
						{
							AddVectors(emptypos,pos,emptypos); ///set this gloval variable
							limit=-1;
							break;
						}

						if(limit--<0){
							break;
						}
					}

					if(limit--<0){
						break;
					}
				}
			}

			if(limit--<0){
				break;
			}

		}

	}

}

public bool:CanHitThis(entityhit, mask, any:data)
{
	if(entityhit == data )
	{// Check if the TraceRay hit the itself.
		return false; // Don't allow self to be hit, skip this result
	}
	if(ValidPlayer(entityhit)&&ValidPlayer(data)&&GetClientTeam(entityhit)==GetClientTeam(data)){
		return false; //skip result, prend this space is not taken cuz they on same team
	}
	return true; // It didn't hit itself
}

/*
public bool:enemyImmunityInRange(client,Float:playerVec[3])
{
	//ELIMINATE ULTIMATE IF THERE IS IMMUNITY AROUND
	new Float:otherVec[3];
	new team = GetClientTeam(client);

	for(new i=1;i<=MaxClients;i++)
	{
		if(ValidPlayer(i,true)&&GetClientTeam(i)!=team&&W3HasImmunity(i,Immunity_Ultimates))
		{
			GetClientAbsOrigin(i,otherVec);
			if(GetVectorDistance(playerVec,otherVec)<350)
			{
				return true;
			}
		}
	}
	return false;
}
*/

