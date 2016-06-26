#include <war3source>

#define PLUGIN_VERSION "3.0a (6/26/2016)"
/**
 * File: War3Source_ShopItems.sp
 * Description: The shop items that come with War3Source:EVO.
 * Author(s): Anthony Iacono
 *--
 *-- Add all shopmenu items into the code, including War3Source:EVO shopmenu items.
 *-- El Diablo
 *-- www.war3evo.info
 */

#pragma semicolon 1

#assert GGAMEMODE == MODE_WAR3SOURCE

//#include <cstrike>

//plates
char helmSound0[]="physics/metal/metal_solid_impact_bullet1.wav";
char helmSound1[]="physics/metal/metal_solid_impact_bullet2.wav";
char helmSound2[]="physics/metal/metal_solid_impact_bullet3.wav";
char helmSound3[]="physics/metal/metal_solid_impact_bullet4.wav";

enum{
	ANKH=0,
	BOOTS,
	CLAW,
#if GGAMETYPE_JAILBREAK == JAILBREAK_OFF
	CLOAK,
#endif
	MASK,
	NECKLACE,
	FROST,
	TOME,
	SOCK,
	RING,
	OIL,
	PLATES,
	HELM,
	SHIELD,
	GAUNTLET,
#if GGAMETYPE == GGAME_TF2
	FIREORB,
#endif
	COURAGE,
	FAITH,
	ARMBAND,
	ANTIWARD,
#if GGAMETYPE == GGAME_TF2
	UBER50,
#endif
	ARMOR_PIERCING,
#if GGAMETYPE == GGAME_TF2
	ANTIHACKITEM,
	MBOOTS,
	MRING,
	MHEALTH,
#endif
#if GGAMETYPE2 == GGAME_PVM
	LEATHER,
	CHAINMAIL,
	BANDEDMAIL,
	HALFPLATE,
	FULLPLATE,
	DRAGONMAIL,
#endif
}

int shopItem[MAXITEMS];//
bool bDidDie[65]; // did they die before spawning?
Handle BootsSpeedCvar;
#if GGAMETYPE_JAILBREAK == JAILBREAK_OFF
#endif
Handle ClawsAttackCvar;
Handle MaskDeathCvar;
bool bFrosted[65]; // don't frost before unfrosted
Handle OrbFrostCvar;
Handle TomeCvar;
Handle SockCvar;
Handle RegenHPTFCvar;

char masksnd[256]; //="war3source/mask.mp3";
int maskSoundDelay[66];

// shield
int MoneyOffsetCS;
Handle ShieldRestrictionCvar;

// fireorb
#if GGAMETYPE == GGAME_TF2
float g_fExtinguishNow[MAXPLAYERS];
const Float:fSecondsTillExtinguish = 3.0;
#endif

public Plugin:myinfo =
{
	name = "W3S - Shopitems",
	author = "PimpinJuice && El Diablo",
	description = "The shop items that come with War3Source.",
	version = "1.0.0.0",
	url = "https://forums.alliedmods.net/showthread.php?p=2430864"
};

public void OnAllPluginsLoaded()
{

	W3Hook(W3Hook_OnW3TakeDmgAll, OnW3TakeDmgAll);
#if GGAMETYPE == GGAME_TF2
	W3Hook(W3Hook_OnW3TakeDmgBullet, OnW3TakeDmgBullet);
#endif
	W3Hook(W3Hook_OnWar3Event, OnWar3Event);
}

public OnPluginStart()
{
	CreateConVar("shopmenu1",PLUGIN_VERSION,"War3Source:EVO shopmenu1", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);

	BootsSpeedCvar=CreateConVar("war3_shop_boots_speed","1.2","Boots speed, 1.2 is default");
	ClawsAttackCvar=CreateConVar("war3_shop_claws_damage","0.10","Claws of attack additional percentage damage per second");
	MaskDeathCvar=CreateConVar("war3_shop_mask_percent","0.50","Percent of damage rewarded for Mask of Death, from 0.0 - 1.0");
	OrbFrostCvar=CreateConVar("war3_shop_orb_speed","0.6","Orb of Frost speed, 1.0 is normal speed, 0.6 default for orb.");
	TomeCvar=CreateConVar("war3_shop_tome_xp","10","Experience awarded for Tome of Experience.");
	SockCvar=CreateConVar("war3_shop_sock_gravity","0.4","Gravity used for Sock of Feather, 0.4 is default for sock, 1.0 is normal gravity");
#if GGAMETYPE == GGAME_TF2
	RegenHPTFCvar=CreateConVar("war3_shop_ring_hp_tf","4","How much HP is regenerated for TF.");
#else
	RegenHPTFCvar=CreateConVar("war3_shop_ring_hp_tf","2","How much HP is regenerated for CSS.");
#endif

	CreateTimer(0.1,PointOneSecondLoop,_,TIMER_REPEAT);
#if GGAMETYPE == GGAME_TF2
	CreateTimer(1.0,SecondLoop,_,TIMER_REPEAT);
#endif

	for(new i=1;i<=MaxClients;i++){
		maskSoundDelay[i]=War3_RegisterDelayTracker();
	}
	LoadTranslations("w3s._common.phrases");
	LoadTranslations("w3s.item.helm.phrases");
	LoadTranslations("w3s.item.courage.phrases");
	LoadTranslations("w3s.item.antiward.phrases");
	LoadTranslations("w3s.item.uberme.phrases");
#if GGAMETYPE == GGAME_TF2
	LoadTranslations("w3s.item.fireorb.phrases");
#endif

	//shield
	ShieldRestrictionCvar=CreateConVar("war3_shop_shield_restriction","0","Set this to 1 if you want to forbid necklace+shield. 0 default");
	LoadTranslations("w3s.item.shield.phrases");

}

