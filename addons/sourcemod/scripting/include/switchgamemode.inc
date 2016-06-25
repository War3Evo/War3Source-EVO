// switchgamemode.inc
// #include <switchgamemode>

#if defined _switchgamemode_included
 #endinput
#endif
#define _switchgamemode_included

#define do_not_compile_this_code


// GGAMETYPE
#define DONTCOMPILE 0
#define GGAME_TF2 1
#define GGAME_CSS 3
#define GGAME_ANYTF 4
#define GGAME_TRADE 5
#define GGAME_HIGHLANDER 7
#define GGAME_CSGO 8
#define GGAME_FOF 9

#define GGAME_PVM 6 // for GGAMETYPE2
#define GGAME_TF2_NORMAL 7 // for GGAMETYPE2
#define GGAME_MVM 2 // for GGAMETYPE2
#define GGAME_CSGO_2 10 // for GGAMETYPE2

#define KDR_ON 1 // for GGAMETYPE_KDR
#define KDR_OFF 0 // for GGAMETYPE_KDR

#define JAILBREAK_ON 1 // for GGAMETYPE_JAILBREAK
#define JAILBREAK_OFF 0 // for GGAMETYPE_JAILBREAK

#define MODE_VANILLA 1
#define MODE_WAR3SOURCE 2
#define MODE_WAR3SOURCE_JAILBREAK 3
#define MODE_TF2RPG 4
#define MODE_MGE 5

#define MODE_DISABLED 0
#define MODE_ENABLED 1

//meanwhile in coding...

//#if GGAMETYPE == GGAME_TF2

//actual codes

//#endif

#include "GAME_SWITCHER/currentgame"




