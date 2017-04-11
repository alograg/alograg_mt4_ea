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
    if (hour == 17 && morningWorkPoint == 0)
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
        morningWorkClose = Ask + (25 * Point);
        morningWorkStopLoss = Ask - (25 * Point);
        morningWorkOperations = OrderSendReliable(Symbol(), OP_BUY, gls, Ask, 3, 0, 0, MorningWorkComment, MagicNumber, 0, Blue);
    }
    if (OP_SELL == type)
    {
        morningWorkOperations = 0;
        double Spread = MarketInfo(Symbol(), MODE_SPREAD) * Point;
        morningWorkClose = NormalizeDouble(Bid - (25 * Point), Digits);
        morningWorkStopLoss = NormalizeDouble(Bid + (25 * Point), Digits);
        morningWorkOperations = OrderSendReliable(Symbol(), OP_SELL, gls*0.2, Bid, 3, 0, 0, MorningWorkComment, MagicNumber, 0, Red);
    }
}

void MorningWorkClose(int ticket)
{
    bool stopLoss = false, close = false;
    int orderTicket;
    if (OP_BUY == morningWorkOperationsType)
    {
        stopLoss = Ask <= morningWorkStopLoss;
        close = Ask >= morningWorkClose;
    }
    if (OP_SELL == morningWorkOperationsType)
    {
        double Spread = MarketInfo(Symbol(), MODE_SPREAD) * Point;
        stopLoss = Bid >= morningWorkStopLoss;
        close = Bid <= morningWorkClose;
    }
    if (close)
    {
        if (CloseOneIfProfit(ticket, SELECT_BY_TICKET, MorningWorkComment))
        {
            morningWorkOperations = -1;
            morningWorkPoint = 0.0;
        }
    }
    /*else
    {
        orderTicket = OrderSelect(ticket, SELECT_BY_TICKET);
        if (TimeDayOfYear(OrderOpenTime()) < TimeDayOfYear(Time[0]))
        {
            if (OrderType() == OP_BUY)
            {
                close = OrderCloseReliable(ticket, OrderLots(), Bid, 4, White);
            }
            if (OrderType() == OP_SELL)
            {
                close = OrderCloseReliable(ticket, OrderLots(), Ask, 4, White);
            }
            morningWorkOperations = -1;
            morningWorkPoint = 0.0;
        }
    }*/
}