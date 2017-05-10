/*------------------------+
|   InversAllNegative.mqh |
|   Yick Enhanced Stealth |
| Copyright 2017, Alograg |
|  https://www.alograg.me |
+------------------------*/
// Propiedades
#property copyright "Copyright 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Constantes
string IanComment = eaName + ": IAN-TM";

void InversAllNegative() {
  if (!CheckNewBar())
    return;
  if (!(TimeHour(Time[0]) == 6 && TimeMinute(Time[0]) == 30 && CheckNewBar()))
    return;
  int TotalToClose = OrdersTotal(), ticket;
  double lots = 0, money = 0;
  for (int indexToClose = totalOrders - 1; 0 <= indexToClose; indexToClose--) {
    ticket = OrderSelect(indexToClose, SELECT_BY_POS);
    money +=
        NormalizeDouble(OrderProfit() + OrderCommission() + OrderSwap(), 2);
    if (OrderType() == OP_BUY)
      lots += OrderLots();
    if (OrderType() == OP_SELL)
      lots -= OrderLots();
  }
  PrintLog(IanComment + ": Lots " + lots + " money " + money);
  if (0 < money)
    return;
  if (0 > lots)
    ticket = OrderSendReliable(Symbol(), OP_BUY, MatAbs(lots), Ask, 3, 0, 0,
                               IanComment, MagicNumber, 0, Green);
  if (0 < lots)
    ticket = OrderSendReliable(Symbol(), OP_SELL, MatAbs(lots), Bid, 3, 0, 0,
                               IanComment, toSell, 0, Green);
}