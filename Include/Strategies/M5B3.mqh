/*------------------------+
|                M5B3.mqh |
| Copyright 2017, Alograg |
|  https://www.alograg.me |
+------------------------*/
// Propiedades
#property copyright "Copyright 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Constants
string M5B3Comment = eaName + ": S-M5B3";
int M5B3ProfitStop = 1;
int M5B3OrderBuy = -1;
int M5B3OrderSell = -1;
int BarsReference = 2;
void M5B3() {
  int period = PERIOD_M1;
  if (!isNewBar(period)) {
    if (M5B3OrderBuy)
      M5B3OrderBuy = OrderIsOpen(M5B3OrderBuy);
    if (M5B3OrderSell)
      M5B3OrderSell = OrderIsOpen(M5B3OrderSell);
    return;
  }
  if (getDayProfit() > M5B3ProfitStop)
    return;
  double lotSize = getLotSize();
  int white = 0, black = 0;
  for (int i = 1; i <= BarsReference; i++) {
    white += (int)isWhiteCandel(period, i);
    black += (int)isBlackCandel(period, i);
  }
  if (!M5B3OrderBuy && white == BarsReference)
    M5B3OrderBuy = OrderSendReliable(Symbol(), OP_BUY, lotSize, Ask, 0, 0, 0,
                                     M5B3Comment, MagicNumber, 0, Blue);
  if (!M5B3OrderSell && black == BarsReference)
    M5B3OrderSell = OrderSendReliable(
        Symbol(), OP_SELL, NormalizeDouble(MathAbs(lotSize), 2), Bid, 0, 0, 0,
        M5B3Comment, MagicNumber, 0, Red);
}
