// War3Source_Engine_BuffSystem.sp

#define PLUGIN_VERSION "3.0"

//for debuff index, see constants, its in an enum
any buffdebuff[MAXPLAYERSCUSTOM][W3Buff][MAXITEMS+MAXITEMS2+MAXITEMS3+MAXRACES+MAXSKILLS+CUSTOMMODIFIERS]; ///a race may only modify a property once

int BuffProperties[W3Buff][W3BuffProperties];

any BuffCached[MAXPLAYERSCUSTOM][W3Buff];// instead of looping, we cache everything in the last dimension, see enum W3BuffCache

/*
public Plugin:myinfo=
{
	name="War3Source Buff System",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};
*/

public War3Source_Engine_BuffSystem_OnPluginStart()
{
	//CreateConVar("BuffSystem",PLUGIN_VERSION,"War3Source:EVO Buff System",FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	InitiateBuffPropertiesArray(BuffProperties);
}

public bool:War3Source_Engine_BuffSystem_InitNatives()
{

	CreateNative("War3_SetBuff",Native_War3_SetBuff);//for races
	CreateNative("War3_SetBuffRace",Native_War3_SetBuffRace);//for races
	CreateNative("War3_SetBuffSkill",Native_War3_SetBuffSkill);//for skills without races
	CreateNative("War3_SetBuffItem",Native_War3_SetBuffItem);//foritems
	CreateNative("War3_SetBuffItem2",Native_War3_SetBuffItem2);//foritems
	CreateNative("War3_SetBuffItem3",Native_War3_SetBuffItem3);//foritems

	CreateNative("War3_ShowBuffs",Native_War3_ShowBuffs);//foritems
#if (GGAMETYPE == GGAME_TF2)
	CreateNative("War3_ShowSpeedBuff",Native_War3_ShowSpeedBuff);//foritems
#endif


	CreateNative("W3BuffCustomOFFSET",NW3BuffCustomOFFSET);

	CreateNative("W3GetPhysicalArmorMulti",NW3GetPhysicalArmorMulti);
	CreateNative("W3GetMagicArmorMulti",NW3GetMagicArmorMulti);


	CreateNative("W3GetBuff",NW3GetBuff);
	CreateNative("W3GetBuffSumInt",NW3GetBuffSumInt);
	CreateNative("W3GetBuffHasTrue",NW3GetBuffHasTrue);
	CreateNative("W3GetBuffStackedFloat",NW3GetBuffStackedFloat);

	CreateNative("W3GetBuffSumFloat",NW3GetBuffSumFloat);
	CreateNative("W3GetBuffMinFloat",NW3GetBuffMinFloat);
	CreateNative("W3GetBuffMaxFloat",NW3GetBuffMaxFloat);

	CreateNative("W3GetBuffMinInt",NW3GetBuffMinInt);
	CreateNative("W3GetBuffLastValue",NW3GetBuffLastValue);

	CreateNative("W3ResetAllBuffRace",NW3ResetAllBuffRace);
	CreateNative("W3ResetBuffRace",NW3ResetBuffRace);
	CreateNative("W3ResetBuffItem",NW3ResetBuffItem);

	CreateNative("W3GetBuffLoopLimit",NW3GetBuffLoopLimit);

	return true;
}
stock int ItemsPlusRacesPlusSkillsLoaded()
{
#if SHOPMENU3 == MODE_ENABLED
	return totalItemsLoaded+totalItems2Loaded+totalItems3Loaded+totalSkillsLoaded+totalRacesLoaded+CUSTOMMODIFIERS;
#else
	return totalItemsLoaded+totalItems2Loaded+totalSkillsLoaded+totalRacesLoaded+CUSTOMMODIFIERS;
#endif
}
public NW3BuffCustomOFFSET(Handle:plugin,numParams)
{
	return (ItemsPlusRacesPlusSkillsLoaded()-CUSTOMMODIFIERS);
}
public Native_War3_ShowBuffs(Handle:plugin,numParams) //buff is from an item
{
	if(numParams==1) //client,race,buffindex,value
	{
		int client=GetNativeCell(1);
		if(!IsFakeClient(client))
		{
			ShowAttackSpeed(client);
			ShowArmorMagic(client);
			ShowArmorPhysical(client);
			ShowInvisBuff(client);
			ShowRegenBuff(client);
			ShowVampireBuff(client);
#if (GGAMETYPE == GGAME_TF2)
			ShowSpeedBuff(client,true);
#endif
		}
	}
}
// This is mainly part of the Cyborg Medic Job, as nothing else currently uses this buff information as a native:
#if (GGAMETYPE == GGAME_TF2)
public Native_War3_ShowSpeedBuff(Handle:plugin,numParams) //buff is from an item
{
	if(numParams==1) //client,race,buffindex,value
	{
		int client=GetNativeCell(1);
		ShowSpeedBuff(client,true);
	}
}
#endif

