// War3Source_Engine_Easy_Buff.sp

/*
public Plugin:myinfo =
{
	name = "War3Source - Engine - EasyBuff",
	author = "War3Source Team and updated by El Diablo",
	description = "Easily link together skills + buffs in War3Source"
};
*/

// EasyBuffs for skills
new Handle:g_hSkillBuffs = INVALID_HANDLE; // Holds the W3Buff
new Handle:g_hBuffSkillValues = INVALID_HANDLE; // Holds the values
new Handle:g_hBuffRace = INVALID_HANDLE; // Holds the race id
new Handle:g_hBuffSkill = INVALID_HANDLE; // Holds the skill id

// EasyBuffs auras
new Handle:g_hAuraId = INVALID_HANDLE;
new Handle:g_hAuraDistance = INVALID_HANDLE;
new Handle:g_hAuraImmunity = INVALID_HANDLE;

#if GGAMEMODE == MODE_WAR3SOURCE
// EasyBuffs for items
new Handle:g_hItemBuffs = INVALID_HANDLE;  // Holds the W3Buff
new Handle:g_hItemBuffValue = INVALID_HANDLE; // Holds the value
new Handle:g_hBuffItem = INVALID_HANDLE; // Holds the item id
#endif

public bool:War3Source_Engine_Easy_Buff_InitNatives()
{
	CreateNative("War3_AddSkillBuff", Native_War3_AddSkillBuff);
	CreateNative("War3_AddAuraSkillBuff", Native_War3_AddSkillAuraBuff);
#if GGAMEMODE == MODE_WAR3SOURCE
	CreateNative("War3_AddItemBuff", Native_War3_AddItemBuff);
#endif
	return true;
}

public War3Source_Engine_Easy_Buff_OnPluginStart()
{
	g_hSkillBuffs = CreateArray(1);
	g_hBuffSkillValues = CreateArray(32); // If your skill has more than 32 levels you're out of luck
	g_hBuffRace = CreateArray(1);
	g_hBuffSkill = CreateArray(1);

	g_hAuraId = CreateArray(1);
	g_hAuraDistance = CreateArray(32);
	g_hAuraImmunity = CreateArray(1);

#if GGAMEMODE == MODE_WAR3SOURCE
	g_hItemBuffs = CreateArray(1);
	g_hBuffItem = CreateArray(1);
	g_hItemBuffValue = CreateArray(1);
#endif
}

AddSkillBuff()
{
	new iRace = GetNativeCell(1);
	new iSkill = GetNativeCell(2);
	new W3Buff:buff = W3Buff:GetNativeCell(3);

	for(new i = 0; i < GetArraySize(g_hSkillBuffs); i++)
	{
		if(GetArrayCell(g_hBuffRace, i) == iRace &&
		   GetArrayCell(g_hBuffSkill, i) == iSkill &&
		   GetArrayCell(g_hSkillBuffs, i) == buff)
		{
			// Change Skill Values (So Races can have Reloading)
			int iSkillMaxLevel = GetRaceSkillMaxLevel(iRace, iSkill) + 1;

			//example of dynamic variable creation:
			//int[] players = new int[MaxClients + 1];

			any[] values = new any[iSkillMaxLevel];
			GetNativeArray(4, values, iSkillMaxLevel);

			SetArrayArray(g_hBuffSkillValues, i, values, iSkillMaxLevel);

			//PrintToServer("[SKILL] Buff Reloading? Setting Buff Possible New Skill Values %i for skill \"{skill %i}\" in \"{race %i}\": Already exists!", buff, iSkill, iRace);
			return i;
		}
	}
	PushArrayCell(g_hBuffRace, iRace);
	PushArrayCell(g_hBuffSkill, iSkill);
	PushArrayCell(g_hSkillBuffs, buff);

	new iSkillMaxLevel = GetRaceSkillMaxLevel(iRace, iSkill) + 1;

	new any:values[iSkillMaxLevel];
	GetNativeArray(4, values, iSkillMaxLevel);

	PushArrayArray(g_hBuffSkillValues, values);

	//PrintToServer("[SKILL] Created buff %i for skill \"{skill %i}\" in \"{race %i}\"", buff, iSkill, iRace);

	return -1;
}

public Native_War3_AddSkillBuff(Handle:plugin, numParams)
{
	new AddSkillBuffNumber=AddSkillBuff();
	if(AddSkillBuffNumber==-1)
	{
		// This ain't a aura
		PushArrayCell(g_hAuraId, -1);
		new any:values[1];
		PushArrayArray(g_hAuraDistance, values);
		PushArrayCell(g_hAuraImmunity, Immunity_None);
		//PrintToServer("This ain't a aura Skill Native_War3_AddSkillBuff");
	}
	else //reloading skill
	{
		SetArrayCell(g_hAuraId, AddSkillBuffNumber, -1);
		new any:values[1];
		SetArrayArray(g_hAuraDistance, AddSkillBuffNumber, values);
		SetArrayCell(g_hAuraImmunity, AddSkillBuffNumber, Immunity_None);
		//PrintToServer("Reloading This ain't a aura Skill Native_War3_AddSkillBuff");
	}
}

