/*--------------------------+
|            Alograg v4.mq4 |
| Copyright © 2017, Alograg |
|    https://www.alograg.me |
+--------------------------*/
#define propVersion "4.02"
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
  doManagment();
  isNewBar();
}
/*----------+
| Al timer  |
+----------*/
void OnTimer() {}
/*-------------------------+
| Ejecuta las estrategias  |
+-------------------------*/
void doStrategies() {
  if (!strategiesActivate || moneyOnRisk())
    return;
  strategiesEvent();
}
/*----------------------------+
| Administra las operaciones  |
+----------------------------*/
void doManagment() { tmEvent(); }