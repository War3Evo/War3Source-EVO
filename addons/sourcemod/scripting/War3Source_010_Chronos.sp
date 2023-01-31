#include <war3source>
#assert GGAMEMODE == MODE_WAR3SOURCE
#assert GGAMETYPE_JAILBREAK == JAILBREAK_OFF

#define RACE_ID_NUMBER 10

/**
* File: War3Source_NightElf.sp
* Description: The Night Elf race for War3Source.
* Author(s): Anthony Iacono
*/

//#pragma semicolon 1

//#include <sourcemod>
//#include "W3SIncs/War3Source_Interface"
//see u only include this file
//#include <sdktools>

public W3ONLY(){} //unload this?

new thisRaceID;

new m_vecVelocity_0, m_vecVelocity_1, m_vecBaseVelocity; //offsets

new bool:bTrapped[MAXPLAYERSCUSTOM];

new SKILL_LEAP, SKILL_REWIND, SKILL_TIMELOCK, ULT_SPHERE; //,ABILITY_SKILL_ENTRANCE,ABILITY_SKILL_EXIT;
////we add stuff later

//new RemovePortals = false;
//new bool:PlayerImmune[MAXPLAYERSCUSTOM];
//new Float:SavedLocationPos[MAXPLAYERSCUSTOM][3];
//new Float:SavedLocationAng[MAXPLAYERSCUSTOM][3];
//new max_exits_per_map[MAXPLAYERSCUSTOM];

//new Float:ManaEntrance[5]={120.0,60.0,50.0,40.0,30.0};
//new Float:ManaExit[5]={120.0,16.0,14.0,12.0,10.0};


//leap
new Float:leapPower[5]={0.0,350.0,400.0,450.0,500.0};
new Float:leapPowerTF[5]={0.0,500.0,550.0,600.0,650.0};

//rewind
new Float:RewindChance[5]={0.0,0.1,0.15,0.2,0.25};
new RewindHPAmount[MAXPLAYERSCUSTOM];

//bash
new Float:TimeLockChance[5]={0.0,0.1,0.15,0.2,0.25};

//sphere
new Float:ultRange=200.0;
new Handle:ultCooldownCvar;
new Float:SphereTime[5]={0.0,3.0,3.5,4.0,4.5};

new String:leapsnd[256]; //="war3source/chronos/timeleap.mp3";
new String:spheresnd[256]; //="war3source/chronos/sphere.mp3";

new Float:sphereRadius=150.0;

new bool:hasSphere[MAXPLAYERSCUSTOM]={false,...};
new Float:SphereLocation[MAXPLAYERSCUSTOM][3];
new Float:SphereEndTime[MAXPLAYERSCUSTOM];


new BeamSprite;
new HaloSprite;


stock oldbuttons[MAXPLAYERSCUSTOM];
new bool:lastframewasground[MAXPLAYERSCUSTOM];
public Plugin:myinfo =
{
	name = "Race - Chronos",
	author = "Ownz (DarkEnergy)",
	description = "Chronos",
	version = "1.0.0.0",
	url = "www.ownageclan.com"
};

