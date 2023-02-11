// War3Source_Engine_Money_Timer.sp

//#assert GGAMEMODE == MODE_WAR3SOURCE

#if (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
//Not sure why I have this here yet, as it compiles fine
//#include <cssdm>
#endif

//#pragma semicolon 1

#if (GGAMETYPE == GGAME_TF2)
new Handle:HudGoldDiamondMessage;
#endif

///////////////////////////////////////////////////////////////////
// Plugin Info
//////////////////////////////////////////////////////////////////
/*
public Plugin:myinfo =
{
	name = "War3Source:EVO Engine Addon",
	author = "El Diablo",
	description = "Engine Addons",
	version = PLUGIN_VERSION,
	url = "http://www.war3evo.com"
};
*/
public War3Source_Engine_Money_Timer_OnPluginStart()
{
#if (GGAMETYPE == GGAME_TF2)
	HudGoldDiamondMessage = CreateHudSynchronizer();
#endif

	CreateTimer(30.0,Timer_UpdateInfo);
	CreateTimer(60.0,Timer_Diamonds);
#if (GGAMETYPE_JAILBREAK == JAILBREAK_ON)
	CreateTimer(60.0,Timer_Gold);
#endif
}

/*
new currentRegs=0;
new currentInGame=0;
new currentConnected=0;
new totalPlayers=0;
new hasLevels=0;
stock SetStatNumbers() {
	currentRegs=0;
	currentInGame=0;
	currentConnected=0;
	totalPlayers=0;
	hasLevels=0;
	for(new i=1; i<GetMaxClients(); i++) {
		if(IsClientConnected(i)) {
			currentConnected++;
			if (!IsFakeClient(i))
			{
				if (W3GetTotalLevels(i) >= 50)
					currentRegs++;
				if (W3GetTotalLevels(i) >= 10)
					hasLevels++;
				if (IsClientInGame(i))
					currentInGame++;
				totalPlayers++;
			}



		}
	}
}*/


/* ***************************  Timer_UpdateInfo *************************************/
new Float:RotateTimer[MAXPLAYERSCUSTOM]=0.0;
new RotateNum[MAXPLAYERSCUSTOM]=0;
new oldVals[33][3];


