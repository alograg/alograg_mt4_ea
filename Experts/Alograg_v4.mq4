/*--------------------------+
|            Alograg v4.mq4 |
| Copyright © 2017, Alograg |
|    https://www.alograg.me |
+--------------------------*/
#define propVersion "4.12"
#define eaName "Alograg"
#define MagicNumber 17808160
// Properties
#property copyright "Copyright © 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Includes
#include <stderror.mqh>
#include <stdlib.mqh>
#include "..\Include\Strategies.mqh"
#include "..\Include\Tools.mqh"
#include "..\Include\TradeManager.mqh"
#include "..\Include\UnitTest.mqh"
// Parameters
extern bool strategiesActivate = FALSE; // Strategies Activate
// Constants
/*----------------+
| Inicialización  |
+----------------*/
int OnInit() {
  Print(eaName + " v." + propVersion);
  // Registro de evento
  EventSetTimer(60 * 60 * 12);
  if (!countPeriods) {
    ENUM_TIMEFRAMES periodList;
    countPeriods = EnumToArray(periodList, allPeriods, PERIOD_M1, PERIOD_D1);
  }
  setLatsPeriods();
  tmInit();
  strategiesInit();
  return (INIT_SUCCEEDED);
}
/*--------+
| Cierre  |
+--------*/
void OnDeinit(const int reason) { EventKillTimer(); }
/*----------+
| Al timer  |
+----------*/
void OnTimer() {}
/*-----------+
| Cada dato  |
+-----------*/
void OnTick() {
  doReport();
  if (IsTesting())
    doTest();
  doManagment();
  doStrategies();
  setLatsPeriods();
}
/*----------+
| Reporta   |
+----------*/
void doReport() {
  if (isNewBar(PERIOD_D1))
    SendAccountReport();
  if (isNewBar(PERIOD_M1))
    SendSimbolParams();
}
/*--------------+
| Para pruebas  |
+--------------*/
void doTest() {
  // orderOn(StringToTime("2017.02.24 18:20"), getLotSize());
}
/*----------------------------+
| Administra las operaciones  |
+----------------------------*/
void doManagment() { tmEvent(); }
/*-------------------------+
| Ejecuta las estrategias  |
+-------------------------*/
void doStrategies() {
  if (!strategiesActivate || moneyOnRisk())
    return;
  if (IsTradeAllowed())
    strategiesEvent();
}
