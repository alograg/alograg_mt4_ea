/*--------------------------+
|            TrailStops.mqh |
| Copyright © 2018, Alograg |
|    https://www.alograg.me |
+--------------------------*/
// Properties
#property copyright "Copyright © 2018, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Parameter
extern int moneyPerOrder = 50;             // Minumun profit (centims)
extern ENUM_TIMEFRAMES review = PERIOD_M5; // Last Price Of
// Constants
// Function
void TrailStops(int ticket)
{
    if (!OrderSelect(ticket, SELECT_BY_TICKET))
        return;
    RefreshRates();
    int mode = OrderType();
    double sBid = MarketInfo(OrderSymbol(), MODE_BID);
    double sAsk = MarketInfo(OrderSymbol(), MODE_ASK);
    double sPoint = MarketInfo(OrderSymbol(), MODE_POINT);
    int sDigits = (int)MarketInfo(OrderSymbol(), MODE_DIGITS);
    int sSpread = (int)MarketInfo(OrderSymbol(), MODE_SPREAD);
    double currentPrice = NormalizeDouble(mode ? sAsk : sBid, sDigits),
           lostClose = OrderStopLoss(),
           newStopLoss = 0;
    if (lostClose == 0)
        lostClose = OrderOpenPrice();
    double midWay = NormalizeDouble(MathAbs(currentPrice - lostClose) / 2, sDigits),
           lastClose = iClose(OrderSymbol(), review, 1);
    if (mode == OP_SELL)
    {
        newStopLoss = MathMin(lostClose, currentPrice + midWay);
        if (lastClose < newStopLoss && lastClose > currentPrice)
            newStopLoss = lastClose;
        //        if (newStopLoss > currentPrice)
        //            return;
    }
    else if (mode == OP_BUY)
    {
        newStopLoss = MathMax(lostClose, currentPrice - midWay);
        if (lastClose > newStopLoss && lastClose < currentPrice)
            newStopLoss = lastClose;
        //        if (newStopLoss < currentPrice)
        //            return;
    }
    newStopLoss = NormalizeDouble(newStopLoss, sDigits);
    if (newStopLoss == OrderStopLoss())
        return;
    RefreshRates();
    if (!OrderModify(OrderTicket(), OrderOpenPrice(), newStopLoss,
                     OrderTakeProfit(), 0, Yellow) &&
        GetLastError() > 0)
    {
        Print("mode", mode);
        Print("sBid", sBid);
        Print("sAsk", sAsk);
        Print("currentPrice", currentPrice);
        Print("newStopLoss", newStopLoss);
        Print("lostClose", lostClose);
        Print("midWay", midWay);
        Print("lastClose", lastClose);
        Print("OrderOpenPrice()", OrderOpenPrice());
        Print("OrderStopLoss()", OrderStopLoss());
        Print("OrderTakeProfit()", OrderTakeProfit());
        ReportError("TrailStops", GetLastError());
    }
    return;
}