stock void SetBuffItem(int client,W3Buff buffindex,int itemid,any value,int buffowner=-1)
{
	internal_SetBuffAny(client,buffindex,itemid,value,buffowner);
}

public Native_War3_SetBuffItem(Handle:plugin,numParams) //buff is from an item
{
	if(numParams>=4) //client,race,buffindex,value
	{
		int client=GetNativeCell(1);
		W3Buff buffindex=GetNativeCell(2);
		int itemid=GetNativeCell(3);
		any value=GetNativeCell(4);
		int buffowner=GetNativeCell(5);
		SetBuffItem(client,buffindex,itemid,value,buffowner); //not offseted
	}
}

stock void SetBuffItem2(int client,W3Buff buffindex,int itemid,any value,int buffowner=-1)
{
	internal_SetBuffAny(client,buffindex,totalItemsLoaded+itemid,value,buffowner); //not offseted
}

public Native_War3_SetBuffItem2(Handle:plugin,numParams) //buff is from an item
{
	if(numParams>=4) //client,race,buffindex,value
	{
		int client=GetNativeCell(1);
		W3Buff buffindex=GetNativeCell(2);
		int itemid=GetNativeCell(3);
		any value=GetNativeCell(4);
		int buffowner=GetNativeCell(5);
		SetBuffItem2(client,buffindex,itemid,value,buffowner); //not offseted
	}
}

stock SetBuffItem3(client,W3Buff:buffindex,itemid,any:value,buffowner=-1)
{
	internal_SetBuffAny(client,buffindex,totalItemsLoaded+totalItems2Loaded+itemid,value,buffowner); //not offseted
}

public Native_War3_SetBuffItem3(Handle:plugin,numParams) //buff is from an item
{
	if(numParams>=4) //client,race,buffindex,value
	{
		int client=GetNativeCell(1);
		W3Buff buffindex=GetNativeCell(2);
		int itemid=GetNativeCell(3);
		any value=GetNativeCell(4);
		int buffowner=GetNativeCell(5);
		SetBuffItem3(client,buffindex,itemid,value,buffowner); //not offseted
	}
}

stock SetBuffRace(client,W3Buff:buffindex,raceid,any:value,buffowner=-1)
{
#if SHOPMENU3 == MODE_ENABLED
	internal_SetBuffAny(client,buffindex,totalItemsLoaded+totalItems2Loaded+totalItems3Loaded+raceid,value,buffowner);
#else
	internal_SetBuffAny(client,buffindex,totalItemsLoaded+totalItems2Loaded+raceid,value,buffowner);
#endif
}

public Native_War3_SetBuff(Handle:plugin,numParams)
{
	if(numParams>=4) //client,race,buffindex,value
	{
		int client=GetNativeCell(1);
		W3Buff buffindex=GetNativeCell(2);
		int raceid=GetNativeCell(3);
		any value=GetNativeCell(4);
		int buffowner=GetNativeCell(5);
		SetBuffRace(client,buffindex,raceid,value,buffowner);
	}
}

public Native_War3_SetBuffRace(Handle:plugin,numParams)
{
	if(numParams>=4) //client,race,buffindex,value
	{
		int client=GetNativeCell(1);
		W3Buff buffindex=GetNativeCell(2);
		int raceid=GetNativeCell(3);
		any value=GetNativeCell(4);
		int buffowner=GetNativeCell(5);
		SetBuffRace(client,buffindex,raceid,value,buffowner); //ofsetted
	}
}

stock SetBuffSkill(int client,W3Buff buffindex,int skillid,any value,int buffowner=-1)
{
#if SHOPMENU3 == MODE_ENABLED
	internal_SetBuffAny(client,buffindex,totalItemsLoaded+totalItems2Loaded+totalItems3Loaded+totalRacesLoaded+skillid,value,buffowner);
#else
	internal_SetBuffAny(client,buffindex,totalItemsLoaded+totalItems2Loaded+totalRacesLoaded+skillid,value,buffowner);
#endif
}

