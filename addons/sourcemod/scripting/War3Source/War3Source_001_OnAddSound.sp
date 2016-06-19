// War3Source_Engine_OnAddSound.sp

public OnAddSound(sound_priority)
{
	War3Source_Engine_CooldownMgr_OnAddSound(sound_priority);
#if GGAMETYPE == GGAME_TF2
#if CYBORG_SKIN == MODE_ENABLED
	War3Source_Engine_Cyborg_OnAddSound(sound_priority);
#endif
#endif
	War3Source_Engine_DamageSystem_OnAddSound(sound_priority);
	War3Source_Engine_MenuShopmenu_OnAddSound(sound_priority);
	War3Source_Engine_PlayerClass_OnAddSound(sound_priority);
	War3Source_Engine_SkillEffects_OnAddSound(sound_priority);
	War3Source_Engine_Wards_Wards_OnAddSound(sound_priority);
	War3Source_Engine_XPGold_OnAddSound(sound_priority);
	//War3Source_Engine_XP_Platinum_OnAddSound(sound_priority);

	War3Source_Engine_WCX_Engine_Skills_OnAddSound(sound_priority);
	War3Source_Engine_WCX_Engine_Teleport_OnAddSound(sound_priority);
}
