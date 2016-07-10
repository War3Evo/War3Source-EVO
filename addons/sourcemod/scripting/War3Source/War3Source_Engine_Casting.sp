//War3Source_Engine_Casting.sp


bool g_bThirdPersonEnabled[MAXPLAYERS+1] = false;
bool g_bThirdPersonForced[MAXPLAYERS+1] = false;

bool g_castingid[MAXPLAYERS+1][MAXSKILLCOUNT];

char ww_on[]= "npc/scanner/scanner_nearmiss1.wav";
char ww_off[]= "npc/scanner/scanner_nearmiss2.wav";

enum PlayerCoolDownClass
{
	iiTarget,
	W3SpellEffects:eSpelleffect,
	W3SpellColor:eSpellcolor,
	iRACEiD,
	iSkiLLiD,
}

Handle g_OnWar3CastingStarted_Pre;
Handle g_OnWar3CastingStarted;
Handle g_OnWar3CastingFinished_Pre;
Handle g_OnWar3CastingFinished;
Handle g_OnWar3CancelSpell_Post;

public War3Source_Engine_Casting_OnPluginStart()
{
	RegAdminCmd("sm_thirdperson", EnableThirdperson, 0, "Usage: sm_thirdperson");
	RegAdminCmd("tp", EnableThirdperson, 0, "Usage: sm_thirdperson");
	RegAdminCmd("sm_firstperson", DisableThirdperson, 0, "Usage: sm_firstperson");
	RegAdminCmd("fp", DisableThirdperson, 0, "Usage: sm_firstperson");
}

public bool:War3Source_Engine_Casting_InitForwards()
{
	g_OnWar3CastingStarted_Pre=CreateGlobalForward("OnWar3CastingStarted_Pre",ET_Hook,Param_Cell,Param_Cell,Param_Cell,Param_String,Param_Cell,Param_Cell,Param_FloatByRef);
	g_OnWar3CastingStarted=CreateGlobalForward("OnWar3CastingStarted",ET_Ignore,Param_Cell,Param_Cell,Param_Cell,Param_String,Param_Cell,Param_Cell);
	g_OnWar3CastingFinished_Pre=CreateGlobalForward("OnWar3CastingFinished_Pre",ET_Hook,Param_Cell,Param_Cell,Param_Cell,Param_String,Param_Cell,Param_Cell);
	g_OnWar3CastingFinished=CreateGlobalForward("OnWar3CastingFinished",ET_Ignore,Param_Cell,Param_Cell,Param_Cell,Param_String,Param_Cell,Param_Cell);
	g_OnWar3CancelSpell_Post=CreateGlobalForward("OnWar3CancelSpell_Post",ET_Ignore,Param_Cell,Param_Cell,Param_Cell,Param_Cell);
	return true;
}
public bool:War3Source_Engine_Casting_InitNatives()
{
	///LIST ALL THESE NATIVES IN INTERFACE
	CreateNative("War3_CancelSpell",NWar3_CancelSpell);
	CreateNative("War3_CastSpell",NWar3_CastSpell);
	CreateNative("War3_IsThirdPerson",NWar3_IsThirdPerson);
	CreateNative("War3_ForceThirdPerson",NWar3_ForceThirdPerson);
	return true;
}

public NWar3_CancelSpell(Handle:plugin,numParams)
{
	int client=GetNativeCell(1);
	int target=GetNativeCell(2);
	int castingid=GetNativeCell(3);
	if(ValidPlayer(client))
	{
		if(g_castingid[target][castingid] && castingid>0)
		{
			g_castingid[target][castingid]=false;

			decl String:sClientName[32],String:sTargetName[32];
			decl String:sClientTeamTag[32],String:sTargetTeamTag[32];

			GetTeamColor(client,STRING(sClientTeamTag));
			GetClientName(client,STRING(sClientName));

			GetTeamColor(target,STRING(sTargetTeamTag));
			GetClientName(target,STRING(sTargetName));
			decl String:sSkillName[32];
			W3GetRaceSkillName(War3_GetRace(target),castingid,STRING(sSkillName));

			War3_ChatMessage(0,"%s%s {default}successfully canceled %s%s's {default}spell {green}%s!",
				sClientTeamTag,sClientName,sTargetTeamTag,sTargetName,sSkillName);

		}
		else if(target==0 && castingid==0)
		{
			ShowPlayerCancelSpellMenu(client);
		}
		else
		{
			War3_ChatMessage(client,"Spell no longer exists.");
		}
	}
}