public Native_War3_SetBuffSkill(Handle:plugin,numParams)
{
	if(numParams>=4) //client,race,buffindex,value
	{
		int client=GetNativeCell(1);
		W3Buff buffindex=GetNativeCell(2);
		int skillid=GetNativeCell(3);
		any value=GetNativeCell(4);
		int buffowner=GetNativeCell(5);
		SetBuffSkill(client,buffindex,skillid,value,buffowner); //ofsetted
	}
}

stock any GetBuff(int client,W3Buff buffindex,int RaceIDorItemID,bool IPassedItemID=false)
{
	if(!IPassedItemID)
	{
		RaceIDorItemID+=totalItemsLoaded;
	}
	if(ValidBuff(buffindex))
	{
		return buffdebuff[client][buffindex][RaceIDorItemID];
	}
	else
	{
		ThrowError("invalidbuffindex");
	}
	return -1;
}

public NW3GetBuff(Handle:plugin,numParams)
{
	int client=GetNativeCell(1);
	W3Buff buffindex=GetNativeCell(2);
	int raceiditemid=GetNativeCell(3);
	bool isItem=GetNativeCell(4);
	return GetBuff(client,buffindex,raceiditemid,isItem);
}

public NW3GetBuffSumInt(Handle:plugin,numParams)
{
	int client=GetNativeCell(1);
	W3Buff buffindex=GetNativeCell(2);
	return GetBuffSumInt(client,buffindex);
}

//stop complaining that we are returning a float!
public NW3GetPhysicalArmorMulti(Handle:plugin,numParams)
{
	return _:PhysicalArmorMulti(GetNativeCell(1));
}
public NW3GetMagicArmorMulti(Handle:plugin,numParams)
{
	return _:MagicArmorMulti(GetNativeCell(1));
}
public NW3GetBuffLastValue(Handle:plugins,numParams)
{
	return GetBuffLastValue(GetNativeCell(1),GetNativeCell(2));
}
public NW3GetBuffHasTrue(Handle:plugin,numParams)
{
	//all one true bools are cached
	return _:GetBuffHasOneTrue(GetNativeCell(1),GetNativeCell(2)); //returns bool
}
public NW3GetBuffStackedFloat(Handle:plugin,numParams)
{
	return _:GetBuffStackedFloat(GetNativeCell(1),GetNativeCell(2)); //returns float usually
}
public NW3GetBuffSumFloat(Handle:plugin,numParams)
{
	return _:GetBuffSumFloat(GetNativeCell(1),GetNativeCell(2));
}
public NW3GetBuffMinFloat(Handle:plugin,numParams)
{
	return _:GetBuffMinFloat(GetNativeCell(1),GetNativeCell(2));
}
public NW3GetBuffMaxFloat(Handle:plugin,numParams)
{
	return _:GetBuffMaxFloat(GetNativeCell(1),GetNativeCell(2));
}
public NW3GetBuffMinInt(Handle:plugin,numParams)
{
	return GetBuffMinInt(GetNativeCell(1),GetNativeCell(2));
}

public NW3ResetAllBuffRace(Handle:plugin,numParams)
{
	new client=GetNativeCell(1);
	new race=GetNativeCell(2);

	for(new buffindex=0;buffindex<MaxBuffLoopLimit;buffindex++)
	{
		ResetBuffParticularRaceOrItem(client,W3Buff:buffindex,totalItemsLoaded+race);
	}
	//SOME NEEDS TO BE SET AGAIN TO REFRESH
}
public NW3ResetBuffRace(Handle:plugin,numParams)
{
	new client=GetNativeCell(1);
	new W3Buff:buffindex=W3Buff:GetNativeCell(2);
	new race=GetNativeCell(3);

	ResetBuffParticularRaceOrItem(client,W3Buff:buffindex,totalItemsLoaded+race);
}


public NW3ResetBuffItem(Handle:plugin,numParams)
{
  new client=GetNativeCell(1);
  new W3Buff:buffindex=W3Buff:GetNativeCell(2);
  new item=GetNativeCell(3);

  ResetBuffParticularRaceOrItem(client,W3Buff:buffindex,item);
}

public NW3GetBuffLoopLimit(Handle:plugin,numParams)
{
	return BuffLoopLimit();
}

public War3Source_Engine_BuffSystem_OnClientPutInServer(client)
{
	//reset all buffs for each race and item
	for(new buffindex=0;buffindex<MaxBuffLoopLimit;buffindex++)
	{
		ResetBuff(client,W3Buff:buffindex);
	}
}

