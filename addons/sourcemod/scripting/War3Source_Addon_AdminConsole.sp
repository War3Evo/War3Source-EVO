// War3Source_Addon_AdminConsole.sp

#include <war3source>

#assert GGAMEMODE == MODE_WAR3SOURCE

public Plugin:myinfo=
{
	name="War3Source Admin Console",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};

public OnPluginStart()
{
	LoadTranslations("w3s._common.phrases");

	RegConsoleCmd("war3_setxp",War3Source_CMDSetXP,"Set a player's XP");
	RegConsoleCmd("war3_givexp",War3Source_CMD_GiveXP,"Give a player XP");
	RegConsoleCmd("war3_removexp",War3Source_CMD_RemoveXP,"Remove some XP from a player");
	RegConsoleCmd("war3_setlevel",War3Source_CMD_War3_SetLevel,"Set a player's level");
	RegConsoleCmd("war3_givelevel",War3Source_CMD_GiveLevel,"Give a player a single level");
	RegConsoleCmd("war3_removelevel",War3Source_CMD_RemoveLevel,"Remove a single level from a player");
	RegConsoleCmd("war3_setgold",War3Source_CMD_War3_SetGold,"Set a player's gold count");
	RegConsoleCmd("war3_givegold",War3Source_CMD_GiveGold,"Give a player gold");
	RegConsoleCmd("war3_removegold",War3Source_CMD_RemoveGold,"Remove some gold from a player");
	RegConsoleCmd("war3_setdiamonds",War3Source_CMD_SetDiamonds,"Set a player's diamonds");
	RegConsoleCmd("war3_setplatinum",War3Source_CMD_SetPlatinum,"set a player's platinum");

#if SHOPMENU3 == MODE_ENABLED
	RegConsoleCmd("war3_setsh3level1",War3Source_CMD_SetSH3level1,"set a player's gem sh3 1st half level");
	RegConsoleCmd("war3_setsh3level2",War3Source_CMD_SetSH3level2,"set a player's gem sh3 2nd half level");
#endif

}

#if SHOPMENU3 == MODE_ENABLED
public Action War3Source_CMD_SetSH3level1(int client,int args)
{
	if(client!=0&&!HasSMAccess(client,ADMFLAG_RCON)){
		ReplyToCommand(client,"No Access");
	}
	else if(args!=3)
		PrintToConsole(client,"[War3Source:EVO] The syntax of the command is: war3_setsh3level1 <player> <item shortname> <level>");
	else
	{
		char match[64];
		GetCmdArg(1,match,sizeof(match));
		char itemshort[64];
		GetCmdArg(2,itemshort,sizeof(itemshort));
		char buf[32];
		GetCmdArg(3,buf,sizeof(buf));
		//int maxgold=W3GetMaxGold();
		char adminname[64];
		if(client!=0)
			GetClientName(client,adminname,sizeof(adminname));
		else
			adminname="Console";
		int itemlevel=StringToInt(buf);
		if(itemlevel<0)
			itemlevel=0;

		int playerlist[66];
		int results=War3Source_PlayerParse(match,playerlist);
		for(int x=0;x<results;x++)
		{
			char name[64];
			GetClientName(playerlist[x],name,sizeof(name));
			War3_SetItemLevel(playerlist[x], War3_GetRace(playerlist[x]), War3_GetItem3IdByShortname(itemshort), itemlevel);
			PrintToConsole(client,"[War3Source:EVO] You just set player %s gem item level to %d",name,itemlevel);
			War3_ChatMessage(playerlist[x],"Admin %s set your gem item level to %d",adminname,itemlevel);

		}
		if(results==0)
			PrintToConsole(client,"%T","[War3Source:EVO] No players matched your query",client);

	}
	return Plugin_Handled;
}

