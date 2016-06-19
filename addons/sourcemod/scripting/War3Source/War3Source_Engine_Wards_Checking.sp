// War3Source_Engine_Wards_Checking.sp

//#assert GGAMEMODE == MODE_WAR3SOURCE

new Handle:disableWardLocationCheckingCvar;

//wardCheck
new spawnCount=0;
new noWardsCount=0;
#define MAX_SPAWNS 128
new Float:spawnPosMin[MAX_SPAWNS][3];
new Float:spawnPosMax[MAX_SPAWNS][3];
new Float:noWardsPosMin[MAX_SPAWNS][3];
new Float:noWardsPosMax[MAX_SPAWNS][3];
new String:path_corners[256];

new bool:W3IsInSpawn[MAXPLAYERS+1] = false;

new totalChecks;   // dont use int:totalChecks; gave tagmismatch
new checkArray[20][4];
/*
public Plugin:myinfo=
{
	name="W3E Ward Location Checking Engine",
	author="Dag",
	description="War3Evo Core Plugins",
	version="1.0",
	url="http://war3evo.info/"
};
*/
public ClearArrays()
{
	for(new x=0;x<20;x++) {
		for(new y=0;y<4;y++) {
			checkArray[x][y]=0;
		}
	}
	for(new x=0;x<MAX_SPAWNS;x++) {
		for(new y=0;y<3;y++) {
			spawnPosMin[x][y]=0.0;
			spawnPosMax[x][y]=0.0;
			noWardsPosMin[x][y]=0.0;
			noWardsPosMax[x][y]=0.0;
		}
	}
}

public War3Source_Engine_Wards_Checking_OnPluginStart()
{
	RegAdminCmd("sm_markcorner",	Command_MarkCorner, 	ADMFLAG_ROOT, 	"marks a vector corner");
	RegAdminCmd("sm_savecorners",	Command_SaveCorners, 	ADMFLAG_ROOT, 	"save the corners");
	RegAdminCmd("sm_commitcorners",	Command_SaveWardCornersToDisk, 	ADMFLAG_ROOT, 	"writes the config file for the ward corners");
	RegAdminCmd("sm_loadcorners", Command_LoadWardCorners, ADMFLAG_ROOT, "reads the ward corners from disk");

	new String:mapName[128];
	GetCurrentMap(mapName, sizeof(mapName));
	BuildPath(Path_SM, path_corners, sizeof(path_corners), "configs/corners-wards-%s.cfg", mapName);

	disableWardLocationCheckingCvar=CreateConVar("war3_disable_ward_checking","0","1 disables ward location checking.");
	generateSpawnAreas();
	Command_LoadWardCorners2();

}
new Float:corners[MAXPLAYERSCUSTOM][2][3];
new cornerSw[MAXPLAYERSCUSTOM];

public Action:Command_LoadWardCorners(client, args)
{
	War3_ChatMessage(client,"loaded %i corner pairs",Command_LoadWardCorners2());
}

public Command_LoadWardCorners2() {
		// Read Map config File
	decl Handle:kv;
	kv = CreateKeyValues("Positions");
	//FileToKeyValues(kv, path_corners);

	if (!FileToKeyValues(kv, path_corners)) {
		PrintToServer("no cfg: %s", path_corners);

		CloseHandle(kv);
		return -10;
	}
	noWardsCount=0;

	do {

			new String:kvKey[5];
			new String:kvKeya[5];
			new String:kvKeyb[5];

			IntToString(noWardsCount,kvKey, sizeof(kvKey));
			Format(kvKeya, sizeof(kvKeya), "%sa",kvKey);
			Format(kvKeyb, sizeof(kvKeyb), "%sb",kvKey);

			//new Float:position[3];
			//new Float position2[3];

			KvGetVector(kv, kvKeya, noWardsPosMin[noWardsCount]);
			KvGetVector(kv, kvKeyb, noWardsPosMax[noWardsCount]);

			noWardsCount++;
		} while (noWardsPosMin[noWardsCount-1][0]!=0.0 && noWardsPosMin[noWardsCount-1][1]!=0.0 && noWardsPosMin[noWardsCount-1][2]!=0.0);
	noWardsCount--;
	CloseHandle(kv);
	return noWardsCount;
}

