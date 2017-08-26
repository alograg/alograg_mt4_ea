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
  if (!(Hour() == 23 && Minute() == 58))
    return;
  // TODO: evitar gaps
  double lotSize = getLotSize();
  if (lotSize <= 0 ||
      (AccountFreeMarginCheck(Symbol(), OP_SELL, lotSize * 1.25) <= 0 ||
       GetLastError() == 134))
    return;
  if (MidnightOrderSell <= 0) {
    MidnightOrderSell =
        OrderSend(Symbol(), OP_SELL, NormalizeDouble(lotSize * 1.25, 2), Bid, 0,
                  0, 0, MidnightComment, MagicNumber, 0, Red);
    if (MidnightOrderSell < 0)
      ReportError("MidnightOrderSell", GetLastError());
  } else if (OrderSelect(MidnightOrderSell, SELECT_BY_TICKET)) {
    int age = OrderAge();
    if (age >= 1)
      OrderOptimizeClose(MidnightOrderSell);
  }
  if (IsTradeAllowed())
    SendNotification("MidnightOrderSell: " + (string)MidnightOrderSell);
}
