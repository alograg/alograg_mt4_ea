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
  int TotalToClose = OrdersTotal(), ticket;
  double toSell = 0, toBuy = 0;
  for (int indexToClose = totalOrders - 1; 0 <= indexToClose; indexToClose--) {
    ticket = OrderSelect(indexToClose, SELECT_BY_POS);
    double profit =
        NormalizeDouble(OrderProfit() + OrderCommission() + OrderSwap(), 2);
    if (0 > profit) {
      if (OrderType() == OP_BUY)
        toSell += OrderLots();
      if (OrderType() == OP_SELL)
        toBuy += OrderLots();
    }
  }
  PrintLog(IanComment + ": Buy " + toBuy + " Sell " + toSell);
  if (toBuy)
    ticket = OrderSendReliable(Symbol(), OP_BUY, toBuy, Ask, 3, 0, 0,
                               IanComment, MagicNumber, 0, Green);
  if (toSell)
    ticket = OrderSendReliable(Symbol(), OP_SELL, toSell, Bid, 3, 0, 0,
                               IanComment, toSell, 0, Green);
}