public OnAddSound(sound_priority)
{
	if(sound_priority==PRIORITY_TOP)
	{
		War3_AddSound(helmSound0,STOCK_SOUND);
		War3_AddSound(helmSound1,STOCK_SOUND);
		War3_AddSound(helmSound2,STOCK_SOUND);
		War3_AddSound(helmSound3,STOCK_SOUND);
	}
	if(sound_priority==PRIORITY_LOW)
	{
		strcopy(masksnd,sizeof(masksnd),"war3source/mask.mp3");
		War3_AddSound(masksnd);
	}
}
#if GGAMETYPE_JAILBREAK == JAILBREAK_OFF
bool war3ready;
#endif
public OnWar3LoadRaceOrItemOrdered(num)
{
	if(num==40){
#if GGAMETYPE_JAILBREAK == JAILBREAK_OFF
		war3ready=true;
#endif
		for(new x=0;x<MAXITEMS;x++)
			shopItem[x]=0;
		shopItem[BOOTS]=War3_CreateShopItemT("boot","fun faster",3,2500);

		shopItem[CLAW]=War3_CreateShopItemT("claw","extra dmg to enemy",3,5000);
#if GGAMETYPE_JAILBREAK == JAILBREAK_OFF
		shopItem[CLOAK]=War3_CreateShopItemT("cloak","partially invisible",2,1000);
#endif

		shopItem[MASK]=War3_CreateShopItemT("mask","gain hp on hit",3,1500);

		shopItem[NECKLACE]=War3_CreateShopItemT("lace","immunity to ultimates",2,800);

		shopItem[FROST]=War3_CreateShopItemT("orb","slow on hit",3,2000);

		shopItem[RING]=War3_CreateShopItemT("ring","regenerate hp",3,1500);

		shopItem[TOME]=War3_CreateShopItemT("tome","gold for xp",10,10000);
		War3_SetItemProperty(	shopItem[TOME], ITEM_USED_ON_BUY,true);

		shopItem[SOCK]=War3_CreateShopItemT("sock","less gravity",2,1500);

		shopItem[OIL]=War3_CreateShopItem("Oil of Penetration","oil","penetrate helm/plates","Coats your weapons with ability to penetrate plates and helm.",8,3500);

		shopItem[PLATES]=War3_CreateShopItem("Plates of Protection","plate","no dmg to chest","Prevents All Damage to Chest.",10,3500);

		shopItem[HELM]=War3_CreateShopItemT("helm","no headshots to self",10,3500);

		shopItem[SHIELD]=War3_CreateShopItemT("shield","immunity to skills",3,2000);

		shopItem[GAUNTLET]=War3_CreateShopItem("Gauntlet of Endurance","gauntlet","35 more max hp","Increases max health by 35 HP",5,3000);
#if GGAMETYPE == GGAME_TF2
		shopItem[FIREORB]=War3_CreateShopItemT("fireorb","chance fire enemy", 10, 4000);
#endif

		shopItem[COURAGE]=War3_CreateShopItem("Armor of Courage","courage","15% dmg reduction","increases up to 15% resistance against all physcial damage\n(does not block magical)\n(does not stack with other armor increases)",10,3000);

		shopItem[FAITH]=War3_CreateShopItem("Armor of Faith","faith","15% magic dmg reduction","increases up to 15% resistance against all magical damage\n(does not block physical)\n(does not stack with other armor increases)",10,3000);

		shopItem[ARMBAND]=War3_CreateShopItem("Armband of Repetition","armband","15% more dps","Increases attack speed by 15%\n(does not stack with other attack speed increases)",10,3000);

		shopItem[ANTIWARD]=War3_CreateShopItemT("antiward","immunity to wards",3,3000);

#if GGAMETYPE == GGAME_TF2
		shopItem[UBER50]=War3_CreateShopItem("+50 Uber","uber50","+50 uber","+50 Uber is added to your current uber",150,3000);
		War3_TFSetItemClasses(shopItem[UBER50],TFClass_Medic);
		War3_SetItemProperty(shopItem[UBER50], ITEM_USED_ON_BUY,true);
#endif

		shopItem[ARMOR_PIERCING]=War3_CreateShopItem("Physical Armor Piercing","piercing","pierce physical armor",
		"Upgrades your weapons with ability to penetrate physical armor.\nRequires Oil of Penetration",20,3500);

#if GGAMETYPE == GGAME_TF2
		shopItem[ANTIHACKITEM]=War3_CreateShopItem("Building Anti-Hack","stophack","stop hacks","When a someone tries to hack your building,\nthis item will be used instead.\n(single use item)",20,3000);
		War3_TFSetItemClasses(shopItem[ANTIHACKITEM],TFClass_Engineer);
		War3_SetItemProperty(shopItem[ANTIHACKITEM], ITEM_USED_ON_BUY,false);

		shopItem[MBOOTS]=War3_CreateShopItem("Medi Boots","mboots","Give Speed","Gives healing target increased movement speed",9,3000);
		War3_TFSetItemClasses(shopItem[MBOOTS],TFClass_Medic);
		shopItem[MRING]=War3_CreateShopItem("Medi Ring","mring","Give Regen","Gives healing target regeneration of hp",9,3000);
		War3_TFSetItemClasses(shopItem[MRING],TFClass_Medic);
		shopItem[MHEALTH]=War3_CreateShopItem("Medi Health","mhealth","Give More Health","Gives healing target extra hp",9,3000);
		War3_TFSetItemClasses(shopItem[MHEALTH],TFClass_Medic);
#endif

#if GGAMETYPE2 == GGAME_PVM
		// Armor
		shopItem[LEATHER]=War3_CreateShopItem("Leather Armor +12","leather","+12 phys armor","Increases physical armor by +12",24,3000);
		shopItem[CHAINMAIL]=War3_CreateShopItem("Chainmail Armor +14","chainmail","+14 phys armor","Increases physical armor by +14",28,3000);
		shopItem[BANDEDMAIL]=War3_CreateShopItem("Banded mail Armor +16","bandedmail","+16 phys armor","Increases physical armor by +16",32,3000);
		shopItem[HALFPLATE]=War3_CreateShopItem("Half-plate Armor +18","halfplate","+18 phys armor","Increases physical armor by +18",36,3000);
		shopItem[FULLPLATE]=War3_CreateShopItem("Full-plate Armor +20","fullplate","+20 phys armor","Increases physical armor by +20",40,3000);

		shopItem[DRAGONMAIL]=War3_CreateShopItem("Dragon mail Armor +50","dragonmail","+50 magic armor","Increases magical armor by +50",50,3000);

		War3_AddItemBuff(shopItem[LEATHER], fArmorPhysical, 12.0);
		War3_AddItemBuff(shopItem[CHAINMAIL], fArmorPhysical, 14.0);
		War3_AddItemBuff(shopItem[BANDEDMAIL], fArmorPhysical, 16.0);
		War3_AddItemBuff(shopItem[HALFPLATE], fArmorPhysical, 18.0);
		War3_AddItemBuff(shopItem[FULLPLATE], fArmorPhysical, 20.0);

		War3_AddItemBuff(shopItem[DRAGONMAIL], fArmorMagic, 50.0);
#endif

		War3_AddItemBuff(shopItem[ANTIWARD], bImmunityWards, true);
		War3_AddItemBuff(shopItem[SOCK], fLowGravityItem, GetConVarFloat(SockCvar));
		War3_AddItemBuff(shopItem[NECKLACE], bImmunityUltimates, true);
		War3_AddItemBuff(shopItem[RING], fHPRegen, GetConVarFloat(RegenHPTFCvar));
		War3_AddItemBuff(shopItem[BOOTS], fMaxSpeed, GetConVarFloat(BootsSpeedCvar));
		War3_AddItemBuff(shopItem[SHIELD], bImmunitySkills, true);
		War3_AddItemBuff(shopItem[GAUNTLET], iAdditionalMaxHealth, 35);
		War3_AddItemBuff(shopItem[ARMBAND], fAttackSpeed, 1.15);
#if GGAMETYPE == GGAME_TF2
		War3_AddItemBuff(shopItem[ANTIHACKITEM], bImmunityHacks, true);
#endif
	}
}

