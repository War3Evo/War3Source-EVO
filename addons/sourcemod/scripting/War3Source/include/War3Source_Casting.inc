
/**
 * File: War3Source_Casting.inc
 * Description: Easier stocks for casting
 * Author(s): War3Source Team
 */

#if defined War3Source_Casting
 #endinput
#endif
#define War3Source_Casting


#include <sdktools_functions>
#include <sdktools_entinput>

enum W3SpellEffects
{
	NoSpellEffects=0,
	SpellEffectsPhysical,
	SpellEffectsArcane,
	SpellEffectsFire,
	SpellEffectsFrost,
	SpellEffectsNature,
	SpellEffectsDarkness,
	SpellEffectsLight,
}

enum W3SpellColor
{
	NoSpellColor=0,
	SpellColorYellow,
	SpellColorGreen,
	SpellColorBlue,
	SpellColorRed,
}


/*
 * Returns if successful
 *
 * */

// if castingid = 0, then it will bring up a menu for the person wanting to cancel a spell.
native bool:War3_CancelSpell(client, target, castingid=0);

native bool:War3_CastSpell(client, target, W3SpellEffects:spelleffect, String:SpellColor[], raceid, SkillID, Float:duration);

native bool:War3_IsThirdPerson(client);

native War3_ForceThirdPerson(client,bool:ForcePlayer);


/**
 * OnWar3StartCasting
 *
 * @param client			client's index.
 * @param target			client's target
 * @param spelleffect		spell effect
 * @param SpellColor		SpellColor = "r g b"
 * @param raceid			race index
 * @param skillid			skill index / also known as castingid
 * @return 					none
 */
forward OnWar3CastingStarted(client, target, W3SpellEffects:spelleffect, String:SpellColor[], raceid, skillid);

/**
 * OnWar3CastingStarted_Pre
 *
 * @param client			client's index.
 * @param target			client's target
 * @param spelleffect		spell effect
 * @param SpellColor		SpellColor = "r g b"
 * @param raceid			race index
 * @param skillid			skill index / also known as castingid
 * @param fcastingtime		change the casting time here (float)
 * @return 					none
 */
forward Action OnWar3CastingStarted_Pre(int client, int target, W3SpellEffects spelleffect, char[] SpellColor, int raceid, int skillid, float &fcastingtime);

/**
 * OnWar3CastingFinished_Pre
 *
 * @param client			client's index.
 * @param target			client's target
 * @param spelleffect		spell effect
 * @param SpellColor		SpellColor = "r g b"
 * @param raceid			race index
 * @param skillid			skill index / also known as castingid
 * @return 					return Plugin_Handled or Plugin_Stop to prevent the spell from finshing, otherwise use Plugin_Continue
 */
forward Action:OnWar3CastingFinished_Pre(client, target, W3SpellEffects:spelleffect, String:SpellColor[], raceid, skillid);

/**
 * OnWar3EndCasting
 *
 * @param client			client's index.
 * @param target			client's target
 * @param spelleffect		spell effect
 * @param SpellColor		SpellColor = "r g b"
 * @param raceid			race index
 * @param skillid			skill index / also known as castingid
 * @return 					none
 */
forward OnWar3CastingFinished(client, target, W3SpellEffects:spelleffect, String:SpellColor[], raceid, skillid);


/**
 * OnWar3CancelSpell_Post
 *
 * @param client			client's index. (The caster)
 * @param raceid			client's raceid index. (The caster's raceid)
 * @param skillid			client's skill index / also known as castingid (The Caster's Skill)
 * @param target			client's target
 * @return 					none
 */
forward OnWar3CancelSpell_Post(client, raceid, skillid, target);


stock TE_SetupDynamicLight(const Float:vecOrigin[3], r,g,b,iExponent,Float:fRadius,Float:fTime,Float:fDecay)
{
	TE_Start("Dynamic Light");
	TE_WriteVector("m_vecOrigin",vecOrigin);
	TE_WriteNum("r",r);
	TE_WriteNum("g",g);
	TE_WriteNum("b",b);
	TE_WriteNum("exponent",iExponent);
	TE_WriteFloat("m_fRadius",fRadius);
	TE_WriteFloat("m_fTime",fTime);
	TE_WriteFloat("m_fDecay",fDecay);
}


stock CreateParticlesUp(const client,bool:parentent,Float:fLifetime,Float:BaseSpread,Float:StartSize,Float:EndSize,Float:Twist,String:material[],String:renderclr[],String:SpreadSpeed[],String:JetLength[],String:Speed[],String:Rate[])
{
	new particle = CreateEntityByName("env_smokestack");
	if(IsValidEdict(particle) && IsClientInGame(client))
	{
		new Float:fAng[3]={0.0,0.0,0.0};
		decl String:Name[32], Float:fPos[3];
		Format(Name, sizeof(Name), "W3S_particles_%i", client);
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", fPos);
		//fPos[2] += 150.0;
		// Set Key Values
		DispatchKeyValueVector(particle, "Origin", fPos);
		DispatchKeyValueVector(particle, "Angles", fAng);
		DispatchKeyValueFloat(particle, "BaseSpread", BaseSpread);
		DispatchKeyValueFloat(particle, "StartSize", StartSize);
		DispatchKeyValueFloat(particle, "EndSize", EndSize);
		DispatchKeyValueFloat(particle, "Twist", Twist);

		DispatchKeyValue(particle, "Name", Name);
		DispatchKeyValue(particle, "SmokeMaterial", material);
		DispatchKeyValue(particle, "RenderColor", renderclr);
		DispatchKeyValue(particle, "SpreadSpeed", SpreadSpeed);
		DispatchKeyValue(particle, "RenderAmt", "255");
		DispatchKeyValue(particle, "JetLength", JetLength);
		DispatchKeyValue(particle, "RenderMode", "0");
		DispatchKeyValue(particle, "Initial", "0");
		DispatchKeyValue(particle, "Speed", Speed);
		DispatchKeyValue(particle, "Rate", Rate);
		DispatchSpawn(particle);

		// Set Entity Inputs
		if(parentent)
		{
			SetVariantString("!activator");
			AcceptEntityInput(particle, "SetParent", client, particle, 0);
		}
		AcceptEntityInput(particle, "TurnOn");
		CreateTimer(fLifetime, INCTimer_RemoveEntity, particle);
		return particle;
	}
	else
	{
		LogError("Failed to create entity env_smokestack!");
	}
	return -1;
}

