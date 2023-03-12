// War3Source_Engine_ItemClass.sp

// uses w3s._War3Source_Engine_ItemClasses.txt translations

// TRANSLATED

//#assert GGAMEMODE == MODE_WAR3SOURCE

// moved to variables
//new totalItemsLoaded=0;  ///USE raceid=1;raceid<=GetRacesLoaded();raceid++ for looping
///race instance variables
//RACE ID = index of [MAXRACES], raceid 1 is raceName[1][32]

new String:itemName[MAXITEMS][64];
new String:itemShortname[MAXITEMS][16];
new String:itemDescription[MAXITEMS][512];
new String:itemShortDescription[MAXITEMS][256];

// So that only these classes can see the item and buy it.
#if (GGAMETYPE == GGAME_TF2)
new bool:itemClassShopmenu[MAXITEMS][10];
#endif

new itemCSmoney[MAXITEMS];
new itemGoldCost[MAXITEMS];
new itemMoneyCost[MAXITEMS];
new itemProperty[MAXITEMS][W3ItemProp] ;

new itemOrderCvar[MAXITEMS];
new itemFlagsCvar[MAXITEMS];
new itemCategoryCvar[MAXITEMS];

new bool:itemTranslated[MAXITEMS];

/*
public Plugin:myinfo=
{
	name="W3S Engine Item Class",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};
*/

public bool:War3Source_Engine_ItemClass_InitNatives()
{

	CreateNative("War3_CreateShopItem",NWar3_CreateShopItem);
	CreateNative("War3_CreateShopItemT",NWar3_CreateShopItemT);
#if (GGAMETYPE == GGAME_TF2)
	CreateNative("War3_TFSetItemClasses",NWar3_SetItemClasses);
	CreateNative("War3_TFIsItemClass",NWar3_IsItemClass);
#endif
	CreateNative("War3_SetItemProperty",NWar3_SetItemProperty);
	CreateNative("War3_GetItemProperty",NWar3_GetItemProperty);

	CreateNative("War3_GetItemIdByShortname",NWar3_GetItemIdByShortname);

	CreateNative("W3GetItemName",NW3GetItemName);
	CreateNative("W3GetItemShortname",NW3GetItemShortname);
	CreateNative("W3GetItemShortdesc",NW3GetItemShortdesc);
	CreateNative("W3GetItemDescription",NW3GetItemDescription);

	CreateNative("W3GetItemsLoaded",Native_GetItemsLoaded);

	CreateNative("W3GetItemCost",NW3GetItemCost);
	CreateNative("W3IsItemCSmoney",NW3IsItemCSmoney);

	//CreateNative("W3GetItemOrder",NW3GetItemOrder);
	CreateNative("W3ItemHasFlag",NW3ItemHasFlag);
	CreateNative("W3GetItemCategory",NW3GetItemCategory);

	return true;
}

