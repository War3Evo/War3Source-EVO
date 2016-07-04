// War3Source_Engine_SkillsClass.sp
// Ideas taken from SkillCraft by El Diablo

//#pragma dynamic 10000

int totalSkillsLoaded=0;

public bool War3Source_Engine_SkillsClass_InitForwards()
{
	p_OnWar3SkillSlotChange=CreateForward(ET_Ignore,Param_Cell,Param_Cell,Param_Cell,Param_Cell);
	return true;
}

public bool War3Source_Engine_SkillsClass_InitNatives()
{
	CreateNative("War3_CreateNewSkill",Native_War3_CreateNewSkill);
	CreateNative("War3_GetSkillsLoaded",Native_War3_GetSkillsLoaded);

	CreateNative("War3_GetSkillName",Native_War3_GetSkillName);
	CreateNative("War3_GetSkillShortname",Native_War3_GetSkillShortname);
	CreateNative("War3_GetSkillIDByShortname",Native_War3_GetSkillIDByShortname);

	CreateNative("War3_GetSkillDesc",Native_War3_GetSkillDesc);
	CreateNative("War3_GetSkillShortDesc",Native_War3_GetSkillShortDesc);

	CreateNative("War3_SetSkillSlot",Native_War3_SetSkillSlot);
	CreateNative("War3_GetSkillSlot",Native_War3_GetSkillSlot);

	CreateNative("War3_HasSkillSlot",Native_War3_HasSkillSlot);

	return true;
}

stock bool GetSkillName(int skillid,char[] retstr,int maxlen)
{
	int num=strcopy(retstr, maxlen, skill_Name[skillid]);
	return view_as<bool>(num);
}
stock bool GetSkillShortname(int skillid,char[] retstr,int maxlen)
{
	int num=strcopy(retstr, maxlen, skill_Shortname[skillid]);
	return view_as<bool>(num);
}
stock bool GetSkillDesc(int skillid,char[] retstr,int maxlen)
{
	int num=strcopy(retstr, maxlen, skill_Description[skillid]);
	return view_as<bool>(num);
}
stock bool GetSkillShortDesc(int skillid,char[] retstr,int maxlen)
{
	int num=strcopy(retstr, maxlen, skill_Short_Description[skillid]);
	return view_as<bool>(num);
}
stock int GetSkillIDByShortname(char[] the_shortname)
{
	int SkillsLoaded = totalSkillsLoaded;
	for(int x=1;x<=SkillsLoaded;x++)
	{
		char short_name[16];
		GetSkillShortname(x,short_name,sizeof(short_name));
		if(StrEqual(short_name,the_shortname,false))
		{
			return x;
		}
	}
	return 0;
}
stock bool SkillExistsByShortname(char[] shortname)
{
	char buffer[16];

	int SkillsLoaded = totalSkillsLoaded;
	for(int skillid=1;skillid<=SkillsLoaded;skillid++)
	{
		GetSkillShortname(skillid,buffer,sizeof(buffer));
		if(StrEqual(shortname, buffer, false)){
			return true;
		}
	}
	return false;
}
stock int CreateNewSkill(char[] variable_skill_longname,char[] variable_skill_shortname,char[] variable_skill_short_description,char[] variable_skill_description)
{
	//if(SkillExistsByShortname(variable_skill_shortname)&&!PluginsReloading)
	if(SkillExistsByShortname(variable_skill_shortname))
	{
		int oldskillid=GetSkillIDByShortname(variable_skill_shortname);
		PrintToServer("Skill already exists: %s, returning old skillid %d",variable_skill_shortname,oldskillid);
		return oldskillid;
	}

	//if(totalSkillsLoaded+1==MAXSKILLS&&!PluginsReloading) //make sure we didnt reach our skill capacity limit
	if(totalSkillsLoaded+1==MAXSKILLS) //make sure we didnt reach our skill capacity limit
	{
		LogError("MAX SKILLS REACHED, CANNOT REGISTER %s %s",variable_skill_longname,variable_skill_shortname);
		return 0;
	}

	//first skill registering, fill in the  zeroth skill along
	if(totalSkillsLoaded==0)
	{
		Format(skill_Name[0],31,"NO SKILL DEFINED %d",0);
		Format(skill_Shortname[0],15,"NO SKILL DEFINED %d",0);
		Format(skill_Description[0],511,"NO SKILL DESCRIPTION DEFINED %d",0);
		Format(skill_Short_Description[0],255,"NO SKILL SHORT DESCRIPTION DEFINED %d",0);
	}

	int tskillid;

	//if(SkillExistsByShortname(variable_skill_shortname)&&PluginsReloading)
	if(SkillExistsByShortname(variable_skill_shortname))
	{
		tskillid=GetSkillIDByShortname(variable_skill_shortname);
	}
	//else if(!SkillExistsByShortname(variable_skill_shortname)&&PluginsReloading)
	else if(!SkillExistsByShortname(variable_skill_shortname))
	{
		LogError("SHORT NAME DOES NOT EXIST!, CANNOT REGISTER %s %s",variable_skill_longname,variable_skill_shortname);
		PrintToChatAll("ERROR RELOADING SKILLS!  Skill %s does not exist!",variable_skill_shortname);
		PrintToChatAll("ERROR RELOADING SKILLS!  Skill id set to 0.");
		PrintToChatAll("ERROR RELOADING SKILLS!  Please reload with correct shortname.");
		return 0;
	}
	else
	{
		totalSkillsLoaded++;
		tskillid=totalSkillsLoaded;
	}

	//make all skills zero so we can easily debug
	Format(skill_Name[tskillid],31,"NO SKILL DEFINED %d",0);
	Format(skill_Shortname[tskillid],15,"NO SKILL DEFINED %d",0);
	Format(skill_Description[tskillid],511,"NO SKILL DESCRIPTION DEFINED %d",0);
	Format(skill_Short_Description[tskillid],255,"NO SKILL SHORT DESCRIPTION DEFINED %d",0);

	strcopy(skill_Name[tskillid], 31, variable_skill_longname);
	strcopy(skill_Shortname[tskillid], 15, variable_skill_shortname);
	strcopy(skill_Description[tskillid], 511, variable_skill_description);
	strcopy(skill_Short_Description[tskillid], 255, variable_skill_short_description);

	//PrintToServer("Create New Skill - Skill id: %d",tskillid);

	//PrintToServer("Create New Skill long name  : %s",variable_skill_longname);
	//PrintToServer("Create New Skill short name : %s",variable_skill_shortname);
	//PrintToServer("Create New Skill description: %s",variable_skill_description);

	//strcopy(Plugins_Shortname, 31, "");
	return tskillid; //this will be the new skill's id / index
}

