//=============================================================================
// Messages --stocks
//=============================================================================
//#define MAX_MESSAGE_LENGTH 250

/**
 * Prints a message in the chat area with [War3Source:EVO] pre-appended.
 * Support color tags: {default}, {green}, {lightgreen}, {red}, {blue}, {olive}.
 *
 * @param client      Client index, pass 0 for message to all.
 * @param szMessage   Message (formatting rules).
 * @return            No return
 */
stock War3_ChatMessage(client, const String:szMessage[], any:...)
{
	if (client == 0)
	{
		decl String:szBuffer[MAX_MESSAGE_LENGTH];
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i))
			{
				SetGlobalTransTarget(i);
				VFormat(szBuffer, sizeof(szBuffer), szMessage, 3);
				Format(szBuffer, sizeof(szBuffer), "{green}[War3Source:EVO]{default} %s", szBuffer);
				CPrintToChat(i, szBuffer);
			}
		}
	}
	else
	{
		decl String:szBuffer[MAX_MESSAGE_LENGTH];
		SetGlobalTransTarget(client);
		VFormat(szBuffer, sizeof(szBuffer), szMessage, 3);
		Format(szBuffer, sizeof(szBuffer), "{green}[War3Source:EVO]{default} %s", szBuffer);

		if(ValidPlayer(client) && !IsFakeClient(client))
		{
			CPrintToChat(client, szBuffer);
		}

		// Added this delay because most chat commands tend to be above the test some types instead below it
		// This will help cause less confusion for new players.

		//new Handle:pack;
		//CreateDataTimer(0.5,DelayWar3ChatMessageTimer,pack);
		//WritePackCell(pack, GetClientUserId(client));
		//WritePackString(pack, szBuffer);
	}
}
/*
public Action:DelayWar3ChatMessageTimer(Handle:timer, Handle:datapack)
{
	new String:sBuffer[MAX_MESSAGE_LENGTH];
	new userid;

	ResetPack(datapack);
	userid = ReadPackCell(datapack);
	ReadPackString(datapack, sBuffer, sizeof(sBuffer));
	CloseHandle(datapack);

	new client = GetClientOfUserId(userid);
	if(ValidPlayer(client))
	{
		CPrintToChat2(client, sBuffer);
	}
}*/

/**
 * Prints a message in the chat area with [War3Source:EVO] pre-appended.
 * Support color tags: {default}, {green}, {olive}, {teamcolor}.
 *
 * @param client      Client index, pass 0 for message to all.
 * @param author      Author index whose color will be used for teamcolor tag.
 * @param szMessage   Message (formatting rules).
 * @return            No return
 */
stock War3_ChatMessageEx(client, author, const String:szMessage[], any:...)
{
	if (client == 0)
	{
		if (author < 0 || author > MaxClients)
		ThrowError("Invalid client index %d", author);

		if (!IsClientInGame(author))
		ThrowError("Client %d is not in game", author);

		decl String:szBuffer[MAX_MESSAGE_LENGTH];
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i))
			{
				//SetGlobalTransTarget(i);
				VFormat(szBuffer, sizeof(szBuffer), szMessage, 4);
				Format(szBuffer, sizeof(szBuffer), "{green}[War3Source:EVO]{default} %s",szBuffer);
				CPrintToChatEx(i, author, szBuffer);
			}
		}
	}
	else
	{
		if(ValidPlayer(client) && !IsFakeClient(client))
		{
			decl String:szBuffer[MAX_MESSAGE_LENGTH];
			//SetGlobalTransTarget(client);
			VFormat(szBuffer, sizeof(szBuffer), szMessage, 4);
			Format(szBuffer, sizeof(szBuffer), "{green}[War3Source:EVO]{default} %s", szBuffer);
			CPrintToChatEx(client, author, szBuffer);
		}
	}
}


//=============================================================================
// Print Skill Damage Console
//=============================================================================
//prints [W3S] You did %d damage to %name with SKILLNAME
//prints [W3S] %name did %d damage to you with SKILLNAME
new String:zzname[32];
stock W3PrintSkillDmgConsole(victim = 0, attacker, damage, skillnum) {
	GetClientName(victim, zzname, sizeof(zzname));
	new race = War3_GetRace(attacker);
	new String:skillname[32];
	//SetTrans( attacker);
	W3GetRaceSkillName(race, skillnum, skillname, sizeof(skillname));
	PrintToConsole(attacker, "[War3Source:EVO] You did +%i damage to %s with %s", damage, zzname, skillname);

	if (victim > 0) {
		//SetTrans( victim);
		W3GetRaceSkillName(race, skillnum, skillname, sizeof(skillname)); //get trans again

		GetClientName(attacker, zzname, sizeof(zzname));
		PrintToConsole(victim, "[War3Source:EVO] %s did %i damage to you with %s",zzname, damage, skillname);
	}
}

