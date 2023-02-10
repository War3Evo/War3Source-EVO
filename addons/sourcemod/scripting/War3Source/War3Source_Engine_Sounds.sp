// War3Source_Engine_Sounds.sp

/*
"FOF"
{
	"HumanAlliance"
	{
		"sound_file_original" "war3source/blinkarrival.mp3"
		"sound_file_new"   "war3source/blinkarrival.wav"
	}
	"NightElf"
	{
		"sound_file_original" "war3source/entanglingrootsdecay1.mp3"
		"sound_file_new"   "war3source/entanglingrootsdecay1.wav"
	}
}
"TF2"
{
	"HumanAlliance"
	{
		"sound_file_original" "war3source/blinkarrival.mp3"
		"sound_file_new"   "war3source/blinkarrival.wav"
	}
	"NightElf"
	{
		"sound_file_original" "war3source/entanglingrootsdecay1.mp3"
		"sound_file_new"   "war3source/entanglingrootsdecay1.wav"
	}
}
*/
public War3Source_Engine_Sounds_OnPluginStart()
{
	array_sounds = CreateArray(PLATFORM_MAX_PATH);
}

// called in War3Source_Engine_Download_Control.sp in CacheFiles()
public LoadSoundsConfig()
{
//SoundConfigLoaded = false;

// auto grabs for game mode:
#if GGAMETYPE == GGAME_CSS
	new Handle: kv = CreateKeyValues("CSS");
#elseif GGAMETYPE == GGAME_CSGO
	new Handle: kv = CreateKeyValues("CSGO");
#elseif GGAMETYPE == GGAME_FOF
	new Handle: kv = CreateKeyValues("FOF");
#elseif GGAMETYPE == GGAME_TF2
	new Handle: kv = CreateKeyValues("TF2");
#endif

	FileToKeyValues(kv, "addons/sourcemod/configs/War3SourceSounds.cfg");

	if (!KvGotoFirstSubKey(kv))
	{
		return;
	}

	// clear array and reload for every map change
	// just in case server admin wants to change sound
	ClearArray(array_sounds);

	do {
		KvGetString(kv, "sound_file_original", sound_file_original, sizeof(sound_file_original));
		KvGetString(kv, "sound_file_new", sound_file_new, sizeof(sound_file_new));

		// prevent duplicates
		if(FindStringInArray(array_sounds, sound_file_original)==-1) // if not found, add
		{
			//Store data in array
			PushArrayString(array_sounds, sound_file_original);
			PushArrayString(array_sounds, sound_file_new);
		}

	} while (KvGotoNextKey(kv));

	CloseHandle(kv);

	//SoundConfigLoaded = true;	
}

