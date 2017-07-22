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
    double stop, priceToEval, currentBreak = BreakEven;
    int differenceInDays = (OrderOpenTime() - TimeCurrent()) / (60 * 60 * 24);
    if (mode == OP_BUY) {
      currentBreak += MarketInfo(Symbol(), MODE_SWAPLONG) * differenceInDays;
      priceToEval = MathMax(OrderOpenPrice(), OrderStopLoss());
      if (Bid - priceToEval > Point * currentBreak) {
        stop = priceToEval + Point * currentBreak;
        OrderModifyReliable(OrderTicket(), OrderOpenPrice(),
                            NormalizeDouble(stop, Digits), OrderTakeProfit(), 0,
                            LightGreen);
        return;
      }
    }
    if (mode == OP_SELL) {
      currentBreak += MarketInfo(Symbol(), MODE_SWAPSHORT) * differenceInDays;
      priceToEval = MathMin(OrderOpenPrice(), OrderStopLoss());
      if (priceToEval == 0)
        priceToEval = OrderOpenPrice();
      if (priceToEval - Ask > Point * currentBreak) {
        stop = priceToEval - Point * currentBreak;
        OrderModifyReliable(OrderTicket(), OrderOpenPrice(),
                            NormalizeDouble(stop, Digits), OrderTakeProfit(), 0,
                            Yellow);
        return;
      }
    }
  }
}
