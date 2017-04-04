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

void CloseAllProfited(string comment = NULL, bool force = false, double minCents = 0.08)
{
    int TotalToClose = OrdersTotal(), iClosed = 0;
    for (int indexToClose = totalOrders - 1; 0 <= indexToClose; indexToClose--)
    {
        iClosed += CloseOneIfProfit(indexToClose, SELECT_BY_POS, comment, force);
    }
    //if (IsTesting())
    //Print("Close: ", iClosed, " closed of ", TotalToClose);
}

int CloseOneIfProfit(int id, int by = SELECT_BY_POS, string comment = NULL, bool force = false, double minCents = 0.07)
{
    if (!OrderSelect(id, by))
        return 0;
    if (OrderSymbol() != Symbol())
        return 0;
        Print("is simbol: ", id);
    if (!isFornComment(comment, OrderComment()))
        return 0;
        Print("is comment: ", id);
    if (OrderTakeProfit() <= 0 && force)
        return 0;
        Print("hasProffit: ", id);
    int hasClose;
    double profit = NormalizeDouble(OrderProfit() + OrderCommission() + OrderSwap() - minCents, 2);
    if (profit > 0.01 || profit < maxLost)
    {
        Print("can close: ", id);
        if (OrderType() == OP_BUY)
        {
            if (!IsTesting())
                hasClose = OrderCloseReliable(OrderTicket(), OrderLots(), Bid, 4, White);
            else
                hasClose = OrderClose(OrderTicket(), OrderLots(), Bid, 4, White);
        }
        if (OrderType() == OP_SELL)
        {
            if (!IsTesting())
                hasClose = OrderCloseReliable(OrderTicket(), OrderLots(), Ask, 4, White);
            else
                hasClose = OrderClose(OrderTicket(), OrderLots(), Ask, 4, White);
        }
        
        return hasClose ? 1 : 0;
    }
    return 0;
}
