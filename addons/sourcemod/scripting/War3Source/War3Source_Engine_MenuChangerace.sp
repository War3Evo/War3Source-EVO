// War3Source_Engine_MenuChangerace.sp

//race cat defs
new Handle:hUseCategories,Handle:hCanDrawCat,Handle:hAllowCategoryDefault,Handle:hAllowAllRacesCategory;
new String:strCategories[MAXCATS][64];
new CatCount;

/*
public Plugin:myinfo=
{
	name="War3Source:EVO Menus changeJob",
	author="Ownz (DarkEnergy) && El Diablo",
	description="War3Source:EVO Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};*/

public War3Source_Engine_MenuChangerace_OnPluginStart()
{
	hUseCategories = CreateConVar("war3_jobcats","0","If non-zero job categories will be enabled");
	hAllowCategoryDefault = CreateConVar("war3_allow_default_cats","0","Allow Default categories to show in category menu? (default 0)");
	hAllowAllRacesCategory = CreateConVar("war3_allow_all_races_cats","0","Allow Default categories to show in category menu? (default 1)");
	RegServerCmd("war3_reloadcats", Command_ReloadCats);
}

public bool:War3Source_Engine_MenuChangerace_InitNativesForwards()
{
	hCanDrawCat=CreateGlobalForward("OnW3DrawCategory",ET_Hook,Param_Cell,Param_Cell);
	return true;
}

public bool:War3Source_Engine_MenuChangerace_InitNatives()
{
	CreateNative("W3GetCategoryName",Native_GetCategoryName);
	return true;
}

public Action:Command_ReloadCats(args) {
	PrintToServer("[WAR3] forcing job categories to be refreshed..");
	refreshCategories();
	return Plugin_Handled;
}


public War3Source_Engine_MenuChangerace_OnWar3Event(client)
{
	if(ValidPlayer(client)&& !W3Denied(DN_ShowChangeRace,client)){
		War3Source_ChangeRaceMenu(client);
	}
}

public bool:HasCategoryAccess(client,i)
{
	if(CanDrawCategory(client,i))
	{
		return true;
	}
	return false;
}

public War3Source_Engine_MenuChangerace_OnMapStart()
{
	// Delay refresh cats helps prevent stack overflow. - el diablo
	CreateTimer(5.0,refresh_cats,_);
}

/* ****************************** Action:refresh_cats ************************** */

public Action:refresh_cats(Handle:timer)
{
	refreshCategories();
}


new String:War3Source_Engine_MenuChangerace_dbErrorMsg[100];
public OnWar3GlobalError(String:err[]){
	strcopy(War3Source_Engine_MenuChangerace_dbErrorMsg,sizeof(War3Source_Engine_MenuChangerace_dbErrorMsg),err);
}

//This just returns the amount of untouched(=level 0) races in the given category
stock GetNewRacesInCat(client,String:category[]) {
	new amount=0;
	new racelist[MAXRACES];
	new racedisplay=W3GetRaceList(racelist);
	for(new i=1;i<racedisplay;i++)
	{
		new String:rcvar[64];
		W3GetCvar(W3GetRaceCell(i,RaceCategorieCvar),rcvar,sizeof(rcvar));
		if(strcmp(category, rcvar, false)==0) {
			amount++;
		}
	}
	return amount;
}

