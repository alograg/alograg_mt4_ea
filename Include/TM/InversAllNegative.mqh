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
int ianTicket = 0;

void InversAllNegative() {
  if (!CheckNewBar())
    return;
  if (!(TimeHour(Time[0]) == 0 && TimeMinute(Time[0]) == 0 && CheckNewBar()))
    return;
  if (ianTicket > 0) {
    int ticket = OrderSelect(ianTicket, SELECT_BY_TICKET);
    if (OrderCloseTime())
      return;
    else
      ianTicket = 0;
  }
  if (AccountFreeMargin() <
      MathMax(firstBalance / 2, AccountFreeMargin() - firstBalance))
    return;
  int TotalToClose = OrdersTotal(), ticket;
  double lots = 0, money = 0;
  for (int indexToClose = totalOrders - 1; 0 <= indexToClose; indexToClose--) {
    ticket = OrderSelect(indexToClose, SELECT_BY_POS);
    if (MathAbs(TimeDayOfYear(OrderOpenTime()) - TimeDayOfYear(time0)) < 7)
      continue;
    money +=
        NormalizeDouble(OrderProfit() + OrderCommission() + OrderSwap(), 2);
    if (OrderType() == OP_BUY)
      lots += OrderLots();
    if (OrderType() == OP_SELL)
      lots -= OrderLots();
  }
  if (0 < money)
    return;
  PrintAndNotify(IanComment + ": Lots " + lots + " money " + money);
  if (0 > lots)
    ianTicket = OrderSendReliable(Symbol(), OP_BUY, MathAbs(lots), Ask, 3, 0, 0,
                                  IanComment, MagicNumber, 0, Green);
  if (0 < lots)
    ianTicket = OrderSendReliable(Symbol(), OP_SELL, MathAbs(lots), Bid, 3, 0, 0,
                                  IanComment, MagicNumber, 0, Green);
}