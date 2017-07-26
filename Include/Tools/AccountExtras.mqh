/*--------------------------+
|            TrailStops.mqh |
| Copyright © 2017, Alograg |
|    https://www.alograg.me |
+--------------------------*/
// Properties
#property copyright "Copyright © 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Parameter
extern int SpreadSize = 100; // Size of spread reference
// extern int RiskSize = 40;    // Size of moneyRisk
// Constants
int SpreadSampleSize = 0;
double Spread[];
// int sizeOfTheRisk = 40;
// Functions
bool moneyOnRisk() {
  int stopOut = AccountStopoutMode() ? 50 : AccountStopoutLevel();
  double MarginLevel =
      AccountMargin() > 0
          ? NormalizeDouble(AccountEquity() / AccountMargin() * 100, 2)
          : AccountEquity();
  return !(AccountMargin() <= AccountEquity() / 2 ||
           AccountMargin() <= AccountBalance() / 2 ||
           MarginLevel <= stopOut * 1.5);
}
double Deposits() {
  double total = 0;
  for (int i = 0; i < OrdersHistoryTotal(); i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
      if (OrderType() > 5) {
        total += OrderProfit();
      }
    }
  }
  return MathMax(total, 40);
}
double getLotSize() {
  return moneyOnRisk() ? 0 : MathMax(AccountEquity() / (100 * 40), 0);
}
double getSpread(double AddValue = 0) {
  double LastValue;
  static double ArrayTotal = 0;
  if (SpreadSampleSize == 0)
    SpreadSampleSize = SpreadSize;
  if ((AddValue == 0 && SpreadSampleSize <= 0) ||
      (AddValue == 0 && ArrayTotal == 0))
    return NormalizeDouble(Ask - Bid, Digits);
  if (AddValue == 0)
    return NormalizeDouble(ArrayTotal / ArraySize(Spread), Digits);
  ArrayTotal = ArrayTotal + AddValue;
  ArraySetAsSeries(Spread, true);
  if (ArraySize(Spread) == SpreadSampleSize) {
    LastValue = Spread[0];
    ArrayTotal = ArrayTotal - LastValue;
    ArraySetAsSeries(Spread, false);
    ArrayResize(Spread, ArraySize(Spread) - 1);
    ArraySetAsSeries(Spread, true);
    ArrayResize(Spread, ArraySize(Spread) + 1);
  } else
    ArrayResize(Spread, ArraySize(Spread) + 1);
  ArraySetAsSeries(Spread, false);
  Spread[0] = AddValue;
  return NormalizeDouble(ArrayTotal / ArraySize(Spread), Digits);
}