public Native_War3_AddSkillAuraBuff(Handle:plugin, numParams)
{
	new AddSkillBuffNumber=AddSkillBuff();
	if(AddSkillBuffNumber==-1)
	{
		decl String:auraShortName[32];
		GetNativeString(5, auraShortName, sizeof(auraShortName));
		new iDistanceArraySize = GetNativeCell(7);
		new bool:bTrackOtherTeam = GetNativeCell(8);
		new War3Immunity:ImmunityCheck = GetNativeCell(9);

		new iAuraID = W3RegisterChangingDistanceAura(auraShortName, bTrackOtherTeam);
		PushArrayCell(g_hAuraId, iAuraID);

		iDistanceArraySize += 1;
		new any:values[iDistanceArraySize];
		GetNativeArray(6, values, iDistanceArraySize);
		PushArrayArray(g_hAuraDistance, values);

		PushArrayCell(g_hAuraImmunity, ImmunityCheck);

		//PrintToServer("[AURA] Registered aura ID %i", iAuraID);
	}
	else  //reloading skill
	{
		decl String:auraShortName[32];
		GetNativeString(5, auraShortName, sizeof(auraShortName));
		new iDistanceArraySize = GetNativeCell(7);
		new bool:bTrackOtherTeam = GetNativeCell(8);
		new War3Immunity:ImmunityCheck = GetNativeCell(9);

		new iAuraID = W3RegisterChangingDistanceAura(auraShortName, bTrackOtherTeam);
		SetArrayCell(g_hAuraId, AddSkillBuffNumber, iAuraID);

		iDistanceArraySize += 1;
		new any:values[iDistanceArraySize];
		GetNativeArray(6, values, iDistanceArraySize);
		SetArrayArray(g_hAuraDistance, AddSkillBuffNumber, values, iDistanceArraySize);

		SetArrayCell(g_hAuraImmunity, AddSkillBuffNumber, ImmunityCheck);
		//PrintToServer("[AURA] Reloading Registered aura ID %i", iAuraID);
	}
}

#if GGAMEMODE == MODE_WAR3SOURCE
public Native_War3_AddItemBuff(Handle:plugin, numParams)
{
	new iItem = GetNativeCell(1);
	new W3Buff:buff = W3Buff:GetNativeCell(2);

	for(new i = 0; i < GetArraySize(g_hItemBuffs); i++)
	{
		if(GetArrayCell(g_hBuffItem, i) == iItem &&
		   GetArrayCell(g_hItemBuffs, i) == buff)
		{
			//DP("[ITEM] Skipping buff %i for item \"{item %i}\": Already exists!", buff, iItem);
			return;
		}
	}

	PushArrayCell(g_hBuffItem, iItem);
	PushArrayCell(g_hItemBuffs, buff);

	new any:value = GetNativeCell(3);
	PushArrayCell(g_hItemBuffValue, value);

	//DP("[ITEM] Created buff %i for item \"{item %i}\"", buff, iItem);
}
#endif

/* SKILLS */

public War3Source_Engine_Easy_Buff_OnWar3EventSpawn(client)
{
	InitSkills(client, GetRace(client));
}

public War3Source_Engine_Easy_Buff_OnSkillLevelChanged(client, race, skill, newskilllevel)
{
	InitSkills(client, race);
}

public War3Source_Engine_Easy_Buff_OnWar3EventDeath(victim, client, deathrace)
{
	ResetSkills(victim, deathrace);
}

public War3Source_Engine_Easy_Buff_OnRaceChanged(client, oldrace, newrace)
{
	ResetSkills(client, oldrace);
	InitSkills(client, newrace);
}

ResetSkills(client, race)
{
	for(new i = 0; i < GetArraySize(g_hSkillBuffs); i++)
	{
		if(GetArrayCell(g_hBuffRace, i) == race)
		{
			new iAuraID = GetArrayCell(g_hAuraId, i);

			if (iAuraID == -1)
			{
				new W3Buff:buff = W3Buff:GetArrayCell(g_hSkillBuffs, i);
				//PrintToServer("[SKILL] Resetting the buff %i from race \"{race %i}\" on \"{client %i}\"", buff, race, client);

				W3ResetBuffRace(client, buff, race);
			}
			else
			{
				//PrintToServer("[AURA] Turning off aura %i from race \"{race %i}\" on \"{client %i}\"", iAuraID, race, client);

				W3RemovePlayerAura(iAuraID, client);
			}
		}
	}
}