public int Native_War3_GetSkillIDByShortname(Handle:plugin,numParams)
{
	char short_lookup[16];
	GetNativeString(1,short_lookup,sizeof(short_lookup));
	return GetSkillIDByShortname(short_lookup);
}
public int Native_War3_CreateNewSkill(Handle:plugin,numParams)
{
	char name[64],shortname[16],skillshortdesc[256],skilldesc[512];
	GetNativeString(1,name,sizeof(name));
	GetNativeString(2,shortname,sizeof(shortname));
	GetNativeString(3,skillshortdesc,sizeof(skilldesc));
	GetNativeString(4,skilldesc,sizeof(skilldesc));

	return CreateNewSkill(name,shortname,skillshortdesc,skilldesc);

}
public Native_War3_GetSkillName(Handle:plugin,numParams)
{
	int skill=GetNativeCell(1);
	int bufsize=GetNativeCell(3);
	if(skill>-1 && skill<=totalSkillsLoaded) //allow "No Skill"
	{
		char skill_name[32];
		GetSkillName(skill,skill_name,sizeof(skill_name));
		SetNativeString(2,skill_name,bufsize);
	}
}
public int Native_War3_GetSkillShortname(Handle plugin,int numParams)
{
	int skill=GetNativeCell(1);
	int bufsize=GetNativeCell(3);
	if(skill>=1 && skill<=totalSkillsLoaded)
	{
		char skill_shortname[16];
		GetSkillShortname(skill,skill_shortname,sizeof(skill_shortname));
		SetNativeString(2,skill_shortname,bufsize);
	}
}
public int Native_War3_GetSkillDesc(Handle plugin,int numParams)
{
	int skill_id=GetNativeCell(1);
	int maxlen=GetNativeCell(3);

	char longbuf[1000];
	GetSkillDesc(skill_id,longbuf,sizeof(longbuf));
	SetNativeString(2,longbuf,maxlen);
}
public int Native_War3_GetSkillShortDesc(Handle plugin,int numParams)
{
	int skill_id=GetNativeCell(1);
	int maxlen=GetNativeCell(3);

	char longbuf[1000];
	GetSkillShortDesc(skill_id,longbuf,sizeof(longbuf));
	SetNativeString(2,longbuf,maxlen);
}
public int Native_War3_GetSkillsLoaded(Handle plugin,int numParams)
{
	return totalSkillsLoaded;
}




public int Native_War3_SetSkillSlot(Handle plugin,int numParams)
{
	//set old skillid
	int client=GetNativeCell(1);
	int skillslot=GetNativeCell(2);
	int newskillid=GetNativeCell(3);
	if(skillslot>MAXSKILLCOUNT||skillslot<0)
	{
		LogError("[War3Source:EVO] SetSkillId:WARNING INVALID SKILL SLOT for client %d to skill slot %d",client,skillslot);
		return;
	}
	if(newskillid<0||newskillid>totalSkillsLoaded)
	{
		LogError("[War3Source:EVO] SetSkillId:WARNING SET INVALID SKILL for client %d to skillid %d",client,newskillid);
		return;
	}
	// If the client has no team, and the skill is set for 0.. it will set all skills on both teams to 0.
	// The structure is on the bottom of this function SC_SetSkill

	if(ValidPlayer(client))
	{
		if(skill_PlayerSkill[client][skillslot]!=newskillid)
		{
			int oldskillid = skill_PlayerSkill[client][skillslot];

			skill_PlayerSkill[client][skillslot]=newskillid;

			Call_StartForward(p_OnWar3SkillSlotChange);
			Call_PushCell(client);
			Call_PushCell(skillslot);
			Call_PushCell(oldskillid);
			Call_PushCell(newskillid);
			Call_Finish(dummy);
		}
	}
}
public int Native_War3_GetSkillSlot(Handle plugin,int numParams)
{
	int client = GetNativeCell(1);
	int skillslot = GetNativeCell(2);
	if(skillslot>MAXSKILLCOUNT||skillslot<0)
	{
		LogError("[War3Source:EVO] GetSkillId:WARNING INVALID SKILL SLOT for client %d to skill slot %d",client,skillslot);
		return 0;
	}
	if (ValidPlayer(client))
	{
		return skill_PlayerSkill[client][skillslot];
	}
	return 0;
}

public int Native_War3_HasSkillSlot(Handle plugin,int numParams)
{
	int client = GetNativeCell(1);
	int skillid = GetNativeCell(2);
	if (client>0 && client<=MaxClients)
	{
		for(int i=0;i<MAXSKILLCOUNT;i++)
		{
			if(
			skillid==skill_PlayerSkill[client][i]
			)
			{
				return i;
			}
		}
	}
	return 0;
}
