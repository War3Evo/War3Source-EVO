/**
 * Check if Ward Location is not allowed
 *
 * @param client			Player's index.
 * @return 					boolean: 1 (or true) if not allowed
 */
native War3_WardLocationNotAllowed(client);

/**
 * Check if location is in spawn area
 *
 * @param client				client index.
 * @param oldstylechecking		will first check using new method, then check using formulas.
 * 								if set to false, it will use the native function only.
 * ** old style:
 * @param client				put 0 if using old style only, otherwise it will check the client
 * 								using the new method that checks using "func_respawnroom"
 * @param pos					Location check (pos[3])
 * @param checkZ				set to 1 to check z axis (default 1)
 * @return 						1 (or true) if is in spawn
 */
native War3_IsInSpawn(client,bool:oldstylechecking=false,Float:pos[3]={0.0,0.0,0.0},checkZ=1);

/**
 * team change LastChangeTeamTime
 * @param client: 			The client's index.
 * @param InSpawn: 			true if client is in spawn\
 * @param spawnEntity: 		enity of Spawn
 */
forward void OnW3InSpawn(int iClient,bool InSpawn,int spawnEntity);
