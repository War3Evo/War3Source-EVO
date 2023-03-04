// War3Source_000_Engine_DatabaseConnect.sp

// TRANSLATIONS DONE

/*
public Plugin:myinfo=
{
	name="W3S Engine Database Connect",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};
*/

public ConnectDB()
{
	PrintToServer("[War3Source:EVO] %t","Connecting to Database");
	new String:sCachedDBIName[256];
	new String:dbErrorMsg[512];

	new Handle:keyValue=CreateKeyValues("War3SourceSettings");
	decl String:path[1024];
	BuildPath(Path_SM,path,sizeof(path),"configs/war3source.ini");
	FileToKeyValues(keyValue,path);
	// Load level configuration
	KvRewind(keyValue);
	char database_connect[256];
	KvGetString(keyValue,"database",database_connect,sizeof(database_connect),"default");
	char error[256];
	strcopy(sCachedDBIName,256,database_connect);


	if(StrEqual(database_connect,"",false) || StrEqual(database_connect,"default",false))
	{
		hDB=SQL_DefConnect(error,sizeof(error));	///use default connect, returns a handle...
	}
	else
	{
		hDB=SQL_Connect(database_connect,true,error,sizeof(error));
	}
	if(!hDB)
	{
		// try to connect SQLITE
		hDB=SQLite_UseDatabase("sourcemod-local",error,sizeof(error));
	}
	if(!hDB)
	{
		PrintToServer("");
		PrintToServer(" ######   #######  ##               ########    ###    #### ##       ");
		PrintToServer("##    ## ##     ## ##               ##         ## ##    ##  ##       ");
		PrintToServer("##       ##     ## ##               ##        ##   ##   ##  ##       ");
		PrintToServer(" ######  ##     ## ##       ####### ######   ##     ##  ##  ##       ");
		PrintToServer("      ## ##  ## ## ##               ##       #########  ##  ##       ");
		PrintToServer("##    ## ##    ##  ##               ##       ##     ##  ##  ##       ");
		PrintToServer(" ######   ##### ## ########         ##       ##     ## #### ######## ");
		PrintToServer("");
		LogError("[War3Source:EVO] ERROR: hDB invalid handle, Check SourceMod database config, could not connect. ");
		W3LogError("[War3Source:EVO] ERROR: hDB invalid handle, Check SourceMod database config, could not connect. ");
		Format(dbErrorMsg,sizeof(dbErrorMsg),"ERR: Could not connect to DB. \n%s",error);
		LogError("ERRMSG:(%s)",error);
		W3LogError("ERRMSG:(%s)",error);
		CreateWar3GlobalError("ERR: Could not connect to Database");
		PrintToServer("[War3Source:EVO] %t","Could not connect to Database");
	}
	else
	{
		char driver_ident[64];
		SQL_ReadDriver(hDB,driver_ident,sizeof(driver_ident));
		if(StrEqual(driver_ident,"mysql",false))
		{
			War3SQLType=SQLType_MySQL;
			PrintToServer("");
			PrintToServer("##     ## ##    ##  ######   #######  ##       ");
			PrintToServer("###   ###  ##  ##  ##    ## ##     ## ##       ");
			PrintToServer("#### ####   ####   ##       ##     ## ##       ");
			PrintToServer("## ### ##    ##     ######  ##     ## ##       ");
			PrintToServer("##     ##    ##          ## ##  ## ## ##       ");
			PrintToServer("##     ##    ##    ##    ## ##    ##  ##       ");
			PrintToServer("##     ##    ##     ######   ##### ## ######## ");
			PrintToServer("");
			PrintToServer("[War3Source:EVO] %T","SQL connection successful, driver {driver}",LANG_SERVER,driver_ident);
		}
		else if(StrEqual(driver_ident,"sqlite",false))
		{
			War3SQLType=SQLType_SQLite;
			PrintToServer("");
			PrintToServer(" ######   #######  ##       #### ######## ######## ");
			PrintToServer("##    ## ##     ## ##        ##     ##    ##       ");
			PrintToServer("##       ##     ## ##        ##     ##    ##       ");
			PrintToServer(" ######  ##     ## ##        ##     ##    ######   ");
			PrintToServer("      ## ##  ## ## ##        ##     ##    ##       ");
			PrintToServer("##    ## ##    ##  ##        ##     ##    ##       ");
			PrintToServer(" ######   ##### ## ######## ####    ##    ######## ");
			PrintToServer("");
			PrintToServer("[War3Source:EVO] %T","SQL connection successful, driver {driver}",LANG_SERVER,driver_ident);
		}
		else
		{
			War3SQLType=SQLType_Unknown;
		}
		SQL_LockDatabase(hDB);
		SQL_FastQuery(hDB, "SET NAMES \"UTF8\"");
		SQL_UnlockDatabase(hDB);
		internal_W3SetVar(hDatabase,hDB);
		internal_W3SetVar(hDatabaseType,War3SQLType);
		DoFwd_War3_Event(DatabaseConnected,0);
	}
	return true;
}
