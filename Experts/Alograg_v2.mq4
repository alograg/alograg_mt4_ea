/*-----------------------------------------------------------------+
|                                                   Alograg v2.mq4 |
|                                          Copyright 2017, Alograg |
|                                           https://www.alograg.me |
+-----------------------------------------------------------------*/
#define propVersion "2.00"
#define eaName "Alograg"
#define MagicNumber 17808158

#property copyright "Copyright 2017, Alograg"
#property link "https://www.alograg.me"
#property version propVersion
#property strict

#include "..\Include\OrderReliable_2011.01.07.mqh"
#include "..\Include\WeekEndGap.mqh"
#include "..\Include\CorissingMad.mqh"

/*-----------------------------------------------------------------+
| Expert initialization function                                   |
+-----------------------------------------------------------------*/
int OnInit()
{
    totalOrders = OrdersTotal();
    EventSetTimer(60);
    return (INIT_SUCCEEDED);
}
/*-----------------------------------------------------------------+
| Expert deinitialization function                                 |
+-----------------------------------------------------------------*/
void OnDeinit(const int reason)
{
    EventKillTimer();
}
/*-----------------------------------------------------------------+
| Expert tick function                                             |
+-----------------------------------------------------------------*/
void OnTick()
{
    totalOrders = OrdersTotal();
    if (IsTesting()) {
        Crossing();
        Gap();
    }
}
/*-----------------------------------------------------------------+
| Timer function                                                   |
+-----------------------------------------------------------------*/
void OnTimer()
{
    if (!IsTesting()) {
        Crossing();
        Gap();
    }
}