public Action War3Source_CMD_SetSH3level2(int client,int args)
{
	if(client!=0&&!HasSMAccess(client,ADMFLAG_RCON)){
		ReplyToCommand(client,"No Access");
	}
	else if(args!=3)
		PrintToConsole(client,"[War3Source:EVO] The syntax of the command is: war3_setsh3level2 <player> <item shortname> <level>");
	else
	{
		char match[64];
		GetCmdArg(1,match,sizeof(match));
		char itemshort[64];
		GetCmdArg(2,itemshort,sizeof(itemshort));
		char buf[32];
		GetCmdArg(3,buf,sizeof(buf));
		//int maxgold=W3GetMaxGold();
		char adminname[64];
		if(client!=0)
			GetClientName(client,adminname,sizeof(adminname));
		else
			adminname="Console";
		int itemlevel=StringToInt(buf);
		if(itemlevel<0)
			itemlevel=0;

		int playerlist[66];
		int results=War3Source_PlayerParse(match,playerlist);
		for(int x=0;x<results;x++)
		{
			char name[64];
			GetClientName(playerlist[x],name,sizeof(name));
			War3_SetItemLevel2(playerlist[x], War3_GetRace(playerlist[x]), War3_GetItem3IdByShortname(itemshort), itemlevel);
			PrintToConsole(client,"[War3Source:EVO] You just set player %s gem item level to %d",name,itemlevel);
			War3_ChatMessage(playerlist[x],"Admin %s set your gem item level to %d",adminname,itemlevel);
		}
		if(results==0)
			PrintToConsole(client,"%T","[War3Source:EVO] No players matched your query",client);

	}
	return Plugin_Handled;
}
#endif


public War3Source_PlayerParse(String:matchstr[],playerlist[])
{
	int i=0;
	if(StrEqual(matchstr,"@all",false))
	{
		// All?

		for(int x=1;x<=MaxClients;x++)
		{
			if(ValidPlayer(x))
			{
				playerlist[i++]=x;
			}
		}
	}
	else
	{
		// Team?
		if(StrEqual(matchstr,"@ct",false))
		{
			for(int x=1;x<=MaxClients;x++)
			{
				if(ValidPlayer(x))
				{
					if(GetClientTeam(x)==3){
						playerlist[i++]=x;
					}
				}
			}
		}
		else if(StrEqual(matchstr,"@t",false))
		{
			for(int x=1;x<=MaxClients;x++)
			{
				if(ValidPlayer(x))
				{
					if(GetClientTeam(x)==2){
						playerlist[i++]=x;
					}
				}
			}
		}
		else
		{
			// Userid?
			if(matchstr[0]=='@')
			{
				int uid=StringToInt(matchstr[1]); //startign from index 1
				for(int x=1;x<=MaxClients;x++)
				{
					if(ValidPlayer(x))
					{
						if(GetClientUserId(x)==uid){
							playerlist[i++]=x;
							break;
						}
					}
				}
			}
			else
			{
				// Player name?
				for(int x=1;x<=MaxClients;x++)
				{
					if(ValidPlayer(x))
					{
						char name[64];
						GetClientName(x,name,sizeof(name));
						if(StrContains(name,matchstr,false)!=-1)
						{
							playerlist[i++]=x;
							break;
						}
					}
				}
			}
		}
	}
	return i;
}

public Action War3Source_CMDSetXP(int client,int args)
{
	if(client!=0&&!HasSMAccess(client,ADMFLAG_RCON)){
		ReplyToCommand(client,"No Access");
	}
	else if(args!=2)
		PrintToConsole(client,"%T","[War3Source:EVO] The syntax of the command is: war3_setxp <player> <xp>",client);
	else
	{
		char match[64];
		GetCmdArg(1,match,sizeof(match));
		char buf[32];
		GetCmdArg(2,buf,sizeof(buf));
		char adminname[64];
		if(client!=0)
			GetClientName(client,adminname,sizeof(adminname));
		else
			adminname="Console";
		int xp=StringToInt(buf);
		if(xp<0)
			xp=0;
		int playerlist[66];
		int results=War3Source_PlayerParse(match,playerlist);
		for(int x=0;x<results;x++)
		{
			char name[64];
			GetClientName(playerlist[x],name,sizeof(name));

			int race=War3_GetRace(playerlist[x]);
			if(race>0)
			{
				War3_SetXP(playerlist[x],race,xp);
				PrintToConsole(client,"%T","[War3Source:EVO] You just set {player} XP to {amount}",client,name,xp);
				War3_ChatMessage(playerlist[x],"%T","Admin {player} set your XP to {amount}",playerlist[x],adminname,xp);
				W3DoLevelCheck(playerlist[x]);
			}
		}
		if(results==0)
			PrintToConsole(client,"%T","[War3Source:EVO] No players matched your query",client);
	}
	return Plugin_Handled;
}

