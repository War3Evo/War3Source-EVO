/**
 * File: War3Source_Effects.inc
 * Description: Finally collecting some methods I keep copying over and over again
 * Author(s): Glider
 *
 */

//=============================================================================
// Screen effects
//=============================================================================
/**
 * Flashes a player's screen a certain color for a duration.
 * @param client: Client's index.
 * @param color[4]: RGBA value of the color, see above for presets.
 * @param duration: Length of flash, optional.
 * @param flags: Flags of Fade user message, optional.
 * @noreturn
 */
native W3FlashScreen(client,color[4],Float:holdduration=0.1,Float:fadeduration=0.2,flags=FFADE_IN);

/**
 * Shakes a player's screen at a magnitude and noise for a duration.
 * @param client: Client's index.
 * @param duration: Optional, how long to shake.
 * @param magnitude: Optional magnitude value.
 * @param noise: Optional noise value.
 * @noreturn
 */
native War3_ShakeScreen(client,Float:duration=1.0,Float:magnitude=40.0,Float:noise=30.0);

#if (GGAMETYPE == GGAME_TF2)
//Sends a particle to client like "miss_text"
native War3_TF_ParticleToClient(clienttoshowto,String:particlestr[],Float:pos[3]);
#endif

///LOOK FURTHER DOWN FOR SIMPLIFIED STOCK FUNCTIONS
//=============================================================================
// Particle effects
//=============================================================================

/**
 * CreateW3SParticle
 *
 * @param String:effectName Name of the particle effect you want to spawn.
 * 							Don't forget to precache this OnMapStart!
 * @param Float:fPos[3] Position to spawn the particle at
 *
 * @returns entity index for the particle or -1 if no particle was spawned
 */
stock CreateW3SParticle(const String:effectName[], const Float:fPos[3], const Float:fAngles[3]=NULL_VECTOR)
{
	new particle = CreateEntityByName("info_particle_system");
	if (IsValidEdict(particle))
	{
		TeleportEntity(particle, fPos, fAngles, NULL_VECTOR);
		DispatchKeyValue(particle, "effect_name", effectName);
		DispatchSpawn(particle);

		ActivateEntity(particle);
		AcceptEntityInput(particle, "Start");

		return particle;
	}
	else
	{
		PrintToServer("Couldn't create info_particle_system!");
	}

	return -1;
}

/**
 * CreateW3SLight
 *
 * Spawns a light_dynamic at a fixed position.
 *
 * @param Float:fPos[3] Position to spawn the light at
 * @param String:color RGBA value of the color like "255 255 255 255"
 * @param String:style See http://developer.valvesoftware.com/wiki/Light under "Appearances"
 * @param distance how far the light stretches
 *
 * @returns the entinty index of the light or -1 if there was none created
 */
stock CreateW3SLight(const Float:fPos[3], const String:color[], const String:style[], const Float:distance)
{
	new light = CreateEntityByName("light_dynamic");
	if (IsValidEdict(light))
	{
		DispatchKeyValue(light, "_light", color);
		DispatchKeyValue(light, "brightness", "1");

		// Not so sure how this changes the looks.
		DispatchKeyValueFloat(light, "spotlight_radius", 32.0);
		DispatchKeyValueFloat(light, "distance", distance);
		DispatchKeyValue(light, "style", style);
		DispatchSpawn(light);
		AcceptEntityInput(light, "TurnOn");

		TeleportEntity(light, fPos, NULL_VECTOR, NULL_VECTOR);

		return light;
	}
	else
	{
		PrintToServer("Couldn't create light_dynamic!");
	}

	return -1;
}

/**
 * ModifyEntityAddDeathTimer
 *
 * @param entityIndex Entity index you want to modify
 * @param Float:w3lifetime Seconds after wich the entity should be killed
 */
stock ModifyEntityAddDeathTimer(const entityIndex, const Float:w3lifetime)
{
	if (IsValidEdict(entityIndex))
	{
		decl String:variantString[60];
		Format(variantString, sizeof(variantString), "OnUser1 !self:Kill::%f:-1", w3lifetime);

		SetVariantString(variantString);
		AcceptEntityInput(entityIndex, "AddOutput");
		AcceptEntityInput(entityIndex, "FireUser1");
	}
}

