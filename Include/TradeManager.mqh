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
#include "TradeManager\ReasonableLoss.mqh"
// Constantes
// Constants
// Methods
void tmInit() {
  BreakEven = breakInSpread ? getSpread() : Point * manualBreakEven;
}
void tmEvent() {
  if (isNewBar(LAST_PERIOD_W1) && AccountProfit() == 0 &&
      getLotSize() >= 0.05) {
    int eq = (int)AccountEquity();
    sizeOfTheRisk = MathMax((int)(eq - (eq % (40))) / 2, 40);
  }
  DixPip();
  ReasonableLoss();
  OldOrders();
  MaintainMarginLevel();
}