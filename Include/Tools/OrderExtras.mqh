/*--------------------------+
|           OrderExtras.mqh |
| Copyright © 2018, Alograg |
|    https://www.alograg.me |
+--------------------------*/
// Properties
#property copyright "Copyright © 2018, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Parameter
// Functions
int OrderAge(int period = 0)
{
  datetime openTime = OrderOpenTime();
  int OpenDay = (int)(openTime - (openTime % (PERIOD_D1 * 60)));
  int Midnight = (int)(iTime(OrderSymbol(), PERIOD_D1, period) -
                       (iTime(OrderSymbol(), PERIOD_D1, period) % (PERIOD_D1 * 60)));
  int DaysOpen = (int)((Midnight - openTime) / (PERIOD_D1 * 60));
  return DaysOpen;
}
int OrderIsOpen(int ticket = 0)
{
  if (ticket)
    if (OrderSelect(ticket, SELECT_BY_TICKET))
      return !OrderCloseTime() ? OrderTicket() : 0;
  if (OrderTicket())
    return !OrderCloseTime() ? OrderTicket() : 0;
  return ticket > 0 ? ticket : OrderTicket();
}
bool OrderOptimizeClose(int ticket)
{
  if (!OrderSelect(ticket, SELECT_BY_TICKET))
    return false;
  RefreshRates();
  int mode = OrderType();
  double sBid = MarketInfo(OrderSymbol(), MODE_BID);
  double sAsk = MarketInfo(OrderSymbol(), MODE_ASK);
  double sPoint = MarketInfo(OrderSymbol(), MODE_POINT);
  int sDigits = (int)MarketInfo(OrderSymbol(), MODE_DIGITS);
  int sSpread = (int)MarketInfo(OrderSymbol(), MODE_SPREAD);
  double lostClose = NormalizeDouble(mode ? sAsk : sBid, sDigits);
  if (mode == OP_SELL)
    lostClose += sSpread * sPoint;
  else if (mode == OP_BUY)
    lostClose -= sSpread * sPoint;
  lostClose = NormalizeDouble(lostClose, sDigits);
  if (!OrderModify(OrderTicket(), OrderOpenPrice(), lostClose,
                   OrderTakeProfit(), 0, Yellow) &&
      GetLastError() > 1)
    ReportError("OrderOptimizeClose", GetLastError());
  return true;
}
