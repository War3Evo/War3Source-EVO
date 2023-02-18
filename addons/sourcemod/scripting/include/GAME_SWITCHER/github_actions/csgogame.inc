// currentgame.inc

#if defined _currentgame_included
 #endinput
#endif
#define _currentgame_included

//To compile you will need to uncomment for what you want to compile for,
//then comment out everything else using //

// Look for switchgamemode.inc in the /scripting/include folder location for defines

// tf2 MVM
//Uncomment below for TF2 MVM:

//#define GGAMETYPE GGAME_TF2
//#define GGAMETYPE2 GGAME_MVM
//#define GGAMETYPE_KDR KDR_OFF
//#define GGAMETYPE_JAILBREAK JAILBREAK_OFF
//#define GGAMEMODE MODE_WAR3SOURCE

//#define SHOPMENU3 MODE_ENABLED

// This was programmally added in to try to have more control
// over spammy War3Source because CSGO can't handle so much
// client spam.  I didn't fully complete it.  If someone else
// wishes to complete this, you can turn it on in currentgame.inc
// This does not help a normal server owner, but may extend itself for a programmer.
//#define MESSAGE_CONTROL_MODE MODE_CONTROL_MESSAGES_DISABLED
//Stop of uncomment for TF2 MVM


// TF2
//Uncomment below for TF2:
//#define GGAMETYPE GGAME_TF2
//#define GGAMETYPE2 GGAME_TF2_NORMAL
//#define GGAMETYPE_KDR KDR_OFF
//#define GGAMETYPE_JAILBREAK JAILBREAK_OFF
//#define GGAMEMODE MODE_WAR3SOURCE
//#define SHOPMENU3 MODE_DISABLED
// This was programmally added in to try to have more control
// over spammy War3Source because CSGO can't handle so much
// client spam.  I didn't fully complete it.  If someone else
// wishes to complete this, you can turn it on in currentgame.inc
// This does not help a normal server owner, but may extend itself for a programmer.
//#define MESSAGE_CONTROL_MODE MODE_DISABLED
// MODE_DISABLED MODE_ENABLED
//#define CYBORG_SKIN MODE_DISABLED
//Stop of uncomment for TF2


//CSGO
//Uncomment below for CSGO:
#define GGAMETYPE GGAME_CSGO
#define GGAMETYPE2 GGAME_CSGO_2
#define GGAMETYPE_KDR KDR_OFF
#define GGAMETYPE_JAILBREAK JAILBREAK_OFF
#define GGAMEMODE MODE_WAR3SOURCE
#define CYBORG_SKIN MODE_DISABLED
#define SHOPMENU3 MODE_DISABLED
// This was programmally added in to try to have more control
// over spammy War3Source because CSGO can't handle so much
// client spam.  I didn't fully complete it.  If someone else
// wishes to complete this, you can turn it on in currentgame.inc
// This does not help a normal server owner, but may extend itself for a programmer.
#define MESSAGE_CONTROL_MODE MODE_DISABLED
//Stop of uncomment for CSGO


////CSS
//Uncomment below for CSS:
//#define GGAMETYPE GGAME_CSS
//#define GGAMETYPE2 GGAME_CSS_2
//#define GGAMETYPE_KDR KDR_ON
//#define GGAMETYPE_JAILBREAK JAILBREAK_OFF
//#define GGAMEMODE MODE_WAR3SOURCE
//#define CYBORG_SKIN MODE_DISABLED
//#define SHOPMENU3 MODE_DISABLED
// This was programmally added in to try to have more control
// over spammy War3Source because CSGO can't handle so much
// client spam.  I didn't fully complete it.  If someone else
// wishes to complete this, you can turn it on in currentgame.inc
// This does not help a normal server owner, but may extend itself for a programmer.
//#define MESSAGE_CONTROL_MODE MODE_DISABLED
//Stop of uncomment for CSS


//FoF
//Uncomment below for FoF:
//#define GGAMETYPE GGAME_FOF
//#define GGAMETYPE2 GGAME_FOF_2
//#define GGAMETYPE_KDR KDR_ON
//#define GGAMETYPE_JAILBREAK JAILBREAK_OFF
//#define GGAMEMODE MODE_WAR3SOURCE
//#define CYBORG_SKIN MODE_DISABLED
//#define SHOPMENU3 MODE_DISABLED
// This was programmally added in to try to have more control
// over spammy War3Source because CSGO can't handle so much
// client spam.  I didn't fully complete it.  If someone else
// wishes to complete this, you can turn it on in currentgame.inc
// This does not help a normal server owner, but may extend itself for a programmer.
//#define MESSAGE_CONTROL_MODE MODE_DISABLED
//Stop of uncomment for FoF