//=============================================================================
// Print Skill Damage Hint
//=============================================================================
//+%d damage with skill name
stock W3PrintSkillDmgHint(victim = 0, attacker, damage, SKILLNUM) {

	new race = War3_GetRace(attacker);
	new String:skillname[32];
	//SetTrans( attacker);
	if(GetRaceSkillName(race, SKILLNUM, skillname, sizeof(skillname))>0)
	{
		PrintHintText(attacker, "+%i damage with %s",damage, skillname);
	}

	if (victim > 0) {
		//SetTrans( victim);
		if(GetRaceSkillName(race, SKILLNUM, skillname, sizeof(skillname))>0)
		{
			PrintHintText(victim, "Received %i damage from %s",damage, skillname);
		}
	}
}
stock W3PrintSkillDmgHintConsole(victim = 0, attacker, damage, SKILLNUM) {
	W3PrintSkillDmgHint(victim, attacker, damage, SKILLNUM);
	W3PrintSkillDmgConsole(victim, attacker, damage, SKILLNUM);
}

//colored
//prints [war3 tag] You did %d damage to %name with SKILLNAME
//prints [war3 tag] %name did %d damage to you with SKILLNAME
///automatically goes into console
//removed in favor of console and hint
/*
 stock W3PrintSkillDmgChat(victim,attacker,damage,String:skillname[]){
 GetClientName(victim,zzname,sizeof(zzname));
 War3_ChatMessage(attacker,"%T","You did +{amount} damage to {player} with {skill}",attacker,damage,zzname,skillname);

 if(victim>0){
 GetClientName(attacker,zzname,sizeof(zzname));
 War3_ChatMessage(victim,"%T","{player} did {amount} damage to you with {skill}",victim,zzname,damage,skillname);
 }
 }
 */

//=============================================================================
// Ultimate Not Leveled
//=============================================================================

stock W3MsgUltNotLeveled(client) {
	new String:buffer[100];
	Format(buffer, sizeof(buffer),"Your Ultimate is not leveled");
	PrintHintText(client, buffer);
}

//=============================================================================
// No Target Found
//=============================================================================

stock W3MsgNoTargetFound(client,Float:distancegameunits=0.0) {
	decl String:print[500];
	Format(print,sizeof(print),"No target found");
	if(distancegameunits>0.1) {
		if(GetConVarInt(W3GetVar(hUseMetricCvar))==0)
		{
			Format(print,sizeof(print),"No target found within %.2f feet",distancegameunits/10.0);
		}
		else
		{
			Format(print,sizeof(print),"No target found within %.2f meters",distancegameunits/30.0);
		}
	}
	PrintHintText(client,"%s",print);
}

//=============================================================================
// Create Ward
//=============================================================================

stock W3MsgCreatedWard(client, currentwardcount = 0, totalwardcount = 0) {
	decl String:print[500];
	Format(print, sizeof(print), "You created a Ward");
	if (totalwardcount > 0) {
		Format(print, sizeof(print), "You created a Ward %i/%i",currentwardcount, totalwardcount);
	}
	PrintHintText(client, "%s", print);
}

//=============================================================================
// Ward Location Deny
//=============================================================================

stock W3MsgWardLocationDeny(client) {
	PrintHintText(client, "You can not build a Ward Here");
}

//=============================================================================
// No Wards Left
//=============================================================================

stock W3MsgNoWardsLeft(client) {
	PrintHintText(client, "You have used up all your Wards!");
}

//=============================================================================
// No Ward When Invisible
//=============================================================================

stock W3MsgNoWardWhenInvis(client) {
	PrintHintText(client, "No Ward Placement While Invisible");
}

//=============================================================================
// Message Evaded
//=============================================================================

stock W3MsgEvaded(victim, attacker) {
	PrintHintText(victim, "You Evaded a Shot");
	PrintHintText(attacker, "Enemy Evaded");
}

//=============================================================================
// Message Entangled
//=============================================================================

stock W3MsgEntangle(victim, attacker) {
	PrintHintText(victim, "You are Entangled!");
	PrintHintText(attacker, "Entangled!");
}

//=============================================================================
// Message No Cast During Freezetime
//=============================================================================

stock W3MsgNoCastDuringFreezetime(client) {
	PrintHintText(client, "Cannot cast during freezetime");
}

//=============================================================================
// Message Skill Blocked
//=============================================================================

