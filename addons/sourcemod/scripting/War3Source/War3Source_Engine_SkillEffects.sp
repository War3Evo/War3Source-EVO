// War3Source_Engine_SkillEffects.sp

//#assert GGAMEMODE == MODE_WAR3SOURCE

/*
public Plugin:myinfo =
{
	name = "War3Source - Engine - Notifications",
	author = "War3Source Team",
	description = "Centralize some notifications"
};
*/
new iMaskSoundDelay[MAXPLAYERSCUSTOM];
new String:sMaskSound[]="war3source/mask.mp3";


new BeamSprite = -1;
new HaloSprite = -1;

public bool:War3Source_Engine_SkillEffects_InitNatives()
{
	CreateNative("War3_TE_SendToAll", Native_TE_SendToAll);
	CreateNative("War3_TE_SendToClient", Native_TE_SendToClient);

	CreateNative("War3_EvadeDamage", Native_EvadeDamage);
	CreateNative("War3_EffectReturnDamage", Native_EffectReturnDamage);
	CreateNative("War3_VampirismEffect", Native_VampirismEffect);
	CreateNative("War3_BashEffect", Native_BashEffect);
	CreateNative("War3_WardVisualEffect", Native_WardVisualEffect);
	CreateNative("War3_WardZapVisualEffect", Native_WardZapVisualEffect);

	return true;
}

public War3Source_Engine_SkillEffects_OnPluginStart()
{
	for(new i=1; i <= MaxClients; i++)
	{
		iMaskSoundDelay[i] = War3_RegisterDelayTracker();
	}
}

public War3Source_Engine_SkillEffects_OnMapStart()
{
	//War3_AddSoundFolder(sMaskSound, sizeof(sMaskSound), "mask.mp3");
	//War3_PrecacheSound(sMaskSound);

	BeamSprite = War3_PrecacheBeamSprite();
	HaloSprite = War3_PrecacheHaloSprite();
}

public War3Source_Engine_SkillEffects_OnAddSound(sound_priority)
{
	if(sound_priority==PRIORITY_MEDIUM)
	{
		War3_AddSound("War3Source_Engine_SkillEffects",sMaskSound);
	}
}

public Native_EvadeDamage(Handle:plugin, numParams)
{
	new victim = GetNativeCell(1);
	new attacker = GetNativeCell(2);

	DamageModPercent(0.0);

	if (ValidPlayer(victim))
	{
		W3FlashScreen(victim, RGBA_COLOR_BLUE);
		W3Hint(victim, HINT_SKILL_STATUS, 1.0, "You Evaded a Shot");
#if (GGAMETYPE == GGAME_TF2)
		decl Float:pos[3];
		GetClientEyePosition(victim, pos);
		pos[2] += 4.0;
		TE_ParticleToClient(0, "miss_text", pos);
#endif
	}

	if (ValidPlayer(attacker))
	{
		W3Hint(attacker, HINT_SKILL_STATUS, 1.0, "Enemy Evaded");
	}
}

public Native_EffectReturnDamage(Handle:plugin, numParams)
{
	// Victim: The guy getting shot
	// Attacker: The guy who takes damage
	new victim = GetNativeCell(1);
	new attacker = GetNativeCell(2);
	new damage = GetNativeCell(3);
	new skill = GetNativeCell(4);

	if (attacker == ATTACKER_WORLD)
	{
		return;
	}

	new beamSprite = War3_PrecacheBeamSprite();
	new haloSprite = War3_PrecacheHaloSprite();

	decl Float:f_AttackerPos[3];
	decl Float:f_VictimPos[3];

	if (ValidPlayer(attacker))
	{
		GetClientAbsOrigin(attacker, f_AttackerPos);
	}
	else if (IsValidEntity(attacker))
	{
		GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", f_AttackerPos);
	}
	else
	{
		W3LogError("Invalid attacker for EffectReturnDamage: %i", attacker);
		return;
	}

	GetClientAbsOrigin(victim, f_VictimPos);

	f_AttackerPos[2] += 35.0;
	f_VictimPos[2] += 40.0;

	TE_SetupBeamPoints(f_AttackerPos, f_VictimPos, beamSprite, beamSprite, 0, 45, 0.4, 10.0, 10.0, 0, 0.5, {255, 35, 15, 255}, 30);
	War3_internal_TE_SendToAll();

	f_VictimPos[0] = f_AttackerPos[0];
	f_VictimPos[1] = f_AttackerPos[1];
	f_VictimPos[2] = 80.0 + f_AttackerPos[2];

	TE_SetupBubbles(f_AttackerPos, f_VictimPos, haloSprite, 35.0, GetRandomInt(6, 8), 8.0);
	War3_internal_TE_SendToAll();

	War3_NotifyPlayerTookDamageFromSkill(attacker, victim, damage, skill);
}

