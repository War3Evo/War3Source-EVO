// War3Source_Engine_Weapon.sp

//#assert GGAMEMODE == MODE_WAR3SOURCE

new m_OffsetActiveWeapon;
new m_OffsetNextPrimaryAttack;

new String:weaponsAllowed[MAXPLAYERSCUSTOM][MAXRACES][300];
new restrictionPriority[MAXPLAYERSCUSTOM][MAXRACES];
new highestPriority[MAXPLAYERSCUSTOM];
new bool:restrictionEnabled[MAXPLAYERSCUSTOM][MAXRACES]; ///if restriction has length, then this should be true (caching allows quick skipping)
new bool:hasAnyRestriction[MAXPLAYERSCUSTOM]; //if any of the races said client has restriction, this is true (caching allows quick skipping)



new g_iWeaponRateQueue[MAXPLAYERSCUSTOM][2]; //ent, client
new g_iWeaponRateQueueLength;

new timerskip;

new Handle:hweaponFiredFwd;
/*
public Plugin:myinfo=
{
	name="W3S Engine Weapons",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};
*/
public War3Source_Engine_Weapon_OnMapStart()
{
	//sm_dump_netprops netprops.txt
	//https://forums.alliedmods.net/showpost.php?p=2207028&postcount=3
	m_OffsetActiveWeapon=FindSendPropInfo("CBasePlayer","m_hActiveWeapon");
	if(m_OffsetActiveWeapon==-1)
	{
		LogError("[War3Source:EVO] Error finding active weapon offset.");
	}
	m_OffsetNextPrimaryAttack= FindSendPropInfo("CBaseCombatWeapon","m_flNextPrimaryAttack");
	if(m_OffsetNextPrimaryAttack==-1)
	{
		LogError("[War3Source:EVO] Error finding active weapon offset.");
	}
	//RegConsoleCmd("w3dropweapon",cmddroptest);
}

/*
public Action:cmddroptest(client,args){
	if(W3IsDeveloper(client)){
		War3_WeaponRestrictTo(client, War3_GetRace(client),"weapon_knife",1);
	}
	return Plugin_Handled;
} */

public bool:War3Source_Engine_Weapon_InitNatives()
{
	CreateNative("War3_WeaponRestrictTo",NWar3_WeaponRestrictTo);
	CreateNative("War3_GetWeaponRestriction",NWar3_GetWeaponRestrict);
	CreateNative("W3GetCurrentWeaponEnt",NW3GetCurrentWeaponEnt);
	CreateNative("W3DropWeapon",NW3DropWeapon);

	return true;
}

public bool:War3Source_Engine_Weapon_InitNativesForwards()
{
	hweaponFiredFwd=CreateGlobalForward("OnWeaponFired",ET_Ignore,Param_Cell);
	return true;
}

public NW3GetCurrentWeaponEnt(Handle:plugin,numParams)
{
	return GetCurrentWeaponEnt(GetNativeCell(1));
}

// bookmark
GetCurrentWeaponEnt(client)
{
	if(client)
	{
		// TF2 couldn't find this on 1/31/2023 ... will have to research this further
		// Reason for if then statement: Exception reported: Offset 0 is invalid
		if(m_OffsetActiveWeapon>0)
		{
#if GGAMETYPE != GGAME_TF2
			// CSGO
			int wep = GetEntDataEnt2(client,m_OffsetActiveWeapon);
#else
			// recommended from Allied Modders to try instad of GetEntDataEnt2
			int wep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
#endif			
			return wep;
		}
		else return -1;
	}
	else
	{
		return -1;
	}
}

public NW3DropWeapon(Handle:plugin,numParams)
{
	new client = GetNativeCell(1);
	new wpent = GetNativeCell(2);
	if (ValidPlayer(client,true) && IsValidEdict(wpent)){
#if (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO) 
		CS_DropWeapon(client,wpent,true);
#endif
		//SDKHooks_DropWeapon(client, wpent);
	}
}

