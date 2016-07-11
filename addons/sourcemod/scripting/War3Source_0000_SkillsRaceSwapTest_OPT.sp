//War3Source_0000_SkillsRaceSwapTest_OPT.sp

#include <war3source>

int thisRaceID;

int SKILL_LEECH,SKILL_SPEED,SKILL_LOWGRAV,SKILL_SUICIDE;

#define RACE_ID_NUMBER 12
#define RACE_LONGNAME "Test Race 1"
#define RACE_SHORTNAME "testrace1"

public Plugin:myinfo =
{
	name = "War3Source_9000_SkillsPack_1",
	author = "El Diablo",
	description = "Skills Pack for War3Source:EVO.",
	version = "1.0",
	url = "http://war3evo.info"
};

int Test1Skill,Test2Skill,Test3Skill,Test4Skill;

bool HooksLoaded = false;
public void Load_Hooks()
{
	if(HooksLoaded) return;
	HooksLoaded = true;

	W3Hook(W3Hook_OnWar3SkillSlotChange, OnWar3SkillSlotChange);
}
public void UnLoad_Hooks()
{
	if(!HooksLoaded) return;
	HooksLoaded = false;

	W3UnhookAll(W3Hook_OnWar3SkillSlotChange);
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

public void OnWar3SkillSlotChange(int client, int skillslot, int oldskillid, int newskillid)
{
	PrintToServer("client %d, skillslot %d, oldskillid %d, newskillid %d",client,skillslot,oldskillid,newskillid);
}

public OnWar3LoadRaceOrItemOrdered2(num,reloadrace_id,String:shortname[])
{
	if(num==1)
	{
		Test1Skill = War3_CreateNewSkill("Test Skill 1","testshort1","short description 1","Description of Test Skill 1");
	}
	if(num==2)
	{
		Test2Skill = War3_CreateNewSkill("Test Skill 2","testshort2","short description 2","Description of Test Skill 2");
	}
	if(num==3)
	{
		Test3Skill = War3_CreateNewSkill("Test Skill 3","testshort3","short description 3","Description of Test Skill 3");
	}
	if(num==4)
	{
		Test4Skill = War3_CreateNewSkill("Test Skill 4","testshort4","short description 4","Description of Test Skill 4");
	}

	if(num==RACE_ID_NUMBER||(reloadrace_id>0&&StrEqual(RACE_SHORTNAME,shortname,false)))
	{
		thisRaceID=War3_CreateNewRace(RACE_LONGNAME,RACE_SHORTNAME,"a test race",reloadrace_id);
		SKILL_LEECH=War3_AddRaceSkill(thisRaceID,"Vamp1","Vamp1 long descriptioin",false,4);
		SKILL_SPEED=War3_AddRaceSkill(thisRaceID,"Vamp2","Vamp2 long description",false,4);
		SKILL_LOWGRAV=War3_AddRaceSkill(thisRaceID,"Vamp3","Vamp3 long description",false,4);
		SKILL_SUICIDE=War3_AddRaceSkill(thisRaceID,"Vamp4","Vamp4 long description",true,4);
		War3_CreateRaceEnd(thisRaceID);
	}
	if(SKILL_LEECH)
	{
	}
	if(SKILL_SPEED)
	{
	}
	if(SKILL_LOWGRAV)
	{
	}
	if(SKILL_SUICIDE)
	{
	}

}

public OnWar3EventDeath(victim, attacker)
{
	if(ValidPlayer(victim))
	{
		War3_SetSkillSlot(victim, SKILL_SPEED, GetRandomInt(1,War3_GetSkillsLoaded()));
	}
}