public OnWar3PluginReady()
{
	ServerCommand("war3 faith_itemcategory \"Defense\"");
}

#if GGAMETYPE == GGAME_TF2
int HealingTarget[MAXPLAYERSCUSTOM];
public Action:SecondLoop(Handle:timer,any:data)
{
	if(W3Paused()) return Plugin_Continue;

	for(int client=1; client <= MaxClients; client++)
	{
		if(ValidPlayer(client, true))
		{
			// Medic Special Items
			if (TF2_GetPlayerClass(client) != TFClass_Medic)
				continue;	// Client isnt valid

			int HealTarget = TF2_GetHealingTarget(client);

			if(HealingTarget[client]>0 && HealingTarget[client]!=HealTarget)
			{
				//DP("HealingTarget[client]!=HealTarget");
				// reset buffs
				//fMaxSpeed2
				War3_SetBuffItem(HealingTarget[client],fMaxSpeed2,shopItem[MBOOTS],1.0);
				// Regen
				War3_SetBuffItem(HealingTarget[client],fHPRegen,shopItem[MRING],0.0);
				// Additional Health
				War3_SetBuffItem(HealingTarget[client],iAdditionalMaxHealth,shopItem[MHEALTH],0);
			}


			if(ValidPlayer(HealTarget))
			{
				HealingTarget[client]=HealTarget;

				if(IsPlayerAlive(HealTarget)) // if alive
				{
					//DP("HealTarget IsPlayerAlive 368");
					if(War3_GetOwnsItem(client,shopItem[MBOOTS]))
					{
						//fMaxSpeed2
						War3_SetBuffItem(HealTarget,fMaxSpeed2,shopItem[MBOOTS],1.2,client);
						//CreateTimer(1.0,SecondLoop,_,TIMER_REPEAT);
						//DP("set MaxSpeed2 HealTarget");
					}
					if(War3_GetOwnsItem(client,shopItem[MRING]))
					{
						// Regen
						War3_SetBuffItem(HealTarget,fHPRegen,shopItem[MRING],2.0,client);
						//DP("set fHPRegen HealTarget");
					}
					if(War3_GetOwnsItem(client,shopItem[MHEALTH]))
					{
						// Regen
						War3_SetBuffItem(HealTarget,iAdditionalMaxHealth,shopItem[MHEALTH],100,client);
						//DP("set iAdditionalMaxHealth HealTarget");
					}
					continue;
				}
				else
				{
					//DP("HealTarget !IsPlayerAlive 392");
					HealingTarget[client]=-1;
					if(War3_GetOwnsItem(client,shopItem[MBOOTS]))
					{
						//fMaxSpeed2
						War3_SetBuffItem(HealTarget,fMaxSpeed2,shopItem[MBOOTS],1.0,client);
						//DP("UNSET fMaxSpeed2 HealTarget");
					}
					if(War3_GetOwnsItem(client,shopItem[MRING]))
					{
						// Regen
						War3_SetBuffItem(HealTarget,fHPRegen,shopItem[MRING],0.0,client);
						//DP("UNSET fHPRegen HealTarget");
					}
					if(War3_GetOwnsItem(client,shopItem[MHEALTH]))
					{
						// Regen
						War3_SetBuffItem(HealTarget,iAdditionalMaxHealth,shopItem[MHEALTH],0,client);
						//DP("UNSET iAdditionalMaxHealth HealTarget");
					}
					continue;
				}
			}
			else
			{
				//DP("HealTarget IsInvalid");
				if(HealingTarget[client]>0)
				{
					// reset buffs
					//fMaxSpeed2
					War3_SetBuffItem(HealingTarget[client],fMaxSpeed2,shopItem[MBOOTS],1.0);
					// Regen
					War3_SetBuffItem(HealingTarget[client],fHPRegen,shopItem[MRING],0.0);
					// Additional Health
					War3_SetBuffItem(HealingTarget[client],iAdditionalMaxHealth,shopItem[MHEALTH],0);
				}
				HealingTarget[client]=-1;
			}
		}
	}

	return Plugin_Continue;
}
#endif