public Native_VampirismEffect(Handle:plugin, numParams)
{
	new victim = GetNativeCell(1);
	new attacker = GetNativeCell(2);
	new leechhealth = GetNativeCell(3);

	if (leechhealth <= 0)
	{
		return;
	}

	W3FlashScreen(victim, RGBA_COLOR_RED);
	W3FlashScreen(attacker, RGBA_COLOR_GREEN);

	// Team Fortress shows HP gained in the HUD already

	if(War3_TrackDelayExpired(iMaskSoundDelay[attacker]))
	{
		War3_EmitSoundToAll(sMaskSound, attacker);
		War3_TrackDelay(iMaskSoundDelay[attacker], 0.25);
	}

	if(War3_TrackDelayExpired(iMaskSoundDelay[victim]))
	{
		War3_EmitSoundToAll(sMaskSound, victim);
		War3_TrackDelay(iMaskSoundDelay[victim], 0.25);
	}
	//PrintToConsole(attacker, "You Leeched +%d HP", leechhealth);
	//PrintToConsole(victim, "Attacker Leeched +%d HP from you!", leechhealth);
}

public Native_BashEffect(Handle:plugin, numParams)
{
	new victim = GetNativeCell(1);
	new attacker = GetNativeCell(2);

	W3FlashScreen(victim, RGBA_COLOR_RED);

	W3Hint(victim, HINT_SKILL_STATUS, 1.0, "You got bashed");
	W3Hint(attacker, HINT_SKILL_STATUS, 1.0, "Bashed enemy");
}

public Native_WardVisualEffect(Handle:plugin, numParams)
{
	new wardindex = GetNativeCell(1);
	decl beamcolor[4];
	GetNativeArray(2, beamcolor, sizeof(beamcolor));
	new iownerteam = GetNativeCell(3);
	new iWardTarget = GetNativeCell(4);
	new bool:bOutward = bool:GetNativeCell(5);

	decl Float:fWardLocation[3];
	War3_GetWardLocation(wardindex, fWardLocation);
	new Float:fInterval = War3_GetWardInterval(wardindex);
	new wardRadius = War3_GetWardRadius(wardindex);

	new Float:fStartPos[3];
	new Float:fEndPos[3];
	new Float:tempVec1[] = {0.0, 0.0, WARDBELOW};
	new Float:tempVec2[] = {0.0, 0.0, WARDABOVE};

	AddVectors(fWardLocation, tempVec1, fStartPos);
	AddVectors(fWardLocation, tempVec2, fEndPos);

	if(iownerteam>0)
	{
			for(new iclient=0;iclient<MaxClients;iclient++)
			{
				// If they are on the same team, then ghost it
				if(ValidPlayer(iclient,true))
				{
					if(W3HasImmunity(iclient, Immunity_Wards))
					{
						beamcolor[3]=30;
					}
					//else if ((iclient == owner) && !(iWardTarget & WARD_TARGET_SELF))
					//{
						//beamcolor[3]=30;
					//}
					else if ((GetClientTeam(iclient) == iownerteam) && !(iWardTarget & WARD_TARGET_ALLIES))
					{
						beamcolor[3]=30;
					}
					else if ((GetClientTeam(iclient) != iownerteam) && !(iWardTarget & WARD_TARGET_ENEMYS))
					{
						beamcolor[3]=30;
					}
					else
					{
						beamcolor[3]=180;
					}
					TE_SetupBeamPoints(fStartPos, fEndPos, BeamSprite, HaloSprite, 0, GetRandomInt(30, 100), fInterval, 70.0, 70.0, 0, 30.0, beamcolor, 10);
					War3_internal_TE_SendToClient(iclient);
				}
			}
	}
	else
	{
		TE_SetupBeamPoints(fStartPos, fEndPos, BeamSprite, HaloSprite, 0, GetRandomInt(30, 100), fInterval, 70.0, 70.0, 0, 30.0, beamcolor, 10);
		War3_internal_TE_SendToAll();
	}

	new Float:StartRadius = wardRadius / 2.0;
	new Speed = RoundToFloor((wardRadius - StartRadius) / fInterval);

	if(bOutward)
	{
		TE_SetupBeamRingPoint(fWardLocation, float(wardRadius), StartRadius, BeamSprite, HaloSprite, 0,1, fInterval, 20.0, 1.5, beamcolor, Speed, 0);
		War3_internal_TE_SendToAll();
	}
	else
	{
		TE_SetupBeamRingPoint(fWardLocation, StartRadius, float(wardRadius), BeamSprite, HaloSprite, 0,1, fInterval, 20.0, 1.5, beamcolor, Speed, 0);
		War3_internal_TE_SendToAll();
	}
}

