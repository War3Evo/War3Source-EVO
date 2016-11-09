// War3Source/include/War3Source_Engine_Teleport_To_Teleporter.inc

// returns true if successfull
native bool War3_SendToTeleporter(int iClient, int iTeam, bool bEntrance, bool bExit, bool bClosest);

public SharedPlugin __pl_Teleport_To_Teleporter =
{
	name = "Teleport_To_Teleporter",
	file = "War3Source_Engine_Teleport_To_Teleporter.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_Teleport_To_Teleporter_SetNTVOptional()
{
	MarkNativeAsOptional("War3_SendToTeleporter");
}
#endif
