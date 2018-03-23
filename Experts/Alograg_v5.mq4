/*--------------------------+
|            Alograg v5.mq4 |
| Copyright © 2018, Alograg |
|    https://www.alograg.me |
+--------------------------*/
#define propVersion "5.00"
#define eaName "Alograg"
#define MagicNumber 17808160
// Properties
#property copyright "Copyright © 2018, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Includes
#include <stderror.mqh>
#include <stdlib.mqh>
#include "..\Include\Tools.mqh"
#include "..\Include\Strategies.mqh"
#include "..\Include\TradeManager.mqh"
#include "..\Include\UnitTest.mqh"
// Parameters
extern bool strategiesActivate = FALSE; // Strategies Activate
// Constants
datetime lastUpdate;
/*----------------+
| Inicialización  |
+----------------*/
int OnInit()
{
  Print(eaName + " v." + propVersion);
  lastUpdate = Time[0];
  if (IsTradeAllowed())
    SendNotification(eaName + " v." + propVersion + " INICIALIZADO");
  // Registro de evento
  EventSetTimer(30);
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
void OnTick()
{
  doReport();
  doManagment();
  doStrategies();
  if (IsTesting())
    doTest();
  setLatsPeriods();
}
/*----------+
| Reporta   |
+----------*/
void doReport()
{
  if (isNewBar(PERIOD_D1))
    SendAccountReport();
  if (isNewBar(PERIOD_M1))
    SendSimbolParams();
}
/*--------------+
| Para pruebas  |
+--------------*/
void doTest()
{
  orderOn(StringToTime("2017.08.01 17:45"), 0.01);
  // closeOrderOn(StringToTime("2017.02.24 08:40"), 104);
  if (isNewBar(PERIOD_W1))
  {
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
void doStrategies()
{
  if (!strategiesActivate || moneyOnRisk())
    return;
  if (IsTradeAllowed())
    strategiesEvent();
}
