/*--------------------------+
|            Alograg v4.mq4 |
| Copyright © 2017, Alograg |
|    https://www.alograg.me |
+--------------------------*/
#define propVersion "4.19"
#define eaName "Alograg"
#define MagicNumber 17808160
// Properties
#property copyright "Copyright © 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Includes
#include "..\Include\Strategies.mqh"
#include "..\Include\Tools.mqh"
#include "..\Include\TradeManager.mqh"
#include "..\Include\UnitTest.mqh"
#include <stderror.mqh>
#include <stdlib.mqh>
// Parameters
extern bool strategiesActivate = FALSE; // Strategies Activate
// Constants
/*----------------+
| Inicialización  |
+----------------*/
int OnInit() {
  Print(eaName + " v." + propVersion);
  if (IsTradeAllowed())
    SendNotification(eaName + " v." + propVersion + " INICIALIZADO");
  // Registro de evento
  AccountInvestment();
  EventSetTimer(60 * 60 * 12);
  setLatsPeriods();
  tmInit();
  // strategiesInit();
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
  AccountInvestment();
  if (isNewBar(PERIOD_D1))
    SendAccountReport();
  if (isNewBar(PERIOD_M1))
    SendSimbolParams();
}
/*--------------+
| Para pruebas  |
+--------------*/
void doTest() {
  // orderOn(StringToTime("2017.03.24 18:20"), getLotSize());
  // closeOrderOn(StringToTime("2017.02.24 08:40"), 104);
  if (isNewBar(PERIOD_D1)) {
    // doWithdrawal(10);
    Print("deposit: ", deposit);
    Print("withdrawal: ", withdrawal);
    Print("investment: ", investment);
    Print("AccountInvestment: ", AccountInvestment());
    Print("AccountEquity: ", AccountEquity());
    Print("AccountBalance: ", AccountBalance());
    Print("AccountMargin: ", AccountMargin());
    Print("AccountMoneyToInvestment: ", AccountMoneyToInvestment());
    Print("getLotSize: ", getLotSize());
  }
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
