// War3Source_Engine_SkillsClass.inc

native int War3_CreateNewSkill(char[] skill_longname,char[] skill_shortname,char[] skill_short_description,char[] skill_description);

native void War3_GetSkillName(int skillid,char[] retstr,int maxlen);
native void War3_GetSkillShortname(int skillid,char[] retstr,int maxlen);
native void War3_GetSkillDesc(int skillid,char[] retstr,int maxlen);
native void War3_GetSkillShortDesc(int skillid,char[] retstr,int maxlen);

native int War3_GetSkillsLoaded();

native void War3_GetSkillIDByShortname(char[] raceshortname);

// set a skill slot with a skill id
native void War3_SetSkillSlot(int client, int skillslot, int newskillid);

// returns get the specific slot for the skill id
native int War3_GetSkillSlot(int client, int skillid);

// returns the slot it finds the skill id (it loops thru all the skill slots, use sparingly)
// returns 0 if none found
native int War3_HasSkillSlot(int client, int skillid);

native int War3_IsSkillSlot(int client, int skillid);
