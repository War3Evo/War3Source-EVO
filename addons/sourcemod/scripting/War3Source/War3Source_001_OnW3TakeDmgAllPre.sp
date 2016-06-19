// War3Source_Engine_DamageSystem_OnW3TakeDmgAllPre.sp

public OnW3TakeDmgAllPre(victim,attacker,Float:damage)
{
	if(MapChanging || War3SourcePause) return 0;

	War3Source_Engine_NewPlayers_OnW3TakeDmgAllPre(victim,attacker,damage);

	War3Source_Engine_BotControl_OnW3TakeDmgAllPre(victim, attacker, damage);

//#if (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
	//War3Source_Engine_PlayerDeathWeapons_OnW3TakeDmgAllPre(victim, attacker, damage);
//#endif

	return 0;
}
