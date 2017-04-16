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
#include "OrderReliable_2011.01.07.mqh"

bool hasOne = false;
int FreeDayNigthMagicSell = 7603845;
int FreeDayNigthMagicBuy = 7603675;
string FreeDayNigthSellComment = eaName + ": FreeDay.S";
string FreeDayNigthBuyComment = eaName + ": FreeDay.B";

void FreeDayNigth(double GapRange = 5, double SL_Factor = 1,
                  double TP_Factor = 1, double MM_Risk = 2) {
  if (TimeDayOfWeek(time0) != 5)
    return;
  if (!(TimeHour(Time[0]) >= 23 && TimeMinute(Time[0]) > 55))
    return;
  double MyPoint = getCurrentPoint();
  double CurrOpen = iMA(Symbol(), PERIOD_D1, 10, 0, MODE_EMA, PRICE_MEDIAN, 0);
  double PrevClose = iMA(Symbol(), PERIOD_D1, 10, 0, MODE_EMA, PRICE_MEDIAN, 1);
  //---- TRADE
  int Ticket;
  double gls = getLotSize(MM_Risk, 0.2);
  if (gls < 0.01)
    return;
  if (gls >= 1)
    StopLoss *= pareto - (gls - pareto);
  PrintLog("FreeDayNigth");
  if (CurrOpen < PrevClose) {
    Ticket = OrderSendReliable(Symbol(), OP_BUY, gls, Ask, 3, 0,
                               0, FreeDayNigthBuyComment,
                               FreeDayNigthMagicBuy, 0, Blue);
  }
  if (CurrOpen > PrevClose) {
    Ticket = OrderSendReliable(Symbol(), OP_SELL, gls, Bid, 3, 0,
                               0, FreeDayNigthSellComment,
                               FreeDayNigthMagicSell, 0, Pink);
  }
}
