/*------------------------+
|        TradeManager.mqh |
| Copyright 2017, Alograg |
|  https://www.alograg.me |
+------------------------*/
// Propiedades
#property copyright "Copyright 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Incluciones
#include "CloseAllProfited.mqh"
#include "TM\InversAllNegative.mqh"
#include "TM\YES.mqh"
#include "TM\FlowTheEnemy.mqh"

// Constantes

void tmInit() { yesInit(); }
void tmEvent() {
  yesProcess();
  FlowTheEnemy();
  InversAllNegative();
}