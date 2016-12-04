// War3Source_Engine_OnWar3Event.sp


public void Internal_War3_Event(W3EVENT event,int client)
{
	War3Source_Engine_DatabaseTop100_OnWar3Event(event,client);

#if GGAMEMODE == MODE_WAR3SOURCE
	War3Source_Engine_ItemOwnership_OnWar3Event(event,client);
	War3Source_Engine_ItemOwnership2_OnWar3Event(event,client);
#endif

#if SHOPMENU3 == MODE_ENABLED
	War3Source_Engine_ItemOwnership3_OnWar3Event(event,client);
#endif
	War3Source_Engine_MenuRacePlayerinfo_OnWar3Event(event,client);

#if GGAMEMODE == MODE_WAR3SOURCE
	War3Source_Engine_MenuShopmenu_OnWar3Event(event,client);
	War3Source_Engine_MenuShopmenu2_OnWar3Event(event,client);
#endif

#if SHOPMENU3 == MODE_ENABLED
	War3Source_Engine_MenuShopmenu3_OnWar3Event(event,client);
#endif
	War3Source_Engine_PlayerClass_OnWar3Event(event,client);

	War3Source_Engine_PlayerLevelbank_OnWar3Event(event,client);

#if SHOPMENU3 == MODE_ENABLED
	War3Source_Engine_XP_Platinum_OnWar3Event(event,client);
#endif

	switch(event)
	{
		case InitPlayerVariables:
		{
			DatabaseInitPlayerVariables(client);
		}
		case ClearPlayerVariables:
		{
			DeleteObject(client);

			// War3Source_Engine_Aura
			InternalClearPlayerVars(client);
			DatabaseClearPlayerVars(client);
			return;
		}
		case DatabaseConnected:
		{
			//War3Source_Engine_Bank
			g_hDatabase=internal_W3GetVar(hDatabase);

			War3Source_Engine_Race_KDR_OnWar3Event(client);
			War3Source_Engine_DatabaseSaveXP_OnWar3Event(client);
#if SHOPMENU3 == MODE_ENABLED
			War3Source_Engine_ItemDatabase3_OnWar3Event(client);
#endif
			return;
		}

		case OnBuffChanged:
		{
			War3Source_Engine_BuffMaxHP_OnWar3Event(client);
			War3Source_Engine_Notifications_OnWar3Event(client);
			return;
		}

		case DoShowHelpMenu:
		{
			War3Source_Engine_HelpMenu_OnWar3Event(client);
			return;
		}

		case DoShowChangeRaceMenu:
		{
			War3Source_Engine_MenuChangerace_OnWar3Event(client);
			return;
		}

#if GGAMEMODE == MODE_WAR3SOURCE
		case DoShowItemsInfoMenu:
		{
			War3Source_Engine_MenuItemsinfo_OnWar3Event(client);
			return;
		}

		case DoShowItems2InfoMenu:
		{
			War3Source_Engine_MenuItemsinfo2_OnWar3Event(client);
			return;
		}
#endif

		case DoShowItems3InfoMenu:
		{
#if SHOPMENU3 == MODE_ENABLED
			War3Source_Engine_MenuItemsinfo3_OnWar3Event(client);
#endif
			return;
		}

		case DoShowSpendskillsMenu:
		{
			War3Source_Engine_MenuSpendskills_OnWar3Event(client);
			return;
		}

		case DoShowWar3Menu:
		{
			War3Source_Engine_MenuWar3Menu_OnWar3Event(client);
			return;
		}

		case DoLevelCheck:
		{
			War3Source_Engine_XPGold_OnWar3Event(client);
			return;
		}

		case PlayerLeveledUp:
		{
			War3Source_Engine_BotControl_OnWar3Event(client);
		}
	}
}

