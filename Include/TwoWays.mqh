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
int sellOption, buyOption, cleanOptions;

void TwoWays() {
  if (sellOption || buyOption) {
    cleanOptions = 0;
    int currentOrder = OrderSelect(sellOption, SELECT_BY_TICKET);
    int sellOptionTime = OrderCloseTime();
    double sellOptionLots = OrderLots();
    currentOrder = OrderSelect(buyOption, SELECT_BY_TICKET);
    int buyOptionTime = OrderCloseTime();
    double buyOptionLots = OrderLots();
    if (!buyOptionTime && sellOptionTime) {
      cleanOptions = CloseOneIfProfit(buyOption, SELECT_BY_TICKET, NULL, false,
                                      buyOptionLots);
    }
    if (buyOptionTime && !sellOptionTime) {
      cleanOptions = CloseOneIfProfit(sellOption, SELECT_BY_TICKET, NULL, false,
                                      sellOptionLots);
    }
    if (cleanOptions) {
      buyOption = 0;
      sellOption = 0;
      return;
    }
    if (!sellOptionTime || !buyOptionTime)
      return;
  }
  if (!CheckNewBar())
    return;
  if (!(TimeHour(Time[0]) == 7 && TimeMinute(Time[0]) == 0 && CheckNewBar()))
    return;
  double lotsForTransaction = getLotSize();
  if (lotsForTransaction <= 0)
    return;
  AddNotify(TwoWaysComment);
  buyOption = OrderSendReliable(Symbol(), OP_BUY, lotsForTransaction, Ask, 3, 0,
                                0, TwoWaysComment, MagicNumber, 0, Green);
  sellOption = OrderSendReliable(Symbol(), OP_SELL, lotsForTransaction, Bid, 3,
                                 0, 0, TwoWaysComment, MagicNumber, 0, Red);
}