bool HooksLoaded = false;
public void Load_Hooks()
{
	if(HooksLoaded) return;
	HooksLoaded = true;

	//PrintToChatAll("HooksLoaded = true");

	W3Hook(W3Hook_OnW3TakeDmgAllPre, OnW3TakeDmgAllPre);
#if GGAMETYPE == GGAME_TF2
	W3Hook(W3Hook_OnW3TakeDmgBulletPre, OnW3TakeDmgBulletPre);
#endif
	W3Hook(W3Hook_OnW3TakeDmgBullet, OnW3TakeDmgBullet);
	W3Hook(W3Hook_OnUltimateCommand, OnUltimateCommand);
}
public void UnLoad_Hooks()
{
	if(!HooksLoaded) return;
	HooksLoaded = false;

	//PrintToChatAll("HooksLoaded = false");

	W3UnhookAll(W3Hook_OnW3TakeDmgAllPre);
#if GGAMETYPE == GGAME_TF2
	W3UnhookAll(W3Hook_OnW3TakeDmgBulletPre);
#endif
	W3UnhookAll(W3Hook_OnW3TakeDmgBullet);
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


public OnPluginStart()
{
	ultCooldownCvar=CreateConVar("war3_chronos_ult_cooldown","20");

	//m_vecVelocity_0 = FindSendPropOffs("CBasePlayer","m_vecVelocity[0]");
	//m_vecVelocity_1 = FindSendPropOffs("CBasePlayer","m_vecVelocity[1]");
	//m_vecBaseVelocity = FindSendPropOffs("CBasePlayer","m_vecBaseVelocity");
	m_vecVelocity_0 = FindSendPropInfo("CBasePlayer","m_vecVelocity[0]");
	m_vecVelocity_1 = FindSendPropInfo("CBasePlayer","m_vecVelocity[1]");
	m_vecBaseVelocity = FindSendPropInfo("CBasePlayer","m_vecBaseVelocity");

	//HookEvent("teamplay_round_win", HookRoundEnd, EventHookMode_Post);
	//HookEvent("teamplay_waiting_ends", HookRoundEnd, EventHookMode_Post);

	//RegConsoleCmd("bashme",Cmdbashme);
	//LoadTranslations("w3s.race.chronos.phrases");
}
public OnAllPluginsLoaded()
{
	War3_RaceOnPluginStart("chronos");
	CreateTimer(0.1,sphereLoop,INVALID_HANDLE, TIMER_REPEAT);
}

//public HookRoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
//{
//	for(new x=0;x<MAXPLAYERSCUSTOM;x++)
//	{
//		max_exits_per_map[x]=0;
//	}
//	RemovePortals = true;
//	CreateTimer(1.0, RemoveAllDisable, _);
//}

//public Action:RemoveAllDisable(Handle:timer, any:client)
//{
	//PrintToChatAll("All Portals has been removed!");
//	RemovePortals = false;
//}

public OnPluginEnd()
{
	if(LibraryExists("RaceClass"))
		War3_RaceOnPluginEnd("chronos");
}

/*
public Action:Cmdbashme(client,args){
	static bool:foo=false;
	War3_SetBuff(client,bStunned,thisRaceID,foo);
	foo=(!foo);
}
*/
new glowsprite;
public OnMapStart()
{
	UnLoad_Hooks();

	//strcopy(leapsnd,sizeof(leapsnd),"war3source/chronos/timeleap.mp3");
	//strcopy(spheresnd,sizeof(spheresnd),"war3source/chronos/sphere.mp3");

	//War3_PrecacheSound(leapsnd);
	//War3_PrecacheSound(spheresnd);
	glowsprite=PrecacheModel("sprites/strider_blackball.spr");

	BeamSprite=War3_PrecacheBeamSprite();
	HaloSprite=War3_PrecacheHaloSprite();

	PrecacheModel("models/props_halloween/bombonomicon.mdl", true);
}

public OnAddSound(sound_priority)
{
	if(sound_priority==PRIORITY_MEDIUM)
	{
		strcopy(leapsnd,sizeof(leapsnd),"war3source/chronos/timeleap.mp3");
		strcopy(spheresnd,sizeof(spheresnd),"war3source/chronos/sphere.mp3");

		War3_AddSound(leapsnd);
		War3_AddSound(spheresnd);
	}
}

public OnWar3LoadRaceOrItemOrdered2(num,reloadrace_id,String:shortname[])
{
	if(num==RACE_ID_NUMBER||(reloadrace_id>0&&StrEqual("chronos",shortname,false)))
	{
		thisRaceID=War3_CreateNewRace("Chronos","chronos",reloadrace_id,"Chronosphere traps victims");
		SKILL_LEAP=War3_AddRaceSkill(thisRaceID,"Time Leap","Leap in the direction you are moving (auto on jump)",false,4);
		SKILL_REWIND=War3_AddRaceSkill(thisRaceID,"Rewind","Chance to regain the damage you took",false,4);
		SKILL_TIMELOCK=War3_AddRaceSkill(thisRaceID,"Time Lock","Chance to stun your enemy",false,4);
		ULT_SPHERE=War3_AddRaceSkill(thisRaceID,"Chronosphere","Rip space and time to trap enemy.\nTrapped victims cannot move and can only deal/receive melee damage,\nSphere protects chornos from outside damage.\nIt lasts 3/3.5/4/4.5 seconds",true,4);
		//ABILITY_SKILL_ENTRANCE=War3_AddRaceSkill(thisRaceID,"Portal Entrance","(+ability) Sets entrance point. (60/50/40/30 second cooldown)\nGoes to random exit point set by any Chronos.",false,4);
		//ABILITY_SKILL_EXIT=War3_AddRaceSkill(thisRaceID,"Portal Exit","(+ability2) Sets exit point.\n(16/14/12/10 second cooldown)\nMax 10 exits per round.\nRound end resets portal exits.",false,4);
		War3_CreateRaceEnd(thisRaceID);
		//War3_SetDependency(thisRaceID, ABILITY_SKILL_ENTRANCE, ULT_SPHERE, 1);
		//War3_SetDependency(thisRaceID, ABILITY_SKILL_EXIT, ABILITY_SKILL_ENTRANCE, 1);
	}
}

public OnW3Denyable(W3DENY:event,client)
{
	if(RaceDisabled)
		return;

	if((event == DN_CanBuyItem1) &&
	(W3GetVar(EventArg1) == War3_GetItemIdByShortname("ring")
	|| W3GetVar(EventArg1) == War3_GetItemIdByShortname("mask")
	|| W3GetVar(EventArg1) == War3_GetItemIdByShortname("gauntlet")
	))
	{
		if(War3_GetRace(client)==thisRaceID)
		{
			W3Deny();
			War3_ChatMessage(client, "I'm too powerful to own these items!");
		}
	}
}

public PlayerJumpEvent(Handle:event,const String:name[],bool:dontBroadcast)
{
	if(RaceDisabled)
		return;

	new client=GetClientOfUserId(GetEventInt(event,"userid"));

	if(ValidPlayer(client,true)){
		new race=War3_GetRace(client);
		if (race==thisRaceID)
		{

			new sl=War3_GetSkillLevel(client,race,SKILL_LEAP);

			if(!Hexed(client)&&sl>0&&SkillAvailable(client,thisRaceID,SKILL_LEAP,false))
			{

				new Float:velocity[3]={0.0,0.0,0.0};
				velocity[0]= GetEntDataFloat(client,m_vecVelocity_0);
				velocity[1]= GetEntDataFloat(client,m_vecVelocity_1);
				new Float:len=GetVectorLength(velocity);
				if(len>3.0){
					//PrintToChatAll("pre  vec %f %f %f",velocity[0],velocity[1],velocity[2]);
					ScaleVector(velocity,leapPower[sl]/len);

					//PrintToChatAll("post vec %f %f %f",velocity[0],velocity[1],velocity[2]);
					SetEntDataVector(client,m_vecBaseVelocity,velocity,true);
					War3_EmitSoundToAll(leapsnd,client);
					War3_EmitSoundToAll(leapsnd,client);
					War3_CooldownMGR(client,10.0,thisRaceID,SKILL_LEAP,_,_);
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
			new skill_SKILL_ASSAULT=War3_GetSkillLevel(client,thisRaceID,SKILL_LEAP);
			if (skill_SKILL_ASSAULT)
			{
				//assaultskip[client]--;
				//if(assaultskip[client]<1&&
				new bool:lastwasgroundtemp=lastframewasground[client];
				lastframewasground[client]=bool:(GetEntityFlags(client) & FL_ONGROUND);
				if(!Hexed(client)&&War3_SkillNotInCooldown(client,thisRaceID,SKILL_LEAP) &&  lastwasgroundtemp &&   !(GetEntityFlags(client) & FL_ONGROUND) )
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
					//	new Float:amt = 1.2 + (float(skill_SKILL_ASSAULT)*0.20);
						//velocity[0]*=amt;
					//	velocity[1]*=amt;
						ScaleVector(velocity,leapPowerTF[skill_SKILL_ASSAULT]/len);
						velocity[2]=oldz;
						TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
						//SetEntDataVector(client,m_vecBaseVelocity,velocity,true); //CS
					}


					War3_EmitSoundToAll(leapsnd,client);
					War3_EmitSoundToAll(leapsnd,client);


					//new Float:amt = 1.0 + (float(skill_SKILL_ASSAULT)*0.2);
					//velocity[0]*=amt;
					//velocity[1]*=amt;
					//TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);

					War3_CooldownMGR(client,10.0,thisRaceID,SKILL_LEAP,_,_);
					//new color[4] = {255,127,0,255};

				}
			}
		}
	}
	return Plugin_Continue;
}

public void OnUltimateCommand(int client, int race, bool pressed, bool bypass)
{
	if(RaceDisabled)
		return;

	if(race==thisRaceID && IsPlayerAlive(client) && pressed)
	{
		new skill_level=War3_GetSkillLevel(client,race,ULT_SPHERE);
		if(skill_level>0)
		{

			if(!Silenced(client)&&War3_SkillNotInCooldown(client,thisRaceID,ULT_SPHERE,true)){

				new Float:endpos[3];
				War3_GetAimTraceMaxLen(client,endpos,ultRange);

				new Float:down[3];
				down[0]=endpos[0];
				down[1]=endpos[1];
				down[2]=endpos[2]-200;
				TR_TraceRay(endpos,down,MASK_ALL,RayType_EndPoint);
				TR_GetEndPosition(endpos);

				War3_EmitSoundToAll(spheresnd,0,_,_,_,_,_,_,endpos);
				War3_EmitSoundToAll(spheresnd,0,_,_,_,_,_,_,endpos);
				War3_EmitSoundToAll(spheresnd,0,_,_,_,_,_,_,endpos);

				new Float:life=SphereTime[skill_level];

				for(new i=0;i<3;i++)
					SphereLocation[client][i]=endpos[i];

				SphereEndTime[client]=GetGameTime()+life;
				hasSphere[client]=true;
				//CreateTimer(0.1,sphereLoop,client);

				//new Float:angles[10]={
				//TE_SetupBeamRingPoint(effect_vec,45.0,44.0,BeamSprite,HaloSprite,0,15,entangle_time,5.0,0.0,{0,255,0,255},10,0);

				new Float:tempdiameter;
				for(new i=-1;i<=8;i++){
					new Float:rad=float(i*10)/360.0*(3.14159265*2);
					tempdiameter=sphereRadius*Cosine(rad)*2;
					new Float:heightoffset=sphereRadius*Sine(rad);

					//PrintToChatAll("degree %d rad %f sin %f cos %f radius %f offset %f",i*10,rad,Sine(rad),Cosine(rad),radius,heightoffset);

					new Float:origin[3];
					origin[0]=endpos[0];
					origin[1]=endpos[1];
					origin[2]=endpos[2]+heightoffset;
					TE_SetupBeamRingPoint(origin, tempdiameter-0.1, tempdiameter, BeamSprite, HaloSprite, 0, 0, life, 2.0, 0.0, {80,200,255,122}, 10, 0);
					War3_TE_SendToAll();
				}




				//sphereLoop(INVALID_HANDLE,client);

				CreateTimer(life,sphereend,client);

				TE_SetupGlowSprite(endpos,glowsprite,life,3.57,255);
				War3_TE_SendToAll();
				War3_CooldownMGR(client,GetConVarFloat(ultCooldownCvar),thisRaceID,ULT_SPHERE,_,_);
			}
		}
		else
		{
			W3MsgUltNotLeveled(client);
		}
	}
}
public Action:sphereLoop(Handle:h,any:data)
{
	for(new client=0;client<=MaxClients;client++)
	{
		if(hasSphere[client]&&SphereEndTime[client]>GetGameTime())
		{
			new Float:victimpos[3];
			new team=GetClientTeam(client);
			float velocity[3];
			velocity[0]=0.0;
			velocity[1]=0.0;
			velocity[2]=0.0;
			for(new i=1;i<=MaxClients;i++)
			{
				if(ValidPlayer(i,true)&&(GetClientTeam(i)!=team&&!bTrapped[i]))
				{
					if(!War3_IsNewPlayer(i)){
						GetClientEyePosition(i,victimpos);
						if(GetVectorDistance(SphereLocation[client],victimpos)<sphereRadius+40)
						{
							if(!W3HasImmunity(i,Immunity_Ultimates))
							{
								// if not on ground, stop velocity!
								if (!(GetEntityFlags(i) & FL_ONGROUND) )
								{
									TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, velocity);
								}
								CreateTimer(SphereEndTime[client]-GetGameTime(),unBashUlt,i);
								War3_SetBuff(i,bBashed,thisRaceID,true,client);

								//War3_SetBuff(i,fAttackSpeed,thisRaceID,0.33);

								War3_SetBuff(i,bImmunitySkills,thisRaceID,false);
								War3_SetBuff(i,bImmunityUltimates,thisRaceID,false);
								bTrapped[i]=true;
								PrintHintText(i,"You have been trapped by a Chronosphere! You can only receive Melee damage");

								//War3_EmitSoundToClient(i,spheresnd);
							}
							else
							{
								War3_NotifyPlayerImmuneFromSkill(client, i, ULT_SPHERE);
							}
						}
					}
					//else
					//{
						//W3MsgNewbieProjectBlocked(i,"Chronosphere",
						//"You would have been stuck in Chronosphere and only be able to melee damage,\nbut because you are new you are immune",
						//"When your newbie protection wears out,\nyou will need to type lace in chat in order to be immune.");
					//}
				}
			}
		}
	}
	//CreateTimer(0.1,sphereLoop,client);
}