ShowPlayerCancelSpellMenu(client)
{
	SetTrans(client);
	Handle CancelSpellMenu=CreateMenu(ShowCancelSpellinfoSelected);
	SetMenuExitButton(CancelSpellMenu,true);
	SetMenuTitle(CancelSpellMenu,"[Magic] Cancel Spell Menu");
	decl String:str[128];
	decl String:selectioninfo[12];
	decl String:sSkillName[32];
	decl String:sClientName[32];

	int team = GetClientTeam(client);
	int otherteam;

	int retrievals=0;

	LoopIngameClients(target)
	{
		otherteam = GetClientTeam(target);

		if(team==otherteam) continue;

		for(int castingid=1;castingid<=4;castingid++)
		{
			if(g_castingid[target][castingid])
			{
				W3GetRaceSkillName(War3_GetRace(target),castingid,STRING(sSkillName));

				Format(selectioninfo,sizeof(selectioninfo),"%d,%d",target,castingid);

				GetClientName(target,STRING(sClientName));

				Format(str,sizeof(str),"%s - %s",sClientName,sSkillName);

				AddMenuItem(CancelSpellMenu,selectioninfo,str);

				retrievals++;
			}
		}
		if(retrievals==0)
		{
			War3_ChatMessage(client,"{red}Could not find any spells being cast.");
			return;
		}
	}
	DisplayMenu(CancelSpellMenu,client,10);
}


