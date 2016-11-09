#include <war3source>
#assert GGAMEMODE == MODE_WAR3SOURCE
#assert GGAMETYPE_JAILBREAK == JAILBREAK_OFF

#define PLUGIN_VERSION "0.0.0.2 (1/18/2013)"

#define RACE_ID_NUMBER 220

//#include "W3SIncs/War3Source_Effects"

new thisRaceID;
public Plugin:myinfo =
{
	name = "Race - Rarity",
	author = "OWNAGE",
	description = "",
	version = "1.1",
	url = "http://ownageclan.com/"
};

bool HooksLoaded = false;
public void Load_Hooks()
{
	if(HooksLoaded) return;
	HooksLoaded = true;

	W3Hook(W3Hook_OnW3TakeDmgAllPre, OnW3TakeDmgAllPre);
#if GGAMETYPE == GGAME_TF2
	W3Hook(W3Hook_OnW3TakeDmgBulletPre, OnW3TakeDmgBulletPre);
#endif
	W3Hook(W3Hook_OnW3TakeDmgAll, OnW3TakeDmgAll);
	W3Hook(W3Hook_OnUltimateCommand, OnUltimateCommand);
	W3Hook(W3Hook_OnAbilityCommand, OnAbilityCommand);
	W3Hook(W3Hook_OnWar3EventSpawn, OnWar3EventSpawn);
}
public void UnLoad_Hooks()
{
	if(!HooksLoaded) return;
	HooksLoaded = false;

	W3UnhookAll(W3Hook_OnW3TakeDmgAllPre);
#if GGAMETYPE == GGAME_TF2
	W3UnhookAll(W3Hook_OnW3TakeDmgBulletPre);
#endif
	W3UnhookAll(W3Hook_OnW3TakeDmgAll);
	W3UnhookAll(W3Hook_OnUltimateCommand);
	W3UnhookAll(W3Hook_OnAbilityCommand);
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

new SKILL_SMITTEN,SKILL_HEARTACHE,SKILL_SLEEP,ULTIMATE;
///based on succubus HON
//new TeleBeam,HaloSprite,BeamSprite;
new HaloSprite,BeamSprite;

new Float:smittenCooldown=15.0;
new Float:smittenDuration=5.0;
new Float:smittenMultiplier[5]={1.0,0.9,0.83,0.76,0.7};
new bSmittened[MAXPLAYERSCUSTOM];
new Float:SmittendMultiplier[MAXPLAYERSCUSTOM];

new Float:sleepDistance[]={0.0,400.0,500.0,600.0,700.0};
new Float:sleepCooldown[]={0.0,40.0,30.0,25.0,15.0};
new Float:sleepDuration[]={0.0,2.0,2.5,2.5,3.5};


new Handle:SleepHandle[MAXPLAYERSCUSTOM]; //the trie
new Handle:SleepTimer[MAXPLAYERSCUSTOM]; //the timer that ends the sleep

new Float:heartacheChance[]={0.0,0.06,0.9,0.12,0.15};

new isMesmerized[MAXPLAYERSCUSTOM];

new Float:ultDuration[]={0.0,1.5,1.75,2.0,2.25};
new Float:ultDistance=500.0;

new holdingvictim[MAXPLAYERSCUSTOM]; //the victim being held
new Handle:holdingTimer[MAXPLAYERSCUSTOM];

public OnWar3LoadRaceOrItemOrdered2(num,reloadrace_id,String:shortname[])
{
	if(num==RACE_ID_NUMBER||(reloadrace_id>0&&StrEqual("rarity",shortname,false)))
	{
		thisRaceID=War3_CreateNewRace("[MLP:FIM] Rarity","rarity",reloadrace_id,"Hold,Mesmerize,Heartache");
		SKILL_SMITTEN=War3_AddRaceSkill(thisRaceID,"Smitten","Reduces enemy damage by up to 30%%\nLasts 5.0 seconds with 15 second cooldown.",false,4);
		SKILL_HEARTACHE=War3_AddRaceSkill(thisRaceID,"Heartache","Up to 15%% chance of dealing 20 true damage and healing self for the same amount",false,4);
		SKILL_SLEEP=War3_AddRaceSkill(thisRaceID,"Mesmerize","Puts enemy to sleep (2.0/2.5/2.5/3.5 seconds), if that enemy is attacked, the sleep will transfer to the attacker\nCooldown decreases with level\nCast distance increases with level",false,4);
		ULTIMATE=War3_AddRaceSkill(thisRaceID,"Hold","Hold and blinds player up to 2.3 seconds",true,4);
		War3_CreateRaceEnd(thisRaceID); ///DO NOT FORGET THE END!!!
	}
}

public OnPluginStart()
{
	CreateConVar("rarity",PLUGIN_VERSION,"War3Source:EVO Job Rarity",FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);

	//LoadTranslations("w3s.race.rarity.phrases");
}

public OnAllPluginsLoaded()
{
	War3_RaceOnPluginStart("rarity");
}

public OnPluginEnd()
{
	if(LibraryExists("RaceClass"))
		War3_RaceOnPluginEnd("rarity");
}

public OnMapStart()
{
	UnLoad_Hooks();
	//TeleBeam=PrecacheModel("materials/sprites/tp_beam001.vmt");
	BeamSprite=War3_PrecacheBeamSprite();
	HaloSprite=War3_PrecacheHaloSprite();
	for (new i=0;i<MAXPLAYERSCUSTOM;i++)
	{
		isMesmerized[i]=0;
	}
	CreateTimer(0.1, doMesmerize, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action:doMesmerize(Handle:timer){
	if(RaceDisabled)
		return;

	for (new client=0;client<MAXPLAYERSCUSTOM;client++)
	{
		if (isMesmerized[client]==1) {
			new Float:effect_vec[3];
			GetClientAbsOrigin(client,effect_vec);
			effect_vec[2]+=15.0;
			TE_SetupBeamRingPoint(effect_vec,45.0,44.0,BeamSprite,HaloSprite,0,15,0.1,5.0,0.0,{175,0,255,255},10,0);
			War3_TE_SendToAll();
			effect_vec[2]+=15.0;
			TE_SetupBeamRingPoint(effect_vec,45.0,44.0,BeamSprite,HaloSprite,0,15,0.1,5.0,0.0,{175,0,255,255},10,0);
			War3_TE_SendToAll();
			effect_vec[2]+=15.0;
			TE_SetupBeamRingPoint(effect_vec,45.0,44.0,BeamSprite,HaloSprite,0,15,0.1,5.0,0.0,{175,0,255,255},10,0);
			War3_TE_SendToAll();
		}
	}

}
public void OnWar3EventSpawn (int client)
{
	bSmittened[client]=false;
}



public Action OnW3TakeDmgAllPre(int victim, int attacker, float damage)
{
	if(RaceDisabled)
		return;

	if(ValidPlayer(victim)&&ValidPlayer(attacker)) //fixed a bug where attacking a mesmerized player when holding holy shield would still result in transfer of stun - Dagothur 1/17/2013
	{
		if(GetClientTeam(victim)!=GetClientTeam(attacker)&&attacker!=victim)
		{
			if(bSmittened[attacker]){
				if(!W3HasImmunity(attacker,Immunity_Skills))
				{
					War3_DamageModPercent(SmittendMultiplier[attacker]);
					//DP("Multi = %.2f",SmittendMultiplier[attacker]);
					new LessDamage=RoundToFloor(FloatMul(FloatSub(1.0,SmittendMultiplier[attacker]),100.0));
					War3_ChatMessage(attacker,"{default}[{blue}SKILL SMITTEN{default}] You do [{green}%d%{default}] less damage!", LessDamage);
				}
				else
				{
					War3_NotifyPlayerImmuneFromSkill(victim, attacker, SKILL_SMITTEN);
				}
			}

		}
		if(SleepHandle[victim]){

			if (!W3HasImmunity(attacker,Immunity_Skills)) {

				KillTimer(SleepTimer[victim]);
				SleepTimer[victim]=INVALID_HANDLE;
				SleepHandle[attacker]=SleepHandle[victim];
				SleepHandle[victim]=INVALID_HANDLE;

				UnSleep(victim,1);
				new Float:duration;
				GetTrieValue(SleepHandle[attacker],"originalduration",duration);

				SleepTimer[attacker]=CreateTimer(duration,EndSleep,attacker);
				Sleep(attacker,duration,victim);
			} else {

				W3Hint(attacker,_,_,"Can't hit a sleeping target when you are skill immune!");
				W3Hint(victim,_,_,"An enemy is skill immune and cannot disturb your slumber!");
				War3_NotifyPlayerImmuneFromSkill(victim, attacker, SKILL_SLEEP);
			}
			War3_DamageModPercent(0.0); //NO DAMAMGE
			decl Float:pos[3];
			GetClientEyePosition(victim, pos);
			pos[2] += 4.0;
#if GGAMETYPE == GGAME_TF2
			War3_TF_ParticleToClient(0, "miss_text", pos); //to the attacker at the enemy pos
#endif

		}
		//DP("Damage = %d",War3_GetWar3DamageDealt());
	}

	///need to do sleep transfer, beware of sleep trie which you  need to close
}

public Action:UnSmitten(Handle:timer,any:client)
{
	bSmittened[client]=false;
	War3_NotifyPlayerSkillActivated(client,SKILL_SMITTEN,false);
	W3Hint(client,_,_,"Deactivated Smitten");
}






//public OnWar3EventPostHurt(victim,attacker,dmgamount,const String:weapon[32],bool:isWarcraft){
public Action OnW3TakeDmgAll(int victim,int attacker, float damage)
{
	if(RaceDisabled)
		return;

	new dmgamount=RoundToCeil(damage);
	if (victim!=attacker) {
		if(W3GetDamageIsBullet() && War3_GetRace(attacker)==thisRaceID ){
			new lvl = War3_GetSkillLevel(attacker,thisRaceID,SKILL_HEARTACHE);
			if(lvl > 0  )
			{
				if(W3Chance(heartacheChance[lvl]*W3ChanceModifier(attacker))    && !IsSkillImmune(victim)  ){

					War3_HealToBuffHP(attacker,dmgamount);
					PrintToConsole(attacker,"Heartache +%d HP",dmgamount);
				}
			}

			lvl = War3_GetSkillLevel(attacker,thisRaceID,SKILL_SMITTEN);
			if(lvl > 0)
			{
				if(!IsSkillImmune(victim)){
					if(!Hexed(attacker)&&War3_SkillNotInCooldown(attacker,thisRaceID,SKILL_SMITTEN,false))
					{
						bSmittened[victim]=true;
						SmittendMultiplier[victim]=smittenMultiplier[lvl];

						CreateTimer(smittenDuration,UnSmitten,victim);
						War3_CooldownMGR(attacker,smittenCooldown,thisRaceID,SKILL_SMITTEN);
						W3Hint(victim,_,_,"You have been Smittened you do less damage");
						W3Hint(attacker,_,_,"Activated Smitten");
						War3_NotifyPlayerSkillActivated(attacker,SKILL_SMITTEN,true);
					}
				}
			}
		}
	}
}




public void OnAbilityCommand(int client, int ability, bool pressed, bool bypass)
{
	if(RaceDisabled)
		return;

	if(War3_GetRace(client)==thisRaceID && ability==0 && pressed && IsPlayerAlive(client))
	{
		new lvl = War3_GetSkillLevel(client,thisRaceID,SKILL_SLEEP);
		if(lvl > 0)
		{
			if(!Silenced(client)&&War3_SkillNotInCooldown(client,thisRaceID,SKILL_SLEEP,true))
			{


				//War3_GetTargetInViewCone(client,Float:max_distance=0.0,bool:include_friendlys=false,Float:cone_angle=23.0,Function:FilterFunction=INVALID_FUNCTION);
				new target = War3_GetTargetInViewCone(client,sleepDistance[lvl],_,_,SkillFilter,SKILL_SLEEP);
				if(target>0)
				{
					if(!W3HasImmunity(target,Immunity_Skills))
					{
						new Float:duration=sleepDuration[lvl];
						SleepHandle[target]=CreateTrie();
						SleepTimer[target]=CreateTimer(duration,EndSleep,target);
						//SetTrieValue(sleepTrie,"timer",timer);
						//SetTrieValue(sleepTrie,"victim",target);
						SetTrieValue(SleepHandle[target],"originalduration",duration);


						//SetTrieValue(sleepTrie,"remainingduration",duration);
						Sleep(target,duration,client);
						decl String:name[128];
						GetClientName(target, name, sizeof(name));

						W3Hint(client,_,_,"You mesmerized %s !",name);
						War3_CooldownMGR(client,sleepCooldown[lvl],thisRaceID,SKILL_SLEEP);
					}
					else
					{
						//W3Hint(target,_,_,"You almost got Mesmerized! Thank your Holy Shield!");
						War3_NotifyPlayerImmuneFromSkill(client, target, SKILL_SLEEP);
					}

				}
				else{
					W3MsgNoTargetFound(client,sleepDistance[lvl]);
				}

			}
		}
	}
}
Sleep(client,Float:duration,attacker=0){
	War3_SetBuff(client,bStunned,thisRaceID,true);
	isMesmerized[client]=1;

	W3Hint(client,_,_,"MESMERIZED: Sleep for %.2f seconds!",duration);
	if (attacker)
	{
		PrintToServer("pew");
		decl Float:our_pos[3];


		GetClientAbsOrigin(attacker, our_pos);
		new Float:effect_vec[3];
		GetClientAbsOrigin(client,effect_vec);
		our_pos[2]+=50.0;
		effect_vec[2]+=50.0;
		TE_SetupBeamPoints(our_pos,effect_vec,BeamSprite,HaloSprite,0,50,2.0,6.0,25.0,0,12.0,{175,0,255,255},40);
		War3_TE_SendToAll();

	}
}

public Action:EndSleep(Handle:t,any:client){

	SleepTimer[client]=INVALID_HANDLE;
	CloseHandle(SleepHandle[client]);
	SleepHandle[client]=INVALID_HANDLE;

	UnSleep(client);
}
UnSleep(client,wasDamage=0){
	War3_SetBuff(client,bStunned,thisRaceID,false);
	isMesmerized[client]=0;
	if (wasDamage)
	{

		W3Hint(client,_,_,"Mesmerize was transferred to your attacker!");
	} else {
		W3Hint(client,_,_,"Mesmerize expired!");
	}
}














public void OnUltimateCommand(int client, int race, bool pressed, bool bypass)
{
	if(RaceDisabled)
		return;

	if(race==thisRaceID && pressed && ValidPlayer(client,true) )
	{
		new level=War3_GetSkillLevel(client,race,ULTIMATE);
		if(level>0)
		{
			if(!Silenced(client)&&War3_SkillNotInCooldown(client,thisRaceID,ULTIMATE,true))
			{
				//War3_GetTargetInViewCone(client,Float:max_distance=0.0,bool:include_friendlys=false,Float:cone_angle=23.0,Function:FilterFunction=INVALID_FUNCTION);
				new target = War3_GetTargetInViewCone(client,ultDistance,_,_,UltFilter,ULTIMATE);
				if(target>0)
				{
					//in case of double hold, release the old one
					if(holdingTimer[client]!=INVALID_HANDLE){
						TriggerTimer(holdingTimer[client]);
					}
					new Float:duration = ultDuration[level];
					///hold it right there
					holdingvictim[client]=target;
					holdingTimer[client]=CreateTimer(duration,EndHold,client);
					War3_SetBuff(client,bStunned,thisRaceID,true);
					War3_SetBuff(target,bStunned,thisRaceID,true);

					War3_CooldownMGR(client,20.0,thisRaceID,ULTIMATE);
				}
				else{
					W3MsgNoTargetFound(client,ultDistance);
				}
			}
		}
	}
}

//return true to allow targeting
public Action:EndHold(Handle:t,any:client){
	new victim=holdingvictim[client];
	War3_SetBuff(victim,bStunned,thisRaceID,false);
	War3_SetBuff(client,bStunned,thisRaceID,false);
	holdingvictim[client]=0;
	holdingTimer[client]=INVALID_HANDLE;
}
public OnWar3EventDeath(client){
	CleanUP(client);
}
public OnClientDisconnect(client){
	CleanUP(client);
}
CleanUP(client){
	if(holdingvictim[client]){
		TriggerTimer(holdingTimer[client]);
		holdingTimer[client]=INVALID_HANDLE;
	}
	if(SleepTimer[client]){
		UnSleep(client);
		KillTimer(SleepTimer[client]);
		SleepTimer[client]=INVALID_HANDLE;
		CloseHandle(SleepHandle[client]);
		SleepHandle[client]=INVALID_HANDLE;

	}
}

#if GGAMETYPE == GGAME_TF2
public Action OnW3TakeDmgBulletPre(int victim, int attacker, float damage, int damagecustom)
{
	//if(RaceDisabled)
		//return;

	//if(ValidPlayer(attacker) && War3_GetRace(attacker) && ValidPlayer(victim) && (W3GetBuffHasTrue(victim,bStunned)||W3GetBuffHasTrue(victim,bBashed)))
	if(ValidPlayer(attacker) && ValidPlayer(victim) && (War3_GetRace(attacker)==thisRaceID||War3_GetRace(victim)==thisRaceID) && (!War3_SkillNotInCooldown(attacker,thisRaceID,ULTIMATE,false)||!War3_SkillNotInCooldown(victim,thisRaceID,ULTIMATE,false)
	||!War3_SkillNotInCooldown(attacker,thisRaceID,SKILL_SLEEP,false)||!War3_SkillNotInCooldown(victim,thisRaceID,SKILL_SLEEP,false)))
	{
		switch (damagecustom)
		{
			case TF_CUSTOM_TAUNT_HADOUKEN, TF_CUSTOM_TAUNT_HIGH_NOON, TF_CUSTOM_TAUNT_GRAND_SLAM, TF_CUSTOM_TAUNT_FENCING,
			TF_CUSTOM_TAUNT_ARROW_STAB, TF_CUSTOM_TAUNT_GRENADE, TF_CUSTOM_TAUNT_BARBARIAN_SWING,
			TF_CUSTOM_TAUNT_UBERSLICE, TF_CUSTOM_TAUNT_ENGINEER_SMASH, TF_CUSTOM_TAUNT_ENGINEER_ARM, TF_CUSTOM_TAUNT_ARMAGEDDON:
			{
				War3_DamageModPercent(0.0);
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

//
#if GGAMETYPE == GGAME_TF2
public OnW3SupplyLocker(client)
{
	if(RaceDisabled)
		return;

	if(ValidPlayer(client))
	{
		bSmittened[client] = false;  // on spawn
	}
}
#endif
public OnW3HealthPickup(const String:output[], caller, activator, Float:delay)
{
	if(RaceDisabled)
		return;

	if(ValidPlayer(activator))
	{
		bSmittened[activator] = false;  // on spawn
	}
}
