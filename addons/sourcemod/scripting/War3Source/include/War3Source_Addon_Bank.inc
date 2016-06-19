//enum W3Bank
//{
	//gold,
	//timeStamp,
//}

//native W3SetBankProp(client,W3HackerProp:property,any:value);
//native any:W3GetBankProp(client,W3HackerProp:property);

//native War3_Bank_Force_Withdraw(client,amount,tomecount=0);

//native War3_Bank_Deposit(client,amount);

/**
 * No checks made to "client" make your own validation checks
 * @return: none
 */
forward OnWar3_BANK_PlayerLoadData(client);

native War3_BankWithdrawTimeLeft(client,String:TimeLeft[],maxlen);

native bool:War3_BankCanWithdraw(client);

// Checks to see if player has enough gold to deposit,
// if they do, it adds gold to their bank and removes gold from their hand.
// if they do not have enough, it will reply to them they don't have enough.
//(i may need to remove the reply later or make it where it can be toggled off on the reply)
native bool:War3_DepositGoldBank(client,Amount=0);

native bool:War3_WithdrawGoldBank(client,Amount=0,bool:Bypass=false);

native War3_SetGoldBank(client,Amount=0);

native War3_GetGoldBank(client);
