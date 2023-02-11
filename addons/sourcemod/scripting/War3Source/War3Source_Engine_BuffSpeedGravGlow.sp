// War3Source_Engine_BuffSpeedGravGlow.sp

////BUFF SYSTEM


/* moved to variables includes file
 * int m_OffsetSpeed=-1;
 *
int reapplyspeed[MAXPLAYERSCUSTOM];
bool invisWeaponAttachments[MAXPLAYERSCUSTOM];
bool bDeniedInvis[MAXPLAYERSCUSTOM];

float gspeedmulti[MAXPLAYERSCUSTOM];

float speedBefore[MAXPLAYERSCUSTOM];
float speedWeSet[MAXPLAYERSCUSTOM];*/

/*
public Plugin:myinfo=
{
	name="War3Source Buff Speed",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};*/

#if GGAMETYPE == GGAME_CSGO
public void War3Source_Engine_BuffSpeedGravGlow_OnMapStart()
{
		Handle hCvar = FindConVar("sv_disable_immunity_alpha");
		if(hCvar == null)
		{
			PrintToServer("CSGO: Couldn't find cvar: \"sv_disable_immunity_alpha\"");
			PrintToServer("CSGO: Couldn't find cvar: \"sv_disable_immunity_alpha\"");
			PrintToServer("CSGO: Couldn't find cvar: \"sv_disable_immunity_alpha\"");
			PrintToServer("CSGO: Couldn't find cvar: \"sv_disable_immunity_alpha\"");
			PrintToServer("CSGO: Couldn't find cvar: \"sv_disable_immunity_alpha\"");
			return;
		}

		/* Enable convar and make sure it can't be changed by accident. */
		SetConVarInt(hCvar, 1);
		HookConVarChange(hCvar, ConVarChange_DisableImmunityAlpha);
}
public ConVarChange_DisableImmunityAlpha(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(!GetConVarBool(convar))
	{
		/* Force enable sv_disable_immunity_alpha */
		SetConVarInt(convar, 1);
		PrintToServer("[W3SE] sv_disable_immunity_alpha is locked and can't be changed!");
	}
}
public War3Source_Engine_BuffSpeedGravGlow_OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_PostThinkPost, PostThinkPost);
}
public PostThinkPost(client)
{
	//if(war3Game==Game_CS || war3Game==Game_CSGO)
	if(invisWeaponAttachments[client])
	{
		SetEntProp(client, Prop_Send, "m_iAddonBits",0);
	}
}
#endif

public bool:War3Source_Engine_BuffSpeedGravGlow_InitNatives()
{
	CreateNative("W3ReapplySpeed",NW3ReapplySpeed);//for races

#if (GGAMETYPE == GGAME_TF2)
	m_OffsetSpeed=FindSendPropInfo("CTFPlayer","m_flMaxspeed");
#else 
	// FOF, CSS, CSGO
	m_OffsetSpeed=FindSendPropInfo("CBasePlayer","m_flLaggedMovementValue");
#endif

	if(m_OffsetSpeed==-1)
	{
		PrintToServer("[War3Source:EVO] Error finding speed offset.");
	}

	m_OffsetClrRender=FindSendPropInfo("CBaseAnimating","m_clrRender");
	if(m_OffsetClrRender==-1)
	{
		PrintToServer("[War3Source:EVO] Error finding render color offset.");
	}

	CreateNative("W3IsBuffInvised",NW3IsBuffInvised);
	CreateNative("W3GetSpeedMulti",NW3GetSpeedMulti);
	return true;
}

public NW3ReapplySpeed(Handle:plugin,numParams)
{
	int client=GetNativeCell(1);
	Internal_W3ReapplySpeed(client);
}
public Internal_W3ReapplySpeed(int client)
{
	reapplyspeed[client]++;
}

public NW3IsBuffInvised(Handle:plugin,numParams)
{
	int client=GetNativeCell(1);
	return GetEntityAlpha(client)<50;
}
public NW3GetSpeedMulti(Handle:plugin,numParams)
{
	int client=GetNativeCell(1);
	if(ValidPlayer(client,true)){
		float multi=1.0;
#if GGAMETYPE == GGAME_TF2
		if(TF2_IsPlayerInCondition(client,TFCond_SpeedBuffAlly)){
			multi=1.35;
		}
#endif
		return  _:(gspeedmulti[client]*multi +0.001); //rounding error
	}
	return _:1.0;
}

