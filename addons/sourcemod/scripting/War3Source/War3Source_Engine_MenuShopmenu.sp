// War3Source_Engine_MenuShopmenu.sp

/*
public Plugin:myinfo=
{
	name="War3Source Menus Shopmenus",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};*/

new Handle:hUseCategorysCvar;
new String:buyTombSound[256]; //="war3source/tomes.mp3";

public War3Source_Engine_MenuShopmenu_OnPluginStart()
{
	hUseCategorysCvar=CreateConVar("war3_buyitems_category", "0", "Enable/Disable shopitem categorys", 0, true, 0.0, true, 1.0);
}

//public OnMapStart()
//{
	//strcopy(buyTombSound,sizeof(buyTombSound),"war3source/tomes.mp3");
	//War3_PrecacheSound(buyTombSound);
//}

public War3Source_Engine_MenuShopmenu_OnAddSound(sound_priority)
{
	if(sound_priority==PRIORITY_LOW)
	{
		strcopy(buyTombSound,sizeof(buyTombSound),"war3source/tomes.mp3");
		War3_AddSound("War3Source_Engine_MenuShopmenu",buyTombSound);
	}
}

public War3Source_Engine_MenuShopmenu_OnWar3Event(W3EVENT:event,client)
{
	if(event==DoShowShopMenu) {
		bool useCategory = GetConVarBool(hUseCategorysCvar);
		if (useCategory)
		ShowMenuShopCategory(client);
		else
		ShowMenuShop(client);
	}
	if(event==DoTriedToBuyItem) { //via say?
		//EventArg3 = item count
		int item=internal_W3GetVar(EventArg1);
		int itemcount=internal_W3GetVar(EventArg3);
		//DP("itemcount %d",itemcount);
		if(internal_GetItemIdByShortname("tome")==item)
			War3_TriedToBuyItem(client,item,internal_W3GetVar(EventArg2),itemcount); ///ALWAYS SET ARG2 before calling this event
		else
			War3_TriedToBuyItem(client,item,internal_W3GetVar(EventArg2)); ///ALWAYS SET ARG2 before calling this event
	}
	//if(event==TomesCallBack) { //via say?
		//War3_TriedToBuyItem(client,War3_GetItemIdByShortname("tome"),true,1,internal_W3GetVar(EventArg1));
	//}
}
new WantsToBuy[MAXPLAYERSCUSTOM];

ShowMenuShopCategory(client)
{
	//SetTrans(client);
	new Handle:shopMenu = CreateMenu(War3Source_ShopMenuCategory_Sel);
	SetMenuExitButton(shopMenu, true);
	new gold = GetPlayerProp(client, PlayerGold);

	//new ReservedGold = War3_ReservedGold(client);
	//gold = gold - ReservedGold;
	//if (gold<0)
	//	gold = 0;

	new String:title[300];
	Format(title,sizeof(title),"[War3Source:EVO] Select an item category to browse. You have %d/%d items",GetClientItemsOwned(client),iGetMaxShopitemsPerPlayer(client));

#if (GGAMETYPE == GGAME_TF2 || GGAMETYPE == GGAME_FOF)
	Format(title,sizeof(title),"%s\n \n Your current balance: %d/%d gold.",title, gold, W3GetMaxGold(client));
#elseif (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
	Format(title,sizeof(title),"%s\n \n %d/%d gold $%d money",title, gold, W3GetMaxGold(client),GetCSMoney(client));
#endif
	SetMenuTitle(shopMenu, title);

	Handle h_ItemCategorys = CreateArray(ByteCountToCells(64));
	char category[64];
	int ItemsLoaded = W3GetItemsLoaded();

	int raceid = GetRace(client);

	int RequiredRaceID=0;

	// find all possible categorys and fill the menu
	for(int x=1; x <= ItemsLoaded; x++)
	{
		RequiredRaceID=War3_GetItemProperty(x,ITEM_REQUIRED_RACE);
		if(RequiredRaceID>0 && raceid!=RequiredRaceID)
		{
			continue;
		}
		else
		{
			if(!W3IsItemDisabledGlobal(x) && !W3ItemHasFlag(x,"hidden"))
			{
				W3GetItemCategory(x, category, sizeof(category));

				if ((FindStringInArray(h_ItemCategorys, category) >= 0) || StrEqual(category, ""))
				continue;
				else
				PushArrayString(h_ItemCategorys, category);
			}
		}
	}

	// fill the menu with the categorys
	while(GetArraySize(h_ItemCategorys))
	{
		GetArrayString(h_ItemCategorys, 0, category, sizeof(category));

		AddMenuItem(shopMenu, category, category, ITEMDRAW_DEFAULT);
		RemoveFromArray(h_ItemCategorys, 0);
	}

	CloseHandle( h_ItemCategorys);
	DisplayMenu(shopMenu,client,20);
}

