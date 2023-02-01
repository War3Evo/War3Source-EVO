// War3Source_Engine_Download_Control.sp

/*
public Plugin:myinfo=
{
	name="War3Source Engine Download Control",
	author="War3Source:EVO Team",
	description="War3Source:EVO Core Plugins",
	version="1.0",
	url="http://war3evo.info/"
};*/

new bool:IsOnMapEnd;

new Handle:imaxdownloadsCvar = INVALID_HANDLE;
new Handle:ihighdownloadsCvar = INVALID_HANDLE;
new Handle:imediumdownloadsCvar = INVALID_HANDLE;
new Handle:ilowdownloadsCvar = INVALID_HANDLE;
new Handle:ibottomdownloadsCvar = INVALID_HANDLE;

new Handle:Log_TOP_prioirtyCvar = INVALID_HANDLE;
new Handle:Log_HIGH_prioirtyCvar = INVALID_HANDLE;
new Handle:Log_MEDIUM_prioirtyCvar = INVALID_HANDLE;
new Handle:Log_LOW_prioirtyCvar = INVALID_HANDLE;
new Handle:Log_BOTTOM_prioirtyCvar = INVALID_HANDLE;

new Handle:EnableTopDownloadsCvar = INVALID_HANDLE;
new Handle:EnableHighDownloadsCvar = INVALID_HANDLE;
new Handle:EnableMediumDownloadsCvar = INVALID_HANDLE;
new Handle:EnableLowDownloadsCvar = INVALID_HANDLE;
new Handle:EnableBottomDownloadsCvar = INVALID_HANDLE;

new Handle:EnablePRECACHEDownloadsCvar = INVALID_HANDLE;

new Forward_Priority = PRIORITY_BOTTOM;

// Internal data
new Handle:g_hSoundFile = INVALID_HANDLE;
new Handle:g_hModelFile = INVALID_HANDLE;

new Handle:g_hStockSound = INVALID_HANDLE;
new Handle:g_hStockModel = INVALID_HANDLE;

new Handle:g_hPriority = INVALID_HANDLE;

//Handle g_hRaceIDSound = null;

//new Handle:g_hHistoryFiles = INVALID_HANDLE;

// Event handles
new Handle:g_OnAddSoundHandle = INVALID_HANDLE;
new Handle:g_OnAddModelHandle = INVALID_HANDLE;

new Handle:EnableDownloadsModuleCvar = INVALID_HANDLE;

new Handle:EnableFullDownloadsModuleCvar = INVALID_HANDLE;


new CurrentClientsConnected;

CacheFiles()
{
	// CACHE FILES HERE FOR NEXT MAP
	//new bool:res;
	if(!GetConVarBool(EnableDownloadsModuleCvar))
	{
		return;
	}

	new res;

	if(GetConVarBool(EnableTopDownloadsCvar))
	{
		Forward_Priority=PRIORITY_TOP;

		Call_StartForward(g_OnAddSoundHandle);
		Call_PushCell(PRIORITY_TOP);
		Call_Finish(res);
	}

	if(GetConVarBool(EnableHighDownloadsCvar))
	{
		Forward_Priority=PRIORITY_HIGH;

		Call_StartForward(g_OnAddSoundHandle);
		Call_PushCell(PRIORITY_HIGH);
		Call_Finish(res);
	}

	if(GetConVarBool(EnableMediumDownloadsCvar))
	{
		Forward_Priority=PRIORITY_MEDIUM;

		Call_StartForward(g_OnAddSoundHandle);
		Call_PushCell(PRIORITY_MEDIUM);
		Call_Finish(res);
	}

	if(GetConVarBool(EnableLowDownloadsCvar))
	{
		Forward_Priority=PRIORITY_LOW;

		Call_StartForward(g_OnAddSoundHandle);
		Call_PushCell(PRIORITY_LOW);
		Call_Finish(res);
	}

	if(GetConVarBool(EnableBottomDownloadsCvar))
	{
		Forward_Priority=PRIORITY_BOTTOM;

		Call_StartForward(g_OnAddSoundHandle);
		Call_PushCell(PRIORITY_BOTTOM);
		Call_Finish(res);
	}
}