public Action War3Source_CMD_GiveXP(int client,int args)
{
	if(client!=0&&!HasSMAccess(client,ADMFLAG_RCON)){
		ReplyToCommand(client,"No Access");
	}
	else if(args!=2)
		PrintToConsole(client,"%T","[War3Source:EVO] The syntax of the command is: war3_givexp <player> <xp>",client);
	else
	{

		char match[64];
		GetCmdArg(1,match,sizeof(match));
		char buf[32];
		GetCmdArg(2,buf,sizeof(buf));
		char adminname[64];
		if(client!=0)
			GetClientName(client,adminname,sizeof(adminname));
		else
			adminname="Console";
		int xp=StringToInt(buf);
		if(xp<0)
			xp=0;


		int playerlist[66];
		int results=War3Source_PlayerParse(match,playerlist);
		for(int x=0;x<results;x++)
		{

			char name[64];
			GetClientName(playerlist[x],name,sizeof(name));
			int race=War3_GetRace(playerlist[x]);
			if(race>0)
			{

				int oldxp=War3_GetXP(playerlist[x],race);
				War3_SetXP(playerlist[x],race,oldxp+xp);
				PrintToConsole(client,"%T","[War3Source:EVO] You just gave {amount} XP to {player}",client,xp,name);
				War3_ChatMessage(playerlist[x],"%T","Admin {player} gave you {amount} XP",playerlist[x],adminname,xp);
				W3DoLevelCheck(playerlist[x]);

			}

		}
		if(results==0)
			PrintToConsole(client,"%T","[War3Source:EVO] No players matched your query",client);
	}
	return Plugin_Handled;
}

public Action War3Source_CMD_RemoveXP(int client,int args)
{
	if(client!=0&&!HasSMAccess(client,ADMFLAG_RCON)){
		ReplyToCommand(client,"No Access");
	}
	else if(args!=2)
		PrintToConsole(client,"%T","[War3Source:EVO] The syntax of the command is: war3_removexp <player> <xp>",client);
	else
	{
		char match[64];
		GetCmdArg(1,match,sizeof(match));
		char buf[32];
		GetCmdArg(2,buf,sizeof(buf));
		char adminname[64];
		if(client!=0)
			GetClientName(client,adminname,sizeof(adminname));
		else
			adminname="Console";
		int xp=StringToInt(buf);
		if(xp<0)
			xp=0;
		int playerlist[66];
		int results=War3Source_PlayerParse(match,playerlist);
		for(int x=0;x<results;x++)
		{
			char name[64];
			GetClientName(playerlist[x],name,sizeof(name));

			int race=War3_GetRace(playerlist[x]);
			if(race>0)
			{
				int newxp=War3_GetXP(playerlist[x],race)-xp;
				if(newxp<0)
					newxp=0;
				War3_SetXP(playerlist[x],race,newxp);
				PrintToConsole(client,"%T","[War3Source:EVO] You just removed {amount} XP from {player}",client,xp,name);
				War3_ChatMessage(playerlist[x],"%T","Admin {player} removed {amount} XP from you",playerlist[x],adminname,xp);
				W3DoLevelCheck(playerlist[x]);
			}
		}
		if(results==0)
			PrintToConsole(client,"%T","[War3Source:EVO] No players matched your query",client);
	}
	return Plugin_Handled;
}

