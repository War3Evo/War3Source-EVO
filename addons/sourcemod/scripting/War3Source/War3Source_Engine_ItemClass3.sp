// War3Source_Engine_ItemClass3.sp

// uses w3s._War3Source_Engine_ItemClasses.txt translations

// moved to variables
//int totalItems3Loaded=0;  ///USE raceid=1;raceid<=GetRacesLoaded();raceid++ for looping
///race instance variables
//RACE ID = index of [MAXRACES], raceid 1 is raceName[1][32]

new String:item3Name[MAXITEMS3][64];
new String:item3Shortname[MAXITEMS3][16];
new String:item3Description[MAXITEMS3][1024];

new String:item3levelname[MAXITEMS3][W3ItemSkills][32];

new item3maxlevel[MAXITEMS3][W3ItemSkills];
new item3Cost[MAXITEMS3];
new item3Property[MAXITEMS3][W3ItemProp] ;

new item3OrderCvar[MAXITEMS3];
new item3FlagsCvar[MAXITEMS3];
new item3CategoryCvar[MAXITEMS3];

/*
public Plugin:myinfo=
{
	name="W3S Engine Item Class 3",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};
*/

public bool:War3Source_Engine_ItemClass3_InitNatives()
{
	CreateConVar("itemclass3",PLUGIN_VERSION,"War3Source:EVO itemclass3",FCVAR_PLUGIN);

	CreateNative("War3_CreateShopItem3",NWar3_CreateShopItem3);

	CreateNative("War3_SetItem3Property",NWar3_SetItem3Property);
	CreateNative("War3_GetItem3Property",NWar3_GetItem3Property);

	CreateNative("War3_GetItem3IdByShortname",NWar3_GetItem3IdByShortname);

	CreateNative("W3GetItem3Name",NW3GetItem3Name);
	CreateNative("W3GetItem3Shortname",NW3GetItem3Shortname);
	CreateNative("W3GetItem3Desc",NW3GetItem3Description);

	CreateNative("W3GetItems3Loaded",Native_GetItems3Loaded);

	CreateNative("W3GetItem3Cost",NW3GetItem3Cost);

	CreateNative("W3GetItem3levelName",NW3GetItem3levelName);

	CreateNative("W3GetItem3maxtotallevels",NW3GetItem3maxtotallevels);

	CreateNative("W3GetItem3maxlevel1",NW3GetItem3maxlevel1);
	CreateNative("W3GetItem3maxlevel2",NW3GetItem3maxlevel2);

	CreateNative("W3GetItem3Order",NW3GetItem3Order);
	CreateNative("W3Item3HasFlag",NW3Item3HasFlag);
	CreateNative("W3GetItem3Category",NW3GetItem3Category);

	CreateNative("W3ItemCategoryExist",NW3ItemCategoryExist);
	CreateNative("W3CompareTwoItemCategories",NW3CompareTwoItemCategories);


	return true;
}

public NWar3_CreateShopItem3(Handle:plugin,numParams)
{

	decl String:name[64],String:shortname[16],String:desc[1024],String:category[64],String:itemlevelname1[32],String:itemlevelname2[32];
	GetNativeString(1,name,sizeof(name));
	GetNativeString(2,shortname,sizeof(shortname));
	GetNativeString(3,desc,sizeof(desc));
	new cost=GetNativeCell(4);
	GetNativeString(5,category,sizeof(category));
	GetNativeString(6,itemlevelname1,sizeof(itemlevelname1));
	new maxlevel1=GetNativeCell(7);
	GetNativeString(8,itemlevelname2,sizeof(itemlevelname2));
	new maxlevel2=GetNativeCell(9);

	new itemid=CreateNewItem3(name,shortname,desc,cost,category,itemlevelname1,maxlevel1,itemlevelname2,maxlevel2);
	return itemid;
}


public NWar3_SetItem3Property(Handle:plugin,numParams)
{
	new item=GetNativeCell(1);
	new W3ItemProp:property=GetNativeCell(2);
	new any:value=GetNativeCell(3);
	SetItem3Property(item,property,value);
}
public NWar3_GetItem3Property(Handle:plugin,numParams)
{
	new item=GetNativeCell(1);
	new W3ItemProp:property=GetNativeCell(2);
	return GetItem3Property(item,property);
}
public NWar3_GetItem3IdByShortname(Handle:plugin,numParams)
{

	new String:itemshortname[16],String:argstr[16];
	GetNativeString(1,argstr,16);
	new ItemsLoaded = W3GetItems3Loaded();
	for(new i=1;i<=ItemsLoaded;i++){
		GetItem3Shortname(i,itemshortname,sizeof(itemshortname));
		if(StrEqual(argstr,itemshortname)){
			return i;
		}
	}
	return 0;
}

