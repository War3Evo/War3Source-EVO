// War3Source_Variables.inc

Handle gh_CVAR_War3Source_Pause = null;

//Handle g_War3Source_Engine_CSGO_Radar = null;

ConVar gh_CVAR_AllowInstantSpawn;

ConVar gh_CVAR_DisableAllText;  // For Testing 1/27/2023

bool War3SourcePause = false;

stock dummy; //variable for dummies! Use this where ever u want for a dummy return
stock String:dummystr[32]; //just a dummy string!

//CVAR variables HANDLES are in cvar.inc
//FORWARD VARIABLES HANDLES ARE IN FORWARDS.INC

int W3VarArr[W3Var];

int dummyreturn; //for your not used return values

#if GGAMETYPE == GGAME_TF2
bool bIsInSteamGroup[MAXPLAYERSCUSTOM] = false;
#endif

/*
 * single event variables
 * these variables are reset as soon as the event finishes. when the event triggers,
 * plugins directly call natives to changet value, and the final resulting value is used.

 * for example. damageModifierPercent is default 1.0.
 * when a damage event happens, the event is notified to all races,
 * and each race can modify this like: multiply by 1.20,
 * and the final value 1.20 is used after all races have
 * a chance to change it, and the orignal damage is multiplied by 1.20 and dealt to the victim.
*/

int bInFreezeTime; // again, kinda hacky


float LastLoadingHintMsg[MAXPLAYERSCUSTOM];

int bHasDiedThisFrame[MAXPLAYERSCUSTOM];
/**********************
 * prevent double kills if the same player in the same frame,
 * like killed by skill damage is one kill message, killed by original damge is another death message,
 * woudl cause double xp kill, because skill damage is actually dealt first (nested)
 */

// El Diablo's Quick Map change convars
Handle hCvarLoadRacesAndItemsOnMapStart;
bool LoadRacesAndItemsOnMapStart;
bool RacesAndItemsLoaded;
bool MapStart;

//=============================
// war3source.inc
//=============================
int m_OffsetClrRender=-1;

//==============================
// DATABASE -- War3Source_Engine_DatabaseSaveXP
//==============================
Handle hDB;
g_SQLType War3SQLType = SQLType_Unknown;


//=================================
// RACE / SHOP / ITEMS
//=================================
Handle g_OnWar3PluginReadyHandle; //loadin default races in order
Handle g_OnWar3PluginReadyHandle2; //other races
Handle g_OnWar3PluginReadyHandle3; //other races backwards compatable
//Handle g_OnWar3PluginReadyHandle4;

//=================================
// SPAWN / DEATH EVENTS
//=================================
Handle p_OnWar3EventSpawnFH;
Handle g_OnWar3EventDeathFH;

//===============================
// War3Source_000_Configuration
//===============================
Handle hRaceLimitEnabled;
Handle hChangeGameDescCvar;
Handle hUseMetric;
Handle botsetraces = null;

//==============================
// War3Source_000_Engine_Hint
//==============================
char lastoutput[MAXPLAYERSCUSTOM][129];
Handle objarray[MAXPLAYERSCUSTOM][W3HintPriority];
bool updatenextframe[MAXPLAYERSCUSTOM];

//=============================
// War3Source_000_Engine_Log
//=============================
Handle hW3Log;
Handle hW3LogError;
Handle hW3LogNotError;
Handle hGlobalErrorFwd;

//=============================
// War3Source_Engine_Aura
//=============================
Handle g_Forward;

//=============================
// War3Source_Engine_Bank
//=============================
Handle g_hDatabase = INVALID_HANDLE;
bool CanLoadDataBase=false;
Handle g_OnWar3_BANK_PlayerLoadData = INVALID_HANDLE;

//=============================
// War3Source_Engine_BuffMaxHP
//=============================
#if GGAMETYPE == GGAME_TF2
Handle g_buffmaxhp_enable_tf2attributes;
#endif

//=============================
// War3Source_Engine_CommandHook
//=============================
Handle p_OnUltimateCommand;
Handle p_OnAbilityCommand;
Handle p_OnUseItemCommand;

//=============================
// War3Source_Engine_PlayerClass
//=============================
int p_properties[MAXPLAYERSCUSTOM][W3PlayerProp];


//=============================
// War3Source_Engine_RaceClass ------------------------------ RACE CLASS
//=============================
int totalRacesLoaded=0;  ///USE raceid=1;raceid<=GetRacesLoaded();raceid++ for looping
///race instance variables
//RACE ID = index of [MAXRACES], raceid 1 is raceName[1][32]

