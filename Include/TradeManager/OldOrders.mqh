/*--------------------------+
|             OldOrders.mqh |
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
string OldOrdersComment = eaName + ": S-OldOrders";
// Function
void OldOrders() {
  int total = OrdersTotal();
  for (int position = 0; position < total; position++) {
    if (OrderSelect(position, SELECT_BY_POS)) {
      if (OrderSymbol() == Symbol()) {
        int differenceInDays =
            (iTime(Symbol(), PERIOD_H1, 0) - OrderOpenTime()) / (60 * 60 * 12);
        if (differenceInDays < 1)
          continue;
        int mode = OrderType();
        double stop,
            priceToEval = OrderStopLoss() ? OrderStopLoss() : OrderOpenPrice(),
            currentBreak =
                (breakInSpread ? getSpread() / 3 : BreakEven) / pareto;
        currentBreak += OrderSwap() * differenceInDays;
        if (mode == OP_BUY) {
          stop = Bid - Point * currentBreak;
          stop -= BreakEven;
          if (stop != OrderStopLoss())
            OrderModifyReliable(OrderTicket(), OrderOpenPrice(),
                                NormalizeDouble(stop, Digits),
                                OrderTakeProfit(), 0, LightGreen);
          continue;
        }
        if (mode == OP_SELL) {
          stop = Ask + Point * currentBreak;
          stop += BreakEven;
          if (stop != OrderStopLoss())
            OrderModifyReliable(OrderTicket(), OrderOpenPrice(),
                                NormalizeDouble(stop, Digits),
                                OrderTakeProfit(), 0, Yellow);
          continue;
        }
      }
    }
  }
}