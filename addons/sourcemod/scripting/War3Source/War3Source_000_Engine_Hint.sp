// War3Source_000_Engine_Hint.sp

new UserMsg:umHintText;

/*
public Plugin:myinfo=
{
	name="Engine Hint Display",
	author="Ownz",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};*/

public War3Source_000_Engine_Hint_OnPluginStart()
{
	umHintText = GetUserMessageId("HintText");

	if (umHintText == INVALID_MESSAGE_ID)
		SetFailState("This game doesn't support HintText???");

	HookUserMessage(umHintText, MsgHook_HintText,true);
}

public NW3Hint(Handle:plugin,numParams)
{
	if(MapChanging || War3SourcePause) return 1;

	new client= GetNativeCell(1);
	if(!ValidPlayer(client)) return 0;

	new W3HintPriority:priority=W3HintPriority:GetNativeCell(2);
	new Float:Duration=GetNativeCell(3);
	if(Duration>20.0){ Duration=20.0;}
	new String:format[128];
	GetNativeString(4,format,sizeof(format));
	new String:output[128];
	FormatNativeString(0,
			4,
			5,
			sizeof(output),
			dummy,
			output
			);

	//must have \n
	new len=strlen(output);
	if(len>0&&output[len-1]!='\n')
	{
		StrCat(output, sizeof(output), "\n");
	}

	new Handle:arr=objarray[client][priority];
	if (arr == INVALID_HANDLE)
		objarray[client][priority] = arr = CreateArray(ByteCountToCells(128)); //128 characters;

	if(W3GetHintPriorityType(priority)==HINT_TYPE_SINGLE)
	{
		ClearArray(arr);
	}

	//does it already exist? then update time
	new index=FindStringInArray(arr,output);
	if(index>=0)
	{
		SetArrayCell(arr,index+1,Duration + GetEngineTime()); //ODD
	}
	else
	{
		PushArrayString(arr, output); //EVEN
		PushArrayCell(arr,Duration + GetEngineTime()); //ODD
	}

	updatenextframe[client]=true;

	return 1;
}

public DeleteObject(client)
{
	//if ur object holds handles, close them!!
	for(new W3HintPriority:i=HINT_NORMAL; i < HINT_SIZE; i++)
	{
		new Handle:arr=objarray[client][i];
		if (arr)
		{
			//PrintToServer("%d",arr));
			CloseHandle(arr); //this is the array created above
			objarray[client][i] = INVALID_HANDLE;
		}
	}
}

public Action:MsgHook_HintText(UserMsg:msg_id, Handle:bf, const players[], playersNum, bool:reliable, bool:init)
{
	if(MapChanging || War3SourcePause) return Plugin_Continue;
//do NOT print to chat here
//do NOT print to chat here
//do NOT print to chat here
//do NOT print to chat here
//do NOT print to chat here

	new bool:intercept=false;

	new String:str[128];
	if (GetUserMessageType() != UM_Protobuf)
	{
		BfReadString(Handle:bf, str, sizeof(str), false);
	}
	else
	{
		PbReadString(bf, "text", str, sizeof(str));
	}

	//PrintToServer("[W3Hint] recieved \"%s\"",str);

	if(str[0]!=' '&&str[0]!='#')
	{
		intercept=true;
	}

	for (new i = 0; i < playersNum; i++)
	{
		if (players[i] != 0 && IsClientInGame(players[i]) && !IsFakeClient(players[i]))
		{
			War3_StopSound(players[i], SNDCHAN_STATIC, "UI/hint.wav");
			if (intercept)
			{
				W3Hint(players[i],HINT_NORMAL,4.0,str); //causes update
				//urgent update
				updatenextframe[players[i]]=true;
			}
		}
	}

	return (intercept) ? Plugin_Handled : Plugin_Continue;
}

public War3Source_000_Engine_Hint_OnGameFrame()
{
	if(MapChanging || War3SourcePause) return;

	for (new client = 1; client <= MaxClients; client++)
	{
		if (ValidPlayer(client,true)&&!IsFakeClient(client))
		{
			//this 0.3 resolution only affects expiry, does not delay new messages as that is signaled by updatenextframe
			static Float:lastshow[MAXPLAYERSCUSTOM];
			new Float:time = GetEngineTime();
			if (lastshow[client] < time-0.3 || updatenextframe[client])
			{
				updatenextframe[client]=false;
				lastshow[client]=time;
				decl String:output[128];
				output[0]=0;
				for (new W3HintPriority:priority=HINT_NORMAL; priority < HINT_SIZE; priority++)
				{
					new Handle:arr=objarray[client][priority];
					if (arr != INVALID_HANDLE)
					{
						new size=GetArraySize(arr);

						//DP("%d size %d",priority,size);
						if (size)
						{
							for (new arrindex=0;arrindex<size;arrindex+=2)
							{
								new Float:expiretime=GetArrayCell(arr,arrindex+1);
								if (time > expiretime)
								{
									//expired
									RemoveFromArray(arr, arrindex);
									RemoveFromArray(arr, arrindex); //new array shifted down, delete same position
									size=GetArraySize(arr); //resized
									arrindex-=2;					//rollback
									continue;
								}
								else
								{
									//then this did not expire, we can print
									new String:str[128];
									GetArrayString(arr,arrindex   ,str,sizeof(str));
									StrCat(output,sizeof(output),str);
									if(W3GetHintPriorityType(W3HintPriority:priority)!=HINT_TYPE_ALL) //PRINT ONLY 1
									{
										break;
									}
								}
							}
							if (size&&W3HintPriority:priority==HINT_NORMAL) //size may have changed when somethign expired
							{
								StrCat(output,sizeof(output)," \n");
							}
						}
					}
				}
				if(strlen(output)>1 /*&& strcmp(output," ")==-1 && strcmp(output,"  ")==-1*/)
				{
					War3_StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");

					new len=strlen(output);
					while (len>0 && (output[len-1]=='\n' || output[len-1]==' ' ))
					{
						len -= 1; //keep eating the last returns
						output[len] = '\0';
					}

					if (!StrEqual(lastoutput[client],output))
					{
						PrintHintText(client," %s",output); //NEED SPACE
					}
				}
				strcopy(lastoutput[client],sizeof(output),output);
			}
		}
	}
}