public Action:PointOneSecondLoop(Handle:timer,any:data)
{
	if(W3Paused()) return Plugin_Continue;

#if GGAMETYPE_JAILBREAK == JAILBREAK_OFF
	if(war3ready){
		doCloak();
	}
#endif
#if GGAMETYPE == GGAME_TF2
	for(int client=1; client <= MaxClients; client++)
	{
		if(ValidPlayer(client, true))
		{
			float  fExtinguishTime = g_fExtinguishNow[client];
			if (fExtinguishTime > 0.0 && fExtinguishTime <= GetGameTime())
			{
				ExtinguishEntity(client);
				TF2_RemoveCondition(client, TFCond_OnFire);

				g_fExtinguishNow[client] = 0.0;
				War3_ChatMessage(client, "You have been extinguished...");
			}
		}
	}
#endif
	return Plugin_Continue;
}
#if GGAMETYPE_JAILBREAK == JAILBREAK_OFF
public doCloak() //this loop should detec weapon chnage and add a new alpha
{
	for(int x=1;x<=MaxClients;x++)
	{
		if(ValidPlayer(x,true)&&War3_GetOwnsItem(x,shopItem[CLOAK]))
		{
			//knife? melle?
			if(War3_IsUsingMeleeWeapon(x))
			{
				War3_SetBuffItem(x,fInvisibilityItem,shopItem[CLOAK],0.4);
			}
			else
			{
				War3_SetBuffItem(x,fInvisibilityItem,shopItem[CLOAK],0.6); // was 0.5
			}
		}
	}
}
#endif
public OnW3Denyable(W3DENY:event,client)
{
	if((event == DN_CanBuyItem1) && (W3GetVar(EventArg1) == shopItem[SHIELD]) && (War3_GetOwnsItem(client, shopItem[NECKLACE]) && GetConVarBool(ShieldRestrictionCvar)))
	{
		W3Deny();
		War3_ChatMessage(client, "Cannot wear Necklace and Shield at the same time.");
	}
	if((event == DN_CanBuyItem1) && (W3GetVar(EventArg1) == shopItem[NECKLACE]) && (War3_GetOwnsItem(client, shopItem[SHIELD])) && GetConVarBool(ShieldRestrictionCvar))
	{
		W3Deny();
		War3_ChatMessage(client, "Cannot wear Necklace and Shield at the same time.");
	}
#if GGAMETYPE == GGAME_TF2
	if((event == DN_CanBuyItem1) && (W3GetVar(EventArg1) == shopItem[MBOOTS]) && TF2_GetPlayerClass(client) != TFClass_Medic)
	{
		W3Deny();
	}
	if((event == DN_CanBuyItem1) && (W3GetVar(EventArg1) == shopItem[MRING]) && TF2_GetPlayerClass(client) != TFClass_Medic)
	{
		W3Deny();
	}
	if((event == DN_CanBuyItem1) && (W3GetVar(EventArg1) == shopItem[MHEALTH]) && TF2_GetPlayerClass(client) != TFClass_Medic)
	{
		W3Deny();
	}
#endif
}



public OnItemPurchase(client,item)
{
	if(item==shopItem[PLATES])
	{
		War3_NotifyPlayerItemActivated(client,shopItem[PLATES],true);
	}
#if GGAMETYPE == GGAME_TF2
	else if(item==shopItem[MBOOTS])
	{
		War3_NotifyPlayerItemActivated(client,shopItem[MBOOTS],true);
		War3_SetBuffItem(client,fMaxSpeed2,shopItem[MBOOTS],1.2);
	}
	else if(item==shopItem[MRING])
	{
		War3_NotifyPlayerItemActivated(client,shopItem[MRING],true);
	}
	else if(item==shopItem[MHEALTH])
	{
		War3_NotifyPlayerItemActivated(client,shopItem[MHEALTH],true);
	}
#endif
	else if(item==shopItem[PLATES])
	{
		War3_NotifyPlayerItemActivated(client,shopItem[PLATES],true);
	}
	else if(item==shopItem[PLATES])
	{
		War3_NotifyPlayerItemActivated(client,shopItem[PLATES],true);
	}
	else if(item==shopItem[HELM])
	{
		War3_NotifyPlayerItemActivated(client,shopItem[HELM],true);
	}
#if GGAMETYPE_JAILBREAK == JAILBREAK_OFF
	else if(item==shopItem[CLOAK])
	{
		War3_NotifyPlayerItemActivated(client,shopItem[CLOAK],true);
	}
#endif
	else if(item==shopItem[CLAW])
	{
		War3_NotifyPlayerItemActivated(client,shopItem[CLAW],true);
	}
	else if(item==shopItem[MASK])
	{
		War3_NotifyPlayerItemActivated(client,shopItem[MASK],true);
	}
	else if(item==shopItem[FROST])
	{
		War3_NotifyPlayerItemActivated(client,shopItem[FROST],true);
	}
	else if(item==shopItem[OIL])
	{
		War3_NotifyPlayerItemActivated(client,shopItem[OIL],true);
	}
	else if(item==shopItem[SOCK])
	{
		if(IsPlayerAlive(client))
		{
			War3_NotifyPlayerItemActivated(client,shopItem[SOCK],true);
			War3_ChatMessage(client,"You pull on your socks");
		}
	}
	else if(item==shopItem[TOME]) // tome of xp
	{
		int race=War3_GetRace(client);
		int add_xp=GetConVarInt(TomeCvar);
		if(add_xp<0)	add_xp=0;

		bool SteamCheck=false;
#if GGAMETYPE == GGAME_TF2
		if(add_xp!=0&&War3_IsInSteamGroup(client))
		{
			add_xp=add_xp*2;
			SteamCheck=true;
		}
#endif
		if(add_xp!=0&&ValidPlayer(client))
		{
			new AdminId:AdminID = GetUserAdmin(client);
			if (AdminID!=INVALID_ADMIN_ID)
			{
				if(GetAdminFlag(GetUserAdmin(client), Admin_Reservation))
				{
					//VIP
					if(SteamCheck)
						add_xp=add_xp*2; // Double more!  Which makes 4x
					else
						add_xp=add_xp*4; // Double more!  Which makes 4x
				}
			}
		}

		War3_SetXP(client,race,War3_GetXP(client,race)+add_xp);
		W3DoLevelCheck(client);
		War3_SetOwnsItem(client,item,false);
		War3_ChatMessage(client,"%T","+{amount} XP",client,add_xp);
		War3_ShowXP(client);
	}
	else if(item==shopItem[FAITH]&&ValidPlayer(client))
	{
		float MultiArmor=W3GetMagicArmorMulti(client);
		if(MultiArmor<3.0)
		{
			MultiArmor=3.0-W3GetMagicArmorMulti(client);
			War3_SetBuffItem(client,fArmorMagic,shopItem[FAITH],MultiArmor); //mvm
		}
		War3_NotifyPlayerItemActivated(client,shopItem[FAITH],true);
	}
	else if(item==shopItem[COURAGE]&&ValidPlayer(client))
	{
		float MultiArmor=W3GetPhysicalArmorMulti(client);
		if(MultiArmor<3.0)
		{
			MultiArmor=3.0-W3GetPhysicalArmorMulti(client);
			War3_SetBuffItem(client,fArmorPhysical,shopItem[COURAGE],MultiArmor); //mvm
		}
		War3_NotifyPlayerItemActivated(client,shopItem[COURAGE],true);
	}
#if GGAMETYPE == GGAME_TF2
	else if(item==shopItem[UBER50]&&ValidPlayer(client))
	{
		if(TF2_GetPlayerClass(client)==TFClass_Medic)
		{
			if(GetEntProp(client, Prop_Send, "m_iClass") == 5)
			{
				float NewUber = TF_GetUberLevel(client) + 50.0;
				if(NewUber>100.0)
					NewUber=100.0;
				TF_SetUberLevel(client, NewUber);
				War3_SetOwnsItem(client,shopItem[UBER50],false);
			}
		}
	}
#endif
}

