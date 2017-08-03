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
// Function
void MaintainMarginLevel() {
  double MarginLevel = 0;
  if (AccountMargin() > 0)
    MarginLevel = NormalizeDouble(AccountEquity() / AccountMargin() * 100, 2);
  int stopOut = AccountStopoutMode() ? 50 : AccountStopoutLevel();
  if (MarginLevel > stopOut * 4)
    return;
  tradeCounterPositions(MarginLevel < stopOut * 2);
}
void tradeCounterPositions(bool strong = false) {
  double lotSize = countOpenPositions();
  if (!lotSize)
    return;
  lotSize /= strong ? 1 : 2;
  lotSize = NormalizeDouble(lotSize, 2);
  if (lotSize != 0) {
    OrderSend(Symbol(), lotSize < 0 ? OP_BUY : OP_SELL,
              NormalizeDouble(MathAbs(lotSize), 2), lotSize < 0 ? Bid : Ask, 0,
              0, 0, MaintainMarginLevelComment, MagicNumber, 0, Green);
  }
}
double countOpenPositions(int mode = -1) {
  double openBuyLots = 0, openSellLots = 0;
  for (int iPos = OrdersTotal() - 1; iPos >= 0; iPos--)
    if (OrderSelect(iPos, SELECT_BY_POS) && OrderSymbol() == Symbol()) {
      if (OrderType() == OP_BUY)
        openBuyLots += OrderLots();
      else
        openSellLots += OrderLots();
    }
  return mode == OP_BUY ? openBuyLots : mode == OP_SELL
                                            ? openSellLots
                                            : openBuyLots - openSellLots;
}