public Action:unBashUlt(Handle:h,any:client){
	War3_SetBuff(client,bBashed,thisRaceID,false);
	//War3_SetBuff(client,fAttackSpeed,thisRaceID,1.0);
	bTrapped[client]=false;
	War3_SetBuff(client,bImmunitySkills,thisRaceID,false);
	War3_SetBuff(client,bImmunityUltimates,thisRaceID,false);
	return Plugin_Stop;
}
public Action:sphereend(Handle:h,any:client){
	hasSphere[client]=false;
	return Plugin_Stop;
}

public Action OnW3TakeDmgAllPre(int victim, int attacker, float damage)
{
	if(RaceDisabled)
		return;

	if(bTrapped[victim]){ ///trapped people can only be damaged with knife
		if(ValidPlayer(attacker,true)){
			new wpnent = W3GetCurrentWeaponEnt(attacker);
			if(wpnent>0&&IsValidEdict(wpnent)){
				decl String:WeaponName[32];
				GetEdictClassname(wpnent, WeaponName, 32);
				if(StrContains(WeaponName,"weapon_knife",false)<0&&!W3IsDamageFromMelee(WeaponName)){

					//PrintToChatAll("block");
					War3_DamageModPercent(0.0);
				}
			}
			else{
				//PrintToChatAll("chronosblock no wpn detected");
				War3_DamageModPercent(0.0);
			}
		}
		else{
			//PrintToChatAll("chronosblock no valid attacker");
			//War3_DamageModPercent(0.0);
			//some damage burn here? allow
		}
	}

	if(ValidPlayer(attacker,true) && bTrapped[attacker]){ //if the attacker is inside the sphere...
		new wpnent2 = W3GetCurrentWeaponEnt(attacker);
		if(wpnent2>0&&IsValidEdict(wpnent2)){
				decl String:WeaponName2[32];
				GetEdictClassname(wpnent2, WeaponName2, 32);
				if(StrContains(WeaponName2,"weapon_knife",false)<0&&!W3IsDamageFromMelee(WeaponName2)){ //and the attacker isn't dealing melee damage...

					//PrintToChatAll("block");
					PrintToServer("attacker in sphere tried to deal ranged damage!");
					War3_DamageModPercent(0.0); //then no damage for the attacker.
				}
		}

	}
//	if(ValidPlayer(attacker)&&bTrapped[attacker]){ //trapped people can only use knife
//	}
	if(ValidPlayer(attacker,true)&&IsInOwnSphere(victim)&&!bTrapped[attacker]){ //cant shoot to inside the sphere
		if(!W3HasImmunity(attacker,Immunity_Ultimates))
		{
			War3_DamageModPercent(0.0);
		}
		else
		{
			War3_NotifyPlayerImmuneFromSkill(victim, attacker, ULT_SPHERE);
		}
	}
	if(ValidPlayer(attacker,true)&&IsInOwnSphere(attacker)&&!bTrapped[victim]){	//cant shoot outside of your sphere
		War3_DamageModPercent(0.0);
	}
	//OnW3TakeDmgAllPre_func(victim,attacker,Float:damage);

}
IsInOwnSphere(client){
	if(hasSphere[client]){
		new Float:pos[3];
		GetClientEyePosition(client,pos);
		if(GetVectorDistance(SphereLocation[client],pos)<sphereRadius+10.0){ //chronos is in his sphere
			return true;
		}
	}
	return false;
}
//public OnWar3EventPostHurt(victim,attacker,dmgamount)
public Action OnW3TakeDmgBullet(int victim, int attacker, float damage)
{
	if(RaceDisabled)
		return;

	new dmgamount=RoundToFloor(damage);
	//PrintToChatAll("Damage: %i",dmgamount);
	//PrintToChatAll("Post Damage Triggered!");
	//PrintToChatAll("Post Damage Triggered!");
#if GGAMETYPE == GGAME_TF2
	if(ValidPlayer(victim,true)&&ValidPlayer(attacker,true) && !W3IsOwnerSentry(attacker))
#else
	if(ValidPlayer(victim,true)&&ValidPlayer(attacker,true))
#endif
	{

		new skilllevel=War3_GetSkillLevel(victim,thisRaceID,SKILL_REWIND);
		//we do a chance roll here, and if its less than our limit (RewindChance) we proceede i a with u
		// allow self damage rewind
		if(victim!=attacker && GetClientTeam(victim)!=GetClientTeam(attacker) && War3_GetRace(victim)==thisRaceID && skilllevel>0&& War3_Chance(RewindChance[skilllevel]) && !Hexed(victim)) //chance roll, and attacker isnt immune to skills
		{
			if(!W3HasImmunity(attacker,Immunity_Skills))
			{
#if GGAMETYPE == GGAME_TF2
				if(TF2_IsPlayerInCondition(victim,TFCond_DeadRingered))
				{
					new Float:mathx=float(dmgamount)*0.10;
					dmgamount=RoundToNearest(mathx);
				}
#endif
				PrintToConsole(victim,"Rewind +%i HP!",dmgamount);
				RewindHPAmount[victim]+=dmgamount;//we create this variable
				PrintHintText(victim,"Rewind +%i HP!",dmgamount);
				W3FlashScreen(victim,RGBA_COLOR_GREEN);
			}
			else
			{
				War3_NotifyPlayerImmuneFromSkill(victim, attacker, SKILL_REWIND);
			}
		}


		new race_attacker=War3_GetRace(attacker);
		skilllevel=War3_GetSkillLevel(attacker,thisRaceID,SKILL_TIMELOCK);
		if(race_attacker==thisRaceID && skilllevel > 0 && victim!=attacker)
		{
			if(War3_SkillNotInCooldown(attacker, thisRaceID, SKILL_TIMELOCK, false) && War3_Chance(TimeLockChance[skilllevel]) && !Stunned(victim)&&!Hexed(attacker))
			{
				if(!W3HasImmunity(victim,Immunity_Skills))
				{
					PrintHintText(victim,"You got Time Locked");
					PrintHintText(attacker,"Time Lock!");


					W3FlashScreen(victim,RGBA_COLOR_BLUE);
					CreateTimer(0.15,UnfreezeStun,victim);

					War3_SetBuff(victim,bStunned,thisRaceID,true);
					War3_CooldownMGR( attacker, 5.0, thisRaceID, SKILL_TIMELOCK, true, true);
				}
				else
				{
					War3_NotifyPlayerImmuneFromSkill(attacker, victim, SKILL_TIMELOCK);
				}
			}
		}

	}
}


