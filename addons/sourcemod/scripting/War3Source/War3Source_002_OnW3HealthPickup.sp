// War3Source_002_OnW3HealthPickup.sp

public War3Source_002_OnW3HealthPickup_OnPluginStart()
{
	HookEntityOutput("item_healthkit_full", "OnPlayerTouch", EntityOutput:Entity_OnPlayerTouch);
	HookEntityOutput("item_healthkit_medium", "OnPlayerTouch", EntityOutput:Entity_OnPlayerTouch);
	HookEntityOutput("item_healthkit_small", "OnPlayerTouch", EntityOutput:Entity_OnPlayerTouch);
}

new Handle:g_OnW3HealthPickup;

public bool:War3Source_002_OnW3HealthPickup_InitNativesForwards()
{
	g_OnW3HealthPickup=CreateGlobalForward("OnW3HealthPickup",ET_Ignore,Param_String,Param_Cell,Param_Cell,Param_Float);

	return true;
}

public Entity_OnPlayerTouch(const String:output[], caller, activator, Float:delay)
{
	if(MapChanging || War3SourcePause) return 0;

	Call_StartForward(g_OnW3HealthPickup);
	Call_PushString(output);
	Call_PushCell(caller);
	Call_PushCell(activator);
	Call_PushFloat(delay);
	Call_Finish();

	return 1;
}