public Action:Timer_UpdateInfo(Handle:timer)
{
	if(!MapChanging && !War3SourcePause)
	{
		new String:buffer[512];
		new gold;
		new diamonds;
		new platinum;

		new String:goldChange[10];
		new String:diamondsChange[10];
		new String:platinumChange[10];
		//SetStatNumbers();
		for(new i;i<=MaxClients;i++)
		{

			if(ValidPlayer(i) && !IsFakeClient(i) && ( GetPlayerProp(i,iGoldDiamondHud)==1))
			{
				//PrintToServer("%i",i);
				//if(GetAdminFlag(GetUserAdmin(i), Admin_Root))
				//{
					//PrintToServer("yes");


					//SetHudTextParams(0.02, 0.04, 1.02, 255, 255, 0, 255);

					//ShowSyncHudText(i, playerCt, " %i T || %i P || %i IG || %i R || %i L",currentConnected,totalPlayers,currentInGame,currentRegs,hasLevels);
				//}

				gold=GetPlayerProp(i, PlayerGold);
				diamonds=War3_GetDiamonds(i);
				platinum=War3_GetPlatinum(i);

				if (gold != oldVals[i][0]) {
					if (gold-oldVals[i][0] > 0)
						Format(goldChange,sizeof(goldChange)," (+%i)",gold-oldVals[i][0]);
					else
						Format(goldChange,sizeof(goldChange)," (%i)",gold-oldVals[i][0]);
				} else {
					Format(goldChange,sizeof(goldChange),"");
				}

				if (diamonds != oldVals[i][1]) {
					if (diamonds-oldVals[i][1] > 0)
						Format(diamondsChange,sizeof(diamondsChange)," (+%i)",diamonds-oldVals[i][1]);
					else
						Format(diamondsChange,sizeof(diamondsChange)," (%i)",diamonds-oldVals[i][1]);

				} else {
					Format(diamondsChange,sizeof(diamondsChange),"");
				}

				if (platinum != oldVals[i][2]) {
					if (platinum-oldVals[i][2] > 0)
						Format(platinumChange,sizeof(platinumChange)," (+%i)",platinum-oldVals[i][2]);
					else
						Format(platinumChange,sizeof(platinumChange)," (%i)",platinum-oldVals[i][2]);
				} else {
					Format(platinumChange,sizeof(platinumChange),"");
				}

				if(GetPlayerProp(i,iRotateHUD)==1||GetPlayerProp(i,iRotateHUD)==2) {
					if(RotateTimer[i]<=0.0) {
						RotateTimer[i]=GetEngineTime();
					}
					if(RotateTimer[i]<GetEngineTime()) {
						if (GetPlayerProp(i,iRotateHUD)==2)
							RotateNum[i]++;
						else
							RotateNum[i]=0; //was RotateNum[i]++;
						RotateTimer[i]=GetEngineTime()+6.0;
						if(RotateNum[i]>2) {
							RotateNum[i]=0;
						}
					}
					if(RotateNum[i]==0) {
						Format(buffer,sizeof(buffer)," Gold: %i%s (Type !war3menu)",gold,goldChange);
						oldVals[i][0]=gold;
					} else if (RotateNum[i]==1) {
						Format(buffer,sizeof(buffer)," Diamonds: %i%s (Type !war3menu)",diamonds,diamondsChange);
						oldVals[i][1]=diamonds;
					} else if (RotateNum[i]==2) {
						oldVals[i][2]=platinum;
						Format(buffer,sizeof(buffer)," Platinum: %i%s (Type !war3menu)",platinum,platinumChange);
					}
	#if (GGAMETYPE == GGAME_TF2)
					if(TF2_GetPlayerClass(i)!=TFClass_Engineer)
					{
						if(RotateNum[i]==0) {
							SetHudTextParams(0.02, 0.08, 1.02, 255, 255, 0, 255);
							ShowSyncHudText(i, HudGoldDiamondMessage, "%s",buffer);
						}
						if(RotateNum[i]==1) {
							SetHudTextParams(0.02, 0.08, 1.02, 255, 255, 0, 255);
							ShowSyncHudText(i, HudGoldDiamondMessage, "%s",buffer);
						}
						if(RotateNum[i]==2) {
							SetHudTextParams(0.02, 0.08, 1.02, 255, 255, 0, 255);
							ShowSyncHudText(i, HudGoldDiamondMessage, "%s",buffer);
						}
					}
					else
					{
						if(RotateNum[i]==0) {
							SetHudTextParams(0.16, 0.08, 1.02, 255, 255, 0, 255);
							ShowSyncHudText(i, HudGoldDiamondMessage, "%s",buffer);
						}
						if(RotateNum[i]==1) {
							SetHudTextParams(0.16, 0.08, 1.02, 255, 255, 0, 255);
							ShowSyncHudText(i, HudGoldDiamondMessage, "%s",buffer);
						}
						if(RotateNum[i]==2) {
							SetHudTextParams(0.16, 0.08, 1.02, 255, 255, 0, 255);
							ShowSyncHudText(i, HudGoldDiamondMessage, "%s",buffer);
						}
					}
	#endif
				}
				else if(GetPlayerProp(i,iRotateHUD)==0)
				{

					Format(buffer,sizeof(buffer)," G %i%s | D %i%s | P %i%s ",gold,goldChange,diamonds,diamondsChange,platinum,platinumChange);

	#if (GGAMETYPE == GGAME_TF2)
					if(TF2_GetPlayerClass(i)!=TFClass_Engineer)
					{
						SetHudTextParams(0.02, 0.08, 1.02, 255, 255, 0, 255);
						ShowSyncHudText(i, HudGoldDiamondMessage, "%s",buffer);
					}
					else
					{
						SetHudTextParams(0.16, 0.08, 1.02, 255, 255, 0, 255);
						ShowSyncHudText(i, HudGoldDiamondMessage, "%s",buffer);
					}
	#endif
					oldVals[i][0]=gold;
					oldVals[i][1]=diamonds;
					oldVals[i][2]=platinum;
				}
				else if(GetPlayerProp(i,iRotateHUD)==3)
				{

					Format(buffer,sizeof(buffer)," G %i%s | D %i%s | P %i%s ",gold,goldChange,diamonds,diamondsChange,platinum,platinumChange);
	#if (GGAMETYPE == GGAME_TF2)
					if(TF2_GetPlayerClass(i)!=TFClass_Engineer)
					{
						SetHudTextParams(0.02, 0.04, 1.02, 255, 255, 0, 255);
						ShowSyncHudText(i, HudGoldDiamondMessage, "%s",buffer);
					}
					else
					{
						SetHudTextParams(0.16, 0.04, 1.02, 255, 255, 0, 255);
						ShowSyncHudText(i, HudGoldDiamondMessage, "%s",buffer);
					}
	#endif
					oldVals[i][0]=gold;
					oldVals[i][1]=diamonds;
					oldVals[i][2]=platinum;
				}
			}
		}
	}
	CreateTimer(1.0,Timer_UpdateInfo);
}

public Action:Timer_Diamonds(Handle:timer, any:userid)
{
	if(!MapChanging && !War3SourcePause)
	{
		for(int i=1; i<GetMaxClients(); i++)
		{
			if(ValidPlayer(i,true,true) && !IsFakeClient(i))
			{
				int GivePlayerDiamonds = War3_GetDiamonds(i) + 1;
				War3_SetDiamonds(i, GivePlayerDiamonds);

				//W3GiveXPGold(i,XPAwardByGeneric,W3GetKillXP(i),0,"XP Per 5 Minutes");
			}
		}
	}
	CreateTimer(60.0,Timer_Diamonds);
}

#if (GGAMETYPE_JAILBREAK == JAILBREAK_ON)
public Action:Timer_Gold(Handle:timer, any:userid)
{
	if(!MapChanging && !War3SourcePause)
	{
		for(int i=1; i<GetMaxClients(); i++)
		{
			if(ValidPlayer(i,true,true) && !IsFakeClient(i))
			{
				int GivePlayerDiamonds = GetPlayerProp(i, PlayerGold) + 5;
				War3_SetGold(i, GivePlayerDiamonds);
			}
		}
	}
	CreateTimer(60.0,Timer_Gold);
}
#endif
