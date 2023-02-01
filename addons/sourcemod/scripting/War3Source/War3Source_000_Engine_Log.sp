public NW3Log(Handle:plugin,numParams)
{
	decl String:outstr[1000];

	FormatNativeString(0, 1, 2, sizeof(outstr), _, outstr);

	decl String:date[32];
	FormatTime(date, sizeof(date), "%c");
	Format(outstr, sizeof(outstr), "%s %s",date, outstr);

	PrintToServer("%s", outstr);
	WriteFileLine(hW3Log, outstr);
	FlushFile(hW3Log);
}

public NW3LogError(Handle:plugin,numParams)
{
	decl String:outstr[1000];

	FormatNativeString(0, 1, 2, sizeof(outstr), _, outstr);

	decl String:date[32];
	FormatTime(date, sizeof(date), "%c");
	Format(outstr,sizeof(outstr), "%s %s", date, outstr);

	PrintToServer("%s", outstr);
	WriteFileLine(hW3LogError, outstr);
	FlushFile(hW3LogError);
}

public NW3LogNotError(Handle:plugin,numParams)
{
	decl String:outstr[1000];

	FormatNativeString(0, 1, 2, sizeof(outstr), _, outstr);

	decl String:date[32];
	FormatTime(date, sizeof(date), "%c");
	Format(outstr, sizeof(outstr), "%s %s", date, outstr);

	PrintToServer("%s", outstr);
	WriteFileLine(hW3LogNotError, outstr);
	FlushFile(hW3LogNotError);
}

public NCreateWar3GlobalError(Handle:plugin, numParams)
{
	decl String:outstr[1000];

	FormatNativeString(0, 1, 2, sizeof(outstr), _, outstr);

	Call_StartForward(hGlobalErrorFwd);
	Call_PushString(outstr);
	Call_Finish(dummy);
}