public Action:Command_SaveWardCornersToDisk(client, args) {

		War3_ChatMessage(client,"Writing ward corners to disk ...");

		new Handle:kv = CreateKeyValues("Positions");
		//new Handle:trie = CreateTrie();


		for (new i=0; i<noWardsCount; ++i) {
			new String:kvKey[5];
			new String:kvKeya[5];
			new String:kvKeyb[5];

			IntToString(i,kvKey, sizeof(kvKey));
			Format(kvKeya, sizeof(kvKeya), "%sa",kvKey);
			Format(kvKeyb, sizeof(kvKeyb), "%sb",kvKey);

			KvSetVector(kv, kvKeya, noWardsPosMin[i]);
			KvSetVector(kv, kvKeyb, noWardsPosMax[i]);


		}
		KvRewind(kv);
		KeyValuesToFile(kv, path_corners);
		CloseHandle(kv);
		//CloseHandle(trie);
		War3_ChatMessage(client,"Wrote %i corners ...",noWardsCount);
}

public Action:Command_SaveCorners(client, args) {

	if (cornerSw[client] != 2) {
		War3_ChatMessage(client,"Not enough corners!");
		return Plugin_Handled;
	}

	new i=noWardsCount++;

	noWardsPosMin[i]=corners[client][0];
	noWardsPosMax[i]=corners[client][1];
	War3_ChatMessage(client,"corners comitted");

	return Plugin_Handled;

}



public Action:Command_MarkCorner(client, args) {

	new Float:vec[3];
	GetClientAbsOrigin(client, vec);

	if (cornerSw[client] == 2) {
		cornerSw[client]=0;
		War3_ChatMessage(client,"CORNERS RESET!");
	}

	if (!cornerSw[client])
	{
		corners[client][0]=vec;
		War3_ChatMessage(client,"Marked a corner!");

	} else {
		corners[client][1]=vec;
		War3_ChatMessage(client,"Marked the other corner!");
	}
	cornerSw[client]++;
	return Plugin_Handled;
}

new Handle:g_War3_InSpawn;

public bool:InitNativesForwards()
{
	MarkNativeAsOptional("War3_WardLocationNotAllowed");

	CreateNative("War3_WardLocationNotAllowed",NWar3_WardLocationNotAllowed);
	CreateNative("War3_IsInSpawn",NWar3_IsInSpawn);

	g_War3_InSpawn=CreateGlobalForward("OnW3InSpawn",ET_Ignore,Param_Cell,Param_Cell,Param_Cell);
	return true;
}

public NWar3_IsInSpawn(Handle:plugin,numParams)
{
	new client = GetNativeCell(1);
	new bool:oldstylechecking = bool:GetNativeCell(2);
	if(!oldstylechecking)
	{
		return W3IsInSpawn[client];
	}
	else
	{
		if(ValidPlayer(client))
		{
			if(!W3IsInSpawn[client])
			{
				// old style
				new Float:vec[3];
				GetNativeArray(3,vec,3);
				new checkZ=GetNativeCell(4);
				GetClientAbsOrigin(client, vec);
				return IsInSpawn(vec, checkZ);
			}
		}
		else
		{
			// old style
			new Float:vec[3];
			GetNativeArray(3,vec,3);
			new checkZ=GetNativeCell(4);
			//GetClientAbsOrigin(client, vec);
			return IsInSpawn(vec, checkZ);
		}
	}
	return false;
}

