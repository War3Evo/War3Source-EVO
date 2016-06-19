// War3Source_Engine_DatabaseTop100.sp

new bool:bRankCached[MAXPLAYERSCUSTOM];
new iRank[MAXPLAYERSCUSTOM];
new iTotalPlayersDB[MAXPLAYERSCUSTOM]; // this is also cached per client, eg one player might see 1/20 when another sees 2/21

new iTopCount; // there might not be 100 in the array.


new String:Top100Name[101][64];
new String:Top100Steamid[101][64];
new Top100totallevel[101];
new Top100totalxp[101];

new Handle:NoAdminWar3Top10Cvar;

/*
public Plugin:myinfo=
{
	name="W3S Engine Database top100",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};
*/

public War3Source_Engine_DatabaseTop100_OnPluginStart()
{
	NoAdminWar3Top10Cvar=CreateConVar("war3_admin_no_display_war3top10","0","1 = do not display admins in war3top10 (default 0)");
}
public War3Source_Engine_DatabaseTop100_OnMapStart()
{
	War3Source_UpdateStats();
}


public War3Source_Engine_DatabaseTop100_OnWar3Event(W3EVENT:event,client)
{
	if(event==DoShowWar3Rank){
		GetRank(client);
	}
	if(event==DoShowWar3Stats){
		War3Source_Stats(client);
	}
	if(event==DoShowWar3Top){
		new num=W3GetVar(EventArg1);
		War3Source_War3Top(client,num);
	}
}



War3Source_UpdateStats()
{
	if(hDB)
	{
		for(new x=0;x<=MaxClients;x++)
		{
			bRankCached[x]=false;
		}
		iTopCount=0;
		SQL_TQuery(hDB,T_RetrieveTopCallback,"SELECT steamid,name,total_level,total_xp FROM war3source ORDER BY total_level DESC,total_xp DESC LIMIT 0,100");
	}
}

public T_RetrieveTopCallback(Handle:owner,Handle:query,const String:error[],any:data)
{
	if(query!=INVALID_HANDLE)
	{
		//PrintToServer("T_RetrieveTopCallback");
		SQL_Rewind(query);
		while(SQL_FetchRow(query) && iTopCount < 100) //sqlite leak?
		{

			new String:steamid[64];
			new String:name[64];
			if(!W3SQLPlayerString(query,"steamid",steamid,sizeof(steamid)))
				continue;
			if(!W3SQLPlayerString(query,"name",name,sizeof(name)) || StrEqual(name,"",false) || StrEqual(name,"0",false))
			{
				strcopy(name,sizeof(name),steamid);
			}
			Format(Top100Name[iTopCount],sizeof(Top100Name),name);

			Format(Top100Steamid[iTopCount],sizeof(Top100Steamid),steamid);
			Top100totallevel[iTopCount]=W3SQLPlayerInt(query,"total_level");
			Top100totalxp[iTopCount]=W3SQLPlayerInt(query,"total_xp");

			++iTopCount;
		}
		CloseHandle(query);
	}
}
GetRank(client)
{

	if(bRankCached[client])
	{
		//War3_ChatMessage(client,"%T","Ranked {amount} of {amount}",client,iRank[client],iTotalPlayersDB[client]);
		War3_ChatMessage(client,"Ranked %d of %d",iRank[client],iTotalPlayersDB[client]);
	}
	else
	{
		//new Handle:hDB=W3GetVar(hDatabase);
		SQL_TQuery(hDB,T_RetrieveRankCache,"SELECT steamid FROM war3source ORDER BY total_level DESC,total_xp DESC",GetClientUserId(client));
	}
}

public T_RetrieveRankCache(Handle:owner,Handle:query,const String:error[],any:userid)
{
	new client=GetClientOfUserId(userid);
	if(client<=0)
		return; // fuck it, the player left
	char client_steamid[64];
	if(!GetClientAuthId(client,AuthId_Steam2,STRING(client_steamid),true))
		return; // invalid auth string, probably a fake steam account
	if(IsFakeClient(client))
		return; // why the fuck is a bot requesting their rank?
	if(query!=INVALID_HANDLE)
	{
		SQL_Rewind(query);
		int iCurRank=0;
		iTotalPlayersDB[client]=0;
		while(SQL_FetchRow(query))
		{
			++iCurRank;
			char steamid[64];
			if(!W3SQLPlayerString(query,"steamid",steamid,sizeof(steamid)))
				continue;
			if(StrEqual(steamid,client_steamid,false))
			{
				iRank[client]=iCurRank;
			}
			++iTotalPlayersDB[client];
		}
		CloseHandle(query);
		if(iRank[client]>0)
		{
			bRankCached[client]=true;
			//War3_ChatMessage(client,"%T","Ranked {amount} of {amount}",client,iRank[client],iTotalPlayersDB[client]);
			War3_ChatMessage(client,"Ranked %d of %d",iRank[client],iTotalPlayersDB[client]);
		}
	}
}






