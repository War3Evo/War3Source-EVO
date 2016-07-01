#include <war3source>

#define PLUGIN_VERSION "(7/1/2016)"
/**
 * File: War3Source_ShopItems.sp
 * Description: The shop items that come with War3Source.
 * Author(s): Anthony Iacono
 *
 *-- Added mypiggybank  == Cash Regen for MVM
 *-- Uncomment line 143 in order to enable it.
 *--
 *-- El Diablo
 *-- www.war3evo.info
 */

#pragma semicolon 1

#assert GGAMEMODE == MODE_WAR3SOURCE

#if GGAMETYPE == GGAME_TF2
enum ITEMENUM{
	POSTHASTE=0,
	TRINKET,
	LIFETUBE,
	SNAKE_BRACELET,
	FORTIFIED_BRACER,
	CASH_REGEN
}
#elseif (GGAMETYPE == GGAME_CSS || GGAMETYPE == GGAME_CSGO)
enum ITEMENUM{
	POSTHASTE=0,
	TRINKET,
	LIFETUBE,
	SNAKE_BRACELET,
	FORTIFIED_BRACER,
}
#endif
int ItemID[MAXITEMS2];

// Regen Cash
#if GGAMETYPE2 == GGAME_MVM
bool CASH_REGEN_PLAYERS[MAXPLAYERSCUSTOM]=false;
int MVM_CURRENT_CASH[MAXPLAYERSCUSTOM]=0;
Handle cvarAmount;
Handle cvarTime;
bool Enable_Cash_Regen=false;
char[] MyPiggyBankSound="war3source/piggybank/mypiggybank2.mp3";
#endif

public Plugin:myinfo =
{
	name = "W3S - Shopitems2",
	author = "Ownz & El Diablo",
	description = "The shop items that come with War3Source:EVO.",
	version = "1.0.0.0",
	url = "http://war3source.com/"
};

public void OnAllPluginsLoaded()
{
	W3Hook(W3Hook_OnW3TakeDmgBulletPre, OnW3TakeDmgBulletPre);
}

public OnPluginStart()
{

	CreateConVar("shopmenu2",PLUGIN_VERSION,"War3Source:EVO shopmenu 2",FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);

	//RegConsoleCmd("+ability1",War3Source_AbilityCommand);
	//RegConsoleCmd("-ability1",War3Source_AbilityCommand);

	//CreateTimer(1.0,test,_,TIMER_REPEAT);
	//W3CreateCvar("w3shop2items","loaded","is the shop2 loaded");
#if GGAMETYPE2 == GGAME_MVM
	cvarAmount = CreateConVar("sm_cashregen_amount", "20", "Amount of money generated per increment", _, true, 0.0, true, 1000.0);
	cvarTime = CreateConVar("sm_cashregen_time", "20", "Time between cash regens", _, true, 0.0);

	if(!HookEventEx("mvm_begin_wave", MVM_OnRoundStart))
	{
		PrintToServer("[War3Source:EVO] Could not hook the mvm_begin_wave event.");
	}
	if(!HookEventEx("teamplay_round_win", MVM_OnTeamplayRoundWin))
	{
		PrintToServer("[War3Source:EVO] Could not hook the teamplay_round_win event.");
	}
	if(!HookEventEx("mvm_wave_complete", MVM_OnRoundEnd))
	{
		PrintToServer("[War3Source:EVO] Could not hook the mvm_wave_complete event.");
	}
	if(!HookEventEx("mvm_mission_complete", MVM_OnRoundComplete))
	{
		PrintToServer("[War3Source:EVO] Could not hook the mvm_mission_complete event.");
	}
	if(!HookEventEx("mvm_pickup_currency", War3Source_MvMCurrencyEvent))
	{
		PrintToServer("[War3Source:EVO] Could not hook the mvm_pickup_currency event.");
	}

	CreateTimer(GetConVarFloat(cvarTime), Timer_Cash, _, TIMER_REPEAT);

	IsMvM(true);
#endif
}