public Action War3Source_CMD_War3_SetLevel(int client,int args)
{
	if(client!=0&&!HasSMAccess(client,ADMFLAG_RCON)){
		ReplyToCommand(client,"No Access");
	}
	else if(args!=2)
		PrintToConsole(client,"%T","[War3Source:EVO] The syntax of the command is: war3_setlevel <player> <level>",client);
	else
	{
		char match[64];
		GetCmdArg(1,match,sizeof(match));
		char buf[32];
		GetCmdArg(2,buf,sizeof(buf));
		char adminname[64];
		if(client!=0)
			GetClientName(client,adminname,sizeof(adminname));
		else
			adminname="Console";
		int level=StringToInt(buf);
		if(level<0)
			level=0;

		int playerlist[66];
		int results=War3Source_PlayerParse(match,playerlist);
		for(int x=0;x<results;x++)
		{
			char name[64];
			GetClientName(playerlist[x],name,sizeof(name));

			int race=War3_GetRace(playerlist[x]);
			if(race>0)
			{
				int oldlevel=War3_GetLevel(playerlist[x],race);
				if(oldlevel>level)
					War3_SetXP(playerlist[x],race,0);


				W3ClearSkillLevels(playerlist[x],race);

				if(level>W3GetRaceMaxLevel(race)){
					level=W3GetRaceMaxLevel(race);
				}
				War3_SetLevel(playerlist[x],race,level);
				PrintToConsole(client,"%T","[War3Source:EVO] You just set player {player} level to {amount}",client,name,level);
				War3_ChatMessage(playerlist[x],"%T","Admin {player} set your level to {amount}, re-pick your skills",playerlist[x],adminname,level);



				W3DoLevelCheck(playerlist[x]);

			}
		}
		if(results==0)
			PrintToConsole(client,"%T","[War3Source:EVO] No players matched your query",client);

	}
	return Plugin_Handled;
}

public Action War3Source_CMD_GiveLevel(int client,int args)
{
	if(client!=0&&!HasSMAccess(client,ADMFLAG_RCON)){
		ReplyToCommand(client,"No Access");
	}
	else if(args!=1)
		PrintToConsole(client,"%T","[War3Source:EVO] The syntax of the command is: war3_givelevel <player>",client);
	else
	{
		char match[64];
		GetCmdArg(1,match,sizeof(match));
		char adminname[64];
		if(client!=0)
			GetClientName(client,adminname,sizeof(adminname));
		else
			adminname="Console";

		int playerlist[66];
		int results=War3Source_PlayerParse(match,playerlist);
		for(int x=0;x<results;x++)
		{
			char name[64];
			GetClientName(playerlist[x],name,sizeof(name));


			int race=War3_GetRace(playerlist[x]);
			if(race>0)
			{
				int newlevel=War3_GetLevel(playerlist[x],race)+1;
				if(newlevel>W3GetRaceMaxLevel(race))
					PrintToConsole(client,"%T","[War3Source:EVO] Player {player} is already at their max level",client,name);
				else
				{
					War3_SetLevel(playerlist[x],race,newlevel);
					PrintToConsole(client,"%T","[War3Source:EVO] You just gave player {player} a level",client,name);
					War3_ChatMessage(playerlist[x],"%T","Admin {player} gave you a level",playerlist[x],adminname);
					W3DoLevelCheck(playerlist[x]);
				}
			}

		}
		if(results==0)
			PrintToConsole(client,"%T","[War3Source:EVO] No players matched your query",client);

	}
	return Plugin_Handled;

}

public Action War3Source_CMD_RemoveLevel(int client,int args)
{
	if(client!=0&&!HasSMAccess(client,ADMFLAG_RCON)){
		ReplyToCommand(client,"No Access");
	}
	else if(args!=1)
		PrintToConsole(client,"%T","[War3Source:EVO] The syntax of the command is: war3_removelevel <player>",client);
	else
	{
		char match[64];
		GetCmdArg(1,match,sizeof(match));
		char adminname[64];
		if(client!=0)
			GetClientName(client,adminname,sizeof(adminname));
		else
			adminname="Console";


		int playerlist[66];
		int results=War3Source_PlayerParse(match,playerlist);
		for(int x=0;x<results;x++)
		{
			char name[64];
			GetClientName(playerlist[x],name,sizeof(name));

			int race=War3_GetRace(playerlist[x]);
			if(race>0)
			{
				int newlevel=War3_GetLevel(playerlist[x],race)-1;
				if(newlevel<0)
					PrintToConsole(client,"%T","[War3Source:EVO] Player {player} is already at level 0",client,name);
				else
				{
					W3ClearSkillLevels(playerlist[x],race);

					War3_SetLevel(playerlist[x],race,newlevel);
					PrintToConsole(client,"%T","[War3Source:EVO] You just removed a level from player {player}",client,name);
					War3_ChatMessage(playerlist[x],"%T","Admin {player} removed a level from you, re-pick your skills",playerlist[x],adminname);
					W3DoLevelCheck(playerlist[x]);
				}
			}

		}
		if(results==0)
			PrintToConsole(client,"%T","[War3Source:EVO] No players matched your query",client);

	}
	return Plugin_Handled;
}

