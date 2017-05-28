/*-----------------------------------------------------------------+
|                                                   WeekendGap.mqh |
|                                          Copyright 2017, Alograg |
|                                           https://www.alograg.me |
+-----------------------------------------------------------------*/

#property copyright "Copyright 2017, Alograg"
#property link "https://www.alograg.me"
#property version propVersion
#property strict

#include "Utilities.mqh"
#include "OrderReliable_2011.01.07.mqh"

void CloseAllProfited(string comment = NULL, bool force = false,
                      double minCents = 0.08) {
  int TotalToClose = OrdersTotal(), iClosed = 0;
  for (int indexToClose = totalOrders - 1; 0 <= indexToClose; indexToClose--) {
    iClosed += CloseOneIfProfit(indexToClose, SELECT_BY_POS, comment, force);
  }
  // if (IsTesting())
  // PrintLog("Close: ", iClosed, " closed of ", TotalToClose);
}

void CloseAllOldProfited(double minCents = 0.03) {
  int TotalToClose = OrdersTotal(), iClosed = 0;
  for (int indexToClose = totalOrders - 1; 0 <= indexToClose; indexToClose--) {
    if (!OrderSelect(indexToClose, SELECT_BY_POS, MODE_TRADES))
      continue;
    if (MathAbs(OrderOpenTime() - time0) <= (60 * 60 * 24))
      continue;
    iClosed +=
        CloseOneIfProfit(indexToClose, SELECT_BY_POS, NULL, false, minCents);
  }
  if (iClosed > 0)
    yesReset();
}

void CloseByProfited() {
  //--------------------------------------------------------------- 2 --
  while (true)                               // Processing cycle..
  {                                          // ..of opposite orders
    double Hedg_Buy = -1.0;                  // Max. cost of Buy
    double Hedg_Sell = -1.0;                 // Max. cost of Sell
    for (int i = 1; i <= OrdersTotal(); i++) // Order searching cycle
    {
      if (OrderSelect(i - 1, SELECT_BY_POS) == true) // If the next is available
      {                                              // Order analysis:
        //--------------------------------------------------- 3 --
        if (OrderSymbol() != Symb)
          continue;            // Symbol is not ours
        int Tip = OrderType(); // Order type
        if (Tip > 1)
          continue; // Pending order
        //--------------------------------------------------- 4 --
        switch (Tip) // By order type
        {
        case 0: // Order Buy
          if (OrderLots() > Hedg_Buy) {
            Hedg_Buy = OrderLots(); // Choose the max. cost
            int Ticket_Buy = OrderTicket(); // Order ticket
          }
          break; // From switch
        case 1:  // Order Sell
          if (OrderLots() > Hedg_Sell) {
            Hedg_Sell = OrderLots(); // Choose the max. cost
            int Ticket_Sell = OrderTicket(); // Order ticket
          }
        } // End of 'switch'
      } // End of order analysis
    } // End of order searching
    //--------------------------------------------------------- 5 --
    if (Hedg_Buy < 0 || Hedg_Sell < 0)            // If no order available..
    {                                             // ..of some type
      Alert("All opposite orders are closed :)"); // Message
      return;                                     // Exit start()
    }
    //--------------------------------------------------------- 6 --
    while (true) // Closing cycle
    {
      //------------------------------------------------------ 7 --
      Alert("Attempt to close by. Awaiting response..");
      bool Ans = OrderCloseBy(Ticket_Buy, Ticket_Sell); // Закрытие
      //------------------------------------------------------ 8 --
      if (Ans == true) // Got it! :)
      {
        Alert("Performed closing by.");
        break; // Exit closing cycle
      }
      //------------------------------------------------------ 9 --
      int Error = GetLastError(); // Failed :(
      switch (Error)              // Overcomable errors
      {
      case 4:
        Alert("Trade server is busy. Retrying..");
        Sleep(3000); // Simple solution
        continue;    // At the next iteration
      case 137:
        Alert("Broker is busy. Retrying..");
        Sleep(3000); // Simple solution
        continue;    // At the next iteration
      case 146:
        Alert("Trading subsystem is busy. Retrying..");
        Sleep(500); // Simple solution
        continue;   // At the next iteration
      }
      switch (Error) // Critical errors
      {
      case 2:
        Alert("Common error.");
        break; // Exit 'switch'
      case 64:
        Alert("Account is blocked.");
        break; // Exit 'switch'
      case 133:
        Alert("Trading is prohibited");
        break; // Exit 'switch'
      case 139:
        Alert("The order is blocked and is being processed");
        break; // Exit 'switch'
      case 145:
        Alert("Modification is prohibited. ",
              "The order is too close to market");
        break; // Exit 'switch'
      default:
        Alert("Occurred error ", Error); // Other alternatives
      }
      Alert("The script has finished operations --------------------------");
      return; // Exit start()
    }
  } // End of the processing cycle
  //-------------------------------------------------------------- 10 --
}

int CloseOneIfProfit(int id, int by = SELECT_BY_POS, string comment = NULL,
                     bool force = false, double minCents = 0.07) {
  if (!OrderSelect(id, by))
    return 0;
  if (OrderSymbol() != Symbol())
    return 0;
  if (!isFornComment(comment, OrderComment()))
    return 0;
  if (OrderTakeProfit() <= 0 && force)
    return 0;
  int hasClose;
  double profit = NormalizeDouble(
      OrderProfit() + OrderCommission() + OrderSwap() - minCents, 2);
  if (profit > 0.01) {
    if (OrderType() == OP_BUY) {
      hasClose = OrderCloseReliable(OrderTicket(), OrderLots(), Bid, 4, White);
    }
    if (OrderType() == OP_SELL) {
      hasClose = OrderCloseReliable(OrderTicket(), OrderLots(), Ask, 4, White);
    }

    return hasClose ? 1 : 0;
  }
  return 0;
}

void CloseAll(string comment = NULL) {
  int TotalToClose = OrdersTotal(), iClosed = 0, hasClose = 0;
  for (int indexToClose = totalOrders - 1; 0 <= indexToClose; indexToClose--) {
    if (OrderSymbol() != Symbol() && !isFornComment(comment, OrderComment()))
      continue;
    if (OrderType() == OP_BUY) {
      hasClose = OrderCloseReliable(OrderTicket(), OrderLots(), Bid, 4, White);
    }
    if (OrderType() == OP_SELL) {
      hasClose = OrderCloseReliable(OrderTicket(), OrderLots(), Ask, 4, White);
    }
  }
}
