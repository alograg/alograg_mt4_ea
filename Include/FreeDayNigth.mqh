/*-----------------------------------------------------------------+
|                                                   FreeDayNigth.mqh |
|                                          Copyright 2017, Alograg |
|                                           https://www.alograg.me |
+-----------------------------------------------------------------*/

#property copyright "Copyright 2017, Alograg"
#property link "https://www.alograg.me"
#property version propVersion
#property strict

#include "Utilities.mqh"
#include "CloseAllProfited.mqh"
#include "OrderReliable_2011.01.07.mqh"

bool hasOne = false;
int FreeDayNigthMagicSell = 7603845;
int FreeDayNigthMagicBuy = 7603675;
string FreeDayNigthSellComment = eaName + ": FreeDay.S";
string FreeDayNigthBuyComment = eaName + ": FreeDay.B";

void FreeDayNigth(double GapRange = 5, double SL_Factor = 1, double TP_Factor = 1, double MM_Risk = 2)
{
  bool ToTrade = COT(OP_BUY, FreeDayNigthMagicBuy) == 0 && COT(OP_SELL, FreeDayNigthMagicSell) == 0;
  if (!ToTrade || hasOne)
  {
    if (TimeDayOfWeek(time0) != 5)
    {
      CloseAllProfited(FreeDayNigthSellComment);
      CloseAllProfited(FreeDayNigthBuyComment);
    }
    return;
  }
  if (TimeDayOfWeek(time0) != 5)
  {
    hasOne = false;
    return;
  }
  if (!(TimeHour(Time[0]) >= 23 && TimeMinute(Time[0]) > 55))
    return;
  double MyPoint = getCurrentPoint();
  double CurrOpen = iMA(Symbol(), PERIOD_D1, 10, 0, MODE_EMA, PRICE_MEDIAN, 0);
  double PrevClose = iMA(Symbol(), PERIOD_D1, 10, 0, MODE_EMA, PRICE_MEDIAN, 1);
  //---- TP / SL
  double ATR = iATR(Symbol(), PERIOD_D1, 13, 0);
  double Spread = MarketInfo(Symbol(), MODE_SPREAD) * Point;
  double TakeProfit = ATR * TP_Factor;
  double StopLoss = (ATR * SL_Factor) + Spread;
  //---- TRADE
  int Ticket;
  double gls = getLotSize(MM_Risk, 0.2);
  if (gls < 0.01)
    return;
  if (gls >= 1)
    StopLoss *= pareto - (gls - pareto);
  if (IsTesting())
    Print("FreeDayNigth");
  if (CurrOpen < PrevClose)
  {
    Ticket = OrderSendReliable(Symbol(), OP_BUY, gls, Ask, 3, Ask - StopLoss, Ask + TakeProfit, FreeDayNigthBuyComment, FreeDayNigthMagicBuy, 0, Blue);
  }
  if (CurrOpen > PrevClose)
  {
    StopLoss = (ATR * SL_Factor / 3) + Spread;
    Ticket = OrderSendReliable(Symbol(), OP_SELL, gls, Bid, 3, Bid + StopLoss, Bid - TakeProfit, FreeDayNigthSellComment, FreeDayNigthMagicSell, 0, Red);
  }
  hasOne = true;
}