public Action War3Source_CMD_War3_SetGold(int client,int args)
{
	if(client!=0&&!HasSMAccess(client,ADMFLAG_RCON)){
		ReplyToCommand(client,"No Access");
	}
	else if(args!=2)
		PrintToConsole(client,"%T","[War3Source:EVO] The syntax of the command is: war3_setgold <player> <gold>",client);
	else
	{
		char match[64];
		GetCmdArg(1,match,sizeof(match));
		char buf[32];
		GetCmdArg(2,buf,sizeof(buf));
		int maxgold=W3GetMaxGold(-1);
		char adminname[64];
		if(client!=0)
			GetClientName(client,adminname,sizeof(adminname));
		else
			adminname="Console";
		int gold=StringToInt(buf);
		if(gold<0)
			gold=0;
		if(gold>maxgold)
			gold=maxgold;

		int playerlist[66];
		int results=War3Source_PlayerParse(match,playerlist);
		for(int x=0;x<results;x++)
		{
			char name[64];
			GetClientName(playerlist[x],name,sizeof(name));


			War3_SetGold(playerlist[x],gold);
			PrintToConsole(client,"%T","[War3Source:EVO] You just set player {player} gold to {amount}",client,name,gold);
			War3_ChatMessage(playerlist[x],"%T","Admin {player} set your gold to {amount}",playerlist[x],adminname,gold);

		}
		if(results==0)
			PrintToConsole(client,"%T","[War3Source:EVO] No players matched your query",client);

	}
	return Plugin_Handled;
}

//War3Source_CMD_SetDiamonds
public Action War3Source_CMD_SetDiamonds(int client,int args)
{
	if(client!=0&&!HasSMAccess(client,ADMFLAG_RCON)){
		ReplyToCommand(client,"No Access");
	}
	else if(args!=2)
		PrintToConsole(client,"[War3Source:EVO] The syntax of the command is: war3_setdiamonds <player> <gold>");
	else
	{
		char match[64];
		GetCmdArg(1,match,sizeof(match));
		char buf[32];
		GetCmdArg(2,buf,sizeof(buf));
		//int maxgold=W3GetMaxGold();
		char adminname[64];
		if(client!=0)
			GetClientName(client,adminname,sizeof(adminname));
		else
			adminname="Console";
		int gold=StringToInt(buf);
		if(gold<0)
			gold=0;
		//if(gold>maxgold)
		//	gold=maxgold;

		int playerlist[66];
		int results=War3Source_PlayerParse(match,playerlist);
		for(int x=0;x<results;x++)
		{
			char name[64];
			GetClientName(playerlist[x],name,sizeof(name));


			War3_SetDiamonds(playerlist[x],gold);
			PrintToConsole(client,"%T","[War3Source:EVO] You just set player {player} diamonds to {amount}",client,name,gold);
			War3_ChatMessage(playerlist[x],"%T","Admin {player} set your diamonds to {amount}",playerlist[x],adminname,gold);

		}
		if(results==0)
			PrintToConsole(client,"%T","[War3Source:EVO] No players matched your query",client);

	}
	return Plugin_Handled;
}

