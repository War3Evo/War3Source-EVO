// War3Source_Engine_Deny.sp

/*
public Plugin:myinfo=
{
	name="War3Source Deny items on racechange",
	author="El Diablo",
	description="War3Source:EVO Core Plugins",
	version="1.0",
	url="http://war3evo.info/"
};

*/
/* ***************************  OnRaceChanged *************************************/

// REMOVE ANY ITEM THAT IS NOT ALLOWED ON RACE.

public War3Source_Engine_Deny_OnRaceChanged(client,oldrace,newrace)
{

		if(ValidPlayer(client))
		{
			new ItemsLoaded = totalItemsLoaded;

			for(new i;i<=ItemsLoaded;i++)
			{
				if(GetOwnsItem(client,i))
				{
					internal_W3SetVar(EventArg1,i);
					if(W3Denyable(DN_CanBuyItem1,client)==false)
					{
						internal_W3SetVar(TheItemBoughtOrLost,i);
						DoFwd_War3_Event(DoForwardClientLostItem,client); //old item
					}
				}
			}
		}
}
