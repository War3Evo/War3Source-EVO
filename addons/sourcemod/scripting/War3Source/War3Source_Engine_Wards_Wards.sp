// War3Source_Engine_Wards_Wards.sp

//#assert GGAMEMODE == MODE_WAR3SOURCE

/*
public Plugin:myinfo =
{
	name = "War3Source - Warcraft Extended - Generic ward skills",
	author = "War3Source Team",
	description = "Default ward implementations"
};*/

#if GGAMETYPE == GGAME_TF2
new String:jarateSound0[]="vo/halloween_merasmus/sf12_wheel_jarate01.wav";
new String:jarateSound1[]="vo/halloween_merasmus/sf12_wheel_jarate02.wav";
new String:jarateSound2[]="vo/halloween_merasmus/sf12_wheel_jarate03.wav";
new String:jarateSound3[]="vo/halloween_merasmus/sf12_wheel_jarate04.wav";
new String:jarateSound4[]="vo/halloween_merasmus/sf12_wheel_jarate05.wav";
#endif
new String:wardZap1[]="ambient/energy/zap1.wav";
new String:wardZap2[]="ambient/energy/zap2.wav";
//new String:wardDamageSound[]="war3source/thunder_clap.wav";
new String:wardDamageSound[]="npc/scanner/scanner_electric2.wav";

new Float:LastWardSound[MAXPLAYERSCUSTOM];
new Float:War3Source_Engine_Wards_Wards_MessageTimer[MAXPLAYERSCUSTOM];
//                     client           ward owner

public War3Source_Engine_Wards_Wards_OnPluginStart()
{
	RegAdminCmd("sm_loadwards", loadwards, ADMFLAG_ROOT, "");
}

public War3Source_Engine_Wards_Wards_OnAddSound(sound_priority)
{
	if(sound_priority==PRIORITY_TOP)
	{
#if GGAMETYPE == GGAME_TF2
		War3_AddSound(jarateSound0,STOCK_SOUND);
		War3_AddSound(jarateSound1,STOCK_SOUND);
		War3_AddSound(jarateSound2,STOCK_SOUND);
		War3_AddSound(jarateSound3,STOCK_SOUND);
		War3_AddSound(jarateSound4,STOCK_SOUND);
#endif
		War3_AddSound(wardDamageSound,STOCK_SOUND);
		War3_AddSound(wardZap1,STOCK_SOUND);
		War3_AddSound(wardZap2,STOCK_SOUND);
	}
}

enum {
	BEHAVIOR_DAMAGE=0,
	BEHAVIOR_HEAL,
	BEHAVIOR_SLOW,
#if GGAMETYPE == GGAME_TF2
	BEHAVIOR_JARATE,
#endif
	BEHAVIOR_ZAP,
	BEHAVIOR_SENTRY_IMMUNITY,
	BEHAVIOR_LAST, // not a real ward behavior, just for indexing
}

new BehaviorIndex[BEHAVIOR_LAST];

new HasWardID[MAXPLAYERSCUSTOM][BEHAVIOR_LAST];

public War3Source_Engine_Wards_Wards_OnWar3PlayerAuthed(client)
{
	LastWardSound[client]=0.0;
	War3Source_Engine_Wards_Wards_MessageTimer[client]=0.0;
	HasWardID[client][BEHAVIOR_SLOW]=-1;
	HasWardID[client][BEHAVIOR_SENTRY_IMMUNITY]=-1;
}