public NWar3_WeaponRestrictTo(Handle:plugin,numParams)
{

	new client=GetNativeCell(1);
	new raceid=GetNativeCell(2);
	new String:restrictedto[300];
	GetNativeString(3,restrictedto,sizeof(restrictedto));

	restrictionPriority[client][raceid]=GetNativeCell(4);
	//new String:pluginname[100];
	//GetPluginFilename(plugin, pluginname, 100);
	//PrintToServer("%s NEW RESTRICTION: %s",pluginname,restrictedto);
	//LogError("%s NEW RESTRICTION: %s",pluginname,restrictedto);
	//PrintIfDebug(client,"%s NEW RESTRICTION: %s",pluginname,restrictedto);
	strcopy(weaponsAllowed[client][raceid],200,restrictedto);
	CalculateWeaponRestCache(client);
}

public NWar3_GetWeaponRestrict(Handle:plugin,numParams)
{
	new client=GetNativeCell(1);
	new raceid=GetNativeCell(2);
	//new String:restrictedto[300];
	new maxsize=GetNativeCell(4);
	if(maxsize>0) SetNativeString(3, weaponsAllowed[client][raceid], maxsize, false);
}
CalculateWeaponRestCache(client)
{
	int num=0;
	int limit=GetRacesLoaded();
	int highestpri=0;
	for(int raceid=0;raceid<=limit;raceid++)
	{
		restrictionEnabled[client][raceid]=(strlen(weaponsAllowed[client][raceid])>0)?true:false;
		if(restrictionEnabled[client][raceid])
		{
			num++;
			if(restrictionPriority[client][raceid]>highestpri)
			{
				highestpri=restrictionPriority[client][raceid];
			}
		}
	}
	hasAnyRestriction[client]=num>0?true:false;


	highestPriority[client]=highestpri;

	timerskip=0; //force next timer to check weapons
}

public War3Source_Engine_Weapon_OnClientPutInServer(client)
{
	//War3_WeaponRestrictTo(client,0,""); //REMOVE RESTICTIONS ON JOIN
	int limit=GetRacesLoaded();
	for(int raceid=0;raceid<=limit;raceid++){
		restrictionEnabled[client][raceid]=false;
		//Format(weaponsAllowed[client][i],3,"");

	}
	CalculateWeaponRestCache(client);
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse); //weapon touch and equip only
}
public War3Source_Engine_Weapon_OnClientDisconnect(client)
{
	SDKUnhook(client,SDKHook_WeaponCanUse,OnWeaponCanUse);
}

bool:CheckCanUseWeapon(client,weaponent){
	decl String:WeaponName[32];
	GetEdictClassname(weaponent, WeaponName, sizeof(WeaponName));

	if(StrContains(WeaponName,"c4")>-1)
	{ //allow c4
		return true;
	}

	int limit=GetRacesLoaded();
	for(int raceid=0;raceid<=limit;raceid++)
	{
		if(restrictionEnabled[client][raceid]&&restrictionPriority[client][raceid]==highestPriority[client])
		{ //cached strlen is not zero
			if(StrContains(weaponsAllowed[client][raceid],WeaponName)<0)
			{ //weapon name not found
				return false;
			}
		}
	}
	return true; //allow
}

