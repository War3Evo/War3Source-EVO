// War3Source_Engine_MenuSpendskills.sp


//#assert GGAMEMODE == MODE_WAR3SOURCE

/*
public Plugin:myinfo=
{
	name="War3Source Menu spendskills",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.1",
	url="http://war3source.com/"
};
*/
new Handle:NoSpendSkillsLimitCvar;

public War3Source_Engine_MenuSpendskills_OnPluginStart()
{
	// No Spendskill level restrictions on non-ultimates (Requires mapchange)
	NoSpendSkillsLimitCvar=CreateConVar("war3_no_spendskills_limit","0","Set to 1 to require no limit on non-ultimate spendskills");
}

public War3Source_Engine_MenuSpendskills_OnWar3Event(client)
{
	War3Source_SkillMenu(client);
}

//checks for any active dependencys on the given skill
//TODO: add translation support
stock bool:HasDependency(client,race,skill,String:buffer[],maxlen,bool:is_ult)
{
	//Check if our skill has a dependency
	new dependencyID = War3_GetDependency(race, skill, SkillDependency:ID);
	if( dependencyID != INVALID_DEPENDENCY ) {
		//If so, append our stuff if the skill minlevel is below our current level(otherwhise do just NOTHING)
		//but wait.. is our depending required level valid?
		new requiredLVL = War3_GetDependency(race, skill, SkillDependency:LVL);
		if(requiredLVL > 0) {
			//oh it is.. okay do the stuff i want to do before lol...
			new currentLVL = GetSkillLevelINTERNAL(client,race,dependencyID);
			if(currentLVL < requiredLVL) {
				//Gotcha! now we just need to overwrite that buffer
				decl String:skillname[64]; //original skill
				GetRaceSkillName(race,skill,skillname,sizeof(skillname));
				decl String:skillname2[64]; // depending skill
				GetRaceSkillName(race,dependencyID,skillname2,sizeof(skillname2));
				if(is_ult)
					Format(buffer,maxlen,"Ultimate: %s [Requires %d lvl on %s]",skillname,(requiredLVL-currentLVL),skillname2);
				else
					Format(buffer,maxlen,"%s [Requires %d lvl on %s]",skillname,(requiredLVL-currentLVL),skillname2);
				return true;
			}
		}
	}
	return false;
}

