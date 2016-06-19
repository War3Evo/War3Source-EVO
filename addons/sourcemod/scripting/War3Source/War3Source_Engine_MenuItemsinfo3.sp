// War3Source_Engine_MenuItemsinfo3.sp

/*
public Plugin:myinfo=
{
	name="War3Source Menus itemsinfo",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};*/

public War3Source_Engine_MenuItemsinfo3_OnWar3Event(client)
{
	ShowMenu3Itemsinfo(client);
}
ShowMenu3Itemsinfo(client){
	new Handle:helpMenu=CreateMenu(ShowMenu3ItemsinfoSelected);
	SetMenuExitButton(helpMenu,true);
	SetMenuTitle(helpMenu,"[War3Source:EVO] Shopmenu items");
	decl String:str[64];
	decl String:numstr[4];

	new ItemsLoaded = W3GetItems3Loaded();
	for(new x=1;x<=ItemsLoaded;x++)
	{
		W3GetItem3Name(x,str,sizeof(str));
		IntToString(x,numstr,sizeof(numstr));
		//PrintToChatAll("%s %s",numstr,str);
		AddMenuItem(helpMenu,numstr,str);
	}
	DisplayMenu(helpMenu,client,MENU_TIME_FOREVER);
}

public ShowMenu3ItemsinfoSelected(Handle:menu,MenuAction:action,client,selection)
{
	if(action==MenuAction_Select)
	{
		decl String:SelectionInfo[4];
		decl String:SelectionDispText[256];
		new SelectionStyle;
		GetMenuItem(menu,selection,SelectionInfo,sizeof(SelectionInfo),SelectionStyle, SelectionDispText,sizeof(SelectionDispText));
		new itemnum=StringToInt(SelectionInfo);
		if(itemnum>0&&itemnum<=W3GetItems3Loaded())
			ShowMenu3Itemsinfo3(client,itemnum);
	}
	if(action==MenuAction_End)
	{
		CloseHandle(menu);
	}
}
public ShowMenu3Itemsinfo3(client,itemnum){
	new Handle:helpMenu=CreateMenu(ShowMenu3Itemsinfo3Selected);
	SetMenuExitButton(helpMenu,true);

	decl String:str[2048];
	W3GetItem3Name(itemnum,str,2047);

	decl String:shortname[16];
	W3GetItem3Shortname(itemnum,shortname,sizeof(shortname));


	decl String:str3[1024];
	W3GetItem3Desc(itemnum,str3,sizeof(str3));



	Format(str,sizeof(str),"\n[War3Source:EVO] Item: %s (identifier: %s)\n%s",str,shortname,str3);

	SetMenuTitle(helpMenu,str);

	Format(str,sizeof(str),"Back");

	AddMenuItem(helpMenu,"-1",str);
	DisplayMenu(helpMenu,client,MENU_TIME_FOREVER);
}
public ShowMenu3Itemsinfo3Selected(Handle:menu,MenuAction:action,client,selection)
{
	if(action==MenuAction_Select)
	{
		//decl String:SelectionInfo[4];
		//decl String:SelectionDispText[256];
		//new SelectionStyle;
		//GetMenuItem(menu,selection,SelectionInfo,sizeof(SelectionInfo),SelectionStyle, SelectionDispText,sizeof(SelectionDispText));
		//new itemnum=StringToInt(SelectionInfo);
		//if(itemnum>0&&itemnum<=GetItemsLoaded())
		ShowMenu3Itemsinfo(client);
	}
	if(action==MenuAction_End)
	{
		CloseHandle(menu);
	}
}
