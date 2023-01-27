// War3Source_Engine_Messages.sp

// find War3Source_Messages.inc

public bool:War3Source_Engine_Messages_InitNatives()
{
	//native bool:War3_CanSendMessage(client,msgcode,prioirty);
	CreateNative("War3_CanSendMessage",Native_War3_CanSendMessage);

	return true;
}

// true = can send message
public Native_War3_CanSendMessage(Handle:plugin,numParams)
{
	//int client=GetNativeCell(1);
	//int msgcode=GetNativeCell(2);
	//int prioirty=GetNativeCell(3);
	if (gh_CVAR_DisableAllText.BoolValue)
	{
		return false;
	}
	return true;
}