#if (GGAMETYPE == GGAME_TF2)
int OldSpeedBuffValue2[MAXPLAYERSCUSTOM];
#endif
bool TimerSpeedBuff[MAXPLAYERSCUSTOM];
any Oldbuffdebuff[MAXPLAYERSCUSTOM][W3Buff][MAXITEMS+MAXITEMS2+MAXITEMS3+MAXRACES+MAXSKILLS+CUSTOMMODIFIERS];

stock internal_SetBuffAny(int client,W3Buff buffindex,int itemraceindex,any value,int buffowner=-1)
{
	buffdebuff[client][buffindex][itemraceindex]=value;

	// later add a AFTER BUFF EVENT

	if(buffindex==fMaxSpeed||buffindex==fMaxSpeed2||buffindex==fSlow||buffindex==fSlow2||buffindex==bStunned||buffindex==bBashed){
		Internal_W3ReapplySpeed(client);
	}
	DoCalculateBuffCache(client,buffindex,itemraceindex);


	internal_W3SetVar(EventArg1,buffindex); //generic war3event arguments
	internal_W3SetVar(EventArg2,itemraceindex);
	internal_W3SetVar(EventArg3,value);
	internal_W3SetVar(EventArg4,buffowner);
	DoFwd_War3_Event(W3EVENT:OnBuffChanged,client);

	if(ValidPlayer(client) && IsFakeClient(client))
		return;

	if(value==Oldbuffdebuff[client][buffindex][itemraceindex])
		return;
	// Tell client what's going on
	if(buffindex==fMaxSpeed||buffindex==fSlow||buffindex==fMaxSpeed2||buffindex==fSlow2)
	{
		if(TimerSpeedBuff[client]==true)
			return;
		TimerSpeedBuff[client]=true;
		if(ValidPlayer(client) && GetPlayerProp(client,iBuffChatInfo2)==1)
		{
			CreateTimer(0.2,SpeedBuffTimer,GetClientUserId(client));
		}
		Oldbuffdebuff[client][buffindex][itemraceindex]=value;
		return;
	}
	// Tell client what's going on
	if(buffindex==fInvisibilitySkill||buffindex==fInvisibilityItem)
	{
		if(ValidPlayer(client) && GetPlayerProp(client,iBuffChatInfo2)==1)
		{
			CreateTimer(0.2,InvisibilityTimer,GetClientUserId(client));
		}
		Oldbuffdebuff[client][buffindex][itemraceindex]=value;
		return;
	}
	// Tell client what's going on
	if(buffindex==fArmorPhysical)
	{
		if(ValidPlayer(client) && GetPlayerProp(client,iBuffChatInfo2)==1)
		{
			CreateTimer(0.2,PhysicalArmorSpeedTimer,GetClientUserId(client));
		}
		Oldbuffdebuff[client][buffindex][itemraceindex]=value;
		return;
	}
	// Tell client what's going on
	if(buffindex==fArmorMagic)
	{
		if(ValidPlayer(client) && GetPlayerProp(client,iBuffChatInfo2)==1)
		{
			CreateTimer(0.2,MagicalArmorSpeedTimer,GetClientUserId(client));
		}
		Oldbuffdebuff[client][buffindex][itemraceindex]=value;
		return;
	}
	// Tell client what's going on
	if(buffindex==fAttackSpeed)
	{
		if(ValidPlayer(client) && GetPlayerProp(client,iBuffChatInfo2)==1)
		{
			CreateTimer(0.2,AttackSpeedTimer,GetClientUserId(client));
		}
		Oldbuffdebuff[client][buffindex][itemraceindex]=value;
		return;
	}
	if(buffindex==fHPRegen)
	{
		if(ValidPlayer(client) && GetPlayerProp(client,iBuffChatInfo2)==1)
		{
			CreateTimer(0.2,RegenSpeedTimer,GetClientUserId(client));
		}
		Oldbuffdebuff[client][buffindex][itemraceindex]=value;
		return;
	}
	if(buffindex==fVampirePercent)
	{
		if(ValidPlayer(client) && GetPlayerProp(client,iBuffChatInfo2)==1)
		{
			CreateTimer(0.2,VampireTimer,GetClientUserId(client));
		}
		Oldbuffdebuff[client][buffindex][itemraceindex]=value;
		return;
	}
}