stock IsInSpawn(const Float:pos[3],checkZ){
	for(new i=0;i<spawnCount;++i){
		if(IsInsideRect(pos, spawnPosMin[i], spawnPosMax[i],checkZ)){
			return 1;
		}
	}
	return 0;
}
stock IsInNoWards(const Float:pos[3],checkZ){
	for(new i=0;i<noWardsCount;++i){
		if(IsInsideRect(pos, noWardsPosMin[i], noWardsPosMax[i],checkZ)){
			return 1;
		}
	}
	return 0;
}
stock bool:IsInsideRect(const Float:Pos[3], const Float:Corner1[3], const Float:Corner2[3],checkZ) {
	decl Float:field1[2];
	decl Float:field2[2];
	decl Float:field3[2];
	if(Corner1[0] < Corner2[0]){
		field1[0] = Corner1[0];
		field1[1] = Corner2[0];
	}else{
		field1[0] = Corner2[0];
		field1[1] = Corner1[0];
	}
	if(Corner1[1] < Corner2[1]){
		field2[0] = Corner1[1];
		field2[1] = Corner2[1];
	}else{
		field2[0] = Corner2[1];
		field2[1] = Corner1[1];
	}
	if(Corner1[2] < Corner2[2]){
		field3[0] = Corner1[2];
		field3[1] = Corner2[2];
	}else{
		field3[0] = Corner2[2];
		field3[1] = Corner1[2];
	}
	if (Pos[0] < field1[0] || Pos[0] > field1[1]) return false;
	if (Pos[1] < field2[0] || Pos[1] > field2[1]) return false;
	if (checkZ)
		if (Pos[2] < field3[0] || Pos[2] > field3[1]) return false;

	return true;
}

stock generateSpawnAreas(){
	spawnCount=0;
	new ent=-1;

	ent=-1;
	while((ent = FindEntityByClassname(ent, "func_respawnroom"))!=-1){
		new i=spawnCount++;
		GetEntRect(ent, spawnPosMin[i], spawnPosMax[i]);
	}

}

stock GetEntRect(ent, Float:posMin[3], Float:posMax[3], Float:dist=1.0){
	GetEntPropVector(ent, Prop_Send, "m_vecMins", posMin);
	GetEntPropVector(ent, Prop_Send, "m_vecMaxs", posMax);
	decl Float:orig[3];
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", orig);

	AddVectors(posMin, orig, posMin);
	AddVectors(posMax, orig, posMax);

	posMin[0] -= dist;
	posMin[1] -= dist;
	posMin[2] -= dist;
	posMax[0] += dist;
	posMax[1] += dist;
	posMax[2] += dist;
}

bool:WardLocationNotAllowed(client)
{
	if(GetConVarInt(disableWardLocationCheckingCvar)==1)
		return false;

	//new client=GetNativeCell(1);

	new Float:vec[3];
	GetClientAbsOrigin(client, vec);
	if (IsInSpawn(vec,0) || IsInNoWards(vec,0))
	{
		//if(ValidPlayer(client))
		//{
			//War3_ChatMessage(client, "Wards cannot be placed in this location");
		//}
		return true;
	}

	if (!totalChecks)
		return false;

	for(new x=0;x<totalChecks;x++) {
		if ((vec[0] < checkArray[x][0] && vec[0] > checkArray[x][1] && vec[1] > checkArray[x][2] && vec[1] < checkArray[x][3])) {
			//if(ValidPlayer(client))
			//{
				//War3_ChatMessage(client, "Wards cannot be placed in this location");
			//}
			return true;
		}
	}
	return false;
}

//native War3_RestoreItemsFromDeath(client,bool:payforit,bool:csmoney);
public NWar3_WardLocationNotAllowed(Handle:plugin,numParams)
{
	if(GetConVarInt(disableWardLocationCheckingCvar)==1)
		return false;

	return WardLocationNotAllowed(GetNativeCell(1));
}

