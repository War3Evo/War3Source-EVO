#include "War3Source/include/War3Source_Auction_House"
#include <war3source>
#assert GGAMEMODE == MODE_WAR3SOURCE


#define PLUGIN_VERSION "0.0.1.0 (12/15/2013)"

enum AuctionType
{
	gold,
	diamonds,
	platinum,
}

new bool:AuctionHouse[MAXPLAYERSCUSTOM][3];
new String:AuctionHouseSteamID[32][MAXPLAYERSCUSTOM][3]; // for security reasons  (may use steamid later)
new AuctionType:AHType1[MAXPLAYERSCUSTOM][3];
new AuctionType:AHType2[MAXPLAYERSCUSTOM][3];
new AHAmount1[MAXPLAYERSCUSTOM][3];
new AHAmount2[MAXPLAYERSCUSTOM][3];

new bool:Autobuy[MAXPLAYERSCUSTOM];

public Plugin:myinfo=
{
	name="War3Source:EVO Engine Auction House",
	author="El Diablo",
	description="War3Source:EVO Core Plugins",
	version="1.0",
	url="http://war3evo.info/"
};

new Handle:hEnableAuctionHouse;

public OnPluginStart()
{
	CreateConVar("AuctionHouse",PLUGIN_VERSION,"War3Source:EVO Auction system",FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	hEnableAuctionHouse = CreateConVar("war3_auctionhouse_enable", "0", "Enable/Disable(1/0) AuctionHouse");
	AddCommandListener(War3Evo_SayCommand, "say");
	AddCommandListener(War3Evo_SayCommand, "say_team");
}

public Action:AuctionAds(Handle:timer,any:userid)
{
	War3_ChatMessage(0,"To create a auction type in the following in chat:");
	War3_ChatMessage(0,"!ah <amount> gold for <amount> diamonds");
	War3_ChatMessage(0,"!ah <amount> diamonds for <amount> gold");
}

//=============================================================================
// AskPluginLoad2
//=============================================================================
public APLRes:AskPluginLoad2(Handle:plugin,bool:late,String:error[],err_max)
{
	MarkNativeAsOptional("War3_ReservedGold");

	CreateNative("War3_ReservedGold",NW3GetReservedGold);

	RegPluginLibrary("W3AuctionHouse");
}

public OnWar3PlayerAuthed(client)
{
	if(ValidPlayer(client))
	{
		AuctionHouse[client][0]=false;
		strcopy(AuctionHouseSteamID[client][0],31,"");    // for security reasons  (may use steamid later)
		AHAmount1[client][0]=0;
		AHAmount2[client][0]=0;
		Autobuy[client]=false;
	}
}


public OnClientDisconnect(client)
{
	AuctionHouse[client][0]=false;
	AHAmount1[client][0]=0;
	AHAmount2[client][0]=0;
	Autobuy[client]=false;
}

public NW3GetReservedGold(Handle:plugin,args){
	new client=GetNativeCell(1);
	new aucaddgold;

	for(new i;i<=2;i++)
	{
		// check if they have an auction
		if(AuctionHouse[client][i]==true)
		{
			// check steam id
			new String:steamid2[32];
			GetClientAuthId(client,AuthId_Steam2,STRING(steamid2),true);

			if (StrEqual(AuctionHouseSteamID[client][0],steamid2))
			{
				// add reserved gold
				if (AHType1[client][i]==gold)
					aucaddgold=aucaddgold+AHAmount1[client][i];
			}
			else
			{
				PrintToServer("Invalid steamid %s for reserved gold checking.",steamid2);
				strcopy(AuctionHouseSteamID[client][0],31,"");
				AuctionHouse[client][i]=false;
			}
		}
	}

	return aucaddgold;
}


public War3_Auction(client,String:AHBuffer[256],bool:menu)
{
	if (menu)
	{
		ShowAuctionMenuShop(client);
		return true;
	}

	new String:strBuffer[7][20];
	ExplodeString(AHBuffer," ",strBuffer,6,20,false);

	if (StrEqual(strBuffer[2],"gold",false)&&(StrEqual(strBuffer[5],"diamonds",false)||StrEqual(strBuffer[5],"diamond",false)))
	{
		// auction gold for diamonds
		new aucgold = StringToInt(strBuffer[1]);
		new aucdiamonds = StringToInt(strBuffer[4]);
		if (aucgold>0 && aucdiamonds>0)
		{
			new GoldonHand = War3_GetGold(client);
			new DiamondsonHand = War3_GetDiamonds(client);
			if (aucgold<=GoldonHand)
				{
					AuctionHouse[client][0]=true;

					new String:steamid[32];
					GetClientAuthId(client,AuthId_Steam2,STRING(steamid),true);

					strcopy(AuctionHouseSteamID[client][0],31,steamid);

					new String:clientname[32];
					GetClientName(client, clientname, 32);

					AHType1[client][0]=gold;
					AHType2[client][0]=diamonds;
					AHAmount1[client][0]=aucgold;
					AHAmount2[client][0]=aucdiamonds;
					PrintCenterTextAll("%s put up a auction. say in chat: !ah",clientname);
					War3_ChatMessage(0,"%s is selling %i Gold for %i Diamonds.",clientname,aucgold,aucdiamonds);
					War3_ChatMessage(client,"You have %i Gold and %i Diamonds and [%i] Reserved Gold.",GoldonHand,DiamondsonHand,War3_ReservedGold(client));
					War3_ChatMessage(client,"For Auction Menu, type !ah");
					War3_ChatMessage(client,"You auction is now listed and will be removed when you disconnect.");
					return true;
				}
				else
				{
					War3_ChatMessage(client,"You only have %i gold.",GoldonHand);
				}


		}
		else
		{
			War3_ChatMessage(client,"Both Gold and Diamonds needs to be greater than 0.");
		}
	}

	if (StrEqual(strBuffer[5],"gold",false)&&StrEqual(strBuffer[2],"diamonds",false))
	{
		// auction gold for diamonds
		new aucgold = StringToInt(strBuffer[4]);
		new aucdiamonds = StringToInt(strBuffer[1]);
		if (aucgold>0 && aucdiamonds>0)
		{
			new GoldonHand = War3_GetGold(client);
			new DiamondsonHand = War3_GetDiamonds(client);
			if (aucdiamonds<=DiamondsonHand)
				{
					AuctionHouse[client][0]=true;

					new String:steamid[32];
					GetClientAuthId(client,AuthId_Steam2,STRING(steamid),true);

					strcopy(AuctionHouseSteamID[client][0],31,steamid);

					new String:clientname[32];
					GetClientName(client, clientname, 32);

					AHType1[client][0]=diamonds;
					AHType2[client][0]=gold;
					AHAmount2[client][0]=aucgold;
					AHAmount1[client][0]=aucdiamonds;
					PrintCenterText(client,"%s put up a auction. say in chat: !ah",clientname);
					War3_ChatMessage(0,"%s is selling %i Diamonds for %i Gold.",clientname,aucdiamonds,aucgold);
					War3_ChatMessage(client,"You have %i Gold and %i Diamonds and [%i] Reserved Gold.",GoldonHand,DiamondsonHand,War3_ReservedGold(client));
					War3_ChatMessage(client,"For Auction Menu, type !ah");
					War3_ChatMessage(client,"You auction is now listed and will be removed when you disconnect.");
					return true;
				}
				else
				{
					War3_ChatMessage(client,"You only have %i Diamond(s).",DiamondsonHand);
				}


		}
		else
		{
			War3_ChatMessage(client,"Both Gold and Diamonds needs to be greater than 0.");
		}

		//return true;  add return true when it works correctly.
	}


	return false;
}
















ShowAuctionMenuShop(client) {
	//PrintToServer("ShowAuctionMenuShop - Debug");
	SetTrans(client);
	new Handle:AuctionshopMenu=CreateMenu(ShopMenu_Selected);
	SetMenuExitButton(AuctionshopMenu,true);

	new aucgold=War3_GetGold(client);
	new ReservedGold = War3_ReservedGold(client);
	aucgold = aucgold - ReservedGold;
	if (aucgold<0)
		aucgold = 0;


	new String:title[300];
	Format(title,sizeof(title),"[War3Source:EVO] Select an item to buy from the Auction House.");
	Format(title,sizeof(title),"%s\n \n You have %i Gold and [%i] Reserved Gold.",title, aucgold, ReservedGold);

	SetMenuTitle(AuctionshopMenu,title);
	decl String:itembuf[6];
	decl String:linestr[96];

	new bool:AuctionsExist=false;

	for(new y=0;y<=2;y++)
	{
		for(new x=1;x<=MaxClients;x++)
		{
			if(AuctionHouse[x][y]==true) // if client has auction then...
			{
				// here just in case i want to check something later
				new bool:JustHereJustInCase = true;
				new String:sellername[32];
				GetClientName(x, sellername, 32);
				if (JustHereJustInCase==true)
				{
					// item number look up
					Format(itembuf,sizeof(itembuf),"%i,%i",x,y);

					if(AHType1[x][y]==gold)
					{
						if(AHType2[x][y]==diamonds)
						{
							Format(linestr,sizeof(linestr),"%i Gold for %i Diamond(s) - %s",AHAmount1[x][y],AHAmount2[x][y],sellername);
							AuctionsExist=true;
							//PrintToServer("ShowAuctionMenuShop - linestr - Debug");
						}
						if(AHType2[x][y]==platinum)
						{
						}
					}

					if(AHType1[x][y]==diamonds)
					{
						if(AHType2[x][y]==gold)
						{
							Format(linestr,sizeof(linestr),"%i Diamond(s) for %i Gold - %s",AHAmount1[x][y],AHAmount2[x][y],sellername);
							AuctionsExist=true;
						}
						if(AHType2[x][y]==platinum)
						{
						}
					}

					if(AHType1[x][y]==platinum)
					{
						if(AHType2[x][y]==gold)
						{
						}
						if(AHType2[x][y]==diamonds)
						{
						}
					}

				}
				AddMenuItem(AuctionshopMenu,itembuf,linestr,ITEMDRAW_DEFAULT);
			}
		}
	}
	if(AuctionsExist)
		DisplayMenu(AuctionshopMenu,client,20);
	else
		War3_ChatMessage(client,"No Auctions Exists.");

	War3_ChatMessage(client,"To create a auction type in the following in chat:");
	War3_ChatMessage(client,"!ah <amount> gold for <amount> diamonds");
	War3_ChatMessage(client,"!ah <amount> diamonds for <amount> gold");
}

public ShopMenu_Selected(Handle:menu,MenuAction:action,client,selection)
{
	//PrintToServer("ShopMenu_Selected - Debug");
	if(action==MenuAction_Select)
	{
		if(ValidPlayer(client))
		{
			decl String:SelectionInfo[4];
			decl String:SelectionDispText[256];
			new SelectionStyle;
			GetMenuItem(menu,selection,SelectionInfo,sizeof(SelectionInfo),SelectionStyle, SelectionDispText,sizeof(SelectionDispText));

			new String:strBuffer[6][2];
			ExplodeString(SelectionInfo,",",strBuffer,2,4,false);

			new seller = StringToInt(strBuffer[0]); // seller
			new itemnumber = StringToInt(strBuffer[1]); // item #

			new BuyerGold = War3_GetGold(client);
			new BuyerDiamonds = War3_GetDiamonds(client);
			new SellerGold = War3_GetGold(seller);
			new SellerDiamonds = War3_GetDiamonds(seller);

			new String:Buyername[32];
			GetClientName(client, Buyername, 32);
			new String:Sellername[32];
			GetClientName(seller, Sellername, 32);

			new bool:TransactionIsGood=false;

			// check money / buy here
			if(seller!=client&&ValidPlayer(client)&&ValidPlayer(seller))
			{
				if(AHType1[seller][itemnumber]==gold)
				{
					if(AHType2[seller][itemnumber]==diamonds)
					{
						if(ValidPlayer(client)&&ValidPlayer(seller))
						{
							new String:steamid[32];
							GetClientAuthId(client,AuthId_Steam2,STRING(steamid),true);

							if (StrEqual(AuctionHouseSteamID[seller][itemnumber],steamid))
							{
								// check gold
								if((SellerGold>=AHAmount1[seller][itemnumber])&&(BuyerDiamonds>=AHAmount2[seller][itemnumber]))
								{
									BuyerGold = BuyerGold + AHAmount1[seller][itemnumber];
									SellerGold = SellerGold - AHAmount1[seller][itemnumber];
									BuyerDiamonds = BuyerDiamonds - AHAmount2[seller][itemnumber];
									SellerDiamonds = SellerDiamonds + AHAmount2[seller][itemnumber];
									War3_ChatMessage(0,"AUCTION HOUSE: %s bought %i Gold for %i Diamonds from %s",Buyername,AHAmount1[seller][itemnumber],AHAmount2[seller][itemnumber],Sellername);
									TransactionIsGood=true;
								}
							}
						}
					}
					if(AHType2[seller][itemnumber]==platinum)
					{
					}
				}

				if(AHType1[seller][itemnumber]==diamonds)
				{
					if(AHType2[seller][itemnumber]==gold)
					{
						if(ValidPlayer(client)&&ValidPlayer(seller))
						{
							new String:steamid[32];
							GetClientAuthId(client,AuthId_Steam2,STRING(steamid),true);

							if (StrEqual(AuctionHouseSteamID[seller][itemnumber],steamid))
							{
								// check gold
								if((SellerDiamonds>=AHAmount1[seller][itemnumber])&&(BuyerGold>=AHAmount2[seller][itemnumber]))
								{
									BuyerGold = BuyerGold - AHAmount2[seller][itemnumber];
									SellerGold = SellerGold + AHAmount2[seller][itemnumber];
									BuyerDiamonds = BuyerDiamonds + AHAmount1[seller][itemnumber];
									SellerDiamonds = SellerDiamonds - AHAmount1[seller][itemnumber];
									War3_ChatMessage(0,"AUCTION HOUSE: %s bought %i Diamonds for %i Gold from %s",Buyername,AHAmount1[seller][itemnumber],AHAmount2[seller][itemnumber],Sellername);
									TransactionIsGood=true;
								}
							}
						}
					}
					if(AHType2[seller][itemnumber]==platinum)
					{
					}
				}

				if(AHType1[seller][itemnumber]==platinum)
				{
					if(AHType2[seller][itemnumber]==gold)
					{
					}
					if(AHType2[seller][itemnumber]==diamonds)
					{
					}
				}
				if(TransactionIsGood==true)
				{
					new MaxClientGold=W3GetMaxGold(client);
					new MaxSellerGold=W3GetMaxGold(seller);
					if(BuyerGold>MaxClientGold)
					{
						new GoldAmount=BuyerGold-MaxClientGold;
						War3_SetGold(client,MaxClientGold);
						War3_DepositGoldBank(client,GoldAmount);
					}
					if(SellerGold>MaxSellerGold)
					{
						new GoldAmount=BuyerGold-MaxSellerGold;
						War3_SetGold(seller,MaxSellerGold);
						War3_DepositGoldBank(client,GoldAmount);
					}
					War3_SetDiamonds(client,BuyerDiamonds);
					War3_SetDiamonds(seller,SellerDiamonds);
					// remove seller from auction house
					AuctionHouseSteamID[seller][itemnumber]="";
					AHAmount1[seller][itemnumber] = 0;
					AHAmount2[seller][itemnumber] = 0;
					AuctionHouse[seller][itemnumber]=false;
				}
			}
			else
			{
				if(!ValidPlayer(seller))
				{
					War3_ChatMessage(client,"Seller is no longer on server. Seller has been removed from the auction house and no transaction has been made.");
					AuctionHouseSteamID[seller][itemnumber]="";
					AHAmount1[seller][itemnumber] = 0;
					AHAmount2[seller][itemnumber] = 0;
					AuctionHouse[seller][itemnumber]=false;
				}
				else
				{
					War3_ChatMessage(client,"You can't buy from yourself!");
				}
			}
		}
	}
	if(action==MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public void OnAllPluginsLoaded()
{
	W3Hook(W3Hook_OnWar3EventSpawn, OnWar3EventSpawn);
}

public void OnWar3EventSpawn (int client)
{
	if(Autobuy[client])
	{
		War3_RestoreItemsFromDeath(client,true);
	}
}

public Action:War3Evo_SayCommand(client, const String:command[], argc)
{
	decl String:argAUC[256]; //was 70
	GetCmdArg(1,argAUC,sizeof(argAUC));

	new String:strBuffer[2][20];
	ExplodeString(argAUC," ",strBuffer,2,20,false);


	if (StrEqual(argAUC,"autobuy",false)||StrEqual(argAUC,"!autobuy",false))
	{
		// switchs boolean;
		Autobuy[client]=!Autobuy[client];
		War3_ChatMessage(client, " {olive}Autobuy toggled %s", Autobuy[client] ? "on" : "off");
		return Plugin_Handled;
	} else if (GetConVarBool(hEnableAuctionHouse) && StrEqual(argAUC,"!ah",false))
	{
		if (War3_Auction(client,argAUC,true))
			return Plugin_Handled;
	}
	else	if (GetConVarBool(hEnableAuctionHouse) && StrEqual(strBuffer[0],"!ah",false))
	{
		if (War3_Auction(client,argAUC,false))
			return Plugin_Handled;
	}
	else if (GetConVarBool(hEnableAuctionHouse) && (StrEqual(strBuffer[0],"bank",false)||StrEqual(strBuffer[0],"!bank",false)))
	{
		War3_ChatMessage(client,"Gold: %i and [%i] Gold Reserved.",War3_GetGold(client)-War3_ReservedGold(client),War3_ReservedGold(client));
		War3_ChatMessage(client,"Diamonds: %i",War3_GetDiamonds(client));
	}

	return	Plugin_Continue;
}