char raceName[MAXRACES][32];
char raceShortname[MAXRACES][16];
char raceShortdesc[MAXRACES][32];
bool raceTranslated[MAXRACES];
bool ignoreRaceEnd; ///dont do anything on CreateRaceEnd cuz this its already done once

//zeroth skill is NOT  used
int raceSkillCount[MAXRACES];
char raceSkillName[MAXRACES][MAXSKILLCOUNT][32];
char raceSkillDescription[MAXRACES][MAXSKILLCOUNT][512];
int raceSkillDescReplaceNum[MAXRACES][MAXSKILLCOUNT];
char raceSkillDescReplace[MAXRACES][MAXSKILLCOUNT][5][64]; ///MAX 5 params for replacement //64 string length
bool skillTranslated[MAXRACES][MAXSKILLCOUNT];

enum SkillRedirect
{
	genericskillid,
}
bool SkillRedirected[MAXRACES][MAXSKILLCOUNT];
int SkillRedirectedToSkill[MAXRACES][MAXSKILLCOUNT];

bool skillIsUltimate[MAXRACES][MAXSKILLCOUNT];
int skillMaxLevel[MAXRACES][MAXSKILLCOUNT];
//int skillProp[MAXRACES][MAXSKILLCOUNT][W3SkillProp];        // not used anywhere

int MinLevelCvar[MAXRACES];
int AccessFlagCvar[MAXRACES];
int RaceOrderCvar[MAXRACES];
int RaceFlagsCvar[MAXRACES];
int RestrictItemsCvar[MAXRACES];
int RestrictLimitCvar[MAXRACES][2];

Handle m_MinimumUltimateLevel;

bool racecreationended=true;
char creatingraceshortname[16];

int raceCell[MAXRACES][ENUM_RaceObject];

bool ReloadRaces_Id[MAXRACES];
int ReloadRaces_Client_Race[MAXPLAYERSCUSTOM];
char ReloadRaces_Shortname[MAXRACES][16];
char ReloadRaces_longname[MAXRACES][32];

bool MapChanging = false;
int MapChangingCount = 0;

int totalItemsLoaded=0;  ///USE raceid=1;raceid<=GetRacesLoaded();raceid++ for looping

Handle gh_AllowDeveloperPowers;
Handle gh_AllowDeveloperAccess;

Handle p_OnTalentsLoaded;

//===============================
// War3Source_001_OnSkinChange
//===============================

Handle p_OnWar3SkinChange;


//=============================
// War3Source_Engine_SkillsClass ------------------------------ SKILLS CLASS
//=============================

Handle p_OnWar3SkillSlotChange;

char skill_Name[MAXSKILLS][32];
char skill_Shortname[MAXSKILLS][16];
char skill_Short_Description[MAXSKILLS][256];
char skill_Description[MAXSKILLS][512];

//If a player is assigned a skill by the race, this holds the information
int skill_PlayerSkill[MAXPLAYERSCUSTOM][MAXSKILLCOUNT];


//=============================
// War3Source_Engine_ItemClass2
//=============================
int totalItems2Loaded=0;


//=============================
// War3Source_Engine_ItemClass3
//=============================
#if SHOPMENU3 == MODE_ENABLED
int totalItems3Loaded=0;
#endif

//=============================
// War3Source_Engine_SkillsClass
//=============================
int totalSkillsLoaded=0;

//=============================
// War3Source_Engine_TrieKeyValue
//=============================
Handle Cvartrie;
Handle Cvararraylist; //cvar
Handle Cvararraylist2; //cvar definition

#if GGAMETYPE == GGAME_TF2
Handle gh_MaxSpeedDebugConvar;
bool bMaxSpeedDebugMessages = false;
Handle gh_MaxSpeedLimitConvar;
float fWar3_MaxSpeedLimit = 1.4;
#endif

//=============================
// War3Source_Engine_BuffSpeedGravGlow
//=============================
int m_OffsetSpeed=-1;

int reapplyspeed[MAXPLAYERSCUSTOM];
bool invisWeaponAttachments[MAXPLAYERSCUSTOM];
bool bDeniedInvis[MAXPLAYERSCUSTOM];

float gspeedmulti[MAXPLAYERSCUSTOM];

float speedBefore[MAXPLAYERSCUSTOM];
float speedWeSet[MAXPLAYERSCUSTOM];


//=============================
// War3Source_Engine_CSGO_Radar
//=============================
#if GGAMETYPE == GGAME_CSGO
Handle mp_teamcashawards;
Handle mp_playercashawards;
bool CSGO_Radar_Changed[MAXPLAYERSCUSTOM];
#endif
