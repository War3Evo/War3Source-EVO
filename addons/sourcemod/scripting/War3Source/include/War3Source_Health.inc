
//=============================================================================
// Health
//=============================================================================
/**
 * heals with the limit of (warcraft ) max hp
 * @noreturn
 */
native bool:War3_HealToMaxHP(client, addhp);

/**
 * heals to max hp * 1.5 buff in tf2
 * no extra hp in other games
 * @noreturn
 */
native War3_HealToBuffHP(client, addhp);

/**
 * direcly decreases the player's hp by X amount (Not via damage)
 * this health removal is "non lethal"
 */
native War3_DecreaseHP(client, decrease);

// This one is actually used by HealToMaxHP, HealToBuffHP aswell as DecreaseHP
stock bool:nsEntity_SetHealth(entity, health)
{
	new currenthp = GetEntProp(entity, Prop_Data, "m_iHealth");

	if (currenthp == health)
	{
		return false;
	}

	SetEntProp(entity, Prop_Data, "m_iHealth", health);
	ChangeEdictState(entity, 0);

	if (currenthp < health)
	{
		return true;
	}

	return false;
}

/**
 * Creates a event to show a player in the HUD how much HP he has healed
 */
stock War3_TFHealingEvent(client, amount_healed)
{
#if GGAMETYPE == GGAME_TF2
	if (!ValidPlayer(client, true) || IsFakeClient(client))
	{
		return;
	}

	new Handle:event = CreateEvent("player_healonhit");
	SetEventInt(event, "entindex", client);
	SetEventInt(event, "amount", amount_healed);
	FireEvent(event);
#else
	return;
#endif
}
