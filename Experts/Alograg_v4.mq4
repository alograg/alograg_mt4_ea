/*--------------------------+
|            Alograg v4.mq4 |
| Copyright © 2017, Alograg |
|    https://www.alograg.me |
+--------------------------*/
#define propVersion "4.00"
#define eaName "Alograg"
#define MagicNumber 17808160
// Properties
#property copyright "Copyright © 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Includes
#include <stdlib.mqh>
#include <stderror.mqh>
#include "..\Include\Tools.mqh"
#include "..\Include\TradeManager.mqh"
#include "..\Include\Strategies.mqh"
// Parameters
extern bool strategiesActivate = FALSE; // Strategies Activate
// Constants
int doError[];
/*----------------+
| Inicialización  |
+----------------*/
int OnInit() {
  // Registro de evento
  EventSetTimer(60 * 60 * 12);
  isNewBar();
  tmInit();
  strategiesInit();
  return (INIT_SUCCEEDED);
}
/*--------+
| Cierre  |
+--------*/
void OnDeinit(const int reason) { EventKillTimer(); }
/*-----------+
| Cada dato  |
+-----------*/
void OnTick() {
  doStrategies();
  //doManagment();
  Print(isNewBar(PERIOD_M1));
  Print(isNewBar(PERIOD_M1));
  if(isNewBar(PERIOD_M1))
  doError[1];
  Print(isNewBar(PERIOD_M1));
  isNewBar();
  Print(isNewBar(PERIOD_M1));
}
/*----------+
| Al timer  |
+----------*/
void OnTimer() {}
/*-------------------------+
| Ejecuta las estrategias  |
+-------------------------*/
void doStrategies() {
  Print("Evaluando PERIOD_D1 " + isNewBar(PERIOD_D1));
  if (!strategiesActivate || moneyOnRisk())
    return;
  strategiesEvent();
}
/*----------------------------+
| Administra las operaciones  |
+----------------------------*/
void doManagment() { tmEvent(); }