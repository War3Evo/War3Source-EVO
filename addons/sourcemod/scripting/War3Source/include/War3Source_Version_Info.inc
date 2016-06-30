// War3Source_Version_Info.inc
//#assert GGAMEMODE == MODE_WAR3SOURCE

#if GGAMETYPE2  == GGAME_MVM
#define VERSION_NUM "3.0_MVM"
#elseif GGAMETYPE_JAILBREAK == JAILBREAK_ON
#define VERSION_NUM "3.0_TF2Jail"
#elseif GGAMETYPE == GGAME_CSGO
// DON'T CHANGE 3.0_CSGO ... JENKINS USES IT
// DON'T CHANGE 3.0_CSGO ... JENKINS USES IT
// DON'T CHANGE 3.0_CSGO ... JENKINS USES IT
#define VERSION_NUM "3.0_CSGO"
#else
#define VERSION_NUM "3.0_TF2"
#endif

//#define VERSION_NUM "1.3.3.1"
//#define eVERSION_NUM "1.0.5.0 (8/6/2013)"
#define eVERSION_NUM "1.2.4.1"
//#define REVISION_NUM 12321 //increment every release
#define REVISION_NUM 12450 //increment every release

//DO NOT REMOVE THE OFFICIAL AUTHORS. YOU SHALL NOT DEPRIVE THEM OF THE CREDIT THEY DESERVE
//#define AUTHORS "PimpinJuice and Ownz (DarkEnergy)"
// Removed orignal since we have been sought out for creating war3source and several
// servers claim us DDOSing their servers and we do not own War3Source.
// We are removing all War3Source name from our servers.  We dont wish
// the other War3Source servers to think we own War3Source

#define AUTHORS "Ownz (DarkEnergy), El Diablo and DAGOTHUR"
#define eAUTHORS "PimpinJuice and Ownz (DarkEnergy)"
