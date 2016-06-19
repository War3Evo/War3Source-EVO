// steamIDconverter.inc

//18:58 < Phoenix_1> no
//18:58 < Phoenix_1> STEAM_0:A:B --> C = B*2 + A --> U:1:C afaik
//18:58 < Forth> Oh, interesting

// [U:1:C] --> is C odd? if yes then A = 1, else A = 0.  B = C / 2 --> STEAM_0:A:B

// X % 2 == 0 is even

#if defined _steamIDconverter_included
 #endinput
#endif
#define _steamIDconverter_included

stock bool Convert_SteamID_TO_UniqueID(char[] sIDinfo, int szSize=64)
{
	if(StrContains(sIDinfo,"STEAM_")>-1)
	{
		new String:sBuffer[3][szSize];
		ExplodeString(sIDinfo, ":", sBuffer, 3, szSize, true);
		new aInt=StringToInt(sBuffer[1]);
		new bInt=StringToInt(sBuffer[2]);
		new cInt=bInt*2+aInt;
		Format(sIDinfo,szSize,"[U:1:%d]",cInt);
		return true;
	}
	return false;
}

stock bool Convert_UniqueID_TO_SteamID(char[] sIDinfo, int szSize=64)
{
	if(StrContains(sIDinfo,"[U:")>-1)
	{
		char[][] sBuffer = new char[3][szSize];
		ExplodeString(sIDinfo, ":", sBuffer, 3, szSize, true);
		int cInt=StringToInt(sBuffer[2]);
		int aInt;
		//if C is even
		if(cInt % 2 == 0)
		{
			aInt=0;
		}
		else
		{
			aInt=1;
		}
		int bInt=cInt/2;
		Format(sIDinfo,szSize,"STEAM_0:%d:%d",aInt,bInt);
		return true;
	}
	return false;
}

stock bool Convert_CSGO_ID_TO_TF2_SteamID(char[] sIDinfo, int szSize=64)
{
	if(StrContains(sIDinfo,"STEAM_1")>-1)
	{
		char[][] sBuffer = new char[3][szSize];
		ExplodeString(sIDinfo, ":", sBuffer, 3, szSize, true);
		int aInt=StringToInt(sBuffer[1]);
		int bInt=StringToInt(sBuffer[2]);
		Format(sIDinfo,szSize,"STEAM_0:%d:%d",aInt,bInt);
		return true;
	}
	return false;
}

stock bool GetClientAuthString_OldStyle(int client, char[] authStringDest, int strSize, bool validate = true)
{
		int accountID = GetSteamAccountID(client, validate);

		if(accountID == 0)
				return false;

		int accountType = (accountID % 2);
		accountID /= 2

		FormatEx(authStringDest, strSize, "STEAM_0:%i:%i", accountType, accountID);
		return true;
}