stock CreateParticlesDown(const client,bool:parentent,Float:fLifetime,Float:BaseSpread,Float:StartSize,Float:EndSize,Float:Twist,String:material[],String:renderclr[],String:SpreadSpeed[],String:JetLength[],String:Speed[],String:Rate[])
{
	new particle = CreateEntityByName("env_smokestack");
	if(IsValidEdict(particle) && IsClientInGame(client))
	{
		new Float:fAng[3]={0.0,0.0,180.0};
		decl String:Name[32], Float:fPos[3];
		Format(Name, sizeof(Name), "W3S_particles_%i", client);
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", fPos);
		fPos[2] += 250.0;
		// Set Key Values
		DispatchKeyValueVector(particle, "Origin", fPos);
		DispatchKeyValueVector(particle, "Angles", fAng);
		DispatchKeyValueFloat(particle, "BaseSpread", BaseSpread);
		DispatchKeyValueFloat(particle, "StartSize", StartSize);
		DispatchKeyValueFloat(particle, "EndSize", EndSize);
		DispatchKeyValueFloat(particle, "Twist", Twist);

		DispatchKeyValue(particle, "Name", Name);
		DispatchKeyValue(particle, "SmokeMaterial", material);
		DispatchKeyValue(particle, "RenderColor", renderclr);
		DispatchKeyValue(particle, "SpreadSpeed", SpreadSpeed);
		DispatchKeyValue(particle, "RenderAmt", "255");
		DispatchKeyValue(particle, "JetLength", JetLength);
		DispatchKeyValue(particle, "RenderMode", "0");
		DispatchKeyValue(particle, "Initial", "0");
		DispatchKeyValue(particle, "Speed", Speed);
		DispatchKeyValue(particle, "Rate", Rate);
		DispatchSpawn(particle);

		// Set Entity Inputs
		if(parentent)
		{
			SetVariantString("!activator");
			AcceptEntityInput(particle, "SetParent", client, particle, 0);
		}
		AcceptEntityInput(particle, "TurnOn");
		CreateTimer(fLifetime, INCTimer_RemoveEntity, particle);
		return particle;
	}
	else
	{
		LogError("Failed to create entity env_smokestack!");
	}
	return -1;
}

stock CreateParticlesDownLoc(Float:fPos[3],Float:fLifetime,Float:BaseSpread,Float:StartSize,Float:EndSize,Float:Twist,String:material[],String:renderclr[],String:SpreadSpeed[],String:JetLength[],String:Speed[],String:Rate[])
{
	new particle = CreateEntityByName("env_smokestack");
	if(IsValidEdict(particle))
	{
		new Float:fAng[3]={0.0,0.0,180.0};
		decl String:Name[32];
		Format(Name, sizeof(Name), "W3S_particles_%i", particle);
		fPos[2] += 250.0;
		// Set Key Values
		DispatchKeyValueVector(particle, "Origin", fPos);
		DispatchKeyValueVector(particle, "Angles", fAng);
		DispatchKeyValueFloat(particle, "BaseSpread", BaseSpread);
		DispatchKeyValueFloat(particle, "StartSize", StartSize);
		DispatchKeyValueFloat(particle, "EndSize", EndSize);
		DispatchKeyValueFloat(particle, "Twist", Twist);

		DispatchKeyValue(particle, "Name", Name);
		DispatchKeyValue(particle, "SmokeMaterial", material);
		DispatchKeyValue(particle, "RenderColor", renderclr);
		DispatchKeyValue(particle, "SpreadSpeed", SpreadSpeed);
		DispatchKeyValue(particle, "RenderAmt", "255");
		DispatchKeyValue(particle, "JetLength", JetLength);
		DispatchKeyValue(particle, "RenderMode", "0");
		DispatchKeyValue(particle, "Initial", "0");
		DispatchKeyValue(particle, "Speed", Speed);
		DispatchKeyValue(particle, "Rate", Rate);
		DispatchSpawn(particle);

		AcceptEntityInput(particle, "TurnOn");
		CreateTimer(fLifetime, INCTimer_RemoveEntity, particle);
		return particle;
	}
	else
	{
		LogError("Failed to create entity env_smokestack!");
	}
	return -1;
}

public Action:INCTimer_RemoveEntity(Handle:timer, any:edict)
{
	if(IsValidEdict(edict))
	{
		AcceptEntityInput(edict, "Kill");
	}
}