#if GGAMETYPE == GGAME_TF2
public OnWar3EventDeath(victim, attacker, deathrace, distance, attacker_hpleft)
{
	if(War3_GetOwnsItem2(victim,ItemID[SCROLL_OF_ESSENCE])&&ValidPlayer(victim))
	{
		W3Hint(victim,HINT_NORMAL,5.0,"Scroll of Essence revives you");
		CreateTimer(1.2,instaspawn,victim);
	}
}

public Action:instaspawn(Handle:timer, any:client)
{
	if(ValidPlayer(client) && !IsPlayerAlive(client))
	{
		TF2_RespawnPlayer(client);
	}
}
#endif

public OnWar3LoadRaceOrItemOrdered(num)
{
	if(num==10){

		for(int x=0;x<MAXITEMS2;x++)
			ItemID[x]=0;

		ItemID[POSTHASTE]=War3_CreateShopItem2T("posthaste","+3% speed",10);
		if(ItemID[POSTHASTE]==0){
			DP("ERR ITEM ID RETURNED IS ZERO");
		}
		ItemID[TRINKET]=War3_CreateShopItem2T("trinket","+0.5 HP regeneration",15);
		ItemID[LIFETUBE]=War3_CreateShopItem2T("lifetube","+1 HP regeneration",40);
		ItemID[SNAKE_BRACELET]=War3_CreateShopItem2T("sbracelt","+5% Evasion",10);
		ItemID[FORTIFIED_BRACER]=War3_CreateShopItem2T("fbracer","+10 max HP",10);
#if GGAMETYPE == GGAME_TF2
		//ItemID[SCROLL_OF_ESSENCE]=War3_CreateShopItem2("Scroll of Essence","scrollessence","instant respawn","The essence of life flows back into you\nand gives you instant respawn.",60000);

		//ItemID[DIE_LAUGHING]=War3_CreateShopItem2("Die Laughing","dielaughing","force enemy taunt on death","The person whom kills you is forced to taunt.",12000);
		//ItemID[ITEM_BOOSTER]=War3_CreateShopItem2("Item Enhancer","itembooster","Boost Items from Shopmenu 1.",60);
		//ItemID[SCROLL_OF_REVIVE]=War3_CreateShopItem2("Scroll of the Phoenix","scrollphoenix","Instant revive from death (like bloodmage revive on you).",300);
#if GGAMETYPE2 == GGAME_MVM
		ItemID[CASH_REGEN]=War3_CreateShopItem2("My Piggy Bank","mvmcashregen","MVM cash regeneration","Cash regeneration.",60000);
#endif

#endif
	}
}

#if GGAMETYPE2 == GGAME_MVM
public OnMapStart()
{
	//War3_PrecacheSound(MyPiggyBankSound);
	IsMvM(true);
}
public OnAddSound(sound_priority)
{
	if(sound_priority==PRIORITY_BOTTOM)
	{
		War3_AddSound(MyPiggyBankSound);
	}
}
#endif
public OnItem2Purchase(client,item)
{
//DP("purchase %d %d",client,item);
	if(item==ItemID[POSTHASTE] )
	{
		War3_SetBuffItem2(client,fMaxSpeed2,ItemID[POSTHASTE],1.034);
	}
	if(item==ItemID[TRINKET] )
	{
		War3_SetBuffItem2(client,fHPRegen,ItemID[TRINKET],0.5);
	}
	if(item==ItemID[LIFETUBE] )
	{
		War3_SetBuffItem2(client,fHPRegen,ItemID[LIFETUBE],1.0);
	}
	if(item==ItemID[FORTIFIED_BRACER]){

		War3_SetBuffItem2(client,iAdditionalMaxHealth,ItemID[FORTIFIED_BRACER],10);
		War3_SetBuffItem2(client,fHPRegenDeny,ItemID[FORTIFIED_BRACER],true);
		War3_HealToMaxHP(client,10);
	}
#if GGAMETYPE2 == GGAME_MVM
	if(item==ItemID[CASH_REGEN])
	{
		CASH_REGEN_PLAYERS[client]=true;
		War3_ChatMessage(client,"{lightgreen}My Piggy Bank Appears before you!{default}");
		EmitSoundToClient(client,MyPiggyBankSound);
	}
#endif
}

