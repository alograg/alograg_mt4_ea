#property copyright "Copyright  2007"
#property link      ""

extern int       Magic       = 1010;
extern double    Lots        = 0.1;
extern bool      MM          = true;
extern int       LotsPercent = 10;
extern int       MaxLot      = 100;
extern double    MinLot      = 0.1;
extern double    SL          = 15;
extern double    TP          = 5;
extern int       Start       = 0;
extern int       End         = 6;

extern double    RSI_PERIOD  = 14;
extern double    RSI_TF      = 5;
extern double    RSI_BUY     = 30;
extern double    RSI_SELL    = 70;

extern double    RSI_BUY_Zera     = 40;
extern double    RSI_SELL_Zera    = 60;
extern bool      Compra      = true;
extern bool      Venda       = true;

//+------------------------------------------------------------------+

int isMgNum(int magic)
{
int ordtotal = OrdersTotal();
for (int i = 0; i < ordtotal; i++)
   {
   OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
   if ((OrderMagicNumber() == magic) && (OrderSymbol() == Symbol())) return(1);
   }
}

//+------------------------------------------------------------------+

int init()
{
return(0);
}

//+------------------------------------------------------------------+

int deinit()
{
return(0);
}

//+------------------------------------------------------------------+

int start()
{
//+------------------------------------------------------------------+
//|Easy Money Management                                             |
//+------------------------------------------------------------------+
double free;

if (AccountFreeMargin() < free * 1500.0) return(0);

if (MM)
   {
   if (LotsPercent > 0)
      Lots = NormalizeDouble(MathCeil(AccountFreeMargin() / 10000.0 * LotsPercent) / 10.0,1);
         else
      Lots = Lots;
   }
   
   if (Lots < MinLot) Lots = MinLot;
   if (Lots > MaxLot) Lots = MaxLot;
   
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+   

double IN;

double RSI = iRSI(NULL, RSI_TF, RSI_PERIOD, PRICE_CLOSE, 0);


if ((TimeHour(TimeCurrent()) <= Start ) && (TimeHour(TimeCurrent()) >= End)) return(0);

IN = NormalizeDouble(AccountFreeMargin() / 2500,2);

if ((isMgNum(Magic) == 0) && (RSI <RSI_BUY))
   {
   if (Compra)
   OrderSend(Symbol(),OP_BUY,Lots,Ask,4,Ask - SL * Point, Ask + TP * Point,0,Magic,0,Green);
   Compra = false;
   Venda = true;
   }   

if ((isMgNum(Magic) == 0) && (RSI >RSI_SELL))
   {
   if (Venda)
   OrderSend(Symbol(),OP_SELL,Lots,Bid,4,Bid + SL * Point,Bid - TP * Point,0,Magic,0,Red);
   Venda = false;
   Compra = true;
   }
   
if ( ( RSI < RSI_SELL_Zera ) && ( RSI > RSI_BUY_Zera ) )
   {
   Venda = true;
   Compra = true;
   }
}