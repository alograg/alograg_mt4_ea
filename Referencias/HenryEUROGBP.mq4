/*
By @alograg
2016-03-14
*/
#property copyright "Alograg"
#property link      "http://alograg.me"
#property version   "0.1"
#property strict
#property description "Copmprador de Alograg"

string ExpertName = "Alograg Theory"; 
int lastBuyTime;

// Definiciones
extern int MagicNumber = 4105245;
extern double Lots = 0.01;
extern double StopLoss = 4;
extern double TakeProfit = 16;
extern int TrailingStop = 8;
extern int Slippage = 3;
extern int EvaluatePeriods = 10;
extern int MinProfit = 0.05;

/**
Cuenta las ordenes abiertas por el Robot
*/
int TotalOrdersCount()
{
  int result=0;
  for(int i = 0; i < OrdersTotal(); i++)
  {
     OrderSelect(i,SELECT_BY_POS ,MODE_TRADES);
     if (OrderMagicNumber() == MagicNumber) result++;

   }
  return (result);
}
bool Between(double Data, double First, double Second)
{
  double  min = MathMin(First, Second);
  double  max = MathMax(First, Second);
  return Data > min && Data < max;
}
void OnInit(){
   lastBuyTime = Time[0];
}
//+------------------------------------------------------------------+
//    expert start function
//+------------------------------------------------------------------+
void OnStart(){
  //Print("Inicia: ", ExpertName);
  double MyPoint = Point;
  if(Digits == 3 || Digits == 5) MyPoint = Point*10;
  double TheStopLoss = 0;
  double TheTakeProfit = 0;
  double MaLowE = iMA("EURGBP", PERIOD_M1, EvaluatePeriods, 0, MODE_EMA, PRICE_LOW, 0);
  double MaHighE = iMA("EURGBP", PERIOD_M1, EvaluatePeriods, 0, MODE_EMA, PRICE_HIGH, 0);
  double MaAvgE = iMA("EURGBP", PERIOD_M1, EvaluatePeriods, 0, MODE_EMA, PRICE_TYPICAL, 0);
  double MaLowELast = iMA("EURGBP", PERIOD_M1, EvaluatePeriods, 0, MODE_EMA, PRICE_LOW, 1);
  double MaHighELast = iMA("EURGBP", PERIOD_M1, EvaluatePeriods, 0, MODE_EMA, PRICE_HIGH, 1);
  double MaAvgELast = iMA("EURGBP", PERIOD_M1, EvaluatePeriods, 0, MODE_EMA, PRICE_TYPICAL, 1);
  double MaLow = iMA("EURGBP", PERIOD_M1, EvaluatePeriods, 0, MODE_SMA, PRICE_LOW, 0);
  double MaHigh = iMA("EURGBP", PERIOD_M1, EvaluatePeriods, 0, MODE_SMA, PRICE_HIGH, 0);
  double MaLowLast = iMA("EURGBP", PERIOD_M1, EvaluatePeriods, 0, MODE_SMA, PRICE_LOW, 1);
  double MaHighLast = iMA("EURGBP", PERIOD_M1, EvaluatePeriods, 0, MODE_SMA, PRICE_HIGH, 1);
  if(TotalOrdersCount() <= 4)
  {
     int result = 0;
     //El minimo ponderado crusa el minimo exponencial
     //Print("Aqui: ", MaLowLast, MaLowELast, MaLow, MaLowE);
     bool isDown = MaLowLast >= MaLowELast &&  MaLow <= MaLowE;
     bool canBuy = lastBuyTime != (int)Time[0];
     Print("Compra? ",isDown, canBuy, lastBuyTime, (int)Time[0]);
     if(isDown && canBuy) // Here is your open buy rule
     {
        Print("Compra de: ", ExpertName);
        result = OrderSend("EURGBP", OP_BUY, Lots, Ask, Slippage, 0, Ask*MinProfit,"Alograg Compro", MagicNumber, 0, Blue);
        if(result > 0)
        {
         TheStopLoss=0;
         TheTakeProfit=0;
         if(TakeProfit>0) TheTakeProfit = Ask + TakeProfit * MyPoint;
         if(StopLoss>0) TheStopLoss = Ask - StopLoss * MyPoint;
         OrderSelect(result, SELECT_BY_TICKET);
         OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(TheStopLoss, Digits), NormalizeDouble(TheTakeProfit, Digits), 0, Green);
         lastBuyTime = Time[0];
        }
     }
  }
  int countOrders = OrdersTotal();
  for(int cnt=0; cnt < countOrders; cnt++)
  {
    OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
    bool isWorkingOrder = OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber;
    if(isWorkingOrder){
      bool isBuy = OrderType() == OP_BUY;
      bool hasPositiveProfit = OrderProfit()>(MinProfit*OrderOpenPrice());
      bool lastHighFlagGood = Between(MaHighLast, Open[1], Close[1])
                          && MaHighELast<Close[1];
      bool currentHighFlagGoBad = Between(MaHigh, Open[0], Close[0])
                          && Between(MaHighE, Open[0], Close[0]);
      bool canSell = MaHigh>MaHighE;
      bool noLoseBuy = MaLowLast>MaLowELast && Low[0]<MaLowE;
      if(isBuy && hasPositiveProfit)
      {
        Print("Evaluar",isBuy, hasPositiveProfit, lastHighFlagGood, currentHighFlagGoBad, canSell, noLoseBuy);
        if(lastHighFlagGood && (currentHighFlagGoBad || noLoseBuy))
        {
          OrderClose(OrderTicket(), OrderLots() ,OrderClosePrice(), Slippage, Red);
          Print("Venta de: ", ExpertName);
        }
        else
        {
        if(TrailingStop>0)
        {
          if(Bid - OrderOpenPrice() > MyPoint * TrailingStop)
          {
            if(OrderStopLoss() < Bid - MyPoint * TrailingStop)
            {
              OrderModify(OrderTicket(), OrderOpenPrice(), Bid - TrailingStop * MyPoint, OrderTakeProfit(), 0, Green);
            }
          }
        }
        }
      }
    }
  }
}