public Engine_BuffSpeedGravGlow_DeciSecondTimer()
{
		if(MapChanging || War3SourcePause) return 0;
		for(int client=1;client<=MaxClients;client++)
		{
			if(ValidPlayer(client,true))
			{
				float gravity=1.0; //default
				if(!GetBuffHasOneTrue(client,bLowGravityDenyAll)&&!W3GetBuffHasTrue(client,bBuffDenyAll)) //can we change gravity?
				{
					float gravity1=GetBuffMinFloat(client,fLowGravitySkill);
					float gravity2=GetBuffMinFloat(client,fLowGravityItem);
					gravity=gravity1<gravity2?gravity1:gravity2;
				}
				///now lets set the grav
				if(GetEntityGravity(client)!=gravity){ ///gravity offset is somewhoe different for each person? this offset is got on PutInServer
					SetEntityGravity(client,gravity);
				}
				///GLOW
				int r=255,g=255,b=255,alpha=255;
				int bestindex=-1;
				int highestvalue=0;
				float settime=0.0;
#if SHOPMENU3 == MODE_ENABLED
				int limit=totalItemsLoaded+GetRacesLoaded()+W3GetItems2Loaded()+W3GetItems3Loaded();
#else
				int limit=totalItemsLoaded+GetRacesLoaded()+W3GetItems2Loaded();
#endif
				for(int i=0;i<=limit;i++){
					if(GetBuff(client,iGlowPriority,i)>highestvalue)
					{
						highestvalue=GetBuff(client,iGlowPriority,i);
						bestindex=i;
						settime=Float:GetBuff(client,fGlowSetTime,i);
					}
					else if(GetBuff(client,iGlowPriority,i)==highestvalue&&highestvalue>0){ //equal priority
						if(GetBuff(client,fGlowSetTime,i)>settime){ //only if this one set it sooner
							highestvalue=GetBuff(client,iGlowPriority,i);
							bestindex=i;
							settime=Float:GetBuff(client,fGlowSetTime,i);
						}
					}
				}
				if(bestindex>-1){
					r=GetBuff(client,iGlowRed,bestindex);
					g=GetBuff(client,iGlowGreen,bestindex);
					b=GetBuff(client,iGlowBlue,bestindex);
					alpha=GetBuff(client,iGlowAlpha,bestindex);
				}
				bool set=false;
				if(GetPlayerR(client)!=r)
					set=true;
				if(GetPlayerG(client)!=g)
					set=true;
				if(GetPlayerB(client)!=b)
					set=true;
				//alpha set is after invis block, not here
				if(set){
					//	PrintToChatAll("%d %d %d %d",r,g,b,alpha);
					SetPlayerRGB(client,r,g,b);
				}
				//invisbility!
				float falpha=1.0;
				if(!GetBuffHasOneTrue(client,bInvisibilityDenySkill))
				{
					falpha=FloatMul(falpha,GetBuffMinFloat(client,fInvisibilitySkill));

				}
				float itemalpha=GetBuffMinFloat(client,fInvisibilityItem);
				if(falpha!=1.0){
					itemalpha=Pow(itemalpha,0.75);
				}
				falpha=FloatMul(falpha,itemalpha);
				int alpha2=RoundFloat(       FloatMul(255.0,falpha)  );
				if(alpha2>=0&&alpha2<=255){
					alpha=alpha2;
				}
				else{
					LogError("alpha playertracking out of bounds 0 - 255");
				}
				if(GetBuffHasOneTrue(client,bInvisibilityDenyAll)||W3GetBuffHasTrue(client,bBuffDenyAll) ){
					if( /*bDeniedInvis[client]==false &&*/ alpha<222) ///buff is not denied
					{
						bDeniedInvis[client]=true;
						W3Hint(client,HINT_NORMAL,4.0,"Cannot Invis. Being revealed");
					}
					alpha=255;
				}
				else{
					bDeniedInvis[client]=false;
				}
				static skipcheckingwearables[MAXPLAYERSCUSTOM];
				if(GetEntityAlpha(client)!=alpha){
					SetEntityAlpha(client,alpha);
					skipcheckingwearables[client]=0;
				}
				if(skipcheckingwearables[client]<=0)
				{
#if GGAMETYPE == GGAME_TF2
					int ent=-1;
					while ((ent = FindEntityByClassname(ent, "tf_wearable")) != -1)
					{
						if(GetEntPropEnt(ent,Prop_Send, "m_hOwnerEntity")==client)
						{
							if(GetEntityAlpha(ent)!=alpha){
								SetEntityAlpha(ent,alpha);
							}
						}
					}
					while ((ent = FindEntityByClassname(ent, "tf_wearable_demoshield")) != -1)
					{
						if(GetEntPropEnt(ent,Prop_Send, "m_hOwnerEntity")==client)
						{
							if(GetEntityAlpha(ent)!=alpha){
								SetEntityAlpha(ent,alpha);
							}
						}
					}
#endif
					for(int i=0;i<10;i++){
						if(-1!=GetPlayerWeaponSlot(client, i))
						{
							int went=GetPlayerWeaponSlot(client, i);
							if(GetEntityAlpha(went)!=alpha)
							{
								SetEntityAlpha(went,alpha);
							}
						}
					}
					skipcheckingwearables[client]=10;
				}
				else{
					skipcheckingwearables[client]--;
				}
				invisWeaponAttachments[client]=alpha<200?true:false;
				int wpn=W3GetCurrentWeaponEnt(client);
				if(wpn>0)
				{
					int alphaw=alpha;
					if(GetBuffHasOneTrue(client,bInvisWeaponOverride))
					{
						int buffloop = BuffLoopLimit();
						for(int i=0;i<=buffloop;i++){
							if(GetBuff(client,bInvisWeaponOverride,i,true))
							{
								alphaw=GetBuffMinInt(client,iInvisWeaponOverrideAmount);
							}
						}

					}
					if(!GetBuffHasOneTrue(client,bDoNotInvisWeapon))
					{
						if(GetEntityAlpha(wpn)!=alphaw)
						{
							SetEntityAlpha(wpn,alphaw);
						}
					}
				}
			}
		}
		return 0;
}

