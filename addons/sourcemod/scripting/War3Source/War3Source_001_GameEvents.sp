// War3Source_001_GameEvents.sp

public bool Internal_OnWar3EventSpawn(client)
{
	// War3Source_000_Engine_Hint.sp
	lastoutput[client][0] = '\0';

	ShouldCalcAura();

#if GGAMETYPE == GGAME_TF2
	War3Source_Engine_BuffMaxHP_OnWar3EventSpawn(client);
#endif

	War3Source_Engine_CooldownMgr_OnWar3EventSpawn(client);

	War3Source_Engine_Easy_Buff_OnWar3EventSpawn(client);

	War3Source_Engine_PlayerClass_OnWar3EventSpawn(client);

	War3Source_Engine_Regen_OnWar3EventSpawn(client);

	War3Source_Engine_Wards_Engine_OnWar3EventSpawn(client);

	War3Source_Engine_WCX_Engine_Skills_OnWar3EventSpawn(client);

	War3Source_Engine_BotControl_OnWar3EventSpawn(client);

	War3Source_Engine_Casting_OnWar3EventSpawn(client);

	return true;
}

public Internal_OnWar3EventDeath(victim,attacker,deathrace,distance,attacker_hpleft)
{
	// War3Source_Engine_Aura.sp
	ShouldCalcAura();

	War3Source_Engine_Easy_Buff_OnWar3EventDeath(victim, attacker, deathrace);

	War3Source_Engine_NewPlayers_OnWar3EventDeath(victim, attacker, deathrace, distance, attacker_hpleft);

	War3Source_Engine_PlayerClass_OnWar3EventDeath(victim, attacker);

	//War3Source_Engine_PlayerDeathWeapons_OnWar3EventDeath(victim);

	War3Source_Engine_Race_KDR_OnWar3EventDeath(victim, attacker, deathrace, distance, attacker_hpleft);

	War3Source_Engine_Wards_Engine_OnWar3EventDeath(victim, attacker);

	War3Source_Engine_Wards_Wards_OnWar3EventDeath(victim, attacker);
#if GGAMETYPE == GGAME_TF2
	War3Source_Engine_BotControl_OnWar3EventDeath(victim, attacker, deathrace, distance, attacker_hpleft);
#endif

#if GGAMETYPE_JAILBREAK == JAILBREAK_OFF
	War3Source_Engine_XPGold_OnWar3EventDeath(victim,attacker);
#endif
}

new iRoundNumber;

public Action:EndFreezeTime(Handle:timer,any:roundNum)
{
	if(roundNum==iRoundNumber)
	{
		bInFreezeTime=false;
	}
}

public War3Source_RoundStartEvent(Handle:event,const String:name[],bool:dontBroadcast)
{
	bInFreezeTime=true;
	++iRoundNumber;
	new Handle:freezeTimeCvar=FindConVar("mp_freezetime");
	if(freezeTimeCvar)
	{
		new Float:fFreezeTime=GetConVarFloat(freezeTimeCvar);
		if(fFreezeTime>0.0)
		{
			CreateTimer(fFreezeTime,EndFreezeTime,iRoundNumber);
		}
		else
		{
			bInFreezeTime=false;
		}
	}
	else
	{
		bInFreezeTime=false;
	}
}


public War3Source_PlayerSpawnEvent(Handle:event,const String:name[],bool:dontBroadcast)
{
	if(MapChanging==true)
	{
		MapChangingCount++;
		PrintToServer("MapChangingCount = %d",MapChangingCount);
	}

	if(MapChanging && MapChangingCount>=6)
	{
		MapChanging=false;
		MapChangingCount=0;
		PrintToServer("MapChanging = false");
	}

	if(MapChanging || War3SourcePause) return 0;

	new userid=GetEventInt(event,"userid");
	if(userid>0)
	{
		new client=GetClientOfUserId(userid);
		if(ValidPlayer(client,true))
		{
			War3_SetMaxHP_INTERNAL(client,GetClientHealth(client));

			CheckPendingRace(client);
			if(IsFakeClient(client)&&W3IsPlayerXPLoaded(client)&&GetRace(client)==0&&GetConVarInt(botsetraces)){ //W3IsPlayerXPLoaded(client) is for skipping until putin server is fired (which cleared variables)
				int tries=100;
				while(tries>0)
				{
					int race=GetRandomInt(1,GetRacesLoaded());
					if(!RaceHasFlag(race,"nobots")) // may want to remove race!=motherbot then put "nobots" for motherbot along with hidden
					{
						tries=0;
						SetRace(client,race);
						SetLevel(client,race,GetRaceMaxLevel(race));
						for(new i=1;i<=GetRaceSkillCount(race);i++)
						{
							SetSkillLevelINTERNAL(client,race,i,GetRaceSkillMaxLevel(race,i));
						}
						W3DoLevelCheck(client);
					}
					tries--;
				}
			}
			new raceid=GetRace(client);
			if(!GetPlayerProp(client,SpawnedOnce))
			{
				SetPlayerProp(client,SpawnedOnce,true);
			}
			else if(raceid<1&&W3IsPlayerXPLoaded(client))
			{
				ShowChangeRaceMenu(client);
			}
			else if(raceid>0&&GetConVarInt(hRaceLimitEnabled)>0&&GetRacesOnTeam(raceid,GetClientTeam(client),true)>GetRaceMaxLimitTeam(raceid,GetClientTeam(client)))
			{
				CheckRaceTeamLimit(raceid,GetClientTeam(client));  //show changerace inside
			}
			raceid=GetRace(client);//get again it may have changed
			if(raceid>0){

				W3DoLevelCheck(client);
				War3_ShowXP(client);

				DoFwd_War3_Event(DoCheckRestrictedItems,client);
			}
			//forward to all other plugins last
			if(Internal_OnWar3EventSpawn(client))
			{
				DoForward_OnWar3EventSpawn(client);
			}

			SetPlayerProp(client,bStatefulSpawn,false); //no longer a "stateful" spawn
		}
	}
	return 0;
}

