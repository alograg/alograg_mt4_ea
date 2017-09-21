/*--------------------------+
|                DixPip.mqh |
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
// Function
void DixPip() {
  int total = OrdersTotal();
  double canLost = AccountMaxLostMoney();
  double dayProfit = getDayProfit();
  bool reach = dayProfit > canLost * 2;
  for (int position = 0; position < total; position++) {
    if (OrderSelect(position, SELECT_BY_POS)) {
      double profit = OrderProfit() + OrderCommission() + OrderSwap();
      // if (profit < 0) {
      //   StarRecovery(OrderTicket());
      //   continue;
      // }
      if (profit > 0)
        TrailStops(OrderTicket());
      else if (reach && profit < 0 && MathAbs(profit) > canLost)
        OrderOptimizeClose(OrderTicket());
    }
  }
}