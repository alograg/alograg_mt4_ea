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
  // OrderCloseBy(orderId, oppositeId, Green);
}