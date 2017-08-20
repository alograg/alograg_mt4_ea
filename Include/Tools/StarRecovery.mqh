/*--------------------------+
|          StarRecovery.mqh |
| Copyright © 2017, Alograg |
|    https://www.alograg.me |
+--------------------------*/
// Properties
#property copyright "Copyright © 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Parameter
// Constants
// Function
void StarRecovery(int ticket) {
  if (!isNewBar(PERIOD_M30))
    return;
  int current = OrderSelect(ticket, SELECT_BY_TICKET);
  if (OrderSymbol() == Symbol()) {
    int differenceInDays = OrderAge();
    if (OrderStopLoss() == 0)
      return;
    int mode = OrderType();
    double stop = 0, priceToEval = OrderStopLoss(),
           openPrice = OrderOpenPrice(),
           halfPrice = (priceToEval + openPrice) / 2;
    if (mode == OP_BUY) {
      if (Bid < halfPrice) {
        stop = (halfPrice + priceToEval) / 2;
      }
    } else if (mode == OP_SELL) {
      if (Ask > halfPrice) {
        stop = (halfPrice + priceToEval) / 2;
      }
    }
    if (stop && stop != OrderStopLoss()) {
      Print("StarRecoveryModify", OrderStopLoss(), stop);
      if (!OrderModify(OrderTicket(), OrderOpenPrice(),
                       NormalizeDouble(stop, Digits), OrderTakeProfit(), 0,
                       Yellow) &&
          FALSE)
        ReportError("StarRecoveryModify", GetLastError());
    }
  }
}
