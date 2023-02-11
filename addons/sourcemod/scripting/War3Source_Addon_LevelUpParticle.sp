#include <war3source>

#define PLUGIN_VERSION "0.0.0.1"
/**
 * File: War3Source_Addon_LevelUpParticle.sp
 * Description: Displays particles whenever somebody levels up.
 * Author(s): Glider & xDr.HaaaaaaaXx
 */

//#pragma semicolon 1

//#include <sourcemod>
//#include <sdktools>
//#include <sdktools_tempents>
//#include <sdktools_tempents_stocks>
//#include "W3SIncs/War3Source_Interface"
#assert GGAMEMODE == MODE_WAR3SOURCE

public Plugin:myinfo =
{
	name = "W3S - Addon - Display Particles on Level Up",
	author = "Glider & xDr.HaaaaaaaXx",
	description = "Displays particles whenever somebody levels up",
	version = "1.2",
};

public OnPluginStart()
{
	//CreateConVar("AddonLevelUpParticle",PLUGIN_VERSION,"[War3Source:EVO] Addon Level Up Particle",FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);

	LoadTranslations("w3s.addon.levelupparticle.phrases");
}
public OnAllPluginsLoaded()
{
	W3Hook(W3Hook_OnWar3Event, OnWar3Event);
}
public OnMapStart()
{
#if (GGAMETYPE == GGAME_TF2)
	War3_PrecacheParticle("achieved");
#elseif (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
	PrecacheModel("effects/combinemuzzle2.vmt");
#endif
}

public void OnWar3Event(W3EVENT event,int client)
{
	if(!ValidPlayer(client)) return;

	if(IsFakeClient(client)) return;

	if (event == PlayerLeveledUp)
	{
		new String:name[32];
		GetClientName(client, name, sizeof(name));
		new String:racename[32];
		new race = War3_GetRace(client);

		new level = War3_GetLevel(client, race);
#if (GGAMETYPE == GGAME_TF2)
#if (GGAMETYPE2 == GGAME_TF2_NORMAL)
		AttachThrowAwayParticle(client, "achieved", NULL_VECTOR, "partyhat", 5.0);
		AttachThrowAwayParticle(client, "bday_1balloon", NULL_VECTOR, "partyhat", 5.0);
		AttachThrowAwayParticle(client, "bday_balloon01", NULL_VECTOR, "partyhat", 5.0);
		AttachThrowAwayParticle(client, "bday_balloon02", NULL_VECTOR, "partyhat", 5.0);
#elseif (GGAMETYPE2 == GGAME_PVM)
		if(!IsFakeClient(client))
		{
			AttachThrowAwayParticle(client, "achieved", NULL_VECTOR, "partyhat", 5.0);
			AttachThrowAwayParticle(client, "bday_1balloon", NULL_VECTOR, "partyhat", 5.0);
			AttachThrowAwayParticle(client, "bday_balloon01", NULL_VECTOR, "partyhat", 5.0);
			AttachThrowAwayParticle(client, "bday_balloon02", NULL_VECTOR, "partyhat", 5.0);
		}
#endif
#endif

#if (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
		CSParticle(client, level);
#endif
		for(new i=1;i<=MaxClients;i++){
			if(ValidPlayer(i)){
				SetTrans(i);
				War3_GetRaceName(race, racename, sizeof(racename));
				War3_ChatMessage(i, "%T", "{player} has leveled {racename} to {amount}", i, name, racename, level);
			}
		}

	}
}
/* already in war3source.ini
#if (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
// Create Effect for Counter Strike Source:
stock CSParticle(const client, const level)
{
	new particle = CreateEntityByName("env_smokestack");
	if(IsValidEdict(particle) && IsClientInGame(client))
	{
		decl String:Name[32], Float:fPos[3];
		Format(Name, sizeof(Name), "CSParticle_%i_%i", client, level);
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", fPos);
		fPos[2] += 28.0;
		new Float:fAng[3] = {0.0, 0.0, 0.0};

		// Set Key Values
		DispatchKeyValueVector(particle, "Origin", fPos);
		DispatchKeyValueVector(particle, "Angles", fAng);
		DispatchKeyValueFloat(particle, "BaseSpread", 15.0);
		DispatchKeyValueFloat(particle, "StartSize", 2.0);
		DispatchKeyValueFloat(particle, "EndSize", 6.0);
		DispatchKeyValueFloat(particle, "Twist", 0.0);

		DispatchKeyValue(particle, "Name", Name);
		DispatchKeyValue(particle, "SmokeMaterial", "effects/combinemuzzle2.vmt");
		DispatchKeyValue(particle, "RenderColor", "252 232 131");
		DispatchKeyValue(particle, "SpreadSpeed", "10");
		DispatchKeyValue(particle, "RenderAmt", "200");
		DispatchKeyValue(particle, "JetLength", "13");
		DispatchKeyValue(particle, "RenderMode", "0");
		DispatchKeyValue(particle, "Initial", "0");
		DispatchKeyValue(particle, "Speed", "10");
		DispatchKeyValue(particle, "Rate", "173");
		DispatchSpawn(particle);

		// Set Entity Inputs
		SetVariantString("!activator");
		AcceptEntityInput(particle, "SetParent", client, particle, 0);
		AcceptEntityInput(particle, "TurnOn");
		particle = EntIndexToEntRef(particle);
		SetVariantString("OnUser1 !self:Kill::3.5:-1");
		AcceptEntityInput(particle, "AddOutput");
		AcceptEntityInput(particle, "FireUser1");
	}
	else
	{
		LogError("Failed to create env_smokestack!");
	}
}
#endif
*/
