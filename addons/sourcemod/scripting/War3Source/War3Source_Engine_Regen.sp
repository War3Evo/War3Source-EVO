// War3Source_Engine_Regen.sp

//#assert GGAMEMODE == MODE_WAR3SOURCE

/*
public Plugin:myinfo=
{
	name="W3S Engine HP Regen",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};
*/

//new Float:nextRegenTime[MAXPLAYERSCUSTOM];
#if GGAMETYPE == GGAME_TF2
int tf2displayskip[MAXPLAYERSCUSTOM]; //health sign particle
#endif
float lastTickTime[MAXPLAYERSCUSTOM];

public War3Source_Engine_Regen_OnWar3EventSpawn(client)
{
	lastTickTime[client]=GetEngineTime();
}
public War3Source_Engine_Regen_OnGameFrame()
{
#if GGAMETYPE == GGAME_TF2
	decl Float:playervec[3];
#endif

	new Float:now=GetEngineTime();
	for(new client=1;client<=MaxClients;client++)
	{
		if(ValidPlayer(client,true))
		{

			new Float:fbuffsum=0.0;
			if(!GetBuffHasOneTrue(client,bBuffDenyAll)){
				fbuffsum+=GetBuffSumFloat(client,fHPRegen);
			}
			fbuffsum-=GetBuffSumFloat(client,fHPDecay);
			if(fbuffsum<0.01&&fbuffsum>-0.01){ //no decay or regen, set tick time only
				lastTickTime[client]=now;
				continue;
			}
			new Float:period=FloatAbs(1.0/fbuffsum);
			if(now-lastTickTime[client]>period)
			{
				lastTickTime[client]+=period;
				//PrintToChat(client,"regein tick %f %f",fbuffsum,now);
				if(fbuffsum>0.01){ //heal
					War3_HealToMaxHP(client,1);
#if GGAMETYPE == GGAME_TF2
					tf2displayskip[client]++;
					if(tf2displayskip[client]>4 && !IsInvis(client)){
						new Float:VecPos[3];
						GetClientAbsOrigin(client,VecPos);
						VecPos[2]+=55.0;
						TE_ParticleToClient(0, GetApparentTeam(client)==TEAM_RED?"healthgained_red":"healthgained_blu", VecPos);
						tf2displayskip[client]=0;
					}
#endif
				}

				if(fbuffsum<-0.01){ //decay
#if GGAMETYPE == GGAME_TF2
					if(W3Chance(0.25)  && !IsInvis(client)){
						GetClientAbsOrigin(client,playervec);
						TE_ParticleToClient(0, GetApparentTeam(client)==TEAM_RED?"healthlost_red":"healthlost_blu", playervec);
					}
#endif
					if(GetClientHealth(client)>1){
						SetEntityHealth(client,GetClientHealth(client)-1);

					}
					else
					{
#if GGAMETYPE == GGAME_TF2
						DealDamage(client,1,_,_,"bleed_kill",_,W3DMGTYPE_TRUEDMG);
#elseif (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
						DealDamage(client,1,_,_,"damageovertime",_,W3DMGTYPE_TRUEDMG);
#endif
					}
				}
			}

		}
	}
}
