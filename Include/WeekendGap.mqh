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
#include "CloseAllProfited.mqh"
#include "OrderReliable_2011.01.07.mqh"

void Gap(double GapRange = 5, double SL_Factor = 1, double TP_Factor = 1,
         double MM_Risk = 2) {
  int MagicSell = 7603841;
  int MagicBuy = 7603671;
  string SellComment = eaName + ": Gap.S";
  string BuyComment = eaName + ": Gap.B";
  if (CheckNewBar()) {
    TrailingOpenOrders(5, MagicBuy, SellComment);
    TrailingOpenOrders(5, MagicSell, BuyComment);
  }
  if (!isNewDay())
    return;
  bool ToTrade = COT(OP_BUY, MagicBuy) == 0 && COT(OP_SELL, MagicSell) == 0;
  if (!ToTrade) {
    if (TimeDayOfWeek(time0) != 1) {
      CloseAllProfited(SellComment);
      CloseAllProfited(BuyComment);
    }
    return;
  }
  if (TimeDayOfWeek(time0) != 1)
    return;
  double MyPoint = getCurrentPoint();
  double CurrOpen = iOpen(Symbol(), Period(), 0);
  double PrevClose = iClose(Symbol(), Period(), 1);
  double Range = NormalizeDouble(MathAbs(PrevClose - CurrOpen), Digits);
  bool GAP = Range >= GapRange * MyPoint;
  //---- TP / SL
  double ATR = iATR(Symbol(), PERIOD_D1, 13, 1);
  double Spread = MarketInfo(Symbol(), MODE_SPREAD) * Point;
  double TakeProfit = ATR * TP_Factor;
  double StopLoss = (ATR * SL_Factor) + Spread;
  //---- TRADE
  int Ticket;
  if (GAP == true) {
    double gls = getLotSize(MM_Risk, 0.2);
    if (gls < 0.01)
      return;
    if (IsTesting())
      Print("Gap");
    if (CurrOpen < PrevClose) {
      Ticket =
          OrderSendReliable(Symbol(), OP_BUY, gls, Ask, 3, Ask - StopLoss,
                            Ask + TakeProfit, BuyComment, MagicBuy, 0, Blue);
    }
    if (CurrOpen > PrevClose) {
      StopLoss = (ATR * SL_Factor / 3) + Spread;
      Ticket =
          OrderSendReliable(Symbol(), OP_SELL, gls, Bid, 3, Bid + StopLoss,
                            Bid - TakeProfit, SellComment, MagicSell, 0, Red);
    }
  }
}
