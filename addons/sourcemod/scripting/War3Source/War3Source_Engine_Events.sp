// War3Source_Engine_Events.sp

Handle p_War3GlobalEventFH;
new Handle:g_hfwddenyable;
new bool:notdenied=true;
/*
public Plugin:myinfo=
{
	name="War3Source Events",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};
*/

public bool:War3Source_Engine_Events_InitNatives()
{
	CreateNative("W3CreateEvent",NW3CreateEvent);//foritems

	CreateNative("W3Denied",NW3Denied);
	CreateNative("W3Deny",NW3Deny);
	return true;
}

public bool:War3Source_Engine_Events_InitNativesForwards()
{
	//"OnWar3Event"
	p_War3GlobalEventFH=CreateForward(ET_Ignore,Param_Cell,Param_Cell);

	g_hfwddenyable=CreateGlobalForward("OnW3Denyable",ET_Ignore,Param_Cell,Param_Cell);
	return true;
}
public NW3CreateEvent(Handle:plugin,numParams)
{
	W3EVENT event=GetNativeCell(1);
	int client=GetNativeCell(2);
	DoFwd_War3_Event(event,client);
}

public void DoFwd_War3_Event(W3EVENT event, int client)
{
	Internal_War3_Event(event,client);
	Call_StartForward(p_War3GlobalEventFH);
	Call_PushCell(event);
	Call_PushCell(client);
	Call_Finish(dummyreturn);
}

public NW3Denied(Handle:plugin,numParams)
{
	notdenied=true;
	Call_StartForward(g_hfwddenyable);
	Call_PushCell(GetNativeCell(1)); //event,/
	Call_PushCell(GetNativeCell(2));	//client
	Call_Finish(dummyreturn);
	return !notdenied;
}
public NW3Deny(Handle:plugin,numParams)
{
	notdenied=false;
}
