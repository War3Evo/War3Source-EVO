#include <war3source>
#assert GGAMEMODE == MODE_WAR3SOURCE


#define RACE_ID_NUMBER 230

//#include "W3SIncs/War3Source_Effects"

/*
public APLRes:AskPluginLoad2Custom(Handle:plugin,bool:late,String:error[],err_max)
{
	if(!GameTF())
		return APLRes_SilentFailure;
	return APLRes_Success;
}
*/
new thisRaceID;
public Plugin:myinfo =
{
	name = "Race - Rainbow Dash",
	author = "OWNAGE",
	description = "",
	version = "1.0",
	url = "http://ownageclan.com/"
};

bool HooksLoaded = false;
public void Load_Hooks()
{
	if(HooksLoaded) return;
	HooksLoaded = true;

	W3Hook(W3Hook_OnW3TakeDmgAll, OnW3TakeDmgAll);
	W3Hook(W3Hook_OnWar3EventPostHurt, OnWar3EventPostHurt);
	W3Hook(W3Hook_OnUltimateCommand, OnUltimateCommand);
	W3Hook(W3Hook_OnAbilityCommand, OnAbilityCommand);
}
public void UnLoad_Hooks()
{
	if(!HooksLoaded) return;
	HooksLoaded = false;

	W3UnhookAll(W3Hook_OnW3TakeDmgAll);
	W3UnhookAll(W3Hook_OnWar3EventPostHurt);
	W3UnhookAll(W3Hook_OnUltimateCommand);
	W3UnhookAll(W3Hook_OnAbilityCommand);
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


new Float:EvadeChance[5]={0.0,0.04,0.06,0.08,0.10};
new Float:attackspeed[5]={1.0,1.02,1.04,1.06,1.08};
new Float:abilityspeed[5]={1.0,1.15,1.23,1.32,1.40};

new Float:fSonicBoom[MAXPLAYERSCUSTOM];
new bool:bSonicBoom[MAXPLAYERSCUSTOM];
new bool:bSonicBoomDamage[MAXPLAYERSCUSTOM];

new Float:LastDamageTime[MAXPLAYERSCUSTOM];

//new SKILL_GENERIC,SKILL_EVADE,SKILL_SWIFT,SKILL_SPEED,ULTIMATE;
new SKILL_EVADE,SKILL_SWIFT,SKILL_SPEED,ULTIMATE;

new bool:inSpeed[MAXPLAYERSCUSTOM];
new Handle:speedendtimer[MAXPLAYERSCUSTOM];


new Float:rainboomradius[5]={0.0,200.0,266.0,333.0,400.0};

/*
public OnPluginStart()
{
	//CreateTimer(1.0,CalcWards,_,TIMER_REPEAT);
	CreateTimer(0.1,SonicBoomCheckLoop,_,TIMER_REPEAT);

	for(new z=0;z<MAXPLAYERSCUSTOM;z++)
	{
		bSonicBoomDamage[z]=false;
		bSonicBoom[z]=false;
		fSonicBoom[z]=0.0;
	}
}*/

public OnAllPluginsLoaded()
{
	War3_RaceOnPluginStart("rainbowdash");
}
public OnPluginEnd()
{
	if(LibraryExists("RaceClass"))
		War3_RaceOnPluginEnd("rainbowdash");
}

public OnWar3LoadRaceOrItemOrdered2(num,reloadrace_id,String:shortname[])
{
	//if(num==1)
	//{
		//SKILL_GENERIC=War3_CreateGenericSkill("g_evasion");
		//DP("registereing gernicsadlfjasf");
	//}
	if(num==RACE_ID_NUMBER||(reloadrace_id>0&&StrEqual("rainbowdash",shortname,false)))
	{
		thisRaceID=War3_CreateNewRace("[MLP:FIM] Rainbow Dash","rainbowdash",reloadrace_id,"Buff teammates,speed");
		//new Handle:evasiondata=CreateArray(5,1);
		//SetArrayArray(evasiondata,0,EvadeChance,sizeof(EvadeChance));
		//SKILL_EVADE=War3_UseGenericSkill(thisRaceID,"g_evasion",evasiondata,"Evasion","5% evasion.");
		SKILL_EVADE=War3_AddRaceSkill(thisRaceID,"Evasion","4/6/8/10 percent chance of evading a shot",false,4);
		SKILL_SWIFT=War3_AddRaceSkill(thisRaceID,"Swiftness","+ 2/4/6/8% Attack Speed");
		SKILL_SPEED=War3_AddRaceSkill(thisRaceID,"Speed","(ability) +40% speed for 6 seconds.\nMust not be injured in the last 10 seconds.\nEnds if injured.");
		ULTIMATE=War3_AddRaceSkill(thisRaceID,"Sonic Rainboom","Buff teammates' damage around you for 4 sec, 200-400 units. Must be in speed (ability) mode to cast.",true);
		War3_CreateRaceEnd(thisRaceID); ///DO NOT FORGET THE END!!!
	}
}
//public FOO(){
	//SKILL_EVADE=SKILL_EVADE+0;
//}

/*
public OnW3Denyable(W3DENY:event,client)
{
	if((event == DN_CanBuyItem1) && (W3GetVar(EventArg1) == War3_GetItemIdByShortname("armband")))
	{
		if(War3_GetRace(client)==thisRaceID)
		{
			W3Deny();
			War3_ChatMessage(client, "Ponies don't have arms!");
		}
	}
} */

/* ***************************	OnRaceChanged *************************************/

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


/* ***************************	InitPassiveSkills *************************************/

public InitPassiveSkills(client)
{
	bSonicBoomDamage[client]=false;
	bSonicBoom[client]=false;
	fSonicBoom[client]=0.0;
	speedendtimer[client]=INVALID_HANDLE;
}

/* ***************************	RemovePassiveSkills *************************************/

public RemovePassiveSkills(client)
{
	bSonicBoomDamage[client]=false;
	bSonicBoom[client]=false;
	fSonicBoom[client]=0.0;
	speedendtimer[client]=INVALID_HANDLE;
}


public Action:SonicBoomCheckLoop(Handle:h,any:data)
{
	if(RaceDisabled)
		return;

	new Float:origin[3];
	for(new i=1;i<=MaxClients;i++){

		if(ValidPlayer(i,true))
		{
			if(bSonicBoom[i] && fSonicBoom[i]>GetGameTime())
			{
				//attacker=RupturedBy[i];
				if(ValidPlayer(i,true))
				{

					GetClientAbsOrigin(i,origin);
#if GGAMETYPE == GGAME_TF2
					//War3_TF_ParticleToClient(0, GetClientTeam(i)==2?"soldierbuff_red_buffed":"soldierbuff_blue_buffed", origin);
					//ThrowAwayParticle(GetClientTeam(i)==2?"soldierbuff_red_buffed":"soldierbuff_blue_buffed", origin, 0.3);
					AttachThrowAwayParticle(i, GetClientTeam(i)==2?"soldierbuff_red_buffed":"soldierbuff_blue_buffed",origin, "chest", 4.0);
#endif
					bSonicBoom[i]=false;
					bSonicBoomDamage[i]=true;
					//lastRuptureLocation[i][0]=origin[0];
					//lastRuptureLocation[i][1]=origin[1];
					//lastRuptureLocation[i][2]=origin[2];
				}
			}
			else
			{
				if(!(fSonicBoom[i]>GetGameTime()))
				{
					bSonicBoomDamage[i]=false;
				}
				//bSonicBoom[i]=false;
			}
		}
	}
}


new HaloSprite,XBeamSprite;
public OnMapStart()
{
	UnLoad_Hooks();

	HaloSprite = War3_PrecacheHaloSprite();
	XBeamSprite = War3_PrecacheBeamSprite();
	for(new z=0;z<MAXPLAYERSCUSTOM;z++)
	{
		bSonicBoomDamage[z]=false;
		bSonicBoom[z]=false;
		fSonicBoom[z]=0.0;
		speedendtimer[z]=INVALID_HANDLE;
	}
	
	CreateTimer(0.1,SonicBoomCheckLoop,_,TIMER_REPEAT);

	for(new z=0;z<MAXPLAYERSCUSTOM;z++)
	{
		bSonicBoomDamage[z]=false;
		bSonicBoom[z]=false;
		fSonicBoom[z]=0.0;
	}
}
/*
public Action:CalcWards(Handle:t){
	for(new i=1;i<66;i++){
		if(ValidPlayer(i)&&!IsFakeClient(i)){

//TF2_AddCondition(i,TFCond_SpeedBuffAlly,1.3);
//TF2_AddCondition(i,TFCond_Buffed,1.3);


//TF2_AddCondition(i,TFCond_Charging,1.3);

		//DP("tick");
		//static data;
		//DP("level %d data %d",W3_GenericSkillLevel(i,SKILL_GENERIC,data),data);
		//DP("data %d",data);
		}
	}
}
*/
///look attack speed
public void OnSkillLevelChanged(int client, int currentrace, int skill, int newskilllevel, int oldskilllevel)
{
	if(RaceDisabled)
		return;

	if(currentrace==thisRaceID)
	{
		if(skill==SKILL_SWIFT)
		{
			War3_SetBuff(client,fAttackSpeed,thisRaceID,attackspeed[newskilllevel]);
		}
	}
}

////speed ability
public void OnAbilityCommand(int client, int ability, bool pressed, bool bypass)
{
	if(RaceDisabled)
		return;

	if(ValidPlayer(client,true)&& pressed && IsPlayerAlive(client))
	{

			new skill_level=War3_GetSkillLevel(client,thisRaceID,SKILL_SPEED);
			if(skill_level>0)
			{
				if(SkillAvailable(client,thisRaceID,SKILL_SPEED)){
					inSpeed[client]=true;
#if GGAMETYPE == GGAME_TF2
					TF2_AddCondition(client,TFCond_SpeedBuffAlly,6.0);
#endif
					War3_SetBuff(client,fMaxSpeed,thisRaceID,abilityspeed[skill_level]);
					War3_SetBuff(client,fSlow,thisRaceID,0.740740741); //slow down by the factor of the SpeedBuffAlly (1.35)
					speedendtimer[client]=CreateTimer(6.0,EndSpeed,client);
					War3_CooldownMGR(client,20.0,thisRaceID,SKILL_SPEED,_,_);
				}
			}

	}
}
public Action:EndSpeed(Handle:t,any:client){
	//DP("end");
#if GGAMETYPE == GGAME_TF2
	TF2_RemoveCondition(client,TFCond_SpeedBuffAlly);
#endif
	War3_SetBuff(client,fMaxSpeed,thisRaceID,1.0);
	War3_SetBuff(client,fSlow,thisRaceID,1.0);
	speedendtimer[client]=INVALID_HANDLE;
	inSpeed[client]=false;
}
public OnWar3EventDeath(client){
	if(ValidPlayer(client))
	{
		if(speedendtimer[client]!=INVALID_HANDLE){
			TriggerTimer(speedendtimer[client]);
		}
	}
}
public Action OnWar3EventPostHurt(int victim, int attacker, float dmgamount, char weapon[32], bool isWarcraft, const float damageForce[3], const float damagePosition[3])
{
	if(RaceDisabled)
		return;

	if(!isWarcraft && ValidPlayer(victim))
	{
		LastDamageTime[victim]=GetEngineTime();
		if(speedendtimer[victim]!=INVALID_HANDLE){
			TriggerTimer(speedendtimer[victim]);
		}
		else if(War3_GetRace(victim)==thisRaceID){
			War3_CooldownMGR(victim,10.0,thisRaceID,SKILL_SPEED,_,_);
		}
	}
}


public void OnUltimateCommand(int client, int race, bool pressed, bool bypass)
{
	if(RaceDisabled)
		return;

	if(race==thisRaceID && pressed && ValidPlayer(client,true))
	{
		new skill=War3_GetSkillLevel(client,race,ULTIMATE);
		//DP("skill %d",skill);
		if(skill>0)
		{
			if(SkillAvailable(client,thisRaceID,ULTIMATE))
			{
				if(!inSpeed[client]){
					PrintHintText(client,"You must be in speed mode (ability)");
				}
				else{
					//TriggerTimer(speedendtimer[client]);
					War3_CooldownMGR(client,20.0,thisRaceID,ULTIMATE,_,_);

					decl Float:start_pos[3];
					GetClientAbsOrigin(client,start_pos);

					//TE_SetupBeamRingPoint(const Float:center[3], Float:Start_Radius, Float:End_Radius, ModelIndex, HaloIndex, StartFrame, FrameRate, Float:Life, Float:Width, Float:Amplitude, const Color[4], Speed, Flags)
					TE_SetupBeamRingPoint(start_pos,                 20.0,            rainboomradius[skill]*2,			 XBeamSprite, HaloSprite,	 0, 		1, 				0.5, 	30.0, 		0.0, 			{255,0,0,255}, 10, 	0);
					War3_TE_SendToAll(0.0);
					TE_SetupBeamRingPoint(start_pos,                 20.0,            rainboomradius[skill]*2,			 XBeamSprite, HaloSprite,	 0, 		1, 				0.5, 	30.0, 		0.0, 			{255, 127, 0,255}, 10, 	0);
					War3_TE_SendToAll(0.05);
					TE_SetupBeamRingPoint(start_pos,                 20.0,            rainboomradius[skill]*2,			 XBeamSprite, HaloSprite,	 0, 		1, 				0.5, 	30.0, 		0.0, 			{255, 255, 0,255}, 10, 	0);
					War3_TE_SendToAll(0.09);
					TE_SetupBeamRingPoint(start_pos,                 20.0,            rainboomradius[skill]*2,			 XBeamSprite, HaloSprite,	 0, 		1, 				0.5, 	30.0, 		0.0, 			{0, 255, 0,255}, 10, 	0);
					War3_TE_SendToAll(0.11);
					TE_SetupBeamRingPoint(start_pos,                 20.0,            rainboomradius[skill]*2,			 XBeamSprite, HaloSprite,	 0, 		1, 				0.5, 	30.0, 		0.0, 			{0, 127, 255,255}, 10, 	0);
					War3_TE_SendToAll(0.13);
					TE_SetupBeamRingPoint(start_pos,                 20.0,            rainboomradius[skill]*2,			 XBeamSprite, HaloSprite,	 0, 		1, 				0.5, 	30.0, 		0.0, 			{0,0,255,255}, 10, 	0);
					War3_TE_SendToAll(0.15);
					TE_SetupBeamRingPoint(start_pos,                 20.0,            rainboomradius[skill]*2,			 XBeamSprite, HaloSprite,	 0, 		1, 				0.5, 	30.0, 		0.0, 			{143, 0, 255,255}, 10, 	0);
					War3_TE_SendToAll(0.17);
					//DP("%f %f",rainboomradius[skill],rainboomradius[skill]*2);

					decl Float:TargetPos[3];
					for (new i = 1; i <= MaxClients; i++) {
#if GGAMETYPE == GGAME_TF2
						if(ValidPlayer(i,true) && GetClientTeam(i) == GetClientTeam(client)&&GetClientTeam(client) == GetApparentTeam(i)) {
#elseif  GGAMETYPE == GGAME_CSGO
						if(ValidPlayer(i,true) && GetClientTeam(i) == GetClientTeam(client)) {
#endif

							GetClientAbsOrigin(i, TargetPos);
							if (GetVectorDistance(start_pos, TargetPos) <= rainboomradius[skill]) {
								//TF2_AddCondition(i,TFCond_Buffed,4.0);
								fSonicBoom[i]=GetGameTime()+4.0;
								bSonicBoom[i]=true;
								War3_ShakeScreen(i,0.5,100.0,80.0);
							}
						}
					}
				}
			}

		}
		else
		{
			W3MsgUltNotLeveled(client);
		}
	}
}















public Action OnW3TakeDmgAll(int victim,int attacker, float damage)
{
	if(RaceDisabled)
		return;

	if(ValidPlayer(victim)&&ValidPlayer(attacker)&&attacker!=victim)
	{
		new vteam=GetClientTeam(victim);
		new ateam=GetClientTeam(attacker);
		if(vteam!=ateam)
		{
			if(W3GetDamageIsBullet() && bSonicBoomDamage[attacker])
			{
				//native bool:War3_DealDamage(victim,damage,attacker=0,damage_type=DMG_GENERIC,String:weaponNameStr[], War3DamageOrigin:W3DMGORIGIN=W3DMGORIGIN_UNDEFINED , War3DamageType:W3DMGTYPE=W3DMGTYPE_MAGIC , bool:respectVictimImmunity=true , bool:countAsFirstDamageRetriggered=false, bool:noWarning=false);

				// W3DMGORIGIN_ULTIMATE = if set to this, this statement automatically checks for immunity to ultimates, especially since this default is true respectVictimImmunity.
				//DP("Old Damage: %.2f",damage);
				new idamage=RoundToFloor(FloatMul(damage,0.35));
				if(War3_DealDamage(victim,idamage,attacker,_,"sonicboom",W3DMGORIGIN_ULTIMATE,W3DMGTYPE_PHYSICAL))
				{
					//DP("deal damage = true (Immunity check)");
#if GGAMETYPE == GGAME_TF2
					decl Float:pos[3];
					GetClientEyePosition(victim, pos);
					pos[2] += 4.0;
					War3_TF_ParticleToClient(0, "minicrit_text", pos); //to the attacker at the enemy pos
#endif
				}
				//DP("New Damage: %d",idamage);
			}
		}
	}
}
/*
public Action OnW3TakeDmgBulletPre(int victim, int attacker, float damage, int damagecustom)
{
	if(ValidPlayer(victim)&&ValidPlayer(attacker)&&attacker!=victim)
	{
		new vteam=GetClientTeam(victim);
		new ateam=GetClientTeam(attacker);
		if(vteam!=ateam)
		{
				new Handle:data;
				new Float:chances[5];

				new level=W3_GenericSkillLevel(victim,SKILL_GENERIC,data);
				if(level){
					GetArrayArray(data,	0,chances);
					if(data!=INVALID_HANDLE&& level>0 &&!Hexed(victim,false) && W3Chance(chances[level]) && !W3HasImmunity(attacker,Immunity_Skills))
					{

						W3FlashScreen(victim,RGBA_COLOR_BLUE);

						War3_DamageModPercent(0.0); //NO DAMAMGE

						W3MsgEvaded(victim,attacker);
						decl Float:pos[3];
						GetClientEyePosition(victim, pos);
						pos[2] += 4.0;
						War3_TF_ParticleToClient(0, "miss_text", pos); //to the attacker at the enemy pos
					}
			}
		}
	}
}  */

public OnW3TakeDmgBulletPre(victim,attacker,Float:damage)
{
	if(RaceDisabled)
		return;

	if(ValidPlayer(victim,true,true)&&ValidPlayer(attacker,true,true)&&attacker!=victim)
	{
		new vteam=GetClientTeam(victim);
		new ateam=GetClientTeam(attacker);
		if(vteam!=ateam)
		{
			//evade
			//if they are not this race thats fine, later check for race
			if(War3_GetRace(victim)==thisRaceID )
			{
				new skill_level_evasion=War3_GetSkillLevel(victim,thisRaceID,SKILL_EVADE);
				if(skill_level_evasion>0 &&!Hexed(victim,false) && GetRandomFloat(0.0,1.0)<=EvadeChance[skill_level_evasion])
				{
					if(!W3HasImmunity(attacker,Immunity_Skills))
					{
						W3FlashScreen(victim,RGBA_COLOR_BLUE);

						War3_DamageModPercent(0.0); //NO DAMAMGE

						W3MsgEvaded(victim,attacker);
#if GGAMETYPE == GGAME_TF2
						decl Float:pos[3];
						GetClientEyePosition(victim, pos);
						pos[2] += 4.0;
						War3_TF_ParticleToClient(0, "miss_text", pos); //to the attacker at the enemy pos
#endif
					}
					else
					{
						War3_NotifyPlayerImmuneFromSkill(attacker, victim, SKILL_EVADE);
					}
				}
			}
		}
	}
}
