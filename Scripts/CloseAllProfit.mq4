//+------------------------------------------------------------------+
//|                                               CloasAllProfit.mq4 |
//|                                          Copyright 2017, Alograg |
//|                                           https://www.alograg.me |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Alograg"
#property link "https://www.alograg.me"
#property version "1.00"
#property strict

//#include <SummaryReport.mqh>

double ExtInitialDeposit;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
    int TotalToClose = OrdersTotal(), hasClose, iClosed = 0;
    double profit;
    Print("Close Start");
    for (int indexToClose = TotalToClose - 1; 0 <= indexToClose; indexToClose--)
    {
        if (!OrderSelect(indexToClose, SELECT_BY_POS))
            continue;
        profit = NormalizeDouble(OrderProfit() + OrderCommission() + OrderSwap() - 0.07, 2);
        if (OrderSymbol() == Symbol())
        {
            if (OrderType() == OP_BUY && profit > 0)
            {
                hasClose = OrderClose(OrderTicket(), OrderLots(), Bid, 4, White);
            }
            if (OrderType() == OP_SELL && profit > 0)
            {
                hasClose = OrderClose(OrderTicket(), OrderLots(), Ask, 4, White);
            }
            iClosed += hasClose ? 1 : 0;
            Print(OrderTicket(), OrderType(), ": ", profit);
        }
    }
    Print(iClosed, " closed of ", TotalToClose);
}
