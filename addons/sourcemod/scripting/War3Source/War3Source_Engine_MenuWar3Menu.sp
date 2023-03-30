// War3Source_Engine_MenuWar3Menu.sp
/*
#assert GGAMEMODE == MODE_WAR3SOURCE

// TRANSLTED 3/29/2023

public Plugin:myinfo=
{
	name="War3Source war3menu",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};*/

public War3Source_Engine_MenuWar3Menu_OnWar3Event(client)
{
	ShowWar3Menu(client);
}

ShowWar3Menu(client){
	new Handle:war3Menu=CreateMenu(War3Source_War3Menu_Select);
	SetMenuTitle(war3Menu,"[War3Source:EVO] %T","Type the command in quotes into chat!",client);
	//new limit=9;
	//new String:transbuf[32];
	new String:menustr[100];
	new String:numstr[4];
	/*
	for(new i=0;i<=limit;i++){

		Format(transbuf,sizeof(transbuf),"War3Menu_Item%d",i);
		Format(menustr,sizeof(menustr),"%T",transbuf,client);
		new String:numstr[4];
		Format(numstr,sizeof(numstr),"%d",i);

		AddMenuItem(war3Menu,numstr,menustr);
	}*/

	Format(menustr,sizeof(menustr),"%T","What are my skills and their levels? - \"!myinfo\"",client);
	Format(numstr,sizeof(numstr),"0");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"%T","What are all the races? - \"!raceinfo\"",client);
	Format(numstr,sizeof(numstr),"1");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"%T","Change my race - \"!changerace\"",client);
	Format(numstr,sizeof(numstr),"2");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"%T","What races are people playing? - \"!playerinfo\"",client);
	Format(numstr,sizeof(numstr),"3");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"%T","Buy items with gold that last until death - \"!sh1\"",client);
	Format(numstr,sizeof(numstr),"4");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"%T","Buy items with diamonds that last until map change - \"!sh2\"",client);
	Format(numstr,sizeof(numstr),"5");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"%T","Buy items with platinum that last forever - \"!sh3\"",client);
	Format(numstr,sizeof(numstr),"6");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"%T","How do I bind a key? - \"!bind\"",client);
	Format(numstr,sizeof(numstr),"7");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"%T","Reset my current race's skills - \"!resetskills\"",client);
	Format(numstr,sizeof(numstr),"8");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"%T","Spend my unused skill points - \"!spendskills\"",client);
	Format(numstr,sizeof(numstr),"9");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"%T","Spend my levelbanks - \"!levelbank\"",client);
	Format(numstr,sizeof(numstr),"10");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"%T","Open the forums - \"!forums\"",client);
	Format(numstr,sizeof(numstr),"11");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"%T","Open the donor page - \"!donate\"",client);
	Format(numstr,sizeof(numstr),"12");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"%T","How do I tag up for bonus xp/gold? - \"!taghelp\"",client);
	Format(numstr,sizeof(numstr),"13");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"%T","How do I view the players with the most levels? - \"!war3top10\"",client);
	Format(numstr,sizeof(numstr),"14");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"%T","Open the full commands listing - \"!commands\"",client);
	Format(numstr,sizeof(numstr),"15");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"%T","View recent mod updates - \"!update\"",client);
	Format(numstr,sizeof(numstr),"16");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"%T","Shopmenu (sh1) information  - \"!itemsinfo\"",client);
	Format(numstr,sizeof(numstr),"17");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"%T","Shopmenu2 (sh2) information  - \"!itemsinfo2\"",client);
	Format(numstr,sizeof(numstr),"18");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"%T","Shopmenu3 (sh3) information  - \"!itemsinfo3\"",client);
	Format(numstr,sizeof(numstr),"19");
	AddMenuItem(war3Menu,numstr,menustr);

	//W3CreateEvent(DoShowItemsInfoMenu,client);

	DisplayMenu(war3Menu,client,MENU_TIME_FOREVER);
}

public War3Source_War3Menu_Select(Handle:menu,MenuAction:action,client,selection)
{
	if(action==MenuAction_Select)
	{
		decl String:SelectionInfo[4];
		decl String:SelectionDispText[256];
		new SelectionStyle;
		GetMenuItem(menu,selection,SelectionInfo,sizeof(SelectionInfo),SelectionStyle, SelectionDispText,sizeof(SelectionDispText));
		if(ValidPlayer(client))
		{
			switch(selection)
			{
				//case 0: // war3help
				//{
					//W3CreateEvent(DoShowHelpMenu,client);
				//}
				case 0: // myinfo
				{
					FakeClientCommandEx(client,"say !myinfo");
				}
				case 1: // raceinfo
				{
					FakeClientCommandEx(client,"say !raceinfo");
				}
				case 2: // changerace
				{
					FakeClientCommandEx(client,"say !changerace");
				}
				case 3: // playerinfo
				{
					FakeClientCommandEx(client,"say !playerinfo");
				}
				case 4: // sh1
				{
					FakeClientCommandEx(client,"say !sh1");
				}
				case 5: // sh2
				{
					FakeClientCommandEx(client,"say !sh2");
				}
				case 6: // sh3
				{
					FakeClientCommandEx(client,"say !sh3");
				}
				case 7: // !bind
				{
					FakeClientCommandEx(client,"say !bind");
				}
				case 8: // resetskills
				{
					FakeClientCommandEx(client,"say !resetskills");
				}
				case 9: // spendskills
				{
					FakeClientCommandEx(client,"say !spendskills");
				}
				case 10: // levelbank
				{
					FakeClientCommandEx(client,"say !levelbank");
				}
				case 11: // !forums
				{
					FakeClientCommandEx(client,"say !forums");
				}
				case 12: // !donate
				{
					FakeClientCommandEx(client,"say !donate");
				}
				case 13: // !taghelp
				{
					FakeClientCommandEx(client,"say !taghelp");
				}
				case 14: // war3top10
				{
					FakeClientCommandEx(client,"say !war3top10");
				}
				case 15: // !commands
				{
					FakeClientCommandEx(client,"say !commands");
				}
				case 16: // !update
				{
					FakeClientCommandEx(client,"say !update");
				}
				case 17: // !itemsinfo
				{
					FakeClientCommandEx(client,"say !itemsinfo");
				}
				case 18: // !itemsinfo2
				{
					FakeClientCommandEx(client,"say !itemsinfo2");
				}
				case 19: // !itemsinfo3
				{
					FakeClientCommandEx(client,"say !itemsinfo3");
				}
			}
		}
	}
	if(action==MenuAction_End)
	{
		CloseHandle(menu);
	}
}