float fclassbasespeed;
float fBeforeSpeedDifferenceMULTI;
float fnewmaxspeed;
float fWarCraftBonus_AND_TF2Bonus;

public War3Source_Engine_BuffSpeedGravGlow_OnGameFrame()
{
	if(MapChanging || War3SourcePause) return 0;

	for(int client=1;client<=MaxClients;client++)
	{
		if(ValidPlayer(client,true))//&&!bIgnoreTrackGF[client])
		{
			/*
			
			How this works:

			The War3Source_Engine_BuffSystem.sp will detect that there was a change in MaxSpeed buff,
			then it will call Internal_W3ReapplySpeed so that reapplyspeed[client]
			is greater than 0, there by forcing this frame to recalculate max speed buff
			then setting it.
			
			*/


			float currentmaxspeed=GetEntDataFloat(client,m_OffsetSpeed);
			//if(bMaxSpeedDebugMessages==true)
			//{
				//PrintToConsole(client,"298 currentmaxspeed=GetEntDataFloat(client,m_OffsetSpeed) = %.2f",currentmaxspeed);
			//}

			//DP("speed %f, speedbefore %f , we set %f",currentmaxspeed,speedBefore[client],speedWeSet[client]);

			if(currentmaxspeed!=speedWeSet[client]) ///SO DID engien set a new speed? copy that!! //TFIsDefaultMaxSpeed(client,currentmaxspeed)){ //ONLY IF NOT SET YET
			{
				speedBefore[client]=currentmaxspeed;
				reapplyspeed[client]++;
			}

			if(reapplyspeed[client]>0)
			{
				reapplyspeed[client]=0;
				//player frame tracking, if client speed is not what we set, we reapply speed
				float speedmulti=1.0;
				//new Float:speedadd=1.0;
				if(!GetBuffHasOneTrue(client,bBuffDenyAll))
				{
					speedmulti=W3GetBuffMaxFloat(client,fMaxSpeed)+W3GetBuffMaxFloat(client,fMaxSpeed2)-1.0;
					if(bMaxSpeedDebugMessages==true)
					{
						PrintToConsole(client,"317 speedmulti = %.2f",speedmulti);
					}
				}
				if(GetBuffHasOneTrue(client,bStunned)||GetBuffHasOneTrue(client,bBashed))
				{
					//DP("stunned or bashed");
					speedmulti=0.0;
					if(bMaxSpeedDebugMessages==true)
					{
						PrintToConsole(client,"326 speedmulti = %.2f",speedmulti);
					}
				}
				if(!GetBuffHasOneTrue(client,bSlowImmunity))
				{
					speedmulti=FloatMul(speedmulti,GetBuffStackedFloat(client,fSlow));
					if(bMaxSpeedDebugMessages==true)
					{
						PrintToConsole(client,"334 speedmulti = %.2f",speedmulti);
					}
					speedmulti=FloatMul(speedmulti,GetBuffStackedFloat(client,fSlow2));
					if(bMaxSpeedDebugMessages==true)
					{
						PrintToConsole(client,"339 speedmulti = %.2f",speedmulti);
					}
				}

#if GGAMETYPE == GGAME_TF2
				if(fWar3_MaxSpeedLimit>0.0)
				{
					if(bMaxSpeedDebugMessages==true)
					{
						PrintToConsole(client,"------------------------------------------------------------");
						PrintToConsole(client,"speedmulti = %.2f",speedmulti);
						PrintToConsole(client,"speedWeSet[client] = %.2f",speedWeSet[client]);
						PrintToConsole(client,"speedBefore[client] = %.2f",speedBefore[client]);
					}

					//Create Speed Limit
					//This is our Max Speed Limit
					fclassbasespeed=TF2_GetClassSpeed(p_properties[client][CurrentClass]);
					fclassbasespeed=TF2_GetClassSpeed(p_properties[client][CurrentClass]);

					if(bMaxSpeedDebugMessages==true)
					{
						PrintToConsole(client,"fclassbasespeed is %.2f",fclassbasespeed);
					}

					fBeforeSpeedDifferenceMULTI = FloatDiv(speedBefore[client],fclassbasespeed);

					if(bMaxSpeedDebugMessages==true)
					{
						PrintToConsole(client,"fBeforeSpeedDifferenceMULTI is %.2f",fBeforeSpeedDifferenceMULTI);
					}

					if(fBeforeSpeedDifferenceMULTI>=fWar3_MaxSpeedLimit)
					{
						if(bMaxSpeedDebugMessages==true)
						{
							PrintToConsole(client,"if(fBeforeSpeedDifferenceMULTI>=fWar3_MaxSpeedLimit)");
						}
						// apply no bonuses and don't change speed
						speedmulti=fBeforeSpeedDifferenceMULTI;
						if(bMaxSpeedDebugMessages==true)
						{
							PrintToConsole(client,"apply no bonuses and don't change speed");
						}

						currentmaxspeed=fclassbasespeed;
						if(bMaxSpeedDebugMessages==true)
						{
							PrintToConsole(client,"currentmaxspeed=fclassbasespeed %.2f",currentmaxspeed);
						}
					}
					else
					{
						if(bMaxSpeedDebugMessages==true)
						{
							PrintToConsole(client,"if(fBeforeSpeedDifferenceMULTI>=fWar3_MaxSpeedLimit) ELSE");
						}

						fWarCraftBonus_AND_TF2Bonus = FloatAdd(fBeforeSpeedDifferenceMULTI,speedmulti)-1.0;
						if(bMaxSpeedDebugMessages==true)
						{
							PrintToConsole(client,"fWarCraftBonus_AND_TF2Bonus is %.2f",fWarCraftBonus_AND_TF2Bonus);
						}

						if(bMaxSpeedDebugMessages==true)
						{
							PrintToConsole(client,"if(fWar3_MaxSpeedLimit>0.0)");
						}
						if(fWarCraftBonus_AND_TF2Bonus>=fWar3_MaxSpeedLimit)
						{
							if(bMaxSpeedDebugMessages==true)
							{
								PrintToConsole(client,"if(War3Source_MaxSpeedLimit>0.0)");
							}

							speedmulti = fWar3_MaxSpeedLimit;
							if(bMaxSpeedDebugMessages==true)
							{
								PrintToConsole(client,"speedmulti = fWar3_MaxSpeedLimit = %.2f",speedmulti);
							}
							if(fBeforeSpeedDifferenceMULTI!=0.0)
							{
								speedBefore[client]=FloatMul(fclassbasespeed,fBeforeSpeedDifferenceMULTI);
								if(bMaxSpeedDebugMessages==true)
								{
									PrintToConsole(client,"speedBefore[client]=FloatMul(fclassbasespeed,fBeforeSpeedDifferenceMULTI) is %.2f",speedBefore[client]);
								}
							}
							else
							{
								speedBefore[client]=currentmaxspeed;
								if(bMaxSpeedDebugMessages==true)
								{
									PrintToConsole(client,"speedBefore[client]=currentmaxspeed is %.2f",speedBefore[client]);
								}
							}
						}
						else
						{
							speedmulti=fWarCraftBonus_AND_TF2Bonus;
						}
					}

					gspeedmulti[client]=speedmulti;
					if(bMaxSpeedDebugMessages==true)
					{
						PrintToConsole(client,"gspeedmulti[client]=speedmulti = %.2f",gspeedmulti[client]);
						PrintToConsole(client,"fclassbasespeed = %.2f",fclassbasespeed);
					}
					fnewmaxspeed=FloatMul(fclassbasespeed,speedmulti);
					if(fnewmaxspeed<0.1)
					{
						fnewmaxspeed=0.1;
					}
					speedWeSet[client]=fnewmaxspeed;
					if(bMaxSpeedDebugMessages==true)
					{
						PrintToConsole(client,"speedWeSet[client]=fnewmaxspeed = %.2f",fnewmaxspeed);
					}
				}
				else
				{
					gspeedmulti[client]=speedmulti;
					if(bMaxSpeedDebugMessages==true)
					{
						PrintToConsole(client,"gspeedmulti[client]=speedmulti = %.2f",gspeedmulti[client]);
						PrintToConsole(client,"speedBefore[client] = %.2f",speedBefore[client]);
					}
					fnewmaxspeed=FloatMul(speedBefore[client],speedmulti);
					if(fnewmaxspeed<0.1)
					{
						fnewmaxspeed=0.1;
					}
					speedWeSet[client]=fnewmaxspeed;
					if(bMaxSpeedDebugMessages==true)
					{
						PrintToConsole(client,"speedWeSet[client]=fnewmaxspeed = %.2f",fnewmaxspeed);
					}
				}
#else
				if(bMaxSpeedDebugMessages==true)
				{
					PrintToConsole(client,"472 speedmulti = %.2f",speedmulti);
					PrintToConsole(client,"473 speedBefore[client] = %.2f",speedBefore[client]);
				}
				gspeedmulti[client]=speedmulti;
				if(speedmulti<=0)
				{
					speedmulti=1.0;
				}
				fnewmaxspeed=FloatMul(speedBefore[client],speedmulti);
				if(bMaxSpeedDebugMessages==true)
				{
					PrintToConsole(client,"479 fnewmaxspeed = %.2f",fnewmaxspeed);
				}
				if(fnewmaxspeed<0.1)
				{
					fnewmaxspeed=0.1;
				}
				speedWeSet[client]=fnewmaxspeed;
				
				if(bMaxSpeedDebugMessages==true)
				{
					PrintToConsole(client,"488 speedWeSet[client]=fnewmaxspeed = %.2f",fnewmaxspeed);
				}
#endif

#if GGAMETYPE == GGAME_FOF
				SetEntDataFloat(client,m_OffsetSpeed,fnewmaxspeed,true);  // Testing for FOF
#else
				SetEntDataFloat(client,m_OffsetSpeed,fnewmaxspeed,true);
#endif
			}
			new MoveType:currentmovetype=GetEntityMoveType(client);
			new MoveType:shouldmoveas=MOVETYPE_WALK;
			if(GetBuffHasOneTrue(client,bNoMoveMode)){
				shouldmoveas=MOVETYPE_NONE;
			}
			if(GetBuffHasOneTrue(client,bNoClipMode)){
				shouldmoveas=MOVETYPE_NOCLIP;
			}
			else if(GetBuffHasOneTrue(client,bFlyMode)&&!W3GetBuffHasTrue(client,bFlyModeDeny)){
				shouldmoveas=MOVETYPE_FLY;
			}

			if(currentmovetype!=shouldmoveas){
				SetEntityMoveType(client,shouldmoveas);
			}
		}
	}
	return 0;
}

// FX Distort == 14
// Render TransAdd == 5
stock SetEntityAlpha(index,alpha)
{
	new String:class[32];
	GetEntityNetClass(index, class, sizeof(class) );
	if(FindSendPropInfo(class,"m_nRenderFX")>-1){
		SetEntityRenderMode(index,RENDER_TRANSCOLOR);
		SetEntityRenderColor(index,GetPlayerR(index),GetPlayerG(index),GetPlayerB(index),alpha);
	}
}

stock GetWeaponAlpha(client)
{
	int wep=W3GetCurrentWeaponEnt(client);
	if(wep>MaxClients && IsValidEdict(wep))
	{
		return GetEntityAlpha(wep);
	}
	return 255;
}


