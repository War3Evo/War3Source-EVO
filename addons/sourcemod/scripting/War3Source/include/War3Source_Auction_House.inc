// War3Source_Auction_House.inc

/**
 * Reserved Gold
 *
 * @param client			Player's index.
 * @return 					how much reserved gold they have
 */
native War3_ReservedGold(client);

public SharedPlugin:__pl_W3AuctionHouse =
{
	name = "W3AuctionHouse",
	file = "War3Source_Addon_Auction_House.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_W3AuctionHouse_SetNTVOptional()
{
	MarkNativeAsOptional("War3_ReservedGold");
}
#endif