ShowInvisBuff(client)
{
	if(ValidPlayer(client))
	{
		new Float:currentAttribute=FloatAdd(Float:BuffCached[client][fInvisibilitySkill],Float:BuffCached[client][fInvisibilityItem]);
		if(currentAttribute>1.0)
			currentAttribute=FloatSub(currentAttribute,1.0);
		else
			currentAttribute=FloatSub(1.0,currentAttribute);
		currentAttribute=currentAttribute*100.0;
		new percentage=RoundToFloor(currentAttribute);
		if(currentAttribute>0.0 && currentAttribute<100.0)
			War3_ChatMessage(client,"You are now {green}%i{default} percent visibile.",percentage);
		else //if(currentAttribute==0.0)
			War3_ChatMessage(client,"You are now {green}100{default} percent visibile.");
	}
}
ShowArmorPhysical(client)
{
	if(ValidPlayer(client))
	{
		new Float:currentAttribute=Float:BuffCached[client][fArmorPhysical];
		new percentage=RoundToFloor(FloatMul(PhysicalArmorMulti(client),100.0));
		percentage=100-percentage;
		if(currentAttribute>0.0)
			War3_ChatMessage(client,"You now have {green}%i{default} percent physical armor damage reduction.",percentage);
		else if(currentAttribute==0.0)
			War3_ChatMessage(client,"You now have {green}0{default} percent physical armor damage reduction.");
	}
}
ShowArmorMagic(client)
{
	if(ValidPlayer(client))
	{
		new Float:currentAttribute=Float:BuffCached[client][fArmorMagic];
		new percentage=RoundToFloor(FloatMul(MagicArmorMulti(client),100.0));
		percentage=100-percentage;
		if(currentAttribute>0.0)
			War3_ChatMessage(client,"You now have {green}%i{default} percent magical armor damage reduction.",percentage);
		else if(currentAttribute==0.0)
			War3_ChatMessage(client,"You now have {green}0{default} percent magical armor damage reduction.");
	}
}
ShowAttackSpeed(client)
{
	if(ValidPlayer(client))
	{
		new Float:currentAttribute=Float:BuffCached[client][fAttackSpeed];
		if(currentAttribute>1.0)
			currentAttribute=FloatSub(currentAttribute,1.0);
		else
			currentAttribute=FloatSub(1.0,currentAttribute);
		currentAttribute=currentAttribute*100.0;
		new percentage=RoundToFloor(currentAttribute);
		if(currentAttribute!=1.0)
			War3_ChatMessage(client,"You now have {green}%i{default} percent attack speed buff.",percentage);
		else if(currentAttribute==1.0)
			War3_ChatMessage(client,"You now have {green}0{default} percent attack speed buff.");
	}
}
ShowVampireBuff(client)
{
	if(ValidPlayer(client))
	{
		new Float:currentAttribute=Float:BuffCached[client][fVampirePercent];
		if(currentAttribute>1.0)
			currentAttribute=FloatSub(currentAttribute,1.0);
		else
			currentAttribute=FloatSub(1.0,currentAttribute);
		currentAttribute=currentAttribute*100.0;
		new percentage=RoundToFloor(FloatSub(100.0,currentAttribute));
		if(currentAttribute>0.0)
			War3_ChatMessage(client,"You now gain {green}%i{default} percent damage as health.",percentage);
		else if(currentAttribute==0.0)
			War3_ChatMessage(client,"You now gain {green}0{default} percent damage as health.");
	}
}
ShowRegenBuff(client)
{
	if(ValidPlayer(client))
	{
		new Float:currentAttribute=Float:BuffCached[client][fHPRegen];
		new percentage=RoundToFloor(currentAttribute);
		if(currentAttribute>0.0)
			War3_ChatMessage(client,"You now gain {green}%i{default} hit points per second.",percentage);
		else if(currentAttribute==0.0)
			War3_ChatMessage(client,"You now gain {green}0{default} hit points per second.");
	}
}
#if (GGAMETYPE == GGAME_TF2)
ShowSpeedBuff(client,bool:bypass=false)
{
	if(ValidPlayer(client))
	{
		new Float:currentmaxspeed=GetEntDataFloat(client,FindSendPropInfo("CTFPlayer","m_flMaxspeed"));
		new Float:NEWcurrentmaxspeed=FloatDiv(currentmaxspeed,TF2_GetClassSpeed(TF2_GetPlayerClass(client)));
		if(NEWcurrentmaxspeed>1.0)
			NEWcurrentmaxspeed=FloatSub(NEWcurrentmaxspeed,1.0);
		else
			NEWcurrentmaxspeed=FloatSub(1.0,NEWcurrentmaxspeed);
		NEWcurrentmaxspeed=NEWcurrentmaxspeed*100.0;
		new percentage=RoundToFloor(NEWcurrentmaxspeed);
		if(OldSpeedBuffValue2[client]!=percentage||bypass)
		{
			if(currentmaxspeed>TF2_GetClassSpeed(TF2_GetPlayerClass(client)))
				War3_ChatMessage(client,"You move at {green}%i{default} percent {green}faster{default} than normal.",percentage);
			else if(currentmaxspeed<TF2_GetClassSpeed(TF2_GetPlayerClass(client)))
				War3_ChatMessage(client,"You move at {green}%i{default} percent {green}slower{default} than normal.",percentage);
			else if(currentmaxspeed==TF2_GetClassSpeed(TF2_GetPlayerClass(client)))
				War3_ChatMessage(client,"You move at {green}normal{default} speed.",percentage);
		}
		OldSpeedBuffValue2[client]=percentage;
	}
}
#endif

