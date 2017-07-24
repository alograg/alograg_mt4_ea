/*--------------------------+
|                DixPip.mqh |
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
void DixPip() {
  int total = OrdersTotal();
  for (int position = 0; position < total; position++) {
    if (OrderSelect(position, SELECT_BY_POS)) {
      TrailStops(OrderTicket());
    }
  }
}