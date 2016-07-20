// War3Source_Engine_BuffHelper.sp


#define MAXBUFFHELPERS 99 /// not the bStunned but how many buffs this helper system can track

//paralell arrays
//ZEROTH is not used and filled wiht -99
Handle objRace;
Handle objBuffIndex;
Handle objClientAppliedTo;
Handle objExpiration;

/*
public Plugin:myinfo=
{
	name="W3S Engine Buff Tracker (Buff helper)",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};
*/

public War3Source_Engine_BuffHelper_OnPluginStart()
{
	objRace=CreateArray();
	objBuffIndex=CreateArray();
	objClientAppliedTo=CreateArray();
	objExpiration=CreateArray();
	PushArrayCell(objRace, -99);
	PushArrayCell(objBuffIndex, -99);
	PushArrayCell(objClientAppliedTo, -99);
	PushArrayCell(objExpiration, -99);

}
//note, accepts duration, not expiration
stock SetObject(index,race,buffindex,client,Float:duration){
	SetArrayCell(objRace,index, race);
	SetArrayCell(objBuffIndex,index, _:buffindex);
	SetArrayCell(objClientAppliedTo,index, client);
	SetArrayCell(objExpiration,index, AbsoluteTime()+duration);
}
GetObject(&index,&race,&buffindex,&client,&Float:expiration){
	race=GetArrayCell(objRace,index);
	buffindex=GetArrayCell(objBuffIndex,index);
	client=GetArrayCell(objClientAppliedTo,index );
	expiration=GetArrayCell(objExpiration,index );
}

// use  1 -- < len
ObjectLen(){
return GetArraySize(objRace);
}
RemoveObject(index){
	RemoveFromArray(objRace, index);
	RemoveFromArray(objBuffIndex, index);
	RemoveFromArray(objClientAppliedTo, index);
	RemoveFromArray(objExpiration, index);
}

public NW3ApplyBuffSimple(Handle:plugin,numParams) {
	int client=GetNativeCell(1);
	int buffindex=GetNativeCell(2);
	int race=GetNativeCell(3);
	new any:initialValue=GetNativeCell(4);
	float duration=GetNativeCell(5);
	bool allowoverwrite=GetNativeCell(6);

	if(!ValidPlayer(client)){
		ThrowError("INVALID CLIENT");
	}
	if(! ValidBuff(W3Buff:buffindex)){
		ThrowError("INVALID BUFF");
	}
	if(!eValidRace(race)){
		ThrowError("INVALID RACE");
	}
	int index=FindExisting(race,buffindex,client);
	//something exists
	if(allowoverwrite==false && index>0){
		return;
	}
//	DP("set client %d",client);
	SetBuffRace(client,W3Buff:buffindex,race,initialValue);


	if(index>0){ //replace
		SetObject(index,race,buffindex,client,Float:duration);

	}
	else{ //add to end
		AddToTracker(race,buffindex,client,Float:duration);
	}
//	BuffHelperSimpleModifier[client][raceid]=buffindex;
//	BuffHelperSimpleRemoveTime[client][raceid]=GetGameTime()+duration;
}
FindExisting(race,buffindex,client){
	int len=ObjectLen();
	for(int i=0;i<len;i++){
		if(
		GetArrayCell(objRace,i)==race&&
		GetArrayCell(objBuffIndex,i)==_:buffindex&&
		GetArrayCell(objClientAppliedTo,i)==client
		){
		return i;
		}
	}
	return 0;
}
AddToTracker(race,buffindex,client,Float:duration){
	PushArrayCell(objRace, race);
	PushArrayCell(objBuffIndex, _:buffindex);
	PushArrayCell(objClientAppliedTo, client);
	PushArrayCell(objExpiration, AbsoluteTime()+duration);
}
//public Action:DeciSecondTimer2(Handle:h)
public War3Source_Engine_BuffHelper_DeciSecondTimer()
{
	if(MapChanging || War3SourcePause) return 0;

	float now=AbsoluteTime();
	int limit=ObjectLen();
	int race;
	int buffindex;
	int client;
	float expiration;
	for(int index=1;index<limit;index++){
		GetObject(index,race,buffindex,client,Float:expiration);
		if(now>expiration){
		//	DP("expire client %d",client);
			W3ResetBuffRace(client,W3Buff:buffindex,race);
			RemoveObject(index);
			limit=ObjectLen();
			index--;
		}
	}

	return 0;
}