public OnWar3LoadRaceOrItemOrdered(num)
{
	if(num==0)
	{
		BehaviorIndex[BEHAVIOR_DAMAGE] = War3_CreateWardBehavior("damage", "Damage ward", "Deals damage to targets");
		BehaviorIndex[BEHAVIOR_HEAL] = War3_CreateWardBehavior("heal", "Healing ward", "Heals targets");
		BehaviorIndex[BEHAVIOR_SLOW] = War3_CreateWardBehavior("disrupt", "Disruptive ward", "Disrupt players");
#if GGAMETYPE == GGAME_TF2
		BehaviorIndex[BEHAVIOR_JARATE] = War3_CreateWardBehavior("jarate", "Jarate ward", "Jarate players");
		BehaviorIndex[BEHAVIOR_SENTRY_IMMUNITY] = War3_CreateWardBehavior("simmune", "Sentry Immunity Ward", "Gives Immunity to Sentry Detection");
#endif
		BehaviorIndex[BEHAVIOR_ZAP] = War3_CreateWardBehavior("zap", "Zap ward", "Zap players");
	}
}
#if GGAMETYPE == GGAME_TF2
public JarateBomber( victim, level, Float:duration )
{
	if( level > 0)
	{
		new Float:radius = 300.0;
		new our_team = GetClientTeam( victim );
		new Float:victim_location[3];
		new Float:jaratecount = 0.0;

		GetClientAbsOrigin( victim, victim_location );

		//TE_SetupExplosion( client_location, ExplosionModel, 10.0, 1, 0, RoundToFloor( radius ), 160 );
		//TE_SendToAll();

		new Float:location_check[3];
		for( new x = 1; x <= MaxClients; x++ )
		{
			if(ValidPlayer( x, true ))
			{
				new team = GetClientTeam( x );
				if( team == our_team )
				{
					GetClientAbsOrigin( x, location_check );
					new Float:distance = GetVectorDistance( victim_location, location_check );
					if( distance < radius )
					{
						if( jaratecount<=duration && !W3HasImmunity( x, Immunity_Wards ) & !TF2_IsPlayerInCondition(x, TFCond_Jarated) )
						{
							jaratecount++;
							TF2_AddCondition( x, TFCond_Jarated, duration );
							if(LastWardSound[x]<GetGameTime()-1)
							{
								new random = GetRandomInt(0,4);
								if(random==0){
									War3_EmitSoundToAll(jarateSound0,x);
								}else if(random==1){
									War3_EmitSoundToAll(jarateSound1,x);
								}else if(random==2){
									War3_EmitSoundToAll(jarateSound2,x);
								}else if(random==3){
									War3_EmitSoundToAll(jarateSound3,x);
								}else{
									War3_EmitSoundToAll(jarateSound4,x);
								}
								LastWardSound[victim]=GetGameTime();
							}
							new Tcolor[4]=RGBA_COLOR_YELLOW;
							Tcolor[3]=50; // more dark yellow flash
							W3FlashScreen( x, Tcolor );
							PrintCenterText(x,"Jarated by an enemy yellow ward! -->> Say \"antiwards\" to be immune next time!");
						}
						else
						{
							//PrintToConsole( victim, "Could not jarate %s due to immunity", client, x );
							// wont work .. no skill id?
							//War3_NotifyPlayerImmuneFromSkill(victim, x, skill);
						}
					}
				}
			}
		}
	}
}
#endif
/*
public Action:Slow_Turtled_Disable(Handle:timer, Handle:datapack)
{
	ResetPack(datapack);
	new client = GetClientOfUserId(ReadPackCell(datapack));
	new RaceID = ReadPackCell(datapack);
	if(ValidPlayer(client))
	{
		SetBuff(client,fSlow,RaceID,1.0);
		SetBuff(client,fMaxSpeed,RaceID,1.0);
	}
	return Plugin_Continue;
}*/


