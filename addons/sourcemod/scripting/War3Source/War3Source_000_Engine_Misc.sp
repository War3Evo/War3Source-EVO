// War3Source_000_Engine_Misc.sp

// TRANSLATIONS DONE

public Native_W3FlashScreen(Handle:plugin,numParams)
{
	if(MapChanging || War3SourcePause) return;

	new client=GetNativeCell(1);
	new color[4];
	GetNativeArray(2,color,4);
	new Float:holdduration=GetNativeCell(3);
	new Float:fadeduration=GetNativeCell(4);
	new flags=GetNativeCell(5);
	if(ValidPlayer(client,false))
	{
		new Handle:hMessage=StartMessageOne("Fade",client);
		if(hMessage!=INVALID_HANDLE)
		{
			if (GetUserMessageType() == UM_Protobuf)
			{
				PbSetInt(hMessage, "duration", RoundFloat(255.0*fadeduration));
				PbSetInt(hMessage, "hold_time", RoundFloat(255.0*holdduration));
				PbSetInt(hMessage, "flags", flags);
				PbSetColor(hMessage, "clr", color);
			}
			else
			{
				BfWriteShort(hMessage,RoundFloat(255.0*fadeduration));
				BfWriteShort(hMessage,RoundFloat(255.0*holdduration)); //holdtime
				BfWriteShort(hMessage,flags);
				BfWriteByte(hMessage,color[0]);
				BfWriteByte(hMessage,color[1]);
				BfWriteByte(hMessage,color[2]);
				BfWriteByte(hMessage,color[3]);
			}
			EndMessage();
		}
	}
}

public Native_War3_ShakeScreen(Handle:plugin,numParams)
{
	if(MapChanging || War3SourcePause) return 0;

	new client=GetNativeCell(1);
	new Float:duration=GetNativeCell(2);
	new Float:magnitude=GetNativeCell(3);
	new Float:noise=GetNativeCell(4);
	if(ValidPlayer(client,false))
	{
#if (GGAMETYPE != GGAME_CSGO)
		new Handle:hBf=StartMessageOne("Shake",client);
		if(hBf!=INVALID_HANDLE)
		{
			BfWriteByte(hBf,0);
			BfWriteFloat(hBf,magnitude);
			BfWriteFloat(hBf,noise);
			BfWriteFloat(hBf,duration);
			EndMessage();
		}
#else
		new Handle:hPb = StartMessageOne("Shake", client, 1);
		if(hPb!=INVALID_HANDLE)
		{
			PbSetInt(hPb, "command", 0);
			PbSetFloat(hPb, "local_amplitude", magnitude);
			PbSetFloat(hPb, "frequency", noise);
			PbSetFloat(hPb, "duration", duration);
			EndMessage();
		}
#endif
	}
	return 0;
}

public Native_War3_SpawnPlayer(Handle:plugin,numParams)
{
	if(MapChanging || War3SourcePause) return 0;

	new client=GetNativeCell(1);
	new ignore_check=GetNativeCell(2);
	if(ValidPlayer(client,false) && (ignore_check!=0 || !IsPlayerAlive(client)))
	{
		//War3Respawn(client);
#if (GGAMETYPE == GGAME_TF2)
		TF2_RespawnPlayer(client);
#elseif (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
		CS_RespawnPlayer(client);
#endif
	}
	return 0;
}


#if (GGAMETYPE == GGAME_TF2)
public Native_War3_IsUbered(Handle:plugin,numParams)
{
	if(MapChanging || War3SourcePause) return false;

	new client = GetNativeCell(1);
	new m_nPlayerCond = FindSendPropInfo("CTFPlayer","m_nPlayerCond") ;
	new cond = GetEntData(client, m_nPlayerCond);
	if(cond & 32)
	{
		return true;
	}
	return false;
}

