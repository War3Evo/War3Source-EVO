// War3Source_Engine_OnW3Denyable.sp

public OnW3Denyable(W3DENY:event,client)
{
#if GGAMETYPE == GGAME_TF2
#if CYBORG_SKIN == MODE_ENABLED
	War3Source_Engine_Cyborg_OnW3Denyable(W3DENY:event,client);
#endif
#endif

	switch(event)
	{
		case DN_CanSelectRace:
		{
			//War3Source_Engine_RaceRestrictions
			War3Source_Engine_RaceRestrictions_OnW3Denyable(client);
			return;
		}

		case DN_CanPlaceWard:
		{
			War3Source_Engine_Wards_Checking_OnW3Denyable(client);
			return;
		}
	}
}
