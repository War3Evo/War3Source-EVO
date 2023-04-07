// War3Source_Engine_ShowMOTD.sp


// TRANSLATED 4/7/2023
// TO-DO: FILE SHOULD LATER GET MERGED INTO COMMANDHOOK


//#assert GGAMEMODE == MODE_WAR3SOURCE

#define MOTDPANEL_TYPE_TEXT 0 /**< Treat msg as plain text */
#define MOTDPANEL_TYPE_INDEX 1 /**< Msg is auto determined by the engine */
#define MOTDPANEL_TYPE_URL 2 /**< Treat msg as an URL link */
#define MOTDPANEL_TYPE_FILE 3 /**< Treat msg as a filename to be openned */
#define COLOR_DEFAULT 0x01
#define COLOR_TEAM 0x03
#define COLOR_GREEN2 0x04

bool g_bPlyrCanDoMotd[MAXPLAYERS+1];

/*
public Plugin:myinfo = {
	name = "War3Source:EVO Engine ShowMOTD",
	author = "El Diablo",
	description = "Let's users view the vairous websites setup.",
	version = "0.2.1",
	url = "http://www.war3evo.com/"
};*/

public War3Source_Engine_ShowMOTD_OnPluginStart()
{
	RegConsoleCmd("say", War3Source_Engine_ShowMOTD_Command_Say);
	RegConsoleCmd("say_team", War3Source_Engine_ShowMOTD_Command_Say);
}

public motdQuery(QueryCookie:cookie, client, ConVarQueryResult:result, const String:cvarName[], const String:cvarValue[])
{
	if (result == ConVarQuery_Okay && StringToInt(cvarValue) == 0 || result != ConVarQuery_Okay)
	{
		g_bPlyrCanDoMotd[client] = true;
	} else {
		g_bPlyrCanDoMotd[client] = false;
	}
}

public Action:War3Source_Engine_ShowMOTD_Command_Say(client, args) {

	if(!ValidPlayer(client)) return Plugin_Continue;

	decl String:text[192];
	if (GetCmdArgString(text, sizeof(text)) < 1) {
		return Plugin_Continue;
	}

	new startidx;
	if (text[strlen(text)-1] == '"') {
		text[strlen(text)-1] = '\0';
		startidx = 1;
	}

	decl String:message[25];
	BreakString(text[startidx], message, sizeof(message));

	if (strcmp(message, "!blu", false) == 0 || strcmp(message, "/blu", false) == 0)
	{
		if(GetAdminFlag(GetUserAdmin(client), Admin_Reservation))
			ChangeClientTeam(client,3);
		return Plugin_Continue;
	}
	if (strcmp(message, "!red", false) == 0 || strcmp(message, "/red", false) == 0)
	{
		if(GetAdminFlag(GetUserAdmin(client), Admin_Reservation))
			ChangeClientTeam(client,2);
		return Plugin_Continue;
	}
	if (strcmp(message, "!bind2", false) == 0 || strcmp(message, "/bind2", false) == 0)
	{
		PerformDONATE(client,"http://youtu.be/N9jbRbBS61c");
		return Plugin_Continue;
	} else if (strcmp(message, "!bind", false) == 0 || strcmp(message, "/bind", false) == 0)
	{
		War3_ChatMessage(client, "%T","{white}To {orange}bind a key{white} you must {orange}enable your developer console.",client);
		War3_ChatMessage(client, "%T","{orange}Escape {white}-> {orange}Options {white}-> {orange}Advanced {white}-> {orange}[ ] Enable Developer Console",client);
		War3_ChatMessage(client, "%T","{white}Hit {orange}'`'{white} to open the console. It is {orange}the button to the left of 1.",client);
		War3_ChatMessage(client, "%T","{white}Type {orange}bind j +ultimate {white}into the console.",client);
		War3_ChatMessage(client, "%T","{white}Type {orange}bind k +ability {white}into the console.",client);
		War3_ChatMessage(client, "%T","{white}To see a {orange}video {white}of this process, type {orange}!bind2",client);
		return Plugin_Continue;
	}
	if (strcmp(message, "!rules", false) == 0 || strcmp(message, "/rules", false) == 0)
	{
		CPrintToChat(client,"%T","Ask an admin.",client);
		return Plugin_Continue;
	}
	if (strcmp(message, "!commands", false) == 0 || strcmp(message, "/commands", false) == 0 || strcmp(message, "!command", false) == 0)
	{
		DoFwd_War3_Event(DoShowHelpMenu,client);
		return Plugin_Continue;
	}
	if (strcmp(message, "!war3top10", false) == 0 || strcmp(message, "/war3top10", false) == 0)
	{
		DoFwd_War3_Event(DoShowWar3Top,client);
		return Plugin_Continue;
	}
	if (strcmp(message, "!playerinfo", false) == 0 || strcmp(message, "/playerinfo", false) == 0)
	{
		DoFwd_War3_Event(DoShowPlayerinfoMenu,client);
		return Plugin_Continue;
	}
	if ( StrContains(message, "/helpme", false)==0 || StrContains(message, "!helpme", false)==0)
	{
		printHelpInfo(client);
		return Plugin_Continue;
	}
	return Plugin_Continue;
}

