/*-----------------------------------------------------------------+
|                                                   MorningWork.mqh |
|                                          Copyright 2017, Alograg |
|                                           https://www.alograg.me |
+-----------------------------------------------------------------*/

#property copyright "Copyright 2017, Alograg"
#property link "https://www.alograg.me"
#property version propVersion
#property strict

#include "Utilities.mqh"
#include "OrderReliable_2011.01.07.mqh"
#include "CloseAllProfited.mqh"

string MorningWorkComment = eaName + ": MorningWork";
double TempArray[];

void MorningWork() {
  if (!CheckNewBar())
    return;
  double MacdCurrent, MacdPrevious, SignalCurrent, SignalPrevious, TendanceMacd,
      TendanceSignal;
  int cnt, ticket, total;
  // variables
  TendanceMacd =
      iMACD(Symbol(), PERIOD_H1, 12, 26, 9, PRICE_TYPICAL, MODE_MAIN, 0);
  TendanceSignal =
      iMACD(Symbol(), PERIOD_H1, 12, 26, 9, PRICE_TYPICAL, MODE_SIGNAL, 0);
  MacdCurrent =
      iMACD(Symbol(), PERIOD_M15, 12, 26, 9, PRICE_TYPICAL, MODE_MAIN, 0);
  MacdPrevious =
      iMACD(Symbol(), PERIOD_M15, 12, 26, 9, PRICE_TYPICAL, MODE_MAIN, 1);
  SignalCurrent =
      iMACD(Symbol(), PERIOD_M15, 12, 26, 9, PRICE_TYPICAL, MODE_SIGNAL, 0);
  SignalPrevious =
      iMACD(Symbol(), PERIOD_M15, 12, 26, 9, PRICE_TYPICAL, MODE_SIGNAL, 1);
  double SignalStrenght =
             NormalizeDouble(MathAbs(MacdCurrent - SignalCurrent), Digits) /
             getPipValue(),
         SignalPosition =
             NormalizeDouble(MathAbs(MacdCurrent), Digits) / getPipValue();
  if (SignalPosition < 1) {
    return;
  }
  double lotsForTransaction = getLotSize();
  if (lotsForTransaction <= 0)
    return;
  //--- check for long position (BUY) possibility
  if (MacdCurrent > SignalCurrent && MacdPrevious < SignalPrevious &&
      TendanceMacd < 0) {
    ticket = OrderSendReliable(Symbol(), OP_BUY, lotsForTransaction, Ask, 3, 0,
                               0, MorningWorkComment, MagicNumber, 0, Green);
  }
  //--- check for short position (SELL) possibility
  if (MacdCurrent < SignalCurrent && MacdPrevious > SignalPrevious &&
      TendanceMacd > 0) {
    ticket = OrderSendReliable(Symbol(), OP_SELL, lotsForTransaction, Bid, 3, 0,
                               0, MorningWorkComment, MagicNumber, 0, Red);
  }
}