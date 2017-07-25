/*--------------------------+
|          TradeManager.mqh |
| Copyright © 2017, Alograg |
|    https://www.alograg.me |
+--------------------------*/
// Properties
#property copyright "Copyright © 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Includes
#include "TradeManager\DixPip.mqh"
#include "TradeManager\MaintainMarginLevel.mqh"
#include "TradeManager\OldOrders.mqh"
// Constantes
// Constants
// Methods
void tmInit() { BreakEven = breakInSpread ? getSpread() : manualBreakEven; }
void tmEvent() {
  OldOrders();
  MaintainMarginLevel();
  DixPip();
}