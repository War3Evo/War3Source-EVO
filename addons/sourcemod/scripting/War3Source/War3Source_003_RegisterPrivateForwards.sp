// War3Source_003_RegisterPrivateForwards.sp

public bool War3Source_003_RegisterPrivateForwards_InitNatives()
{
	CreateNative("W3Hook", Native_Hook);
	CreateNative("W3HookEx", Native_HookEx);
	CreateNative("W3Unhook", Native_Unhook);
	CreateNative("W3UnhookEx", Native_UnhookEx);
	CreateNative("W3UnhookAll", Native_UnhookAll);
	CreateNative("W3UnhookAllEx", Native_UnhookAllEx);

	return true;
}

ConVar disable_races_mapend = null;
ConVar enable_races_mapstart = null;

public void War3Source_003_RegisterPrivateForwards_OnPluginStart()
{
	disable_races_mapend = CreateConVar("war3_disable_races_mapend","1","Disable races on round end?");
	enable_races_mapstart = CreateConVar("war3_enable_races_mapstart","1","Enable races on round start?");
}

public void War3Source_003_RegisterPrivateForwards_OnMapStart()
{
	if(enable_races_mapstart.BoolValue)
	{
		for(new i=1;i<=MaxClients;i++)
		{
			if(ValidPlayer(i))
			{
				if(GetRace(i)>0)
				{
					EnableRace(i);
				}
			}
		}
	}
}

public void War3Source_003_RegisterPrivateForwards_OnMapEnd()
{
	if(disable_races_mapend.BoolValue)
	{
		for(new i=1;i<=MaxClients;i++)
		{
			if(ValidPlayer(i))
			{
				if(GetRace(i)>0)
				{
					DisableRace(i);
				}
			}
		}
	}
}


stock Handle GetW3HookType(W3HookType W3HOOKtype)
{
	switch(W3HOOKtype)
	{
		case W3Hook_OnW3TakeDmgAllPre:
		{
			return p_OnW3TakeDmgAllPre;
		}
		case W3Hook_OnW3TakeDmgBulletPre:
		{
			return p_OnW3TakeDmgBulletPre;
		}
		case W3Hook_OnW3TakeDmgAll:
		{
			return p_OnW3TakeDmgAll;
		}
		case W3Hook_OnW3TakeDmgBullet:
		{
			return p_OnW3TakeDmgBullet;
		}
		case W3Hook_OnWar3EventPostHurt:
		{
			return p_OnWar3EventPostHurt;
		}
		// command hook
		case W3Hook_OnUltimateCommand:
		{
			return p_OnUltimateCommand;
		}
		case W3Hook_OnAbilityCommand:
		{
			return p_OnAbilityCommand;
		}
		case W3Hook_OnUseItemCommand:
		{
			return p_OnUseItemCommand;
		}
		// others
		case W3Hook_OnWar3Event:
		{
			return p_War3GlobalEventFH;
		}
		case W3Hook_OnWar3EventSpawn:
		{
			return p_OnWar3EventSpawnFH;
		}
		case W3Hook_OnTalentsLoaded:
		{
			return p_OnTalentsLoaded;
		}
		case W3Hook_OnWar3SkinChange:
		{
			return p_OnWar3SkinChange;
		}
		case W3Hook_OnWar3SkillSlotChange:
		{
			return p_OnWar3SkillSlotChange;
		}
	}
	return null;
}

public int Native_Hook(Handle plugin, int numParams)
{
	W3HookType W3HOOKtype = GetNativeCell(1);

	Handle FwdHandle = GetW3HookType(W3HOOKtype);
	Function Func = GetNativeFunction(2);

	if(FwdHandle != null)
	{
		AddToForward(FwdHandle, plugin, Func);
	}
}

public int Native_HookEx(Handle plugin, int numParams)
{
	W3HookType W3HOOKtype = GetNativeCell(1);

	Handle FwdHandle = GetW3HookType(W3HOOKtype);
	Function Func = GetNativeFunction(2);

	if(FwdHandle != null)
	{
		return AddToForward(FwdHandle, plugin, Func);
	}
	return 0;
}

public int Native_Unhook(Handle plugin, int numParams)
{
	W3HookType W3HOOKtype = GetNativeCell(1);

	Handle FwdHandle = GetW3HookType(W3HOOKtype);

	if(FwdHandle != null)
	{
		RemoveFromForward(FwdHandle, plugin, GetNativeFunction(2));
	}
}
public int Native_UnhookEx(Handle plugin, int numParams)
{
	W3HookType W3HOOKtype = GetNativeCell(1);

	Handle FwdHandle = GetW3HookType(W3HOOKtype);

	if(FwdHandle != null)
	{
		return RemoveFromForward(FwdHandle, plugin, GetNativeFunction(2));
	}
	return 0;
}

public int Native_UnhookAll(Handle plugin, int numParams)
{
	W3HookType W3HOOKtype = GetNativeCell(1);

	Handle FwdHandle = GetW3HookType(W3HOOKtype);

	if(FwdHandle != null)
	{
		RemoveAllFromForward(FwdHandle, plugin);
	}
}
public int Native_UnhookAllEx(Handle plugin, int numParams)
{
	W3HookType W3HOOKtype = GetNativeCell(1);

	Handle FwdHandle = GetW3HookType(W3HOOKtype);

	if(FwdHandle != null)
	{
		return RemoveAllFromForward(FwdHandle, plugin);
	}
	return 0;
}