public OnWardPulse(wardindex, behavior, wardtarget)
{
#if GGAMETYPE == GGAME_TF2
	if(behavior != BehaviorIndex[BEHAVIOR_DAMAGE]
	&& behavior != BehaviorIndex[BEHAVIOR_HEAL]
	&& behavior != BehaviorIndex[BEHAVIOR_SLOW]
	&& behavior != BehaviorIndex[BEHAVIOR_SENTRY_IMMUNITY]
	&& behavior != BehaviorIndex[BEHAVIOR_JARATE]
	&& behavior != BehaviorIndex[BEHAVIOR_ZAP])
	{
		return;
	}
#else
	if(behavior != BehaviorIndex[BEHAVIOR_DAMAGE]
	&& behavior != BehaviorIndex[BEHAVIOR_HEAL]
	&& behavior != BehaviorIndex[BEHAVIOR_SLOW]
	&& behavior != BehaviorIndex[BEHAVIOR_ZAP])
	{
		return;
	}
#endif

	new beamcolor[4];
	new team = GetClientTeam(War3_GetWardOwner(wardindex));

	if(War3_GetWardUseDefaultColor(wardindex))
	{
		if (behavior == BehaviorIndex[BEHAVIOR_DAMAGE])
		{
			//beamcolor = team == TEAM_BLUE ?  {0, 0, 255, 255} : {255, 0, 0, 255};
			beamcolor = {255, 0, 0, 255};
		}
		else if (behavior == BehaviorIndex[BEHAVIOR_HEAL])
		{
			//beamcolor = team == TEAM_BLUE ? {0, 255, 128, 255} : {128, 255, 0, 255};
			beamcolor = {0, 255, 128, 255};
		}
		else if (behavior == BehaviorIndex[BEHAVIOR_SLOW])
		{
			//beamcolor = team == TEAM_BLUE ? {0, 200, 63, 255} : {255, 89, 246, 255};
			//beamcolor = team == TEAM_BLUE ? {0, 200, 63, 255} : {255, 89, 246, 255};
			beamcolor = {255, 89, 246, 255};
		}
#if GGAMETYPE == GGAME_TF2
		else if (behavior == BehaviorIndex[BEHAVIOR_SENTRY_IMMUNITY])
		{
			beamcolor = {255, 128, 0, 255}; // orange?
		}
		else if (behavior == BehaviorIndex[BEHAVIOR_JARATE])
		{
			//beamcolor = team == TEAM_BLUE ? {255, 255, 102, 255} : {255, 255, 102, 255};
			beamcolor = {255, 255, 102, 255};
		}
#endif
		else if (behavior == BehaviorIndex[BEHAVIOR_ZAP])
		{
			//beamcolor = team == TEAM_BLUE ? {255, 255, 102, 255} : {255, 255, 102, 255};
			beamcolor = {255,000,255,255};
		}

	}
	else
	{
		team == TEAM_BLUE ? War3_GetWardColor2(wardindex, beamcolor) : War3_GetWardColor3(wardindex, beamcolor);
	}

	if (behavior == BehaviorIndex[BEHAVIOR_HEAL])
	{
		War3_WardVisualEffect(wardindex, beamcolor, team, wardtarget, true);
	}
	else if (behavior == BehaviorIndex[BEHAVIOR_SENTRY_IMMUNITY])
	{
		War3_WardVisualEffect(wardindex, beamcolor, team, wardtarget, true);
	}
	else if (behavior == BehaviorIndex[BEHAVIOR_ZAP])
	{
		War3_WardZapVisualEffect(wardindex, beamcolor, team, wardtarget);
	}
	else
	{
		War3_WardVisualEffect(wardindex, beamcolor, team, wardtarget);
	}
}

