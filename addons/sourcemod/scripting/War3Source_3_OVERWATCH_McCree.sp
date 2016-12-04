//War3Source_3_OVERWATCH_McCree.sp

#include <war3source>
#assert GGAMEMODE == MODE_OVERWATCH
#assert GGAMETYPE_JAILBREAK == JAILBREAK_OFF

#define RACE_ID_NUMBER 20
#define RACE_LONGNAME "McCree"
#define RACE_SHORTNAME "mccree"

public Plugin:myinfo =
{
	name = "Race - McCree",
	author = "Ownz (DarkEnergy)",
	description = "McCree",
	version = "1.0.0.0",
	url = "war3evo.info"
};

int thisRaceID;

int SKILL_FAN_FIRE, SKILL_COMBAT_ROLL, SKILL_FLASHBANG, ULT_DEADEYE;

bool HooksLoaded = false;
public void Load_Hooks()
{
	if(HooksLoaded) return;
	HooksLoaded = true;

	//W3Hook(W3Hook_OnUltimateCommand, OnUltimateCommand);
	//W3Hook(W3Hook_OnWar3EventSpawn, OnWar3EventSpawn);
}
public void UnLoad_Hooks()
{
	if(!HooksLoaded) return;
	HooksLoaded = false;

	//W3UnhookAll(W3Hook_OnUltimateCommand);
	//W3UnhookAll(W3Hook_OnWar3EventSpawn);
}
bool RaceDisabled=true;
public OnWar3RaceEnabled(newrace)
{
	if(newrace==thisRaceID)
	{
		Load_Hooks();

		RaceDisabled=false;
	}
}
public OnWar3RaceDisabled(oldrace)
{
	if(oldrace==thisRaceID)
	{
		RaceDisabled=true;

		UnLoad_Hooks();
	}
}
public OnAllPluginsLoaded()
{
	War3_RaceOnPluginStart(RACE_SHORTNAME);
}

public OnPluginEnd()
{
	if(LibraryExists("RaceClass"))
		War3_RaceOnPluginEnd(RACE_SHORTNAME);
}
public OnWar3LoadRaceOrItemOrdered2(num,reloadrace_id,String:shortname[])
{
	if(num==RACE_ID_NUMBER||(reloadrace_id>0&&StrEqual(RACE_SHORTNAME,shortname,false)))
	{

		thisRaceID=War3_CreateNewRace(RACE_LONGNAME,RACE_SHORTNAME,reloadrace_id,"revolver,stun,deadeye");
		SKILL_FAN_FIRE=War3_AddRaceSkill(thisRaceID,"Fan Fire","alternate fire [right click] empty everything in his clip all at once.",false,4);
		SKILL_COMBAT_ROLL=War3_AddRaceSkill(thisRaceID,"Combat Roll","Gives speed boost for .5 of a second and reloads clip.\n8 second cooldown.",false,4);
		SKILL_FLASHBANG=War3_AddRaceSkill(thisRaceID,"Flashbang","Throw sapper (or bomb), when it explodes and blinds everyone in\na radius of the explosion for .7 seconds.\nDoes 25 damage.",false,4);
		ULT_DEADEYE=War3_AddRaceSkill(thisRaceID,"Deadeye","60 second wait till can use ultimate - then 60 second cooldown.\nPress +ultimate once to focus on players,\nthen press again to shoot all of them in your visual.\nCharges 1 second per 200 health of each enemy in sight.\nMax Duration 10 seconds.",true,4);
		War3_CreateRaceEnd(thisRaceID);

		if(RaceDisabled || SKILL_FAN_FIRE || SKILL_COMBAT_ROLL || SKILL_FLASHBANG || ULT_DEADEYE)
		{
			//shut up warnings!
		}

		//War3_SetDependency(thisRaceID, ULT_IMPROVED_TELEPORT, ULT_TELEPORT, 4);
	}
}

public OnRaceChanged(client,oldrace,newrace)
{
	if(newrace==thisRaceID)
	{
		// activate skills / bufffs
		W3SetPlayerProp(client, iMaxHP, 200);

		//native bool War3_SetClass(int client, TFClassType tClass, bool bSpecialEffects = true, bool bTryRemoveProblemEffects = true);
		War3_SetClass(client, TFClass_Spy);
	}
	else
	{
		//remove buffs / skills
	}
}

