/*-----------------------------------------------------------------+
|                                                   WeekendGap.mqh |
|                                          Copyright 2017, Alograg |
|                                           https://www.alograg.me |
+-----------------------------------------------------------------*/

#property copyright "Copyright 2017, Alograg"
#property link "https://www.alograg.me"
#property version propVersion
#property strict

#include "Utilities.mqh"
#include "OrderReliable_2011.01.07.mqh"

void Gap(double GapRange = 5, double SL_Factor = 2, double TP_Factor = 1, double MM_Risk = 2)
{
  if (!isNewDay())
    return;
  int MagicSell = 760384;
  int MagicBuy = 760367;
  bool ToTrade = COT(OP_BUY, MagicBuy) == 0 && COT(OP_SELL, MagicSell) == 0;
  int toDay = TimeDayOfWeek(Time[0]);
  if (!ToTrade && toDay != 1)
    return;
  double MyPoint = getCurrentPoint();
  double CurrOpen = iOpen(Symbol(), Period(), 0);
  double PrevClose = iClose(Symbol(), Period(), 1);
  double Range = NormalizeDouble(MathAbs(PrevClose - CurrOpen), Digits);
  bool GAP = Range >= GapRange * MyPoint;
  if (IsTesting())
  {
    Print(ToTrade);
    Print(GAP);
    Print(Range);
    Print(GapRange * MyPoint);
  }
  //---- TP / SL
  double ATR = iATR(Symbol(), PERIOD_D1, 13, 1);
  double Spread = MarketInfo(Symbol(), MODE_SPREAD) * Point;
  double TakeProfit = ATR * TP_Factor;
  double StopLoss = (ATR * SL_Factor) + Spread;
  double RealStopLoos = getLotSize(MM_Risk, StopLoss);
  //---- TRADE
  int Ticket;
  if (GAP == true)
  {
    double gls = getLotSize(MM_Risk, StopLoss);
    if (IsTesting())
      Print("Gap");
    if (CurrOpen < PrevClose)
    {
      Ticket = OrderSendReliable(Symbol(), OP_BUY, gls, Ask, 3, Ask - StopLoss, Ask + TakeProfit, eaName + ": Gap.B", MagicBuy, 0, Blue);
    }
    if (CurrOpen > PrevClose)
    {
      StopLoss = (ATR * SL_Factor/3) + Spread;
      Ticket = OrderSendReliable(Symbol(), OP_SELL, gls, Bid, 3, Bid + StopLoss, Bid - TakeProfit, eaName + ": Gap.S", MagicSell, 0, Red);
    }
  }
}
