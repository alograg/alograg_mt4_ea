/*-----------------------------------------------------------------+
|                                                   Alograg v3.mq4 |
|                                          Copyright 2017, Alograg |
|                                           https://www.alograg.me |
+-----------------------------------------------------------------*/
#define propVersion "3.00"
#define eaName "Alograg"
#define MagicNumber 17808159

#property copyright "Copyright 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict

#include "..\Include\OrderReliable_2011.01.07.mqh"
#include "..\Include\Utilities.mqh"

// Externos
// extern int pipsPerDay = 100;          //Meta de pips por dia

// Constantes
double pareto = 0.8;
double toDayMoney = 0.0;

/*-----------------------------------------------------------------+
| Expert initialization function                                   |
+-----------------------------------------------------------------*/
int OnInit() {
  GlobalVariableSet(eaName + "_block_profit", firstBalance * 0.2);
  initUtilsGlobals();
  EventSetTimer(60);
  return (INIT_SUCCEEDED);
}
/*-----------------------------------------------------------------+
| Expert deinitialization function                                 |
+-----------------------------------------------------------------*/
void OnDeinit(const int reason) {
  EventKillTimer();
  GlobalVariableDel(eaName + "_block_profit");
}
/*-----------------------------------------------------------------+
| Expert tick function                                             |
+-----------------------------------------------------------------*/
void OnTick() {
  if (IsTesting())
    doStrategies();
}
/*-----------------------------------------------------------------+
| Timer function                                                   |
+-----------------------------------------------------------------*/
void OnTimer() {}

void doStrategies() {}