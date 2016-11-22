// IMPORTANT: TO ADD MORE TO THIS LIST, ADD TO THE BOTTOM!

//Basically Instance variables for the Player Class
enum W3PlayerProp
{
	bool:bPutInServer,
	CurrentRace,
	PendingRace,
	PlayerGold,
	PlayerDiamonds,//REMOVE PlayerDiamonds, //DRPECE
	iMaxHP,
	bIsDucking,

	JoinDate,

	bool:xpLoaded,
	bool:talentsLoaded,
	Float:RaceChosenTime,
	bool:RaceSetByAdmin,
	bool:SpawnedOnce, //if player has spawned once
	Float:sqlStartLoadXPTime,

	bool:isDeveloper,
	bool:isOfficalW3E,
	Float:LastChangeTeamTime,
	bool:bStatefulSpawn, //set true if spawn is a non repeated spawn. set to true on join and death, set false after spawn forward is finished.
	iGoldDiamondHud,   // Player preferences (Gold Hud on / off)
	bool:dbRaceSelected, //used in spawn camper.
	PlayerPlatinum,
	iBuffChatInfo, // Player preferences (Detailed Buff messages)
	iDetailedOnDeathMsgs, // Player preferences (Detailed Buff messages)
	iBuffChatInfo2, // Player preferences (Detailed Buff messages)
	iIntroSong, // Player preferences
	iSaySounds, // Player preferences
	iHlstatsx,
	iAutoBuyMaxGoldItem,
	iServerAds,
	iIrcCrossServerChat,
	iFragRadio,
	iRotateHUD,
	iChatText,
	iCombatMessages,
	iAdminSecurityExtra,
	//iTomeCount,
	//iAutoBuyMaxGoldItem,
	iGraphics,
#if GGAMETYPE == GGAME_TF2
	TFClassType:CurrentClass
#endif
}

native int W3SetPlayerProp(int client,W3PlayerProp property,any value);
native any W3GetPlayerProp(int client,W3PlayerProp property);