public Action:UnfreezeStun(Handle:h,any:client) //always keep timer data generic
{
	War3_SetBuff(client,bStunned,thisRaceID,false);
	return Plugin_Stop;
}
public OnWar3EventDeath(victim,attacker){
	RewindHPAmount[victim]=0;
}
new skip;
public OnGameFrame() //this is a sourcemod forward?, every game frame it is called. forwards if u implement it sourcemod will call you
{
	if(RaceDisabled)
		return;

	if(skip==0){

		for(new i=1;i<=MaxClients;i++){
			if(ValidPlayer(i,true))//valid (in game and shit) and alive (true parameter)k
			{
				if(RewindHPAmount[i]>0){
					War3_HealToMaxHP(i,1);
					War3_TFHealingEvent(i,1);
					RewindHPAmount[i]--;
				}
			}

		}
		skip=2;
	}
	skip--;
	/*
	new entity = -1;
	while ((entity=FindEntityByClassname(entity, "info_target"))!=INVALID_ENT_REFERENCE)
	{
		if(IsValidEntity(entity))
		{
			if(RemovePortals)
			{
				decl String:targetname[128];
				GetEntPropString(entity, Prop_Data, "m_iName", targetname, sizeof(targetname));
				if(StrEqual(targetname, "spawn_purgatory", false))
				{
					AcceptEntityInput(entity, "kill");
				}
			}
		}
	}*/
}

