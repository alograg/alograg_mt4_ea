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
           currentBreak = NormalizeDouble(getSpread() * 3, Digits),
           profitExpected = OrderTakeProfit();
    if (profitExpected != 0) {
      double tailingBase = MathAbs(priceToEval - profitExpected);
      currentBreak = MathMax(tailingBase, currentBreak);
    }
    RefreshRates();
    if (mode == OP_BUY) {
      if (Bid - priceToEval > currentBreak / 2) {
        currentBreak /= 3;
        stop = MathMax(priceToEval, OrderOpenPrice()) +
               NormalizeDouble(currentBreak, Digits);
      }
    } else if (mode == OP_SELL) {
      if (priceToEval - Ask > currentBreak / 2) {
        currentBreak /= 3;
        stop = MathMin(priceToEval, OrderOpenPrice()) -
               NormalizeDouble(currentBreak, Digits);
      }
    }
    if (stop && stop != OrderStopLoss())
      if (!OrderModify(OrderTicket(), OrderOpenPrice(),
                       NormalizeDouble(stop, Digits),
                       NormalizeDouble(profitExpected, Digits), 0, Yellow) &&
          FALSE)
        ReportError("TrailStopsModify; stop " + NormalizeDouble(stop, Digits) +
                        ", Ask " + NormalizeDouble(Ask, Digits),
                    GetLastError());
  }
}
