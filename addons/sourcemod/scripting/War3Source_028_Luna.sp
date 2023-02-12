#include <war3source>

// bookmark
#if (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
	#endinput
#endif

#assert GGAMEMODE == MODE_WAR3SOURCE

#define RACE_ID_NUMBER 280

/**
 * File: War3Source_Luna.sp
 * Description: Luna Moonfang for War3Source!
 * Author(s): Jareth(wcs version) & DonRevan(war3source remake)
 */
//#pragma semicolon 1
//#include <sourcemod>
//#include "W3SIncs/War3Source_Interface"
//#include <sdktools>
#include "War3Source/include/revantools"
new thisRaceID;

bool HooksLoaded = false;
public void Load_Hooks()
{
	if(HooksLoaded) return;
	HooksLoaded = true;

	W3Hook(W3Hook_OnW3TakeDmgBullet, OnW3TakeDmgBullet);
	W3Hook(W3Hook_OnUltimateCommand, OnUltimateCommand);
}
public void UnLoad_Hooks()
{
	if(!HooksLoaded) return;
	HooksLoaded = false;

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

new String:beamsnd[]= "war3source/moonqueen/beam.mp3";

//skill is auto cast via chance
//new Float:LucentChance[5] = {0.00,0.05,0.11,0.22,0.30};
new LucentBeamMin[5] = {0, 3, 4, 5, 6};
new LucentBeamMax[5] = {0, 7, 8, 9, 10};

new Float:GlaiveRadius[5] = {0.0,250.0,300.0,350.0,400.0};
new Float:GlaiveChance = 0.22;
new GlaiveDamage[5] = {0,4,6,8,12};

new Float:BlessingRadius[5] = {0.0,160.0,200.0,240.0,280.0};
new BlessingIncrease[5] = {0,1,2,2,3};

new Float:EclipseRadius=500.0;
new EclipseAmount[5]= {0,4,6,8,10};

new SKILL_MOONBEAM,SKILL_BOUNCE,SKILL_AURA,ULT;
new LightModel;
//new XBeamSprite,CoreSprite,MoonSprite,BeamSprite,HaloSprite;
new XBeamSprite,CoreSprite,MoonSprite,HaloSprite;
//new BlueSprite;
new Handle:ultCooldownCvar = INVALID_HANDLE;
new AuraID;
public Plugin:myinfo =
{
	name = "War3Source Race - Luna Moonfang",
	author = "Jareth&DonRevan",
	description = "Luna Moonfang",
	version = "1.0",
	url = "www.wcs-lagerhaus.de"
};

public OnPluginStart()
{
	ultCooldownCvar=CreateConVar("war3_luna_ultimate_cooldown","20","Luna Moonfangs ultimate cooldown (ultimate)");
	//CreateTimer(3.0,CalcBlessing,_,TIMER_REPEAT);
	//LoadTranslations("w3s.race.luna.phrases");
}
public OnAllPluginsLoaded()
{
	War3_RaceOnPluginStart("luna");
}
public OnPluginEnd()
{
	if(LibraryExists("RaceClass"))
		War3_RaceOnPluginEnd("luna");
}

public OnMapStart()
{
	UnLoad_Hooks();
	//War3_PrecacheSound( beamsnd ); // originally disabled
	//BeamSprite=War3_PrecacheBeamSprite(); // originally disabled
	//HaloSprite=War3_PrecacheHaloSprite(); // orginally enabled
	//CoreSprite = PrecacheModel( "materials/sprites/physcannon_blueflare1.vmt" ); // orginally enabled
	//MoonSprite = PrecacheModel( "materials/sprites/physcannon_bluecore1b.vmt"); // orginally enabled
	//BlueSprite = PrecacheModel( "materials/sprites/physcannon_bluelight1.vmt" ); // originally disabled
	//XBeamSprite = PrecacheModel( "materials/sprites/XBeam2.vmt" ); // orginally enabled
	//LightModel = PrecacheModel( "models/effects/vol_light.mdl" ); // orginally enabled

	HaloSprite=War3_PrecacheHaloSprite();
#if (GGAMETYPE == GGAME_CSGO)
	CoreSprite = PrecacheModel( "effects/combinemuzzle1.vmt" );
	if (CoreSprite <= 0 ) LogError("Error PrecacheModel effects/combinemuzzle1.vmt");
	MoonSprite = PrecacheModel( "particle/particle_glow_01" );
	if (MoonSprite <= 0 ) LogError("Error PrecacheModel particle/particle_glow_01");
	XBeamSprite = PrecacheModel( "materials/sprites/physbeam.vmt" );
	if (XBeamSprite <= 0 ) LogError("Error PrecacheModel materials/sprites/physbeam.vmt");
	//PrecacheModel("particle/particle_flares/particle_flare_004");
	//LightModel = PrecacheModel( "models/Effects/vol_light.mdl" ); original
	LightModel = PrecacheModel( "models/effects/vol_light.mdl" ); // (capital E to e)
	if (LightModel <= 0 ) LogError("Error PrecacheModel models/effects/vol_light.mdl");
#else
	CoreSprite = PrecacheModel( "materials/sprites/physcannon_blueflare1.vmt" );
	if (CoreSprite <= 0 ) LogError("Error PrecacheModel effects/combinemuzzle1.vmt");
	MoonSprite = PrecacheModel( "materials/sprites/physcannon_bluecore1b.vmt");
	if (MoonSprite <= 0 ) LogError("Error PrecacheModel particle/particle_glow_01");
	//BlueSprite = PrecacheModel( "materials/sprites/physcannon_bluelight1.vmt" );
	XBeamSprite = PrecacheModel( "materials/sprites/XBeam2.vmt" );
	if (XBeamSprite <= 0 ) LogError("Error PrecacheModel materials/sprites/XBeam2.vmt");
	LightModel = PrecacheModel( "models/effects/vol_light.mdl" );
	if (LightModel <= 0 ) LogError("Error PrecacheModel models/effects/vol_light.mdl");
	//PrecacheModel("particle/fire.vmt");
#endif
}

public OnAddSound(sound_priority)
{
	if(sound_priority==PRIORITY_HIGH)
	{
		War3_AddSound("Luna Moonfang",beamsnd,CUSTOM_SOUND);
	}
}


public OnWar3LoadRaceOrItemOrdered2(num,reloadrace_id,String:shortname[])
{
	if(num==RACE_ID_NUMBER||(reloadrace_id>0&&StrEqual("luna",shortname,false)))
	{

		thisRaceID=War3_CreateNewRace("Luna Moonfang","luna",reloadrace_id,"Lucent Beam,Eclipse");
		SKILL_MOONBEAM=War3_AddRaceSkill(thisRaceID,"Lucent Beam","Luna concentrates on the moon`s energy and channels it forcefully to the surface, 3-7/4-8/5-9/6-10 dmg. Autocast. 3s cooldown.",false,4);
		SKILL_BOUNCE=War3_AddRaceSkill(thisRaceID,"Moon Glaive","Allows Luna to attack extra enemies with each Glaive attack.",false,4);
		SKILL_AURA=War3_AddRaceSkill(thisRaceID,"Lunar Blessing","Nearby ranged units gain the power of the moon. +1-4 damage",false,4);
		ULT=War3_AddRaceSkill(thisRaceID,"Eclipse","Calls to the moon`s magic, summoning a concentrated burst of Lucent Beams to damage targets around Luna. 4-10 beams.",true,4);
		War3_CreateRaceEnd(thisRaceID);
		AuraID=W3RegisterChangingDistanceAura("luna_blessing");
	}
}

//Purpose: Applies/Removes the Aura from player that actually changed from/to this race..
public OnRaceChanged(client,oldrace,newrace)
{
	if(newrace==thisRaceID)
	{
		new level=War3_GetSkillLevel(client,thisRaceID,SKILL_AURA);
		if(level>0){
			W3SetPlayerAura(AuraID,client,BlessingRadius[level],level);
		}
		else
		{
			W3RemovePlayerAura(AuraID,client);
		}
	}
	else
	{
		War3_SetBuff(client,bImmunitySkills,thisRaceID,false);
		W3RemovePlayerAura(AuraID,client);
	}
}

public void OnSkillLevelChanged(int client, int currentrace, int skill, int newskilllevel, int oldskilllevel)
{
	if(RaceDisabled)
		return;

	if(currentrace==thisRaceID)
	{
		if(skill==SKILL_AURA)
		{
			//Updates Lunar Blessing Aura Info...
			if(newskilllevel>0)
			{
				W3SetPlayerAura(AuraID,client,BlessingRadius[newskilllevel],newskilllevel);
			}
			else
			{
				W3RemovePlayerAura(AuraID,client);
			}
		}
	}
}

public OnW3PlayerAuraStateChanged(client,aura,bool:inAura,level,AuraStack,AuraOwner)
{
	if(RaceDisabled)
		return;

	//Is that our aura?
	if(aura==AuraID)
	{
		/*
		if(inAura>0)
		{
			new String:StrOwner[128];
			GetClientName(AuraOwner,StrOwner,sizeof(StrOwner));
			new String:Strclient[128];
			GetClientName(client,Strclient,sizeof(Strclient));
			DP("Client %s is in Aura - Number of Auras %d - Scout Aura Owner %s",Strclient,inAura,StrOwner);
		}
		else
		{
			new String:StrOwner[128];
			GetClientName(AuraOwner,StrOwner,sizeof(StrOwner));
			new String:Strclient[128];
			GetClientName(client,Strclient,sizeof(Strclient));
			DP("Client %s is Not in Aura - Number of Auras %d - Scout Aura Owner %s",Strclient,inAura,StrOwner);
		}*/

		//Yes, to let mod our damage done
		if(AuraStack>0)
		{
			new StackBuff=AuraStack*BlessingIncrease[level];
			War3_SetBuff(client,iDamageBonus,thisRaceID,StackBuff,AuraOwner);
			if(inAura && IsPlayerAlive(client)) {
				decl Float:client_pos[3];
				GetClientAbsOrigin(client,client_pos);
				TE_SetupGlowSprite(client_pos, LightModel, 2.0, 1.0, 255);
				War3_TE_SendToAll();
			}
		}
		else
		{
			War3_SetBuff(client,iDamageBonus,thisRaceID,0);
		}
	}
}

//public void OnWar3EventSpawn (int client)
//{
	//if(War3_GetRace(client)==thisRaceID) {
		//new skill_level = War3_GetSkillLevel( client, thisRaceID, SKILL_AURA );
		//if(skill_level>0)
		//CreateTimer( 0.1, Timer_LunaFX, client);
	//}
//}

public Action OnW3TakeDmgBullet(int victim, int attacker, float damage)
{
	if(RaceDisabled)
		return;

	if( IS_PLAYER( victim ) && IS_PLAYER( attacker ) && victim > 0 && attacker > 0 && attacker != victim )
	{
		new vteam = GetClientTeam( victim );
		new ateam = GetClientTeam( attacker );
		if( vteam != ateam )
		{
			new race_attacker = War3_GetRace( attacker );
			new skill_level = War3_GetSkillLevel( attacker, thisRaceID, SKILL_MOONBEAM );
			new skill_level2 = War3_GetSkillLevel( attacker, thisRaceID, SKILL_BOUNCE );
			if( race_attacker == thisRaceID &&!Hexed(attacker) && W3Chance(W3ChanceModifier(attacker))) //skill activation chance modifier; damage was out of control on pyro just like crypt lord's beetles - Dagothur 1/16/2013
			{
				// So that players' sentry does not proc this skill
				// Less chance to Proc for based on your class.
				//
#if (GGAMETYPE == GGAME_TF2)
				if(!W3IsOwnerSentry(attacker) && skill_level > 0 && SkillAvailable(attacker,thisRaceID,SKILL_MOONBEAM,false))
#else
				if(skill_level > 0 && SkillAvailable(attacker,thisRaceID,SKILL_MOONBEAM,false))
#endif
				{
					if(!W3HasImmunity( victim, Immunity_Skills ))
					{
						MoonBeamDamageAndEffect(victim, attacker, LucentBeamMin[skill_level], LucentBeamMax[skill_level]);
						/*		decl Float:start_pos[3];
						 decl Float:target_pos[3];
						 GetClientAbsOrigin(attacker,start_pos);
						 GetClientAbsOrigin(victim,target_pos);
						 target_pos[2]+=60.0;
						 start_pos[1]+=50.0;
						 TE_SetupBeamPoints(target_pos, start_pos, BlueSprite, HaloSprite, 0, 100, 2.0, 1.0, 3.0, 0, 0.0, {255,0,255,255}, 10);
						 TE_SendToAll();
						 TE_SetupBeamPoints(target_pos, start_pos, BlueSprite, HaloSprite, 0, 100, 2.0, 3.0, 5.0, 0, 0.0, {128,0,255,255}, 30);
						 TE_SendToAll(2.0);
						 //TE_SetupBeamRingPoint(const Float:center[3], Float:Start_Radius, Float:End_Radius, ModelIndex(Precache), HaloIndex(Precache), StartFrame, FrameRate, Float:Life, Float:Width, Float:Amplitude, const Color[4], Speed, Flags);
						 TE_SetupBeamRingPoint(target_pos, 20.0, 90.0, XBeamSprite, HaloSprite, 0, 1, 1.0, 90.0, 0.0, {128,0,255,255}, 10, 0);
						 TE_SendToAll(2.0);
						 TE_SetupBeamPoints(target_pos, start_pos, BlueSprite, HaloSprite, 0, 100, 2.0, 5.0, 7.0, 0, 0.0, {128,0,255,255}, 70);
						 TE_SendToAll(4.0);
						 TE_SetupBeamPoints(target_pos, start_pos, BlueSprite, HaloSprite, 0, 100, 2.0, 6.0, 8.0, 0, 0.0, {128,0,255,255}, 170);
						 TE_SendToAll(9.0);
						 */
						War3_CooldownMGR(attacker,3.0,thisRaceID,SKILL_MOONBEAM,true,false);
					}
					else
					{
						War3_NotifyPlayerImmuneFromSkill(attacker, victim, SKILL_MOONBEAM);
					}
				}

				if( skill_level2 > 0 && W3Chance(GlaiveChance) )
				{
					new lunadmg = GlaiveDamage[skill_level2];
					new Float:sparkdir[3] = {0.0,0.0,90.0};
					new Float:maxdist = GlaiveRadius[skill_level2];
					decl Float:start_pos[3];
					decl Float:end_pos2[3];
					GetClientAbsOrigin(victim,start_pos);
					GetClientAbsOrigin(victim,end_pos2);
					end_pos2[2]+=1000.0;
					//
					//TE_SetupBeamPoints(start_pos,end_pos2,XBeamSprite, HaloSprite, 0, 1, Float:2.0,  Float:3.0, 3.0, 1, 0.0, {255,255,255,255}, 0);
					//TE_SendToAll(0.0);
					//TE_SetupBeamRingPoint(start_pos, 20.0, maxdist+10.0, XBeamSprite, HaloSprite, 0, 1, 1.0, 90.0, 0.0, {128,0,255,255}, 10, 0);
					//TE_SendToAll(2.0);
					for (new i = 1; i <= MaxClients; i++)
					{
						if(ValidPlayer(i,true) && GetClientTeam(i) != GetClientTeam(attacker))
						{
							//this was checking for ward immunity instead of skill immunity - Dagothur 1/16/2013
							decl Float:TargetPos[3];
							GetClientAbsOrigin(i, TargetPos);
							if (GetVectorDistance(start_pos, TargetPos) <= maxdist)
							{
								if(!W3HasImmunity(i,Immunity_Skills))
								{
									TE_SetupSparks(TargetPos, sparkdir, 90, 90);
									War3_TE_SendToAll();
									if(War3_DealDamage( i, lunadmg, attacker, DMG_FALL, "moonglaive" ))
									{
										War3_NotifyPlayerTookDamageFromSkill(i, attacker, lunadmg, SKILL_BOUNCE);
									}
									//W3PrintSkillDmgConsole(i,attacker, War3_GetWar3DamageDealt(),SKILL_BOUNCE);
									//PrintHintText(i,"You have been hit by a Moon Glaive!");
								}
								else
								{
									War3_NotifyPlayerImmuneFromSkill(attacker, victim, SKILL_BOUNCE);
								}
							}
						}
					}
				}
			}
		}
	}
}

new EclipseOwner[MAXPLAYERSCUSTOM];
new EclipseAmountLeft[MAXPLAYERSCUSTOM];
public void OnUltimateCommand(int client, int race, bool pressed, bool bypass)
{
	if(RaceDisabled)
		return;

	if( race == thisRaceID && pressed && IsPlayerAlive( client ) && !Silenced( client ) )
	{
		new level = War3_GetSkillLevel( client, race, ULT );
		if( level > 0)
		{
			if( bypass || War3_SkillNotInCooldown( client, thisRaceID, ULT, true ) )
			{
				EclipseAmountLeft[client]=EclipseAmount[level];

				CreateTimer( 0.15, Timer_EclipseLoop, client);

				decl Float:StartPos[3];
				GetClientAbsOrigin(client, StartPos);
				StartPos[2]+=400.0;
				TE_SetupGlowSprite(StartPos, MoonSprite, 5.0, 3.0, 255);
				War3_TE_SendToAll();

				/*
				 es est_Effect_06 #a .9 sprites/physcannon_blueflare1.vmt server_var(vector2) server_var(vector1) 100 3 16 8 10 0 128 0 255 255 170
				 es est_effect_08 #a .3 sprites/XBeam2.vmt server_var(vector1) 200 90 3 3 100 400 0 128 0 255 255 10 1
				 es est_Effect_06 #a 0 sprites/physcannon_blueflare1.vmt server_var(vector2) server_var(vector1) 100 .3 17 11 10 10 228 228 228 255 100
				 es est_effect_08 #a 0 sprites/physcannon_blueflare1.vmt server_var(vector1) 5000 40 3 5 90 400 0 255 255 255 255 10 1
				 es est_effect_08 #a 0 sprites/physcannon_blueflare1.vmt server_var(vector1) 40 5000 3 5 90 400 0 255 255 255 255 10 1
				 es est_effect_08 #a 0 sprites/physcannon_blueflare1.vmt server_var(vector1) 400 500 3 5 90 400 0 255 255 255 255 10 1

				 est_Effect_08 <player Filter> <delay> <model> <center 'X Y Z'> <Start Radius> <End Radius> <framerate> <life> <width> <spread> <amplitude> <R> <G> <B> <A> <speed> <flags>
				 */
				TE_SetupBeamRingPoint(StartPos, 1000.0, 40.0, CoreSprite, HaloSprite, 0, 3, 5.0, 90.0, 0.0, {255,255,255,255}, 10, 0);
				War3_TE_SendToAll();
				TE_SetupBeamRingPoint(StartPos, 40.0, 1000.0, CoreSprite, HaloSprite, 0, 3, 5.0, 90.0, 0.0, {255,255,255,255}, 10, 0);
				War3_TE_SendToAll();
				TE_SetupBeamRingPoint(StartPos, 400.0, 500.0, CoreSprite, HaloSprite, 0, 3, 5.0, 90.0, 0.0, {255,255,255,255}, 10, 0);
				War3_TE_SendToAll();
				TE_SetupBeamRingPoint(StartPos, 200.0, 90.0, XBeamSprite, HaloSprite, 0, 3, 3.0, 100.0, 0.0, {128,0,255,255}, 10, 0);
				War3_TE_SendToAll(3.0);

				War3_CooldownMGR(client,GetConVarFloat(ultCooldownCvar),thisRaceID,ULT,true,true);
			}
		}
		else
		W3MsgUltNotLeveled( client );
	}
}

// Old Aura - replaced with new aura engine(now a damage aura instead of a healing wave)
/*public W3DoLunarBlessing(client)
 {
 //assuming client exists and has this race
 new skill = War3_GetSkillLevel(client,thisRaceID,SKILL_AURA);
 if(skill>0&&!Hexed(client,false))
 {
 new HealerTeam = GetClientTeam(client);
 new Float:HealerPos[3];
 GetClientAbsOrigin(client,HealerPos);
 new Float:VecPos[3];

 for(new i=1;i<=MaxClients;i++)
 {
 if(ValidPlayer(i,true)&&GetClientTeam(i)==HealerTeam)
 {
 GetClientAbsOrigin(i,VecPos);
 if(GetVectorDistance(HealerPos,VecPos)<=BlessingRadius)
 {
 War3_HealToMaxHP(i,skill);
 //VecPos[2]+=80.0;
 TE_SetupGlowSprite(VecPos, LightModel, 2.0, 1.0, 255);
 TE_SendToAll();
 }
 }
 }
 }
 }

 public Action:CalcBlessing(Handle:timer,any:userid)
 {
 if(thisRaceID>0)
 for(new i=1;i<=MaxClients;i++)
 {
 if(ValidPlayer(i,true))
 {
 if(War3_GetRace(i)==thisRaceID)
 {
 W3DoLunarBlessing(i);
 }
 }
 }
 }

public Action:Timer_LunaFX( Handle:timer, any:client )
{
	new Float:Angles[3] = {90.0,90.0,90.0};
	CreateParticles(client,false,5.0,Angles,15.0,15.0,25.0,15.0,"particle/fire.vmt","128 0 255","100","900","5","200");
	decl Float:client_pos[3];
	GetClientAbsOrigin(client,client_pos);
	client_pos[2]+=35.0;
	TE_SetupBeamRingPoint(client_pos,80.0,300.0,BeamSprite,HaloSprite,0,20,5.0,80.0,1.0, {128,0,255,255},10,0);
	TE_SendToAll();
}*/

public Action:Timer_EclipseLoop( Handle:timer, any:attacker )
{

	EclipseAmountLeft[attacker]--;
	if( ValidPlayer(attacker,true))
	{
		//get list of players
		new playerlist[MAXPLAYERSCUSTOM];
		new playercount=0;
		new teamattacker=GetClientTeam(attacker);
		decl Float:AttackerPos[3];
		GetClientAbsOrigin(attacker,AttackerPos);
		decl Float:TargetPos[3];
		for (new i = 1; i <= MaxClients; i++) {
#if (GGAMETYPE == GGAME_TF2)
			if(ValidPlayer(i,true)&& teamattacker != GetClientTeam(i) && teamattacker!=GetApparentTeam(i) && !Spying(i))
#else
			if(ValidPlayer(i,true)&& teamattacker != GetClientTeam(i))
#endif
			{
				GetClientAbsOrigin(i, TargetPos);
				if (GetVectorDistance(AttackerPos, TargetPos) <= EclipseRadius)
				{
						playerlist[playercount]=i;
						playercount++;
				}
			}
		}
		//DP("%d",playercount);
		if(playercount > 0) { //get randomplayer and deal damage
			new index = GetRandomInt(0, playercount - 1);
			new victim = playerlist[index];

			if(!W3HasImmunity( victim, Immunity_Ultimates ))
			{
				// Use level 4 damage values for the ultimate
				MoonBeamDamageAndEffect(victim, attacker, LucentBeamMin[4], LucentBeamMax[4]);
				W3FlashScreen(victim, RGBA_COLOR_WHITE);
			}
			else
			{
				War3_NotifyPlayerImmuneFromSkill(attacker, victim, ULT);
			}
		}
		if(EclipseAmountLeft[attacker] > 0) {
			CreateTimer(0.5, Timer_EclipseLoop, any:attacker);
		}

	}
}

public Action:Timer_EclipseStop(Handle:timer, any:victim)
{
	EclipseOwner[victim] = -1;
}

MoonBeamDamageAndEffect(victim, attacker, min, max) {
	decl Float:start_pos[3];
	decl Float:end_pos2[3];

	GetClientAbsOrigin(victim, start_pos);
	GetClientAbsOrigin(victim, end_pos2);

	end_pos2[2] += 10000.0;
	//TE_SetupBeamPoints(const Float:start[3], const Float:end[3], ModelIndex, HaloIndex, StartFrame, FrameRate, Float:Life, Float:Width, Float:EndWidth, FadeLength, Float:Amplitude, const Color[4], Speed)
	TE_SetupBeamPoints(start_pos, end_pos2, XBeamSprite, HaloSprite, 0, 30, Float:1.0, Float:20.0, 20.0, 0, 0.0, {255,255,255,255}, 300);
	War3_TE_SendToAll(0.0);

	//TE_SetupBeamRingPoint(const Float:center[3], Float:Start_Radius, Float:End_Radius, ModelIndex, HaloIndex, StartFrame, FrameRate, Float:Life, Float:Width, Float:Amplitude, const Color[4], Speed, Flags)
	TE_SetupBeamRingPoint(start_pos, 20.0, 99.0, XBeamSprite, HaloSprite, 0, 1, 0.5, 30.0, 0.0, {255,255,255,255}, 10, 0);
	War3_TE_SendToAll(0.3);

	if(War3_DealDamage(victim, GetRandomInt(min, max), attacker ,DMG_FALL, "lucentbeam"))
	{
		//W3PrintSkillDmgHintConsole(victim, attacker, War3_GetWar3DamageDealt(), SKILL_MOONBEAM);
		War3_NotifyPlayerTookDamageFromSkill(victim, attacker, War3_GetWar3DamageDealt(), SKILL_MOONBEAM);
	}

	War3_EmitSoundToAll(beamsnd, victim);
	War3_EmitSoundToAll(beamsnd, attacker);

}