public War3Source_Engine_Wards_Checking_OnMapStart()
{
	ClearArrays();

	new String:mapName[128];
	GetCurrentMap(mapName, sizeof(mapName));
	BuildPath(Path_SM, path_corners, sizeof(path_corners), "configs/corners-wards-%s.cfg", mapName);
	generateSpawnAreas();
	Command_LoadWardCorners2();
#if GGAMETYPE == GGAME_TF2
	decl String:mapname[128];
	GetCurrentMap(mapname, sizeof(mapname));
	//DP(mapname);
	if (strcmp(mapname, "pl_goldrush", false) == 0) {
		totalChecks = 2;
		checkArray[0][0] = -2200; //x <
		checkArray[0][1] = -3700; //x >
		checkArray[0][2] = 1700; //y >
		checkArray[0][3] = 2200; //y <

		checkArray[1][0] = -4100;
		checkArray[1][1] = -4700;
		checkArray[1][2] = -2666;
		checkArray[1][3] = -2255;
	} else if (strcmp(mapname, "koth_nucleus", false) == 0)	{
		totalChecks = 6;
		checkArray[0][0] = -1300; //x <
		checkArray[0][1] = -1500; //x >
		checkArray[0][2] = -450; //y >
		checkArray[0][3] = 400; //y <

		checkArray[1][0] = 1500; //x <
		checkArray[1][1] = 1200; //x >
		checkArray[1][2] = -400; //y >
		checkArray[1][3] = 400; //y <

		checkArray[2][0] = 2000; //x < not bugged
		checkArray[2][1] = 1600; //x >
		checkArray[2][2] = 100; //y >
		checkArray[2][3] = 400; //y <

		checkArray[3][0] = 1800; //x < not bugged
		checkArray[3][1] = 1100; //x >
		checkArray[3][2] = -1000; //y >
		checkArray[3][3] = -700; //y <

		checkArray[4][0] = -1100; //x < not bugged
		checkArray[4][1] = -1900; //x >
		checkArray[4][2] = -1000; //y >
		checkArray[4][3] = -700; //y <

		checkArray[5][0] = -1600; //x < not bugged
		checkArray[5][1] = -2000; //x >
		checkArray[5][2] = 100; //y >]
		checkArray[5][3] = 400; //y <

	}	 else if (strcmp(mapname, "koth_viaduct", false) == 0)	{
		totalChecks = 2;
		checkArray[0][0] = -928; //x <
		checkArray[0][1] = -1800; //x >
		checkArray[0][2] = 2823; //y >
		checkArray[0][3] = 3224; //y <

		checkArray[1][0] = -1000;
		checkArray[1][1] = -1700;
		checkArray[1][2] = -3200;
		checkArray[1][3] = -2800;
	}  else if (strcmp(mapname, "koth_lakeside_final", false) == 0)	{
		totalChecks = 2;
		checkArray[0][0] = 3400; //x <
		checkArray[0][1] = 2800; //x >
		checkArray[0][2] = -1000; //y >
		checkArray[0][3] = -50; //y <

		checkArray[1][0] = -2600;
		checkArray[1][1] = -3400;
		checkArray[1][2] = -1000;
		checkArray[1][3] = 50;
	} else if (strcmp(mapname, "koth_harvest_final", false) == 0)	{
		totalChecks = 2;
		checkArray[0][0] = 900; //x <
		checkArray[0][1] = 27; //x >
		checkArray[0][2] = 1700; //y >
		checkArray[0][3] = 2100; //y <

		checkArray[1][0] = -27;
		checkArray[1][1] = -900;
		checkArray[1][2] = -2100;
		checkArray[1][3] = -1700;
	}  else if (strcmp(mapname, "pl_badwater", false) == 0)	{
		totalChecks = 5;
		checkArray[0][0] = -1000; //x <
		checkArray[0][1] = -1300; //x >
		checkArray[0][2] = -80; //y >
		checkArray[0][3] = 200; //y <

		checkArray[1][0] = 255;
		checkArray[1][1] = -230;
		checkArray[1][2] = -90;
		checkArray[1][3] = 300;

		checkArray[2][0] = 550; //x <
		checkArray[2][1] = 375; //x >
		checkArray[2][2] = 150; //y >
		checkArray[2][3] = 900; //y <

		checkArray[3][0] = 3200;


		checkArray[3][1] = 2650;
		checkArray[3][2] = -2000;
		checkArray[3][3] = -400;

		checkArray[4][0] = -1500; //x <
		checkArray[4][1] = -2250; //x >
		checkArray[4][2] = -1100; //y >
		checkArray[4][3] = -725; //y <
	} else if (strcmp(mapname, "pl_upward", false) == 0)	{
		totalChecks = 6;
		checkArray[0][0] = -600; //x <
		checkArray[0][1] = -1000; //x >
		checkArray[0][2] = -2300; //y >
		checkArray[0][3] = -1900; //y <

		checkArray[1][0] = -1600; //x <
		checkArray[1][1] = -2000; //x >
		checkArray[1][2] = -1700; //y >
		checkArray[1][3] = -1400; //y <

		checkArray[2][0] = -1150; //x < not bugged
		checkArray[2][1] = -1400; //x >
		checkArray[2][2] = -1300; //y >
		checkArray[2][3] = -800; //y <

		checkArray[3][0] = 720; //x < not bugged
		checkArray[3][1] = 300; //x >
		checkArray[3][2] = 1000; //y >
		checkArray[3][3] = 1400; //y <

		checkArray[4][0] = 1000; //x < not bugged
		checkArray[4][1] = 88; //x >
		checkArray[4][2] = -25; //y >
		checkArray[4][3] = 730; //y <

		checkArray[5][0] = 2000; //x < not bugged
		checkArray[5][1] = 1500; //x >
		checkArray[5][2] = -800; //y >]
		checkArray[5][3] = -475; //y <


	}  else if (strcmp(mapname, "cp_dustbowl", false) == 0)	{
		totalChecks = 7;
		checkArray[0][0] = -1750; //x <
		checkArray[0][1] = -2500; //x >
		checkArray[0][2] = 2264; //y >
		checkArray[0][3] = 3100; //y <

		checkArray[1][0] = -1550; //x <
		checkArray[1][1] = -1800; //x >
		checkArray[1][2] = 1400; //y >
		checkArray[1][3] = 2100; //y <

		checkArray[2][0] = 2900; //x < not bugged
		checkArray[2][1] = 1400; //x >
		checkArray[2][2] = -350; //y >
		checkArray[2][3] = 1100; //y <

		checkArray[3][0] = -1300; //x < not bugged
		checkArray[3][1] = -2655; //x >
		checkArray[3][2] = -1750; //y >
		checkArray[3][3] = -560; //y <

		checkArray[4][0] = -215; //x < not bugged
		checkArray[4][1] = -1300; //x >
		checkArray[4][2] = 250; //y >
		checkArray[4][3] = 1315; //y <

		checkArray[5][0] = 300; //x < not bugged
		checkArray[5][1] = -100; //x >
		checkArray[5][2] = 600; //y >]
		checkArray[5][3] = 1000; //y <

		checkArray[6][0] = 1300; //x < not bugged
		checkArray[6][1] = 800; //x >
		checkArray[6][2] = 600; //y >]
		checkArray[6][3] = 1000; //y <

	} else if (strcmp(mapname, "pl_hoodoo_final", false) == 0)	{
		totalChecks = 5;
		checkArray[0][0] = 5700; //x <
		checkArray[0][1] = 5000; //x >
		checkArray[0][2] = 340; //y >
		checkArray[0][3] = 1400; //y <

		checkArray[1][0] = 2700; //x <
		checkArray[1][1] = 1450; //x >
		checkArray[1][2] = -3800; //y >
		checkArray[1][3] = -1750; //y <

		checkArray[2][0] = -3400; //x < not bugged
		checkArray[2][1] = -3900; //x >
		checkArray[2][2] = -1650; //y >
		checkArray[2][3] = -1200; //y <

		checkArray[3][0] = -4200; //x < not bugged
		checkArray[3][1] = -4800; //x >
		checkArray[3][2] = -1300; //y >
		checkArray[3][3] = -300; //y <

		checkArray[4][0] = -7700; //x < not bugged
		checkArray[4][1] = -8800; //x >
		checkArray[4][2] = -1100; //y >
		checkArray[4][3] = 0; //y <
	} else {
		totalChecks = 0;
	}
#endif
}