War3Source_SkillMenu(client)
{

	// HACK: Supress this menu until loaded player data
	if(W3IsPlayerXPLoaded(client))
	{
		SetTrans(client);
		new race_num=GetRace(client);
		if(!(GetLevelsSpent(client,race_num)<War3_GetLevel(client,race_num))){
			War3_ChatMessage(client,"%T","You do not have any skill points to spend, if you want to reset your skills use resetskills",client);
		}

		else if(race_num>0)
		{
			new Handle:sMenu=CreateMenu(War3Source_SMenu_Selected);
			new skillcount=GetLevelsSpent(client,race_num);
			new level=War3_GetLevel(client,race_num);
			SetMenuExitButton(sMenu,true);
			SetMenuTitle(sMenu,"%T\n \n","[War3Source:EVO] Select your desired skill. ({amount}/{amount})",client,skillcount,level);
			decl String:skillname[64];
			new curskilllevel;

			decl String:sbuf[4];
			decl String:buf[192];
			new SkillCount = GetRaceSkillCount(race_num);
			for(new x=1;x<=SkillCount;x++)
			{
				curskilllevel=GetSkillLevelINTERNAL(client,race_num,x);
				if(curskilllevel<GetRaceSkillMaxLevel(race_num,x)){

					if(GetRaceSkillName(race_num,x,skillname,sizeof(skillname))>0)
					{

						if(!IsSkillUltimate(race_num,x))
						{
							//if(level>=curskilllevel*2+1){
							Format(sbuf,sizeof(sbuf),"%d",x);
							Format(buf,sizeof(buf),"%T","{skillname} (Skill Level {amount})",client,skillname,curskilllevel+1);
							new bool:failed = HasDependency(client,race_num,x,buf,sizeof(buf),false);
							if(failed)
								AddMenuItem(sMenu,sbuf,buf,ITEMDRAW_DISABLED);
							else
	                           {
	                            // No Spending skills limit
	                            if(GetConVarBool(NoSpendSkillsLimitCvar))
	                              {
	                               AddMenuItem(sMenu,sbuf,buf,ITEMDRAW_DEFAULT);
	                              }
	                             else
	  							   AddMenuItem(sMenu,sbuf,buf,(level>=curskilllevel*2+1)?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
	                           }
							//}
						}
						else {
							//if(level>=curskilllevel*2+1+){
							Format(sbuf,sizeof(sbuf),"%d",x);
							Format(buf,sizeof(buf),"%T ","Ultimate: {skillname} (Skill Level {amount})",client,skillname,curskilllevel+1);
							if((level<W3GetMinUltLevel())){
								Format(buf,sizeof(buf),"%s %T",buf,"[Requires lvl {amount}]",client,W3GetMinUltLevel());
							}
							new bool:failed = HasDependency(client,race_num,x,buf,sizeof(buf),true);
							if(failed)
								AddMenuItem(sMenu,sbuf,buf,ITEMDRAW_DISABLED);
							else
	                            AddMenuItem(sMenu,sbuf,buf,(level>=curskilllevel*2+1+W3GetMinUltLevel()-1)?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
						}

						/*if(War3_IsSkillPartOfTree(race_num, x)) //the skill depends on something
						{
							Format(sbuf, sizeof(sbuf), "%d", x);
							Format(buf, sizeof(buf),"%T","{skillname} (Skill Level {amount})",client, skillname, curskilllevel+1);

							new minlevel = 0; //counter measure: if I define them here and not within the for loop, I don't define them "SkillCount" times. less ressources used
							new skilllevelinternal = 0; // ^
							for(new i= 1; i<=SkillCount; i++) //now lets loop again to see if we can find the mysterious skill xyz thats so important!
							{
								minlevel = War3_SkillTreeDependencyLevel(race_num, i); //skill x depends on something lvl ??. What's the req.?
								new i_skillIDdepends = War3_GetSkillTreeDependencyID(race_num, i); //finally, x depends on skill xyz. what's its ID?

								if(i_skillIDdepends == i)
								{ //the skill we need (i_SkillIDdepends) is i! we have a winner! wohoo! now lets apply the stuff!
									skilllevelinternal = GetSkillLevelINTERNAL(client,race_num,i);

									if( skilllevelinternal >= minlevel) //has he leveled the skill needed higher than/equal to the required parameter?
									{
										decl String:name[64];
										W3GetRaceSkillName(race_num,i,name,sizeof(name));
										Format(buf, sizeof(buf),"%s %T",buf,"[Requires {skillname} L{amount}]",client, name, minlevel);
										//finally, apply all necessary changes to the menu
									}
								}
							}
							AddMenuItem(sMenu, sbuf, buf, (skilllevelinternal >= minlevel)?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED); //defines the way the skill is displayed (white: non selectable / yellow: like normal
						}*/
						//if(curskilllevel<GetRaceSkillMaxLevel(race_num,x)) //, show if 3 when maxlevel is 4 not max level
					}
				}

			}
			DisplayMenu(sMenu,client,20);
		}
	}
}

public War3Source_SMenu_Selected(Handle:menu,MenuAction:action,client,selection)
{
	if(action==MenuAction_Select)
	{
		//PrintToChatAll("Client %d's menu was selected.[MenuAction_Select]  Reason: %d", client, selection);

		if(ValidPlayer(client,false))
		{
			new raceid=GetRace(client);
			if(selection>=0&&selection<=GetRaceSkillCount(raceid))
			{
				// OPTIMZE THIS
				decl String:SelectionInfo[4];
				GetMenuItem(menu, selection, SelectionInfo, sizeof(SelectionInfo));
				new skill=StringToInt(SelectionInfo);



				if(IsSkillUltimate(raceid,selection))
				{
					new race=GetRace(client);
					new level=War3_GetLevel(client,race);
					if(level>=W3GetMinUltLevel())
					{
						if(GetLevelsSpent(client,race)<War3_GetLevel(client,race))
						{
							SetSkillLevelINTERNAL(client,race,skill,GetSkillLevelINTERNAL(client,race,skill)+1);
							decl String:skillname[64];
							if(GetRaceSkillName(race,skill,skillname,sizeof(skillname))>0)
							{
								War3_ChatMessage(client,"%T","{skillname} is now level {amount}",client,skillname,War3_GetSkillLevelINTERNAL(client,race,skill));
							}
							else
							{
								LogError("MenuSpendSkills - War3Source Lookup of GetRaceSkillName(%d,%d,%s,sizeof(%d))",race,skill,skillname,sizeof(skillname));
							}
						}
						else
							War3_ChatMessage(client,"%T","You can not choose a skill without gaining another level",client);
					}
					else{
						War3_ChatMessage(client,"%T","You need to be at least level {amount} to choose an ultimate",client,W3GetMinUltLevel());
					}

				}
				else
				{
					new race=GetRace(client);
					if(GetLevelsSpent(client,race)<War3_GetLevel(client,race))
					{
						SetSkillLevelINTERNAL(client,race,skill,GetSkillLevelINTERNAL(client,race,skill)+1);
						decl String:skillname[64];
						if(GetRaceSkillName(race,skill,skillname,sizeof(skillname))>0)
						{
							War3_ChatMessage(client,"%T","{skillname} is now level {amount}",client,skillname,War3_GetSkillLevelINTERNAL(client,race,skill));
						}
						else
						{
							LogError("MenuSpendSkills - War3Source:EVO Lookup of GetRaceSkillName(%d,%d,%s,sizeof(%d))",race,skill,skillname,sizeof(skillname));
						}
					}
					else{
						War3_ChatMessage(client,"%T","You can not choose a skill without gaining another level",client);
					}
				}
				W3DoLevelCheck(client);
			}
		}
	} else if(action==MenuAction_Cancel)
	{
		if(selection==MenuCancel_Exit||selection==MenuCancel_Timeout)
		{
			//PrintToChatAll("Client %d's menu was selected.[MenuAction_Cancel]  Reason: %d", client, selection);
			if(ValidPlayer(client))
			{
				new race=GetRace(client);
				if(GetLevelsSpent(client,race)<War3_GetLevel(client,race))
				{
					War3_ChatMessage(client,"{lightgreen}You did not select any skills.\nYour skills were auto assigned.\nType resetskills in chat to reconfigure them.{default}");
					War3_bots_distribute_sp(client);
				}
			}
		}
	} else if(action==MenuAction_End)
	{
		//PrintToChatAll("Client %d's menu was selected.[MenuAction_End]  Reason: %d", client, selection);
		CloseHandle(menu);
	}
}
