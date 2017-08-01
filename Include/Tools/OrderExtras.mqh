/*--------------------------+
|           OrderExtras.mqh |
| Copyright © 2017, Alograg |
|    https://www.alograg.me |
+--------------------------*/
// Properties
#property copyright "Copyright © 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Parameter
// Functions
int OrderAge(int period = 0) {
  datetime openTime = OrderOpenTime();
  int OpenDay = (int)(openTime - (openTime % (PERIOD_D1 * 60)));
  int Midnight = (int)(iTime(Symbol(), PERIOD_D1, period) -
                       (iTime(Symbol(), PERIOD_D1, period) % (PERIOD_D1 * 60)));
  int DaysOpen = (int)((Midnight - openTime) / (PERIOD_D1 * 60));
  return DaysOpen;
}
int OrderIsOpen(int ticket = 0) {
  if (ticket) {
    if (OrderSelect(ticket, SELECT_BY_TICKET))
      return !OrderCloseTime() ? OrderTicket() : 0;
  }
  if (OrderTicket())
    return !OrderCloseTime() ? OrderTicket() : 0;
  return ticket > 0 ? ticket : OrderTicket();
}
int OrderProfitPips() {
  return (int)((OrderProfit() - OrderCommission()) / OrderLots() /
               MarketInfo(OrderSymbol(), MODE_TICKVALUE));
}