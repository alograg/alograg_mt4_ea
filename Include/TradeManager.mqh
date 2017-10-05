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
//#include "TradeManager\ReasonableLoss.mqh"
// Parameter
extern double maxLots = 10;             // Max lots allowed
extern double expectedMoneyByDay = 200; // Expected day Profit
// Constants
double maxLotsAllowed = 10;
double symbolLoteSize = 0;
double accountLeverage = 0;
double useBreak = 0;
// Methods
void tmInit() {
  BreakEven = breakInSpread ? getSpread() : Point * manualBreakEven;
  useBreak = (breakInSpread ? getSpread() : BreakEven) / pareto;
  int eq = AccountMoneyToInvestment();
  symbolLoteSize = MarketInfo(Symbol(), MODE_LOTSIZE);
  accountLeverage = AccountLeverage();
  if (expectedMoneyByDay > 0) {
    maxLotsAllowed = expectedMoneyByDay / SymbolPipValue();
    maxLotsAllowed /= expectedMoneyByDay;
    maxLotsAllowed /= useBreak / Point;
    maxLotsAllowed /= MathMax(strategiOperations, 1);
  }
  maxLotsAllowed = MathMin(maxLotsAllowed, maxLots);
}
void tmEvent() {
  if (isNewBar(LAST_PERIOD_D1))
    useBreak = (breakInSpread ? getSpread() : BreakEven) / pareto;
  if (isNewBar(LAST_PERIOD_W1) && AccountProfit() == 0 &&
      getLotSize() > maxLotsAllowed)
    tmInit();
  DixPip();
  // ReasonableLoss();
  // OldOrders();
  // MaintainMarginLevel();
}
