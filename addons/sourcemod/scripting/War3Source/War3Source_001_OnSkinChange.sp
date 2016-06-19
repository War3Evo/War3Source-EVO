// War3Source_001_OnSkinChange


public void Internal_OnSkinChange(int client, int newrace)
{
	if(!ValidPlayer(client,true)) return;

	if(newrace==-1)
	{
		newrace = GetRace(client);
	}
	Call_StartForward(p_OnWar3SkinChange);
	Call_PushCell(client);
	Call_PushCell(newrace);
	Call_Finish(dummyreturn);

	return;
}