public printHelpInfo(client)
{
		War3_ChatMessage(client,"%T","{lightseagreen}This is a {darkgreen}War3Mod{lightseagreen} server.",client);
		War3_ChatMessage(client,"%T","{lightseagreen}You gain {darkgreen}exp{lightseagreen} and {darkgreen}gold{lightseagreen} for kills and map objectives.",client);
		War3_ChatMessage(client,"%T","{lightseagreen}When you {darkgreen}level up{lightseagreen} you can gain new {darkgreen}skills.",client);
		War3_ChatMessage(client,"%T","{lightseagreen}Type {darkgreen}raceinfo{lightseagreen} to learn what different {darkgreen}skills {lightseagreen} each race gets!",client);
		War3_ChatMessage(client,"%T","{lightseagreen}Type {darkgreen}shopmenu{lightseagreen} to spend {darkgreen}gold {lightseagreen} on different {darkgreen}items.",client);
		War3_ChatMessage(client,"%T","{lightseagreen}Type {darkgreen}war3menu{lightseagreen} for the full help menu. Type {darkgreen}myinfo {lightseagreen} to see your current race info.",client);
}
public hiddenURL(client, String:url[])
{
	new Handle:setup = CreateKeyValues("data");

	KvSetString(setup, "title", "Musicspam");
	KvSetNum(setup, "type", MOTDPANEL_TYPE_URL);
	KvSetString(setup, "msg", url);

	ShowVGUIPanel(client, "info", setup, false);
	CloseHandle(setup);
	//return Plugin_Continue;
}



public PerformDONATE(client, String:DONATE_URL[128])
{
	new Handle:setup = CreateKeyValues("data");

	KvSetString(setup, "title", "War3Source:EVO");
	KvSetNum(setup, "type", MOTDPANEL_TYPE_URL);
	KvSetString(setup, "msg", DONATE_URL);
	KvSetNum(setup, "customsvr", 1);

	ShowVGUIPanel(client, "info", setup, true);
	CloseHandle(setup);
	//ShowMOTDPanel(client, "War3Source:EVO", DONATE_URL, MOTDPANEL_TYPE_URL);
}

// Example usage: index.php?a=URLEncode(param_1)&b=URLEncode(param_2)&c=URLEncode(param_3)
stock URLEncode(String:str[],len)
{
	// Make sure % is first to avoid collisions.
	new String:ReplaceThis[20][] = {"%", " ", "!", "*", "'", "(", ")", ";", ":", "@", "&", "=", "+", "$", ",", "/", "?", "#", "[", "]"};
	new String:ReplaceWith[20][] = {"%25", "%20", "%21", "%2A", "%27", "%28", "%29", "%3B", "%3A", "%40", "%26", "%3D", "%2B", "%24", "%2C", "%2F", "%3F", "%23", "%5B", "%5D"};
	for(new x=0;x<20;x++)
	{
		ReplaceString(str, len, ReplaceThis[x], ReplaceWith[x]);
	}
	if(strlen(str)>len-1){
		LogError("!donate encode url exceeded length: %s",str);
		//War3Failed("statistics encode url exceeded length"); //this should never happen as ReplaceString was fixed not to overwrite its length
	}
}
