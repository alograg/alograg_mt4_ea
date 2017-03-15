//+------------------------------------------------------------------+
//|                                                AlogragExpert.mq4 |
//|                                          Copyright 2017, Alograg |
//|                                           https://www.alograg.me |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Alograg"
#property link      "https://www.alograg.me"
#property version   "1.00"
#property description "Copmprador de Alograg"
#property strict

string ExpertName = "Alograg Theory"; 
int lastBuyTime;
int lastSellTime;

// Definiciones
extern int MagicNumber = 4105245;
extern double Lots = 0.01;
extern double StopLoss = 4;
extern double TakeProfit = 16;
extern int TrailingStop = 8;
extern int Slippage = 3;
extern int EvaluatePeriods = 10;
extern double MinProfit = 0.05;

int TotalOrdersCount()
{
  int result=0;
  bool hasOrder;
  for(int i = 0; i < OrdersTotal(); i++)
  {
     hasOrder = OrderSelect(i,SELECT_BY_POS ,MODE_TRADES);
     if (OrderMagicNumber() == MagicNumber)
     {
      result++;
     }

   }
  return (result);
}
int TotalBuyOrdersCount()
{
  int result=0;
  bool hasOrder;
  for(int i = 0; i < OrdersTotal(); i++)
  {
     hasOrder = OrderSelect(i,SELECT_BY_POS ,MODE_TRADES);
     if (OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY) result++;
   }
  return (result);
}
int TotalSellOrdersCount()
{
  int result=0;
  bool hasOrder;
  for(int i = 0; i < OrdersTotal(); i++)
  {
     hasOrder = OrderSelect(i,SELECT_BY_POS ,MODE_TRADES);
     if (OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL) result++;
   }
  return (result);
}
bool Between(double Data, double First, double Second)
{
  double  min = MathMin(First, Second);
  double  max = MathMax(First, Second);
  return Data > min && Data < max;
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   //Print("Inicia: ", ExpertName);
   lastBuyTime = Time[0];
   lastSellTime = Time[0];
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
    double MyPoint = Point;
    bool hasOrder;
    if(Digits == 3 || Digits == 5) MyPoint = Point*10;
    double TheStopLoss = 0;
    double TheTakeProfit = 0;
    double MaLowE = iMA("EURGBP", PERIOD_M5, EvaluatePeriods, 0, MODE_EMA, PRICE_LOW, 0);
    double MaHighE = iMA("EURGBP", PERIOD_M5, EvaluatePeriods, 0, MODE_EMA, PRICE_HIGH, 0);
    double MaAvgE = iMA("EURGBP", PERIOD_M5, EvaluatePeriods, 0, MODE_EMA, PRICE_TYPICAL, 0);
    double MaLowELast = iMA("EURGBP", PERIOD_M5, EvaluatePeriods, 0, MODE_EMA, PRICE_LOW, 1);
    double MaHighELast = iMA("EURGBP", PERIOD_M5, EvaluatePeriods, 0, MODE_EMA, PRICE_HIGH, 1);
    double MaAvgELast = iMA("EURGBP", PERIOD_M5, EvaluatePeriods, 0, MODE_EMA, PRICE_TYPICAL, 1);
    double MaLow = iMA("EURGBP", PERIOD_M5, EvaluatePeriods, 0, MODE_SMA, PRICE_LOW, 0);
    double MaHigh = iMA("EURGBP", PERIOD_M5, EvaluatePeriods, 0, MODE_SMA, PRICE_HIGH, 0);
    double MaLowLast = iMA("EURGBP", PERIOD_M5, EvaluatePeriods, 0, MODE_SMA, PRICE_LOW, 1);
    double MaHighLast = iMA("EURGBP", PERIOD_M5, EvaluatePeriods, 0, MODE_SMA, PRICE_HIGH, 1);
    if(TotalOrdersCount() <= 10)
    {
      int result = 0;
      //El minimo ponderado crusa el minimo exponencial
      //Print("Aqui: ", MaLowLast, MaLowELast, MaLow, MaLowE);
      bool isDown = (MaLowLast >= MaLowELast &&  MaLow <= MaLowE && High[0]<= MaAvgE)
                    || (Open[1]<=MaLowLast && High[1]>MaHigh);
      bool isUp = Close[1] >= MaHighELast && Open[1] >= MaHighELast
                  && Close[0] >= MaHighE && Open[0] >= MaHighE
                  && MaLowE >= MaLow;
      bool canPlaceBuy = lastBuyTime != (int)Time[0] && TotalBuyOrdersCount()<=4;
      bool canPlaceSell = lastBuyTime != (int)Time[0] && TotalSellOrdersCount()<=4;
      //Print("Compra? ",isDown, canBuy, lastBuyTime, (int)Time[0]);
      if(isDown && canPlaceBuy) // Here is your open buy rule
      {
          Print("Orde compra de: ", ExpertName);
          result = OrderSend("EURGBP", OP_BUY, Lots, Ask, Slippage, 0, 0,"Alograg propuso", MagicNumber, 0, Blue);
          if(result > 0)
          {
          TheStopLoss=0;
          TheTakeProfit=0;
          if(TakeProfit>0) TheTakeProfit = Ask + TakeProfit * MyPoint;
          if(StopLoss>0) TheStopLoss = Ask - StopLoss * MyPoint;
          //hasOrder = OrderSelect(result, SELECT_BY_TICKET);
          //hasOrder = OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(TheStopLoss, Digits), NormalizeDouble(TheTakeProfit, Digits), 0, Green);
          lastBuyTime = Time[0];
          }
      }
      if(isUp && canPlaceSell) // Here is your open buy rule
      {
          Print("Orden centa de: ", ExpertName);
          result = OrderSend("EURGBP", OP_SELL, Lots, Bid, Slippage, 0, 0,"Alograg propuso", MagicNumber, 0, Blue);
          if(result > 0)
          {
          TheStopLoss=0;
          TheTakeProfit=0;
          if(TakeProfit>0) TheTakeProfit = Bid + TakeProfit * MyPoint;
          if(StopLoss>0) TheStopLoss = Bid - StopLoss * MyPoint;
          //hasOrder = OrderSelect(result, SELECT_BY_TICKET);
          //hasOrder = OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(TheStopLoss, Digits), NormalizeDouble(TheTakeProfit, Digits), 0, Green);
          lastBuyTime = Time[0];
          }
      }
    }
    int countOrders = OrdersTotal();
    for(int cnt=0; cnt < countOrders; cnt++)
    {
      hasOrder = OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      bool isWorkingOrder = OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber;
      if(isWorkingOrder){
        bool isBuy = OrderType() == OP_BUY;
        bool isSell = OrderType() == OP_SELL;
        bool hasPositiveProfit = OrderProfit()>((1+MinProfit)*OrderOpenPrice());
        bool canSell;
        if(isBuy)
        {
          canSell = (int)OrderOpenTime() != (int)Time[0] && hasPositiveProfit;
          bool lastLowOnTop = Low[1] >= MaHighLast && Low[1] >= MaAvgELast && Between(Low[0], MaHighE, MaAvgE);
          //Print("Evaluar",canSell, lastLowOnTop);
          if(canSell && lastLowOnTop)
          {
            hasOrder = OrderClose(OrderTicket(), OrderLots() ,OrderClosePrice(), Slippage, Red);
            Print("Cierre de: ", ExpertName);
          }
          if(hasOrder && TrailingStop>0)
          {
            if(Bid - OrderOpenPrice() > MyPoint * TrailingStop)
            {
              if(OrderStopLoss() < Bid - MyPoint * TrailingStop)
              {
                Print("Subir limite: ", Bid - TrailingStop * MyPoint);
                hasOrder = OrderModify(OrderTicket(), OrderOpenPrice(), Bid - TrailingStop * MyPoint, OrderTakeProfit(), 0, Green);
              }
            }
          }
        }
        if(isSell)
        {
          bool canClose = (int)OrderOpenTime() != (int)Time[0] && OrderProfit()>0.5;
          bool lastLowOnLow = Close[1] <= MaLowELast && High[0]<MaLow
                              && MaLowE>MaLowELast;
          //Print("Evaluar",canSell, lastLowOnTop);
          if(canClose && lastLowOnLow)
          {
            hasOrder = OrderClose(OrderTicket(), OrderLots() ,OrderClosePrice(), Slippage, Red);
            Print("Cierre de: ", ExpertName);
          }
          if(hasOrder && TrailingStop>0)
          {
            if(Bid - OrderOpenPrice() > MyPoint * TrailingStop)
            {
              if(OrderStopLoss() < Ask - MyPoint * TrailingStop)
              {
                Print("Subir limite: ", Ask - TrailingStop * MyPoint);
                hasOrder = OrderModify(OrderTicket(), OrderOpenPrice(), Ask - TrailingStop * MyPoint, OrderTakeProfit(), 0, Green);
              }
            }
          }
        }
      }
    }
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
