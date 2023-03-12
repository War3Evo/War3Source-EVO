// War3Source_Engine_HelpMenu.sp

// TRANSLATED

new Handle:vecHelpCommands;
#define HELPCOMMAND_COUNT GetArraySize(vecHelpCommands)

/*
public Plugin:myinfo=
{
	name="War3Source help menu",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};
*/

public War3Source_Engine_HelpMenu_OnPluginStart()
{

	if(!War3Source_InitiateHelpVector())
		SetFailState("[War3Source:EVO] %T","There was a failure in creating the help vector, definitely halting.", LANG_SERVER);
	War3Source_InitHelpCommands();
}

public bool:War3Source_Engine_HelpMenu_InitNatives()
{
	CreateNative("War3_CreateHelpCommand",Native_War3_CreateHelpCommand);

	return true;
}
public Native_War3_CreateHelpCommand(Handle:plugin,numParams)
{
	decl String:name[64];
	GetNativeString(1,name,sizeof(name));
	decl String:desc[256];
	GetNativeString(2,desc,sizeof(desc));
	NewHelpCommand(name,desc);

}
public War3Source_Engine_HelpMenu_OnWar3Event(client)
{
	War3Source_War3Help(client);
}

bool:War3Source_InitiateHelpVector()
{
	vecHelpCommands=CreateArray(); //this is only called once...
	return true;
}

NewHelpCommand(String:name[],String:info[])
{
	new Handle:vec=CreateArray(ByteCountToCells(256)); //this array is no only created once, and help commands are only added once at first load, no longer on map change
	PushArrayString(vec,name);
	PushArrayString(vec,info);
	PushArrayCell(vecHelpCommands,vec);
}
War3Source_InitHelpCommands()
{
	new limit=17;


	new String:transbuf1[32];
	new String:transbuf2[32];
	for(new i=0;i<=limit;i++){
		Format(transbuf1,sizeof(transbuf1),"HelpMenu%d",i);
		Format(transbuf2,sizeof(transbuf2),"HelpMenu%ddesc",i);

		NewHelpCommand(transbuf1,transbuf2);
	}
}
Handle:GetHelpItem(command)
{
	return GetArrayCell(vecHelpCommands,command);
}

War3Source_War3Help(client)
{
	new Handle:helpMenu=CreateMenu(War3Source_HelpMenu_Selected);
	SetMenuExitButton(helpMenu,true);
	SetMenuTitle(helpMenu,"[War3Source:EVO] %T","Select a command for more info",client);
	decl String:commandname[64];
	decl String:helpbuf[4];
	new Handle:commandHandle;
	for(new x=0;x<HELPCOMMAND_COUNT;x++)
	{
		Format(helpbuf,sizeof(helpbuf),"%d",x);
		commandHandle=GetHelpItem(x);
		GetArrayString(commandHandle,0,commandname,sizeof(commandname));
		decl String:str[300];
		Format(str,sizeof(str),"%T",commandname,client);
		AddMenuItem(helpMenu,helpbuf,str);


	}
	DisplayMenu(helpMenu,client,MENU_TIME_FOREVER);
}



public War3Source_HelpMenu_Selected(Handle:menu,MenuAction:action,client,selection)
{
	if(action==MenuAction_Select)
	{
		decl String:SelectionInfo[4];
		decl String:SelectionDispText[256];
		new SelectionStyle;
		GetMenuItem(menu,selection,SelectionInfo,sizeof(SelectionInfo),SelectionStyle, SelectionDispText,sizeof(SelectionDispText));
		new command=StringToInt(SelectionInfo);
		if(command>-1&&command<HELPCOMMAND_COUNT)
			War3Source_HelpMenu_Command(client,command);
	}
	if(action==MenuAction_End)
	{
		CloseHandle(menu);
	}
}

War3Source_HelpMenu_Command(client,command)
{
	new Handle:helpMenu_Command=CreateMenu(War3Source_HM_Command_Select);
	SetMenuExitButton(helpMenu_Command,true);
	decl String:name[64];
	new Handle:helpCommandHandle=GetHelpItem(command);
	GetArrayString(helpCommandHandle,0,name,sizeof(name));

	decl String:strcmd[300];
	Format(strcmd,sizeof(strcmd),"%T",name,client);

	decl String:desc[300];
	GetArrayString(helpCommandHandle,1,desc,sizeof(desc));
	decl String:strdesc[300];
	Format(strdesc,sizeof(strdesc),"%T",desc,client);

	Format(strdesc,sizeof(strdesc),"%T%s\n \n","Description:",client,strdesc);
	SetMenuTitle(helpMenu_Command,"[War3Source:EVO] %T\n \n%s","Command - {cmd}",client,strcmd,strdesc);

	decl String:backtohelp[32];
	Format(backtohelp,sizeof(backtohelp),"%T","Back to help commands",client);
	AddMenuItem(helpMenu_Command,"backtohelp",backtohelp);
	DisplayMenu(helpMenu_Command,client,MENU_TIME_FOREVER);
}

public War3Source_HM_Command_Select(Handle:menu,MenuAction:action,client,selection)
{
	if(action==MenuAction_Select)
	{
		War3Source_War3Help(client);
	}
	if(action==MenuAction_End)
	{
		CloseHandle(menu);
	}
}
