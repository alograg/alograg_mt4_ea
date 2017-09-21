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
extern double manualBreakEven = 12; // Manual Break (pips)
// Constants
double BreakEven = 12;
// Function
void TrailStops(int ticket) {
  int current = OrderSelect(ticket, SELECT_BY_TICKET);
  if (OrderSymbol() == Symbol()) {
    int mode = OrderType();
    double stop = 0,
           priceToEval = OrderStopLoss() ? OrderStopLoss() : OrderOpenPrice(),
           currentBreak = NormalizeDouble(
               (breakInSpread ? getSpread() : BreakEven) / pareto, Digits),
           profitExpected = OrderTakeProfit();
    int differenceInDays = OrderAge();
    // currentBreak += OrderSwap() * differenceInDays;
    RefreshRates();
    if (mode == OP_BUY) {
      if (profitExpected == 0)
        profitExpected = OrderOpenPrice() + (currentBreak * 1.6);
      if (Bid - priceToEval > currentBreak) {
        currentBreak /= 2;
        stop = MathMax(priceToEval, OrderOpenPrice()) +
               NormalizeDouble(currentBreak, Digits);
      }
    } else if (mode == OP_SELL) {
      if (profitExpected == 0)
        profitExpected = OrderOpenPrice() - (currentBreak * 1.6);
      if (priceToEval - Ask > currentBreak) {
        currentBreak /= 2;
        stop = MathMin(priceToEval, OrderOpenPrice()) -
               NormalizeDouble(currentBreak, Digits);
      }
    }
    if (stop && stop != OrderStopLoss())
      if (!OrderModify(OrderTicket(), OrderOpenPrice(),
                       NormalizeDouble(stop, Digits),
                       NormalizeDouble(profitExpected, Digits), 0, Yellow) &&
          TRUE)
        ReportError("TrailStopsModify " + NormalizeDouble(stop, Digits) + " " +
                        Ask,
                    GetLastError());
  }
}