/**
 * ModifyEntityAttach
 *
 * http://developer.valvesoftware.com/wiki/Entity_Hierarchy_%28parenting%29
 *
 * @param entityIndex Entity index of the entity you want to modify
 * @param otherEntityIndex Entity index to attach the particle to
 * @param String:attachTo Attachment point of the otherEntityIndex.
 * 						  Leave this out or set it to "" when you don't want
 * 						  to attach to any specific point.
 */
stock ModifyEntityAttach(const entityIndex, const otherEntityIndex, const String:attachTo[]="")
{
	if (IsValidEdict(entityIndex))
	{
		SetVariantString("!activator");
		AcceptEntityInput(entityIndex, "SetParent", otherEntityIndex, entityIndex, 0);

		if (!StrEqual(attachTo, ""))
		{
			SetVariantString(attachTo);
			AcceptEntityInput(entityIndex, "SetParentAttachment", entityIndex, entityIndex, 0);
		}
	}
}

//=============================================================================
//                                 One liners...
//=============================================================================

//=========================================
//                 PARTICLES
//==========================================

stock ThrowAwayParticle(const String:effectName[], const Float:fPos[3], const Float:w3lifetime)
{
	new particle = CreateW3SParticle(effectName, fPos);
	ModifyEntityAddDeathTimer(particle, w3lifetime);

	return particle;
}

// If you have an attachment point you can pass NULL_VECTOR to fPos
stock AttachParticle(const client, const String:effectName[], const Float:fPos[3], const String:attachTo[]="")
{
	new particle = CreateW3SParticle(effectName, fPos);
	ModifyEntityAttach(particle, client, attachTo);

	return particle;
}

// If you have an attachment point you can pass NULL_VECTOR to fPos
stock AttachThrowAwayParticle(const client, const String:effectName[], const Float:fPos[3], const String:attachTo[], const Float:w3lifetime, const Float:fAngles[3]=NULL_VECTOR)
{
	new particle = CreateW3SParticle(effectName, fPos, fAngles);
	ModifyEntityAttach(particle, client, attachTo);
	ModifyEntityAddDeathTimer(particle, w3lifetime);

	return particle;
}

//=========================================
//                 LIGHTS
//==========================================

stock ThrowAwayLightEmitter(const Float:fPos[3], const String:color[], const String:style[], const Float:distance, const Float:w3lifetime)
{
	new light = CreateW3SLight(fPos, color, style, distance);
	ModifyEntityAddDeathTimer(light, w3lifetime);
}

// If you have an attachment point you can pass NULL_VECTOR to fPos
stock AttachLight(const client, const Float:fPos[3], const String:color[], const String:style[], const Float:distance, const String:attachTo[])
{
	new light = CreateW3SLight(fPos, color, style, distance);
	ModifyEntityAttach(light, client, attachTo);

	return light;
}

// If you have an attachment point you can pass NULL_VECTOR to fPos
stock AttachThrowAwayLight(const client, const Float:fPos[3], const String:color[], const String:style[], const Float:distance, const String:attachTo[], const Float:w3lifetime)
{
	new light = CreateW3SLight(fPos, color, style, distance);
	ModifyEntityAttach(light, client, attachTo);
	ModifyEntityAddDeathTimer(light, w3lifetime);

	return light;
}

//=============================================================================
//                                 Temp Entitys
//=============================================================================

stock TE_SetupBubbles(const Float:vecOrigin[3], const Float:vecFinish[3],modelIndex,const Float:heightF,count,const Float:speedF)
{
	TE_Start("Bubbles");
	TE_WriteVector("m_vecMins", vecOrigin);
	TE_WriteVector("m_vecMaxs", vecFinish);
	TE_WriteFloat("m_fHeight", heightF);
	TE_WriteNum("m_nModelIndex", modelIndex);
	TE_WriteNum("m_nCount", count);
	TE_WriteFloat("m_fSpeed", speedF);
}