public NWar3_CreateShopItem(Handle:plugin,numParams)
{

	decl String:name[64],String:shortname[16],String:shortdesc[256],String:desc[512];
	GetNativeString(1,name,sizeof(name));
	GetNativeString(2,shortname,sizeof(shortname));
	GetNativeString(3,shortdesc,sizeof(shortdesc));
	GetNativeString(4,desc,sizeof(desc));
	new cost=GetNativeCell(5);
	new costmoney=GetNativeCell(6);
	new usecsmoney=GetNativeCell(7);
	new itemid=CreateNewItem(name,shortname,shortdesc,desc,cost,costmoney,usecsmoney);
	return itemid;
}
public NWar3_CreateShopItemT(Handle:plugin,numParams)
{

	decl String:name[64],String:shortname[16],String:shortdesc[256],String:desc[512];
	GetNativeString(1,shortname,sizeof(shortname));
	GetNativeString(2,shortdesc,sizeof(shortdesc));
	new cost=GetNativeCell(3);
	new costmoney=GetNativeCell(4);
	new usecsmoney=GetNativeCell(5);


	Format(name,sizeof(name),"%s_ItemName",shortname);

	Format(desc,sizeof(desc),"%s_ItemDesc",shortname);

	new itemid=CreateNewItem(name,shortname,shortdesc,desc,cost,costmoney,usecsmoney);
	itemTranslated[itemid]=true;

	if(StrEqual(shortname,"scroll")){
		Format(shortname,sizeof(shortname),"_scroll");   ///SHORTNAME IS ONLY USED ONCE BELOW
	}

	new String:buf[64];
	Format(buf,sizeof(buf),"w3s.item.%s.phrases",shortname);
	LoadTranslations(buf);
	return itemid;
}
#if (GGAMETYPE == GGAME_TF2)
public NWar3_SetItemClasses(Handle:plugin,numParams)
{
	new itemid = GetNativeCell(1);
	new bool:itemClassExists=false;
	for(new i=2; i <= numParams; i++)
	{
		switch(GetNativeCellRef(i))
		{
			case TFClass_Unknown:
			{
				itemClassShopmenu[itemid][0]=true;
				itemClassExists=true;
			}
			case TFClass_Scout:
			{
				itemClassShopmenu[itemid][1]=true;
				itemClassExists=true;
			}
			case TFClass_Sniper:
			{
				itemClassShopmenu[itemid][2]=true;
				itemClassExists=true;
			}
			case TFClass_Soldier:
			{
				itemClassShopmenu[itemid][3]=true;
				itemClassExists=true;
			}
			case TFClass_DemoMan:
			{
				itemClassShopmenu[itemid][4]=true;
				itemClassExists=true;
			}
			case TFClass_Medic:
			{
				itemClassShopmenu[itemid][5]=true;
				itemClassExists=true;
			}
			case TFClass_Heavy:
			{
				itemClassShopmenu[itemid][6]=true;
				itemClassExists=true;
			}
			case TFClass_Pyro:
			{
				itemClassShopmenu[itemid][7]=true;
				itemClassExists=true;
			}
			case TFClass_Spy:
			{
				itemClassShopmenu[itemid][8]=true;
				itemClassExists=true;
			}
			case TFClass_Engineer:
			{
				itemClassShopmenu[itemid][9]=true;
				itemClassExists=true;
			}
		}
	}
	// If the item does not have a setting, then all classes can use it.
	if(itemClassExists==false)
	{
	// Set for all
		for(new x=0; x <= 9; x++)
		{
			itemClassShopmenu[itemid][x]=true;
		}
	}
}

stock bool internal_War3_TFIsItemClass(int itemid,TFClassType iPlayerClass)
{
	if(itemClassShopmenu[itemid][0]==true)
		return true;

	bool itemClassSet=false;

	//Check if itemClass was set?
	for(int x=0; x <= 9; x++)
	{
		if(itemClassShopmenu[itemid][x]==true)
			itemClassSet=true;
	}

	if (!itemClassSet)
		return true;
	else
		return itemClassShopmenu[itemid][iPlayerClass];
}

public NWar3_IsItemClass(Handle:plugin,numParams)
{
	int itemid = GetNativeCell(1);
	TFClassType iPlayerClass = view_as<TFClassType>(GetNativeCell(2));

	//DP("itemid %i iPlayerClass %b",itemid,itemClassShopmenu[itemid][iPlayerClass]);

	return internal_War3_TFIsItemClass(itemid,iPlayerClass);
}
#endif
public NWar3_SetItemProperty(Handle:plugin,numParams)
{
	new item=GetNativeCell(1);
	new W3ItemProp:property=GetNativeCell(2);
	new any:value=GetNativeCell(3);
	SetItemProperty(item,property,value);
}
public NWar3_GetItemProperty(Handle:plugin,numParams)
{
	new item=GetNativeCell(1);
	new W3ItemProp:property=GetNativeCell(2);
	return GetItemProperty(item,property);
}
public int internal_GetItemIdByShortname(char argstr[16])
{
	char itemshortname[16];
	int ItemsLoaded = totalItemsLoaded;
	for(int i=1;i<=ItemsLoaded;i++){
		GetItemShortname(i,itemshortname,sizeof(itemshortname));
		if(StrEqual(argstr,itemshortname)){
			return i;
		}
	}
	return -1;
}
public NWar3_GetItemIdByShortname(Handle:plugin,numParams)
{

	new String:itemshortname[16],String:argstr[16];
	GetNativeString(1,argstr,16);
	new ItemsLoaded = totalItemsLoaded;
	for(new i=1;i<=ItemsLoaded;i++){
		GetItemShortname(i,itemshortname,sizeof(itemshortname));
		if(StrEqual(argstr,itemshortname)){
			return i;
		}
	}
	return -1;
}



