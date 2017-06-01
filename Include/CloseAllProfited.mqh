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
    if (MathAbs(OrderOpenTime() - time0) <= (60 * 60 * 24 * 3))
      continue;
    iClosed +=
        CloseOneIfProfit(indexToClose, SELECT_BY_POS, NULL, false, minCents);
  }
  if (iClosed > 0)
    yesReset();
}

void CloseByProfited() {
  int Ticket_Sell, Ticket_Buy;
  string Symb = Symbol();
  double Hedg_Buy, Hedg_Sell;
  do {
    Hedg_Buy = -1.0;
    Hedg_Sell = -1.0;
    for (int i = 1; i <= OrdersTotal(); i++) {
      if (OrderSelect(i - 1, SELECT_BY_POS) == true) {
        if (OrderSymbol() != Symb)
          continue;
        int Tip = OrderType();
        if (Tip > 1)
          continue;
        switch (Tip) {
        case 0:
          if (OrderLots() > Hedg_Buy) {
            Hedg_Buy = OrderLots();
            Ticket_Buy = OrderTicket();
          }
          break;
        case 1:
          if (OrderLots() > Hedg_Sell) {
            Hedg_Sell = OrderLots();
            Ticket_Sell = OrderTicket();
          }
        }
      }
      if (Ticket_Buy && Ticket_Sell) {
        bool Ans = OrderCloseBy(Ticket_Buy, Ticket_Sell);
        yesReset();
      }
    }
  } while (Hedg_Buy > 0 && Hedg_Sell > 0);
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
  CloseByProfited();
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
void CloseAllOldProfitedByType(int type, double minCents = 0.03) {
  int TotalToClose = OrdersTotal(), iClosed = 0;
  for (int indexToClose = totalOrders - 1; 0 <= indexToClose; indexToClose--) {
    if (!OrderSelect(indexToClose, SELECT_BY_POS, MODE_TRADES))
      continue;
    if (MathAbs(OrderOpenTime() - time0) <= (60 * 60 * 24 * 3))
      continue;
    iClosed +=
        CloseOneIfProfit(indexToClose, SELECT_BY_POS, NULL, false, minCents);
  }
  if (iClosed > 0)
    yesReset();
}