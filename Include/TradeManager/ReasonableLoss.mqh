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
  return false;
  if (!isNewBar(PERIOD_D1))
    return false;
  int wokringPeriod = PERIOD_D1, ticket = 0, total = 0, age = 0;
  double yesterdayProfit = getDayProfit(1), before = 0, profit;
  for (total = OrdersTotal(); total >= 0; total--) {
    if (!OrderSelect(total, SELECT_BY_POS))
      continue;
    profit = OrderProfit() + OrderCommission() + OrderSwap();
    if (profit > 0)
      continue;
    if (profit < before && profit > yesterdayProfit * (lostFactor / -100)) {
      ticket = OrderTicket();
      before = profit;
    }
  }
  if (!ticket) {
    for (total = OrdersTotal(); total >= 0; total--) {
      bool possible = true;
      if (!OrderSelect(total, SELECT_BY_POS))
        continue;
      age = OrderAge();
      if (!age)
        continue;
      else if (age > 7) {
        double avgPrice = (Bid + Ask) / 2;
        possible = iOpen(Symbol(), wokringPeriod, 1) <
                       iHigh(Symbol(), wokringPeriod, age) &&
                   iClose(Symbol(), wokringPeriod, 1) >
                       iLow(Symbol(), wokringPeriod, age);
      }
      if (possible)
        continue;
      profit = OrderProfit() + OrderCommission() + OrderSwap();
      if (profit > 0)
        continue;
      if (profit < before && profit < -10) {
        ticket = OrderTicket();
        before = profit;
      }
    }
  }
  if (ticket)
    return OrderOptimizeClose(ticket);
  return false;
}
