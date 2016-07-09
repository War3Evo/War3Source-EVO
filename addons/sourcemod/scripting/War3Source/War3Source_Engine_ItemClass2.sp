// War3Source_Engine_ItemClass2.sp

///race instance variables
//RACE ID = index of [MAXRACES], raceid 1 is raceName[1][32]

char item2Name[MAXITEMS][64];
char item2Shortname[MAXITEMS][16];
char item2ShortDescription[MAXITEMS][256];
char item2Description[MAXITEMS][512];

int item2diamondCost[MAXITEMS];
int item2Property[MAXITEMS][W3ItemProp] ;

int item2OrderCvar[MAXITEMS];
int item2FlagsCvar[MAXITEMS];
int item2CategoryCvar[MAXITEMS];

bool item2Translated[MAXITEMS];
/*
public Plugin:myinfo=
{
	name="W3S Engine Item Class 2",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};*/

public bool:War3Source_Engine_ItemClass2_InitNatives()
{
	CreateConVar("war3evo_itemclass2",PLUGIN_VERSION,"War3Source:EVO itemclass2");

	CreateNative("War3_CreateShopItem2",NWar3_CreateShopItem2);
	CreateNative("War3_CreateShopItem2T",NWar3_CreateShopItem2T);

	CreateNative("War3_SetItem2Property",NWar3_SetItem2Property);
	CreateNative("War3_GetItem2Property",NWar3_GetItem2Property);

	CreateNative("War3_GetItem2IdByShortname",NWar3_GetItem2IdByShortname);

	CreateNative("W3GetItem2Name",NW3GetItem2Name);
	CreateNative("W3GetItem2Shortname",NW3GetItem2Shortname);
	CreateNative("W3GetItem2Shortdesc",NW3GetItem2Shortdesc);
	CreateNative("W3GetItem2Desc",NW3GetItem2Description);

	CreateNative("W3GetItems2Loaded",Native_GetItems2Loaded);

	CreateNative("W3GetItem2Cost",NW3GetItem2Cost);


	CreateNative("W3GetItem2Order",NW3GetItem2Order);
	CreateNative("W3Item2HasFlag",NW3Item2HasFlag);
	CreateNative("W3GetItem2Catagory",NW3GetItem2Catagory);


	return true;
}

public NWar3_CreateShopItem2(Handle:plugin,numParams)
{

	decl String:name[64],String:shortname[16],String:shortdesc[256],String:desc[512];
	GetNativeString(1,name,sizeof(name));
	GetNativeString(2,shortname,sizeof(shortname));
	GetNativeString(3,shortdesc,sizeof(shortdesc));
	GetNativeString(4,desc,sizeof(desc));
	new cost=GetNativeCell(5);
	new itemid=CreateNewItem2(name,shortname,shortdesc,desc,cost);
	return itemid;
}
public NWar3_CreateShopItem2T(Handle:plugin,numParams)
{

	decl String:name[64],String:shortname[16],String:shortdesc[256],String:desc[512];
	GetNativeString(1,shortname,sizeof(shortname));
	GetNativeString(2,shortdesc,sizeof(shortdesc));
	new cost=GetNativeCell(3);

	Format(name,sizeof(name),"%s_temName",shortname);

	Format(desc,sizeof(desc),"%s_temDesc",shortname);

	new itemid=CreateNewItem2(name,shortname,shortdesc,desc,cost);
	item2Translated[itemid]=true;

	/*
	if(StrEqual(shortname,"scroll")){
		Format(shortname,sizeof(shortname),"_scroll");   ///SHORTNAME IS ONLY USED ONCE BELOW
	}
	*/

	char buf[64];
	Format(buf,sizeof(buf),"w3s.item2.%s.phrases",shortname);
	LoadTranslations(buf);
	return itemid;
}

public NWar3_SetItem2Property(Handle:plugin,numParams)
{
	new item=GetNativeCell(1);
	new W3ItemProp:property=GetNativeCell(2);
	new any:value=GetNativeCell(3);
	SetItem2Property(item,property,value);
}
public NWar3_GetItem2Property(Handle:plugin,numParams)
{
	new item=GetNativeCell(1);
	new W3ItemProp:property=GetNativeCell(2);
	return GetItem2Property(item,property);
}
public NWar3_GetItem2IdByShortname(Handle:plugin,numParams)
{

	char itemshortname[16],argstr[16];
	GetNativeString(1,argstr,16);
	new ItemsLoaded = W3GetItems2Loaded();
	for(new i=1;i<=ItemsLoaded;i++){
		GetItem2Shortname(i,itemshortname,sizeof(itemshortname));
		if(StrEqual(argstr,itemshortname)){
			return i;
		}
	}
	return -1;
}