public War3Source_Engine_BuffSystem_OnRaceChanged(client, oldrace, newrace)
{
	if(ValidPlayer(client) && !IsFakeClient(client) && GetPlayerProp(client,iBuffChatInfo)==1)
	{
		DisplayBuffsTimer(GetClientUserId(client));
	}
}

//public Action:DisplayBuffsTimer(Handle:timer,any:userid)
DisplayBuffsTimer(any:userid)
{
	new client=GetClientOfUserId(userid);
	if(ValidPlayer(client))
	{
		War3_ChatMessage(client,"{lightgreen}Your new Buffs{default}:");
		War3_ShowBuffs(client);
	}
}

public Action:InvisibilityTimer(Handle:timer,any:userid)
{
	new client=GetClientOfUserId(userid);
	if(ValidPlayer(client))
	{
		ShowInvisBuff(client);
	}
}


public Action:RegenSpeedTimer(Handle:timer,any:userid)
{
	new client=GetClientOfUserId(userid);
	if(ValidPlayer(client))
	{
		ShowRegenBuff(client);
	}
}

public Action:VampireTimer(Handle:timer,any:userid)
{
	new client=GetClientOfUserId(userid);
	if(ValidPlayer(client))
	{
		ShowVampireBuff(client);
	}
}


public Action:PhysicalArmorSpeedTimer(Handle:timer,any:userid)
{
	new client=GetClientOfUserId(userid);
	if(ValidPlayer(client))
	{
		ShowArmorPhysical(client);
	}
}

public Action:MagicalArmorSpeedTimer(Handle:timer,any:userid)
{
	new client=GetClientOfUserId(userid);
	if(ValidPlayer(client))
	{
		ShowArmorMagic(client);
	}
}

public Action:AttackSpeedTimer(Handle:timer,any:userid)
{
	new client=GetClientOfUserId(userid);
	if(ValidPlayer(client))
	{
		ShowAttackSpeed(client);
	}
}

public Action:SpeedBuffTimer(Handle:timer,any:userid)
{
	new client=GetClientOfUserId(userid);
	if(ValidPlayer(client))
	{
#if (GGAMETYPE == GGAME_TF2)
		ShowSpeedBuff(client);
#endif
	}
	TimerSpeedBuff[client]=false;
}

///REMOVE SINGLE BUFF FROM ALL RACES
ResetBuff(client,W3Buff:buffindex){

	if(ValidBuff(buffindex))
	{
		int loop = ItemsPlusRacesPlusSkillsLoaded();
		for(int i=0;i<=loop;i++) //reset starts at 0
		{
			buffdebuff[client][buffindex][i]=BuffDefault(buffindex);

			DoCalculateBuffCache(client,buffindex,i);
		}
		Internal_W3ReapplySpeed(client);

	}
}
//RESET SINGLE BUFF OF SINGLE RACE
ResetBuffParticularRaceOrItem(client,W3Buff:buffindex,particularraceitemindex){
	if(ValidBuff(buffindex))
	{
		buffdebuff[client][buffindex][particularraceitemindex]=BuffDefault(buffindex);

		DoCalculateBuffCache(client,buffindex,particularraceitemindex);
		Internal_W3ReapplySpeed(client);
	}
}

DoCalculateBuffCache(client,W3Buff:buffindex,particularraceitemindex){
	///after we set it, we do an entire calculation to cache its value ( on selected buffs , mainly bools we test for HasTrue )
	switch(BuffCacheType(buffindex)){
		case DoNotCache: {}
		case bHasOneTrue: BuffCached[client][buffindex]=CalcBuffHasOneTrue(client,buffindex);
		case iAbsolute: BuffCached[client][buffindex]=CalcBuffSumInt(client,buffindex);
		case fAbsolute: BuffCached[client][buffindex]=CalcBuffSumFloat(client,buffindex);
		case fStacked: BuffCached[client][buffindex]=CalcBuffStackedFloat(client,buffindex);
		case fMaximum: BuffCached[client][buffindex]=CalcBuffMax(client,buffindex);
		case fMinimum: BuffCached[client][buffindex]=CalcBuffMin(client,buffindex);
		case iMinimum: BuffCached[client][buffindex]=CalcBuffMinInt(client,buffindex);
		case iLastValue: BuffCached[client][buffindex]=CalcBuffRecentValue(client,buffindex,particularraceitemindex);
	}
}


