#include <war3source>

#pragma semicolon 1

public Plugin:myinfo =
{
	name = "War3Source - Engine - Changing Sounds CFG",
	author = "El Diablo",
	description = "Allows server own to change sound files",
	version = "1.0.0",
	url = "war3source.com"
};

char sound_file_original[PLATFORM_MAX_PATH];
char sound_file_new[PLATFORM_MAX_PATH];

new Handle: old_array_sounds;
new Handle: new_array_sounds;

new Handle: war3_debug_sounds;

int Loaded = -1;


//=============================================================================
// AskPluginLoad2Custom
//=============================================================================
public APLRes:AskPluginLoad2Custom(Handle:myself,bool:late,String:error[],err_max)
{
	old_array_sounds = CreateArray(PLATFORM_MAX_PATH);
	new_array_sounds = CreateArray(PLATFORM_MAX_PATH);
	if(Loaded == -1)
	{
		Loaded = LoadSoundsConfig();
	}
	return APLRes_Success;
}

public OnPluginStart()
{
	RegAdminCmd("oldsounds", oldsounds, ADMFLAG_ROOT);
	RegAdminCmd("newsounds", newsounds, ADMFLAG_ROOT);

	war3_debug_sounds = CreateConVar("war3_debug_sounds", "0", "Enable/Disable debugging sounds");

	if(Loaded != 666)
	{
		if(old_array_sounds == null)
		{
			old_array_sounds = CreateArray(PLATFORM_MAX_PATH);
		}
		if(new_array_sounds == null)
		{
			new_array_sounds = CreateArray(PLATFORM_MAX_PATH);
		}
		Loaded = LoadSoundsConfig();
	}
}

public bool DebugOn()
{
	return GetConVarBool(war3_debug_sounds);
}

public Action oldsounds(int client, int args)
{
	char cSoundFile[PLATFORM_MAX_PATH];
	for(new i=0; i <= GetArraySize(old_array_sounds)-1; i++)
	{
		GetArrayString(old_array_sounds, i, cSoundFile, sizeof(cSoundFile));
		ReplyToCommand(client, "OLD: %i %s",i,cSoundFile);
	}
	return Plugin_Handled;
}

public Action newsounds(int client, int args)
{
	char cSoundFile[PLATFORM_MAX_PATH];
	for(new i=0; i <= GetArraySize(old_array_sounds)-1; i++)
	{
		GetArrayString(new_array_sounds, i, cSoundFile, sizeof(cSoundFile));
		ReplyToCommand(client, "NEW: %i %s",i,cSoundFile);
	}
	return Plugin_Handled;
}

public int LoadSoundsConfig()
{
	if (DebugOn() == true) { PrintToServer("1-LOADING SOUNDS CONFIG..."); }
// auto grabs for game mode:
#if (GGAMETYPE == GGAME_CSS)
	new Handle: kv = CreateKeyValues("CSS");
#elseif (GGAMETYPE == GGAME_CSGO)
	new Handle: kv = CreateKeyValues("CSGO");
#elseif (GGAMETYPE == GGAME_FOF)
	new Handle: kv = CreateKeyValues("FOF");
#elseif (GGAMETYPE == GGAME_TF2)
	new Handle: kv = CreateKeyValues("TF2");
#endif

	FileToKeyValues(kv, "addons/sourcemod/configs/war3sourcesounds.cfg");

	if (!KvGotoFirstSubKey(kv))
	{
		return ThrowNativeError(80070002, "Unable to load sounds config file. Can not find addons/sourcemod/configs/war3sourcesounds.cfg");
	}
	if (DebugOn() == true) { PrintToServer("2-LOADING SOUNDS CONFIG..."); }

	// clear array and reload for every map change
	// just in case server admin wants to change sound

	ClearArray(old_array_sounds);
	ClearArray(new_array_sounds);

	int find_index = -1;

	do {
		KvGetString(kv, "sound_file_original", sound_file_original, sizeof(sound_file_original));
		KvGetString(kv, "sound_file_new", sound_file_new, sizeof(sound_file_new));

		// prevent duplicates
		find_index = FindStringInArray(old_array_sounds, sound_file_original);
		if(find_index == -1) // if not found, add
		{
			//Store data in array
			PushArrayString(old_array_sounds, sound_file_original);
			if (DebugOn() == true) { PrintToServer("ORIGINAL SOUND: %s", sound_file_original); }
			if (DebugOn() == true) { PrintToServer("***************GetArrayBlockSize: %i", GetArraySize(old_array_sounds)); }


			PushArrayString(new_array_sounds, sound_file_new);
			if (DebugOn() == true) { PrintToServer("NEW      SOUND: %s", sound_file_new); }
			if (DebugOn() == true) { PrintToServer("***************GetArrayBlockSize: %i", GetArraySize(new_array_sounds)); }

		}

	} while (KvGotoNextKey(kv));

	CloseHandle(kv);

	return 666;
}

public Action:OnAddSoundChange(char cSoundName[64], char cSoundFile[PLATFORM_MAX_PATH])
{

	if (DebugOn() == true) { PrintToServer("***OnAddSoundChange***"); }
	if (DebugOn() == true) { PrintToServer("***cSoundName: %s", cSoundName); }
	if (DebugOn() == true) { PrintToServer("***cSoundFile: %s", cSoundFile); }

	if (DebugOn() == true) { PrintToServer("***old_array_sounds: %i", GetArraySize(old_array_sounds)); }

	int sound_file_index = FindStringInArray(old_array_sounds, cSoundFile);
	//char sSoundFileReplacement[PLATFORM_MAX_PATH]; //was 1024

	if (DebugOn() == true) { PrintToServer("***sound_file_index: %i", sound_file_index); }

	if(sound_file_index>-1) 
	{
		//replace
		if (DebugOn() == true) { PrintToServer("***replace sound***"); }
		GetArrayString(new_array_sounds, sound_file_index, cSoundFile, sizeof(cSoundFile));
		//strcopy(cSoundFile, sizeof(sSoundFileReplacement), sSoundFileReplacement);
		//SetNativeString(1, cSoundFile, sizeof(sSoundFileReplacement), false);
		if (DebugOn() == true) { PrintToServer("if(sound_file_index>-1) ***cSoundFile: %s", cSoundFile); }
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
