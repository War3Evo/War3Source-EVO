// War3Source_Engine_MenuShopmenu3.sp

//#assert GGAMEMODE == MODE_WAR3SOURCE


//new Handle:hShopMenu2RequiredFlag;

/*
public Plugin:myinfo=
{
	name="War3Source Menus Shopmenus 3",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};
*/

public War3Source_Engine_MenuShopmenu3_OnPluginStart()
{
	//LoadTranslations("w3s.shopmenu2.phrases");
	W3CreateCvar("w3shop3menu","loaded","is the shop3 loaded");
	//hShopMenu2RequiredFlag=CreateConVar("war3_shopmenu2_flag","0","Flag(or 0 to disable) which is required to access shopmenu2. Flag name (like kick)");
}

//flag to access shop 2
/*
stock bool:HasRequiredFlag2(client) {
	decl String:buffer[4];
	GetConVarString(hShopMenu2RequiredFlag,buffer,sizeof(buffer));
	new AdminFlag:flag;
	if(FindFlagByName(buffer, flag)) {
		if(HasSMAccess(client,FlagToBit(flag))) {
			return true;
		}
		return false;
	}
	return true;
}
*/

new WantsToBuy3[MAXPLAYERSCUSTOM];

ShowMenu3ShopCategory(client)
{
	new Handle:shopMenu = CreateMenu(War3Source_ShopMenu3Category_Sel);
	SetMenuExitButton(shopMenu, true);
	new platinum = War3_GetPlatinum(client);

	new String:title[300];
	Format(title,sizeof(title),"\nSelect an item category to browse. You have %d/%d items",GetClientItems3Owned(client),GetMaxShopitems3PerPlayer());

	Format(title,sizeof(title),"%s\n \n You have %i Platinum.",title, platinum);

	new String:racename[32];
	new race=GetRace(client);
	GetRaceName(race,racename,sizeof(racename));

	Format(title,sizeof(title),"%s\n Current job: %s\n",title, racename);
	Format(title,sizeof(title),"%s\n GEMS BOUGHT WILL BE BOUND TO YOUR CURRENT RACE!!!\n",title);
	Format(title,sizeof(title),"%s\n GEMS BOUGHT WILL BE BOUND TO YOUR CURRENT RACE!!!\n",title);
	SetMenuTitle(shopMenu, title);

	new Handle:h_ItemCategorys = CreateArray(ByteCountToCells(64));
	decl String:category[64];
	new ItemsLoaded = W3GetItems3Loaded();

	// find all possible categorys and fill the menu
	for(new x=1; x <= ItemsLoaded; x++)
	{
		if(!W3IsItem3DisabledGlobal(x) && !W3Item3HasFlag(x,"hidden"))
		{
			W3GetItem3Category(x, category, sizeof(category));

			if ((FindStringInArray(h_ItemCategorys, category) >= 0) || StrEqual(category, ""))
			continue;
			else
			PushArrayString(h_ItemCategorys, category);
		}
	}

	// fill the menu with the categorys
	while(GetArraySize(h_ItemCategorys))
	{
		GetArrayString(h_ItemCategorys, 0, category, sizeof(category));

		if(StrEqual(category,"Red"))
		{
			AddMenuItem(shopMenu, category, "Red - raw power/offense", ITEMDRAW_DEFAULT);
		}
		else if(StrEqual(category,"Yellow"))
		{
			AddMenuItem(shopMenu, category, "Yellow - modifiers", ITEMDRAW_DEFAULT);
		}
		else if(StrEqual(category,"Blue"))
		{
			AddMenuItem(shopMenu, category, "Blue - recovery", ITEMDRAW_DEFAULT);
		}
		else if(StrEqual(category,"Orange"))
		{
			AddMenuItem(shopMenu, category, "Orange - matching red and yellow", ITEMDRAW_DEFAULT);
		}
		else if(StrEqual(category,"Green"))
		{
			AddMenuItem(shopMenu, category, "Green - matching yellow and blue", ITEMDRAW_DEFAULT);
		}
		else if(StrEqual(category,"Purple"))
		{
			AddMenuItem(shopMenu, category, "Purple - matching blue and red", ITEMDRAW_DEFAULT);
		}
		else
		{
			AddMenuItem(shopMenu, category, category, ITEMDRAW_DEFAULT);
		}

		RemoveFromArray(h_ItemCategorys, 0);
	}

	CloseHandle( h_ItemCategorys);

	DisplayMenu(shopMenu,client,MENU_TIME_FOREVER);
}

