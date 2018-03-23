/*--------------------------+
|          TradeManager.mqh |
| Copyright © 2017, Alograg |
|    https://www.alograg.me |
+--------------------------*/
// Properties
#property copyright "Copyright © 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Includes
//#include "TradeManager\.mqh"
// Parameter
extern ENUM_TIMEFRAMES trailStopsEach = PERIOD_H1; // Trail Stops each
// Constants
// Methods
void tmInit()
{
}
void tmEvent()
{
    int total = OrdersTotal();
    if (isNewBar(trailStopsEach))
    {
        for (int position = 0; position < total; position++)
        {
            if (OrderSelect(position, SELECT_BY_POS))
            {
                double profit = OrderProfit() + OrderCommission() + OrderSwap();
                if (profit >= (moneyPerOrder * OrderLots()))
                {
                    TrailStops(OrderTicket());
                }
            }
        }
    }
}