public Native_WardZapVisualEffect(Handle:plugin, numParams)
{
	new wardindex = GetNativeCell(1);
	decl beamcolor[4];
	GetNativeArray(2, beamcolor, sizeof(beamcolor));
	new iownerteam = GetNativeCell(3);
	new iWardTarget = GetNativeCell(4);
	new bool:bZap = bool:GetNativeCell(5);
	new thewardtarget = GetNativeCell(6);

	decl Float:fWardLocation[3];
	War3_GetWardLocation(wardindex, fWardLocation);
	new Float:fInterval = War3_GetWardInterval(wardindex);
	new wardRadius = War3_GetWardRadius(wardindex);

	new Float:fStartPos[3];
	new Float:fEndPos[3];
	new Float:tempVec1[] = {0.0, 0.0, WARDBELOW};
	new Float:tempVec2[] = {0.0, 0.0, WARDABOVE};

	AddVectors(fWardLocation, tempVec1, fStartPos);
	AddVectors(fWardLocation, tempVec2, fEndPos);

	if(!bZap)
	{
		if(iownerteam>0)
		{
			for(new iclient=0;iclient<MaxClients;iclient++)
			{
				// If they are on the same team, then ghost it
				if(ValidPlayer(iclient,true))
				{
					if(W3HasImmunity(iclient, Immunity_Wards))
					{
						beamcolor[3]=30;
					}
					//else if ((iclient == owner) && !(iWardTarget & WARD_TARGET_SELF))
					//{
						//beamcolor[3]=30;
					//}
					else if ((GetClientTeam(iclient) == iownerteam) && !(iWardTarget & WARD_TARGET_ALLIES))
					{
						beamcolor[3]=30;
					}
					else if ((GetClientTeam(iclient) != iownerteam) && !(iWardTarget & WARD_TARGET_ENEMYS))
					{
						beamcolor[3]=30;
					}
					else
					{
						beamcolor[3]=180;
					}
					TE_SetupBeamPoints(fStartPos, fEndPos, BeamSprite, HaloSprite, 0, GetRandomInt(30, 100), fInterval, 70.0, 70.0, 0, 30.0, beamcolor, 10);
					War3_internal_TE_SendToClient(iclient);
				}
			}
		}
		else
		{
			TE_SetupBeamPoints(fStartPos, fEndPos, BeamSprite, HaloSprite, 0, GetRandomInt(30, 100), fInterval, 70.0, 70.0, 0, 30.0, beamcolor, 10);
			War3_internal_TE_SendToAll();
		}

		new Float:StartRadius = wardRadius -100.0;
		wardRadius *= 2;
		new Speed = RoundToFloor((wardRadius - StartRadius) / fInterval);

		TE_SetupBeamRingPoint(fWardLocation, StartRadius, float(wardRadius), BeamSprite, HaloSprite, 0,1, fInterval, 20.0, 1.5, beamcolor, Speed, 0);
		War3_internal_TE_SendToAll();
	}
	else
	{
		if(ValidPlayer(thewardtarget))
		{
			new Float:otherpos[3];
			GetClientEyePosition(thewardtarget,otherpos);
			//otherpos[2]-=20.0; //THIS IS EYE NOW, NOT ABS
			//fWardLocation[2]+=100.0;

			// what if position was same height?
			fWardLocation[2]=otherpos[2];
			otherpos[2]-=20.0;
			fWardLocation[2]+=50.0;

			// fInterval was 0.15
			if(iownerteam==2)
			{
				TE_SetupBeamPoints(fWardLocation,otherpos,BeamSprite,HaloSprite,0,35,fInterval,6.0,5.0,0,1.0,{255, 0, 0, 255},20);
				War3_internal_TE_SendToAll();
			}
			else if(iownerteam==3)
			{
				TE_SetupBeamPoints(fWardLocation,otherpos,BeamSprite,HaloSprite,0,35,fInterval,6.0,5.0,0,1.0,{0, 0, 255, 255},20);
				War3_internal_TE_SendToAll();
			}
			else
			{
				TE_SetupBeamPoints(fWardLocation,otherpos,BeamSprite,HaloSprite,0,35,fInterval,6.0,5.0,0,1.0,{255,000,255,255},20);
				War3_internal_TE_SendToAll();
			}
		}
	}
}

stock War3_internal_TE_SendToAll(Float:delay=0.0)
{
	decl TempClients[MAXPLAYERSCUSTOM];
	new iCount=0;
	for(new i=1; i <= MaxClients; i++)
	{
		if(ValidPlayer(i) && !IsFakeClient(i) && GetPlayerProp(i,iGraphics)>0)
		{
			TempClients[iCount]=i;
			iCount++;
			//TE_SendToClient(i, delay);
		}
	}
	TE_Send(TempClients, iCount, delay);
}
stock War3_internal_TE_SendToClient(client,Float:delay=0.0)
{
	if(ValidPlayer(client) && GetPlayerProp(client,iGraphics)>0)
	{
		TE_SendToClient(client, delay);
	}
}

// Helps filter graphics out for players whom do not want to see graphics from WarCraft
public Native_TE_SendToAll(Handle:plugin, numParams)
{
	new Float:delay=Float:GetNativeCell(1);
	War3_internal_TE_SendToAll(delay);
	/*
	for(new i=1; i <= MaxClients; i++)
	{
		if(ValidPlayer(i) && GetPlayerProp(i,iGraphics)>0)
		{
			TE_SendToClient(i, delay);
		}
	}*/
}

public Native_TE_SendToClient(Handle:plugin, numParams)
{
	new client=GetNativeCell(1);
	new Float:delay=Float:GetNativeCell(2);
	War3_internal_TE_SendToClient(client,delay);
	/*
	if(ValidPlayer(i) && GetPlayerProp(i,iGraphics)>0)
	{
		TE_SendToClient(i, delay);
	}*/
}