//deactivate BUFFS AND PASSIVES
public OnItemLost(client,item){ //deactivate passives , client may have disconnected
#if GGAMETYPE_JAILBREAK == JAILBREAK_OFF
	if(item==shopItem[CLOAK])
	{
		War3_SetBuffItem(client,fInvisibilityItem,shopItem[CLOAK],1.0);
		War3_NotifyPlayerItemActivated(client,shopItem[CLOAK],false);
	}
	else if(item==shopItem[FAITH])
#else
	if(item==shopItem[FAITH])
#endif
	{
		War3_SetBuffItem(client,fArmorMagic,shopItem[FAITH],0.0);
		War3_NotifyPlayerItemActivated(client,shopItem[FAITH],false);
	}
	else if(item==shopItem[COURAGE])
	{
		War3_SetBuffItem(client,fArmorPhysical,shopItem[COURAGE],0.0);
		War3_NotifyPlayerItemActivated(client,shopItem[COURAGE],false);
	}
#if GGAMETYPE == GGAME_TF2
	else if(item==shopItem[FIREORB])
	{
		War3_NotifyPlayerItemActivated(client,shopItem[FIREORB],false);
	}
	else if(item==shopItem[MBOOTS])
	{
		War3_NotifyPlayerItemActivated(client,shopItem[MBOOTS],false);
		War3_SetBuffItem(client,fMaxSpeed2,shopItem[MBOOTS],1.0);
		if(HealingTarget[client]>0)
		{
			War3_SetBuffItem(HealingTarget[client],fMaxSpeed2,shopItem[MBOOTS],1.0);
		}
	}
	else if(item==shopItem[MRING])
	{
		War3_NotifyPlayerItemActivated(client,shopItem[MRING],false);
		if(HealingTarget[client]>0)
		{
			War3_SetBuffItem(HealingTarget[client],fHPRegen,shopItem[MRING],0.0);
		}
	}
	else if(item==shopItem[MHEALTH])
	{
		War3_NotifyPlayerItemActivated(client,shopItem[MHEALTH],false);
		if(HealingTarget[client]>0)
		{
			War3_SetBuffItem(HealingTarget[client],iAdditionalMaxHealth,shopItem[MHEALTH],0);
		}
	}
#endif
	else if(item==shopItem[CLAW])
	{
		War3_NotifyPlayerItemActivated(client,shopItem[CLAW],false);
	}
	else if(item==shopItem[FROST])
	{
		War3_NotifyPlayerItemActivated(client,shopItem[FROST],false);
	}
	else if(item==shopItem[FAITH])
	{
		War3_NotifyPlayerItemActivated(client,shopItem[FAITH],false);
	}
	else if(item==shopItem[COURAGE])
	{
		War3_NotifyPlayerItemActivated(client,shopItem[COURAGE],false);
	}
	else if(item==shopItem[PLATES])
	{
		War3_NotifyPlayerItemActivated(client,shopItem[PLATES],false);
	}
	else if(item==shopItem[HELM])
	{
		War3_NotifyPlayerItemActivated(client,shopItem[HELM],false);
	}
	else if(item==shopItem[ARMOR_PIERCING])
	{
		War3_NotifyPlayerItemActivated(client,shopItem[ARMOR_PIERCING],false);
	}

	else if(item==shopItem[MASK])
	{
		War3_NotifyPlayerItemActivated(client,shopItem[MASK],false);
	}
}
///change ownership only, DO NOT RESET BUFFS here, do that in OnItemLost
public OnWar3EventDeath(victim, attacker, deathrace, distance, attacker_hpleft)
{
	if (ValidPlayer(victim))
	{
		bDidDie[victim]=true;
#if GGAMETYPE == GGAME_TF2
		g_fExtinguishNow[victim] = 0.0; //fireorb

		if(War3_GetOwnsItem(victim, shopItem[FIREORB]))
		{
			War3_SetOwnsItem(victim, shopItem[FIREORB], false);
		}
		if(War3_GetOwnsItem(victim,shopItem[MBOOTS])) // MBOOTS
		{
			War3_SetOwnsItem(victim,shopItem[MBOOTS],false);
		}
		if(War3_GetOwnsItem(victim,shopItem[MRING])) // MRING
		{
			War3_SetOwnsItem(victim,shopItem[MRING],false);
		}
		if(War3_GetOwnsItem(victim,shopItem[MHEALTH])) // MBOOTS
		{
			War3_SetOwnsItem(victim,shopItem[MHEALTH],false);
		}
#endif
		if(War3_GetOwnsItem(victim,shopItem[CLAW])) // claws
		{
			War3_SetOwnsItem(victim,shopItem[CLAW],false);
		}
#if GGAMETYPE_JAILBREAK == JAILBREAK_OFF
		if(War3_GetOwnsItem(victim,shopItem[CLOAK]))
		{
			War3_SetOwnsItem(victim,shopItem[CLOAK],false); // cloak
		}
#endif
		if(War3_GetOwnsItem(victim,shopItem[FROST])) // orb of frost
		{
			War3_SetOwnsItem(victim,shopItem[FROST],false);
		}
		if(War3_GetOwnsItem(victim,shopItem[OIL]))
		{
			War3_SetOwnsItem(victim,shopItem[OIL],false);
		}
		if(War3_GetOwnsItem(victim,shopItem[PLATES]))
		{
			War3_SetOwnsItem(victim,shopItem[PLATES],false);
		}
		if(War3_GetOwnsItem(victim,shopItem[HELM]))
		{
			War3_SetOwnsItem(victim,shopItem[HELM],false);
		}
		if(War3_GetOwnsItem(victim,shopItem[FAITH]))
		{
			War3_SetOwnsItem(victim,shopItem[FAITH],false);
		}
		if(War3_GetOwnsItem(victim,shopItem[COURAGE]))
		{
			War3_SetOwnsItem(victim,shopItem[COURAGE],false);
		}
		if(War3_GetOwnsItem(victim,shopItem[ARMOR_PIERCING]))
		{
			War3_SetOwnsItem(victim,shopItem[ARMOR_PIERCING],false);
		}
		if(War3_GetOwnsItem(victim,shopItem[ANTIWARD]))
		{
			War3_SetOwnsItem(victim,shopItem[ANTIWARD],false);
		}
		if(War3_GetOwnsItem(victim,shopItem[SOCK]))
		{
			War3_SetOwnsItem(victim,shopItem[SOCK],false);
		}
		if(War3_GetOwnsItem(victim,shopItem[NECKLACE]))
		{
			War3_SetOwnsItem(victim,shopItem[NECKLACE],false);
		}
		if(War3_GetOwnsItem(victim,shopItem[RING]))
		{
			War3_SetOwnsItem(victim,shopItem[RING],false);
		}
		if(War3_GetOwnsItem(victim,shopItem[BOOTS]))
		{
			War3_SetOwnsItem(victim,shopItem[BOOTS],false);
		}
		if(War3_GetOwnsItem(victim,shopItem[MASK]))
		{
			War3_SetOwnsItem(victim,shopItem[MASK],false);
		}
		if(War3_GetOwnsItem(victim,shopItem[SHIELD]))
		{
			War3_SetOwnsItem(victim,shopItem[SHIELD],false);
		}
		if(War3_GetOwnsItem(victim,shopItem[GAUNTLET]))
		{
			War3_SetOwnsItem(victim,shopItem[GAUNTLET],false);
		}
		if(War3_GetOwnsItem(victim,shopItem[ARMBAND]))
		{
			War3_SetOwnsItem(victim,shopItem[ARMBAND],false);
		}
#if GGAMETYPE == GGAME_TF2
		if(War3_GetOwnsItem(victim,shopItem[ANTIHACKITEM]))
		{
			War3_SetOwnsItem(victim,shopItem[ANTIHACKITEM],false);
		}
#endif

#if GGAMETYPE2 == GGAME_PVM
		if(War3_GetOwnsItem(victim, shopItem[LEATHER]))
		{
			War3_SetOwnsItem(victim, shopItem[LEATHER], false);
		}
		if(War3_GetOwnsItem(victim,shopItem[CHAINMAIL]))
		{
			War3_SetOwnsItem(victim,shopItem[CHAINMAIL],false);
		}
		if(War3_GetOwnsItem(victim,shopItem[BANDEDMAIL]))
		{
			War3_SetOwnsItem(victim,shopItem[BANDEDMAIL],false);
		}
		if(War3_GetOwnsItem(victim,shopItem[HALFPLATE]))
		{
			War3_SetOwnsItem(victim,shopItem[HALFPLATE],false);
		}
		if(War3_GetOwnsItem(victim,shopItem[FULLPLATE]))
		{
			War3_SetOwnsItem(victim,shopItem[FULLPLATE],false);
		}
#endif
	}
}