public War3Source_ShopMenu3Category_Sel(Handle:menu, MenuAction:action, client, selection)
{
	if(action==MenuAction_Select)
	{
		if(ValidPlayer(client))
		{
			decl String:SelectionInfo[64];
			decl String:SelectionDispText[256];
			new SelectionStyle;
			GetMenuItem(menu, selection, SelectionInfo, sizeof(SelectionInfo), SelectionStyle, SelectionDispText,sizeof(SelectionDispText));

			ShowMenu3Shop3(client, SelectionInfo);
		}
	}
	if(action==MenuAction_End)
	{
		CloseHandle(menu);
	}
}


ShowMenu3Shop3(client, const String:category[]=""){
	new Handle:shopMenu3=CreateMenu(Show_Menu3Itemsinfo3Selected3);
	SetMenuExitButton(shopMenu3,true);
	new Platinum=War3_GetPlatinum(client);

	new String:title[300];

	if(!StrEqual(category, ""))
		Format(title,sizeof(title),"\nSelect an [%s] item to buy. You have %d/%d items",category,GetClientItems3Owned(client),GetMaxShopitems3PerPlayer());
	else
		Format(title,sizeof(title),"\nSelect an item to buy. You have %d/%d items",GetClientItems3Owned(client),GetMaxShopitems3PerPlayer());

	new String:racename[32];
	new race=GetRace(client);
	GetRaceName(race,racename,sizeof(racename));

	Format(title,sizeof(title),"%s\n \n You have %d Platinum\n",title,Platinum);

	Format(title,sizeof(title),"%s\n Current job: %s\n",title, racename);

	Format(title,sizeof(title),"%s\n GEMS BOUGHT WILL BE BOUND TO YOUR CURRENT RACE!!!\n",title);
	Format(title,sizeof(title),"%s\n GEMS BOUGHT WILL BE BOUND TO YOUR CURRENT RACE!!!\n",title);
	//Format(title,sizeof(title),"%s\n",title,category);

	SetMenuTitle(shopMenu3,title);
	decl String:itemname3[64];
	decl String:itembuf3[4];
	decl String:linestr3[96];
	decl String:itemcategory[64];
	decl cost;
	new Items3Loaded = W3GetItems3Loaded();

	AddMenuItem(shopMenu3,"-1","[Return to Categories]");

	//DP("Items2Loaded = %i",Items2Loaded);
	for(new x=1;x<=Items3Loaded;x++)
	{
		//if(W3RaceHasFlag(x,"hidden")){
		//	PrintToServer("hidden %d",x);
		//}
			//if(!W3IsItem3DisabledGlobal(x)&&!W3Item3HasFlag(x,"hidden")){
		if(!W3IsItem3DisabledGlobal(x)&&!W3Item3HasFlag(x,"hidden"))
		{
			W3GetItem3Category(x, itemcategory, sizeof(itemcategory));

			if ((!StrEqual(category, "") && StrEqual(category, itemcategory)) || (StrEqual(category, "")))
			{
				new war3e=1;
				if(war3e==1)
				{
					Format(itembuf3,sizeof(itembuf3),"%d",x);
					W3GetItem3Name(x,itemname3,sizeof(itemname3));
					//DP("W3GetItem3Name = %s",itemname3);
					cost=W3GetItem3Cost(x);
					//DP("W3GetItem3Cost = %i",cost);
					if(War3_GetOwnsItem3(client,race,x))
					{
						Format(linestr3,sizeof(linestr3),">%s - %d Platinum",itemname3,cost);
					}
					else
					{
						Format(linestr3,sizeof(linestr3),"%s - %d Platinum",itemname3,cost);
					}
					//AddMenuItem(shopMenu3,itembuf3,linestr3,(W3IsItem3DisabledForRace(GetRace(client),x) || W3IsItem3DisabledGlobal(x) || War3_GetOwnsItem3(client,x))?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
					if(Platinum>=cost)
						AddMenuItem(shopMenu3,itembuf3,linestr3,War3_GetOwnsItem3(client,race,x)?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
					else
						AddMenuItem(shopMenu3,itembuf3,linestr3,ITEMDRAW_DISABLED);
				}
			}
		}
	}
	AddMenuItem(shopMenu3,"-1","[Return to Categories]");

	DisplayMenu(shopMenu3,client,MENU_TIME_FOREVER);
}

public War3Source_ShopMenu3_Selected(Handle:menu,MenuAction:action,client,selection)
{
	if(action==MenuAction_Select)
	{
		if(ValidPlayer(client))
		{
			decl String:SelectionInfo[16];
			decl String:SelectionDispText[256];
			new SelectionStyle;
			GetMenuItem(menu,selection,SelectionInfo,sizeof(SelectionInfo),SelectionStyle, SelectionDispText,sizeof(SelectionDispText));
			new String:exploded[2][16];
			ExplodeString(SelectionInfo, ",", exploded, 2, 15);
			new item=StringToInt(exploded[0]);
			new checknum=StringToInt(exploded[1]);
			if(checknum==-1)
			{
				decl String:category[64];
				W3GetItem3Category(item, category, sizeof(category));

				ShowMenu3Shop3(client, category);
			}
			else
			{
				InternalTriedToBuyItem3(client,item,true);
			}

		}
	}
	if(action==MenuAction_End)
	{
		CloseHandle(menu);
	}
}
InternalTriedToBuyItem3(client,item,bool:reshowmenu=true){
	if(item>0&&item<=W3GetItems3Loaded())
	{
		decl String:itemname3[64];
		W3GetItem3Name(item,itemname3,sizeof(itemname3));

		new race=GetRace(client);


		new cred=War3_GetPlatinum(client);
		new cost_num=W3GetItem3Cost(item);

		new bool:canbuy=true;

		if(W3IsItem3DisabledGlobal(item)){
			War3_ChatMessage(client,"%s is disabled",itemname3);
			canbuy=false;
		}
		else if(W3IsItem3DisabledForRace(race,item)){

			new String:racename3[32];
			GetRaceName(race,racename3,sizeof(racename3));
			War3_ChatMessage(client,"You may not purchase %s when you are %s",itemname3,racename3);
			canbuy=false;
		}
		else if(War3_GetOwnsItem3(client,race,item)){
			War3_ChatMessage(client,"You already own %s",itemname3);
			canbuy=false;
		}
		else if(cred<cost_num){
			War3_ChatMessage(client,"You cannot afford %s",itemname3);
			if(reshowmenu){
				ShowMenu3ShopCategory(client);
			}
			canbuy=false;
		}
//		if(canbuy){
//			W3SetVar(EventArg1,item);
//			W3SetVar(EventArg2,1);
//			W3SetVar(EventArg3,race);
//			W3CreateEvent(CanBuyItem,client);
//			if(W3GetVar(EventArg2)==0){
//				canbuy=false;
//			}
//		}
		//if its use instantly then let them buy it
		//items maxed out
		//if(canbuy&&!War3_GetItemProperty(item,ITEM_USED_ON_BUY)&&GetClientItems3Owned(client)>=GetMaxShopitems3PerPlayer()){

		else if(canbuy&&W3ItemCategoryExist(client,race,item))
		{
			canbuy=false;
			WantsToBuy3[client]=item;
			InternalGemSlotItemsMenuBuy(client);
			//DP("Trigger InternalAlreadyHaveGemSlotItemsMenuBuy");
		}
		else if(canbuy&&GetClientItems3Owned(client)>=GetMaxShopitems3PerPlayer())
		{
			canbuy=false;
			WantsToBuy3[client]=item;
			InternalExceededMaxItemsMenu3Buy(client);

		}

		if(canbuy){
			War3_SetPlatinum(client,cred-cost_num);

			War3_ChatMessage(client,"You have successfully purchased %s",itemname3);


			internal_W3SetVar(TheItemBoughtOrLost,item);
			internal_W3SetVar(TheRaceItemBoughtOrLost,race);
			DoFwd_War3_Event(DoForwardClientBoughtItem3,client); //old item//forward, and set has item true inside

			//W3SetItem3ExpireTime(client,item,NOW()+3600);
			//W3SaveItem3ExpireTime(client,item);
		}
	}
}

InternalGemSlotItemsMenuBuy(client)
{
	new Handle:hInternalMenu=CreateMenu(OnSelectAlreadyHaveGemSlotItemsMenuBuy);
	SetMenuExitButton(hInternalMenu,true);

	new race=GetRace(client);


	//SetMenuTitle(hInternalMenu,"You already have a %s item.\nChoose an item to replace with %s.\nYou will not get Platinum back!",categorySTR,itemname3);

	decl String:itemname3[64];
	decl String:itembuf3[4];
	decl String:linestr3[96];
	decl String:TmpStr[32];
	new bool:display=false;
	AddMenuItem(hInternalMenu,"-1","[Return to Categories]");

	if(W3CompareTwoItemCategories(WantsToBuy3[client],War3_GetItemId1(client,race))==true&&War3_GetOwnsItem3(client,race,War3_GetItemId1(client,race)))
	{
			Format(itembuf3,sizeof(itembuf3),"%d",War3_GetItemId1(client,race));
			W3GetItem3Name(War3_GetItemId1(client,race),itemname3,sizeof(itemname3));

			W3GetItem3Category(War3_GetItemId1(client,race),TmpStr,31);
			Format(linestr3,sizeof(linestr3),"[%s] - %s",TmpStr,itemname3);
			AddMenuItem(hInternalMenu,itembuf3,linestr3);
			display=true;
	}
	if(W3CompareTwoItemCategories(WantsToBuy3[client],War3_GetItemId2(client,race))==true&&War3_GetOwnsItem3(client,race,War3_GetItemId2(client,race)))
	{
			Format(itembuf3,sizeof(itembuf3),"%d",War3_GetItemId2(client,race));
			W3GetItem3Name(War3_GetItemId2(client,race),itemname3,sizeof(itemname3));

			W3GetItem3Category(War3_GetItemId2(client,race),TmpStr,31);
			Format(linestr3,sizeof(linestr3),"[%s] - %s",TmpStr,itemname3);
			AddMenuItem(hInternalMenu,itembuf3,linestr3);
			display=true;
	}
	if(W3CompareTwoItemCategories(WantsToBuy3[client],War3_GetItemId3(client,race))==true&&War3_GetOwnsItem3(client,race,War3_GetItemId3(client,race)))
	{
			Format(itembuf3,sizeof(itembuf3),"%d",War3_GetItemId3(client,race));
			W3GetItem3Name(War3_GetItemId3(client,race),itemname3,sizeof(itemname3));

			W3GetItem3Category(War3_GetItemId3(client,race),TmpStr,31);
			Format(linestr3,sizeof(linestr3),"[%s] - %s",TmpStr,itemname3);
			AddMenuItem(hInternalMenu,itembuf3,linestr3);
			display=true;
	}

	decl String:categorySTR[32];

	W3GetItem3Category(WantsToBuy3[client],categorySTR,31);

	W3GetItem3Name(WantsToBuy3[client],itemname3,63);

	if(display)
		SetMenuTitle(hInternalMenu,"You already have a [%s] item.\nChoose an item to replace with [%s] %s.\nYou will not get Platinum back!",categorySTR,categorySTR,itemname3);
	else
		SetMenuTitle(hInternalMenu,"You can only have one [%s] item per job.",categorySTR);

	//DP("Display Menu");
	DisplayMenu(hInternalMenu,client,MENU_TIME_FOREVER);
}

public OnSelectAlreadyHaveGemSlotItemsMenuBuy(Handle:menu,MenuAction:action,client,selection)
{
	if(action==MenuAction_Select)
	{
		if(ValidPlayer(client))
		{
			decl String:SelectionInfo3[4];
			decl String:SelectionDispText3[256];
			new SelectionStyle3;
			GetMenuItem(menu,selection,SelectionInfo3,sizeof(SelectionInfo3),SelectionStyle3, SelectionDispText3,sizeof(SelectionDispText3));
			new item=StringToInt(SelectionInfo3);
			if(item==-1)
			{
				ShowMenu3ShopCategory(client);
			}
			else if(item>0&&item<=W3GetItems3Loaded())
			{

				new cred=War3_GetPlatinum(client);
				new cost_num=W3GetItem3Cost(WantsToBuy3[client]);
				decl String:itemname3[64];
				W3GetItem3Name(WantsToBuy3[client],itemname3,sizeof(itemname3));


				if(cred<cost_num){
					War3_ChatMessage(client,"You cannot afford %s",itemname3);
					ShowMenu3Shop3(client);
				}
				else{
					internal_W3SetVar(TheItemBoughtOrLost,item);
					internal_W3SetVar(TheRaceItemBoughtOrLost,GetRace(client));
					DoFwd_War3_Event(DoForwardClientLostItem3,client); //old item



					War3_SetPlatinum(client,cred-cost_num);

					War3_ChatMessage(client,"You have successfully purchased %s",itemname3);

					internal_W3SetVar(TheItemBoughtOrLost,WantsToBuy3[client]);
					internal_W3SetVar(TheRaceItemBoughtOrLost,GetRace(client));
					DoFwd_War3_Event(DoForwardClientBoughtItem3,client); //old item
				}
			}
		}
	}
}


InternalExceededMaxItemsMenu3Buy(client)
{
	new Handle:hMenu=CreateMenu(OnSelectExceededMaxItemsMenu3Buy);
	SetMenuExitButton(hMenu,true);

	decl String:itemname3[64];
	//W3GetItem3Name(WantsToBuy3[client],itemname3,sizeof(itemname3));

	//SetMenuTitle(hMenu,"You already have a max of %d items. Choose an item to replace with %s. You will not get Platinum back",GetMaxShopitems3PerPlayer(),itemname3);

	new bool:itemsexists=false;

	decl String:itembuf3[4];
	decl String:linestr3[96];
	decl String:TmpStr[32];
	new race=GetRace(client);

	AddMenuItem(hMenu,"-1","[Return to Categories]");

	//if(W3CompareItemCategories(WantsToBuy3[client],War3_GetItemId1(client,race))==false&&War3_GetOwnsItem3(client,race,War3_GetItemId1(client,race)))
	if(War3_GetOwnsItem3(client,race,War3_GetItemId1(client,race)))
	{
			Format(itembuf3,sizeof(itembuf3),"%d",War3_GetItemId1(client,race));
			W3GetItem3Name(War3_GetItemId1(client,race),itemname3,sizeof(itemname3));

			W3GetItem3Category(War3_GetItemId1(client,race),TmpStr,31);
			Format(linestr3,sizeof(linestr3),"[%s] - %s",TmpStr,itemname3);
			AddMenuItem(hMenu,itembuf3,linestr3);
			//display=true;
			itemsexists=true;
	}
	//if(W3CompareItemCategories(WantsToBuy3[client],War3_GetItemId2(client,race))==false&&War3_GetOwnsItem3(client,race,War3_GetItemId2(client,race)))
	if(War3_GetOwnsItem3(client,race,War3_GetItemId2(client,race)))
	{
			Format(itembuf3,sizeof(itembuf3),"%d",War3_GetItemId2(client,race));
			W3GetItem3Name(War3_GetItemId2(client,race),itemname3,sizeof(itemname3));

			W3GetItem3Category(War3_GetItemId2(client,race),TmpStr,31);
			Format(linestr3,sizeof(linestr3),"[%s] - %s",TmpStr,itemname3);
			AddMenuItem(hMenu,itembuf3,linestr3);
			//display=true;
			itemsexists=true;
	}
	//if(W3CompareItemCategories(WantsToBuy3[client],War3_GetItemId3(client,race))==false&&War3_GetOwnsItem3(client,race,War3_GetItemId3(client,race)))
	if(War3_GetOwnsItem3(client,race,War3_GetItemId3(client,race)))
	{
			Format(itembuf3,sizeof(itembuf3),"%d",War3_GetItemId3(client,race));
			W3GetItem3Name(War3_GetItemId3(client,race),itemname3,sizeof(itemname3));

			W3GetItem3Category(War3_GetItemId3(client,race),TmpStr,31);
			Format(linestr3,sizeof(linestr3),"[%s] - %s",TmpStr,itemname3);
			AddMenuItem(hMenu,itembuf3,linestr3);
			//display=true;
			itemsexists=true;
	}

	decl String:categorySTR[32];
	W3GetItem3Category(WantsToBuy3[client],categorySTR,31);

	if(itemsexists)
		SetMenuTitle(hMenu,"You already have a max of %d items.\nChoose an item to replace with [%s] %s.\nYou will not get Platinum back",GetMaxShopitems3PerPlayer(),categorySTR,itemname3);
	else
		SetMenuTitle(hMenu,"You can only have one [%s] item per job.",categorySTR);


	/*
	new ItemsLoaded = W3GetItems3Loaded()
	new race=GetRace(client);
	for(new x=1;x<=ItemsLoaded;x++)
	{
		if(War3_GetOwnsItem3(client,race,x)){
			Format(itembuf3,sizeof(itembuf3),"%d",x);
			W3GetItem3Name(x,itemname3,sizeof(itemname3));

			W3GetItem3Category(x,TmpStr,31);
			Format(linestr3,sizeof(linestr3),"[%s] - %s",TmpStr,itemname3);
			AddMenuItem(hMenu,itembuf3,linestr3);
		}
	}
	*/
	DisplayMenu(hMenu,client,MENU_TIME_FOREVER);
}
public OnSelectExceededMaxItemsMenu3Buy(Handle:menu,MenuAction:action,client,selection)
{
	if(action==MenuAction_Select)
	{
		if(ValidPlayer(client))
		{
			decl String:SelectionInfo3[4];
			decl String:SelectionDispText3[256];
			new race=GetRace(client);
			new SelectionStyle3;
			GetMenuItem(menu,selection,SelectionInfo3,sizeof(SelectionInfo3),SelectionStyle3, SelectionDispText3,sizeof(SelectionDispText3));
			new item=StringToInt(SelectionInfo3);
			if(item==-1)
			{
				ShowMenu3ShopCategory(client);
			}
			else if(W3ItemCategoryExist(client,race,WantsToBuy3[client]))
			{
				InternalGemSlotItemsMenuBuy(client);
			}
			else if(item>0&&item<=W3GetItems3Loaded())
			{

				new cred=War3_GetPlatinum(client);
				new cost_num=W3GetItem3Cost(WantsToBuy3[client]);
				decl String:itemname3[64];
				W3GetItem3Name(WantsToBuy3[client],itemname3,sizeof(itemname3));


				if(cred<cost_num){
					War3_ChatMessage(client,"You cannot afford %s",itemname3);
					ShowMenu3Shop3(client);
				}
				else{
					internal_W3SetVar(TheItemBoughtOrLost,item);
					internal_W3SetVar(TheRaceItemBoughtOrLost,GetRace(client));
					DoFwd_War3_Event(DoForwardClientLostItem3,client); //old item



					War3_SetPlatinum(client,cred-cost_num);

					War3_ChatMessage(client,"You have successfully purchased %s",itemname3);

					internal_W3SetVar(TheItemBoughtOrLost,WantsToBuy3[client]);
					internal_W3SetVar(TheRaceItemBoughtOrLost,GetRace(client));
					DoFwd_War3_Event(DoForwardClientBoughtItem3,client); //old item
				}
			}
		}
	}
}

public War3Source_Engine_MenuShopmenu3_OnWar3Event(W3EVENT:event,client)
{
	if(event==DoShowShopMenu3){
		ShowMenu3ShopCategory(client);
		}

	if(event==DoTriedToBuyItem3){ //via say?
		InternalTriedToBuyItem3(client,W3GetVar(EventArg1),W3GetVar(EventArg2)); ///ALWAYS SET ARG2 before calling this event
	}
	if(event==DoShowPlayerItems3OwnTarget){
		new target = W3GetVar(EventArg1);
		if(ValidPlayer(target,false)) {
			War3_playertargetItemMenu3(client,target) ;
		}
	}
}


	// race items menu
War3_playertargetItemMenu3(client,target){
		//DP("War3_playertargetItemMenu3");

		new Handle:hMenu=CreateMenu(War3_playertargetItemMenu3Selected3);
		SetMenuExitButton(hMenu,true);

		new String:title[3000];

		// Items info
		//if(client==target)
		//{
		new String:racename[32];
		new race=GetRace(target);
		GetRaceName(race,racename,sizeof(racename));
		new String:playername[128];
		GetClientName(target,playername,127);

		Format(title,sizeof(title),"\nInformation for %s\n \n%s has:\n \n",playername,racename);

		//Format(title,sizeof(title),"%s\n \n",title);

		new String:itemname[64];
		//Format(title,sizeof(title),"%s\n \n",title);

		//new Items3Loaded = W3GetItems3Loaded();
		new itemxp;
		new itemMaxXp;
		new itemlvl;
		new maxlvl;
		new String:TmpStr[32];

		new itemid1=War3_GetItemId1(target,race);
		new itemid2=War3_GetItemId2(target,race);
		new itemid3=War3_GetItemId3(target,race);



		//one
		if(War3_GetOwnsItem3(target,race,itemid1))
		{
			W3GetItem3Name(itemid1,itemname,sizeof(itemname));
			W3GetItem3Category(itemid1,TmpStr,31);
			Format(title,sizeof(title),"%s\n[%s] - %s",title,TmpStr,itemname);
			itemlvl=War3_GetItemLevel(target, race, itemid1);
			maxlvl=W3GetItem3maxlevel1(itemid1);
			W3GetItem3levelName(itemid1,TmpStr,31,skill1);
			if(itemlvl==maxlvl)
				Format(title,sizeof(title),"%s\n%s: lvl %d/%d\n\n",title,TmpStr,itemlvl,maxlvl);
			else
			{
				itemxp=War3_GetItemXP(target, race, itemid1);
				itemMaxXp=W3GetReqXP(itemlvl+1);
				Format(title,sizeof(title),"%s\n%s: lvl %d/%d xp: %d/%d\n\n",title,TmpStr,itemlvl,maxlvl,itemxp,itemMaxXp);
			}
			maxlvl=W3GetItem3maxlevel2(itemid1);
			if(maxlvl>0)
			{
				itemlvl=War3_GetItemLevel2(target, race, itemid1);
				maxlvl=W3GetItem3maxlevel2(itemid1);
				W3GetItem3levelName(itemid1,TmpStr,31,skill2);
				if(itemlvl==maxlvl)
					Format(title,sizeof(title),"%s\n%s: lvl %d/%d\n\n",title,TmpStr,itemlvl,maxlvl);
				else
				{
					itemxp=War3_GetItemXP2(target, race, itemid1);
					itemMaxXp=W3GetReqXP(itemlvl+1);
					Format(title,sizeof(title),"%s\n%s: lvl %d/%d xp: %d/%d\n\n",title,TmpStr,itemlvl,maxlvl,itemxp,itemMaxXp);
				}
			}
			Format(title,sizeof(title),"%s\n \n",title);
			Format(title,sizeof(title),"%s\n \n",title);
		}
		//two
		if(War3_GetOwnsItem3(target,race,itemid2))
		{
			W3GetItem3Name(itemid2,itemname,sizeof(itemname));
			W3GetItem3Category(itemid2,TmpStr,31);
			Format(title,sizeof(title),"%s\n[%s] - %s",title,TmpStr,itemname);
			itemlvl=War3_GetItemLevel(target, race, itemid2);
			maxlvl=W3GetItem3maxlevel1(itemid2);
			W3GetItem3levelName(itemid2,TmpStr,31,skill1);
			if(itemlvl==maxlvl)
				Format(title,sizeof(title),"%s\n%s: lvl %d/%d\n\n",title,TmpStr,itemlvl,maxlvl);
			else
			{
				itemxp=War3_GetItemXP(target, race, itemid2);
				itemMaxXp=W3GetReqXP(itemlvl+1);
				Format(title,sizeof(title),"%s\n%s: lvl %d/%d xp: %d/%d\n\n",title,TmpStr,itemlvl,maxlvl,itemxp,itemMaxXp);
			}
			maxlvl=W3GetItem3maxlevel2(itemid2);
			if(maxlvl>0)
			{
				itemlvl=War3_GetItemLevel2(target, race, itemid2);
				maxlvl=W3GetItem3maxlevel2(itemid2);
				W3GetItem3levelName(itemid2,TmpStr,31,skill2);
				if(itemlvl==maxlvl)
					Format(title,sizeof(title),"%s\n%s: lvl %d/%d\n\n",title,TmpStr,itemlvl,maxlvl);
				else
				{
					itemxp=War3_GetItemXP2(target, race, itemid2);
					itemMaxXp=W3GetReqXP(itemlvl+1);
					Format(title,sizeof(title),"%s\n%s: lvl %d/%d xp: %d/%d\n\n",title,TmpStr,itemlvl,maxlvl,itemxp,itemMaxXp);
				}
			}
			Format(title,sizeof(title),"%s\n \n",title);
			Format(title,sizeof(title),"%s\n \n",title);
		}
		//three
		if(War3_GetOwnsItem3(target,race,itemid3))
		{
			W3GetItem3Name(itemid3,itemname,sizeof(itemname));
			W3GetItem3Category(itemid3,TmpStr,31);
			Format(title,sizeof(title),"%s\n[%s] - %s",title,TmpStr,itemname);
			itemlvl=War3_GetItemLevel(target, race, itemid3);
			maxlvl=W3GetItem3maxlevel1(itemid3);
			W3GetItem3levelName(itemid3,TmpStr,31,skill1);
			if(itemlvl==maxlvl)
				Format(title,sizeof(title),"%s\n%s: lvl %d/%d\n\n",title,TmpStr,itemlvl,maxlvl);
			else
			{
				itemxp=War3_GetItemXP(target, race, itemid3);
				itemMaxXp=W3GetReqXP(itemlvl+1);
				Format(title,sizeof(title),"%s\n%s: lvl %d/%d xp: %d/%d\n\n",title,TmpStr,itemlvl,maxlvl,itemxp,itemMaxXp);
			}
			maxlvl=W3GetItem3maxlevel2(itemid3);
			if(maxlvl>0)
			{
				itemlvl=War3_GetItemLevel2(target, race, itemid3);
				maxlvl=W3GetItem3maxlevel2(itemid3);
				W3GetItem3levelName(itemid3,TmpStr,31,skill2);
				if(itemlvl==maxlvl)
					Format(title,sizeof(title),"%s\n%s: lvl %d/%d\n\n",title,TmpStr,itemlvl,maxlvl);
				else
				{
					itemxp=War3_GetItemXP2(target, race, itemid3);
					itemMaxXp=W3GetReqXP(itemlvl+1);
					Format(title,sizeof(title),"%s\n%s: lvl %d/%d xp: %d/%d\n\n",title,TmpStr,itemlvl,maxlvl,itemxp,itemMaxXp);
				}
			}
			Format(title,sizeof(title),"%s\n \n",title);
			Format(title,sizeof(title),"%s\n \n",title);
		}

		//Format(title,sizeof(title),"%s\n \n",title);

		SetMenuTitle(hMenu,"%s",title);

		new String:buf[3];

		IntToString(target,buf,sizeof(buf));
		//new String:str[16];
		//Format(str,sizeof(str),"Refresh");
		AddMenuItem(hMenu,buf,"Refresh");

		DisplayMenu(hMenu,client,MENU_TIME_FOREVER);
}

public War3_playertargetItemMenu3Selected3(Handle:menu,MenuAction:action,client,selection){
	if(action==MenuAction_Select)
	{
		decl String:SelectionInfo[4];
		decl String:SelectionDispText[256];
		new SelectionStyle;
		GetMenuItem(menu,selection,SelectionInfo,sizeof(SelectionInfo),SelectionStyle, SelectionDispText,sizeof(SelectionDispText));
		new target=StringToInt(SelectionInfo);
		if(!ValidPlayer(target)){
			War3_ChatMessage(client,"Player has left the server");
		}
		else
		{
			if(selection==0){
				War3_playertargetItemMenu3(client,target);
			}
		}
		if(action==MenuAction_End)
		{
			CloseHandle(menu);
		}
	}
}


public Show_Menu3Itemsinfo3(client,itemnum){
	new Handle:helpMenu=CreateMenu(War3Source_ShopMenu3_Selected);
	SetMenuExitButton(helpMenu,true);

	decl String:str[256];
	W3GetItem3Name(itemnum,str,255);

	//decl String:shortname[16];
	//W3GetItem3Shortname(itemnum,shortname,sizeof(shortname));


	decl String:str3[256];
	W3GetItem3Desc(itemnum,str3,sizeof(str3));

	decl String:category[64];
	W3GetItem3Category(itemnum, category, sizeof(category));

	new String:racename[32];
	new race=GetRace(client);
	GetRaceName(race,racename,sizeof(racename));

	decl String:title[4000];

	decl cost;
	cost=W3GetItem3Cost(itemnum);

	Format(title,sizeof(title),"\nBUY [%s] %s?\n\n%s",category,str,str3);

	Format(title,sizeof(title),"%s\n\nCurrent Job: %s\n",title,racename);

	Format(title,sizeof(title),"%s\n\nCosts: %d Platinum\n\n",title,cost);


	SetMenuTitle(helpMenu,title);

	decl String:itembuf3[16];
	Format(itembuf3,sizeof(itembuf3),"%d,%d",itemnum,itemnum);
	AddMenuItem(helpMenu,itembuf3,"Buy");

	Format(str,sizeof(str),"Back");
	Format(itembuf3,sizeof(itembuf3),"%d,-1",itemnum);
	AddMenuItem(helpMenu,itembuf3,str);

	DisplayMenu(helpMenu,client,MENU_TIME_FOREVER);
}

public Show_Menu3Itemsinfo3Selected3(Handle:menu,MenuAction:action,client,selection)
{
	if(action==MenuAction_Select)
	{
		decl String:SelectionInfo[4];
		decl String:SelectionDispText[256];
		new SelectionStyle;
		GetMenuItem(menu,selection,SelectionInfo,sizeof(SelectionInfo),SelectionStyle, SelectionDispText,sizeof(SelectionDispText));
		new itemnum=StringToInt(SelectionInfo);
		//if(itemnum>0&&itemnum<=W3GetItems3Loaded())
		//ShowMenu3Itemsinfo(client);
		if(itemnum==-1)
		{
			ShowMenu3ShopCategory(client);
		}
		else
		{
			Show_Menu3Itemsinfo3(client,itemnum);
		}
	}
	if(action==MenuAction_End)
	{
		CloseHandle(menu);
	}
}