/*
CheckWard(client)
{
	new Float:loc[3];
	GetClientAbsOrigin(client,loc);
	for(new i=0;i<MAXWARDS;i++)
	{
		if(WardOwner[i]!=0)
		{
			PrintToServer("%i",i);
			new Float:loc2[3];
			loc2=WardLocation[i];
			if (GetVectorDistance(loc,loc2) < 185.0)
				return 1;
		}
	}
	return 0;
}*/
#if GGAMETYPE == GGAME_TF2
bool:CanPlaceWardNearHere(client)
{
					if(TF2_GetPlayerClass(client)==TFClass_Engineer||TF2_GetPlayerClass(client)==TFClass_Medic)
					{
						return false; //dont deny
					}
					new iTeam=GetClientTeam(client);
					new bool:conf_found=false;
					new Handle:hCheckEntities=War3_NearBuilding(client);
					new size_arr=0;
					if(hCheckEntities!=INVALID_HANDLE)
						size_arr=GetArraySize(hCheckEntities);
					for(new x=0;x<size_arr;x++)
					{
						new ent=GetArrayCell(hCheckEntities,x);
						if(!IsValidEdict(ent)) continue;
						new builder=GetEntPropEnt(ent,Prop_Send,"m_hBuilder");
						if(builder>0 && ValidPlayer(builder) && GetClientTeam(builder)!=iTeam)
						{
							conf_found=true;
							break;
						}
					}
					if(size_arr>0)
						CloseHandle(hCheckEntities);
					if(conf_found)
					{
						return true; //deny
					}

					return false;
}
#endif
public War3Source_Engine_Wards_Checking_OnW3Denyable(client)
{
				//W3SetVar(EventArg1,true);
				new bool:Silence=bool:W3GetVar(EventArg1);
				new Float:DistanceCheck=Float:W3GetVar(EventArg2);

				if(!(GetEntityFlags(client) & FL_ONGROUND))
				{
					W3Deny();
					if(!Silence)
					{
						War3_ChatMessage(client,"Can not place wards in the air!");
						W3Hint(client,HINT_SKILL_STATUS,2.0,"Can not place wards in the air!");
					}
				}
				if(WardLocationNotAllowed(client))
				{
					W3Deny();
					if(!Silence)
					{
						W3MsgWardLocationDeny(client);
					}
				}
				if (War3_IsWardDistanceTooClose(client,DistanceCheck))
				{
					W3Deny();
					if(!Silence)
					{
						War3_ChatMessage(client,"This ward is too close to another ward");
					}
				}
#if GGAMETYPE == GGAME_TF2
				if(CanPlaceWardNearHere(client))
				{
					W3Deny();
					if(!Silence)
					{
						W3MsgWardLocationDeny(client);
					}
				}
				if(War3_IsCloaked(client))
				{
					W3Deny();
					if(!Silence)
					{
						W3MsgNoWardWhenInvis(client);
					}
				}
#endif
}


public Engine_Wards_Checking_OnEntityCreated(entity, const String:classname[])
{
	if (StrEqual(classname, "func_respawnroom", false))	// This is the earliest we can catch this
	{
		SDKHook(entity, SDKHook_StartTouch, SpawnStartTouch);
		SDKHook(entity, SDKHook_EndTouch, SpawnEndTouch);
	}
}
public SpawnStartTouch(spawn, client)
{
	// Make sure it is a client and not something random
	if(ValidPlayer(client))
	{
		W3IsInSpawn[client] = true;

		Call_StartForward(g_War3_InSpawn);
		Call_PushCell(client);
		Call_PushCell(W3IsInSpawn[client]);
		Call_PushCell(spawn);
		//new result;
		Call_Finish(dummy);
	}
}

public SpawnEndTouch(spawn, client)
{
	if(ValidPlayer(client))
	{
		W3IsInSpawn[client] = false;

		Call_StartForward(g_War3_InSpawn);
		Call_PushCell(client);
		Call_PushCell(W3IsInSpawn[client]);
		Call_PushCell(spawn);
		//new result;
		Call_Finish(dummy);
	}
}