public NW3GetItemName(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);
	new String:str[64];
	GetItemName(itemid,str,sizeof(str));
	SetNativeString(2,str,GetNativeCell(3));
}
public NW3GetItemShortname(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);

	new String:str[16];
	GetItemShortname(itemid,str,sizeof(str));
	SetNativeString(2,str,GetNativeCell(3));

}
public NW3GetItemShortdesc(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);

	new String:str[256];
	GetItemShortdesc(itemid,str,sizeof(str));
	SetNativeString(2,str,GetNativeCell(3));

}
public NW3GetItemDescription(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);

	new String:str[512];
	GetItemDescription(itemid,str,sizeof(str));
	SetNativeString(2,str,GetNativeCell(3));
}
public Native_GetItemsLoaded(Handle:plugin,numParams)
{
	return totalItemsLoaded;
}

stock int GetItemCost(int client,int itemid,bool csmoney=false)
{
	int itemcost=0;

	if(csmoney)
	{
		itemcost = GetCvarInt(itemMoneyCost[itemid]);
	}
	else
	{
		itemcost = GetCvarInt(itemGoldCost[itemid]);
		internal_W3SetVar(EventArg1,itemid);
		internal_W3SetVar(EventArg2,itemcost); //set event vars
		DoFwd_War3_Event(OnPreShopMenu1ItemCost,client); //fire event
		return internal_W3GetVar(EventArg2); //retrieve possibly modified vars
	}

	return itemcost;
}

public NW3GetItemCost(Handle:plugin,numParams)
{
	new client=GetNativeCell(1);
	new itemid=GetNativeCell(2);
	new bool:csmoney=bool:GetNativeCell(3);

	new itemcost=0;

	if(csmoney)
	{
		itemcost = W3GetCvarInt(itemMoneyCost[itemid]);
	}
	else
	{
		itemcost = W3GetCvarInt(itemGoldCost[itemid]);
		internal_W3SetVar(EventArg1,itemid);
		internal_W3SetVar(EventArg2,itemcost); //set event vars
		DoFwd_War3_Event(OnPreShopMenu1ItemCost,client); //fire event
		return internal_W3GetVar(EventArg2); //retrieve possibly modified vars
	}

	return itemcost;
}

public NW3IsItemCSmoney(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);
	return W3GetCvarInt(itemCSmoney[itemid]);
}

public NW3GetItemOrder(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);
	return W3GetCvarInt(itemOrderCvar[itemid]);
}
public NW3ItemHasFlag(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);
	new String:buf[1000];
	W3GetCvar(itemFlagsCvar[itemid],buf,sizeof(buf));

	new String:flagsearch[32];
	GetNativeString(2,flagsearch,sizeof(flagsearch));

	return (StrContains(buf,flagsearch)>-1);
}
public NW3GetItemCategory(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);
	new String:buf[1000];
	W3GetCvar(itemCategoryCvar[itemid],buf,sizeof(buf));
	SetNativeString(2,buf,GetNativeCell(3));
}



