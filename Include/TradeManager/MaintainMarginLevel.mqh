/*--------------------------+
|   MaintainMarginLevel.mqh |
| Copyright © 2017, Alograg |
|    https://www.alograg.me |
+--------------------------*/
// Properties
#property copyright "Copyright © 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Parameters
// Constants
string MaintainMarginLevelComment = eaName + ": S-MaintainMarginLevel";
string mmlCounterComment = eaName + ": S-MMLCounter";
int mmlOrder = -1;
int mmlCounterOrder = -1;
double lastLostAmount = 0;
double firstMML = -1;
// Function
void MaintainMarginLevel() {
  // if (mmlOrder && isNewBar(PERIOD_H4)) {
  //   if (mmlOrder)
  //     mmlOrder = OrderIsOpen(mmlOrder);
  //   if (!mmlCounterOrder) {
  //     mmlCounterOrder =
  //         OrderSend(Symbol(), OrderType() == OP_SELL ? OP_BUY : OP_SELL,
  //                   NormalizeDouble(OrderLots() / 2, 2),
  //                   OrderType() == OP_SELL ? Ask : Bid, 0, 0, 0,
  //                   mmlCounterComment, MagicNumber, 0, Yellow);
  //   } else
  //     mmlCounterOrder = OrderIsOpen(mmlCounterOrder);
  // }
  if (!isNewBar(PERIOD_M1)) {
    if (mmlOrder)
      mmlOrder = OrderIsOpen(mmlOrder);
    return;
  }
  if (moneyOnRisk() || mmlOrder > 0)
    return;
  double currentLost = AccountProfit(), severity = MathAbs(currentLost),
         currentBalance = AccountBalance();
  bool preventMarginDown = severity >= currentBalance / 3,
       preventMarginDownToLow = severity >= currentBalance / 2;
  if (currentLost >= 0 || !preventMarginDown || currentLost > lastLostAmount ||
      preventMarginDownToLow) {
    firstMML = -1;
    return;
  }
  lastLostAmount = currentLost;
  mmlOrder = tradeCounterPositions(severity >= currentBalance / 1.5);
}
int tradeCounterPositions(bool strong = false) {
  double lotSize = AccountOpenPositions();
  if (0 == lotSize)
    return 0;
  // lotSize /= strong ? 1 : 2;
  lotSize = NormalizeDouble(lotSize, 2);
  if (lotSize != 0) {
    if (isNewBar(PERIOD_H1) || firstMML <= 0) {
      double stoploss = lotSize < 0 ? Ask : Bid;
      stoploss +=
          (lotSize < 0 ? -1 : 1) * ((getCandelSize(PERIOD_H4, 1) / 3) * 2);
      stoploss = lotSize < 0 ? MathMin(MathMin(iLow(Symbol(), PERIOD_D1, 1),
                                               iLow(Symbol(), PERIOD_D1, 0)),
                                       stoploss)
                             : MathMax(MathMax(iHigh(Symbol(), PERIOD_D1, 1),
                                               iHigh(Symbol(), PERIOD_D1, 0)),
                                       stoploss);
      firstMML = stoploss;
    }
    return OrderSend(Symbol(), lotSize < 0 ? OP_BUY : OP_SELL, MathAbs(lotSize),
                     lotSize < 0 ? Ask : Bid, 0, firstMML, 0,
                     MaintainMarginLevelComment, MagicNumber, 0, Green);
  }
  return -1;
}
