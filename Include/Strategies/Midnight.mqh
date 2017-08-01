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
int MidnightOrderSell = -1;
void Midnight() {
  if (!isNewBar(PERIOD_M1)) {
    if (MidnightOrderSell)
      MidnightOrderSell = OrderIsOpen(MidnightOrderSell);
    return;
  }
  MqlDateTime currentTimeing;
  TimeToStruct(iTime(Symbol(), PERIOD_M1, 0), currentTimeing);
  if (!(currentTimeing.hour == 23 && currentTimeing.min == 58))
    return;
  // TODO: evitar gaps
  double lotSize = getLotSize();
  if (lotSize <= 0)
    return;
  if (MidnightOrderSell <= 0)
    MidnightOrderSell =
        OrderSendReliable(Symbol(), OP_SELL, lotSize, Bid, 0, 0, 0,
                          MidnightComment, MagicNumber, 0, Red);
  else if (OrderSelect(MidnightOrderSell, SELECT_BY_TICKET)) {
    if (OrderAge() >= 1) {
      int mode = OrderType();
      double lostClose = NormalizeDouble(mode ? Ask : Bid, Digits),
             currentBreak = breakInSpread ? getSpread() : BreakEven;
      if (mode == OP_SELL) {
        lostClose += Point * currentBreak;
        lostClose += BreakEven;
      } else if (mode == OP_BUY) {
        lostClose -= Point * currentBreak;
        lostClose -= BreakEven;
      }
      OrderModifyReliable(OrderTicket(), OrderOpenPrice(), lostClose,
                          OrderTakeProfit(), 0, Yellow);
    }
    SendNotification("MidnightOrderSell: " + MidnightOrderSell);
  }
}