//native W3GetItem3levelName(itemid,String:ret[],maxlen,W3ItemSkills:sidenum);
public NW3GetItem3levelName(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);
	if(itemid>0)
	{
		new String:str[32];
		strcopy(str,31,item3levelname[itemid][GetNativeCell(4)]);
		SetNativeString(2,str,GetNativeCell(3));
	}
}

public NW3GetItem3Name(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);
	if(itemid>0)
	{
		new String:str[64];
		GetItem3Name(itemid,str,sizeof(str));
		SetNativeString(2,str,GetNativeCell(3));
	}
}
public NW3GetItem3Shortname(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);
	if(itemid>0)
	{
		new String:str[16];
		GetItem3Shortname(itemid,str,sizeof(str));
		SetNativeString(2,str,GetNativeCell(3));
	}
}
public NW3GetItem3Description(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);
	if(itemid>0)
	{
		new String:str[1024];
		GetItem3Description(itemid,str,sizeof(str));
		SetNativeString(2,str,GetNativeCell(3));
	}
}
public Native_GetItems3Loaded(Handle:plugin,numParams)
{
	return totalItems3Loaded;
}


public NW3GetItem3maxtotallevels(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);
	return (Internal_NW3GetItem3maxlevel1(itemid) + Internal_NW3GetItem3maxlevel2(itemid));
}


public NW3GetItem3maxlevel1(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);
	return Internal_NW3GetItem3maxlevel1(itemid);
}
public NW3GetItem3maxlevel2(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);
	return Internal_NW3GetItem3maxlevel2(itemid);
}


Internal_NW3GetItem3maxlevel1(itemid){
	if(itemid>0 && itemid<MAXITEMS3)
	{
		return item3maxlevel[itemid][skill1];
	}
	return 0;
}
Internal_NW3GetItem3maxlevel2(itemid){
	if(itemid>0 && itemid<MAXITEMS3)
	{
		return item3maxlevel[itemid][skill2];
	}
	return 0;
}

public NW3GetItem3Cost(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);
	if(itemid>0 && itemid<MAXITEMS3)
	{
		return W3GetCvarInt(item3Cost[itemid]);
	}
	return 0;
}


public NW3GetItem3Order(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);
	return W3GetCvarInt(item3OrderCvar[itemid]);
}
public NW3Item3HasFlag(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);
	if(itemid>0 && itemid<MAXITEMS3)
	{
		new String:buf[1000];
		W3GetCvar(item3FlagsCvar[itemid],buf,sizeof(buf));

		new String:flagsearch[32];
		GetNativeString(2,flagsearch,sizeof(flagsearch));
		return (StrContains(buf,flagsearch)>-1);
	}
	return false;
}
public NW3GetItem3Category(Handle:plugin,numParams)
{
	new itemid=GetNativeCell(1);
	if(itemid>0 && itemid<MAXITEMS3)
	{
		new String:buf[1000];
		W3GetCvar(item3CategoryCvar[itemid],buf,sizeof(buf));
		SetNativeString(2,buf,GetNativeCell(3));
	}
}

//native bool:W3CompareItemCategories(itemid1,itemid2);
public NW3CompareTwoItemCategories(Handle:plugin,numParams)
{
	if(numParams<2)
		return false;

	new itemz1=GetNativeCell(1);
	new itemz2=GetNativeCell(2);

	return CompareTwoItemCategories(itemz1,itemz2);
}

public NW3ItemCategoryExist(Handle:plugin,numParams)
{
	if(numParams<3)
		return false;

	new client=GetNativeCell(1);

	if(!ValidPlayer(client))
		return false;

	new raceid=GetNativeCell(2);
	new item=GetNativeCell(3);

	new itemid1=War3_GetItemId1(client,raceid);
	new itemid2=War3_GetItemId2(client,raceid);
	new itemid3=War3_GetItemId3(client,raceid);

	new bool:found=false;

	found=CompareTwoItemCategories(item,itemid1);
	if(!found)
		found=CompareTwoItemCategories(item,itemid2);
	if(!found)
		found=CompareTwoItemCategories(item,itemid3);

	//if(found)
		//DP("returning true on compare items");
	//else
		//DP("returning false on compare items");
	return found;
}


