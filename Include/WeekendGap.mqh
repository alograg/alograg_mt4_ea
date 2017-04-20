/*-----------------------------------------------------------------+
|                                                   WeekendGap.mqh |
|                                          Copyright 2017, Alograg |
|                                           https://www.alograg.me |
+-----------------------------------------------------------------*/

#property copyright "Copyright 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict

#include "Utilities.mqh"
#include "CloseAllProfited.mqh"
#include "OrderReliable_2011.01.07.mqh"

int WeekendGapMagicSell = 7603841;
int WeekendGapMagicBuy = 7603671;
string WeekendGapSellComment = eaName + ": Gap.S";
string WeekendGapBuyComment = eaName + ": Gap.B";

void WeekendGap(double GapRange = 5, double SL_Factor = 1, double TP_Factor = 1,
                double MM_Risk = 2) {
  if (TimeDayOfWeek(Time[0]) != 1)
    return;
  if (TimeHour(Time[0]) >= 1 || TimeMinute(Time[0]) >= 1 || !CheckNewBar())
    return;
  double gls = getLotSize();
  if (gls < 0.01)
    return;
  Print("Gap open: " + gls);
  double CurrOpen = iOpen(Symbol(), Period(), 0);
  double PrevClose = iClose(Symbol(), Period(), 1);
  double Range = NormalizeDouble(MathAbs(PrevClose - CurrOpen), Digits);
  int Ticket;
  //---- TRADE
  if (CurrOpen < PrevClose) {
    Ticket =
        OrderSendReliable(Symbol(), OP_BUY, gls, Ask, 3, 0, 0,
                          WeekendGapBuyComment, WeekendGapMagicBuy, 0, Blue);
  }
  if (CurrOpen > PrevClose) {
    Ticket =
        OrderSendReliable(Symbol(), OP_SELL, gls, Bid, 3, 0, 0,
                          WeekendGapSellComment, WeekendGapMagicSell, 0, Red);
  }
}
