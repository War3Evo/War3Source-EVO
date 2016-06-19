// War3Source_Engine_OnRaceChanged.sp

public Internal_On_Race_Changed(client,oldrace,newrace)
{
	War3Source_Engine_Deny_OnRaceChanged(client,oldrace,newrace);

	War3Source_Engine_BuffSystem_OnRaceChanged(client, oldrace, newrace);

	War3Source_Engine_Easy_Buff_OnRaceChanged(client, oldrace, newrace);

#if SHOPMENU3 == MODE_ENABLED
	War3Source_Engine_ItemDatabase3_OnRaceChanged(client,oldrace,newrace);
#endif

	War3Source_Engine_Wards_Engine_OnRaceChanged(client,oldrace,newrace);
}
