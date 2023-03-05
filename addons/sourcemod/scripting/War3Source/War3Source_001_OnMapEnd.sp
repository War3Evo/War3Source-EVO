// War3Source_001_OnMapEnd
// moved from War3Source.sp

// TRANSLATED

//=============================================================================
// OnMapEnd
//=============================================================================

public OnMapEnd()
{
	PrintToServer("[War3Source:EVO] %t","MapChanging = true");
	MapChanging = true;
	War3Source_Engine_Download_Control_OnMapEnd();
	War3Source_003_RegisterPrivateForwards_OnMapEnd();
}
