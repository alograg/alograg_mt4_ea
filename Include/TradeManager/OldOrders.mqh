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
// Function
void OldOrders() {
  int total = OrdersTotal();
  if (Hour() != 23 || total < 2)
    return;
  // TODO: ajustar bien la busqueda de valores negativos
  OrderSelect(0, SELECT_BY_POS);
  int order1Type = OrderType();
  int order1Ticket = OrderTicket();
  double order1Lots = OrderLots();
  datetime order1OpenAt = OrderOpenTime();
  double order1Profit = OrderProfit();
  string order1Symbol = OrderSymbol();
  int order1DaysOld =
      MathFloor(iTime(Symbol(), PERIOD_H1, 0) - order1OpenAt / (60 * 60 * 24));
  OrderSelect(1, SELECT_BY_POS);
  int order2Type = OrderType();
  int order2Ticket = OrderTicket();
  double order2Lots = OrderLots();
  datetime order2OpenAt = OrderOpenTime();
  double order2Profit = OrderProfit();
  string order2Symbol = OrderSymbol();
  int order2DaysOld =
      MathFloor(iTime(Symbol(), PERIOD_H1, 0) - order2OpenAt / (60 * 60 * 24));
  if ((!order1DaysOld && !order2DaysOld) || order1Symbol != OrderSymbol() ||
      order1Type == order2Type)
    return;
  int orderId = order1Profit > order2Profit ? order1Ticket : order2Ticket,
      oppositeId = order1Profit < order2Profit ? order1Ticket : order2Ticket;
  OrderCloseBy(orderId, oppositeId, Green);
}