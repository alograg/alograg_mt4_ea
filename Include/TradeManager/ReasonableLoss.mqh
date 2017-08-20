/*--------------------------+
|        ReasonableLoss.mqh |
| Copyright © 2017, Alograg |
|    https://www.alograg.me |
+--------------------------*/
// Properties
#property copyright "Copyright © 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Parameters
extern int lostFactor = 50; // Reasonable Loss (%)
// Constants
string ReasonableLossComment = eaName + ": S-ReasonableLoss";
// Functions
bool ReasonableLoss() {
  // return false;
  if (!isNewBar(PERIOD_D1))
    return false;
  for (int total = OrdersTotal(); total >= 0; total--) {
    bool possible = true;
    if (!OrderSelect(total, SELECT_BY_POS))
      continue;
    int age = OrderAge();
    if (age <= 7)
      continue;
    int mode = OrderType();
    double lostClose = NormalizeDouble(mode ? Ask : Bid, Digits),
           currentBreak =
               iHigh(Symbol(), PERIOD_D1, 1) - iLow(Symbol(), PERIOD_D1, 1);
    if (mode == OP_SELL) {
      lostClose += currentBreak;
    } else if (mode == OP_BUY) {
      lostClose -= currentBreak;
    }
    if (!OrderModify(OrderTicket(), OrderOpenPrice(), lostClose,
                     OrderTakeProfit(), 0, Yellow))
      ReportError("ReasonableLoss", GetLastError());
  }
  return false;
}
