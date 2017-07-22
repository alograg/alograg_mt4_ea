/*--------------------------+
|           isOpenOrder.mqh |
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
// Function
bool isOpenOrder(int ticket) {
  bool currentTicket = OrderSelect(ticket, SELECT_BY_TICKET);
  return OrderCloseTime() ? ticket : false;
}