stock W3MsgSkillBlocked(victim=0,attacker=0,String:skillname[]) {
	if(victim>0) {
		PrintHintText(victim,"Blocked enemy %s",skillname);
	}
	if(attacker>0) {
		PrintHintText(victim,"Enemy Blocked %s",skillname);
	}
}

//=============================================================================
// Message Newbie Project Blocked
//=============================================================================

stock W3MsgNewbieProjectBlocked(victim=0,String:skillname[],String:chatmessage[],String:chatmessage2[]) {
	if(victim>0) {
		PrintHintText(victim,"[New Player Project] Blocked enemy %s",skillname);
		War3_ChatMessage(victim,"{green}[New Player Project]{lightgreen}%s{default}.",chatmessage);
		War3_ChatMessage(victim,"{green}[New Player Project]{lightgreen}%s{default}.",chatmessage2);
	}
}

//=============================================================================
// Message Banished
//=============================================================================

stock W3MsgBanished(victim, attacker) {
	PrintHintText(victim, "You have been Banished");
	PrintHintText(attacker, "You Banished");
}

//=============================================================================
// Message Stole Money
//=============================================================================

stock W3MsgStoleMoney(victim, attacker, dollars) {
	PrintHintText(victim, "Enemy stole %i dollars from you",dollars);
	PrintHintText(attacker, "You Stole %i dollars",dollars);
}

//=============================================================================
// Message Stole Gold
//=============================================================================

stock W3MsgStoleGold(victim, attacker, gold) {
	PrintHintText(victim, "Enemy stole %i gold from you",gold);
	PrintHintText(attacker, "You Stole %i gold", gold);
}

//=============================================================================
// Message Revived Blood Mage
//=============================================================================

stock W3MsgRevivedBM(playerrevived, savior, gold=0, xp=0, heal=0) {
	new String:clientName[64];
	GetClientName(playerrevived, clientName, sizeof(clientName));
	new String:saviorName[64];
	GetClientName(savior, saviorName, sizeof(saviorName));

	PrintHintText(savior, "You revived %s", clientName);
	War3_ChatMessage(playerrevived, "%s revived you", saviorName);
}

//=============================================================================
// Message Using Voodoo
//=============================================================================

stock W3MsgUsingVoodoo(client) {
	PrintHintText(client,"Activated Voodoo!");
}

//=============================================================================
// Message Voodoo Ended
//=============================================================================

stock W3MsgVoodooEnded(client) {
	PrintHintText(client,"Voodoo has ended");
}

//=============================================================================
// Message Enemy Has immunity
//=============================================================================

stock W3MsgEnemyHasImmunity(client,bool:console=true) {
	PrintHintText(client,"Enemy has immunity!");
	PrintToConsole(client,"[War3Source:EVO] Enemy has immunity!");
}

//=============================================================================
// Message Ultimate Not Activatable
//=============================================================================

stock W3MsgUltimateNotActivatable(client) {
	PrintHintText(client, "This ultimate is not activatable"); //prints
}

//=============================================================================
// Message Ultimate Blocked
//=============================================================================

stock W3MsgUltimateBlocked(client) {
	PrintHintText(client, "Ultimate Blocked");
}

//=============================================================================
// Message Threw Knives
//=============================================================================

stock W3MsgThrewKnives(client) {
	PrintHintText(client,"You threw knives around you");
}

//=============================================================================
// Message Hit By Knives
//=============================================================================

stock W3MsgHitByKnives(client) {
	PrintHintText(client, "Attacked by Fan of Knives");
}

//=============================================================================
// Message Activated
//=============================================================================

stock W3MsgActivated(client,String:postpendstr[]) {
	PrintHintText(client,"Activated %s",postpendstr);
}

//=============================================================================
// Message Attacked By
//=============================================================================

stock W3MsgAttackedBy(client,String:postpendstr[]) {
	PrintHintText(client,"Attacked By %s",postpendstr);
}

//=============================================================================
// Message Mole In
//=============================================================================

stock W3MsgMoleIn(client,Float:timetillactivation) {
	PrintHintText(client,"WARNING! MOLE IN %i SECONDS!",timetillactivation);
	War3_ChatMessage(client,"WARNING! MOLE IN %i SECONDS!",timetillactivation);
}

//=============================================================================
// Message No Longer Disguised
//=============================================================================

stock W3MsgNoLongerDisguised(client) {
	War3_ChatMessage(client, "You are no longer disguised");
	PrintHintText(client, "You are no longer disguised");
}

//=============================================================================
// Message Vengence Was Blocked
//=============================================================================

stock W3MsgVengenceWasBlocked(client,String:reason[]) {
	War3_ChatMessage(client,"Vengence blocked (%s)",reason);
}
