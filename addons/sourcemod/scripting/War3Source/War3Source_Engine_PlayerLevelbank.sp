// War3Source_Engine_PlayerLevelbank.sp

// TRANSLATED except for convars 4/5/2023

//#assert GGAMEMODE == MODE_WAR3SOURCE

new levelbank[MAXPLAYERSCUSTOM];
new Handle:hCvar_NewPlayerLevelbank;

new Handle:hCvarPrintLevelBank;
new Handle:hLevelup;
/*
public Plugin:myinfo=
{
	name="W3S Engine LevelBank",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};
*/

public War3Source_Engine_PlayerLevelbank_OnPluginStart()
{
	hCvar_NewPlayerLevelbank=CreateConVar("war3_new_player_levelbank","20","The amount of free levels a person gets that is new to the server (no xp record)");
	internal_W3SetVar(hNewPlayerLevelbankCvar,hCvar_NewPlayerLevelbank);

	hCvarPrintLevelBank=CreateConVar("war3_print_levelbank_spawn","0","Print how much you have in your level bank in chat every time you spawn?");
	hLevelup=CreateConVar("war3_levelbank_method","0","Selects the method the levelbank uses the levelup a player(available: 0=just increase current job level(default) 1=give required XP to levelup)");

	RegAdminCmd("war3_addlevelbank",War3Source_CMD_addlevelbank,ADMFLAG_RCON,"Add to user(steamid)'s level bank");
	LoadTranslations("w3s.levelbank.phrases");
}

public bool:War3Source_Engine_PlayerLevelbank_InitNatives()
{
	CreateNative("W3GetLevelBank",NW3GetLevelBank); //these have forwards to handle
	CreateNative("W3SetLevelBank",NW3SetLevelBank);

	return true;
}
public NW3GetLevelBank(Handle:plugin,numParams){

	return levelbank[GetNativeCell(1)];
}
public NW3SetLevelBank(Handle:plugin,numParams){

	levelbank[GetNativeCell(1)]=GetNativeCell(2);
}



public War3Source_Engine_PlayerLevelbank_OnWar3Event(W3EVENT:event,client)
{
	if(event==PlayerIsNewToServer){
		GiveNewPlayerLevelBank(client);
	}
	if(event==DoShowLevelBank){
		CmdShowLevelBankMenu(client);
	}
	if(event==ClearPlayerVariables){
		W3SetLevelBank(client,0);
	}
}


GiveNewPlayerLevelBank(client){
	W3SetLevelBank(client,W3GetLevelBank(client)+GetConVarInt(hCvar_NewPlayerLevelbank));
}







public CmdShowLevelBankMenu(client){
	if(W3Denyable(DN_ShowLevelbank,client)) {
		SetTrans(client);
		new Handle:hMenu=CreateMenu(OnSelectShowLevelBankMenu);
		SetMenuTitle(hMenu,"%T","You have {amount} levels in your levelbank",client,W3GetLevelBank(client));
		SetMenuExitButton(hMenu,true);

		new String:str[1000],String:racename[32];
		GetRaceName(GetRace(client),racename,sizeof(racename));
		Format(str,sizeof(str),"%T %s","Add a level to curret race from bank:",client,racename);
		AddMenuItem(hMenu,"0",str);
		DisplayMenu(hMenu,client,20);
	}
}

public OnSelectShowLevelBankMenu(Handle:menu,MenuAction:action,client,selection)
{
	if(action==MenuAction_Select)
	{
		if(selection==0){
			SetTrans(client);
			if(W3GetLevelBank(client)<=0){
				War3_ChatMessage(client,"%T","You do not have any levels in the level bank",client);
				return;
			}
			new race=GetRace(client);
			if(race<=0){
				War3_ChatMessage(client,"%T","You do not have a valid race",client);
				return;
			}
			if(GetRaceMaxLevel(race)<=War3_GetLevel(client,race)){
				War3_ChatMessage(client,"%T","Your race is already maxed",client);
				return;
			}
			// Revan: I've added this in order to make some scripts working
			// because War3_SetLevel doesn't triggers generic levelup events.
			new method = GetConVarInt(hLevelup);
			if(method == 0) {
				// Just increase race level.
				SetLevel(client,race,War3_GetLevel(client,race)+1);
			}
			else {
				// Add enough XP to let player levelup.
				new requiredxp = W3GetReqXP(War3_GetLevel(client,race)+1);
				SetXP(client,race,requiredxp);
				W3DoLevelCheck(client);
			}
			W3SetLevelBank(client,W3GetLevelBank(client)-1);
			//War3_SetLevel(client,race,War3_GetLevel(client,race)+1);
			new String:racename[32];
			GetRaceName(race,racename,sizeof(racename));
			War3_ChatMessage(client,"%T %s","Successfully added a level to race",client,racename);
			CmdShowLevelBankMenu(client);
		}
	}
	if(action==MenuAction_End)
	{
		CloseHandle(menu);
	}
	return;
}