public NW3GetItem2Name(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);
	char str[64];
	GetItem2Name(itemid,str,sizeof(str));
	SetNativeString(2,str,GetNativeCell(3));
}
public NW3GetItem2Shortname(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);

	char str[16];
	GetItem2Shortname(itemid,str,sizeof(str));
	SetNativeString(2,str,GetNativeCell(3));

}
public NW3GetItem2Shortdesc(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);

	char str[256];
	GetItem2Shortdesc(itemid,str,sizeof(str));
	SetNativeString(2,str,GetNativeCell(3));

}
public NW3GetItem2Description(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);

	char str[512];
	GetItem2Description(itemid,str,sizeof(str));
	SetNativeString(2,str,GetNativeCell(3));
}
public Native_GetItems2Loaded(Handle:plugin,numParams)
{
	return totalItems2Loaded;
}


public NW3GetItem2Cost(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);
	return W3GetCvarInt(item2diamondCost[itemid]);
}


public NW3GetItem2Order(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);
	return W3GetCvarInt(item2OrderCvar[itemid]);
}
public NW3Item2HasFlag(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);
	char buf[1000];
	W3GetCvar(item2FlagsCvar[itemid],buf,sizeof(buf));

	char flagsearch[32];
	GetNativeString(2,flagsearch,sizeof(flagsearch));

	return (StrContains(buf,flagsearch)>-1);
}
public NW3GetItem2Catagory(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);
	char buf[1000];
	W3GetCvar(item2CategoryCvar[itemid],buf,sizeof(buf));
	SetNativeString(2,buf,GetNativeCell(3));
}

CreateNewItem2(String:titemname[] ,String:titemshortname[] ,String:titemshortdesc[] ,String:titemdescription[], itemcostgold){

	if(totalItems2Loaded+1==MAXITEMS){ //make sure we didnt reach our item capacity limit
		LogError("MAX ITEMS REACHED, CANNOT REGISTER %s",titemname);
		return -1;
	}

	//first item registering, fill in the  zeroth  along
	if(totalItems2Loaded==0){

		Format(item2Name[0],31,"ZEROTH ITEM");

	}
	else{
		decl String:shortnameexisted[16];
		new ItemsLoaded = W3GetItems2Loaded();
		for(new i=1;i<=ItemsLoaded;i++){
			GetItem2Shortname(i,shortnameexisted,sizeof(shortnameexisted));
			if(StrEqual(titemshortname,shortnameexisted)){
				return i; //item already exists
			}
		}
	}



	totalItems2Loaded++;
	new titemid=totalItems2Loaded;

	strcopy(item2Name[titemid], 31, titemname);
	strcopy(item2Shortname[titemid], 15, titemshortname);
	strcopy(item2ShortDescription[titemid], 255, titemshortdesc);
	strcopy(item2Description[titemid], 511, titemdescription);

	char cvarstr[32];
	Format(cvarstr,sizeof(cvarstr),"%s_diamondcost",titemshortname);
	item2diamondCost[titemid]=W3CreateCvarInt(cvarstr,itemcostgold,"item2 cost with diamonds");

	Format(cvarstr,sizeof(cvarstr),"%s_item2order",titemshortname);
	item2OrderCvar[titemid]=W3CreateCvarInt(cvarstr,titemid*200,"item2 order");

	Format(cvarstr,sizeof(cvarstr),"%s_item2flags",titemshortname);
	item2FlagsCvar[titemid]=W3CreateCvar(cvarstr,"0","item2 flags");

	Format(cvarstr,sizeof(cvarstr),"%s_item2category",titemshortname);
	item2CategoryCvar[titemid]=W3CreateCvar(cvarstr,"0","item2 category");

	return titemid; //this will be the new item's id / index
}
GetItem2Name(itemid,String:str[],len){
	if(item2Translated[itemid]){

		char buf[64];
		Format(buf,sizeof(buf),"%T",item2Name[itemid],GetTrans());
		strcopy(str,len,buf);
	}
	else{
		strcopy(str,len,item2Name[itemid]);
	}
}
GetItem2Shortname(itemid,String:str[],len){
	strcopy(str,len,item2Shortname[itemid]);

}
GetItem2Shortdesc(itemid,String:str[],len){
	strcopy(str,len,item2ShortDescription[itemid]);

}
GetItem2Description(itemid,String:str[],len){
	if(item2Translated[itemid]){
		char buf[512];
		Format(buf,sizeof(buf),"%T",item2Description[itemid],GetTrans());
		strcopy(str,len,buf);
	}
	else{
		strcopy(str,len,item2Description[itemid]);
	}
}

SetItem2Property(item,W3ItemProp:ITEMproperty,any:value)  {
	item2Property[item][ITEMproperty]=value;
}
GetItem2Property(item,W3ItemProp:ITEMproperty){
	return item2Property[item][ITEMproperty];
}
