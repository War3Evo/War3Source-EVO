// War3Source_Engine_MenuWar3Menu.sp
/*
#assert GGAMEMODE == MODE_WAR3SOURCE

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
	SetMenuTitle(war3Menu,"[War3Source:EVO] Type the command in quotes into chat!");
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


	Format(menustr,sizeof(menustr),"What are my skills and their levels? - \"!myinfo\"");
	Format(numstr,sizeof(numstr),"0");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"What are all the races? - \"!raceinfo\"");
	Format(numstr,sizeof(numstr),"1");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"Change my race - \"!changerace\"");
	Format(numstr,sizeof(numstr),"2");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"What races are people playing? - \"!playerinfo\" ");
	Format(numstr,sizeof(numstr),"3");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"Buy items with gold that last until death - \"!sh1\"");
	Format(numstr,sizeof(numstr),"4");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"Buy items with diamonds that last until map change - \"!sh2\"");
	Format(numstr,sizeof(numstr),"5");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"Buy items with platinum that last forever - \"!sh3\"");
	Format(numstr,sizeof(numstr),"6");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"How do I bind a key? - \"!bind\"");
	Format(numstr,sizeof(numstr),"7");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"Reset my current race's skills - \"!resetskills\"");
	Format(numstr,sizeof(numstr),"8");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"Spend my unused skill points - \"!spendskills\"");
	Format(numstr,sizeof(numstr),"9");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"Spend my levelbanks - \"!levelbank\"");
	Format(numstr,sizeof(numstr),"10");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"Open the forums - \"!forums\"");
	Format(numstr,sizeof(numstr),"11");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"Open the donor page - \"!donate\"");
	Format(numstr,sizeof(numstr),"12");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"How do I tag up for bonus xp/gold? - \"!taghelp\"");
	Format(numstr,sizeof(numstr),"13");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"How do I view the players with the most levels? - \"!war3top10\"");
	Format(numstr,sizeof(numstr),"14");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"Open the full commands listing - \"!commands\"");
	Format(numstr,sizeof(numstr),"15");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"View recent mod updates - \"!update\"");
	Format(numstr,sizeof(numstr),"16");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"Shopmenu (sh1) information  - \"!itemsinfo\"");
	Format(numstr,sizeof(numstr),"17");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"Shopmenu2 (sh2) information  - \"!itemsinfo2\"");
	Format(numstr,sizeof(numstr),"18");
	AddMenuItem(war3Menu,numstr,menustr);

	Format(menustr,sizeof(menustr),"Shopmenu3 (sh3) information  - \"!itemsinfo3\"");
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

