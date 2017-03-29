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
#include "..\Include\FreeDayNigth.mqh"

// Externos
extern int pipsPerDay = 100;       //Meta de pips por dia
extern double moneyPerDay = 150.0; //Meta de pips por dia

double toDayMoney = 0.0;

/*-----------------------------------------------------------------+
| Expert initialization function                                   |
+-----------------------------------------------------------------*/
int OnInit()
{
    initUtilsGlobals();
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
    if (IsTesting())
        doStrategies();
}
/*-----------------------------------------------------------------+
| Timer function                                                   |
+-----------------------------------------------------------------*/
void OnTimer()
{
    if (isNewDay() && !IsTesting())
        SendReport();
    if (!IsTesting())
        doStrategies();
}

void doStrategies()
{
    Gap();
    FreeDayNigth();
}