ShowMenuShop(client, const String:category[]="") {
	SetTrans(client);
	new Handle:shopMenu=CreateMenu(War3Source_ShopMenu_Selected);
	SetMenuExitButton(shopMenu,true);

	new gold=GetPlayerProp(client, PlayerGold);
	//new ReservedGold = War3_ReservedGold(client);
	//gold = gold - ReservedGold;
	//if (gold<0)
	//	gold = 0;


	new String:title[300];
	Format(title,sizeof(title),"[War3Source:EVO] Select an item to buy. You have %d/%d items",GetClientItemsOwned(client),iGetMaxShopitemsPerPlayer(client));
#if (GGAMETYPE == GGAME_TF2 || GGAMETYPE == GGAME_FOF)
	//Format(title,sizeof(title),"%s%T\n \n",title,"You have {amount} Gold",GetTrans(),gold);
	//Format(title,sizeof(title),"%s\n \n You have %i Gold and [%i] Reserved Gold.",title, gold, ReservedGold);
	Format(title,sizeof(title),"%s\n \n Your current balance: %d/%d gold.",title, gold, W3GetMaxGold(client));
#elseif (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
	Format(title,sizeof(title),"%s\n \n %d/%d gold $%d money",title, gold, W3GetMaxGold(client),GetCSMoney(client));
#endif

	SetMenuTitle(shopMenu,title);
	new String:itemname[64];
	new String:itembuf[4];
	new String:linestr[96];
	new String:itemcategory[64];
	new String:itemshortdesc[256];
	new cost;
	bool drawitemdisabled=false;
	new ItemsLoaded = totalItemsLoaded;
#if (GGAMETYPE == GGAME_TF2)
	bool SteamGroupRequired=false;
#endif
	bool useCategory = GetConVarBool(hUseCategorysCvar);
	//new BackButton=0;
	if (useCategory)
	{
		AddMenuItem(shopMenu,"-1","[Return to Categories]");
	}

	for(new x=1;x<=ItemsLoaded;x++)
	{
//		BackButton++;

/*		if (useCategory)
		{
			if(BackButton==1)
				{
					AddMenuItem(shopMenu,"-1","[Return to Categories]");
					ItemsLoaded=ItemsLoaded-1;
					//BackButton=0;
					continue;
				}
		}*/

		//if(W3RaceHasFlag(x,"hidden")){   //
		//	PrintToServer("hidden %d",x);
		//}
		//War3_TFIsItemClass has a internal GAMETF Checking.. if not GAMETF it auto returns true.
		// Create a back button every 7 items
#if (GGAMETYPE == GGAME_TF2)
		if(!internal_W3IsItemDisabledGlobal(x)&&!W3ItemHasFlag(x,"hidden")&&internal_War3_TFIsItemClass(x,TF2_GetPlayerClass(client)))
		{
#else
		if(!internal_W3IsItemDisabledGlobal(x)&&!W3ItemHasFlag(x,"hidden"))
		{
#endif
			W3GetItemCategory(x, itemcategory, sizeof(itemcategory));

			if ((!StrEqual(category, "") && StrEqual(category, itemcategory)) || (StrEqual(category, "")))
			{
				Format(itembuf,sizeof(itembuf),"%d",x);
				W3GetItemName(x,itemname,sizeof(itemname));
				cost=W3GetItemCost(client,x,W3IsItemCSmoney(x));
				if(GetOwnsItem(client,x)) {
					if(W3IsItemCSmoney(x)) {
						Format(linestr,sizeof(linestr),">%s - $%d",itemname,cost);
					}
					else {
						Format(linestr,sizeof(linestr),">%s - %d Gold",itemname,cost);
					}
				}
				else {
					if(W3IsItemCSmoney(x)) {
						Format(linestr,sizeof(linestr),"%s - $%d",itemname,cost);
					}
					else {
						Format(linestr,sizeof(linestr),"%s - %d Gold",itemname,cost);
					}
				}
#if (GGAMETYPE == GGAME_TF2)
				if(!bIsInSteamGroup[client]&&W3ItemHasFlag(x,"steamgroup"))
				{
					Format(linestr,sizeof(linestr),"%s *Steam Group Required*",linestr);
					//AddMenuItem(shopMenu,itembuf,linestr,ITEMDRAW_DISABLED);
					drawitemdisabled=true;
					SteamGroupRequired=true;
					//War3_ChatMessage(client,"Item %s requires you join our Steam Group.",itemname);
					//War3_ChatMessage("Sometimes we lose connection to the steam group, so please be patient.");
				}
				else
				{
					//AddMenuItem(crMenu,rbuf,rdisp,(minlevel<=W3GetTotalLevels(client)||StrEqual(steamid,"STEAM_0:1:35173666",false)?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
					if(W3ItemHasFlag(x,"steamgroup"))
					{
						Format(linestr,sizeof(linestr),"%s <Steam Group Enabled>",linestr);
					}
					//AddMenuItem(shopMenu,itembuf,linestr,(W3IsItemDisabledForRace(War3_GetRace(client),x) || W3IsItemDisabledGlobal(x) || War3_GetOwnsItem(client,x))?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
				}
#endif
//				AddMenuItem(shopMenu,itembuf,linestr,(W3IsItemDisabledForRace(War3_GetRace(client),x) || W3IsItemDisabledGlobal(x) || War3_GetOwnsItem(client,x))?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);

				W3GetItemShortdesc(x,itemshortdesc,sizeof(itemshortdesc));
				Format(linestr,sizeof(linestr),"%s\n%s",linestr,itemshortdesc);

				if(drawitemdisabled)
				{
					AddMenuItem(shopMenu,itembuf,linestr,ITEMDRAW_DISABLED);
					drawitemdisabled=false;
				}
				else
				{
					AddMenuItem(shopMenu,itembuf,linestr,(W3IsItemDisabledForRace(GetRace(client),x) || W3IsItemDisabledGlobal(x) || GetOwnsItem(client,x))?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
				}
			}
		}//
	}
#if (GGAMETYPE == GGAME_TF2)
	if(SteamGroupRequired)
	{
		War3_ChatMessage(client,"Please join our Steam Group.");
	}
#endif
	if (useCategory)
	{
		//AddMenuItem(shopMenu,"-1","[Return to Categories]");
	}
	DisplayMenu(shopMenu,client,20);
}

public War3Source_ShopMenu_Selected(Handle:menu,MenuAction:action,client,selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(ValidPlayer(client))
			{
				char SelectionInfo[4];
				char SelectionDispText[256];
				new SelectionStyle;
				GetMenuItem(menu,selection,SelectionInfo,sizeof(SelectionInfo),SelectionStyle, SelectionDispText,sizeof(SelectionDispText));
				new item=StringToInt(SelectionInfo);
				bool useCategory = GetConVarBool(hUseCategorysCvar);
				if(item==-1&&useCategory)
				{
					ShowMenuShopCategory(client);
				}
				else
				{
					War3_TriedToBuyItem(client,item,true);
				}

			}
		}
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
	}
}