public void OnWar3EventSpawn (int client)
{
	if( bFrosted[client])
	{
		bFrosted[client]=false;
		War3_SetBuffItem(client,fSlow,shopItem[FROST],1.0);
	}
	//if(War3_GetOwnsItem(client,shopItem[SOCK]))
	//{
		//War3_ChatMessage(client,"You pull on your socks");
	//}
	bDidDie[client]=false;

}

// use? OnW3TakeDmgAll
/*
Trying to resolve:  I think we should try OnW3TakeDmgAll because it allows damage.
[SM] Displaying call stack trace for plugin "war3source/War3Source_Engine_DamageSystem.smx":
L 12/08/2012 - 02:58:58: [SM]   [0]  Line 455, War3Source_Engine_DamageSystem.sp::Native_War3_DealDamage()
L 12/08/2012 - 02:58:58: [SM] Plugin encountered error 25: Call was aborted
L 12/08/2012 - 02:58:58: [SM] Native "War3_DealDamage" reported: Error encountered while processing a dynamic native
L 12/08/2012 - 02:58:58: [SM] Displaying call stack trace for plugin "war3source/War3Source_013_SuccubusHunter.smx":
L 12/08/2012 - 02:58:58: [SM]   [0]  Line 213, War3Source_013_SuccubusHunter.sp::OnWar3EventPostHurt()
L 12/08/2012 - 03:06:15: Error log file session closed.

same error above except with shopmenu items
*/
//public OnWar3EventPostHurt(victim,attacker,damage){

