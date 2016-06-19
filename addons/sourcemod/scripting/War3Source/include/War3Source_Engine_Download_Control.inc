// War3Source_Engine_Download_Control.inc

#if defined _Download_Control_included
 #endinput
#endif
#define _Download_Control_included

//#define MAX_SOUND_FILES 5000
#define STOCK_SOUND 1

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
 * @param soundfile: Sound file to cache
 * @param priority: Uses forward priority when called

 * @return nothing
 */
native War3_AddSound(String:soundfile[],stocksound=0,priority=PRIORITY_TAKE_FORWARD);

// WARD EVENTS

forward OnAddSound(sound_priority);

// STOCKS
stock War3_EmitSound(const clients[],
					numClients,
					const String:sample[],
					entity = SOUND_FROM_PLAYER,
					channel = SNDCHAN_AUTO,
					level = SNDLEVEL_NORMAL,
					flags = SND_NOFLAGS,
					Float:volume = SNDVOL_NORMAL,
					pitch = SNDPITCH_NORMAL,
					speakerentity = -1,
					const Float:origin[3] = NULL_VECTOR,
					const Float:dir[3] = NULL_VECTOR,
					bool:updatePos = true,
					Float:soundtime = 0.0)
{
	decl String:szSound[PLATFORM_MAX_PATH];

#if (GGAMETYPE == GGAME_CSGO)
	Format(szSound, sizeof(szSound), "*%s", sample);
#else
	strcopy(szSound, sizeof(szSound), sample);
#endif

	EmitSound(clients, numClients, szSound, entity, channel, level, flags, volume, pitch, speakerentity, origin, dir, updatePos, soundtime);
}

stock War3_EmitSoundToClient(client,
							const String:sample[],
							entity = SOUND_FROM_PLAYER,
							channel = SNDCHAN_AUTO,
							level = SNDLEVEL_NORMAL,
							flags = SND_NOFLAGS,
							Float:volume = SNDVOL_NORMAL,
							pitch = SNDPITCH_NORMAL,
							speakerentity = -1,
							const Float:origin[3] = NULL_VECTOR,
							const Float:dir[3] = NULL_VECTOR,
							bool:updatePos = true,
							Float:soundtime = 0.0)
{
	new clients[1];
	clients[0] = client;
	/* Save some work for SDKTools and remove SOUND_FROM_PLAYER references */
	entity = (entity == SOUND_FROM_PLAYER) ? client : entity;
	War3_EmitSound(clients, 1, sample, entity, channel,
	level, flags, volume, pitch, speakerentity,
	origin, dir, updatePos, soundtime);
}

stock War3_EmitSoundToAll(const String:sample[],
						entity = SOUND_FROM_PLAYER,
						channel = SNDCHAN_AUTO,
						level = SNDLEVEL_NORMAL,
						flags = SND_NOFLAGS,
						Float:volume = SNDVOL_NORMAL,
						pitch = SNDPITCH_NORMAL,
						speakerentity = -1,
						const Float:origin[3] = NULL_VECTOR,
						const Float:dir[3] = NULL_VECTOR,
						bool:updatePos = true,
						Float:soundtime = 0.0)
{
	new clients[MaxClients];
	new total = 0;

	for (new i=1; i<=MaxClients; i++)
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

	War3_EmitSound(clients, total, sample, entity, channel,
	level, flags, volume, pitch, speakerentity,
	origin, dir, updatePos, soundtime);
}

stock War3_EmitAmbientSound(const String:sample[],
						const Float:pos[3],
						entity = SOUND_FROM_WORLD,
						level = SNDLEVEL_NORMAL,
						flags = SND_NOFLAGS,
						Float:vol = SNDVOL_NORMAL,
						pitch = SNDPITCH_NORMAL,
						Float:delay = 0.0)
{
	decl String:szSound[PLATFORM_MAX_PATH];

#if (GGAMETYPE == GGAME_CSGO)
	Format(szSound, sizeof(szSound), "*%s", sample);
#else
	strcopy(szSound, sizeof(szSound), sample);
#endif

	EmitAmbientSound(szSound, pos, entity, level, flags, vol, pitch, delay);
}

stock War3_StopSound(entity, channel, const String:sample[])
{
	decl String:szSound[PLATFORM_MAX_PATH];

#if (GGAMETYPE == GGAME_CSGO)
	Format(szSound, sizeof(szSound), "*%s", sample);
#else
	strcopy(szSound, sizeof(szSound), sample);
#endif

	StopSound(entity, channel, szSound);
}
