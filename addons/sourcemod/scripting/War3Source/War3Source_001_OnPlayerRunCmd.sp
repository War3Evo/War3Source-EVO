// War3Source_Engine_OnPlayerRunCmd.sp

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if(MapChanging || War3SourcePause) return Plugin_Continue;
//=============================
// War3Source_Engine_BuffSpeedGravGlow
//=============================
	if(ValidPlayer(client,true)){ //block attack
		if(GetBuffHasOneTrue(client,bStunned)||GetBuffHasOneTrue(client,bDisarm)){
			if((buttons & IN_ATTACK) || (buttons & IN_ATTACK2))
			{
				buttons &= ~IN_ATTACK;
				buttons &= ~IN_ATTACK2;
			}
		}
	}

//=============================
// War3Source_Engine_PlayerClass
//=============================
	if(ValidPlayer(client)){
		p_properties[client][bIsDucking]=(buttons & IN_DUCK)?true:false; //hope its faster


		if(GetBuffHasOneTrue(client,bStunned)||GetBuffHasOneTrue(client,bDisarm)){
			if((buttons & IN_ATTACK) || (buttons & IN_ATTACK2))
			{
				buttons &= ~IN_ATTACK;
				buttons &= ~IN_ATTACK2;
			}
		}
	}

//=============================
// War3Source_Engine_Weapon
//=============================
	if(ValidPlayer(client,true)){
		static bool:wasdisarmed[MAXPLAYERSCUSTOM];
		if(GetBuffHasOneTrue(client,bStunned)||GetBuffHasOneTrue(client,bDisarm)){
			wasdisarmed[client]=true;
			new ent = GetCurrentWeaponEnt(client);
			if(ent != -1)
			{
				 SetEntPropFloat(ent, Prop_Send, "m_flNextPrimaryAttack", GetGameTime()+0.2);
			}
		}
		else if(	wasdisarmed[client]){
			wasdisarmed[client]=false;

			new ent = GetCurrentWeaponEnt(client);
			if(ent != -1)
			{
				 SetEntPropFloat(ent, Prop_Send, "m_flNextPrimaryAttack", GetGameTime());
			}
		}
	}

	return Plugin_Continue;
}
