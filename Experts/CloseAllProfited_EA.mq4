//+------------------------------------------------------------------+
//|                                          CloseAllProfited_EA.mq4 |
//|                                          Copyright 2017, Alograg |
//|                                           https://www.alograg.me |
//+------------------------------------------------------------------+
#define propVersion "1.07"

#property copyright "Copyright 2017, Alograg"
#property link "https://www.alograg.me"
#property version propVersion
#property strict

string lastCleanLabel;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
  //---
  Print("Close Start");
  lastCleanLabel =
      StringFormat("%i_%s_%d_LastClear", AccountNumber(), Symbol(), Period());
  GlobalVariableSet(lastCleanLabel, TimeHour(Time[0]));
  //---
  return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
  //---
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTick() {
  if (NewDayBar())
    return;
  int TotalToClose = OrdersTotal(), hasClose, iClosed = 0;
  double profit;
  for (int indexToClose = TotalToClose - 1; 0 <= indexToClose; indexToClose--) {
    if (!OrderSelect(indexToClose, SELECT_BY_POS))
      continue;
    profit = NormalizeDouble(
        OrderProfit() + OrderCommission() + OrderSwap() - 0.07, 2);
    if (OrderSymbol() == Symbol()) {
      if (OrderType() == OP_BUY && profit > 0) {
        hasClose = OrderClose(OrderTicket(), OrderLots(), Bid, 4, White);
      }
      if (OrderType() == OP_SELL && profit > 0) {
        hasClose = OrderClose(OrderTicket(), OrderLots(), Ask, 4, White);
      }
      iClosed += hasClose ? 1 : 0;
      // Print(OrderTicket(), OrderType(), ": ", profit);
    }
  }
  Comment("v", propVersion, " - Cleaner\n", iClosed, " closed of ",
          TotalToClose);
}
//+------------------------------------------------------------------+
//| New Bar                                                          |
//+------------------------------------------------------------------+
bool NewDayBar() {
  lastCleanLabel =
      StringFormat("%i_%s_%d_LastClear", AccountNumber(), Symbol(), Period());
  double lastClean = GlobalVariableGet(lastCleanLabel);
  double toDay = TimeHour(Time[0]);
  if (lastClean != toDay) {
    GlobalVariableSet(lastCleanLabel, toDay);
    return true;
  }
  return false;
}