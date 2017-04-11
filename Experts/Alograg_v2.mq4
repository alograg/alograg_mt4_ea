/*-----------------------------------------------------------------+
|                                                   Alograg v2.mq4 |
|                                          Copyright 2017, Alograg |
|                                           https://www.alograg.me |
+-----------------------------------------------------------------*/
#define propVersion "2.01"
#define eaName "Alograg"
#define MagicNumber 17808158

#property copyright "Copyright 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict

#include "..\Include\OrderReliable_2011.01.07.mqh"
#include "..\Include\Utilities.mqh"
#include "..\Include\WeekEndGap.mqh"
#include "..\Include\FreeDayNigth.mqh"
#include "..\Include\SummaryReport.mqh"
//#include "..\Include\MorningWork.mqh"
#include "..\Include\Alograg_v2_tester.mqh"

// Externos
extern int pipsPerDay = 100; // Meta de pips por dia
extern double moneyPerDay = 150.0; // Meta de pips por dia
extern double firstBalance = 1000.00; // Inversion inicial

// Constantes
double pareto = 0.8;
double toDayMoney = 0.0;

/*-----------------------------------------------------------------+
| Expert initialization function                                   |
+-----------------------------------------------------------------*/
<< << << < HEAD int OnInit() {
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
  if (IsTesting()) {
    doStrategies();
    // CloseAllProfited(eaName + "-641075158");
  }
}
/*-----------------------------------------------------------------+
| Timer function                                                   |
+-----------------------------------------------------------------*/
void OnTimer() {
  if (isNewDay() && !IsTesting())
    SendReport();
  if (!IsTesting())
    doStrategies();
}

void doStrategies() {
  Gap();
  FreeDayNigth();
  initUtilsGlobals();
}