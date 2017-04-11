extern int TakeProfit = 56;
extern double StopLoss = 125;
extern int x1 = 135;
extern int x2 = 127;
extern int x3 = 16;
extern int x4 = 93;
extern double lots = 0.1;
extern int MagicNumber = 524178;
static int prevtime = 0;

double sl, xecn, TakeProfitX;
//+------------------------------------------------------------------+
//| expert initialization function |
//+------------------------------------------------------------------+
int OnInit()
{
    //----
    return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| expert deinitialization function |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
}
//+------------------------------------------------------------------+
//| expert start function |
//+------------------------------------------------------------------+
void OnTick()
{
    xecn = 1;
    if (Digits == 5)
    {
        xecn = 10;
    }
    if (Digits == 3)
    {
        xecn = 10;
    }

    TakeProfitX = TakeProfit * xecn;
    sl = StopLoss * xecn;

    if (Time[0] == prevtime)
        return;
    prevtime = Time[0];
    int spread = 3;
    //----
    if (IsTradeAllowed())
    {
        RefreshRates();
        spread = MarketInfo(Symbol(), MODE_SPREAD);
    }
    else
    {
        prevtime = Time[1];
        return;
    }
    int ticket = -1;
    // check for opened position
    int total = OrdersTotal();
    //----
    for (int i = 0; i < total; i++)
    {
        OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        // check for symbol & magic number
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
            int prevticket = OrderTicket();
            // long position is opened
            if (OrderType() == OP_BUY)
            {
                    if (perceptron() < 0)
                    { // reverse
                    Print("Reverse BUY->SELL");
                        ticket = OrderSend(Symbol(), OP_SELL, lots * 2, Bid, 3,0, Ask - TakeProfitX * Point, "AI", MagicNumber, 0, Red);
                        //Sleep(30000);
                        //----
                        if (ticket < 0)
                            prevtime = Time[1];
                        //else
                          //  OrderCloseBy(ticket, prevticket, Blue);
                    }
                    else
                    { // trailing stop
                        if (!OrderModify(OrderTicket(), OrderOpenPrice(), 0,
                                         OrderTakeProfit(), 0, Blue))
                        {
                            //Sleep(30000);
                            prevtime = Time[1];
                        }
                    }
                // short position is opened
            }
            else
            {
                    if (perceptron() > 0)
                    { // reverse
                        ticket = OrderSend(Symbol(), OP_BUY, lots * 2, Ask, 3,0, Bid + TakeProfitX * Point, "AI", MagicNumber, 0, Blue);
                        //Sleep(30000);
                        //----
                        if (ticket < 0)
                            prevtime = Time[1];
                       // else
                         //   OrderCloseBy(ticket, prevticket, Blue);
                    }
                    else
                    { // trailing stop
                        if (!OrderModify(OrderTicket(), OrderOpenPrice(), 0,
                                         OrderTakeProfit(), 0, Blue))
                        {
                            //Sleep(30000);
                            prevtime = Time[1];
                        }
                    }
            }
            // exit
            return;
        }
    }
    // check for long or short position possibility
    //if (perceptron() > 0)
    //{ //long
        ticket = OrderSend(Symbol(), OP_BUY, lots, Ask, 3, 0, Bid + TakeProfitX * Point, "AI",
                           MagicNumber, 0, Blue);
        //----
    //    if (ticket < 0)
      //  {
            //Sleep(30000);
        //    prevtime = Time[1];
//        }
  //  }
    //else
    //{ // short
        ticket = OrderSend(Symbol(), OP_SELL, lots, Bid, 3, 0, Ask - TakeProfitX * Point, "AI",
                           MagicNumber, 0, Red);
        if (ticket < 0)
        {
            //Sleep(30000);
            prevtime = Time[1];
        }
    //}
    //--- exit
    return;
}
//+------------------------------------------------------------------+
//| The PERCEPTRON - a perceiving and recognizing function |
//+------------------------------------------------------------------+
double perceptron()
{
    double w1 = x1 - 100;
    double w2 = x2 - 100;
    double w3 = x3 - 100;
    double w4 = x4 - 100;
    double a1 = iAC(Symbol(), 0, 0);
    double a2 = iAC(Symbol(), 0, 7);
    double a3 = iAC(Symbol(), 0, 14);
    double a4 = iAC(Symbol(), 0, 21);
    return (w1 * a1 + w2 * a2 + w3 * a3 + w4 * a4);
}
//+------------------------------------------------------------------+