public Native_War3_HasFlag(Handle:plugin,numParams)
{
	if(MapChanging || War3SourcePause) return false;

	new client = GetNativeCell(1);
	new ent = -1;
	while ((ent = FindEntityByClassname(ent, "item_teamflag")) != -1)
	{
		if (GetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity")==client)
			return true;
	}
	return false;
}

public Native_War3_IsCloaked(Handle:plugin,numParams)
{
	if(MapChanging || War3SourcePause) return false;

	new client = GetNativeCell(1);
	new m_nPlayerCond = FindSendPropInfo("CTFPlayer","m_nPlayerCond") ;
	new cond = GetEntData(client, m_nPlayerCond);
	if(cond & 16)
	{
		return true;
	}
	return false;
}

public Native_War3_TF_PTC(Handle:plugin,numParams)
{
	if(MapChanging || War3SourcePause) return 0;

	new client = GetNativeCell(1);
	new String:str[32];
	GetNativeString(2, str, sizeof(str));
	new Float:pos[3];
	GetNativeArray(3,pos,3);
	return TE_ParticleToClient(client,str,pos);
}

stock TE_ParticleToClient(client,String:Name[],Float:origin[3]=NULL_VECTOR,Float:start[3]=NULL_VECTOR,
		Float:angles[3]=NULL_VECTOR,entindex=-1,attachtype=-1,attachpoint=-1,bool:resetParticles=true,
		Float:delay=0.0)
{
	// translation buffter
	char wcstbuffer[128];
	// find string table
	new tblidx = FindStringTable("ParticleEffectNames");
	if (tblidx==INVALID_STRING_TABLE)
	{
		Format(wcstbuffer, sizeof(wcstbuffer), "[War3Source:EVO] %t","Could not find string table: ParticleEffectNames");
		LogError(wcstbuffer);
		return 0;
	}

	// find particle index
	new String:tmp[256];
	new count = GetStringTableNumStrings(tblidx);
	new stridx = INVALID_STRING_INDEX;
	new i;
	for (i=0; i<count; i++)
	{
		ReadStringTable(tblidx, i, tmp, sizeof(tmp));
		if (StrEqual(tmp, Name, false))
		{
			stridx = i;
			break;
		}
	}
	if (stridx==INVALID_STRING_INDEX)
	{
		Format(wcstbuffer, sizeof(wcstbuffer), "[War3Source:EVO] %T","Could not find particle: {name}",LANG_SERVER,Name);
		LogError(wcstbuffer);
		return 0;
	}

	TE_Start("TFParticleEffect");
	TE_WriteFloat("m_vecOrigin[0]", origin[0]);
	TE_WriteFloat("m_vecOrigin[1]", origin[1]);
	TE_WriteFloat("m_vecOrigin[2]", origin[2]);
	TE_WriteFloat("m_vecStart[0]", start[0]);
	TE_WriteFloat("m_vecStart[1]", start[1]);
	TE_WriteFloat("m_vecStart[2]", start[2]);
	TE_WriteVector("m_vecAngles", angles);
	TE_WriteNum("m_iParticleSystemIndex", stridx);
	if (entindex!=-1)
	{
		TE_WriteNum("entindex", entindex);
	}
	if (attachtype!=-1)
	{
		TE_WriteNum("m_iAttachType", attachtype);
	}
	if (attachpoint!=-1)
	{
		TE_WriteNum("m_iAttachmentPointIndex", attachpoint);
	}
	TE_WriteNum("m_bResetParticles", resetParticles ? 1 : 0);
	if(client==0)
	{
		War3_internal_TE_SendToAll(delay);
	}
	else
	{
		War3_internal_TE_SendToClient(client, delay);
	}
	return 0;
}
#endif

#if (GGAMETYPE == GGAME_FOF)
public void War3Source_000_Engine_Misc_OnMapStart()
{
	CFoF_Player_m_iHealth = FindSendPropInfo("CFoF_Player","m_iHealth");
	if (CFoF_Player_m_iHealth < 0 )
	{
		LogError("CFoF_Player_m_iHealth = %i",  CFoF_Player_m_iHealth);
	}
}
public void War3Source_000_Engine_Misc_OnPluginStart()
{
	CFoF_Player_m_iHealth = FindSendPropInfo("CFoF_Player","m_iHealth");
	if (CFoF_Player_m_iHealth < 0 )
	{
		LogError("CFoF_Player_m_iHealth = %i",  CFoF_Player_m_iHealth);
	}
}

public bool CFoF_Player_m_iHealth_Set(int entity, int health)
{
	//War3_ChatMessage(entity, "CFoF_Player_m_iHealth_Set = %i", CFoF_Player_m_iHealth);
	if(entity <= 0)
	{
		return false;
	}
/*
	if(CFoF_Player_m_iHealth < 0)
	{
		return false;
	}
*/
	int currenthp = GetEntData(entity, CFoF_Player_m_iHealth, 4);

	//War3_ChatMessage(entity, "currenthp = %i", currenthp);
	//War3_ChatMessage(entity, "health = %i", health);
	if (currenthp == health)
	{
		return false;
	}

	SetEntData(entity, CFoF_Player_m_iHealth, health, 4, true);

	if (currenthp < health)
	{
		//War3_ChatMessage(entity, "currenthp < health");
		return true;
	}

	//War3_ChatMessage(entity, "false");
	return false;

}
#endif

public Native_War3_HTMHP(Handle:plugin,numParams)
{
	if(MapChanging || War3SourcePause) return false;

	int client = GetNativeCell(1);
	int addhp = GetNativeCell(2);
	int maxhp = War3_GetMaxHP(client);
	int currenthp=GetClientHealth(client);
	//War3_ChatMessage(client,"addhp = %i",addhp);
	//War3_ChatMessage(client,"War3_GetMaxHP = %i",maxhp);
	//War3_ChatMessage(client,"GetClientHealth = %i",currenthp);
	//do not make hp lower
	if(currenthp<maxhp)
	{ 
		int newhp=GetClientHealth(client)+addhp;
		if (newhp>maxhp)
		{
			newhp=maxhp;
		}
#if (GGAMETYPE == GGAME_FOF)
		CFoF_Player_m_iHealth_Set(client,newhp);
#else
		return nsEntity_SetHealth(client,newhp);
#endif
	}
	return false;
}

public Native_War3_HTBHP(Handle:plugin,numParams)
{
	if(MapChanging || War3SourcePause) return 0;

	new client = GetNativeCell(1);
	new addhp = GetNativeCell(2);
	new maxhp=RoundFloat(float(War3_GetMaxHP(client))*1.5);
	new currenthp=GetClientHealth(client);
	if(currenthp<maxhp){ ///do not make hp lower
		new newhp=GetClientHealth(client)+addhp;
		if (newhp>maxhp){
			newhp=maxhp;
		}
#if (GGAMETYPE == GGAME_FOF)
		CFoF_Player_m_iHealth_Set(client,newhp);
#else
		return nsEntity_SetHealth(client,newhp);
#endif
	}

	return 0;
}

public Native_War3_DecreaseHP(Handle:plugin,numParams)
{
	if(MapChanging || War3SourcePause) return 0;

	new client = GetNativeCell(1);
	new dechp = GetNativeCell(2);
	new newhp=GetClientHealth(client)-dechp;
	if(newhp<1){
		newhp=1;
	}
#if (GGAMETYPE == GGAME_FOF)
	CFoF_Player_m_iHealth_Set(client,newhp);
#else
	nsEntity_SetHealth(client,newhp);
#endif

	return 0;
}

public NW3IsDeveloper(Handle:plugin,numParams)
{
	if(MapChanging) return false;

	new client=GetNativeCell(1); //offical W3 developers
	if(ValidPlayer(client)){
		return GetPlayerProp(client,isDeveloper);
	}
	return false;
}

public NW3IsHelper(Handle:plugin,numParams)
{
	if(MapChanging) return false;

	new client=GetNativeCell(1); //offical W3 Helpers
	if(ValidPlayer(client)){
		return GetPlayerProp(client,isOfficalW3E);
	}
	return false;
}


public any internal_W3GetVar(any param1)
{
	return W3VarArr[param1];
}
public NW3GetVar(Handle:plugin,numParams)
{
	return _:W3VarArr[War3Var:GetNativeCell(1)];
}
public void internal_W3SetVar(any param1, any param2)
{
	W3VarArr[param1]=param2;
}
public NW3SetVar(Handle:plugin,numParams){
	W3VarArr[War3Var:GetNativeCell(1)]=GetNativeCell(2);
}

public GetStatsVersion(){
	//return W3GetStatsVersion();
}

public NW3HasDiedThisFrame(Handle:plugin,numParams){
	if(MapChanging) return 0;

	new client=GetNativeCell(1);
	return ValidPlayer(client)&&bHasDiedThisFrame[client];
}