public Action OnW3TakeDmgAll(int victim,int attacker, float damage)
{
#if GGAMETYPE == GGAME_TF2
	if(!W3IsOwnerSentry(attacker))
	{
#endif
		if(W3GetDamageIsBullet()&&ValidPlayer(victim)&&ValidPlayer(attacker,true)&&GetClientTeam(victim)!=GetClientTeam(attacker))
		{
			//DP("bullet 1 claw %d vic alive%d",War3_GetOwnsItem(attacker,shopItem[CLAW]),ValidPlayer(victim,true,true));
			//int vteam=GetClientTeam(victim);
			//int ateam=GetClientTeam(attacker);

			if(!Perplexed(attacker))
			{
				if(War3_GetOwnsItem(attacker,shopItem[CLAW])&&ValidPlayer(victim,true,true)&&W3Chance(W3ChanceModifier(attacker))) // claws of attack
				{
					float dmg=FloatMul(damage,GetConVarFloat(ClawsAttackCvar));
					if(dmg<0.0) 	dmg=0.0;

					//SetEntityHealth(victim,new_hp);
					//DP("%f",W3ChanceModifier(attacker));
					if(W3Chance(W3ChanceModifier(attacker))){
					dmg*=W3ChanceModifier(attacker);
					}
					else{
						dmg*=0.50;
					}
					//	DP("%f",dmg);
					if(War3_DealDamage(victim,RoundFloat(dmg),attacker,_,"claws",W3DMGORIGIN_ITEM,W3DMGTYPE_PHYSICAL,_,_,true)){ //real damage with indicator

						//PrintToConsole(attacker,"%T","+{amount} Claws Damage",attacker,War3_GetWar3DamageDealt());
						War3_NotifyPlayerTookDamageFromItem(victim, attacker, War3_GetWar3DamageDealt(), shopItem[CLAW]);
					}
				}

				if( War3_GetOwnsItem(attacker,shopItem[FROST]) && !bFrosted[victim])
				{
					/*new chance;
					switch (TF2_GetPlayerClass(attacker))
					{
						case TFClass_Scout:
						{
							chance = 55;
						}
						case TFClass_Sniper:
						{
							chance = 90;
						}
						case TFClass_Soldier:
						{
							chance = 45;
						}
						case TFClass_DemoMan:
						{
							chance = 80;
						}
						case TFClass_Medic:
						{
							chance = 30;
						}
						case TFClass_Heavy:
						{
							chance = 5;
						}
						case TFClass_Pyro:
						{
							chance = 5;
						}
						case TFClass_Spy:
						{
							chance = 65;
						}
						case TFClass_Engineer:
						{
							chance = 5;
						}
						default:
						{
							chance = 10;
						}
					}
					if(GetRandomInt(1, 100) <= chance) */
					if(W3Chance(W3ChanceModifier(attacker)) && GetRandomFloat(0.0,1.0)<=0.25)
					{
						float speed_frost=GetConVarFloat(OrbFrostCvar);
						if(speed_frost<=0.0) speed_frost=0.01; // 0.0 for override removes
						if(speed_frost>1.0)	speed_frost=1.0;
						War3_SetBuffItem(victim,fSlow,shopItem[FROST],speed_frost);
						bFrosted[victim]=true;

						//PrintToConsole(attacker,"%T","ORB OF FROST!",attacker);
						//PrintToConsole(victim,"%T","Frosted, reducing your speed",victim);
						PrintHintText(victim,"Frosted, reducing your speed!");
						//War3_NotifyPlayerItemActivated(attacker,shopItem[FROST],true);
						// Need to create a datapack here to transfer both victim and attacker info..
						CreateTimer(1.0,Unfrost,victim);
					}
				}


				if(War3_GetOwnsItem(attacker,shopItem[MASK]) && damage>0.0 && W3Chance(W3ChanceModifier(attacker))) // Mask of death  && W3Chance(W3ChanceModifier(attacker))
				{
					float hp_percent=GetConVarFloat(MaskDeathCvar);
					if(hp_percent<0.0)	hp_percent=0.0;
					if(hp_percent>1.0)	hp_percent=1.0;  //1 = 100%
					//int add_hp=RoundFloat(FloatMul(float(damage),hp_percent));
					int add_hp=RoundFloat(FloatMul(damage,hp_percent));
					if(add_hp>40)	add_hp=40; // awp or any other weapon, just limit it
					War3_HealToBuffHP(attacker,add_hp);
					if(War3_TrackDelayExpired(maskSoundDelay[attacker])){
						War3_EmitSoundToAll(masksnd,attacker);
						War3_TrackDelay(maskSoundDelay[attacker],0.25);
					}
					if(War3_TrackDelayExpired(maskSoundDelay[victim])){
						War3_EmitSoundToAll(masksnd,victim);
						War3_TrackDelay(maskSoundDelay[victim],0.25);
					}
					//PrintToConsole(attacker,"%T","+{amount} Mask leeched HP",attacker,add_hp);
					//War3_NotifyPlayerTookDamageFromItem(victim, attacker, War3_GetWar3DamageDealt(), shopItem[MASK]);
					War3_NotifyPlayerLeechedFromItem(victim,attacker,add_hp,shopItem[MASK]);
				}
			}
		}
#if GGAMETYPE == GGAME_TF2
	}
#endif
}

public Action:Unfrost(Handle:timer,any:client)
{
	bFrosted[client]=false;
	War3_SetBuffItem(client,fSlow,shopItem[FROST],1.0);
	if(ValidPlayer(client))
	{

		PrintToConsole(client,"%T","REGAINED SPEED from frost",client);
	}
}

public void OnWar3Event(W3EVENT event,int client)
{
	if(event==ClearPlayerVariables){
		bDidDie[client]=false;
	}
	if(event == CanBuyItem)
	{
#if GGAMETYPE == GGAME_TF2
		new item = W3GetVar(EventArg1);
		//W3SetVar(EventArg2, 1);
		if(item==shopItem[UBER50] && TF2_GetPlayerClass(client)!=TFClass_Medic)
		{
			W3SetVar(EventArg2, 0);
			War3_ChatMessage(client, "Only Medics can buy this item!");
		}
		if(item==shopItem[ANTIHACKITEM] && TF2_GetPlayerClass(client)!=TFClass_Engineer)
		{
			W3SetVar(EventArg2, 0);
			War3_ChatMessage(client, "Only Engineers can buy this item!");
		}
#endif
	}
}

