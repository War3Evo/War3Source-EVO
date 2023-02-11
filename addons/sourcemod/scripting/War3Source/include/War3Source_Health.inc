
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
#if (GGAMETYPE == GGAME_FOF)
	War3_HealToMaxHP(entity, health);
#else
	int currenthp = GetEntProp(entity, Prop_Data, "m_iHealth");

	//War3_ChatMessage(entity, "currenthp = %i", currenthp);
	//War3_ChatMessage(entity, "health to add = %i", health);
	if (currenthp == health)
	{
		//War3_ChatMessage(entity, "1 return false");
		return false;
	}

	SetEntProp(entity, Prop_Data, "m_iHealth", health);
	ChangeEdictState(entity, 0);

	if (currenthp < health)
	{
		//War3_ChatMessage(entity, "1 return true");
		return true;
	}

	//War3_ChatMessage(entity, "2 return true");
	return false;
#endif
}

/**
 * Creates a event to show a player in the HUD how much HP he has healed
 */
stock War3_TFHealingEvent(client, amount_healed)
{
#if (GGAMETYPE == GGAME_TF2)
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
