// War3Source_Engine_Download_Control.inc

#if defined _Download_Control_included
 #endinput
#endif
#define _Download_Control_included

//#define MAX_SOUND_FILES 5000
/**
 * @section Bitwise values definitions for admin flags.
 */
#define PRIORITY_TOP			(1<<0)		/**< Convenience macro for Admin_Reservation as a FlagBit */
#define PRIORITY_HIGH			(1<<1)		/**< Convenience macro for Admin_Generic as a FlagBit */ //%50
#define PRIORITY_MEDIUM			(1<<2)		/**< Convenience macro for Admin_Kick as a FlagBit */    //%25
#define PRIORITY_LOW			(1<<3)		/**< Convenience macro for Admin_Ban as a FlagBit */ //%
#define PRIORITY_BOTTOM			(1<<4)		/**< Convenience macro for Admin_Unban as a FlagBit */
//#define PRIORITY_				(1<<5)		/**< Convenience macro for Admin_Slay as a FlagBit */
//#define PRIORITY_			(1<<6)		/**< Convenience macro for Admin_Changemap as a FlagBit */
//#define PRIORITY_				(1<<7)		/**< Convenience macro for Admin_Convars as a FlagBit */
//#define PRIORITY_				(1<<8)		/**< Convenience macro for Admin_Config as a FlagBit */
//#define PRIORITY_				(1<<9)		/**< Convenience macro for Admin_Chat as a FlagBit */
//#define PRIORITY_				(1<<10)		/**< Convenience macro for Admin_Vote as a FlagBit */
//#define PRIORITY_			(1<<11)		/**< Convenience macro for Admin_Password as a FlagBit */
//#define PRIORITY_				(1<<12)		/**< Convenience macro for Admin_RCON as a FlagBit */
//#define PRIORITY_				(1<<13)		/**< Convenience macro for Admin_Cheats as a FlagBit */
//#define PRIORITY_				(1<<14)		/**< Convenience macro for Admin_Root as a FlagBit */
//#define PRIORITY_				(1<<15)		/**< Convenience macro for Admin_Custom1 as a FlagBit */
//#define PRIORITY_				(1<<16)		/**< Convenience macro for Admin_Custom2 as a FlagBit */
//#define PRIORITY_				(1<<17)		/**< Convenience macro for Admin_Custom3 as a FlagBit */
//#define PRIORITY_				(1<<18)		/**< Convenience macro for Admin_Custom4 as a FlagBit */
//#define PRIORITY_				(1<<19)		/**< Convenience macro for Admin_Custom5 as a FlagBit */
#define PRIORITY_TAKE_FORWARD				(1<<20)		/**< Convenience macro for Admin_Custom6 as a FlagBit */

/**
 * Adds Sounds to DownloadTable and Cache as needed.
 *
 * @param SoundName: The name of the sound, could be race name, or anything else
 * @param soundfile: Sound file to cache
 * @param priority: Uses forward priority when called

 * @return nothing
 */
native void War3_AddSound(char[] SoundName,char[] soundfile,int stocksound=0,int priority=PRIORITY_TAKE_FORWARD);

// WARD EVENTS

forward OnAddSound(sound_priority);
forward Action:OnAddSoundChange(char cSoundName[64], char cSoundFile[PLATFORM_MAX_PATH]);

// STOCKS
stock War3_EmitSound(const int[] iclients,
					int inumClients,
					const char[] csample,
					int ientity = SOUND_FROM_PLAYER,
					int ichannel = SNDCHAN_AUTO,
					int ilevel = SNDLEVEL_NORMAL,
					int iflags = SND_NOFLAGS,
					float fvolume = SNDVOL_NORMAL,
					int ipitch = SNDPITCH_NORMAL,
					int ispeakerentity = -1,
					float forigin[3] = NULL_VECTOR,
					float fdir[3] = NULL_VECTOR,
					bool bupdatePos = true,
					float fsoundtime = 0.0)
{
	char szSound[PLATFORM_MAX_PATH];

#if (GGAMETYPE == GGAME_CSGO)
	Format(szSound, sizeof(szSound), "*%s", csample);
#else
	strcopy(szSound, sizeof(szSound), csample);
#endif

	EmitSound(iclients, inumClients, szSound, ientity, ichannel, ilevel, iflags, fvolume, ipitch, ispeakerentity, forigin, fdir, bupdatePos, fsoundtime);
}

stock War3_EmitSoundToClient(int client,
							const char[] sample,
							int entity = SOUND_FROM_PLAYER,
							int channel = SNDCHAN_AUTO,
							int level = SNDLEVEL_NORMAL,
							int flags = SND_NOFLAGS,
							float volume = SNDVOL_NORMAL,
							int pitch = SNDPITCH_NORMAL,
							int speakerentity = -1,
							float origin[3] = NULL_VECTOR,
							float dir[3] = NULL_VECTOR,
							bool updatePos = true,
							float soundtime = 0.0)
{
	int clients[1];
	clients[0] = client;
	/* Save some work for SDKTools and remove SOUND_FROM_PLAYER references */
	entity = (entity == SOUND_FROM_PLAYER) ? client : entity;
	War3_EmitSound(clients, 1, sample, entity, channel,
	level, flags, volume, pitch, speakerentity,
	origin, dir, updatePos, soundtime);
}

stock War3_EmitSoundToAll(const char[] csample,
						int ientity = SOUND_FROM_PLAYER,
						int ichannel = SNDCHAN_AUTO,
						int ilevel = SNDLEVEL_NORMAL,
						int iflags = SND_NOFLAGS,
						float fvolume = SNDVOL_NORMAL,
						int ipitch = SNDPITCH_NORMAL,
						int ispeakerentity = -1,
						float forigin[3] = NULL_VECTOR,
						float fdir[3] = NULL_VECTOR,
						bool bupdatePos = true,
						float fsoundtime = 0.0)
{
	int[] clients = new int[MaxClients];
	int total = 0;

	for (int i=1; i<=MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			clients[total++] = i;
		}
	}

	if (!total)
	{
		return;
	}

	War3_EmitSound(clients, total, csample, ientity, ichannel,
	ilevel, iflags, fvolume, ipitch, ispeakerentity,
	forigin, fdir, bupdatePos, fsoundtime);
}

stock War3_EmitAmbientSound(char[] sample,
						const float pos[3],
						int entity = SOUND_FROM_WORLD,
						int level = SNDLEVEL_NORMAL,
						int flags = SND_NOFLAGS,
						float vol = SNDVOL_NORMAL,
						int pitch = SNDPITCH_NORMAL,
						float delay = 0.0)
{
	char szSound[PLATFORM_MAX_PATH];

#if (GGAMETYPE == GGAME_CSGO)
	Format(szSound, sizeof(szSound), "*%s", sample);
#else
	strcopy(szSound, sizeof(szSound), sample);
#endif

	EmitAmbientSound(szSound, pos, entity, level, flags, vol, pitch, delay);
}

stock War3_StopSound(int entity, int channel, const char[] sample)
{
	char szSound[PLATFORM_MAX_PATH];

#if (GGAMETYPE == GGAME_CSGO)
	Format(szSound, sizeof(szSound), "*%s", sample);
#else
	strcopy(szSound, sizeof(szSound), sample);
#endif

	StopSound(entity, channel, szSound);
}