public OnItem2Lost(client,item){ //deactivate passives , client may have disconnected
//DP("lost %d %d",client,item);
	if(item==ItemID[POSTHASTE]){
		War3_SetBuffItem2(client,fMaxSpeed2,ItemID[POSTHASTE],1.0);
	}
	if(item==ItemID[TRINKET] ) // boots of speed
	{
		War3_SetBuffItem2(client,fHPRegen,ItemID[TRINKET],0.0);
	}
	if(item==ItemID[LIFETUBE] ) // boots of speed
	{
		War3_SetBuffItem2(client,fHPRegen,ItemID[LIFETUBE],0.0);
	}
	if(item==ItemID[FORTIFIED_BRACER]){
		War3_SetBuffItem2(client,iAdditionalMaxHealth,ItemID[FORTIFIED_BRACER],0);
		War3_SetBuffItem(client,fHPRegenDeny,ItemID[FORTIFIED_BRACER],false);
	}
#if GGAMETYPE2 == GGAME_MVM
	if(item==ItemID[CASH_REGEN])
	{
		int tempint = War3_GetDiamonds(client)+40;
		War3_SetDiamonds(client,tempint);
		CASH_REGEN_PLAYERS[client]=false;
	}
#endif
}
public Action OnW3TakeDmgBulletPre(int victim, int attacker, float damage, int damagecustom)
{
//sh has no shop2 items
	if(IS_PLAYER(victim)&&IS_PLAYER(attacker)&&victim>0&&attacker>0&&attacker!=victim)
	{
		int vteam=GetClientTeam(victim);
		int ateam=GetClientTeam(attacker);
		if(vteam!=ateam)
		{
			if(!Perplexed(victim,false)&&War3_GetOwnsItem2(victim,ItemID[SNAKE_BRACELET]))
			{
				if(W3Chance(0.05))
				{
					War3_DamageModPercent(0.0); //NO DAMAMGE
					W3MsgEvaded(victim,attacker);
				}
			}
		}
	}
}
#if GGAMETYPE2 == GGAME_MVM
					//mvm_bomb_deploy_reset_by_player      OnRoundDeployReset
public MVM_OnRoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	Enable_Cash_Regen=true;
}

public MVM_OnTeamplayRoundWin(Handle:event, const String:name[], bool:dontBroadcast)
{
	//DP("teamplay_round_win");
	Enable_Cash_Regen=false;
	for(new i = 1; i <= MaxClients; i++)
		{
			if(CASH_REGEN_PLAYERS[i])
			{
				War3_ChatMessage(i,"{lightgreen}My Piggy Bank Vanishes!{default}");
				War3_SetOwnsItem2(i,ItemID[CASH_REGEN],false);
				War3_ChatMessage(i,"{lightgreen}Please wait 20 seconds for money corrections!{default}");
				CreateTimer(20.0,EndOfRound_Timer_Cash,i);
			}
		}
}

public MVM_OnRoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	Enable_Cash_Regen=false;
	for(new i = 1; i <= MaxClients; i++)
		{
			if(CASH_REGEN_PLAYERS[i])
			{
				War3_ChatMessage(i,"{lightgreen}My Piggy Bank Vanishes!{default}");
				//CASH_REGEN_PLAYERS[i]=false;
				War3_SetOwnsItem2(i,ItemID[CASH_REGEN],false);
				War3_ChatMessage(i,"{lightgreen}Please wait 20 seconds for money corrections!{default}");
				CreateTimer(20.0,EndOfRound_Timer_Cash,i);
			}
		}
}