public Action War3Source_CMD_SetPlatinum(int client,int args)
{
	if(client!=0&&!HasSMAccess(client,ADMFLAG_RCON)){
		ReplyToCommand(client,"No Access");
	}
	else if(args!=2)
		PrintToConsole(client,"[War3Source:EVO] The syntax of the command is: war3_setplatinum <player> <gold>");
	else
	{
		char match[64];
		GetCmdArg(1,match,sizeof(match));
		char buf[32];
		GetCmdArg(2,buf,sizeof(buf));
		//int maxgold=W3GetMaxGold();
		char adminname[64];
		if(client!=0)
			GetClientName(client,adminname,sizeof(adminname));
		else
			adminname="Console";
		int platinum=StringToInt(buf);
		if(platinum<0)
			platinum=0;
		//if(gold>maxgold)
		//	gold=maxgold;

		int playerlist[66];
		int results=War3Source_PlayerParse(match,playerlist);
		for(int x=0;x<results;x++)
		{
			char name[64];
			GetClientName(playerlist[x],name,sizeof(name));


			War3_SetPlatinum(playerlist[x],platinum);
			PrintToConsole(client,"[War3Source:EVO] You just set player %s platinum to %d",name,platinum);
			War3_ChatMessage(playerlist[x],"Admin %s set your platinum to %d",adminname,platinum);

		}
		if(results==0)
			PrintToConsole(client,"%T","[War3Source:EVO] No players matched your query",client);

	}
	return Plugin_Handled;
}

public Action War3Source_CMD_GiveGold(int client,int args)
{
	if(client!=0&&!HasSMAccess(client,ADMFLAG_RCON)){
		ReplyToCommand(client,"No Access");
	}
	else if(args!=2)
		PrintToConsole(client,"%T","[War3Source:EVO] The syntax of the command is: war3_givegold <player> <gold>",client);
	else
	{
		char match[64];
		GetCmdArg(1,match,sizeof(match));
		char buf[32];
		GetCmdArg(2,buf,sizeof(buf));
		char adminname[64];
		if(client!=0)
			GetClientName(client,adminname,sizeof(adminname));
		else
			adminname="Console";
		int gold=StringToInt(buf);
		if(gold<0)
			gold=0;

		int maxgold=W3GetMaxGold(-1);

		int playerlist[66];
		int results=War3Source_PlayerParse(match,playerlist);
		for(int x=0;x<results;x++)
		{
			//maxgold=W3GetMaxGold(x);
			char name[64];
			GetClientName(playerlist[x],name,sizeof(name));


			int newgold=War3_GetGold(playerlist[x])+gold;
			if(newgold<0)
				newgold=0;
			if(newgold>maxgold)
				newgold=maxgold;
			War3_SetGold(playerlist[x],newgold);
			PrintToConsole(client,"%T","[War3Source:EVO] You just gave player {player} {amount} gold",client,name,gold);
			War3_ChatMessage(playerlist[x],"%T","Admin {player} give you {amount} gold",playerlist[x],adminname,gold);

		}
		if(results==0)
			PrintToConsole(client,"%T","[War3Source:EVO] No players matched your query",client);

	}
	return Plugin_Handled;
}

public Action:War3Source_CMD_RemoveGold(client,args)
{
	if(client!=0&&!HasSMAccess(client,ADMFLAG_RCON)){
		ReplyToCommand(client,"No Access");
	}
	else if(args!=2)
		PrintToConsole(client,"%T","[War3Source:EVO] The syntax of the command is: war3_givegold <player> <gold>",client);
	else
	{
		char match[64];
		GetCmdArg(1,match,sizeof(match));
		char buf[32];
		GetCmdArg(2,buf,sizeof(buf));
		char adminname[64];
		if(client!=0)
			GetClientName(client,adminname,sizeof(adminname));
		else
			adminname="Console";
		int gold=StringToInt(buf);
		if(gold<0)
			gold=0;

		int maxgold=W3GetMaxGold(-1);

		int playerlist[66];
		int results=War3Source_PlayerParse(match,playerlist);
		for(int x=0;x<results;x++)
		{
			//maxgold=W3GetMaxGold(x);
			char name[64];
			GetClientName(playerlist[x],name,sizeof(name));

			int newcreds=War3_GetGold(playerlist[x])-gold;
			if(newcreds<0)
				newcreds=0;
			if(newcreds>maxgold)
				newcreds=maxgold;
			War3_SetGold(playerlist[x],newcreds);
			PrintToConsole(client,"%T","[War3Source:EVO] You just removed {amount} gold from player {player}",client,gold,name);
			War3_ChatMessage(playerlist[x],"%T","Admin {player} removed {amount} gold from you",playerlist[x],adminname,gold);

		}
		if(results==0)
			PrintToConsole(client,"%T","[War3Source:EVO] No players matched your query",client);
	}
	return Plugin_Handled;
}
