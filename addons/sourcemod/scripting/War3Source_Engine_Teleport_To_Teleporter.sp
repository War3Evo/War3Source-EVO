// War3Source_Engine_Teleport_To_Teleporter.sp

#include <war3source>
#include "War3Source/include/War3Source_Engine_Teleport_To_Teleporter.inc"

#if (GGAMETYPE != GGAME_TF2)
	#endinput
#endif

public Plugin myinfo =
{
	name = "Engine Teleport to Teleporter",
	author = "El Diablo",
	description = "Engine Teleport to Teleporter",
	version = "1.0",
	url = "http://war3evo.info"
};

float emptypos[3];

//=============================================================================
// AskPluginLoad2
//=============================================================================
public APLRes:AskPluginLoad2(Handle:plugin,bool:late,String:error[],err_max)
{
	CreateNative("War3_SendToTeleporter",Native_War3_SendToTeleporter);

	RegPluginLibrary("Teleport_To_Teleporter");
	return APLRes_Success;
}

public int Native_War3_SendToTeleporter(Handle plugin, int args)
{
	if(args < 5)
	{
		//PrintToChatAll("args < 5");
		return 0;
	}

	int iClient=GetNativeCell(1);

	if(!ValidPlayer(iClient)) return 0;

	//PrintToChatAll("Native_War3_SendToTeleporter ValidPlayer");

	int iTeam=GetNativeCell(2);
	if(iTeam != 2 && iTeam !=3) return 0;
	//PrintToChatAll("iTeam valid");

	bool bEntrance=GetNativeCell(3);
	bool bExit=GetNativeCell(4);
	bool bClosest=GetNativeCell(5);

	int iEnt;
	int TeleporterOwner;

	float TeleporterPosition[3];
	float ClientPosition[3];
	float dist;

	int ExitTeleporterEntities[64];
	int ExitTeleporterOwner[64];
	int ExitTeleporterEntitiesCount = 0;

	int EntranceTeleporterEntities[64];
	int EntranceTeleporterOwner[64];
	int EntranceTeleporterEntitiesCount = 0;

	War3_CachedPosition(iClient,ClientPosition);

	float CurrentTeleporterDistance = 9999.0;

	int ClosestTeleporterEntity = 0;
	int ClosestTeleporterOwner = 0;
	int TeleporterCount = 0;

	while ((iEnt = FindEntityByClassname(iEnt, "obj_teleporter")) != INVALID_ENT_REFERENCE)
	{
		GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", TeleporterPosition);

		dist=GetVectorDistance(ClientPosition,TeleporterPosition);

		if(!bClosest || (bClosest && dist<=CurrentTeleporterDistance))
		{
			TeleporterOwner = GetEntPropEnt(iEnt, Prop_Send, "m_hBuilder");

			if(ValidPlayer(TeleporterOwner) && GetClientTeam(TeleporterOwner) == iTeam)
			{

				if(bEntrance && TF2_GetObjectMode(iEnt) == TFObjectMode_Entrance)
				{
					CurrentTeleporterDistance = dist;

					//entrance
					if(bClosest)
					{
						ClosestTeleporterOwner = TeleporterOwner;
						ClosestTeleporterEntity = iEnt;
						TeleporterCount++;
					}
					else
					{
						if(EntranceTeleporterEntitiesCount<64)
						{
							EntranceTeleporterOwner[EntranceTeleporterEntitiesCount] = TeleporterOwner;
							EntranceTeleporterEntities[EntranceTeleporterEntitiesCount] = iEnt;
							EntranceTeleporterEntitiesCount++;
						}
					}
				}
				else if(bExit)
				{
					CurrentTeleporterDistance = dist;

					//exit
					if(bClosest)
					{
						ClosestTeleporterOwner = TeleporterOwner;
						ClosestTeleporterEntity = iEnt;
						TeleporterCount++;
					}
					else
					{
						if(ExitTeleporterEntitiesCount<64)
						{
							ExitTeleporterOwner[ExitTeleporterEntitiesCount] = TeleporterOwner;
							ExitTeleporterEntities[ExitTeleporterEntitiesCount] = iEnt;
							ExitTeleporterEntitiesCount++;
						}
					}
				}
			}
		}
	}

	if(bClosest && TeleporterCount>0)
	{
		//PrintToChatAll("bClosest && TeleporterCount>0");
		War3_SpawnPlayer(iClient);
		return TeleportPlayer(iClient, ClosestTeleporterOwner, ClosestTeleporterEntity);
	}
	else if(bExit && ExitTeleporterEntitiesCount>0)
	{
		//PrintToChatAll("bExit && ExitTeleporterEntitiesCount>0");
		int RandTeleporter = GetRandomInt(0, ExitTeleporterEntitiesCount);
		War3_SpawnPlayer(iClient);
		return TeleportPlayer(iClient, ExitTeleporterOwner[RandTeleporter], ExitTeleporterEntities[RandTeleporter]);
	}
	else if(bEntrance && EntranceTeleporterEntitiesCount>0)
	{
		//PrintToChatAll("bEntrance && EntranceTeleporterEntitiesCount>0");
		int RandTeleporter = GetRandomInt(0, EntranceTeleporterEntitiesCount);
		War3_SpawnPlayer(iClient);
		return TeleportPlayer(iClient, ExitTeleporterOwner[RandTeleporter], ExitTeleporterEntities[RandTeleporter]);
	}

	return 0;
}