public Action:OnWeaponCanUse(client, weaponent)
{
	if(hasAnyRestriction[client]){
		if(CheckCanUseWeapon(client,weaponent))
		{
			return Plugin_Continue; //ALLOW
		}
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public War3Source_Engine_Weapon_DeciSecondTimer()
{
	if(MapChanging || War3SourcePause) return 0;

	timerskip--;
	if(timerskip<1){
		timerskip=10;
		for(new client=1;client<=MaxClients;client++){
			/*if(true){ //test
			new wpnent = GetCurrentWeaponEnt(client);
			if(FindSendPropOffs("CWeaponUSP","m_bSilencerOn")>0){

			SetEntData(wpnent,FindSendPropOffs("CWeaponUSP","m_bSilencerOn"),true,true);
			}

			}*/
			if(hasAnyRestriction[client]&&ValidPlayer(client,true)){

				new String:name[32];
				GetClientName(client,name,sizeof(name));
				//PrintToChatAll("ValidPlayer %d",client);

				new wpnent = GetCurrentWeaponEnt(client);
				//PrintIfDebug(client,"   weapon ent %d %d",client,wpnent);
				//new String:WeaponName[32];

				//if(IsValidEdict(wpnent)){

				//	}

				//PrintIfDebug(client,"    %s res: (%s) weapon: %s",name,weaponsAllowed[client],WeaponName);
				//	if(strlen(weaponsAllowed[client])>0){
				if(wpnent>0&&IsValidEdict(wpnent)){


					if (CheckCanUseWeapon(client,wpnent)){
						//allow
					}
					else
					{
						//RemovePlayerItem(client,wpnent);

						//PrintIfDebug(client,"            drop");
#if (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
						CS_DropWeapon(client,wpnent,true);
#endif
						//SDKHooks_DropWeapon(client, wpnent);
						//AcceptEntityInput(wpnent, "Kill");
						//UTIL_Remove(wpnent);

					}

				}
				else{
					//PrintIfDebug(client,"no weapon");
					//PrintToChatAll("no weapon");
				}
				//	}
			}
		}
	}
	return 1;
}

//=============================
// War3Source_Engine_Weapon >>> OnPlayerRunCmd
//=============================


public WeaponFireEvent(Handle:event,const String:name[],bool:dontBroadcast)
{

	new client = GetClientOfUserId(GetEventInt(event,"userid"));

	///PrintToServer("3");
	//SetEntPropVector(client, Prop_Send, "m_vecPunchAngle", Float:{0.0,0.0,0.0});

	//if(!IsRace(client))
	//  return;
	// if( (g_fDuration[client] < Getgametime()) || ( g_fMulti[client] < 1.0 ) ) //g_fDuratioin is for "in the fast attack speed mode"
	//    return;
	new ent = GetCurrentWeaponEnt(client);
	if(ent != -1)
	{
		//fill the stack for next frame
		g_iWeaponRateQueue[g_iWeaponRateQueueLength][0] = ent;
		g_iWeaponRateQueue[g_iWeaponRateQueueLength++][1] = client;
	}
	new Handle:oldevent=internal_W3GetVar(SmEvent);
	internal_W3SetVar(SmEvent,event);
	Call_StartForward(hweaponFiredFwd);
	Call_PushCell(client);
	Call_Finish(dummy);
	internal_W3SetVar(SmEvent,oldevent);
}

public Action:TF2_CalcIsAttackCritical(client, weapon, String:weaponname[], &bool:result)
{
	// new client = GetClientOfUserId(GetEventInt(event,"userid"));
	//if(!IsRace(client))
	//  return;
	// if( (g_fDuration[client] < Getgametime()) || ( g_fMulti[client] < 1.0 ) ) //g_fDuratioin is for "in the fast attack speed mode"
	//    return;
	new ent = GetEntDataEnt2(client,m_OffsetActiveWeapon);
	if(ent != -1)
	{
		//fill the stack for next frame
		g_iWeaponRateQueue[g_iWeaponRateQueueLength][0] = ent;
		g_iWeaponRateQueue[g_iWeaponRateQueueLength][1] = client;
		g_iWeaponRateQueueLength++;
	}

	Call_StartForward(hweaponFiredFwd);
	Call_PushCell(client);
	Call_Finish(dummy);
}

public War3Source_Engine_Weapon_OnGameFrame()
{
	if(g_iWeaponRateQueueLength>0)       //see events
	{
		decl ent, client, Float:time;
		new Float:gametime = GetGameTime();
		for(new i = 0; i < g_iWeaponRateQueueLength; i++) {
			ent = g_iWeaponRateQueue[i][0];
			if(IsValidEntity(ent)) {   //weapon ent is valid

				client = g_iWeaponRateQueue[i][1];
				new Float:multi = GetBuffMaxFloat(client,fAttackSpeed);
				if(multi!=1.0){        //do we need to change it?
					time = (GetEntDataFloat(ent,m_OffsetNextPrimaryAttack) - gametime) / multi;
					SetEntDataFloat(ent,m_OffsetNextPrimaryAttack,time + gametime,true);
				}
			}
		}
		g_iWeaponRateQueueLength = 0;
	}
}