CreateNewItem(String:titemname[] ,String:titemshortname[] ,String:titemshortdesc[] ,String:titemdescription[], itemcostgold,itemcostmoney,usecsmoney=0){

	if(totalItemsLoaded+1==MAXITEMS){ //make sure we didnt reach our item capacity limit
		LogError("[War3Source:EVO] %T","MAX ITEMS REACHED, CANNOT REGISTER {titemname}", LANG_SERVER, titemname);
		return -1;
	}

	//first item registering, fill in the  zeroth  along
	if(totalItemsLoaded==0)
	{
		Format(itemName[0],31,"%t","ZEROTH ITEM");
	}
	else
	{
		decl String:shortnameexisted[16];
		new ItemsLoaded = W3GetItemsLoaded();
		for(new i=1;i<=ItemsLoaded;i++)
		{
			GetItemShortname(i,shortnameexisted,sizeof(shortnameexisted));
			if(StrEqual(titemshortname,shortnameexisted))
			{
				return i; //item already exists
			}
		}
	}



	totalItemsLoaded++;
	new titemid=totalItemsLoaded;

	strcopy(itemName[titemid], 31, titemname);
	strcopy(itemShortname[titemid], 15, titemshortname);
	strcopy(itemShortDescription[titemid], 255, titemshortdesc);
	strcopy(itemDescription[titemid], 511, titemdescription);

	new String:cvarstr[32];
	new String:transbuffstr[32];

	Format(transbuffstr,sizeof(transbuffstr),"%t","use cs money instead of gold");
	Format(cvarstr,sizeof(cvarstr),"%s_usecsmoney",titemshortname);
	itemCSmoney[titemid]=W3CreateCvarInt(cvarstr,usecsmoney,transbuffstr);

	Format(transbuffstr,sizeof(transbuffstr),"%t","item cost with gold");
	Format(cvarstr,sizeof(cvarstr),"%s_goldcost",titemshortname);
	itemGoldCost[titemid]=W3CreateCvarInt(cvarstr,itemcostgold,transbuffstr);

	Format(transbuffstr,sizeof(transbuffstr),"%t","item cost with cs money");
	Format(cvarstr,sizeof(cvarstr),"%s_moneycost",titemshortname);
	itemMoneyCost[titemid]=W3CreateCvarInt(cvarstr,itemcostmoney,transbuffstr);

	Format(transbuffstr,sizeof(transbuffstr),"%t","item order");
	Format(cvarstr,sizeof(cvarstr),"%s_itemorder",titemshortname);
	itemOrderCvar[titemid]=W3CreateCvarInt(cvarstr,titemid*100,transbuffstr);

	Format(transbuffstr,sizeof(transbuffstr),"%t","item flags");
	Format(cvarstr,sizeof(cvarstr),"%s_itemflags",titemshortname);
	itemFlagsCvar[titemid]=W3CreateCvar(cvarstr,"0",transbuffstr);

	Format(transbuffstr,sizeof(transbuffstr),"%t","item category");
	Format(cvarstr,sizeof(cvarstr),"%s_itemcategory",titemshortname);
	itemCategoryCvar[titemid]=W3CreateCvar(cvarstr,"0",transbuffstr);

	return titemid; //this will be the new item's id / index
}
GetItemName(itemid,String:str[],len){
	if(itemTranslated[itemid]){

		new String:buf[64];
		Format(buf,sizeof(buf),"%T",itemName[itemid],GetTrans());
		strcopy(str,len,buf);
	}
	else{
		strcopy(str,len,itemName[itemid]);
	}
}
GetItemShortname(itemid,String:str[],len){
	strcopy(str,len,itemShortname[itemid]);

}
GetItemShortdesc(itemid,String:str[],len){
	strcopy(str,len,itemShortDescription[itemid]);

}
GetItemDescription(itemid,String:str[],len){
	if(itemTranslated[itemid]){
		new String:buf[512];
		Format(buf,sizeof(buf),"%T",itemDescription[itemid],GetTrans());
		strcopy(str,len,buf);
	}
	else{
		strcopy(str,len,itemDescription[itemid]);
	}
}

SetItemProperty(item,W3ItemProp:ITEMproperty,any:value)  {
	itemProperty[item][ITEMproperty]=value;
}
GetItemProperty(item,W3ItemProp:ITEMproperty){
	return itemProperty[item][ITEMproperty];
}
