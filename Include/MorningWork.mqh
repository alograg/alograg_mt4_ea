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

string MorningWorkSellComment = eaName + ": MorningWork";
int morningWorkOperations = 0;
int morningWorkOperationsType = NULL;
double morningWorkPoint = 0.0;
double morningWorkClose = 0.0;
double morningWorkStopLoss = 0.0;

void MorningWork()
{
    Print("morningWorkOperations: ", morningWorkOperations);
    if (morningWorkOperations > 0)
    {
        MorningWorkClose(morningWorkOperations);
        return;
    }
    int hour = TimeHour(Time[0]);
    if (hour >= 22)
        return;
    if (hour == 5 || hour == 17)
        morningWorkPoint = Close[0];
    if (morningWorkPoint == 0)
        return;
    double Spread = MarketInfo(Symbol(), MODE_SPREAD) * Point;
    if (Ask + (25 * Point) >= morningWorkPoint)
        MorningWorkOpen(OP_BUY);
    if (Bid + (25 * Point) + Spread >= morningWorkPoint)
        MorningWorkOpen(OP_SELL);
    return;
}

void MorningWorkOpen(int type)
{
    double gls = getLotSize(2, 0.2);
    if (gls < 0.01)
        return;
    if (IsTesting())
        Print("MorningWork");
    morningWorkOperationsType = type;
    if (OP_BUY == type)
    {
        morningWorkOperations = OrderSendReliable(Symbol(), OP_BUY, gls, Ask, 3, 0, 0, MorningWorkSellComment, MagicNumber, 0, Blue);
        morningWorkClose = Ask + (25 * Point);
        morningWorkStopLoss = Ask - (25 * Point);
    }
    if (OP_SELL == type)
    {
        double Spread = MarketInfo(Symbol(), MODE_SPREAD) * Point;
        morningWorkOperations = OrderSendReliable(Symbol(), OP_SELL, gls, Bid, 3, 0, 0, MorningWorkSellComment, MagicNumber, 0, Red);
        morningWorkClose = Bid - (25 * Point) + Spread;
        morningWorkStopLoss = Bid + (25 * Point) + Spread;
    }
}

void MorningWorkClose(int ticket)
{
    if (NULL == morningWorkOperationsType)
        return;
    bool stopLoss = false, close = false;
    if (OP_BUY == morningWorkOperationsType)
    {
        stopLoss = Ask <= morningWorkStopLoss;
        close = Ask >= morningWorkClose;
        if (!stopLoss && close)
        {
            morningWorkClose = Ask + Point;
            morningWorkStopLoss = Ask - Point;
            close = false;
        }
    }
    if (OP_SELL == morningWorkOperationsType)
    {
        stopLoss = Bid <= morningWorkStopLoss;
        close = Bid >= morningWorkClose;
        if (!stopLoss && close)
        {
            morningWorkClose = Bid - Point;
            morningWorkStopLoss = Bid - Point;
            close = false;
        }
    }
    if (stopLoss)
        CloseOneIfProfit(morningWorkOperations, SELECT_BY_TICKET);
    morningWorkOperations = 0;
}