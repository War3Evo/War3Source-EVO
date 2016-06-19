//=============================================================================
// War3Source SQL Functions
//=============================================================================

/// General callback for threaded queries.  No Actions
public void SQLWar3GeneralCallback(Handle owner, Handle hndl, const char[] error, StringMap data)
{
	SQLCheckForErrors(hndl,error,"SQLWar3GeneralCallback",data);
}

//pass me a trie with key "query" = your query into originalqueryTrie
stock void SQLCheckForErrors(Handle hndl,const char[] originalerror,const char prependstr[]="", StringMap originalqueryTrie) {
	char orignalquerystr[512];
	if(!originalqueryTrie.GetString("query",STRING(orignalquerystr)))
	{
		LogError("SQLCheckForErrors: originalqueryTrie is not null but key 'query' not set from trie");
		//DP("closed");
	}

	if(!StrEqual("", originalerror))
	{
		LogError("SQL error: [%s] %s QUERY:%s", prependstr, originalerror,orignalquerystr);
	}
	else if(hndl == null)
	{
		char err[512];
		SQL_GetError(hndl, err, sizeof(err));
		LogError("SQLCheckForErrors: [%s] %s QUERY:%s", prependstr, err,orignalquerystr);
	}
}

public bool:SQL_FastQueryLogOnError(Handle:DB,const String:query[]) {
	if(!SQL_FastQuery(DB,query)) {
		new String:error[256];
		SQL_GetError(DB, error, sizeof(error));
		LogError("SQLFastQuery %s failed, Error: %s",query,error);
		return false;
	}
	return true;
}

//normal query like SQL_QUERY, database must be locked
stock bool:SQL_War3_NormalQuery(Handle:DB,String:querystr[]) {
	new Handle:result= SQL_Query(DB, querystr);
	if(result==INVALID_HANDLE) {
		new String:error[256];
		SQL_GetError(DB, error, sizeof(error));
		LogError("SQL_War3_NormalQuery %s failed, Error: %s",querystr,error);
		return false;
	}
	else {
		CloseHandle(result);
	}
	return true;
}
//fetch using column string
stock W3SQLPlayerInt(Handle:query,const String:columnname[]) //fech from query
{
	new column;
	SQL_FieldNameToNum(query,columnname,column);
	decl String:result[16];
	SQL_FetchString(query,column,result,sizeof(result));
	return StringToInt(result);
}
//fetch using column string
stock W3SQLPlayerFloat(Handle:query,const String:columnname[]) //fech from query
{
	new column;
	SQL_FieldNameToNum(query,columnname,column);
	decl String:result[16];
	SQL_FetchString(query,column,result,sizeof(result));
	return StringToFloat(result);
}
//fetch using column string
stock W3SQLPlayerString(Handle:query,const String:columnname[],String:out_buffer[],size_out) //fech from query
{
	new column;
	if(SQL_FieldNameToNum(query,columnname,column))
	{
		SQL_FetchString(query,column,out_buffer,size_out);
		return true;
	}
	return false;
}

stock bool:W3SQL_ISNULL(Handle:query,const String:columnname[]) //fech from query
{
	new column;
	SQL_FieldNameToNum(query,columnname,column);
	return SQL_IsFieldNull(query,column);
}
///add a column to table, be careful of parameters
///table should be locked!!!
stock AddColumn(Handle:DB,const String:columnname[],const String:datatype[],const String:table_name[])
{
	decl String:query[256];
	Format(query,256,"ALTER TABLE %s ADD COLUMN %s %s DEFAULT '0'",table_name,columnname,datatype);
	PrintToServer("[War3Source:EVO] Tried to ADD column in TABLE %s: %s",table_name,columnname);
	SQL_FastQueryLogOnError(DB,query);
}

///string?