War3Source_ChangeRaceMenu(client,bool:forceUncategorized=false)
{
	if(W3IsPlayerXPLoaded(client))
	{
		//Check for Races Developer:
		//El Diablo: Adding myself as a races developer so that I can double check for any errors
		//in the races content of any server.  This allows me to have all races enabled.
		//I do not have any other access other than all races to make sure that
		//all races work correctly with war3source.
		char steamid[32];
		GetClientAuthId(client,AuthId_Steam2,STRING(steamid),true);

		SetTrans(client);
		decl Handle:crMenu;
		if( IsCategorized() && !forceUncategorized ) {
			//Revan: the long requested changerace categorie feature
			//TODO:
			//- translation support
			crMenu=CreateMenu(War3Source_CRMenu_SelCat);
			SetMenuExitButton(crMenu,true);

			new String:title[400];
			if(strlen(War3Source_Engine_MenuChangerace_dbErrorMsg)){
				Format(title,sizeof(title),"%s\n \n",War3Source_Engine_MenuChangerace_dbErrorMsg);
			}
			Format(title,sizeof(title),"%s%T",title,"[War3Source:EVO] Select a category",GetTrans()) ;
			if(W3GetLevelBank(client)>0){
				Format(title,sizeof(title),"%s\n%T\n",title,"You Have {amount} levels in levelbank. Say levelbank to use it",GetTrans(), W3GetLevelBank(client));
			}
			SetMenuTitle(crMenu,"%s\n \n",title);
			decl String:strCat[64];
			//Prepend 'All Jobs' entry.
			if(GetConVarBool(hAllowAllRacesCategory))
			{
				AddMenuItem(crMenu,"-1","All Races/Jobs");
			}
			//At first we gonna add the categories
			for(new i=1;i<CatCount;i++) {
				W3GetCategory(i,strCat,sizeof(strCat));
				if(StrEqual(strCat,"default") && !GetConVarBool(hAllowCategoryDefault))
					continue;
				if(strlen(strCat)>0) {
					if(HasCategoryAccess(client,i)) {
						new amount=GetNewRacesInCat(client,strCat);
						if(amount>0) {
							decl String:buffer[64];
							Format(buffer,sizeof(buffer),"%s (%i new jobs)",strCat,amount);
						}
						AddMenuItem(crMenu,strCat,strCat);
					}
				}
			}
		}
		else {
			crMenu=CreateMenu(War3Source_CRMenu_Selected);
			SetMenuExitButton(crMenu,true);

			new String:title[400], String:rbuf[4];
			if(strlen(War3Source_Engine_MenuChangerace_dbErrorMsg)){
				Format(title,sizeof(title),"%s\n \n",War3Source_Engine_MenuChangerace_dbErrorMsg);
			}
			Format(title,sizeof(title),"%s%T",title,"[War3Source:EVO] Select your desired job",GetTrans()) ;
			if(W3GetLevelBank(client)>0){
				Format(title,sizeof(title),"%s\n%T\n",title,"You Have {amount} levels in levelbank. Say levelbank to use it",GetTrans(), W3GetLevelBank(client));
			}
			SetMenuTitle(crMenu,"%s\n \n",title);
			// Iteriate through the races and print them out
			new String:rname[32];
			new String:rdisp[128],String:requirement[128],String:ShortDesc[32];


			new racelist[MAXRACES];
			new racedisplay=W3GetRaceList(racelist);
			//if(GetConVarInt(W3GetVar(hSortByMinLevelCvar))<1){
			//	for(new x=0;x<War3_GetRacesLoaded();x++){//notice this starts at zero!
			//		racelist[x]=x+1;
			//	}
			//}
#if GGAMETYPE == GGAME_TF2
			new bool:SteamGroupRequired=false;
#endif
			new bool:VIPRequired=false;
			new bool:draw_ITEMDRAW_DEFAULT=false;

			new AdminId:id = GetUserAdmin(client);
			new bool:IsVip = (id == INVALID_ADMIN_ID) ? false : true;
			//if(IsVip)
			//{
				//DP("ISVIP = TRUE");
			//}
			//else
			//{
				//DP("ISVIP = FALSE");
			//}

			bool value = true;

			for(int i=0;i<racedisplay;i++) //notice this starts at zero!
			{
				int	x=racelist[i];

				W3SetVar(EventArg1,x);
				W3SetVar(EventArg2,true);
				value=W3Denyable(DN_CanSelectRace,client);

				if(!value) continue;

				Format(rbuf,sizeof(rbuf),"%d",x); //DATA FOR MENU!

				draw_ITEMDRAW_DEFAULT=false;
				VIPRequired=false;
#if GGAMETYPE == GGAME_TF2
				SteamGroupRequired=false;
#endif

				new String:requiredflagstr[32];
				W3GetRaceAccessFlagStr(x,requiredflagstr,sizeof(requiredflagstr));  ///14 = index, see races.inc

				if(!StrEqual(requiredflagstr, "0", false) && !StrEqual(requiredflagstr, "", false))
				{
					GetRaceName(x,rname,sizeof(rname));
					Format(rname,sizeof(rname),"%s V",rname);
					draw_ITEMDRAW_DEFAULT=false;
					VIPRequired=true;
					//DP("VIPRequired=true;");
				}
#if GGAMETYPE == GGAME_TF2
				else if(!bIsInSteamGroup[client]&&W3RaceHasFlag(x,"steamgroup"))
				{
					GetRaceName(x,rname,sizeof(rname));
					Format(rname,sizeof(rname),"%s S",rname);
					draw_ITEMDRAW_DEFAULT=false;
					SteamGroupRequired=true;
					//DP("SteamGroupRequired=true;");
				}
#endif
				else
				{
					GetRaceName(x,rname,sizeof(rname));
				}

				if(IsVip)
				{
					GetRaceName(x,rname,sizeof(rname));
				}

				//decl String:ttmpstr[16];
				//FloatToString(War3_GetRaceKDR(x), ttmpstr, sizeof(ttmpstr));
				Format(rname,sizeof(rname),"%s %.1f",rname,War3_GetRaceKDR(x));

				new yourteam,otherteam;
				for(new y=1;y<=MaxClients;y++)
				{

					if(ValidPlayer(y,false))
					{
						if(GetRace(y)==x)
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
				new String:extra[3];
				if(GetRace(client)==x)
				{
					Format(extra,sizeof(extra),">");

				}
				else if(W3GetPendingRace(client)==x){
					Format(extra,sizeof(extra),"<");

				}



				Format(rdisp,sizeof(rdisp),"%s%T",extra,"{racename} [L {amount}]",GetTrans(),rname,War3_GetLevel(client,x));
				new minlevel=W3GetRaceMinLevelRequired(x);
				if(minlevel<0) minlevel=0;
				if(minlevel)
				{
					//Format(rdisp,sizeof(rdisp),"%s %T",rdisp,"reqlvl {amount}",GetTrans(),minlevel);
					Format(requirement,sizeof(requirement),"%s %T","","reqlvl {amount}",GetTrans(),minlevel);
				}

				if(IsVip && VIPRequired)
				{
					Format(requirement,sizeof(requirement),"V");
					draw_ITEMDRAW_DEFAULT=false;
				}
				//else if(!bIsInSteamGroup(client)&&W3RaceHasFlag(x,"steamgroup"))
				//{
					//Format(requirement,sizeof(requirement),"*steamgroup req.*");
					//draw_ITEMDRAW_DEFAULT=false;
					//SteamGroupRequired=true;
				//}
				//else
				//{
#if GGAMETYPE == GGAME_TF2
				else if(bIsInSteamGroup[client] && W3RaceHasFlag(x,"steamgroup"))
				{
					// Lets not fill up the display, this would tell them the race is a steam group race
					Format(requirement,sizeof(requirement),"S");
				}
#endif
				draw_ITEMDRAW_DEFAULT=minlevel<=GetTotalLevels(client)?true:false;
					//AddMenuItem(crMenu,rbuf,rdisp,minlevel<=W3GetTotalLevels(client)?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
				//}

				// Display only one requirement
				Format(rdisp,sizeof(rdisp),"%s %s",rdisp,requirement);
				// Erase requirement
				strcopy(requirement, sizeof(requirement), "");

				// Very Short Race Description
				//if(!IsVip && VIPRequired)
				//{
					//Format(rdisp,sizeof(rdisp),"%s\n%s",rdisp,"please consider donating");
				//}
				//else
#if GGAMETYPE == GGAME_TF2
				if(!IsVip && SteamGroupRequired)
				{
					Format(rdisp,sizeof(rdisp),"%s\n%s",rdisp,"Join our Steam Group");
				}
				else
				{
					War3_GetRaceShortdesc(x,ShortDesc,sizeof(ShortDesc));
					Format(rdisp,sizeof(rdisp),"%s\n%s",rdisp,ShortDesc);
				}
#else
				War3_GetRaceShortdesc(x,ShortDesc,sizeof(ShortDesc));
				Format(rdisp,sizeof(rdisp),"%s\n%s",rdisp,ShortDesc);
#endif

				// If client is admin, all races are availible.
				new AdminId:admin = GetUserAdmin(client);
				if(admin != INVALID_ADMIN_ID) //flag is required and this client is not admin
				{
					draw_ITEMDRAW_DEFAULT=true;
					//AddMenuItem(crMenu,rbuf,rdisp,ITEMDRAW_DEFAULT);
				}

				// draw menu item
				if(draw_ITEMDRAW_DEFAULT||W3IsDeveloper(client))
				{
					AddMenuItem(crMenu,rbuf,rdisp,ITEMDRAW_DEFAULT);
				}
				else
				{
					AddMenuItem(crMenu,rbuf,rdisp,ITEMDRAW_DISABLED);
				}

			}
#if GGAMETYPE == GGAME_TF2
			if(SteamGroupRequired==true)
			{
				War3_ChatMessage(client,"Please join our steam group!");
			}
#endif
		}
		DisplayMenu(crMenu,client,MENU_TIME_FOREVER);
	}
	else{
		War3_ChatMessage(client,"XP failed to load! Please reconnect!");
	}

}

public War3Source_CRMenu_SelCat(Handle:menu,MenuAction:action,client,selection)
{
	switch(action) {
		case MenuAction_Select:
		{
			if(ValidPlayer(client))
			{
				SetTrans(client);
				new String:sItem[64],String:title[512],String:rbuf[4],String:rname[32],String:rdisp[128],String:requirement[128];
				GetMenuItem(menu, selection, sItem, sizeof(sItem));
				if( StringToInt(sItem) == -1 ) {
					War3Source_ChangeRaceMenu(client,true);
					return;
				}

				new Handle:crMenu=CreateMenu(War3Source_CRMenu_Selected);
				SetMenuExitButton(crMenu,true);
				Format(title,sizeof(title),"%T","[War3Source:EVO] Select your desired job",GetTrans());
				SetMenuTitle(crMenu,"%s\nCategory: %s\n",title,sItem);
				// Iteriate through the races and print them out
				new racelist[MAXRACES];
				new racedisplay=W3GetRaceList(racelist);
#if GGAMETYPE == GGAME_TF2
				new bool:SteamGroupRequired=false;
#endif
				bool value=true;
				AddMenuItem(crMenu,"-1","[Return to Categories]");
				for(int i=0;i<racedisplay;i++)
				{
					int	x=racelist[i];
					char rcvar[64];

					W3SetVar(EventArg1,x);
					W3SetVar(EventArg2,true);
					value=W3Denyable(DN_CanSelectRace,client);

					if(!value) continue;

					W3GetCvar(W3GetRaceCell(x,RaceCategorieCvar),rcvar,sizeof(rcvar));
					if(strcmp(sItem, rcvar, false)==0) {
						IntToString(x,rbuf,sizeof(rbuf)); //menudata as string
						GetRaceName(x,rname,sizeof(rname));
						decl String:extra[3],yourteam,otherteam;
						for(new y=1;y<=MaxClients;y++)
						{

							if(ValidPlayer(y,false))
							{
								if(GetRace(y)==x)
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
						strcopy(extra, sizeof(extra), "");
						if(GetRace(client)==x)
						{
							Format(extra,sizeof(extra),">");
						}
						else if(W3GetPendingRace(client)==x){
							Format(extra,sizeof(extra),"<");
						}
						Format(rdisp,sizeof(rdisp),"%s%T",extra,"{racename} [L {amount}]",GetTrans(),rname,War3_GetLevel(client,x));
						new minlevel=W3GetRaceMinLevelRequired(x);
						if(minlevel<0) minlevel=0;
						if(minlevel)
						{
							//Format(rdisp,sizeof(rdisp),"%s %T",rdisp,"reqlvl {amount}",GetTrans(),minlevel);
							//requirement
							Format(requirement,sizeof(requirement),"%s %T","","reqlvl {amount}",GetTrans(),minlevel);
						}
						new String:requiredflagstr[32];
						W3GetRaceAccessFlagStr(x,requiredflagstr,sizeof(requiredflagstr));  ///14 = index, see races.inc

						new bool:draw_ITEMDRAW_DEFAULT=false;

						if(!StrEqual(requiredflagstr, "0", false)&&!StrEqual(requiredflagstr, "", false))
						{
							//Format(rdisp,sizeof(rdisp),"%s (VIP Only)",rdisp);
							Format(requirement,sizeof(requirement),"(VIP Only)");
							draw_ITEMDRAW_DEFAULT=false;
						}
#if GGAMETYPE == GGAME_TF2
						else if(!bIsInSteamGroup[client]&&W3RaceHasFlag(x,"steamgroup"))
						{
							//Format(rdisp,sizeof(rdisp),"%s *Steam Group Required*",rdisp);
							Format(requirement,sizeof(requirement),"*Steam Group Required*");

							draw_ITEMDRAW_DEFAULT=false;
							//AddMenuItem(crMenu,rbuf,rdisp,ITEMDRAW_DISABLED);

							SteamGroupRequired=true;

							//War3_ChatMessage(client,"Job %s requires you join our Steam Group",rname);
							//War3_ChatMessage("Sometimes we lose connection to the steam group, so please be patient.");
						}
#endif
						else
						{
							// MIN LEVEL REQUIREMENT

							//AddMenuItem(crMenu,rbuf,rdisp,(minlevel<=W3GetTotalLevels(client)||StrEqual(steamid,"STEAM_0:1:35173666",false)?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
							if(W3RaceHasFlag(x,"steamgroup"))
							{
								// Lets not fill up the display, this would tell them the race is a steam group race

								Format(requirement,sizeof(requirement),"(Steam Group)");

							}

							draw_ITEMDRAW_DEFAULT=minlevel<=GetTotalLevels(client)?true:false;
							//AddMenuItem(crMenu,rbuf,rdisp,minlevel<=W3GetTotalLevels(client)?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
						}

						// Display only one requirement
						Format(rdisp,sizeof(rdisp),"%s %s",rdisp,requirement);
						// Erase requirement
						strcopy(requirement, sizeof(requirement), "");

						// If client is admin, all races are availible.
						new AdminId:admin = GetUserAdmin(client);
						if(admin != INVALID_ADMIN_ID) //flag is required and this client is not admin
						{
							draw_ITEMDRAW_DEFAULT=true;
							//AddMenuItem(crMenu,rbuf,rdisp,ITEMDRAW_DEFAULT);
						}

						// draw menu item
						if(draw_ITEMDRAW_DEFAULT||W3IsDeveloper(client))
						{
							AddMenuItem(crMenu,rbuf,rdisp,ITEMDRAW_DEFAULT);
						}
						else
						{
							AddMenuItem(crMenu,rbuf,rdisp,ITEMDRAW_DISABLED);
						}

					}
#if GGAMETYPE == GGAME_TF2
					if(SteamGroupRequired==true)
					{
						War3_ChatMessage(client,"Please join our Steam Group.");
					}
#endif
				}
				DisplayMenu(crMenu,client,MENU_TIME_FOREVER);
			}
		}
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
	}
}


public War3Source_CRMenu_Selected(Handle:menu,MenuAction:action,client,selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(ValidPlayer(client))
			{
				SetTrans(client);
				//new menuselectindex=selection+1;
				//if(racechosen>0&&racechosen<=War3_GetRacesLoaded())

				decl String:SelectionInfo[4];
				decl String:SelectionDispText[256];

				new SelectionStyle;
				GetMenuItem(menu,selection,SelectionInfo,sizeof(SelectionInfo),SelectionStyle, SelectionDispText,sizeof(SelectionDispText));
				new race_selected=StringToInt(SelectionInfo);

				if(race_selected==-1) {
					War3Source_ChangeRaceMenu(client); //user came from the categorized cr menu and clicked the back button
					return;
				}

				new bool:allowChooseRace=bool:CanSelectRace(client,race_selected); //this is the deny system W3Denyable
				if(allowChooseRace==false){
					War3Source_ChangeRaceMenu(client);//derpy hooves
				}


			/* MOVED TO RESTRICT ENGINE
				if(allowChooseRace){
					// Minimum level?

					new total_level=0;
					new RacesLoaded = War3_GetRacesLoaded();
					for(new x=1;x<=RacesLoaded;x++)
					{
						total_level+=War3_GetLevel(client,x);
					}
					new min_level=W3GetRaceMinLevelRequired(race_selected);
					if(min_level<0) min_level=0;

					if(min_level!=0&&min_level>total_level&&!W3IsDeveloper(client))
					{
						War3_ChatMessage(client,"%T","You need {amount} more total levels to use this race",GetTrans(),min_level-total_level);
						War3Source_ChangeRaceMenu(client);
						allowChooseRace=false;
					}
				}
					*/

				// GetUserFlagBits(client)&ADMFLAG_ROOT??




				///MOVED TO RESTRICT ENGINE
				/*
				new String:requiredflagstr[32];

				W3GetRaceAccessFlagStr(race_selected,requiredflagstr,sizeof(requiredflagstr));  ///14 = index, see races.inc

				if(allowChooseRace&&!StrEqual(requiredflagstr, "0", false)&&!StrEqual(requiredflagstr, "", false)&&!W3IsDeveloper(client)){

					new AdminId:admin = GetUserAdmin(client);
					if(admin == INVALID_ADMIN_ID) //flag is required and this client is not admin
					{
						allowChooseRace=false;
						War3_ChatMessage(client,"%T","Restricted Race. Ask an admin on how to unlock",GetTrans());
						PrintToConsole(client,"%T","No Admin ID found",client);
						War3Source_ChangeRaceMenu(client);

					}
					else{
						decl AdminFlag:flag;
						if (!FindFlagByChar(requiredflagstr[0], flag)) //this gets the flag class from the string
						{
							War3_ChatMessage(client,"%T","ERROR on admin flag check {flag}",client,requiredflagstr);
							allowChooseRace=false;
						}
						else
						{
							if (!GetAdminFlag(admin, flag)){
								allowChooseRace=false;
								War3_ChatMessage(client,"%T","Restricted race, ask an admin on how to unlock",GetTrans());
								PrintToConsole(client,"%T","Admin ID found, but no required flag",client);
								War3Source_ChangeRaceMenu(client);
							}
						}
					}
				}

				*/



					//PrintToChatAll("1");
				decl String:buf[32];
				GetRaceName(race_selected,buf,sizeof(buf));
				if(allowChooseRace&&race_selected==GetRace(client)/*&&(   W3GetPendingRace(client)<1||W3GetPendingRace(client)==War3_GetRace(client)    ) */){ //has no other pending race, cuz user might wana switch back

					War3_ChatMessage(client,"%T","You are already {racename}",GetTrans(),buf);
					//if(W3GetPendingRace(client)){
					W3SetPendingRace(client,-1);

					//}
					allowChooseRace=false;

				}






				if(allowChooseRace)
				{
					SetPlayerProp(client,RaceChosenTime,GetGameTime());
					SetPlayerProp(client,RaceSetByAdmin,false);

					//has race, set pending,
					if(GetRace(client)>0&&IsPlayerAlive(client)&&!W3IsDeveloper(client)) //developer direct set (for testing purposes)
					{
						new bool:JailBreak=false;
	#if defined _tf2jail_included
						JailBreak=true;
	#endif
						if(!JailBreak)
						{
							//new Float:pos[3];
							//GetClientAbsOrigin(client,pos);

							//if(W3IsHelper(client))
							//{
							if(gh_CVAR_AllowInstantSpawn.BoolValue && War3_IsInSpawn(client))
							{
								W3SetPendingRace(client,-1);
								SetRace(client,race_selected);
								War3_ChatMessage(client,"You can now changerace or changejob instantly in spawn.");
							}
							else
							{
								War3_ChatMessage(client,"You must be in {green}spawn{default} to have instant job/race changing.",buf);
								W3SetPendingRace(client,race_selected);
								War3_ChatMessage(client,"You will be {green}%s{default} after death or spawn",buf);
							}
							//}
							//else
							//{
								//W3SetPendingRace(client,race_selected);
								//War3_ChatMessage(client,"You will be {green}%s{default} after death or spawn",buf);
							//}
						}
						else
						{
							War3_ChatMessage(client,"Only in JailBreak Warcraft can you switch races instantly!",buf);
							W3SetPendingRace(client,-1);
							SetRace(client,race_selected);
						}
					}
					//HAS NO RACE, CHANGE NOW
					else //schedule the race change
					{
						W3SetPendingRace(client,-1);
						SetRace(client,race_selected);

						//PrintToChatAll("2");
						//print is in setrace
						//War3_ChatMessage(client,"You are now %s",buf);

						W3DoLevelCheck(client);
					}

				}
			}
		}
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
	}
}

//category stocks
//Checks if a category exist
stock bool:W3IsCategory(const String:cat_name[]) {
	for(new i=0;i<CatCount;i++) {
		if(strcmp(strCategories[i], cat_name, false)==0) {
			return true; //cat exist
		}
	}
	return false;//no cat founded that is named X
}
//Removes all categories
stock W3ClearCategory() {
	for(new i=0;i<CatCount;i++) {
		strcopy(strCategories[i],64,"");
	}
	CatCount = 0;
}

//Adds a new Category and returns true on success
stock bool:W3AddCategory(const String:cat_name[]) {
	if(CatCount<MAXCATS) {
		strcopy(strCategories[CatCount],64,cat_name);
		/*if(bCreateW3Cvar) {
			//Add a w3cvar for this cat
			decl String:buffer[FACTION_LENGTH],w3cvar;
			strcopy(buffer,sizeof(buffer),cat_name);
			ReplaceString(buffer,sizeof(buffer), " ", "_", false);
			Format(buffer,sizeof(buffer),"\"accessflag_%s\"",buffer);
			w3cvar = W3FindCvar(buffer);
			if(w3cvar==-1)
				w3cvar = W3CreateCvar(buffer,"0","Admin flag required to access this category");
			}
			iCategories[CatCount]=w3cvar;
		}*/
		CatCount++;
		return true;
	}
	W3Log("Too much categories!!! (%i/%i) - failed to add new category",CatCount,MAXCATS);
	return false;
}
//Returns a Category Name thing
stock W3GetCategory(iIndex,String:cat_name[],max_size) {
	decl String:buffer[FACTION_LENGTH];
	strcopy(buffer,sizeof(buffer),strCategories[iIndex]);
	ReplaceString(buffer,sizeof(buffer), "_", " ", false);
	strcopy(cat_name,max_size,buffer);
}
//Refreshes Categories
refreshCategories() {
	W3ClearCategory();
	//zeroth cat will not be drawn = perfect hidden cat ;D
	W3AddCategory("hidden");
	decl String:rcvar[64];
	decl racelist[MAXRACES];
	//Loop tru all _avaible_ races
	new racedisplay=W3GetRaceList(racelist);
	for(new i=0;i<racedisplay;i++)
	{
		new x=racelist[i];
		W3GetCvar(W3GetRaceCell(x,RaceCategorieCvar),rcvar,sizeof(rcvar));
		//To avoid multiple-same-named-categories we need to check if the category allready exist
		if(!W3IsCategory(rcvar)) {
			//Add a new category
			W3AddCategory(rcvar);
		}
	}
}
bool:IsCategorized() {
	return GetConVarBool(hUseCategories);
}
//Calls the forward
bool:CanDrawCategory(iClient,iCategoryIndex) {
	decl value;
	Call_StartForward(hCanDrawCat);
	Call_PushCell(iClient);
	Call_PushCell(iCategoryIndex);
	Call_Finish(value);
	if (value == 3 || value == 4)
		return false;
	return true;
}
public _:Native_GetCategoryName(Handle:plugin,numParams)
{
	SetNativeString(2, strCategories[GetNativeCell(1)], GetNativeCell(3), false);
}