public War3Source_ShopMenuCategory_Sel(Handle:menu, MenuAction:action, client, selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(ValidPlayer(client))
			{
				char SelectionInfo[64];
				char SelectionDispText[256];
				new SelectionStyle;
				GetMenuItem(menu, selection, SelectionInfo, sizeof(SelectionInfo), SelectionStyle, SelectionDispText,sizeof(SelectionDispText));

				ShowMenuShop(client, SelectionInfo);
			}
		}
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
	}
}

Handle war3_shop_tome_xp = null;

War3_TriedToBuyItem(client,item,bool:reshowmenu=true,tomecount=0) {
	//DP("itemcount inside triedtobuyitem %d",tomecount);
	if(item>0&&item<=totalItemsLoaded)
	{
		SetTrans(client);

		char itemname[64];
		GetItemName(item,itemname,sizeof(itemname));

		//new cred=War3_GetGold(client);
		//new ReservedGold = War3_ReservedGold(client);
		//cred = cred - ReservedGold;
		//if (cred<0)
		//	cred = 0;


		int money=GetCSMoney(client);
		int cost_num=GetItemCost(client,item,W3IsItemCSmoney(item));


		if(StrEqual(itemname,"tome of experience",false))
		{
			if(IsPlayerAlive(client)){
				War3_EmitSoundToAll(buyTombSound,client);
			}
			else{
				War3_EmitSoundToClient(client,"war3source/tomes.mp3");
			}
			int tomect = tomecount;
			if (tomect == 0)
			{
				//buy only 1 tome
				tomect=1;
			}
			if (tomect > 1)
			{
				int BankGold = War3_GetGoldBank(client);
				int bankplusgoldamount=BankGold+War3_GetGold(client);
				int TempCost=cost_num*tomect;
				if(TempCost>bankplusgoldamount)
				{
					War3_ChatMessage(client,"You do not have enough money on hand + in the bank to buy that many tomes!");
					return;
				}
				else
				{
					int boughtnum=0;
					for(int x=1;x<=tomect;x++)
					{
						if(BankGold >= cost_num)
						{
							if(War3_WithdrawGoldBank(client,cost_num,true))
							{
								BankGold=War3_GetGoldBank(client);
								boughtnum++;
							}
						}
					}
					if(boughtnum>0)
					{
						int WithdrewAmount=boughtnum*cost_num;
						War3_ChatMessage(client,"Withdrew {green}%d {default}Gold from bank. New Balance: {green}%d {default}Gold.",WithdrewAmount,War3_GetGoldBank(client));
						//tomect-=boughtnum;
					}
					if(tomect>1)
					{
						cost_num*=tomect;
					}
				}
				// withdraw


				// buy more than one tome
				Format(itemname,sizeof(itemname),"%d Tomes of Experience",tomect);
				//cost_num*=tomect;
			}
		}

		int cred=GetPlayerProp(client, PlayerGold);


		bool canbuy=true;

		internal_W3SetVar(EventArg1,item);
		canbuy=W3Denyable(DN_CanBuyItem1,client);

		int race=GetRace(client);
		if(internal_W3IsItemDisabledGlobal(item))
		{
			War3_ChatMessage(client,"%s is disabled",itemname);
			canbuy=false;
		}

		else if(W3IsItemDisabledForRace(race,item))
		{
			char racename[32];
			GetRaceName(race,racename,sizeof(racename));
			War3_ChatMessage(client,"You may not purchase %s when you are %s",itemname,racename);
			canbuy=false;
		}
		else if(GetOwnsItem(client,item))
		{
			War3_ChatMessage(client,"You already own %s",itemname);
			canbuy=false;
		}
		else if((W3IsItemCSmoney(item)?money:cred)<cost_num)
		{
			War3_ChatMessage(client,"You cannot afford %s",itemname);
			if(W3IsItemCSmoney(item)==false)
				War3_ChatMessage(client,"You have %i Gold. It costs %i Gold.",cred,cost_num);
			if(reshowmenu && !IsFakeClient(client)) {
			bool useCategory = GetConVarBool(hUseCategorysCvar);
			if (useCategory)
				ShowMenuShopCategory(client);
			else
				ShowMenuShop(client);
			}
			canbuy=false;
		}
		if(canbuy) {
			internal_W3SetVar(EventArg1,item);
			internal_W3SetVar(EventArg2,1);
			DoFwd_War3_Event(CanBuyItem,client);
			if(internal_W3GetVar(EventArg2)==0) {
				canbuy=false;
			}
		}
		//if its use instantly then let them buy it
		//items maxed out
		if(canbuy&&!War3_GetItemProperty(item,ITEM_USED_ON_BUY)&&GetClientItemsOwned(client)>=iGetMaxShopitemsPerPlayer(client)) {
			canbuy=false;
			WantsToBuy[client]=item;
			//DP("Max Item");

			War3M_ExceededMaxItemsMenuBuy(client);

		}

		if(canbuy) {
			if(W3IsItemCSmoney(item)) {
				SetCSMoney(client,money-cost_num);
			}
			else {
				//cred = cred + ReservedGold;
				//War3_SetGold(client,cred-cost_num);
				SetPlayerProp(client, PlayerGold, (cred-cost_num));
			}
			War3_ChatMessage(client,"You have successfully purchased %s",itemname);

			if(tomecount>1)
			{
				//int race=GetRace(client);
				if(war3_shop_tome_xp==null)
				{
					war3_shop_tome_xp = FindConVar("war3_shop_tome_xp");
				}
				int add_xp=GetConVarInt(war3_shop_tome_xp);
				if(add_xp<0)	add_xp=0;
				bool SteamCheck=false;

#if (GGAMETYPE == GGAME_TF2)
				if(add_xp!=0&&bIsInSteamGroup[client])
				{
					add_xp=add_xp*2;
					SteamCheck=true;
				}
#endif
				if(add_xp!=0&&ValidPlayer(client))
				{
					new AdminId:AdminID = GetUserAdmin(client);
					if (AdminID!=INVALID_ADMIN_ID)
					{
						if(GetAdminFlag(GetUserAdmin(client), Admin_Reservation))
						{
							//VIP
							if(SteamCheck)
								add_xp=add_xp*2; // Double more!  Which makes 4x
							else
								add_xp=add_xp*4; // Double more!  Which makes 4x
						}
					}
				}

				add_xp*=tomecount; //# of tomes
				SetXP(client,race,GetXP(client,race)+add_xp);
				W3DoLevelCheck(client);
				SetOwnsItem(client,item,false);
				War3_ChatMessage(client,"+{amount} XP",add_xp);
				War3_ShowXP(client);
				//DP("first");
			}
			else
			{
				internal_W3SetVar(TheItemBoughtOrLost,item);
				DoFwd_War3_Event(DoForwardClientBoughtItem,client); //old item//forward, and set has item true inside
				//DP("Last");
			}
		}
	}
}

