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
extern int resitsDays = 3; // Days without operations
// Constants
string OldOrdersComment = eaName + ": S-OldOrders";
// Function
bool OldOrders() {
  int total = OrdersTotal();
  MqlDateTime currentTimeing;
  TimeToStruct(iTime(Symbol(), PERIOD_M1, 0), currentTimeing);
  if (!(currentTimeing.hour == 23 && currentTimeing.min == 57) || total < 2)
    return false;
  string report = "", sellReport = "", buyReport = "";
  int orderId = 0, oppositeId = 0, sellPips = 0, buyPips = 0;
  for (; total >= 0; total--) {
    if (!OrderSelect(total, SELECT_BY_POS))
      continue;
    if (OrderAge() <= resitsDays || OrderSymbol() != Symbol())
      continue;
    int mode = OrderType(), pips = OrderProfitPips();
    if (mode == OP_SELL && sellPips > pips) {
      orderId = OrderTicket();
      sellPips = pips;
      sellReport = "#" + (string)orderId + " pips: " + (string)pips + ", age " +
                   (string)OrderAge();
    }
    if (mode == OP_BUY && buyPips > pips) {
      oppositeId = OrderTicket();
      buyPips = pips;
      buyReport = "#" + (string)orderId + " pips: " + (string)pips + ", age " +
                  (string)OrderAge();
    }
  }
  if (!orderId || !oppositeId)
    return false;
  if (IsTradeAllowed())
    SendNotification("Old orders\n" + sellReport + "\n" + buyReport);
  bool temp = OrderCloseBy(orderId, oppositeId, Green);
  if (temp <= 0)
    ReportError("OldOrders", GetLastError());
  return temp;
}