public OnClientPutInServer(client)
{
	SDKHook(client,SDKHook_TraceAttack,SDK_Forwarded_TraceAttack);
}

public OnClientDisconnect(client)
{
	SDKUnhook(client,SDKHook_TraceAttack,SDK_Forwarded_TraceAttack);
}

// plates  & helm
public Action:SDK_Forwarded_TraceAttack(victim, &attacker, &inflictor, &Float:damage, &damagetype, &ammotype, hitbox, hitgroup)
{
	new Oil_item = War3_GetItemIdByShortname("oil");
	new Owns_item = War3_GetOwnsItem(attacker,Oil_item);

	if((Owns_item!=1)&&((hitgroup==2&&(hitbox==5||hitbox==4))||(hitgroup==3&&hitbox==3))&&War3_GetOwnsItem(victim,shopItem[PLATES])&&!Perplexed(victim)){
		damage=0.0;
		new random = GetRandomInt(0,3);
		if(random==0){
			War3_EmitSoundToAll(helmSound0,victim);
		}else if(random==1){
			War3_EmitSoundToAll(helmSound1,victim);
		}else if(random==2){
			War3_EmitSoundToAll(helmSound2,victim);
		}else{
			War3_EmitSoundToAll(helmSound3,victim);
		}
		W3FlashScreen(victim,RGBA_COLOR_WHITE);
#if GGAMETYPE == GGAME_TF2
		decl Float:pos[3];
		GetClientEyePosition(victim, pos);
		pos[2] += 4.0;
		War3_TF_ParticleToClient(0, "miss_text", pos); //to the attacker at the enemy pos
#endif
		W3Hint(attacker,HINT_LOWEST,5.0,"The enemy you hit has \"plates\" from \"sh1\". Type \"oil\" to counter!");
	}
	// helms
	if((Owns_item!=1)&&hitgroup==1&&War3_GetOwnsItem(victim,shopItem[HELM])&&!Perplexed(victim)){
		damage=0.0;
		new random = GetRandomInt(0,3);
		if(random==0){
			War3_EmitSoundToAll(helmSound0,victim);
		}else if(random==1){
			War3_EmitSoundToAll(helmSound1,victim);
		}else if(random==2){
			War3_EmitSoundToAll(helmSound2,victim);
		}else{
			War3_EmitSoundToAll(helmSound3,victim);
		}
		W3FlashScreen(victim,RGBA_COLOR_BLACK);
#if GGAMETYPE == GGAME_TF2
		decl Float:pos[3];
		GetClientEyePosition(victim, pos);
		pos[2] += 4.0;
		War3_TF_ParticleToClient(0, "miss_text", pos); //to the attacker at the enemy pos
#endif
		W3Hint(attacker,HINT_LOWEST,5.0,"The enemy you hit has \"helm\" from \"sh1\". Type \"oil\" to counter!");
	}
	return Plugin_Changed;
}

stock GetMoney(player)
{
	return GetEntData(player,MoneyOffsetCS);
}

stock SetMoney(player,money)
{
	SetEntData(player,MoneyOffsetCS,money);
}

#if GGAMETYPE == GGAME_TF2
public Action OnW3TakeDmgBullet(int victim, int attacker, float damage)
{
#if GGAMETYPE == GGAME_TF2
	if (!W3IsOwnerSentry(attacker))
	{
#endif
		if(ValidPlayer(victim, true) && ValidPlayer(attacker) && victim != attacker)
		{
			if (GetClientTeam(victim) != GetClientTeam(attacker))
			{
				if(W3Chance(W3ChanceModifier(attacker)))
				{
					if(War3_GetOwnsItem(attacker, shopItem[FIREORB]) && !(TF2_IsPlayerInCondition(victim, TFCond_OnFire)) && !Perplexed(attacker))
					{
						char GetWeapon[64];
						if(ValidPlayer(attacker,true,true))
						{
							GetClientWeapon( attacker, GetWeapon , 64);
						}
						else
						{
							GetWeapon = "";
						}
						bool WeaponIsCritial=false;
						int activeweapon = FindSendPropOffs("CTFPlayer", "m_hActiveWeapon");
						int weapon = GetEntDataEnt2(attacker, activeweapon);
						if(IsValidEntity(weapon))
						{
							int weaponindex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
							switch(weaponindex)
							{
							//594  makes The Phlogistinator Over powered
								case 163,349,457,38,594:
								{
									WeaponIsCritial=true;
								}
							}
						}
						if(!WeaponIsCritial && GetRandomFloat(0.0,1.0)<=getClassChance(attacker))
						{
							// removed because broken - need sourcemod update
							TF2_IgnitePlayer(victim, attacker);
							g_fExtinguishNow[victim] = GetGameTime() + fSecondsTillExtinguish;
							// Make a War3_NotifyPlayerItemHit(attacker,victim);
							War3_NotifyPlayerItemActivated(attacker,shopItem[FIREORB],true);
						}
					}
				}
			}
		}
#if GGAMETYPE == GGAME_TF2
	}
#endif
}
float getClassChance(attacker) {
	float chance;
	switch (TF2_GetPlayerClass(attacker))
	{
		case TFClass_Scout:
		{
			chance = 0.25;
		}
		case TFClass_Sniper:
		{
			chance = 0.25;
		}
		case TFClass_Soldier:
		{
			chance = 0.50;
		}
		case TFClass_DemoMan:
		{
			chance = 0.50;
		}
		case TFClass_Medic:
		{
			chance = 0.15;
		}
		case TFClass_Heavy:
		{
			chance = 0.15;
		}
		case TFClass_Pyro:
		{
			chance = 0.15;
		}
		case TFClass_Spy:
		{
			chance = 0.25;
		}
		case TFClass_Engineer:
		{
			chance = 0.25;
		}
		default:
		{
			chance = 0.25;
		}
	}
	return chance;
}
#endif