InitSkills(client, race)
{
	if(race<=0) return;

	for(new i = 0; i < GetArraySize(g_hSkillBuffs); i++)
	{
		if(GetArrayCell(g_hBuffRace, i) == race)
		{
			new iAuraID = GetArrayCell(g_hAuraId, i);
			new iSkill = GetArrayCell(g_hBuffSkill, i);
			new iLevel = GetSkillLevel(client, race, iSkill);

			// Not a aura
			if (iAuraID == -1)
			{
				new W3Buff:buff = W3Buff:GetArrayCell(g_hSkillBuffs, i);
				new any:value = any:GetArrayCell(g_hBuffSkillValues, i, iLevel);
				//if(buff==fArmorPhysical)
				//{
					//PrintToServer("Apply Armor Physical buff");
				//}
				//if(buff==fArmorMagic)
				//{
					//PrintToServer("Apply Armor Magicl buff");
				//}
				//PrintToServer("[SKILL] Giving buff %i with a magnitude of %f to player \"{client %i}\" (Playing race \"{race %i}\" with skill \"{skill %i}\" at level %i)", buff, value, client, race, iSkill, iLevel);

				SetBuffRace(client, buff, race, value);
			}
			else
			{
				//PrintToServer("[AURA] Activating aura %i on player \"{client %i}\" (Playing race \"{race %i}\" with skill \"{skill %i}\" at level %i)", iAuraID, client, race, iSkill, iLevel);

				new Float:value = Float:GetArrayCell(g_hAuraDistance, i, iLevel);
				W3SetPlayerAura(iAuraID, client, value, iLevel);
			}
		}
	}
}

public OnW3PlayerAuraStateChanged(client, tAuraID, bool:inAura, level, AuraStack, AuraOwner)
{
	for(new i = 0; i < GetArraySize(g_hSkillBuffs); i++)
	{
		if(GetArrayCell(g_hAuraId, i) == tAuraID)
		{
			new race = GetArrayCell(g_hBuffRace, i);
			new W3Buff:buff = W3Buff:GetArrayCell(g_hSkillBuffs, i);
			new War3Immunity:ImmunityCheck = War3Immunity:GetArrayCell(g_hAuraImmunity, i);

			//new iSkill = GetArrayCell(g_hBuffSkill, i);

			if(AuraStack>0)
			{
				if(!W3HasImmunity(client,ImmunityCheck))
				{
					new any:value = any:GetArrayCell(g_hBuffSkillValues, i, level);

					SetBuffRace(client, buff, race, value, AuraOwner);
					//PrintToServer("[AURA] Giving buff %i with a magnitude of %f to player \"{client %i}\" (Aura from skill \"{skill %i}\" of race \"{race %i}\" at level %i)", buff, value, client, iSkill, race, level);
				}
				else
				{
					War3_NotifyPlayerImmuneFromSkill(AuraOwner, client, GetArrayCell(g_hBuffSkill, i));
				}
			}
			else
			{
				W3ResetBuffRace(client, buff, race);
				//PrintToServer("[AURA] Resetting the buff %i caused by skill \"{skill %i}\" of race \"{race %i}\" on \"{client %i}\"", buff, iSkill, race, client);
			}
		}
	}
}

#if GGAMEMODE == MODE_WAR3SOURCE
/* ITEMS */

public OnItemPurchase(client, item)
{
	InitItems(client, item);
	//DP("InitItems(%d,%d)",client, item);
}

public OnItemLost(client, item)
{
	ResetItems(client, item);
	//DP("ResetItems(%d,%d)",client, item);
}

ResetItems(client, item)
{
	for(new i = 0; i < GetArraySize(g_hItemBuffs); i++)
	{
		if(GetArrayCell(g_hBuffItem, i) == item)
		{
			new W3Buff:buff = W3Buff:GetArrayCell(g_hItemBuffs, i);
			//DP("[ITEM] Resetting the buff %i from item \"{item %i}\" on \"{client %i}\"", buff, item, client);
			War3_NotifyPlayerItemActivated(client,item,false);
			W3ResetBuffItem(client, buff, item);
		}
	}
}

InitItems(client, item)
{
	for(new i = 0; i < GetArraySize(g_hItemBuffs); i++)
	{
		if(GetArrayCell(g_hBuffItem, i) == item)
		{
			new any:value = any:GetArrayCell(g_hItemBuffValue, i);
			new W3Buff:buff = W3Buff:GetArrayCell(g_hItemBuffs, i);

			//DP("[ITEM] Giving buff %i with a magnitude of %f to player \"{client %i}\" (Owning item \"{item %i}\")", buff, value, client, item);
			War3_NotifyPlayerItemActivated(client,item,true);
			SetBuffItem(client, buff, item, value);
		}
	}
}
#endif