public Action:War3Source_PlayerDeathEvent(Handle:event,const String:name[],bool:dontBroadcast)
{
	if(MapChanging || War3SourcePause) return Plugin_Continue;

	new uid_victim = GetEventInt(event, "userid");
	new uid_attacker = GetEventInt(event, "attacker");
	//new uid_entity = GetEventInt(event, "entityid");

	new victimIndex = 0;
	new attackerIndex = 0;

	new victim = GetClientOfUserId(uid_victim);
	new attacker = GetClientOfUserId(uid_attacker);

	new distance=0;
	new attacker_hpleft=0;

	//new String:weapon[32];
	//GetEventString(event, "weapon", weapon, 32);
	//ReplaceString(weapon, 32, "WEAPON_", "");

	if(victim>0&&attacker>0)
	{
		//Get the distance
		new Float:victimLoc[3];
		new Float:attackerLoc[3];
		GetClientAbsOrigin(victim,victimLoc);
		GetClientAbsOrigin(attacker,attackerLoc);
		distance = RoundToNearest(FloatDiv(calcDistance(victimLoc[0],attackerLoc[0], victimLoc[1],attackerLoc[1], victimLoc[2],attackerLoc[2]),12.0));

		attacker_hpleft = GetClientHealth(attacker);

	}


	if(uid_attacker>0){
		attackerIndex=GetClientOfUserId(uid_attacker);
	}

	if(uid_victim>0){
		victimIndex=GetClientOfUserId(uid_victim);
	}

	new bool:deadringereath=false;
	if(uid_victim>0)
	{
		new deathFlags = GetEventInt(event, "death_flags");
		if (deathFlags & 32) //TF_DEATHFLAG_DEADRINGER
		{
			deadringereath=true;
			//PrintToChat(client,"war3 debug: dead ringer kill");

			new assister=GetClientOfUserId(GetEventInt(event,"assister"));

			if(victimIndex!=attackerIndex&&ValidPlayer(attackerIndex))
			{
				if(GetClientTeam(attackerIndex)!=GetClientTeam(victimIndex))
				{
					decl String:weapon[64];
					GetEventString(event,"weapon",weapon,sizeof(weapon));
					new bool:is_hs,bool:is_melee;
					is_hs=(GetEventInt(event,"customkill")==1);
					//DP("wep %s",weapon);
					is_melee=W3IsDamageFromMelee(weapon);
					if(assister>=0 && GetRace(assister)>0)
					{
						W3GiveFakeXPGold(attackerIndex,victimIndex,assister,XPAwardByFakeAssist,_,_,"",_,_);
					}
					W3GiveFakeXPGold(attackerIndex,victimIndex,assister,XPAwardByFakeKill,0,0,"",is_hs,is_melee);
				}
			}

		}
		else
		{
			W3DoLevelCheck(victimIndex);
		}
	}

	if(bHasDiedThisFrame[victimIndex]>0){
		return Plugin_Handled;
	}
	bHasDiedThisFrame[victimIndex]++;
	//lastly
	//DP("died? %d",bHasDiedThisFrame[victimIndex]);
	if(victimIndex&&!deadringereath) //forward to all other plugins last
	{

		W3VarArr[DeathRace]=GetRace(victimIndex);

		new Handle:oldevent=internal_W3GetVar(SmEvent);
	//	DP("new event %d",event);
		internal_W3SetVar(SmEvent,event); //stacking on stack

		///pre death event, internal event
		internal_W3SetVar(EventArg1,attackerIndex);
		DoFwd_War3_Event(OnDeathPre,victimIndex);

		Internal_OnWar3EventDeath(victimIndex,attackerIndex,W3VarArr[DeathRace],distance,attacker_hpleft);
		//post death event actual forward
		//DoForward_OnWar3EventDeath(victimIndex,attackerIndex,W3VarArr[DeathRace],distance,attacker_hpleft,weapon);
		DoForward_OnWar3EventDeath(victimIndex,attackerIndex,W3VarArr[DeathRace],distance,attacker_hpleft);

		internal_W3SetVar(SmEvent,oldevent); //restore on stack , if any
		//DP("restore event %d",event);
		//then we allow change race AFTER death forward
		SetPlayerProp(victimIndex,bStatefulSpawn,true);//next spawn shall be stateful
		CheckPendingRace(victimIndex);

	}
	return Plugin_Continue;
}