War3M_ExceededMaxItemsMenuBuy(client)
{
	SetTrans(client);
	new Handle:hMenu=CreateMenu(OnSelectExceededMaxItemsMenuBuy);
	SetMenuExitButton(hMenu,true);

	char itemname[64];
	W3GetItemName(WantsToBuy[client],itemname,sizeof(itemname));

	SetMenuTitle(hMenu,"[War3Source:EVO] You already have a max of %d items. Choose an item to replace with %s. You will not get gold back",iGetMaxShopitemsPerPlayer(client),itemname);

	char itembuf[4];
	char linestr[96];
	int ItemsLoaded = totalItemsLoaded;
	for(int x=1;x<=ItemsLoaded;x++)
	{
		if(GetOwnsItem(client,x)) {
			Format(itembuf,sizeof(itembuf),"%d",x);
			W3GetItemName(x,itemname,sizeof(itemname));

			Format(linestr,sizeof(linestr),"%s",itemname);
			AddMenuItem(hMenu,itembuf,linestr);
		}
	}
	DisplayMenu(hMenu,client,20);
}
public OnSelectExceededMaxItemsMenuBuy(Handle:menu,MenuAction:action,client,selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(ValidPlayer(client))
			{
				SetTrans(client);
				char SelectionInfo[4];
				char SelectionDispText[256];
				int SelectionStyle;
				GetMenuItem(menu,selection,SelectionInfo,sizeof(SelectionInfo),SelectionStyle, SelectionDispText,sizeof(SelectionDispText));
				int itemtolose=StringToInt(SelectionInfo);
				if(itemtolose>0&&itemtolose<=totalItemsLoaded)
				{
					//check he can afford new item
					int cred=GetPlayerProp(client, PlayerGold);
					int money=GetCSMoney(client);
					//new ReservedGold = War3_ReservedGold(client);
					//cred = cred - ReservedGold;
					//if (cred<0)
					//	cred = 0;

					int cost_num=W3GetItemCost(client,WantsToBuy[client],W3IsItemCSmoney(WantsToBuy[client]));
					char itemname[64];
					GetItemName(WantsToBuy[client],itemname,sizeof(itemname));

					if((W3IsItemCSmoney(WantsToBuy[client])?money:cred)<cost_num) {
						War3_ChatMessage(client,"You cannot afford %s",itemname);
						if(W3IsItemCSmoney(WantsToBuy[client])==false)
							War3_ChatMessage(client,"Your current balance on hand is %d/%d Gold.",cred,W3GetMaxGold(client));
							//War3_ChatMessage(client,"You have %d/%d Gold and [%d] Reserved Gold.",cred,W3GetMaxGold(client),ReservedGold);
						bool useCategory = GetConVarBool(hUseCategorysCvar);
						if (useCategory)
							ShowMenuShopCategory(client);
						else
							ShowMenuShop(client);
					}
					else {
						internal_W3SetVar(TheItemBoughtOrLost,itemtolose);
						DoFwd_War3_Event(DoForwardClientLostItem,client); //old item


						if(W3IsItemCSmoney(WantsToBuy[client])) {
							SetCSMoney(client,money-cost_num);
						}
						else {
							//cred = cred + ReservedGold;
							War3_SetGold(client,cred-cost_num);
						}
						War3_ChatMessage(client,"You have successfully purchased %s",itemname);

						internal_W3SetVar(TheItemBoughtOrLost,WantsToBuy[client]);
						DoFwd_War3_Event(DoForwardClientBoughtItem,client); //old item
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
