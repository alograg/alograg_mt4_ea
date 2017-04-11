//+------------------------------------------------------------------+
//|                                                 Equity-guard.mq4 |
//|                      Copyright © 2011, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Mohan Copyright © 2012, use it at your own risk"
#property link "http://www.forexfactory.com/mohan76"

extern string ea = "close all trrade if equity below daily or hardlimimit";

extern double daily_quota = 100;
extern double secure_Min_balance = 19000;
double todaybalance;
int oldday, force;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init() {
  //----

  //----
  return (0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit() {
  //----

  //----
  return (0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start() {
  //----

  if (AccountEquity() <= secure_Min_balance) {
    CloseAll();
  }
  int dow = Day();
  if (oldday != dow) {
    todaybalance = AccountEquity();
    oldday = dow;
    force = 1;
    SendMail("Daily Balance ",
             StringConcatenate("Equity : ", AccountEquity(), "Daily Level ",
                               todaybalance - daily_quota, "All time Level :",
                               secure_Min_balance));
  }
  if (AccountEquity() <= (todaybalance - daily_quota)) {
    CloseAll();
  }

  Comment("Equity : ", AccountEquity(), " Daily Level : ",
          (todaybalance - daily_quota), " All time Level : ",
          secure_Min_balance);
  //----
  return (0);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CloseAll                                                         |
//+------------------------------------------------------------------+
void CloseAll() {

  for (int i = OrdersTotal() - 1; i >= 0; i--) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) {
      continue;
    }

    while (IsTradeContextBusy()) {
      Sleep(10);
    }

    RefreshRates();
    //     double SymAsk = NormalizeDouble( MarketInfo( Sym, MODE_ASK ),
    // SymDigits );
    //    double SymBid = NormalizeDouble( MarketInfo( Sym, MODE_BID ),
    // SymDigits );

    if (OrderType() == OP_BUY) {
      OrderClose(OrderTicket(), OrderLots(), Bid, 0, CLR_NONE);
    } else if (OrderType() == OP_SELL) {
      OrderClose(OrderTicket(), OrderLots(), Ask, 0, CLR_NONE);
    }

    int Err = GetLastError();
  }
  if (force > 0) {
    SendMail("Force Close ",
             StringConcatenate("Equity : ", AccountEquity(), " Daily Level: ",
                               todaybalance - daily_quota, " All time Level : ",
                               secure_Min_balance));
    force = 0;
  }
}
//+------------------------------------------------------------------+
