// War3Source_002_OnW3SupplyLocker.sp

public War3Source_002_OnW3SupplyLocker_OnPluginStart()
{
	HookEvent("post_inventory_application", Event_Inventory, EventHookMode_Post);
}

new Handle:g_OnW3SupplyLocker;

public bool:War3Source_002_OnW3SupplyLocker_InitNativesForwards()
{
	g_OnW3SupplyLocker=CreateGlobalForward("OnW3SupplyLocker",ET_Ignore,Param_Cell);

	return true;
}

public Action:Event_Inventory(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(MapChanging || War3SourcePause) return Plugin_Continue;

	new client = GetClientOfUserId(GetEventInt(event, "userid"));

#if CYBORG_SKIN == MODE_ENABLED
#if GGAMETYPE == GGAME_TF2
	Cyborg_Event_Inventory(client, name, dontBroadcast);
#endif
#endif

	Call_StartForward(g_OnW3SupplyLocker);
	Call_PushCell(client);
	Call_Finish();

	return Plugin_Continue;
}