public ShowCancelSpellinfoSelected(Handle:menu,MenuAction:action,client,selection)
{
	if(action==MenuAction_Select)
	{
		if(ValidPlayer(client))
		{
			decl String:exploded[2][12];

			char SelectionInfo[4];
			char SelectionDispText[256];
			int SelectionStyle;
			GetMenuItem(menu,selection,SelectionInfo,sizeof(SelectionInfo),SelectionStyle, SelectionDispText,sizeof(SelectionDispText));

			ExplodeString(SelectionInfo, ",", exploded, 2, 12);
			int target=StringToInt(exploded[0]);
			int castingid=StringToInt(exploded[1]);

			g_castingid[target][castingid]=false;

			SetBuffRace(target,fInvisibilitySkill,War3_GetRace(target),1.0);

			internal_ForceThirdPerson(target,false);

			SetBuffRace(target,bBashed,0,false);
			SetBuffRace(target,bDisarm,0,false);

			decl String:sClientName[32],String:sTargetName[32];
			decl String:sClientTeamTag[32],String:sTargetTeamTag[32];

			GetTeamColor(client,STRING(sClientTeamTag));
			GetClientName(client,STRING(sClientName));

			GetTeamColor(target,STRING(sTargetTeamTag));
			GetClientName(target,STRING(sTargetName));
			decl String:sSkillName[32];
			W3GetRaceSkillName(War3_GetRace(target),castingid,STRING(sSkillName));


			War3_ChatMessage(0,"%s%s {default}successfully canceled %s%s's {default}spell {green}%s!",
							sClientTeamTag,sClientName,sTargetTeamTag,sTargetName,sSkillName);

			Call_StartForward(g_OnWar3CancelSpell_Post);
			Call_PushCell(client);
			Call_PushCell(War3_GetRace(client));
			Call_PushCell(castingid);
			Call_PushCell(target);
			Call_Finish(dummy);
		}
	}
	if(action==MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public NWar3_CastSpell(Handle:plugin,numParams)
{
	int client=GetNativeCell(1);
	int target=GetNativeCell(2);
	W3SpellEffects spelleffect = W3SpellEffects:GetNativeCell(3);

	char SpellColor[20];
	GetNativeString(4, SpellColor, sizeof(SpellColor));

	int raceid=GetNativeCell(5);
	int SkillID=GetNativeCell(6);
	float castingtime=Float:GetNativeCell(7);

	CastSpell(client,target,spelleffect,SpellColor,raceid,SkillID,castingtime);

	return true;
}

public Action CastSpell(int client,int target,W3SpellEffects spelleffect,char[] Spellcolor,int raceid,int SkillID,float castingtime)
{
	if(ValidPlayer(client))
	{
		SetBuffRace(client,bBashed,0,true);
		SetBuffRace(client,bDisarm,0,true);

		War3_ForceThirdPerson(client,true);

		g_castingid[client][SkillID]=true;

		Action returnVal = Plugin_Continue;
		Call_StartForward(g_OnWar3CastingStarted_Pre);
		Call_PushCell(client);
		Call_PushCell(target);
		Call_PushCell(spelleffect);
		Call_PushString(Spellcolor);
		Call_PushCell(raceid);
		Call_PushCell(SkillID);
		Call_PushFloatRef(castingtime);
		Call_Finish(_:returnVal);
		if(returnVal != Plugin_Continue)
		{
			g_castingid[client][SkillID]=false;

			SetBuffRace(client,fInvisibilitySkill,0,1.0);

			internal_ForceThirdPerson(client,false);

			SetBuffRace(client,bBashed,0,false);
			SetBuffRace(client,bDisarm,0,false);
			return Plugin_Stop;
		}

		switch (spelleffect)
		{
			case NoSpellEffects:
			{
			}
			case SpellEffectsPhysical:
			{
			}
			case SpellEffectsArcane:
			{
			}
			case SpellEffectsFire:
			{
			}
			case SpellEffectsFrost:
			{
			}
			case SpellEffectsNature:
			{
			}
			case SpellEffectsDarkness:
			{
				//ShadowCast(client,raceid,castingtime);
			}
			case SpellEffectsLight:
			{
				//War3_ChatMessage(0,"{green}%s{default} is casting {green}%s{default} spell.",sClientName,sSkillName);
				LightCast(client,target,spelleffect,Spellcolor,raceid,SkillID,castingtime);
			}
		}

		Call_StartForward(g_OnWar3CastingStarted);
		Call_PushCell(client);
		Call_PushCell(target);
		Call_PushCell(spelleffect);
		Call_PushString(Spellcolor);
		Call_PushCell(raceid);
		Call_PushCell(SkillID);
		Call_Finish(dummy);
	}
	return Plugin_Continue;
}

public LightCast(client,target,W3SpellEffects:spelleffect,String:SpellColor[],raceid,SkillID,Float:CastingTimer)
{
	float this_pos[3];
	GetClientAbsOrigin(client,this_pos);
	TE_SetupBeamRingPoint(this_pos, 90.0, 40.0, HaloSprite, HaloSprite, 0, 5, 0.8, 50.0, 0.0, {255,255,255,255}, 1, 0) ;
	TE_SendToAll();
	TE_SetupBeamRingPoint(this_pos, 88.0, 150.0, HaloSprite, HaloSprite, 0, 5, 1.5, 20.0, 0.0, {255,255,255,255}, 1, 0) ;
	TE_SendToAll(0.75);
	TE_SetupDynamicLight(this_pos,120,255,120,12,80.0,CastingTimer,1.0);
	TE_SendToAll();
	SetBuffRace(client,fInvisibilitySkill,0,0.22);

	SetBuffRace(client,bBashed,0,true);
	SetBuffRace(client,bDisarm,0,true);

	if(ValidPlayer(target))
	{
		Handle Packhead;
		CreateDataTimer(CastingTimer,RemoveHolyCast,Packhead);
		WritePackCell(Packhead, client);
		WritePackCell(Packhead, target);
		WritePackCell(Packhead, spelleffect);
		WritePackString(Packhead, SpellColor);
		WritePackCell(Packhead, raceid);
		WritePackCell(Packhead, SkillID);
		WritePackFloat(Packhead, CastingTimer);
	}
	else
	{
		Handle Packhead;
		CreateDataTimer(CastingTimer,FinishSpellCast,Packhead);
		WritePackCell(Packhead, client);
		WritePackCell(Packhead, target);
		WritePackCell(Packhead, spelleffect);
		WritePackString(Packhead, SpellColor);
		WritePackCell(Packhead, raceid);
		WritePackCell(Packhead, SkillID);
	}

	CreateParticlesUp(client,true,CastingTimer,45.0,5.0,10.0,0.0,"effects/softglow.vmt",SpellColor,"10","300","300","120");
	EmitSoundToAll(ww_on,client);
}

public Action:RemoveHolyCast(Handle:t,any:Packhead)
{
	char SpellColor[20];
	ResetPack(Packhead);
	int client = ReadPackCell(Packhead);
	int target = ReadPackCell(Packhead);
	W3SpellEffects spelleffect = W3SpellEffects:ReadPackCell(Packhead);
	ReadPackString(Packhead, SpellColor, sizeof(SpellColor));
	int raceid = ReadPackCell(Packhead);
	int SkillID = ReadPackCell(Packhead);
	float CastingTimer = ReadPackFloat(Packhead);

	if(!g_castingid[client][SkillID]) return Plugin_Stop;

	Action returnVal = Plugin_Continue;
	Call_StartForward(g_OnWar3CastingFinished_Pre);
	Call_PushCell(client);
	Call_PushCell(target);
	Call_PushCell(spelleffect);
	Call_PushString(SpellColor);
	Call_PushCell(raceid);
	Call_PushCell(SkillID);
	Call_Finish(_:returnVal);
	if(returnVal != Plugin_Continue)
	{
		g_castingid[client][SkillID]=false;

		SetBuffRace(client,fInvisibilitySkill,0,1.0);

		internal_ForceThirdPerson(client,false);

		SetBuffRace(client,bBashed,0,false);
		SetBuffRace(client,bDisarm,0,false);
		return Plugin_Stop;
	}

	if(ValidPlayer(client,true) && g_castingid[client][SkillID])
	{
		EmitSoundToAll(ww_off,client);
		float this_pos[3];
		GetClientAbsOrigin(client,this_pos);
		TE_SetupBeamRingPoint(this_pos, 10.0, 90.0, HaloSprite, HaloSprite, 0, 5, 0.8, 50.0, 0.0, {155,115,100,200}, 1, 0) ;
		TE_SendToAll();
		if(ValidPlayer(target,true))
		{
			GetClientAbsOrigin(target,this_pos);
			TE_SetupDynamicLight(this_pos,120,255,120,12,80.0,1.88,1.0);
			TE_SendToAll();

			CreateParticlesDown(target,true,CastingTimer,45.0,5.0,10.0,0.0,"effects/softglow.vmt",SpellColor,"10","300","300","120");
		}


		Call_StartForward(g_OnWar3CastingFinished);
		Call_PushCell(client);
		Call_PushCell(target);
		Call_PushCell(spelleffect);
		Call_PushString(SpellColor);
		Call_PushCell(raceid);
		Call_PushCell(SkillID);
		Call_Finish(dummy);
	}
	g_castingid[client][SkillID]=false;

	SetBuffRace(client,fInvisibilitySkill,0,1.0);

	internal_ForceThirdPerson(client,false);

	SetBuffRace(client,bBashed,0,false);
	SetBuffRace(client,bDisarm,0,false);

	return Plugin_Continue;
}

public Action:FinishSpellCast(Handle:t,any:Packhead)
{
	char SpellColor[20];
	ResetPack(Packhead);
	int client = ReadPackCell(Packhead);
	int target = ReadPackCell(Packhead);
	W3SpellEffects spelleffect = W3SpellEffects:ReadPackCell(Packhead);
	ReadPackString(Packhead, SpellColor, sizeof(SpellColor));
	int raceid = ReadPackCell(Packhead);
	int SkillID = ReadPackCell(Packhead);

	if(!g_castingid[client][SkillID]) return Plugin_Stop;

	Action returnVal = Plugin_Continue;
	Call_StartForward(g_OnWar3CastingFinished_Pre);
	Call_PushCell(client);
	Call_PushCell(target);
	Call_PushCell(spelleffect);
	Call_PushString(SpellColor);
	Call_PushCell(raceid);
	Call_PushCell(SkillID);
	Call_Finish(_:returnVal);
	if(returnVal != Plugin_Continue)
	{
		g_castingid[client][SkillID]=false;

		SetBuffRace(client,fInvisibilitySkill,0,1.0);

		internal_ForceThirdPerson(client,false);

		SetBuffRace(client,bBashed,0,false);
		SetBuffRace(client,bDisarm,0,false);
		return Plugin_Stop;
	}

	if(ValidPlayer(client,true) && g_castingid[client][SkillID])
	{
		EmitSoundToAll(ww_off,client);
		float this_pos[3];
		GetClientAbsOrigin(client,this_pos);
		TE_SetupBeamRingPoint(this_pos, 10.0, 90.0, HaloSprite, HaloSprite, 0, 5, 0.8, 50.0, 0.0, {155,115,100,200}, 1, 0) ;
		TE_SendToAll();

		Call_StartForward(g_OnWar3CastingFinished);
		Call_PushCell(client);
		Call_PushCell(target);
		Call_PushCell(spelleffect);
		Call_PushString(SpellColor);
		Call_PushCell(raceid);
		Call_PushCell(SkillID);
		Call_Finish(dummy);
	}
	g_castingid[client][SkillID]=false;

	SetBuffRace(client,fInvisibilitySkill,0,1.0);

	internal_ForceThirdPerson(client,false);

	SetBuffRace(client,bBashed,0,false);
	SetBuffRace(client,bDisarm,0,false);

	return Plugin_Continue;
}

public NWar3_IsThirdPerson(Handle:plugin,numParams)
{
	return g_bThirdPersonEnabled[GetNativeCell(1)];
}

internal_ForceThirdPerson(client,bool:ForcePlayer)
{
	if(client>0 && client<=MaxClients && IsClientConnected(client) && IsClientInGame(client) && IsPlayerAlive(client))
	{
		if(ForcePlayer==true && g_bThirdPersonEnabled[client]==false)
		{
			SetVariantInt(1);
			AcceptEntityInput(client, "SetForcedTauntCam");
			g_bThirdPersonForced[client]=true;
		}
		else if(ForcePlayer==false && g_bThirdPersonForced[client])
		{
			if(g_bThirdPersonEnabled[client]==false)
			{
				SetVariantInt(0);
				AcceptEntityInput(client, "SetForcedTauntCam");
			}
			g_bThirdPersonForced[client]=false;
		}
	}
}

public NWar3_ForceThirdPerson(Handle:plugin,numParams)
{
	int client = GetNativeCell(1);
	bool ForcePlayer = GetNativeCell(2);
	internal_ForceThirdPerson(client,ForcePlayer);
}

public War3Source_Engine_Casting_OnWar3EventSpawn(client)
{
	if (g_bThirdPersonEnabled[client] && !IsFakeClient(client))
	{
		CreateTimer(0.2, SetViewOnSpawn, client);
	}
}

public Action:SetViewOnSpawn(Handle:timer, any:client)
{
	if(MapChanging) return Plugin_Stop;

	if (client != 0)	//Checked g_bThirdPersonEnabled in hook callback, dont need to do it here~
	{
		SetVariantInt(1);
		AcceptEntityInput(client, "SetForcedTauntCam");
	}

	return Plugin_Stop;
}

public Action:EnableThirdperson(client, args)
{
	if(!IsPlayerAlive(client))
		PrintToChat(client, "[SM] Thirdperson view will be enabled when you spawn.");
#if GGAMETYPE == GGAME_TF2
	SetVariantInt(1);
	AcceptEntityInput(client, "SetForcedTauntCam");
#elseif GGAMETYPE == GGAME_CSS
	SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", 0);
	SetEntProp(client, Prop_Send, "m_iObserverMode", 1);
	SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 0);
	SetEntProp(client, Prop_Send, "m_iFOV", 120);
#endif
	g_bThirdPersonEnabled[client] = true;
	return Plugin_Handled;
}

public Action:DisableThirdperson(client, args)
{
	if(!IsPlayerAlive(client))
		PrintToChat(client, "[SM] Thirdperson view disabled!");
#if GGAMETYPE == GGAME_TF2
	SetVariantInt(0);
	AcceptEntityInput(client, "SetForcedTauntCam");
#elseif GGAMETYPE == GGAME_CSS
		SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", client);
		SetEntProp(client, Prop_Send, "m_iObserverMode", 0);
		SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1);
		SetEntProp(client, Prop_Send, "m_iFOV", 90);
#endif
	g_bThirdPersonEnabled[client] = false;
	return Plugin_Handled;
}

public War3Source_Engine_Casting_OnClientDisconnect(client)
{
	g_bThirdPersonEnabled[client] = false;
}