any:BuffDefault(W3Buff:buffindex){
	return BuffProperties[buffindex][DefaultValue];
}
BuffStackCacheType:BuffCacheType(W3Buff:buffindex){
	return BuffProperties[buffindex][BuffStackType];
}

////loop through the value of all items and races contributing values
stock any:CalcBuffMax(client,W3Buff:buffindex)
{
	if(ValidBuff(buffindex))
	{
		new any:value=buffdebuff[client][buffindex][0];
		int loop = ItemsPlusRacesPlusSkillsLoaded();
		for(new i=0;i<=loop;i++)
		{
			new any:value2=buffdebuff[client][buffindex][i];
			if(value2>value){
				value=value2;
			}
		}
		return value;
	}
	LogError("invalid buff index");
	return -1;
}
stock any:CalcBuffMin(client,W3Buff:buffindex)
{
	if(ValidBuff(buffindex))
	{
		new any:value=buffdebuff[client][buffindex][0];
		int loop = ItemsPlusRacesPlusSkillsLoaded();
		for(new i=0;i<=loop;i++)
		{
			new any:value2=buffdebuff[client][buffindex][i];
			if(value2<value){
				value=value2;
			}
		}
		return value;
	}
	LogError("invalid buff index");
	return -1;
}
CalcBuffMinInt(client,W3Buff:buffindex)
{
	if(ValidBuff(buffindex))
	{
		new value=buffdebuff[client][buffindex][0];
		int loop = ItemsPlusRacesPlusSkillsLoaded();
		for(new i=0;i<=loop;i++)
		{
			new value2=buffdebuff[client][buffindex][i];
			if(value2<value){
				value=value2;
			}
		}
		return value;
	}
	LogError("invalid buff index");
	return -1;
}
stock bool:CalcBuffHasOneTrue(client,W3Buff:buffindex)
{
	if(ValidBuff(buffindex))
	{
		int loop = ItemsPlusRacesPlusSkillsLoaded();
		for(new i=0;i<=loop;i++)
		{
			if(buffdebuff[client][buffindex][i])
			{
				return true;
			}
		}
		return false;

	}
	LogError("invalid buff index");
	return false;
}

//multiplied all the values together , only for floats
stock Float:CalcBuffStackedFloat(client,W3Buff:buffindex)
{
	if(ValidBuff(buffindex))
	{
		float value=buffdebuff[client][buffindex][0];
		int loop = ItemsPlusRacesPlusSkillsLoaded();
		for(int i=0;i<=loop;i++)
		{
			value=FloatMul(value,buffdebuff[client][buffindex][i]);
		}
		return value;
	}
	LogError("invalid buff index");
	return -1.0;
}


//all values added!
stock CalcBuffSumInt(client,W3Buff:buffindex)
{
	if(ValidBuff(buffindex))
	{
		any value=0;
		//this one starts from zero
		int loop = ItemsPlusRacesPlusSkillsLoaded();
		for(int i=0;i<=loop;i++)
		{
			value=value+buffdebuff[client][buffindex][i];
		}
		return value;
	}
	LogError("invalid buff index");
	return -1;
}