bool:CompareTwoItemCategories(item1x,item2x)
{
	new bool:found=false;

	new String:buf[1000],String:buf2[1000];

	if(item1x>0 && item1x<MAXITEMS3 && item2x>0&& item2x<MAXITEMS3)
	{
		W3GetCvar(item3CategoryCvar[item1x],buf,sizeof(buf));
		W3GetCvar(item3CategoryCvar[item2x],buf2,sizeof(buf2));

		if(StrEqual(buf,buf2))
			found=true;
	}
	return found;
}




CreateNewItem3(String:titemname[] ,String:titemshortname[] ,String:titemdescription[], itemcostplatinum, String:titemcategory[], String:itemlevelname1[], maxlevel1, String:itemlevelname2[], maxlevel2){

	if(totalItems3Loaded+1==MAXITEMS3){ //make sure we didnt reach our item capacity limit
		LogError("%T","MAX ITEMS REACHED, CANNOT REGISTER {titemname}", LANG_SERVER, titemname);
		return -1;
	}

	//first item registering, fill in the  zeroth  along
	if(totalItems3Loaded==0){

		Format(item2Name[0],31,"%t","ZEROTH ITEM");

	}
	else{
		decl String:shortnameexisted[16];
		new ItemsLoaded = W3GetItems3Loaded();
		for(new i=1;i<=ItemsLoaded;i++){
			GetItem3Shortname(i,shortnameexisted,sizeof(shortnameexisted));
			if(StrEqual(titemshortname,shortnameexisted)){
				return i; //item already exists
			}
		}
	}



	totalItems3Loaded++;
	new titemid=totalItems3Loaded;

	strcopy(item3levelname[titemid][skill1], 31, itemlevelname1);
	item3maxlevel[titemid][skill1]=maxlevel1;

	strcopy(item3levelname[titemid][skill2], 31, itemlevelname2);
	item3maxlevel[titemid][skill2]=maxlevel2;

	strcopy(item3Name[titemid], 31, titemname);
	strcopy(item3Shortname[titemid], 15, titemshortname);
	strcopy(item3Description[titemid], 1023, titemdescription);

	new String:cvarstr[32];
	new String:transbuffstr[32];

	Format(transbuffstr,sizeof(transbuffstr),"%t","item3 cost with platinum");
	Format(cvarstr,sizeof(cvarstr),"%s_platinumcost",titemshortname);
	item3Cost[titemid]=W3CreateCvarInt(cvarstr,itemcostplatinum,transbuffstr);

	Format(transbuffstr,sizeof(transbuffstr),"%t","item3 order");
	Format(cvarstr,sizeof(cvarstr),"%s_item3order",titemshortname);
	item3OrderCvar[titemid]=W3CreateCvarInt(cvarstr,titemid*400,transbuffstr);

	Format(transbuffstr,sizeof(transbuffstr),"%t","item3 flags");
	Format(cvarstr,sizeof(cvarstr),"%s_item3flags",titemshortname);
	item3FlagsCvar[titemid]=W3CreateCvar(cvarstr,"0",transbuffstr);

	Format(transbuffstr,sizeof(transbuffstr),"%t","item3 category");
	Format(cvarstr,sizeof(cvarstr),"%s_item3category",titemshortname);
	item3CategoryCvar[titemid]=W3CreateCvar(cvarstr,titemcategory,transbuffstr);

	return titemid; //this will be the new item's id / index
}
GetItem3Name(itemid,String:str[],len){
	strcopy(str,len,item3Name[itemid]);
}
GetItem3Shortname(itemid,String:str[],len){
	strcopy(str,len,item3Shortname[itemid]);

}
GetItem3Description(itemid,String:str[],len){
	strcopy(str,len,item3Description[itemid]);
}


SetItem3Property(item,W3ItemProp:ITEMproperty,any:value)  {
	item3Property[item][ITEMproperty]=value;
}
GetItem3Property(item,W3ItemProp:ITEMproperty){
	return item3Property[item][ITEMproperty];
}