public OnWardTrigger(wardindex, victim, owner, behavior)
{
	if (behavior == BehaviorIndex[BEHAVIOR_DAMAGE])
	{
		if(W3HasImmunity(victim, Immunity_Wards))
		{
			W3MsgSkillBlocked(victim, _, "Wards");
		}
		else
		{
			//W3Hint(victim,HINT_DMG_RCVD,1.0,"You're being damaged! QUICK -->> Say \"antiwards\" or move!");
			if(War3Source_Engine_Wards_Wards_MessageTimer[victim]<(GetGameTime()-3.0))
			{
				War3_ChatMessage(victim,"{default}You're being damaged! QUICK -->> Say \"{green}antiwards{default}\" or move!");
				War3Source_Engine_Wards_Wards_MessageTimer[victim]=GetGameTime();
			}

			decl data[MAXWARDDATA];
			War3_GetWardData(wardindex, data);
			new damage = data[GetSkillLevel(owner, GetRace(owner), War3_GetWardSkill(wardindex))];

#if SHOPMENU3 == MODE_ENABLED
			// Adjust damage via shopmenu3 item TEARDROP_TOURMALINE
			new itemID=War3_GetItem3IdByShortname("teardptour");
			if(itemID>-1)
			{
				if(War3_GetOwnsItem3(owner,GetRace(owner),itemID))
				{
					//damage+=War3_GetTotalItemLevels(owner,OwnerRace,itemID);
					damage+=War3_GetItemLevel(owner,GetRace(owner),itemID);
				}
			}
#endif
			new Tcolor[4]=RGBA_COLOR_RED;
			Tcolor[3]=50;

			W3FlashScreen(owner,Tcolor);
			W3FlashScreen(victim,Tcolor);

			War3_WardVisualEffect(wardindex, {255, 0, 0, 255}, 0, WARD_TARGET_ENEMYS);

			War3_NotifyPlayerTookDamageFromSkill(victim, owner, damage, War3_GetWardSkill(wardindex));

			if(DealDamage(victim, damage, owner, _, "weapon_wards"))
			{
#if GGAMETYPE == GGAME_TF2
				War3_ShowHealthLostParticle(victim);
#endif
				if(LastWardSound[victim]<(GetGameTime()-0.5))
				{
					War3_EmitSoundToAll(wardDamageSound,victim,SNDCHAN_WEAPON);
					LastWardSound[victim]=GetGameTime();
				}
			}
		}
	}

	else if (behavior == BehaviorIndex[BEHAVIOR_HEAL])
	{
		decl data[MAXWARDDATA];
		War3_GetWardData(wardindex, data);

		new healAmount = data[GetSkillLevel(owner, GetRace(owner), War3_GetWardSkill(wardindex))];

#if SHOPMENU3 == MODE_ENABLED
		// Adjust heal rate via shopmenu3 item SOLID_ZIRCON
		new itemID=War3_GetItem3IdByShortname("szircon");
		if(itemID>-1)
		{
			if(War3_GetOwnsItem3(owner,GetRace(owner),itemID))
			{
				//damage+=War3_GetTotalItemLevels(owner,OwnerRace,itemID);
				healAmount+=War3_GetItemLevel(owner,GetRace(owner),itemID);
			}
		}
#endif

		if (War3_HealToMaxHP(victim, healAmount))
		{
			new Tcolor[4]=RGBA_COLOR_GREEN;
			Tcolor[3]=40;
			W3FlashScreen(victim,Tcolor);
#if GGAMETYPE == GGAME_TF2
			War3_ShowHealthGainedParticle(victim);
			War3_TFHealingEvent(victim, healAmount);
#endif
			new iiMaxHP=War3_GetMaxHP(victim);
			new iHealth=GetClientHealth(victim);
			new iQuarterHealth=RoundToFloor(FloatMul(float(iiMaxHP),0.33));
			if(iHealth<iQuarterHealth)
			{
				War3_WardVisualEffect(wardindex, {255, 0, 0, 125}, 0, WARD_TARGET_NOBODY, false);
			} else if(iHealth<(iQuarterHealth*2))
			{
				War3_WardVisualEffect(wardindex, {255, 255, 102, 125}, 0, WARD_TARGET_NOBODY, false);
			}
			else if(iHealth<iiMaxHP)
			{
				War3_WardVisualEffect(wardindex, {0, 255, 128, 125}, 0, WARD_TARGET_NOBODY, false);
			}
		}
	}

	else if (behavior == BehaviorIndex[BEHAVIOR_SLOW])
	{
		if(W3HasImmunity(victim, Immunity_Wards))
		{
			W3MsgSkillBlocked(victim, _, "Wards");
		}
		else
		{
			if(War3Source_Engine_Wards_Wards_MessageTimer[victim]<(GetGameTime()-3.0))
			{
				War3_ChatMessage(victim,"{default}You're being disrupted! QUICK -->> Say \"{green}antiwards{default}\" or move!");
				W3Hint(victim,HINT_DMG_RCVD,1.0,"You're being disrupted! QUICK -->> Say \"antiwards\" or move!");
				War3Source_Engine_Wards_Wards_MessageTimer[victim]=GetGameTime();
			}
			decl Float:data[MAXWARDDATA];
			War3_GetWardData(wardindex, data);

			new Tcolor[4]=RGBA_COLOR_BLUE;
			Tcolor[3]=50;
			W3FlashScreen(victim,Tcolor);

			new wardskill = War3_GetWardSkill(wardindex);
			new Float:SlowAmount = Float:data[GetSkillLevel(owner, GetRace(owner), wardskill)];

			// do actual slowing
			SetBuff(victim,fSlow,GetRace(owner),SlowAmount);
			War3_WardVisualEffect(wardindex, {255, 89, 246, 255}, 0, WARD_TARGET_ENEMYS);

			HasWardID[victim][BEHAVIOR_SLOW]=wardindex;

			//new Handle:pack;
			//CreateDataTimer(0.1,Slow_Turtled_Disable,pack);
			//WritePackCell(pack, GetClientUserId(victim));
			//WritePackCell(pack, War3_GetRace(owner));

			//new Handle:pack2;
			//CreateDataTimer(5.0,Slow_Turtled_Disable,pack2);
			//WritePackCell(pack2, GetClientUserId(victim));
			//WritePackCell(pack2, War3_GetRace(owner));
		}
	}
#if GGAMETYPE == GGAME_TF2
	else if (behavior == BehaviorIndex[BEHAVIOR_SENTRY_IMMUNITY])
	{
		if(W3HasImmunity(victim, Immunity_Wards))
		{
			W3MsgSkillBlocked(victim, _, "Wards");
		}
		else
		{
			if(War3Source_Engine_Wards_Wards_MessageTimer[victim]<(GetGameTime()-3.0))
			{
				War3_ChatMessage(victim,"{default}This ward makes you immune to Sentry Detection.");
				W3Hint(victim,HINT_DMG_RCVD,1.0,"Sentry Immunity On");
				War3Source_Engine_Wards_Wards_MessageTimer[victim]=GetGameTime();
			}
			//decl Float:data[MAXWARDDATA];
			//War3_GetWardData(wardindex, data);

			new Tcolor[4]=RGBA_COLOR_ORANGE;
			Tcolor[3]=50;
			W3FlashScreen(victim,Tcolor);

			//new wardskill = War3_GetWardSkill(wardindex);
			//new Float:SlowAmount = Float:data[War3_GetSkillLevel(owner, War3_GetRace(owner), wardskill)];

			// do actual immunity
			new flags = GetEntityFlags(victim)|FL_NOTARGET;
			SetEntityFlags(victim, flags);

			War3_WardVisualEffect(wardindex, {255, 128, 0, 255}, 0, WARD_TARGET_ALLIES, true);

			HasWardID[victim][BEHAVIOR_SENTRY_IMMUNITY]=wardindex;

			//new Handle:pack;
			//CreateDataTimer(0.1,Slow_Turtled_Disable,pack);
			//WritePackCell(pack, GetClientUserId(victim));
			//WritePackCell(pack, War3_GetRace(owner));

			//new Handle:pack2;
			//CreateDataTimer(5.0,Slow_Turtled_Disable,pack2);
			//WritePackCell(pack2, GetClientUserId(victim));
			//WritePackCell(pack2, War3_GetRace(owner));
		}
	}
	else if (behavior == BehaviorIndex[BEHAVIOR_JARATE])
	{
		if(W3HasImmunity(victim, Immunity_Wards))
		{
			W3MsgSkillBlocked(victim, _, "Wards");
		}
		else
		{
			decl Float:data[MAXWARDDATA];
			War3_GetWardData(wardindex, data);

			new Tcolor[4]=RGBA_COLOR_YELLOW;
			Tcolor[3]=50;
			W3FlashScreen(owner,Tcolor);

			if(War3Source_Engine_Wards_Wards_MessageTimer[victim]<(GetGameTime()-3.0))
			{
				W3Hint(victim,HINT_DMG_RCVD,1.0,"You're being jarate! QUICK -->> Say \"antiwards\" or move!");
				War3Source_Engine_Wards_Wards_MessageTimer[victim]=GetGameTime();
			}
			new wardskill = War3_GetWardSkill(wardindex);
			new Float:Duration = Float:data[GetSkillLevel(owner, GetRace(owner), wardskill)];

			// do actual stuff
			JarateBomber( victim, GetSkillLevel(owner, GetRace(owner), wardskill), Duration );
			War3_WardVisualEffect(wardindex, {255, 255, 102, 255}, 0, WARD_TARGET_ENEMYS);
		}
	}
#endif
	else if (behavior == BehaviorIndex[BEHAVIOR_ZAP])
	{
		if(W3HasImmunity(victim, Immunity_Wards))
		{
			W3MsgSkillBlocked(victim, _, "Wards");
		}
		else
		{
			if(War3Source_Engine_Wards_Wards_MessageTimer[victim]<(GetGameTime()-3.0))
			{
				War3_ChatMessage(victim,"{default}You're being zapped! QUICK -->> Say \"{green}antiwards{default}\" or move!");
				War3Source_Engine_Wards_Wards_MessageTimer[victim]=GetGameTime();
			}

			decl data[MAXWARDDATA];
			War3_GetWardData(wardindex, data);
			new damage = data[GetSkillLevel(owner, GetRace(owner), War3_GetWardSkill(wardindex))];

#if SHOPMENU3 == MODE_ENABLED
			// Adjust damage via shopmenu3 item TEARDROP_TOURMALINE
			new itemID=War3_GetItem3IdByShortname("teardptour");
			if(itemID>-1)
			{
				if(War3_GetOwnsItem3(owner,GetRace(owner),itemID))
				{
					//damage+=War3_GetTotalItemLevels(owner,OwnerRace,itemID);
					damage+=War3_GetItemLevel(owner,GetRace(owner),itemID);
				}
			}
#endif

			new Tcolor[4]=RGBA_COLOR_BLUE;
			Tcolor[3]=25;

			W3FlashScreen(owner,Tcolor);
			Tcolor=RGBA_COLOR_RED;
			Tcolor[3]=40;
			W3FlashScreen(victim,Tcolor);

			new team = GetClientTeam(owner);

			War3_WardZapVisualEffect(wardindex, {255,000,255,255}, team, WARD_TARGET_ENEMYS, true, victim);

			War3_NotifyPlayerTookDamageFromSkill(victim, owner, damage, War3_GetWardSkill(wardindex));

			if(DealDamage(victim, damage, owner, _, "weapon_wards"))
			{
#if GGAMETYPE == GGAME_TF2
				War3_ShowHealthLostParticle(victim);
#endif
				if(LastWardSound[victim]<(GetGameTime()-0.2))
				{
					new random = GetRandomInt(0,1);
					if(random==0){
						War3_EmitSoundToAll(wardZap1,victim,SNDCHAN_WEAPON);
					}else {
						War3_EmitSoundToAll(wardZap1,victim,SNDCHAN_WEAPON);
					}
					LastWardSound[victim]=GetGameTime();
				}
			}
		}
	}

}
//public OnWar3EventSpawn(client)
public War3Source_Engine_Wards_Wards_OnWar3EventDeath(victim, attacker)
{
	for(new irace=1;irace<=internal_GetRacesLoaded();irace++)
	{
		HasWardID[victim][BEHAVIOR_SENTRY_IMMUNITY]=-1;
		HasWardID[victim][BEHAVIOR_SLOW]=-1;
		SetBuff(victim,fSlow,irace,1.0);
		SetBuff(victim,fMaxSpeed,irace,1.0);
		new flags = GetEntityFlags(victim)&~FL_NOTARGET;
		SetEntityFlags(victim, flags);
	}
}
public OnWardExpire(wardindex, owner, behaviorID)
{
	for(new victim=1;victim<=MaxClients;victim++)
	{
		if(ValidPlayer(victim) && (HasWardID[victim][BEHAVIOR_SLOW]>-1||HasWardID[victim][BEHAVIOR_SENTRY_IMMUNITY]>-1))
		{
			if(HasWardID[victim][BEHAVIOR_SLOW]==wardindex && behaviorID==BehaviorIndex[BEHAVIOR_SLOW])
			{
				// Remove Slow and Remove Ward ID
				HasWardID[victim][BEHAVIOR_SLOW]=-1;
				SetBuff(victim,fSlow,GetRace(owner),1.0);
				SetBuff(victim,fMaxSpeed,GetRace(owner),1.0);
			}
			if(HasWardID[victim][BEHAVIOR_SENTRY_IMMUNITY]==wardindex && behaviorID==BehaviorIndex[BEHAVIOR_SENTRY_IMMUNITY])
			{
				// Remove Sentry Immunity
				HasWardID[victim][BEHAVIOR_SENTRY_IMMUNITY]=-1;
				new flags = GetEntityFlags(victim)&~FL_NOTARGET;
				SetEntityFlags(victim, flags);
				War3_ChatMessage(victim,"{default}You are no longer immune to Sentry Detection.");
				W3Hint(victim,HINT_DMG_RCVD,1.0,"Sentry Immunity Off");
			}
		}
	}
}
public OnWardNotTrigger(wardindex, victim, owner, behavior)
{
	if(ValidPlayer(victim) && ValidPlayer(owner) && (HasWardID[victim][BEHAVIOR_SLOW]>-1||HasWardID[victim][BEHAVIOR_SENTRY_IMMUNITY]>-1))
	{
		if(HasWardID[victim][BEHAVIOR_SLOW]==wardindex && behavior==BehaviorIndex[BEHAVIOR_SLOW])
		{
			// Remove Slow and Remove Ward ID
			HasWardID[victim][BEHAVIOR_SLOW]=-1;
			SetBuff(victim,fSlow,GetRace(owner),1.0);
			SetBuff(victim,fMaxSpeed,GetRace(owner),1.0);
		}
		else if(HasWardID[victim][BEHAVIOR_SENTRY_IMMUNITY]==wardindex && behavior==BehaviorIndex[BEHAVIOR_SENTRY_IMMUNITY])
		{
			// Remove Sentry Immunity
			HasWardID[victim][BEHAVIOR_SENTRY_IMMUNITY]=-1;
			new flags = GetEntityFlags(victim)&~FL_NOTARGET;
			SetEntityFlags(victim, flags);
			War3_ChatMessage(victim,"{default}You are no longer immune to Sentry Detection.");
			W3Hint(victim,HINT_DMG_RCVD,1.0,"Sentry Immunity Off");
		}
	}
}

public Action:loadwards(client,args)
{
	BehaviorIndex[BEHAVIOR_DAMAGE] = War3_CreateWardBehavior("damage", "Damage ward", "Deals damage to targets");
	BehaviorIndex[BEHAVIOR_HEAL] = War3_CreateWardBehavior("heal", "Healing ward", "Heals targets");
	BehaviorIndex[BEHAVIOR_SLOW] = War3_CreateWardBehavior("disrupt", "Disruptive ward", "Disrupt players");
#if GGAMETYPE == GGAME_TF2
	BehaviorIndex[BEHAVIOR_JARATE] = War3_CreateWardBehavior("jarate", "Jarate ward", "Jarate players");
#endif
	BehaviorIndex[BEHAVIOR_ZAP] = War3_CreateWardBehavior("zap", "Zap ward", "Zap players");
	return Plugin_Handled;
}