/* ***************************	ability *************************************/

/*
public void OnAbilityCommand(int client, int ability, bool pressed, bool bypass)
{
	if(ValidPlayer(client,true,true) && War3_GetRace(client)==thisRaceID && ability==0 && pressed && GetClientTeam(client)!=1)
	{
		new skill_levels=War3_GetSkillLevel(client,thisRaceID,ABILITY_SKILL_ENTRANCE);
		if(skill_levels>=1 && War3_SkillNotInCooldown(client,thisRaceID,ABILITY_SKILL_ENTRANCE))
		{
			SetPortalEntrance(client);
			War3_CooldownMGR(client,ManaEntrance[skill_levels],thisRaceID,ABILITY_SKILL_ENTRANCE,_,_);
		}
	}
	if(ValidPlayer(client,true,true) && War3_GetRace(client)==thisRaceID && ability==2 && pressed && max_exits_per_map[client]<3 && GetClientTeam(client)!=1)
	{
		new skill_levels=War3_GetSkillLevel(client,thisRaceID,ABILITY_SKILL_EXIT);
		if(skill_levels>=1 && War3_SkillNotInCooldown(client,thisRaceID,ABILITY_SKILL_EXIT))
		{
			SetPortalExit(client);
			max_exits_per_map[client]++;
			War3_CooldownMGR(client,ManaExit[skill_levels],thisRaceID,ABILITY_SKILL_EXIT,_,_);
		}
	}
}

SetPortalExit(client)
{
	new target = CreateEntityByName("info_target");
	if(IsValidEntity(target))
	{
		new Float:g_pos_portal[3];
		GetClientAbsOrigin(client,g_pos_portal);
		TeleportEntity(target, g_pos_portal, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(target, "targetname", "spawn_purgatory");
		DispatchSpawn(target);
		PrintToChat(client, "Portal Exit %d of 3 has Been Spawned per round!",max_exits_per_map[client]);
	}
}

SetPortalEntrance(client)
{
					new Float:playerVec[3];
					GetClientAbsOrigin(client,playerVec);
					//new Float:otherVec[3];
					//MAY NOT USE SOME OF THIS STUFF BELOW.. SEE LOGS
					for(new i=1;i<=MaxClients;i++)
					{
						if(ValidPlayer(i,true))
						{
							GetClientAbsOrigin(i,otherVec);
							if(GetVectorDistance(playerVec,otherVec)<150.0)
							{
								W3FlashScreen(i,RGBA_COLOR_WHITE);
								W3FlashScreen(client, RGBA_COLOR_WHITE);
								//position = vector to hold the victim's location
								new Float:position[3];
								//fill victim's vector with his location
								GetEntPropVector(i, Prop_Send, "m_vecOrigin", position);
								//position2 victim= vector to hold the warden's location
								new Float:position2[3];
								GetEntPropVector(client, Prop_Send, "m_vecOrigin", position2);
								//diff is a temp vector used to hold the vector between the two players
								new Float:diff[3];
								diff[0] = position[0] - position2[0];
								diff[1] = position[1] - position2[1];
								//go vector holds the 'normalization' of the difference vector
								new Float:go[3];
								NormalizeVector(diff, go);
								//knock back of 500 'normalized' units ... z axis is statically set to be 450
								go[0]/=400.0;
								go[1]/=400.0;
								go[2]=40.0;
								TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, go);
							}
							GetClientAbsOrigin(i,otherVec);
							if(GetVectorDistance(playerVec,otherVec)<30.0 && i!=client)
							{
								War3_HealToMaxHP(i,500);
								TF2_AddCondition(i,TFCond_Ubercharged,6.0);
								War3_SetBuff(i,bDisarm,thisRaceID,true);
								War3_SetBuff(i,bFlyMode,thisRaceID,true);
								PlayerImmune[i]=true;
								SavedLocationPos[i]=otherVec;
								GetClientEyeAngles(i,SavedLocationAng[i]);
							}
						}
					}
					new portal = CreateEntityByName("teleport_vortex");
					if(IsValidEntity(portal))
					{
						SetEntProp(portal, Prop_Send, "m_iState", 1);
						DispatchSpawn(portal);
						new Float:g_pos_portal[3];
						GetClientAbsOrigin(client,g_pos_portal);
						g_pos_portal[2]+=160;
						TeleportEntity(portal, g_pos_portal, NULL_VECTOR, NULL_VECTOR);
						PrintToChat(client, "Portal Has been spawned!");
					}
					CreateTimer(5.0, RemoveAllTeleport, client);
}

public Action:RemoveAllTeleport(Handle:timer, any:client)
{
	//new Float:playerVec[3];
	//GetClientAbsOrigin(client,playerVec);
	//new Float:otherVec[3];
	for(new i=1;i<=MaxClients;i++)
	{
		if(ValidPlayer(i,true))
		{
			if(PlayerImmune[i])
			{
				//War3_HealToMaxHP(i,150);
				TeleportEntity(i, SavedLocationPos[i], SavedLocationAng[i], NULL_VECTOR);
				War3_SetBuff(i,bDisarm,thisRaceID,false);
				War3_SetBuff(i,bFlyMode,thisRaceID,false);
				//otherVec=SavedLocationPos[i];
				PlayerImmune[i]=false;
			}
		}
	}
}

*/
#if GGAMETYPE == GGAME_TF2
public Action OnW3TakeDmgBulletPre(int victim, int attacker, float damage, int damagecustom)
{
	//if(RaceDisabled)
		//return;

	//if(ValidPlayer(attacker) && War3_GetRace(attacker) && ValidPlayer(victim) && (W3GetBuffHasTrue(victim,bStunned)||W3GetBuffHasTrue(victim,bBashed)))
	if(ValidPlayer(attacker) && ValidPlayer(victim) && (War3_GetRace(attacker)==thisRaceID||War3_GetRace(victim)==thisRaceID) && (!War3_SkillNotInCooldown(attacker,thisRaceID,ULT_SPHERE,false)||!War3_SkillNotInCooldown(victim,thisRaceID,ULT_SPHERE,false)))
	{
		switch (damagecustom)
		{
			case TF_CUSTOM_TAUNT_HADOUKEN, TF_CUSTOM_TAUNT_HIGH_NOON, TF_CUSTOM_TAUNT_GRAND_SLAM, TF_CUSTOM_TAUNT_FENCING,
			TF_CUSTOM_TAUNT_ARROW_STAB, TF_CUSTOM_TAUNT_GRENADE, TF_CUSTOM_TAUNT_BARBARIAN_SWING,
			TF_CUSTOM_TAUNT_UBERSLICE, TF_CUSTOM_TAUNT_ENGINEER_SMASH, TF_CUSTOM_TAUNT_ENGINEER_ARM, TF_CUSTOM_TAUNT_ARMAGEDDON:
			{
				War3_DamageModPercent(0.0);
				//PrintToChatAll("taunt killer %d victim %d",attacker, victim);
				CreateTimer(0.1,EndTauntkill,attacker);
			}
		}
	}
}
#endif

public Action:EndTauntkill(Handle:t,any:client)
{
	FakeClientCommand(client, "kill");
}
