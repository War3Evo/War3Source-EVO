// War3Source_Engine_MenuRacePlayerinfo.sp

//#assert GGAMEMODE == MODE_WAR3SOURCE

/*
public Plugin:myinfo=
{
	name="War3Source Menus playerinfo raceinfo",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};*/

int raceinfoshowskillnumber[MAXPLAYERSCUSTOM];

Handle ShowOtherPlayerItemsCvar;
Handle ShowTargetSelfPlayerItemsCvar;

public War3Source_Engine_MenuRacePlayerinfo_OnPluginStart()
{
	CreateConVar("MenuRacePlayerInfo",PLUGIN_VERSION,"[War3Source:EVO] Menu Core",FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	// No Spendskill level restrictions on non-ultimates (Requires mapchange)
	ShowOtherPlayerItemsCvar=CreateConVar("war3_show_playerinfo_other_player_items","1","0 disables showing other players items using playerinfo. [default 1]");
	//war3_show_playerinfo_targetself_items 0
	ShowTargetSelfPlayerItemsCvar=CreateConVar("war3_show_playerinfo_targetself_items","1","0 disables showing targeting yourself items using playerinfo. [default 1]");

}			//War3_playertargetItemMenu

public War3Source_Engine_MenuRacePlayerinfo_OnWar3Event(W3EVENT:event,client){
	if(event==DoShowRaceinfoMenu){
		ShowMenu3Raceinfo(client);
	}
	if(event==DoShowPlayerinfoMenu){
		War3_PlayerInfoMenu(client,"");
	}
	if(event==DoShowPlayerinfoEntryWithArg){
		PlayerInfoMenuEntry(client);
	}
	if(event==DoShowParticularRaceInfo){
		int raceid = internal_W3GetVar(RaceinfoRaceToShow);
		if(eValidRace(raceid)) {
			War3_ShowParticularRaceInfoMenu(client,raceid);
		}
	}
	if(event==DoShowPlayerInfoTarget){
		int target = internal_W3GetVar(EventArg1);
		if(ValidPlayer(target,false)) {
			War3_playertargetMenu(client,target) ;
		}
	}
	if(event==DoShowPlayerItemsOwnTarget){
		int target = internal_W3GetVar(EventArg1);
		if(ValidPlayer(target,false)) {
			War3_playertargetItemMenu(client,target) ;
		}
	}
}
ShowMenu3Raceinfo(client)
{
	SetTrans(client);
	Handle hMenu=CreateMenu(War3_raceinfoSelected);
	SetMenuExitButton(hMenu,true);
	SetMenuTitle(hMenu,"%T\n ","[War3Source:EVO] Select a job for more info",client);
	// Iteriate through the races and print them out

	char rbuf[4];
	char rracename[32];
	char rdisp[128];

	int racelist[MAXRACES];
	int racedisplay=W3GetRaceList(racelist);
	//if(GetConVarInt(internal_W3GetVar(hSortByMinLevelCvar))<1){
	//	for(int x=0;x<War3_GetRacesLoaded();x++){//notice this starts at zero!
	//		racelist[x]=x+1;
	//	}
	//}




	for(int i=0;i<racedisplay;i++) //notice this starts at zero!
	{
		int	raceid=racelist[i];

		Format(rbuf,sizeof(rbuf),"%d",raceid); //DATA FOR MENU!
		GetRaceName(raceid,rracename,sizeof(rracename));



		int yourteam,otherteam;
		for(int y=1;y<=MaxClients;y++)
		{

			if(ValidPlayer(y,false))
			{
				if(GetRace(y)==raceid)
				{
					if(GetClientTeam(client)==GetClientTeam(y))
					{
						++yourteam;
					}
					else
					{
						++otherteam;
					}
				}
			}
		}
		char extra[3];
		if(GetRace(client)==raceid)
		{
			Format(extra,sizeof(extra),">");

		}
		else if(W3GetPendingRace(client)==raceid){
			Format(extra,sizeof(extra),"<");

		}

		Format(rdisp,sizeof(rdisp),"%s%s %d,%d %d/%d",extra,rracename,yourteam,otherteam,War3_GetLevel(client,raceid),GetRaceMaxLevel(raceid));
		AddMenuItem(hMenu,rbuf,rdisp);
	}
	DisplayMenu(hMenu,client,MENU_TIME_FOREVER);
}


public War3_raceinfoSelected(Handle:menu,MenuAction:action,client,selection)
{
	if(action==MenuAction_Select)
	{
		if(ValidPlayer(client))
		{

			char SelectionInfo[4];
			char SelectionDispText[256];

			int SelectionStyle;
			GetMenuItem(menu,selection,SelectionInfo,sizeof(SelectionInfo),SelectionStyle, SelectionDispText,sizeof(SelectionDispText));
			int race_selected=StringToInt(SelectionInfo);

			raceinfoshowskillnumber[client]=-1;
			War3_ShowParticularRaceInfoMenu(client,race_selected);
		}
	}
	if(action==MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public War3_ShowParticularRaceInfoMenu(client,raceid)
{
	SetTrans(client);
	Handle hMenu=CreateMenu(War3_particularraceinfoSelected);
	SetMenuExitButton(hMenu,true);
	SetMenuExitBackButton(hMenu,true);

	char racename[32];
	char skilldesc[1000];
	char skillname[64];
	//char longbuf[7000];
	GetRaceName(GetRace(client),racename,sizeof(racename));



	char selectioninfo[32];


	SetMenuTitle(hMenu,"%T\n \n","[War3Source:EVO] Information for job: {racename} (LVL {amount}/{amount})",client,racename,War3_GetLevel(client,raceid),GetRaceMaxLevel(raceid));



	int level;
	int SkillCount = GetRaceSkillCount(raceid);
	for(int x=1;x<=SkillCount;x++)
	{
		char str[1000];
		if(GetRaceSkillName(raceid,x,skillname,sizeof(skillname))>0)
		{
			level=GetSkillLevelINTERNAL(client,raceid,x) ;

			int skillSlot = GetSkillSlot(client,x);

			if(IsSkillUltimate(raceid,x))
			{
				if(skillSlot>0)
				{
					GetSkillName(skillSlot,skillname,sizeof(skillname));
				}
				Format(str,sizeof(str),"%T","Ultimate: {skillname} (LVL {amount}/{amount})",client,skillname,level,GetRaceSkillMaxLevel(raceid,x));
			}
			else
			{
				if(skillSlot>0)
				{
					GetSkillName(skillSlot,skillname,sizeof(skillname));
				}
				Format(str,sizeof(str),"%T","{skillname} (LVL {amount}/{amount})",client,skillname,level,GetRaceSkillMaxLevel(raceid,x));
			}

			Format(selectioninfo,sizeof(selectioninfo),"%d,skill,%d",raceid,x);


			if(raceinfoshowskillnumber[client]==x)
			{
				if(GetRaceSkillDesc(raceid,x,skilldesc,sizeof(skilldesc))>0)
				{
					if(skillSlot>0)
					{
						GetSkillDesc(skillSlot,skilldesc,sizeof(skilldesc));
					}
					//	AddMenuItem(hMenu,selectioninfo,skilldesc,ITEMDRAW_RAWLINE); //,ITEMDRAW_DISABLED|ITEMDRAW_RAWLINE
					Format(str,sizeof(str),"%s \n%s \n",str,skilldesc);
					//Format(longbuf,sizeof(longbuf),"%s\n%s%s  (Level %d/%d)\n%s\n ",longbuf,,skillname,level,,skilldesc);
				}
			}

			if(x==GetRaceSkillCount(raceid)&&raceinfoshowskillnumber[client]==x){
				Format(str,sizeof(str),"%s \n",str); //extend whitespace
			}
			else if(x==GetRaceSkillCount(raceid)){
				Format(str,sizeof(str),"%s \n \n",str); //extend whitespace
			}

			AddMenuItem(hMenu,selectioninfo,str);
		}
		else
		{
			LogError("MenuRacePlayerInfo War3_ShowParticularRaceInfoMenu - War3Source Lookup of GetRaceSkillName(%d,%d,%s,sizeof(%d))",raceid,x,skillname,sizeof(skillname));
		}
	}

	while(SkillCount<6)
	{
		Format(selectioninfo,sizeof(selectioninfo),"%d,0,%d",raceid,0);
		AddMenuItem(hMenu,selectioninfo,"",ITEMDRAW_NOTEXT); //empty line
		SkillCount++;
	}

	if(CanSelectRace(client,raceid,true))
	{
		Format(selectioninfo,sizeof(selectioninfo),"%d,changejob,%d",7,raceid);
		char str[100];
		Format(str,sizeof(str),"%T \n","Change to this Job",client);
		AddMenuItem(hMenu,selectioninfo,str);
	}

	//Format(selectioninfo,sizeof(selectioninfo),"%d,raceinfo,%d",raceid,0);  //raceinfo ??

	//Format(selectioninfo,sizeof(selectioninfo),"%d,jobinfo,%d",8,0);
	//char str[100];
	//Format(str,sizeof(str),"%T \n","Back to jobinfo",client);
	//AddMenuItem(hMenu,selectioninfo,str);

	//Format(selectioninfo,sizeof(selectioninfo),"%d,0,%d",raceid,0);
	//AddMenuItem(hMenu,selectioninfo,"",ITEMDRAW_NOTEXT); //empty line

	//char selectionDisplayBuff[64];
	//Format(selectionDisplayBuff,sizeof(selectionDisplayBuff),"%T \n \n","See all players with job {racename}",client,racename) ;
	//Format(selectioninfo,sizeof(selectioninfo),"%d,seeall,%d",raceid,0);
	//AddMenuItem(hMenu,selectioninfo,selectionDisplayBuff);



	DisplayMenu(hMenu,client,MENU_TIME_FOREVER);
}














public War3_particularraceinfoSelected(Handle:menu,MenuAction:action,client,selection)
{
	if(action==MenuAction_Select)
	{
		if(ValidPlayer(client))
		{

			char exploded[3][32];

			char SelectionInfo[32];
			char SelectionDispText[256];
			int SelectionStyle;
			GetMenuItem(menu,selection,SelectionInfo,sizeof(SelectionInfo),SelectionStyle, SelectionDispText,sizeof(SelectionDispText));

			ExplodeString(SelectionInfo, ",", exploded, 3, 32);
			int raceid=StringToInt(exploded[0]);

			if(StrEqual(exploded[1],"skill")){
				int skillnum=StringToInt(exploded[2]);
				if(raceinfoshowskillnumber[client]==selection){
					raceinfoshowskillnumber[client]=-1;
				}
				else{
					raceinfoshowskillnumber[client]=skillnum;
				}
				War3_ShowParticularRaceInfoMenu(client,raceid);

			}
			//else if(StrEqual(exploded[1],"jobinfo")){
			//	ShowMenu3Raceinfo(client);
			//}
			else if(StrEqual(exploded[1],"changejob")){
				int jobnum=StringToInt(exploded[2]);
				//char buf[32];
				//GetRaceName(jobnum,buf,sizeof(buf));

				//int bool:allowChooseRace=bool:CanSelectRace(client,jobnum); //this is the deny system W3Denyable
				//if(allowChooseRace==false){
					//War3_ChatMessage(client,"You can not change to %s.",buf);
					//ShowMenu3Raceinfo(client);
				//}
				W3SetPendingRace(client,jobnum);
				//SetRace(client, jobnum);
				ForcePlayerSuicide(client);
				//War3_ChatMessage(client,"%T","You will be {racename} after death or spawn",GetTrans(),buf);
			}
			//else if(StrEqual(exploded[1],"seeall")){
				//show all players with this raceid


			//	War3_playersWhoAreThisRaceMenu(client,raceid);
			//}

		}
	}
	if(action==MenuAction_Cancel)
	{
		if(selection==MenuCancel_ExitBack)
		{
			ShowMenu3Raceinfo(client);
		}
	}
	if(action==MenuAction_End)
	{
		CloseHandle(menu);
	}
}













War3_playersWhoAreThisRaceMenu(client,raceid)
{
	Handle hMenu=CreateMenu(War3_playersWhoAreThisRaceSel);
	SetMenuExitButton(hMenu,true);

	char racename[32];
	GetRaceName(raceid,racename,sizeof(racename));

	SetMenuTitle(hMenu,"%T\n \n","[War3Source:EVO] People who are job: {racename}",client,racename);

	char playername[64];
	char war3playerbuf[4];

	for(int x=1;x<=MaxClients;x++)
	{
		if(ValidPlayer(x)&&GetRace(x)==raceid){

			Format(war3playerbuf,sizeof(war3playerbuf),"%d",x);  //target index
			GetClientName(x,playername,sizeof(playername));
			char menuitemstr[100];
			char teamname[10];
			GetShortTeamName( GetClientTeam(x),teamname,sizeof(teamname));
			Format(menuitemstr,sizeof(menuitemstr),"%T","{player} (Level {amount}) [{team}]",client,playername,War3_GetLevel(x,raceid),teamname);
			AddMenuItem(hMenu,war3playerbuf,menuitemstr);
		}
	}
	DisplayMenu(hMenu,client,MENU_TIME_FOREVER);

}
public War3_playersWhoAreThisRaceSel(Handle:menu,MenuAction:action,client,selection)
{
	if(action==MenuAction_Select)
	{

		char SelectionInfo[4];
		char SelectionDispText[256];
		int SelectionStyle;
		GetMenuItem(menu,selection,SelectionInfo,sizeof(SelectionInfo),SelectionStyle, SelectionDispText,sizeof(SelectionDispText));
		int target=StringToInt(SelectionInfo);
		if(ValidPlayer(target))
			War3_playertargetMenu(client,target);
		else
			War3_ChatMessage(client,"%T","Player has left the server",client);

	}
	if(action==MenuAction_End)
	{
		CloseHandle(menu);
	}
}





PlayerInfoMenuEntry(client){
	char arg[32];
	Handle dataarray=internal_W3GetVar(hPlayerInfoArgStr); //should always be created, upper plugin closes handle
	GetArrayString(dataarray,0,arg,sizeof(arg));
	War3_PlayerInfoMenu(client,arg);
}


War3_PlayerInfoMenu(client,String:arg[]){
	SetTrans(client);
	//PrintToChatAll("%s",arg);
	if(strlen(arg)>10){   //has argument (space after)
		char arg2[32];
		Format(arg2,sizeof(arg2),"%s",arg[11]);
		//PrintToChatAll("%s",arg2);


		int found=0;
		int targetlist[MAXPLAYERSCUSTOM];
		char name[32];
		for(int i=1;i<=MaxClients;i++){
			if(ValidPlayer(i)){
				GetClientName(i,name,sizeof(name));
				if(StrContains(name,arg2,false)>-1){
					targetlist[found++]=i;
				}
			}
		}
		if(found==0){
			//War3_ChatMessage(client,"%T","!playerinfo <optional name>: No target found",client);
		}
		else if(found>1){
			//War3_ChatMessage(client,"%T","!playerinfo <optional name>: More than one target found",client);
			//redundant code..maybe we should optmize?
			Handle hMenu=CreateMenu(War3_playerinfoSelected1);
			SetMenuExitButton(hMenu,true);
			SetMenuTitle(hMenu,"%T\n ","[War3Source:EVO] Select a player to view its information",client);
			// Iteriate through the players and print them out
			char playername[32];
			char war3playerbuf[4];
			char racename[32];
			char menuitem[100] ;
			for(new i=0;i<found;i++)
			{
				new clientindex=targetlist[i];
				Format(war3playerbuf,sizeof(war3playerbuf),"%d",clientindex);  //target index
				GetClientName(clientindex,playername,sizeof(playername));
				GetRaceName(GetRace(clientindex),racename,sizeof(racename));

				// Replace No Race w/ No Job
				if(StrEqual("No Race",racename,true))
					strcopy(racename, sizeof(racename), "No Job");

				if(GetRace(clientindex)>0)
				{
					Format(menuitem,sizeof(menuitem),"%T","{player} ({racename} LVL {amount})",GetTrans(),playername,racename,War3_GetLevel(clientindex,GetRace(clientindex)));
				}
				else
				{
					Format(menuitem,sizeof(menuitem),"%T","{player} ({racename})",GetTrans(),playername,racename);
				}
				AddMenuItem(hMenu,war3playerbuf,menuitem);

			}
			DisplayMenu(hMenu,client,MENU_TIME_FOREVER);

		}
		else {
				War3_playertargetMenu(client,targetlist[0]);
		}
	}
	else
	{

		Handle hMenu=CreateMenu(War3_playerinfoSelected1);
		SetMenuExitButton(hMenu,true);
		SetMenuTitle(hMenu,"%T\n ","[War3Source:EVO] Select a player to view its information",client);
		// Iteriate through the players and print them out
		char playername[32];
		char war3playerbuf[4];
		char racename[32];
		char menuitem[100] ;
		for(new x=1;x<=MaxClients;x++)
		{
			if(ValidPlayer(x)){

				Format(war3playerbuf,sizeof(war3playerbuf),"%d",x);  //target index
				GetClientName(x,playername,sizeof(playername));
				GetRaceName(GetRace(x),racename,sizeof(racename));

				// Replace No Race w/ No Job
				if(StrEqual("No Race",racename,true))
					strcopy(racename, sizeof(racename), "No Job");

				if(GetRace(x)>0)
				{
					Format(menuitem,sizeof(menuitem),"%T","{player} ({racename} LVL {amount})",GetTrans(),playername,racename,War3_GetLevel(x,GetRace(x)));
				}
				else
				{
					Format(menuitem,sizeof(menuitem),"%T","{player} ({racename})",GetTrans(),playername,racename);
				}
				AddMenuItem(hMenu,war3playerbuf,menuitem);
			}
		}
		DisplayMenu(hMenu,client,MENU_TIME_FOREVER);
	}
}

public War3_playerinfoSelected1(Handle:menu,MenuAction:action,client,selection)
{
	if(action==MenuAction_Select)
	{
		char SelectionInfo[4];
		char SelectionDispText[256];
		int SelectionStyle;
		GetMenuItem(menu,selection,SelectionInfo,sizeof(SelectionInfo),SelectionStyle, SelectionDispText,sizeof(SelectionDispText));
		int target=StringToInt(SelectionInfo);
		if(ValidPlayer(target))
			War3_playertargetMenu(client,target);
		else
			War3_ChatMessage(client,"%T","Player has left the server",client);
	}
	if(action==MenuAction_End)
	{
		CloseHandle(menu);
	}
}


War3_playertargetMenu(client,target)
{
	SetTrans(client);
	Handle hMenu=CreateMenu(War3_playertargetMenuSelected);
	SetMenuExitButton(hMenu,true);

	char targetname[32];
	GetClientName(target,targetname,sizeof(targetname));

	char racename[32];
	char skillname[64];

	int raceid=GetRace(target);
	GetRaceName(raceid,racename,sizeof(racename));

	int level;
	level=War3_GetLevel(target,raceid);

	char title[3000];

	Format(title,sizeof(title),"%T\n \n","[War3Source:EVO] Information for {player}",client,targetname);
	Format(title,sizeof(title),"%s\n \nTotal levels: %d ",title,GetClientTotalLevels(target));

	if(level<GetRaceMaxLevel(raceid)){
		Format(title,sizeof(title),"%s%T",title,"Current Job: {racename} (LVL {amount}/{amount}) XP: {amount}/{amount}",client,racename,level,GetRaceMaxLevel(raceid),GetXP(target,raceid),W3GetReqXP(level+1));
	}else{
		Format(title,sizeof(title),"%s%T",title,"Current Job: {racename} (LVL {amount}/{amount}) XP: {amount}",client,racename,level,GetRaceMaxLevel(raceid),GetXP(target,raceid));
	}
	//Format(title,sizeof(title),"%s\n",title);
	Format(title,sizeof(title),"%s\nRace kdr: %.2f\n",title,GetRaceKDR(raceid));

	int SkillCount = GetRaceSkillCount(raceid);
	for(int x=1;x<=SkillCount;x++)
	{
		if(GetRaceSkillName(raceid,x,skillname,sizeof(skillname))>0)
		{
			level=GetSkillLevelINTERNAL(target,raceid,x) ;
			if(IsSkillUltimate(raceid,x))
			{
				Format(title,sizeof(title),"%s%T\n",title,"Ultimate: {skillname} (LVL {amount}/{amount})",client,skillname,level,GetRaceSkillMaxLevel(raceid,x));
			}
			else
			{
				Format(title,sizeof(title),"%s%T\n",title,"{skillname} (LVL {amount}/{amount})",client,skillname,level,GetRaceSkillMaxLevel(raceid,x));
			}
		}
		else
		{
			LogError("MenuRacePlayerInfo War3_playertargetMenu - War3Source Lookup of GetRaceSkillName(%d,%d,%s,sizeof(%d))",raceid,x,skillname,sizeof(skillname));
		}
	}
	// IF FALSE:
	// ONLY SHOW ITEMS IF YOU ARE OWNER
	// DON'T SHOW OTHER PLAYERS ITEMS
//    if(client==target)
	if(GetConVarBool(ShowOtherPlayerItemsCvar)&&client!=target)
	{
		Format(title,sizeof(title),"%s\n \n%T\n",title,"Items:",client);

		char itemname[64];
		int moleitemid=internal_GetItemIdByShortname("mole");
		int ItemsLoaded = totalItemsLoaded;
		for(int itemid=1;itemid<=ItemsLoaded;itemid++)
		{
			if(GetOwnsItem(target,itemid)&&itemid!=moleitemid)
			{
			 W3GetItemName(itemid,itemname,sizeof(itemname));
			 Format(title,sizeof(title),"%s\n%s",title,itemname);
			}
		}
		int Items2Loaded = W3GetItems2Loaded();
		for(int itemid=1;itemid<=Items2Loaded;itemid++)
		{
			if(War3_GetOwnsItem2(target,itemid)&&itemid!=moleitemid)
			{
				W3GetItem2Name(itemid,itemname,sizeof(itemname));
				Format(title,sizeof(title),"%s\n%s",title,itemname);
			}
		}
	}
	else if(GetConVarBool(ShowTargetSelfPlayerItemsCvar)&&client==target)
	{
		Format(title,sizeof(title),"%s\n \n%T\n",title,"Items:",client);

		char itemname[64];
		int moleitemid=internal_GetItemIdByShortname("mole");
		int ItemsLoaded = totalItemsLoaded;
		for(int itemid=1;itemid<=ItemsLoaded;itemid++)
		{
			if(GetOwnsItem(target,itemid)&&itemid!=moleitemid)
			{
			 W3GetItemName(itemid,itemname,sizeof(itemname));
			 Format(title,sizeof(title),"%s\n%s",title,itemname);
			}
		}
		int Items2Loaded = W3GetItems2Loaded();
		for(int itemid=1;itemid<=Items2Loaded;itemid++)
		{
			if(War3_GetOwnsItem2(target,itemid)&&itemid!=moleitemid)
			{
				W3GetItem2Name(itemid,itemname,sizeof(itemname));
				Format(title,sizeof(title),"%s\n%s",title,itemname);
			}
		}
	}
	float armorred=(1.0-PhysicalArmorMulti(target))*100;
	Format(title,sizeof(title),"%s\n \n%T",title,"Physical Armor: {amount} (+-{amount}%)",client,GetBuffSumFloat(target,fArmorPhysical),armorred<0.0?"+":"-",armorred<0.0?armorred*-1.0:armorred);

	armorred=(1.0-W3GetMagicArmorMulti(target))*100;
	Format(title,sizeof(title),"%s\n%T",title,"PImagicArmor: {amount} (+-{amount}%)",client,GetBuffSumFloat(target,fArmorMagic),armorred<0.0?"+":"-",armorred<0.0?armorred*-1.0:armorred);

	Format(title,sizeof(title),"%s\n \n",title);


	SetMenuTitle(hMenu,"%s",title);
	// Iteriate through the races and print them out




	char buf[3];

	IntToString(target,buf,sizeof(buf));
	char str[100];
	Format(str,sizeof(str),"%T","Refresh",client);
	AddMenuItem(hMenu,buf,str);

	char selectionDisplayBuff[64];
	Format(selectionDisplayBuff,sizeof(selectionDisplayBuff),"%T","See {racename} Job information",client,racename)  ;
	AddMenuItem(hMenu,buf,selectionDisplayBuff);

	Format(selectionDisplayBuff,sizeof(selectionDisplayBuff),"%T","See all players with job {racename}",client,racename) ;
	AddMenuItem(hMenu,buf,selectionDisplayBuff);

	Format(selectionDisplayBuff,sizeof(selectionDisplayBuff),"%T","Spectate Player",client) ;
	AddMenuItem(hMenu,buf,selectionDisplayBuff);

	DisplayMenu(hMenu,client,MENU_TIME_FOREVER);
}

War3_playertargetItemMenu(client,target)
{
		Handle hMenu=CreateMenu(War3_playertargetItemMenuSelected2);
		SetMenuExitButton(hMenu,true);

		char title[3000];

		// Items info
		//if(client==target)
		//{
		Format(title,sizeof(title),"%s\n \n%T\n",title,"Items:",client);

		Format(title,sizeof(title),"%s\n \n",title);

		char itemname[64];
		int moleitemid=internal_GetItemIdByShortname("mole");
		int ItemsLoaded = totalItemsLoaded;
		for(int itemid=1;itemid<=ItemsLoaded;itemid++)
		{
			if(GetOwnsItem(target,itemid)&&itemid!=moleitemid)
			{
				W3GetItemName(itemid,itemname,sizeof(itemname));
				Format(title,sizeof(title),"%s\n%s",title,itemname);
			}
		}
		Format(title,sizeof(title),"%s\n \n",title);

		int Items2Loaded = W3GetItems2Loaded();
		for(int itemid=1;itemid<=Items2Loaded;itemid++)
		{
			if(War3_GetOwnsItem2(target,itemid)&&itemid!=moleitemid)
			{
				W3GetItem2Name(itemid,itemname,sizeof(itemname));
				Format(title,sizeof(title),"%s\n%s",title,itemname);
			}
		}
	//}

		Format(title,sizeof(title),"%s\n \n",title);

		SetMenuTitle(hMenu,"%s",title);

		char buf[3];

		IntToString(target,buf,sizeof(buf));
		char str[100];
		Format(str,sizeof(str),"%T","Refresh",client);
		AddMenuItem(hMenu,buf,str);

		DisplayMenu(hMenu,client,MENU_TIME_FOREVER);
}


public War3_playertargetItemMenuSelected2(Handle:menu,MenuAction:action,client,selection)
{
	if(action==MenuAction_Select)
	{
		char SelectionInfo[4];
		char SelectionDispText[256];
		int SelectionStyle;
		GetMenuItem(menu,selection,SelectionInfo,sizeof(SelectionInfo),SelectionStyle, SelectionDispText,sizeof(SelectionDispText));
		int target=StringToInt(SelectionInfo);
		if(!ValidPlayer(target)){
			War3_ChatMessage(client,"%T","Player has left the server",client);
		}
		else
		{
			if(selection==0){
				War3_playertargetItemMenu(client,target);
			}
		}
		if(action==MenuAction_End)
		{
			CloseHandle(menu);
		}
	}
}

public War3_playertargetMenuSelected(Handle:menu,MenuAction:action,client,selection)
{
	if(action==MenuAction_Select)
	{
		char SelectionInfo[4];
		char SelectionDispText[256];
		int SelectionStyle;
		GetMenuItem(menu,selection,SelectionInfo,sizeof(SelectionInfo),SelectionStyle, SelectionDispText,sizeof(SelectionDispText));
		int target=StringToInt(SelectionInfo);
		if(!ValidPlayer(target)){
			War3_ChatMessage(client,"%T","Player has left the server",client);
		}
		else{

			if(selection==0){
				War3_playertargetMenu(client,target);
			}
			if(selection==1){
				int raceid=GetRace(target);
				War3_ShowParticularRaceInfoMenu(client,raceid);
			}
			if(selection==2){
				int raceid=GetRace(target);
				War3_playersWhoAreThisRaceMenu(client,raceid);
			}
			if(selection==3){
				if(ValidPlayer(target,true)){
					SetEntDataEnt2(client, FindSendPropInfo("CBasePlayer", "m_hObserverTarget"),target,true);
				}
				else{
					War3_ChatMessage(client,"%T","Player Not Alive",client);
				}
				War3_playertargetMenu(client,target);
			}
		}
	}
	if(action==MenuAction_End)
	{
		CloseHandle(menu);
	}
}





GetClientTotalLevels(client)
{
	int total_level=0;
	int RacesLoaded = GetRacesLoaded();
	for(int r=1;r<=RacesLoaded;r++)
	{
		total_level+=War3_GetLevel(client,r);
	}
	return  total_level;
}



