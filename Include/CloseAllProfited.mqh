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

void CloseAllProfited(string comment = NULL, bool force = false, double minCents = 0.07)
{
    int TotalToClose = OrdersTotal(), hasClose, iClosed = 0;
    double profit;
    for (int indexToClose = totalOrders - 1; 0 <= indexToClose; indexToClose--)
    {
        if (!OrderSelect(indexToClose, SELECT_BY_POS))
            continue;
        if (OrderTakeProfit() != 0 && !force)
            continue;
        profit = NormalizeDouble(OrderProfit() + OrderCommission() + OrderSwap() - minCents, 2);
        if (OrderSymbol() == Symbol() && isFornComment(comment, OrderComment()) && (profit > 0.01 || profit < (firstBalance * -0.5)))
        {
            if (OrderType() == OP_BUY)
            {
                hasClose = OrderCloseReliable(OrderTicket(), OrderLots(), Bid, 4, White);
            }
            if (OrderType() == OP_SELL)
            {
                hasClose = OrderCloseReliable(OrderTicket(), OrderLots(), Ask, 4, White);
            }
            iClosed += hasClose ? 1 : 0;
        }
    }
    //if (IsTesting())
    //Print("Close: ", iClosed, " closed of ", TotalToClose);
}