// Stats
War3Source_Stats(client)
{

	new Handle:statsMenu=CreateMenu(War3Source_Stats_Selected);
	SetMenuExitButton(statsMenu,true);
	//SetMenuTitle(statsMenu,"%T","[War3Source:EVO] Select a player to view stats",client);
	SetMenuTitle(statsMenu,"[War3Source:EVO] Select a player to view stats");
	decl String:playername[64];
	decl String:war3playerbuf[4];

	for(new x=1;x<=MaxClients;x++)
	{
		if(ValidPlayer(x,false))
		{
			Format(war3playerbuf,sizeof(war3playerbuf),"%d",x);
			GetClientName(x,playername,sizeof(playername));
			AddMenuItem(statsMenu,war3playerbuf,playername);
		}
	}
	DisplayMenu(statsMenu,client,20);
}

public War3Source_Stats_Selected(Handle:menu,MenuAction:action,client,selection)
{
	if(action==MenuAction_Select)
	{
		decl String:SelectionInfo[4];
		decl String:SelectionDispText[256];
		new SelectionStyle;
		GetMenuItem(menu,selection,SelectionInfo,sizeof(SelectionInfo),SelectionStyle, SelectionDispText,sizeof(SelectionDispText));
		new target=StringToInt(SelectionInfo);
		if(ValidPlayer(target))
			War3Source_Stats_Player(client,target);
		else
		{
			//War3_ChatMessage(client,"%T","The player you selected has left the server",client);
			War3_ChatMessage(client,"The player you selected has left the server");
			War3Source_Stats(client);
		}
	}
	if(action==MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public War3Source_Stats_Player(client,target)
{
	if(ValidPlayer(target,false))
	{
		new Handle:playerInfo=CreateMenu(War3Source_Stats_Player_Select);
		SetMenuExitButton(playerInfo,true);
		decl String:playername[64];
		GetClientName(target,playername,sizeof(playername));
		new RacesLoaded = War3_GetRacesLoaded();
		for(new x=1;x<=RacesLoaded;x++)
		{

			decl String:race_name[32];
			GetRaceName(x,race_name,sizeof(race_name));
			new String:data_str[16];
			Format(data_str,sizeof(data_str),"%d.%d",target,x);
			AddMenuItem(playerInfo,data_str,race_name);
		}

		decl String:race_name[32];
		GetRaceName(GetRace(target),race_name,sizeof(race_name));
		new goldtitle=GetPlayerProp(target, PlayerGold);
		//SetMenuTitle(playerInfo,"%T\n","[War3Source:EVO] Info for {player}. Current Job: {racename} gold: {amount}",client,playername,race_name,gold);
		SetMenuTitle(playerInfo,"[War3Source:EVO] Info for %s. Current Job: %s gold: %d",playername,race_name,goldtitle);
		DisplayMenu(playerInfo,client,20);
	}
	else
	{
		//War3_ChatMessage(client,"%T","The player has disconnected from the server",client);
		War3_ChatMessage(client,"The player has disconnected from the server");
		War3Source_Stats(client);
	}
}

public War3Source_Stats_Player_Select(Handle:menu,MenuAction:action,client,selection)
{
	if(action==MenuAction_Select)
	{
		decl String:SelectionInfo[16];
		decl String:SelectionDispText[256];
		new SelectionStyle;
		GetMenuItem(menu,selection,SelectionInfo,sizeof(SelectionInfo),SelectionStyle, SelectionDispText,sizeof(SelectionDispText));
		new String:buffer_out[2][8];
		ExplodeString(SelectionInfo,".",buffer_out,2,8);
		new index=StringToInt(buffer_out[0]);
		new race_num=StringToInt(buffer_out[1]);
		if(index>0 && race_num>=0)
		{
			War3Source_Stats_Player_Race(client,index,race_num);
		}
	}
	else if(action==MenuAction_Cancel)
	{
		if(selection==MenuCancel_Exit)
		{
			War3Source_Stats(client);
		}
	}
	if(action==MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public War3Source_Stats_Player_Race(client,target,race_num)
{
	if(ValidPlayer(target))
	{
		new Handle:playerInfo=CreateMenu(War3Source_Stats_PRS);
		SetMenuExitButton(playerInfo,true);
		decl String:playername[64];
		GetClientName(target,playername,sizeof(playername));

		new String:longbuf[1000];

		decl String:race_name[32];
		GetRaceName(race_num,race_name,sizeof(race_name));
		new level=War3_GetLevel(target,race_num);
		new xp=GetXP(target,race_num);

		//Format(longbuf,sizeof(longbuf),"%T\n","[War3Source:EVO] {racename} info for {player}. Level: {amount} XP: {amount}",client,race_name,playername,level,xp);
		Format(longbuf,sizeof(longbuf),"[War3Source:EVO] %s info for %s. Level: %d XP: %d\n",race_name,playername,level,xp);

		new SkillCount = GetRaceSkillCount(race_num);
		for(new i=1;i<=SkillCount;i++){
			new String:skillname[64];
			if(GetRaceSkillName(race_num,i,skillname,sizeof(skillname))>0)
			{
				new skilllevel=War3_GetSkillLevelINTERNAL(target,race_num,i);
				//Format(longbuf,sizeof(longbuf),"%s%T\n",longbuf,"{skillname} - Level {amount}",client,skillname,skilllevel);
				Format(longbuf,sizeof(longbuf),"%s %s - Level %d\n",longbuf,skillname,skilllevel);
			}
		}

		new String:menuback[32];
		//Format(menuback,sizeof(menuback),"%T","Back",client);
		Format(menuback,sizeof(menuback),"Back");

		SetMenuTitle(playerInfo,"%s\n \n",longbuf);
		decl String:target_str[8];
		Format(target_str,sizeof(target_str),"%d",target);
		AddMenuItem(playerInfo,target_str,menuback);
		DisplayMenu(playerInfo,client,20);
	}
	else
	{
		//War3_ChatMessage(client,"%T","The player has disconnected from the server",client);
		War3_ChatMessage(client,"The player has disconnected from the server");
		War3Source_Stats(client);
	}

}

public War3Source_Stats_PRS(Handle:menu,MenuAction:action,client,selection)
{
	if(action==MenuAction_Select)
	{
		decl String:SelectionInfo[4];
		decl String:SelectionDispText[256];
		new SelectionStyle;
		GetMenuItem(menu,selection,SelectionInfo,sizeof(SelectionInfo),SelectionStyle, SelectionDispText,sizeof(SelectionDispText));
		new target=StringToInt(SelectionInfo);
		if(ValidPlayer(target))
			War3Source_Stats_Player(client,target);
		else
		{
			//War3_ChatMessage(client,"%T","The player you selected has left the server",client);
			War3_ChatMessage(client,"The player you selected has left the server");
			War3Source_Stats(client);
		}
	}
	if(action==MenuAction_End)
	{
		CloseHandle(menu);
	}
}




War3Source_War3Top(client,top_num,cur_place=0)
{

	new Handle:topMenu=CreateMenu(War3Source_War3Top_Selected);
	SetMenuExitButton(topMenu,false);
	if(cur_place<0)	cur_place=0;
	new total_display=cur_place+10;
	if(total_display>iTopCount)
		total_display=iTopCount;
	if(total_display>top_num)
		total_display=top_num;
	if(top_num>iTopCount)
		top_num=iTopCount;
	new String:menuText[512];
	//Format(menuText,sizeof(menuText),"%T\n","[War3Source:EVO] Top {amount} ({amount}-{amount})",client,top_num,cur_place+1,total_display);
	Format(menuText,sizeof(menuText),"[War3Source:EVO] Top %d (%d-%d)\n",top_num,cur_place+1,total_display);
	new x2=0;
	//for(new x=cur_place;x<total_display;x++)
	for(new x=cur_place;x<99;x++)
	{
		if(StrContains(Top100Name[x],"[A]",true)!=-1 && StrContains(Top100Name[x],"-W3E-",false)!=-1 && GetConVarInt(NoAdminWar3Top10Cvar)==1)
		{
			continue;
		}
		if(x2<total_display)
		{
			Format(menuText,sizeof(menuText),"%s%d - %s (Lvl. %d, %d XP)\n",menuText,x2+1,Top100Name[x],Top100totallevel[x],Top100totalxp[x]);
			x2++;
		}
	}
	SetMenuTitle(topMenu,menuText);
	new String:data_str[18];
	new String:menuexit[32];
	new String:menunext[32];
	new String:menuprevious[32];
	//Format(menuexit,sizeof(menuexit),"%T","Exit",client);
	Format(menuexit,sizeof(menuexit),"Exit");
	//Format(menunext,sizeof(menunext),"%T","Next",client);
	Format(menunext,sizeof(menunext),"Next");
	//Format(menuprevious,sizeof(menuprevious),"%T","Previous",client);
	Format(menuprevious,sizeof(menuprevious),"Previous");

	AddMenuItem(topMenu,"",menuexit);
	Format(data_str,sizeof(data_str),"n.%d.%d",top_num,cur_place);
	if(total_display<top_num) AddMenuItem(topMenu,data_str,menunext);
	Format(data_str,sizeof(data_str),"p.%d.%d",top_num,cur_place);
	if(cur_place>0) AddMenuItem(topMenu,data_str,menuprevious);

	DisplayMenu(topMenu,client,20);
}

public War3Source_War3Top_Selected(Handle:menu,MenuAction:action,client,selection)
{
	if(action==MenuAction_Select)
	{
		decl String:SelectionInfo[18];
		decl String:SelectionDispText[256];
		new SelectionStyle;
		GetMenuItem(menu,selection,SelectionInfo,sizeof(SelectionInfo),SelectionStyle, SelectionDispText,sizeof(SelectionDispText));
		new String:buffer_out[3][8];
		ExplodeString(SelectionInfo,".",buffer_out,3,8);
		new top_num=StringToInt(buffer_out[1]);
		new cur_place=StringToInt(buffer_out[2]);
		if(buffer_out[0][0]=='n')
		{
			// next
			War3Source_War3Top(client,top_num,cur_place+10);
		}
		else if(buffer_out[0][0]=='p')
		{
			War3Source_War3Top(client,top_num,cur_place-10);
		}
	}
	if(action==MenuAction_End)
	{
		CloseHandle(menu);
	}
}

