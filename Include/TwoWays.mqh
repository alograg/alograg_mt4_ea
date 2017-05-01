/*------------------------+
|             TwoWays.mqh |
| Copyright 2017, Alograg |
|  https://www.alograg.me |
+------------------------*/

#property copyright "Copyright 2017, Alograg"
#property link "https://www.alograg.me"
#property version propVersion
#property strict

string TwoWaysComment = eaName + ": TwoWays";
int sellOption, buyOption;

void TwoWays() {
  if (!CheckNewBar())
    return;
  if (sellOption || buyOption) {
    int currentOrder = OrderSelect(sellOption, SELECT_BY_TICKET);
    int sellOptionTime = OrderCloseTime();
    currentOrder = OrderSelect(buyOption, SELECT_BY_TICKET);
    int buyOptionTime = OrderCloseTime();
    if (!sellOptionTime || !buyOptionTime)
      return;
  }
  double lotsForTransaction = getLotSize();
  if (lotsForTransaction <= 0)
    return;
  buyOption = OrderSendReliable(Symbol(), OP_BUY, lotsForTransaction, Ask, 3, 0,
                                0, TwoWaysComment, MagicNumber, 0, Green);
  sellOption = OrderSendReliable(Symbol(), OP_SELL, lotsForTransaction, Bid, 3,
                                 0, 0, TwoWaysComment, MagicNumber, 0, Red);
}