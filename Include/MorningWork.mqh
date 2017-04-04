/*-----------------------------------------------------------------+
|                                                   MorningWork.mqh |
|                                          Copyright 2017, Alograg |
|                                           https://www.alograg.me |
+-----------------------------------------------------------------*/

#property copyright "Copyright 2017, Alograg"
#property link "https://www.alograg.me"
#property version propVersion
#property strict

#include "Utilities.mqh"
#include "OrderReliable_2011.01.07.mqh"
#include "CloseAllProfited.mqh"

string MorningWorkComment = eaName + ": MorningWork";
int morningWorkOperations = -1;
int morningWorkOperationsType = NULL;
double morningWorkPoint = 0.0;
double morningWorkClose = 0.0;
double morningWorkStopLoss = 0.0;

void MorningWork()
{
    if (0 == morningWorkOperations || !CheckNewBar())
        return;
    if (morningWorkOperations > 0)
    {
        MorningWorkClose(morningWorkOperations);
        return;
    }
    int hour = TimeHour(Time[0]);
    if (hour >= 22)
        return;
    if (hour == 17)
    {
        morningWorkPoint = Close[1];
        return;
    }
    if (morningWorkPoint == 0)
        return;
    double Spread = MarketInfo(Symbol(), MODE_SPREAD) * Point,
           movePoints = (50 * Point);
    if (IsTesting())
        Print("MorningWork");
    if (Ask >= morningWorkPoint + movePoints)
    {
        MorningWorkOpen(OP_BUY);
    }
    else if (Bid <= morningWorkPoint - movePoints + Spread)
    {
        MorningWorkOpen(OP_SELL);
    }
    return;
}

void MorningWorkOpen(int type)
{
    double gls = getLotSize(2, 0.2);
    if (gls < 0.01)
        return;
    morningWorkOperationsType = type;
    if (OP_BUY == type)
    {
        morningWorkOperations = 0;
        if (!IsTesting())
            morningWorkOperations = OrderSendReliable(Symbol(), OP_BUY, gls, Ask, 3, 0, 0, MorningWorkComment, MagicNumber, 0, Blue);
        else
            morningWorkOperations = OrderSend(Symbol(), OP_BUY, gls, Ask, 3, 0, 0, MorningWorkComment, MagicNumber, 0, Blue);
        morningWorkClose = Ask + (25 * Point);
        morningWorkStopLoss = Ask - (25 * Point);
    }
    if (OP_SELL == type)
    {
        morningWorkOperations = 0;
        double Spread = MarketInfo(Symbol(), MODE_SPREAD) * Point;
        if (!IsTesting())
            morningWorkOperations = OrderSendReliable(Symbol(), OP_SELL, gls, Bid, 3, 0, 0, MorningWorkComment, MagicNumber, 0, Red);
        else
            morningWorkOperations = OrderSend(Symbol(), OP_SELL, gls, Bid, 3, 0, 0, MorningWorkComment, MagicNumber, 0, Red);
        morningWorkClose = Bid - (25 * Point) + Spread;
        morningWorkStopLoss = Bid + (25 * Point) + Spread;
    }
}

void MorningWorkClose(int ticket)
{
    bool stopLoss = false, close = false;
    int orderTicket = OrderSelect(ticket, SELECT_BY_TICKET);
    if (OP_BUY == morningWorkOperationsType)
    {
        stopLoss = Ask <= morningWorkStopLoss;
        close = Ask >= morningWorkClose;
        if (!stopLoss && close)
        {
            morningWorkClose += Point;
            morningWorkStopLoss = Ask - Point;
        }
    }
    if (OP_SELL == morningWorkOperationsType)
    {
        double Spread = MarketInfo(Symbol(), MODE_SPREAD) * Point;
        stopLoss = Bid >= morningWorkStopLoss;
        close = Bid <= morningWorkClose;
        if (!stopLoss && close)
        {
            //morningWorkClose += Point;
            //morningWorkStopLoss = Bid + Point + Spread;
        }
    }
    Print("MorningWork; ", close, " - ", stopLoss, " - ", Bid, " - ", morningWorkClose, " - ", morningWorkStopLoss);
    if (close)
    {
        if (CloseOneIfProfit(ticket, SELECT_BY_TICKET, MorningWorkComment, true))
        {
            morningWorkOperations = -1;
            //morningWorkPoint = 0;
        }
    }
}