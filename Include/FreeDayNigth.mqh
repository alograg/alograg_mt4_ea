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
  if (!(TimeHour(Time[0]) >= 23 && TimeMinute(Time[0]) >= 45 && CheckNewBar()))
    return;
  double gls = getLotSize();
  if (gls < 0.01)
    return;
  PrintLog("FreeDayNigth");
  double CurrOpen = iMACD(Symbol(), PERIOD_D1, 12, 26, 9, PRICE_TYPICAL, MODE_SIGNAL, 0);
  double PrevClose = iMACD(Symbol(), PERIOD_D1, 12, 26, 9, PRICE_TYPICAL, MODE_SIGNAL, 1);
  int Ticket;
  //---- TRADE
  if (CurrOpen > PrevClose) {
    Ticket = OrderSendReliable(Symbol(), OP_BUY, gls, Ask, 3, 0,
                               0, FreeDayNigthBuyComment,
                               FreeDayNigthMagicBuy, 0, Blue);
  }
  if (CurrOpen < PrevClose) {
    Ticket = OrderSendReliable(Symbol(), OP_SELL, gls, Bid, 3, 0,
                               0, FreeDayNigthSellComment,
                               FreeDayNigthMagicSell, 0, Pink);
  }
}
