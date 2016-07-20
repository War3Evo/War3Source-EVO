//War3Source_Interface.inc

//Here to provide backwards compatibilty for 2nd Gen War3Source Races
#include <war3source>

enum ValveGameEnum
{
	Game_None=0,
	Game_CS=1,
	Game_DOD=2,
	Game_TF=3,
	Game_L4D=4,
	Game_L4D2=5,
	Game_CSGO=6,
	Game_FOF=7,

	//Are you feeling Lazy? use this!
	CS=Game_CS,
	DOD=Game_DOD,
	FOF=Game_FOF,
	TF=Game_TF,
	L4D=Game_L4D,
	L4D2=Game_L4D2,
	CSGO=Game_CSGO
}

/**
 * Gets called when the +ultimate or -ultimate command is called, IT ISNT ALWAYS FOR YOUR RACE, YOU NEED TO CHECK!!!
 * @param client: The client's index.
 * @param race: The race for which it was called.
 * @param pressed: If true, +ultimate, false, -ultimate.
 */
forward OnUltimateCommand(client,race,bool pressed);


/**
 * Gets called when the +ability# or -ability# command is called.
 * If its +ability or -ability (without a number), 0 is passed to ability.
 * Isn't always for you, check War3_GetRace(client)==yourRace
 * @param client: The client's index.
 * @param ability: The ability number.
 * @param pressed: If true, +ability#, false, -ability#.
 */
forward OnAbilityCommand(client,ability,bool pressed);

forward OnWar3Event(W3EVENT:event,client);

// Generic damage event, derived from SDKHooks
// This damage is POSTHURT and damage CANNOT BE MODIFIED
// Use OnW3TakeDmgAllPre if you need to modify damage
forward OnWar3EventPostHurt(victim, attacker, float damage, const String:weapon[32], bool isWarcraft);

/**
 * Called when a an entity takes damage, requires SDK Hooks until SM natively supports this.
 * @param victim: Victim entity.
 * @param attacker: Attacker entity.
 * @param damage: How much damage is done.
 * @noreturn
 *
 * order of execution is
 * damageallpre
 * bulletpre (if bullet)
 * damageall
 * bullet  (if bullet)
 */
//Friendly Fire triggers this function!!! even though it didnt damage any teammate
//Ubered victim triggers this function, even though it didnt damage the enemy (BLOCKED INTERNALLY BY WAR3 from forwarding)
//THIS is a theoretical damage given by the engine, if u want real damage dealt use the hurt-event
//use natives to retrieve inflictor and game damagetype
//becareful when using this, u should only use this to reduce incoming damage. if you want to return damge, only use on bullet (first trigger damage)(below) or check IsBullet
//you may set damage mod percent HERE
//you may NOT DAMAGE IN HERE
forward OnW3TakeDmgAllPre(victim,attacker,float damage);
/**
 * Same forward as above, but this is only fired if victim and attacker are both valid, the victim is alive,
 * they are different entitys and they are on different teams
 */
forward OnW3EnemyTakeDmgBulletPre(victim, attacker, float damage);

//bullet only
forward OnW3TakeDmgBulletPre(victim,attacker,float damage);

//you may NOT set damage mod percent HERE
//you may DAMAGE in here, however damage will be engine theoretical damage, not actual damage dealt
forward OnW3TakeDmgAll(victim,attacker,float damage);
// BULLET GAME DAMAGE ONLY or Warcraft damage that is allowed to be retriggered (allow more item and skill modifiers), (FILTERED)
//you may NOT set damage mod percent HERE
//you may DAMAGE in here
forward OnW3TakeDmgBullet(victim,attacker,float damage);


/**
 * Extends the path to a sound clip with the correct prefix
 */
stock void War3_AddSoundFolder(char[] sBaseString, int maxlength, char[] sSoundFile)
{
	Format(sBaseString, maxlength, "war3source/%s", sSoundFile);
}

stock bool War3_AddCustomSound(char[] csound, bool precache = true, bool preload = true)
{
	War3_AddSound(csound);
}

stock W3EmitSoundToAll(char[] csample,
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
  War3_EmitSoundToAll(csample,ientity,ichannel,ilevel,iflags,fvolume,ipitch,ispeakerentity,forigin,fdir,bupdatePos,fsoundtime);
}

native ValveGameEnum War3_GetGame();

//some races need to see this even if they aren't tf2 :/ **What a waste of processer time!
#if GGAMETYPE != GGAME_TF2
/**
 * Stock for displaying the healthlost particle in TF2
 */
stock War3_ShowHealthLostParticle(client)
{
	//
}
stock W3IsOwnerSentry(client,bool UseInternalInflictor=true,ExternalInflictor=0)
{
	//
}
#endif

//native War3_LogInfo(const String:fmt[], any:...);
