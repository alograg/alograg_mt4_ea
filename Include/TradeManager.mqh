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
// Parameter
extern double maLots = 10; // Max lots allowed
// Constantes
// Constants
// Methods
void tmInit() {
  BreakEven = breakInSpread ? getSpread() : Point * manualBreakEven;
  int eq = AccountMoneyToInvestment();
  // sizeOfTheRisk = MathMax((int)(eq - (eq % (RiskSize))) / 2, RiskSize);
}
void tmEvent() {
  if (isNewBar(LAST_PERIOD_W1) && AccountProfit() == 0 &&
      getLotSize() > maLots) {
    tmInit();
  }
  DixPip();
  // ReasonableLoss();
  OldOrders();
  // MaintainMarginLevel();
}