UpdateDownloadControl()
{
	if(!GetConVarBool(EnableDownloadsModuleCvar))
	{
		return;
	}

	new DownloadCount=0;

	if(GetConVarBool(EnableFullDownloadsModuleCvar))
	{
		new String:StringDetail[2048];
		new String:TempBuffer[PLATFORM_MAX_PATH];

		new iMaxDownloads=CurrentClientsConnected*GetConVarInt(imaxdownloadsCvar);

		Format(StringDetail,sizeof(StringDetail),"imaxdownloadsCvar %d * CurrentClientsConnected %d = iMaxDownloads %d", GetConVarInt(imaxdownloadsCvar), CurrentClientsConnected, iMaxDownloads);
		LogDownloads(StringDetail);

		for(new i = 0; i < GetArraySize(g_hSoundFile); i++)
		{
			GetArrayString(g_hSoundFile, i, TempBuffer, sizeof(TempBuffer));
			AddSoundFiles(TempBuffer,i,666,0);
			AddModelFiles(TempBuffer,i,666,0);
			if(GetConVarBool(Log_TOP_prioirtyCvar))
			{
				if(GetArrayCell(g_hPriority, i)==PRIORITY_TOP)
				{
					Format(StringDetail,sizeof(StringDetail),"(PRIORITY_TOP) ALL FILES %s", TempBuffer);
					LogDownloads(StringDetail);
				}
				else if(GetArrayCell(g_hPriority, i)==PRIORITY_HIGH)
				{
					Format(StringDetail,sizeof(StringDetail),"(PRIORITY_HIGH) ALL FILES %s", TempBuffer);
					LogDownloads(StringDetail);
				}
				else if(GetArrayCell(g_hPriority, i)==PRIORITY_MEDIUM)
				{
					Format(StringDetail,sizeof(StringDetail),"(PRIORITY_MEDIUM) ALL FILES %s", TempBuffer);
					LogDownloads(StringDetail);
				}
				else if(GetArrayCell(g_hPriority, i)==PRIORITY_LOW)
				{
					Format(StringDetail,sizeof(StringDetail),"(PRIORITY_LOW) ALL FILES %s", TempBuffer);
					LogDownloads(StringDetail);
				}
				else if(GetArrayCell(g_hPriority, i)==PRIORITY_BOTTOM)
				{
					Format(StringDetail,sizeof(StringDetail),"(PRIORITY_BOTTOM) ALL FILES %s", TempBuffer);
					LogDownloads(StringDetail);
				}
				//Format(StringDetail,sizeof(StringDetail),"ALL FILES %s", TempBuffer);
				//LogDownloads(StringDetail);
			}
			DownloadCount++;
		}

		Format(StringDetail,sizeof(StringDetail),"DownloadCount %d", DownloadCount);
		LogDownloads(StringDetail);
	}
	else
	{

		new String:StringDetail[2048];
		new String:TempBuffer[PLATFORM_MAX_PATH];

		new iMaxDownloads=CurrentClientsConnected*GetConVarInt(imaxdownloadsCvar);

		Format(StringDetail,sizeof(StringDetail),"imaxdownloadsCvar %d * CurrentClientsConnected %d = iMaxDownloads %d", GetConVarInt(imaxdownloadsCvar), CurrentClientsConnected, iMaxDownloads);
		LogDownloads(StringDetail);

		if(GetConVarBool(EnableTopDownloadsCvar))
		{
			for(new i = 0; i < GetArraySize(g_hSoundFile); i++)
			{
				if(GetArrayCell(g_hPriority, i)==PRIORITY_TOP)
				{
					GetArrayString(g_hSoundFile, i, TempBuffer, sizeof(TempBuffer));
					AddSoundFiles(TempBuffer,i,666,0);
					AddModelFiles(TempBuffer,i,666,0);
					if(GetConVarBool(Log_TOP_prioirtyCvar))
					{
						Format(StringDetail,sizeof(StringDetail),"PRIORITY_TOP %s", TempBuffer);
						LogDownloads(StringDetail);
					}
					DownloadCount++;
				}
			}
		}
		new TOPDownloadCount=DownloadCount;
		// HIGH
		new iCount=0;
		new iMaxDownloadsNow=iMaxDownloads-RoundToCeil(FloatMul(float(iMaxDownloads),GetConVarFloat(ihighdownloadsCvar)));
		if(GetConVarBool(EnableHighDownloadsCvar))
		{
			for(new i = 0; i < GetArraySize(g_hSoundFile); i++)
			{
				if(GetArrayCell(g_hPriority, i)==PRIORITY_HIGH)
				{
					GetArrayString(g_hSoundFile, i, TempBuffer, sizeof(TempBuffer));

					if(AddSoundFiles(TempBuffer,i,iMaxDownloadsNow,iCount))
					{
						iCount++;
					}

					if(AddModelFiles(TempBuffer,i,iMaxDownloadsNow,iCount)
					{
						iCount++;
					}

					if(GetConVarBool(Log_HIGH_prioirtyCvar))
					{
						Format(StringDetail,sizeof(StringDetail),"PRIORITY_HIGH %s Count %d Download Count %d", TempBuffer, iMaxDownloadsNow-iCount, DownloadCount-TOPDownloadCount);
						LogDownloads(StringDetail);
					}
					DownloadCount++;
				}
			}
		}
		// MED
		iMaxDownloadsNow=iMaxDownloads-(iMaxDownloadsNow-iCount);
		iMaxDownloadsNow=RoundToCeil(FloatMul(float(iMaxDownloadsNow),GetConVarFloat(imediumdownloadsCvar)));
		iCount=0;
		if(GetConVarBool(EnableMediumDownloadsCvar))
		{
			for(new i = 0; i < GetArraySize(g_hSoundFile); i++)
			{
				if(GetArrayCell(g_hPriority, i)==PRIORITY_MEDIUM)
				{
					GetArrayString(g_hSoundFile, i, TempBuffer, sizeof(TempBuffer));
					if(AddSoundFiles(TempBuffer,i,iMaxDownloadsNow,iCount))
					{
						iCount++;
					}
					if(AddModelFiles(TempBuffer,i,iMaxDownloadsNow,iCount))
					{
						iCount++;
					}
					if(GetConVarBool(Log_MEDIUM_prioirtyCvar))
					{
						Format(StringDetail,sizeof(StringDetail),"PRIORITY_MEDIUM %s Count %d Download Count %d", TempBuffer, iMaxDownloadsNow-iCount, DownloadCount-TOPDownloadCount);
						LogDownloads(StringDetail);
					}
					DownloadCount++;
				}
			}
		}
		// PRIORITY_LOW
		iMaxDownloadsNow=iMaxDownloads-(iMaxDownloadsNow-iCount);
		iMaxDownloadsNow=RoundToCeil(FloatMul(float(iMaxDownloadsNow),GetConVarFloat(ilowdownloadsCvar)));
		iCount=0;
		if(GetConVarBool(EnableLowDownloadsCvar))
		{
			for(new i = 0; i < GetArraySize(g_hSoundFile); i++)
			{
				if(GetArrayCell(g_hPriority, i)==PRIORITY_LOW)
				{
					GetArrayString(g_hSoundFile, i, TempBuffer, sizeof(TempBuffer));
					if(AddSoundFiles(TempBuffer,i,iMaxDownloadsNow,iCount))
					{
						iCount++;
					}
					if(AddModelFiles(TempBuffer,i,iMaxDownloadsNow,iCount))
					{
						iCount++;
					}
					if(GetConVarBool(Log_LOW_prioirtyCvar))
					{
						Format(StringDetail,sizeof(StringDetail),"PRIORITY_LOW %s Count %d Download Count %d", TempBuffer, iMaxDownloadsNow-iCount, DownloadCount-TOPDownloadCount);
						LogDownloads(StringDetail);
					}
					DownloadCount++;
				}
			}
		}
		// PRIORITY_BOTTOM
		iMaxDownloadsNow=iMaxDownloads-(iMaxDownloadsNow-iCount);
		iMaxDownloadsNow=RoundToCeil(FloatMul(float(iMaxDownloadsNow),GetConVarFloat(ibottomdownloadsCvar)));
		iCount=0;
		if(GetConVarBool(EnableBottomDownloadsCvar))
		{
			for(new i = 0; i < GetArraySize(g_hSoundFile); i++)
			{
				if(GetArrayCell(g_hPriority, i)==PRIORITY_BOTTOM)
				{
					GetArrayString(g_hSoundFile, i, TempBuffer, sizeof(TempBuffer));
					if(AddSoundFiles(TempBuffer,i,iMaxDownloadsNow,iCount))
					{
						iCount++;
					}
					if(AddModelFiles(TempBuffer,i,iMaxDownloadsNow,iCount))
					{
						iCount++;
					}
					if(GetConVarBool(Log_BOTTOM_prioirtyCvar))
					{
						Format(StringDetail,sizeof(StringDetail),"PRIORITY_BOTTOM %s Count %d Download Count %d", TempBuffer, iMaxDownloadsNow-iCount, DownloadCount-TOPDownloadCount);
						LogDownloads(StringDetail);
					}
					DownloadCount++;
				}
			}
		}
	}


	//if(DownloadCount<=0)
	//{
		//ClearArray(g_hHistoryFiles);
		//LogDownloads("CLEARED HISTORY FILES [DownloadCount<=0]");
	//}
	//ClearArray(g_hSoundFile);
	//ClearArray(g_hPriority);
}

new OnPluginStartIndex=1;

public War3Source_Engine_Download_Control_OnPluginStart()
{
	EnableFullDownloadsModuleCvar = CreateConVar("war3_downloads_full_download", "1","1 to enable module");

	EnableDownloadsModuleCvar = CreateConVar("war3_downloads_enabled", "1","1 to enable module");
	EnablePRECACHEDownloadsCvar = CreateConVar("war3_downloads_precache_enabled", "1","set 1 to enable downloads of Priority TOP");
	EnableTopDownloadsCvar = CreateConVar("war3_downloads_top_enabled", "1","set 1 to enable downloads of Priority TOP");
	EnableHighDownloadsCvar = CreateConVar("war3_downloads_high_enabled", "1","set 1 to enable downloads of Priority TOP");
	EnableMediumDownloadsCvar = CreateConVar("war3_downloads_medium_enabled", "1","set 1 to enable downloads of Priority TOP");
	EnableLowDownloadsCvar = CreateConVar("war3_downloads_low_enabled", "1","set 1 to enable downloads of Priority TOP");
	EnableBottomDownloadsCvar = CreateConVar("war3_downloads_bottom_enabled", "1","set 1 to enable downloads of Priority TOP");

	imaxdownloadsCvar = CreateConVar("war3_downloads_max", "999999","max allowed downloads per player (max * maxclients)");
	ihighdownloadsCvar = CreateConVar("war3_downloads_high", "0.50","percentage 0.50 is 50 percent");
	imediumdownloadsCvar = CreateConVar("war3_downloads_medium", "0.25","percentage 0.25 is 25 percent");
	ilowdownloadsCvar = CreateConVar("war3_downloads_low", "0.10","percentage 0.10 is 10 percent");
	ibottomdownloadsCvar = CreateConVar("war3_downloads_bottom", "0.05","percentage 0.05 is 5 percent");
	Log_TOP_prioirtyCvar = CreateConVar("war3_downloads_log_top", "1","set 1 to enable");
	Log_HIGH_prioirtyCvar = CreateConVar("war3_downloads_log_high", "1","set 1 to enable");
	Log_MEDIUM_prioirtyCvar = CreateConVar("war3_downloads_log_medium", "1","set 1 to enable");
	Log_LOW_prioirtyCvar = CreateConVar("war3_downloads_log_low", "1","set 1 to enable");
	Log_BOTTOM_prioirtyCvar = CreateConVar("war3_downloads_log_bottom", "1","set 1 to enable");
	CurrentClientsConnected=2;
	IsOnMapEnd=false;
	OnPluginStartIndex=1;
	//CacheFiles();
	//UpdateDownloadControl();
	//RegAdminCmd("sm_soundcache",soundcache,ADMFLAG_ROOT);
}
/*
public Action soundcache(int client, int args)
{
	//g_hHistoryFiles
	char StringDetail[2048];
	char SoundModify[PLATFORM_MAX_PATH];
	for(new i = 0; i < GetArraySize(g_hHistoryFiles); i++)
	{
		GetArrayString(g_hHistoryFiles, i, STRING(SoundModify));

		if(GetArrayCell(g_hStockSound, i)<=0)
		{
			Format(StringDetail,sizeof(StringDetail),"CURRENT NON-STOCK SOUND CACHED: %s",SoundModify);
			LogDownloads(StringDetail);
		}
		else
		{
			Format(StringDetail,sizeof(StringDetail),"CURRENT STOCK SOUND CACHED: %s",SoundModify);
			LogDownloads(StringDetail);
		}
	}
	return Plugin_Handled;
}*/

LogDownloads(String:LogThis[2048])
{
		new String:szFile[256];
		BuildPath(Path_SM, szFile, sizeof(szFile), "logs/download_control.log");
		LogToFile(szFile, LogThis);
}

public War3Source_Engine_Download_Control_OnClientDisconnect_Post(client)
{
	if(IsOnMapEnd)
	{
		// Hack allows us to obtain the amount of clients connected OnMapEnd
		CurrentClientsConnected++;

		//new String:StringDetail[2048];
		//Format(StringDetail,sizeof(StringDetail),"War3Source_Engine_Download_Control: OnClientDisconnect_Post  CurrentClientsConnected:%d", CurrentClientsConnected);
		//LogDownloads(StringDetail);
	}
}

stock bool FakePrecacheSound( char szPath[PLATFORM_MAX_PATH] )
{
	char szPathStar[PLATFORM_MAX_PATH];
	Format(szPathStar, sizeof(szPathStar), "*%s", szPath);
	strcopy(STRING(szPath), szPathStar);
	AddToStringTable( FindStringTable( "soundprecache" ), szPathStar );
	return true;
}

stock bool War3_Internal_PreCacheSound( char szPath[PLATFORM_MAX_PATH] , bool preload=false )
{
#if (GGAMETYPE == GGAME_CSGO)
		return FakePrecacheSound(szPath);
#else
		return PrecacheSound(szPath, preload);
#endif
}

/**
 * Add to downloads table and precaches a given sound.
 *
 * @param sound Name of the sound to download and precache.
 * @param precache If precache is true the file will be precached.
 * @param preload If preload is true the file will be precached before level startup.
 *
 * @return True if successfully precached, false otherwise.
 */
bool War3_AddSoundFiles(char sound[PLATFORM_MAX_PATH], bool precache = true, bool preload = true)
{
	char path[PLATFORM_MAX_PATH];
	Format(path, sizeof(path), "sound/%s", sound);
	//if (FileExists(path))
	//{
	AddFileToDownloadsTable(path);
	if (precache)
	{
		return War3_Internal_PreCacheSound(sound, preload);
	}
	/*
	}
	else if (FileExists(sound))
	{
		AddFileToDownloadsTable(sound);
		if (precache)
		{
			return War3_Internal_PreCacheSound(sound, preload);
		}
	}
	else
	{
		new String:StringDetail[2048];
		Format(StringDetail,sizeof(StringDetail),"War3Source_Engine_Download_Control: Sound file \"%s\" not found", path);
		LogDownloads(StringDetail);
	}*/

	return false;
}

/**
 * Add to downloads table and precaches a given sound.
 *
 * @param mnodel Name of the sound to download and precache.
 * @param precache If precache is true the file will be precached.
 * @param preload If preload is true the file will be precached before level startup.
 *
 * @return True if successfully precached, false otherwise.
 */
bool War3_AddModelFiles(char model[PLATFORM_MAX_PATH], bool precache = true, bool preload = true)
{
	char path[PLATFORM_MAX_PATH];
	Format(path, sizeof(path), "models/%s", model);
	//if (FileExists(path))
	//{
	AddFileToDownloadsTable(path);
	if (precache)
	{
		return War3_Internal_PreCacheSound(model, preload);
	}
	/*
	}
	else if (FileExists(sound))
	{
		AddFileToDownloadsTable(sound);
		if (precache)
		{
			return War3_Internal_PreCacheSound(sound, preload);
		}
	}
	else
	{
		new String:StringDetail[2048];
		Format(StringDetail,sizeof(StringDetail),"War3Source_Engine_Download_Control: Sound file \"%s\" not found", path);
		LogDownloads(StringDetail);
	}*/

	return false;
}
// True files are added to history, false if not.

bool:AddSoundFiles(const String:sound[PLATFORM_MAX_PATH],iSoundIndex,iMaxDownloadsCount,iCurrentCount)
{
	bool ReturnBool = false;

	new String:SoundModify[PLATFORM_MAX_PATH];
	//decl String:path[PLATFORM_MAX_PATH],String:SoundModify[PLATFORM_MAX_PATH];
	//Format(path, sizeof(path), "sound/%s", sound);

	Format(SoundModify, sizeof(SoundModify), "%s", sound);

	//if (FileExists(path) && GetArrayCell(g_hStockSound, iSoundIndex)>0) return false;

	new String:StringDetail[2048];
	// Precache only stock files (Bypass history check)

	PrintToServer(SoundModify);

	TrimString(SoundModify);

	if(StrEqual("",SoundModify)) return false;

	// History Check -- do AddFileToDownloadsTable first before War3_Internal_PreCacheSound
	if(iMaxDownloadsCount > iCurrentCount)
	{
		//Removing History as it seems to be creating a problem on map change
		//if(FindStringInArray(g_hHistoryFiles, SoundModify)==-1)
		//{
			//PushArrayString(g_hHistoryFiles, sound);
			// Add to download tables if custom file
			if(GetArrayCell(g_hStockSound, iSoundIndex)<=0)
			{
				// Do not precache races or items (for now)
				//if(GetArrayCell(g_hRaceIDSound, iSoundIndex)>0)
				//{
					//War3_AddSoundFiles(SoundModify,true,false);
				//}
				//else
				//{
				War3_AddSoundFiles(SoundModify,true);
				//}
				if(GetConVarInt(EnablePRECACHEDownloadsCvar)>0)
				{
					Format(StringDetail,sizeof(StringDetail),"**AddFileToDownloadsTable** %s",SoundModify);
					LogDownloads(StringDetail);
				}
			}
			ReturnBool = true;
		//}
	}

	//if(FileExists(path) && GetArrayCell(g_hStockSound, iSoundIndex)>0)
	if(GetArrayCell(g_hStockSound, iSoundIndex)>0)
	{
		PrintToServer("STOCK SOUND: %s",SoundModify);
		if(!War3_Internal_PreCacheSound(SoundModify, false))
		{
			Format(StringDetail,sizeof(StringDetail),"War3Source_Engine_Download_Control: (War3_Internal_PreCacheSound) Sound file \"%s\" not found", SoundModify);
			LogDownloads(StringDetail);
		}
		else
		{
			if(GetConVarInt(EnablePRECACHEDownloadsCvar)>0)
			{
				Format(StringDetail,sizeof(StringDetail),"**STOCK PRECACHED** %s",SoundModify);
				LogDownloads(StringDetail);
			}
		}
	}
	else
	{
		PrintToServer("CUSTOM SOUND: %s",SoundModify);
		if(!War3_Internal_PreCacheSound(SoundModify, false))
		{
			Format(StringDetail,sizeof(StringDetail),"War3Source_Engine_Download_Control: (War3_Internal_PreCacheSound) Sound file \"%s\" not found", SoundModify);
			LogDownloads(StringDetail);
		}
		else
		{
			if(GetConVarInt(EnablePRECACHEDownloadsCvar)>0)
			{
				Format(StringDetail,sizeof(StringDetail),"**CUSTOM PRECACHED** %s",SoundModify);
				LogDownloads(StringDetail);
			}
		}
	}
	return ReturnBool;
}


bool:AddModelFiles(const String:model[PLATFORM_MAX_PATH], iSoundIndex, iMaxDownloadsCount, iCurrentCount)
{
	bool ReturnBool = false;

	new String:ModelModify[PLATFORM_MAX_PATH];
	//decl String:path[PLATFORM_MAX_PATH],String:SoundModify[PLATFORM_MAX_PATH];
	//Format(path, sizeof(path), "sound/%s", sound);

	Format(ModelModify, sizeof(ModelModify), "%s", model);

	//if (FileExists(path) && GetArrayCell(g_hStockSound, iSoundIndex)>0) return false;

	new String:StringDetail[2048];
	// Precache only stock files (Bypass history check)

	PrintToServer(ModelModify);

	TrimString(ModelModify);

	if(StrEqual("", ModelModify)) return false;

	// History Check -- do AddFileToDownloadsTable first before War3_Internal_PreCacheSound
	if(iMaxDownloadsCount > iCurrentCount)
	{
		//Removing History as it seems to be creating a problem on map change
		//if(FindStringInArray(g_hHistoryFiles, SoundModify)==-1)
		//{
			//PushArrayString(g_hHistoryFiles, sound);
			// Add to download tables if custom file
			if(GetArrayCell(g_hStockModel, iModelIndex)<=0)
			{
				// Do not precache races or items (for now)
				//if(GetArrayCell(g_hRaceIDSound, iSoundIndex)>0)
				//{
					//War3_AddSoundFiles(SoundModify,true,false);
				//}
				//else
				//{
				War3_AddModelFiles(ModelModify, true);
				//}
				if(GetConVarInt(EnablePRECACHEDownloadsCvar)>0)
				{
					Format(StringDetail, sizeof(StringDetail), "**AddFileToDownloadsTable** %s",ModelModify);
					LogDownloads(StringDetail);
				}
			}
			ReturnBool = true;
		//}
	}

	//if(FileExists(path) && GetArrayCell(g_hStockSound, iSoundIndex)>0)
	if(GetArrayCell(g_hStockModel, iModelIndex)>0)
	{
		PrintToServer("STOCK MODEL: %s",ModelModify);
		if(!War3_Internal_PreCacheModel(ModelModify, false))
		{
			Format(StringDetail, sizeof(StringDetail),"War3Source_Engine_Download_Control: (War3_Internal_PreCacheSound) Model file \"%s\" not found", ModelModify);
			LogDownloads(StringDetail);
		}
		else
		{
			if(GetConVarInt(EnablePRECACHEDownloadsCvar)>0)
			{
				Format(StringDetail, sizeof(StringDetail), "**STOCK PRECACHED** %s", ModelModify);
				LogDownloads(StringDetail);
			}
		}
	}
	else
	{
		PrintToServer("CUSTOM MODEL: %s", ModelModify);
		if(!War3_Internal_PreCacheSound(ModelModify, false))
		{
			Format(StringDetail, sizeof(StringDetail), "War3Source_Engine_Download_Control: (War3_Internal_PreCacheSound) Model file \"%s\" not found", ModelModify);
			LogDownloads(StringDetail);
		}
		else
		{
			if(GetConVarInt(EnablePRECACHEDownloadsCvar) > 0)
			{
				Format(StringDetail, sizeof(StringDetail), "**CUSTOM PRECACHED** %s", ModelModify);
				LogDownloads(StringDetail);
			}
		}
	}
	return ReturnBool;
}

//new iMaxDownloads=40, HighPriorityPercent, MedPriorityPercent, LowPriorityPercent, BottomPriorityPercent

//public OnAllPluginsLoaded()
//{
	//if(OnPluginStartIndex>0)
	//{
		//CacheFiles();
	//}
//}

public War3Source_Engine_Download_Control_OnMapStart()
{
	IsOnMapEnd=false;
	//if(OnPluginStartIndex>0)
	//{
		//OnPluginStartIndex=0;
		//ServerCommand("sm_nextmap koth_nucleus");
		//ServerCommand("mp_timelimit 1");
		//PrintToServer("MAP");
		//CreateTimer(6.0, DeleteParticle, Particle);
	//}
	if(OnPluginStartIndex>0)
	{
		CacheFiles();
		OnPluginStartIndex=0;
	}
	UpdateDownloadControl();
}

public War3Source_Engine_Download_Control_OnMapEnd()
{
	CurrentClientsConnected=0;
	IsOnMapEnd=true;

	ClearArray(g_hSoundFile);
	ClearArray(g_hStockSound);
	//ClearArray(g_hRaceIDSound);
	ClearArray(g_hPriority);

	CacheFiles();
}

public bool:War3Source_Engine_Download_Control_InitNativesForwards()
{
	g_OnAddSoundHandle = CreateGlobalForward("OnAddSound", ET_Ignore, Param_Cell);
	g_OnAddModelHandle = CreateGlobalForward("OnAddModel", ET_Ignore, Param_Cell);
	return true;
}

public bool:War3Source_Engine_Download_Control_InitNatives()
{
	CreateNative("War3_AddSound", Native_War3_AddSound);
	CreateNative("War3_AddModel", Native_War3_AddModel);

	g_hSoundFile = CreateArray(ByteCountToCells(1024));
	g_hModelFile = CreateArray(ByteCountToCells(1024));

	g_hStockSound = CreateArray(1);
	g_hPriority = CreateArray(1);

	g_hStockModel = CreateArray(1);
	g_hPriority = CreateArray(1);

	//g_hRaceIDSound = CreateArray(1);

	//g_hHistoryFiles = CreateArray(ByteCountToCells(1024));

	return true;
}

public int Native_War3_AddSound(Handle:plugin, numParams)
{
	//PrintToServer("numParams %d",numParams);
	char sSoundFile[1024];
	GetNativeString(1, sSoundFile, sizeof(sSoundFile));

	if(FindStringInArray(g_hSoundFile, sSoundFile)==-1) // if not found, add
	{
		int stocksound = GetNativeCell(2);
		PushArrayCell(g_hStockSound, stocksound);

		int priority = GetNativeCell(3);
		if(priority==PRIORITY_TAKE_FORWARD)
		{
			priority = Forward_Priority;
		}
		PushArrayCell(g_hPriority, priority);
		PushArrayString(g_hSoundFile, sSoundFile);

		/*
		if(numParams==4)
		{
			int iRaceID = GetNativeCell(4);
			PushArrayCell(g_hRaceIDSound, iRaceID);
		}
		else
		{
			PushArrayCell(g_hRaceIDSound, 0);
		}*/

	}
}

public int Native_War3_AddSound(Handle:plugin, numParams)
{
	//PrintToServer("numParams %d",numParams);
	char sModelFile[1024];
	GetNativeString(1, sModelFile, sizeof(sModelFile));

	if(FindStringInArray(g_hModelFile, sModelFile)==-1) // if not found, add
	{
		int stockmodel = GetNativeCell(2);
		PushArrayCell(g_hStockModel, stockmodel);

		int priority = GetNativeCell(3);
		if(priority==PRIORITY_TAKE_FORWARD)
		{
			priority = Forward_Priority;
		}
		PushArrayCell(g_hPriority, priority);
		PushArrayString(g_hModelFile, sModelFile);

		/*
		if(numParams==4)
		{
			int iRaceID = GetNativeCell(4);
			PushArrayCell(g_hRaceIDSound, iRaceID);
		}
		else
		{
			PushArrayCell(g_hRaceIDSound, 0);
		}*/

	}
}

//if(GetArrayCell(g_hRaceIDSound, iSoundIndex)>0))
// an old idea which could possibly work
/*
public War3Source_Engine_Download_Control_EnableRace(int iRaceID)
{
	if(iRaceID==0) return;
	char TempBuffer[PLATFORM_MAX_PATH];
	//PrintToServer("g_hSoundFile GetArraySize %d",GetArraySize(g_hSoundFile));
	bool RaceFound = false;
	for(int i = 0; i < GetArraySize(g_hSoundFile); i++)
	{
		//PrintToServer("g_hSoundFile GetArraySize %d",GetArraySize(g_hSoundFile));
		//PrintToServer("g_hRaceIDSound GetArraySize %d",GetArraySize(g_hRaceIDSound));

		//PrintToServer("Download_Control_EnableRace index %i",i);
		if(GetArrayCell(g_hRaceIDSound, i)==iRaceID)
		{
			RaceFound=true;
			GetArrayString(g_hSoundFile, i, TempBuffer, sizeof(TempBuffer));
			//precache sounds
			if(PrecacheScriptSound(TempBuffer))
			{
				PrintToServer("%s PrecacheScriptSound",TempBuffer);
				PrintToServer("RaceID %d",iRaceID);
				PrintToServer("%s Precached!",TempBuffer);
			}
			else
			{
				PrintToServer("RaceID %d",iRaceID);
				PrintToServer("%s PrecacheScriptSound ELSE",TempBuffer);
				if(PrecacheSound(TempBuffer))
				{
					PrintToServer("%s PrecacheSound Successful!",TempBuffer);
				}
				else
				{
					PrintToServer("%s PrecacheSound NOT Successful!",TempBuffer);
				}
			}
		}
	}
	if(!RaceFound)
	{
		PrintToServer("Race Sounds %d sound not in g_hSoundFile!",iRaceID);
	}
}*/