//all values added!
stock CalcBuffSumFloat(client,W3Buff:buffindex)
{
	if(ValidBuff(buffindex))
	{
		any value=0;
		//this one starts from zero
		int loop = ItemsPlusRacesPlusSkillsLoaded();
		for(int i=0;i<=loop;i++)
		{
			value=Float:value+Float:(buffdebuff[client][buffindex][i]);
		}
		return value;
	}
	LogError("invalid buff index");
	return -1;
}
//Returns the most recent value set by any race
stock CalcBuffRecentValue(client,W3Buff:buffindex,race)
{
	if(ValidBuff(buffindex))
	{
		new value = buffdebuff[client][buffindex][race];
		if(value!=-1)
		{
			return value;
		} else {
			return BuffCached[client][buffindex];
		}
	}
	LogError("invalid buff index");
	return -1;
}
////////getting cached values!
stock GetBuffLastValue(client,W3Buff:buffindex)
{
	if(ValidBuff(buffindex))
	{
		if(BuffCacheType(buffindex)!=iLastValue){
			ThrowError("Tried to get cached value when buff index (%d) should not cache this type (%d)",buffindex,BuffCacheType(buffindex));
		}
		return BuffCached[client][buffindex];
	}
	LogError("invalid buff index");
	return false;
}
stock bool:GetBuffHasOneTrue(client,W3Buff:buffindex)
{
	if(ValidBuff(buffindex))
	{
		if(BuffCacheType(buffindex)!=bHasOneTrue){
			ThrowError("Tried to get cached value when buff index (%d) should not cache this type (%d)",buffindex,BuffCacheType(buffindex));
		}
		return BuffCached[client][buffindex];
	}
	LogError("invalid buff index");
	return false;
}
stock Float:GetBuffStackedFloat(client,W3Buff:buffindex)
{
	if(ValidBuff(buffindex))
	{
		if(BuffCacheType(buffindex)!=fStacked){
			ThrowError("Tried to get cached value when buff index (%d) should not cache this type (%d)",buffindex,BuffCacheType(buffindex));
		}
		return BuffCached[client][buffindex];
	}
	LogError("invalid buff index");
	return 0.0;
}
stock GetBuffSumInt(client,W3Buff:buffindex)
{
	if(ValidBuff(buffindex))
	{
		if(BuffCacheType(buffindex)!=iAbsolute){
			ThrowError("Tried to get cached value when buff index (%d) should not cache this type (%d)",buffindex,BuffCacheType(buffindex));
		}
		return BuffCached[client][buffindex];
	}
	LogError("invalid buff index");
	return false;
}
stock Float:GetBuffSumFloat(client,W3Buff:buffindex)
{
	if(ValidBuff(buffindex))
	{
		if(BuffCacheType(buffindex)!=fAbsolute){
			ThrowError("Tried to get cached value when buff index (%d) should not cache this type (%d)",buffindex,BuffCacheType(buffindex));
		}
		if (ValidPlayer(client)) {
			return Float:BuffCached[client][buffindex];
		}
		else {
			return 0.0;
		}
	}
	LogError("invalid buff index");
	return 0.0;
}
stock Float:GetBuffMaxFloat(client,W3Buff:buffindex)
{
	if(ValidBuff(buffindex))
	{
		if(BuffCacheType(buffindex)!=fMaximum){
			ThrowError("Tried to get cached value when buff index (%d) should not cache this type (%d)",buffindex,BuffCacheType(buffindex));
		}
		return BuffCached[client][buffindex];
	}
	LogError("invalid buff index");
	return 0.0;
}
stock Float:GetBuffMinFloat(client,W3Buff:buffindex)
{
	if(ValidBuff(buffindex))
	{
		if(BuffCacheType(buffindex)!=fMinimum){
			ThrowError("Tried to get cached value when buff index (%d) should not cache this type (%d)",buffindex,BuffCacheType(buffindex));
		}
		return BuffCached[client][buffindex];
	}
	LogError("invalid buff index");
	return 0.0;
}
GetBuffMinInt(client,W3Buff:buffindex)
{
	if(ValidBuff(buffindex))
	{
		if(BuffCacheType(buffindex)!=iMinimum){
			ThrowError("Tried to get cached value when buff index (%d) should not cache this type (%d)",buffindex,BuffCacheType(buffindex));
		}
		return BuffCached[client][buffindex];
	}
	LogError("invalid buff index");
	return 0;
}

stock Float:PhysicalArmorMulti(client){
	new Float:armor=Float:GetBuffSumFloat(client,fArmorPhysical);
	//PrintToServer("physical armor=%f",armor);
	if(armor<0.0){
		armor=armor*-1.0;
		return ((armor*0.06)/(1.0+armor*0.06))+1.0;
	}
	return (1.0-(armor*0.06)/(1.0+armor*0.06));
}
stock Float:MagicArmorMulti(client){

	new Float:armor=Float:GetBuffSumFloat(client,fArmorMagic);
	//PrintToServer("magical armor=%f",armor);
	if(armor<0.0){
		armor=armor*-1.0;
		return ((armor*0.06)/(1.0+armor*0.06))+1.0;
	}
	return (1.0-(armor*0.06)/(1.0+armor*0.06));
}

//use 0 < limit
stock int BuffLoopLimit()
{
	//return totalItemsLoaded+totalRacesLoaded+1;
	return ItemsPlusRacesPlusSkillsLoaded();
}
