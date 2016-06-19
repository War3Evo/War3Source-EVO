// War3Source_Engine_PlayerCollision.sp

int g_offsCollisionGroup;
/*
public Plugin:myinfo=
{
	name="W3S Engine Player Collisions",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};*/

public War3Source_Engine_PlayerCollision_OnPluginStart()
{
	g_offsCollisionGroup = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
}

public bool:War3Source_Engine_PlayerCollision_InitNativesForwards()
{
	CreateNative("War3_SetCollidable", Native_War3_SetCollidable);
	return true;
}

stock bool:SetCollidable(client,bool:collidable){
	if(g_offsCollisionGroup>0)
	{
		SetEntData(client, g_offsCollisionGroup, collidable?5:2, 4, true);
		return true;
	}
	return false;
}

//native bool:War3_SetCollidable(client,bool:SetCollidable);
public Native_War3_SetCollidable(Handle:plugin, numParams)
{
	new client=GetNativeCell(1);
	if(ValidPlayer(client))
	{
		return SetCollidable(client,bool:GetNativeCell(2));
	}
	return false;
}
