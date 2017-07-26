/*--------------------------+
|             OldOrders.mqh |
| Copyright © 2017, Alograg |
|    https://www.alograg.me |
+--------------------------*/
// Properties
#property copyright "Copyright © 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Parameters
// Constants
string OldOrdersComment = eaName + ": S-OldOrders";
extern int resitsDays = 2; // Days without operations
// Function
bool OldOrders() {
  int total = OrdersTotal();
  MqlDateTime currentTimeing;
  TimeToStruct(iTime(Symbol(), PERIOD_M1, 0), currentTimeing);
  if (!(currentTimeing.hour == 23 && currentTimeing.min == 56) || total < 2)
    return false;
  int orderId = 0, oppositeId = 0, sellPips = 0, buyPips = 0;
  for (; total >= 0; total--) {
    if (!OrderSelect(total, SELECT_BY_POS))
      continue;
    if (OrderAge() >= resitsDays)
      continue;
    int mode = OrderType(), age = OrderAge(), pips = OrderProfitPips();
    if (mode == OP_SELL && sellPips > pips) {
      orderId = OrderTicket();
      sellPips = pips;
    }
    if (mode == OP_BUY && buyPips > pips) {
      oppositeId = OrderTicket();
      buyPips = pips;
    }
  }
  if (!orderId && !oppositeId)
    return false;
  return OrderCloseBy(orderId, oppositeId, Green);
}