public MVM_OnRoundComplete(Handle:event, const String:name[], bool:dontBroadcast)
{
	Enable_Cash_Regen=false;
	for(new i = 1; i <= MaxClients; i++)
		{
			if(CASH_REGEN_PLAYERS[i])
			{
				War3_ChatMessage(i,"{lightgreen}My Piggy Bank Vanishes!{default}");
				War3_SetOwnsItem2(i,ItemID[CASH_REGEN],false);
				War3_ChatMessage(i,"{lightgreen}Please wait 20 seconds for money corrections!{default}");
				CreateTimer(20.0,EndOfRound_Timer_Cash,i);
			}
		}
}

public Action:EndOfRound_Timer_Cash(Handle:g_Timer, any:i)
{
	if(!IsValidClient(i) || IsFakeClient(i))
	{
		//Plugin_Continue;
	}
	else
	{
		War3_ChatMessage(i,"{lightgreen}My Piggy Bank is correcting your funds!{default}");
		War3_ChatMessage(i,"{lightgreen}Don't forget to buy another My Piggy Bank, if you can afford it!{default}");
		new CurrentCash = GetEntProp(i, Prop_Send, "m_nCurrency");
		if (MVM_CURRENT_CASH[i]>CurrentCash)
		{
			CurrentCash=MVM_CURRENT_CASH[i];
		}
		if(CurrentCash <= 0 ) SetEntProp(i, Prop_Send, "m_nCurrency", 4000);
		if(CurrentCash <= 32767 - GetConVarInt(cvarAmount)) SetEntProp(i, Prop_Send, "m_nCurrency", CurrentCash + GetConVarInt(cvarAmount));
		MVM_CURRENT_CASH[i]=0;
	}

	return Plugin_Continue;
}

// pickup money
public War3Source_MvMCurrencyEvent(Handle:event,const String:name[],bool:dontBroadcast)
{
	new i = GetEventInt(event, "player");
	//new currency = GetEventInt(event, "currency");

	if (ValidPlayer(i, true))
	{
		new CurrentCash = GetEntProp(i, Prop_Send, "m_nCurrency");
		if (MVM_CURRENT_CASH[i]<CurrentCash)
		{
			MVM_CURRENT_CASH[i]=CurrentCash;
		}
	}

}

public Action:Timer_Cash(Handle:g_Timer)
{
	//DP("Timer for Cash Regen");
	if(Enable_Cash_Regen==true)
	{
	//DP("if(Enable_Cash_Regen==true)");
	for(new i = 1; i <= MaxClients; i++)
		{
			if(!IsValidClient(i) || IsFakeClient(i)) continue;
			//DP("Cash Regen MaxClients %i",i);
			if(CASH_REGEN_PLAYERS[i]==true)
			{
				new CurrentCash = GetEntProp(i, Prop_Send, "m_nCurrency");
				if (MVM_CURRENT_CASH[i]<CurrentCash)
				{
					MVM_CURRENT_CASH[i]=CurrentCash;
				}
				else
				{
					CurrentCash=MVM_CURRENT_CASH[i];
				}
				if(CurrentCash <= 32767 - GetConVarInt(cvarAmount)) SetEntProp(i, Prop_Send, "m_nCurrency", CurrentCash + GetConVarInt(cvarAmount));
			}
		}
	}
	return Plugin_Continue;
}

stock IsValidClient(client, bool:replay = true)
{
	if(client <= 0 || client > MaxClients || !IsClientInGame(client) || GetEntProp(client, Prop_Send, "m_bIsCoaching")) return false;
	if(replay && (IsClientSourceTV(client) || IsClientReplay(client))) return false;
	return true;
}

stock ClearTimer(&Handle:g_Timer)
{
	if(g_Timer != INVALID_HANDLE)
	{
		KillTimer(g_Timer);
		g_Timer = INVALID_HANDLE;
	}
}

#endif
