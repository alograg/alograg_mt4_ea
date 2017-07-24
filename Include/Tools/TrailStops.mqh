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
extern bool breakInSpread = FALSE;  // Use spread as break
extern double manualBreakEven = 15; // Manual Break
// Constants
double BreakEven = 15;
// Function
void TrailStops(int ticket) {
  OrderSelect(ticket, SELECT_BY_TICKET);
  int mode = OrderType();
  if (OrderSymbol() == Symbol()) {
    double stop,
        priceToEval = OrderStopLoss() ? OrderStopLoss() : OrderOpenPrice(),
        currentBreak = (breakInSpread ? getSpread() / 3 : BreakEven) / pareto;
    int differenceInDays =
        (iTime(Symbol(), PERIOD_D1, 0) - OrderOpenTime()) / (60 * 60 * 24);
    currentBreak += OrderSwap() * differenceInDays;
    if (mode == OP_BUY) {
      if (Bid - priceToEval > Point * currentBreak) {
        stop = MathMax(priceToEval, OrderOpenPrice()) + Point * currentBreak;
        stop += BreakEven;
        if (stop != OrderStopLoss())
          OrderModifyReliable(OrderTicket(), OrderOpenPrice(),
                              NormalizeDouble(stop, Digits), OrderTakeProfit(),
                              0, LightGreen);
        return;
      }
    }
    if (mode == OP_SELL) {
      if (priceToEval - Ask > Point * currentBreak) {
        stop = MathMin(priceToEval, OrderOpenPrice()) - Point * currentBreak;
        stop -= BreakEven;
        if (stop != OrderStopLoss())
          OrderModifyReliable(OrderTicket(), OrderOpenPrice(),
                              NormalizeDouble(stop, Digits), OrderTakeProfit(),
                              0, Yellow);
        return;
      }
    }
  }
}