public bool TeleportPlayer(int iClient, int iOwner, int iTeleporterEnt)
{
	if(ValidPlayer(iClient) && ValidPlayer(iOwner) && IsValidEntity(iTeleporterEnt))
	{
		// teleport
		float TeleporterPosition[3];
		GetEntPropVector(iTeleporterEnt, Prop_Send, "m_vecOrigin", TeleporterPosition);

		// offset above teleport a little bit
		TeleporterPosition[2] += 20;

		emptypos[0]=0.0;
		emptypos[1]=0.0;
		emptypos[2]=0.0;

		getEmptyLocationHull(iClient,TeleporterPosition);

		float special[3];
		float top[3];
		GetClientEyePosition(iClient, special);
		special[2] += 11.0;
		top = special;
		top[2] -= 30.0;

		if(GetVectorLength(emptypos)>1.0){
			/*
			if (GetClientTeam(iClient) == 2) {
				TimedParticle(iOwner, "smoke_rocket_steam", TeleporterPosition, 5.0);
				TimedParticle(iClient, "critgun_weaponmodel_red", special, 5.0);
				TimedParticle(iClient, "critgun_weaponmodel_red", special, 5.0);
				TimedParticle(iClient, "critgun_weaponmodel_red", top, 5.0);
				TimedParticle(iClient, "critgun_weaponmodel_red", top, 5.0);
				TimedParticle(iClient, "player_recent_teleport_red", top, 5.0);
			}
			else if(GetClientTeam(iClient) == 3){
				TimedParticle(iOwner, "smoke_rocket_steam", TeleporterPosition, 5.0);
				TimedParticle(iClient, "critgun_weaponmodel_blu", special, 5.0);
				TimedParticle(iClient, "critgun_weaponmodel_blu", special, 5.0);
				TimedParticle(iClient, "critgun_weaponmodel_blu", top, 5.0);
				TimedParticle(iClient, "critgun_weaponmodel_blu", top, 5.0);
				TimedParticle(iClient, "player_recent_teleport_blue", top, 5.0);
			}*/

			War3_TeleportEntity(iClient, TeleporterPosition, NULL_VECTOR, NULL_VECTOR);
			return true;
		}
	}
	return false;
}


//new absincarray[]={0,4,-4,8,-8,12,-12,18,-18,22,-22,25,-25};//,27,-27,30,-30,33,-33,40,-40}; //for human it needs to be smaller
int absincarray[]={0,4,-4,8,-8,12,-12,18,-18,22,-22,25,-25,27,-27,30,-30,33,-33,40,-40,-50,-75,-90,-110}; //for human it needs to be smaller

public bool getEmptyLocationHull(int client,float originalpos[3]){


	float mins[3];
	float maxs[3];
	GetClientMins(client,mins);
	GetClientMaxs(client,maxs);

	int absincarraysize=sizeof(absincarray);

	int limit=5000;
	for(int x=0;x<absincarraysize;x++){
		if(limit>0){
			for(int y=0;y<=x;y++){
				if(limit>0){
					for(int z=0;z<=y;z++){
						float pos[3]={0.0,0.0,0.0};
						AddVectors(pos,originalpos,pos);
						pos[0]+=float(absincarray[x]);
						pos[1]+=float(absincarray[y]);
						pos[2]+=float(absincarray[z]);

						TR_TraceHullFilter(pos,pos,mins,maxs,MASK_SOLID,Teleport_CanHitThis,client);
						//new ent;
						if(!TR_DidHit(_))
						{
							AddVectors(emptypos,pos,emptypos); ///set this gloval variable
							limit=-1;
							break;
						}

						if(limit--<0){
							break;
						}
					}

					if(limit--<0){
						break;
					}
				}
			}

			if(limit--<0){
				break;
			}

		}

	}

}


public bool:Teleport_CanHitThis(entityhit, mask, any:data)
{
	if(entityhit == data )
	{// Check if the TraceRay hit the itself.
		return false; // Don't allow self to be hit, skip this result
	}
	if(ValidPlayer(entityhit)&&ValidPlayer(data)&&GetClientTeam(entityhit)==GetClientTeam(data)){
		return false; //skip result, prend this space is not taken cuz they on same team
	}
	return true; // It didn't hit itself
}
/*
TimedParticle(int ent, char[] name, float pos[3], float time) {
	int particle = CreateEntityByName("info_particle_system");
	if (!IsValidEntity(particle)) return;
	DispatchKeyValue(particle, "effect_name", name);
	TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(particle);
	ActivateEntity(particle);
	AcceptEntityInput(particle, "start");

	if (ent > 0) {
		SetVariantString("!activator");
		AcceptEntityInput(particle, "SetParent", ent, particle, 0);
	}
	CreateTimer(time, Timer_ParticleEnd, particle);
}

public Action Timer_ParticleEnd(Handle timer, any particle)
{
	if (!IsValidEntity(particle)) return;
	char classn[32];
	GetEdictClassname(particle, classn, sizeof(classn));
	if (strcmp(classn, "info_particle_system") != 0) return;
	RemoveEdict(particle);
}*/