public Action:War3Source_CMD_addlevelbank(client,args){
	if(args!=2)
	{
		ReplyToCommand(client,"parameters: \"steamid\" <amount>      IE: war3_addlevelbank \"STEAM_0:1:12345\" 10");
	}
	else{
		new String:steamid[32];
		GetCmdArg(1, steamid, sizeof(steamid));
		new String:temp[32];
		GetCmdArg(2, temp, sizeof(temp));
		int num=StringToInt(temp);


		bool playerwasingame;
		int ingameoldlevelbank;
		char othersteamid[32];
		for(int i=1;i<=MaxClients;i++)
		{
			if(ValidPlayer(i)&&W3IsPlayerXPLoaded(i))
			{
				GetClientAuthId(client,AuthId_Steam2,STRING(othersteamid),true);
				if(StrEqual(steamid,othersteamid,false)){
					ReplyToCommand(client,"%T","Found client {client} in game with steamid {steamid}, giving adding to level bank levels now",client,i,steamid);
					ingameoldlevelbank = W3GetLevelBank(i);
					W3SetLevelBank(i,num+W3GetLevelBank(i));

					playerwasingame=true;
					break;
				}
			}
		}

		// already defined
		//new Handle:hDB=internal_W3GetVar(hDatabase);
		if(hDB)
		{
			SQL_LockDatabase(hDB);   //DB must not ERROR! else u will not unlock databaase!!!



			char query_buffer[512];
			int oldlevelbank;
			if(!playerwasingame)
			{   ///not in game, we retrieve level bank
				Format(query_buffer,sizeof(query_buffer),"SELECT levelbankV2 FROM war3source WHERE steamid='%s'",steamid);
				new Handle:result=SQL_Query(hDB, query_buffer);

				if(result!=INVALID_HANDLE&&SQL_MoreRows(result))
				{
					ReplyToCommand(client,"%T","steamid appears to exist",client);

					SQL_FetchRow(result);
					oldlevelbank=SQL_FetchInt(result, 0);
				}
				else
				{
					ReplyToCommand(client,"%T","ERR: NO RESULT SET, player never joined the server once? Add Failed",client);
					SQL_UnlockDatabase(hDB);
					return;
				}
			}
			else
			{   //.he was in game, use old level bank value (but right now has the new levels)
				oldlevelbank= ingameoldlevelbank;
			}



			new newlevelbank=oldlevelbank+num;

			Format(query_buffer,sizeof(query_buffer),"UPDATE war3source SET levelbankV2='%d' WHERE steamid='%s'",newlevelbank,steamid);
			if(!SQL_FastQueryLogOnError(hDB,query_buffer))
			{
				ReplyToCommand(client,"insert failed");
			}
			else
			{
				ReplyToCommand(client,"%T","no sql error, success? {steamid}    new level bank: {newlevelbank}",client,steamid,newlevelbank);
			}
			SQL_UnlockDatabase(hDB);
		}
		else{
			ReplyToCommand(client,"%T","Failed: no database connection",client);
			return;
		}
	}
	return;
}

public OnWar3EventSpawn(client){
	if(GetConVarInt(hCvarPrintLevelBank)&&W3GetLevelBank(client)>0)
	{
		War3_ChatMessage(client,"%T","You have {amount} levels in your levelbank, say levelbank to use them",client,W3GetLevelBank(client));

	}
}
