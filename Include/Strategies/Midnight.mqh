/*------------------------+
|            Midnight.mqh |
| Copyright 2017, Alograg |
|  https://www.alograg.me |
+------------------------*/
// Propiedades
#property copyright "Copyright 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Constants
string MidnightComment = eaName + ": S-Midnight";
double MidnightOperations = 1.25;
int MidnightOrderSell = -1;
void Midnight() {
  if (!isNewBar(PERIOD_M1)) {
    if (MidnightOrderSell) {
      MidnightOrderSell = OrderIsOpen(MidnightOrderSell);
      if (MidnightOrderSell && !OrderStopLoss()) {
        double max = MathMax(iHigh(Symbol(), PERIOD_H1, 1),
                             iHigh(Symbol(), PERIOD_H1, 2)) +
                     getSpread();
        double min =
            MathMin(iLow(Symbol(), PERIOD_H1, 1), iLow(Symbol(), PERIOD_H1, 2));
        double tp = min - ((max - min) * 3);
        if (Hour() == 3 && OrderTakeProfit() != tp) {
          if (!OrderModify(MidnightOrderSell, OrderOpenPrice(), max, tp, 0,
                           Yellow) &&
              TRUE) {
            ReportError(
                StringFormat("MidnightModify 3am: %f | %f | %f | %f | %f", max,
                             min, tp, Bid, Ask),
                GetLastError());
          }
        }
      }
    }
    return;
  }
  if (!(Hour() == 23 && Minute() == 58))
    return;
  // TODO: evitar gaps
  double lotSize = getLotSize();
  if (MidnightOrderSell <= 0) {
    if (lotSize <= 0 ||
        (AccountFreeMarginCheck(Symbol(), OP_SELL,
                                lotSize * MidnightOperations) <= 0 ||
         GetLastError() == 134))
      return;
    MidnightOrderSell = OrderSend(
        Symbol(), OP_SELL, NormalizeDouble(lotSize * MidnightOperations, 2),
        Bid, 0, 0, AurealTakeProfits(OP_SELL, lotSize), MidnightComment,
        MagicNumber, 0, Red);
    if (MidnightOrderSell < 0)
      ReportError("MidnightOrderSell", GetLastError());
  }
  // if (MidnightOrderSell > 0 &&
  //     OrderSelect(MidnightOrderSell, SELECT_BY_TICKET)) {
  //   OrderOptimizeClose(MidnightOrderSell);
  if (IsTradeAllowed())
    SendNotification("MidnightOrderSell: " + (string)MidnightOrderSell);
}
