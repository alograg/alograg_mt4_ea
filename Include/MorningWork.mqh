/*------------------------+
|         MorningWork.mqh |
| Copyright 2017, Alograg |
|  https://www.alograg.me |
+------------------------*/

#property copyright "Copyright 2017, Alograg"
#property link "https://www.alograg.me"
#property version propVersion
#property strict

#include "Utilities.mqh"
#include "OrderReliable_2011.01.07.mqh"

string MorningWorkComment = eaName + ": MorningWork";
double TempArray[];
double TendanceSignal = 0, TendanceSignalPrevious = 0;

void MorningWork() {
  if (!CheckNewBar())
    return;
  double MacdCurrent, MacdPrevious, SignalCurrent, SignalPrevious, TendanceMacd,
      TendanceMacdPrevious;
  int cnt, ticket, total;
  // variables
  MacdCurrent =
      iMACD(Symbol(), shortWork, 12, 26, 9, PRICE_TYPICAL, MODE_MAIN, 0);
  double SignalPosition =
      NormalizeDouble(MathAbs(MacdCurrent), Digits) / getPipValue();
  if (SignalPosition < 1)
    return;
  double lotsForTransaction = getLotSize();
  if (lotsForTransaction <= 0)
    return;
  TendanceMacd =
      iMACD(Symbol(), PERIOD_H4, 12, 26, 9, PRICE_TYPICAL, MODE_MAIN, 0);
  TendanceSignal =
      iMACD(Symbol(), PERIOD_H4, 12, 26, 9, PRICE_TYPICAL, MODE_SIGNAL, 0);
  TendanceMacdPrevious =
      iMACD(Symbol(), PERIOD_H4, 12, 26, 9, PRICE_TYPICAL, MODE_MAIN, 1);
  TendanceSignalPrevious =
      iMACD(Symbol(), PERIOD_H4, 12, 26, 9, PRICE_TYPICAL, MODE_SIGNAL, 1);
  MacdPrevious =
      iMACD(Symbol(), shortWork, 12, 26, 9, PRICE_TYPICAL, MODE_MAIN, 1);
  SignalCurrent =
      iMACD(Symbol(), shortWork, 12, 26, 9, PRICE_TYPICAL, MODE_SIGNAL, 0);
  SignalPrevious =
      iMACD(Symbol(), shortWork, 12, 26, 9, PRICE_TYPICAL, MODE_SIGNAL, 1);
  bool canBuy = MacdCurrent > SignalCurrent && MacdPrevious <= SignalPrevious &&
                TendanceMacd < 0 && TendanceSignalPrevious < TendanceSignal;
  bool canSell = MacdCurrent < SignalCurrent &&
                 MacdPrevious >= SignalPrevious && TendanceMacd > 0 &&
                 TendanceSignalPrevious > TendanceSignal;
  // Print("MorningWork: buy ("+ canBuy + "), sell ("+ canSell +")");
  //--- check for long position (BUY) possibility
  if (canBuy) {
    ticket = OrderSendReliable(Symbol(), OP_BUY, lotsForTransaction, Ask, 3, 0,
                               0, MorningWorkComment, MagicNumber, 0, Green);
  }
  //--- check for short position (SELL) possibility
  if (canSell) {
    ticket = OrderSendReliable(Symbol(), OP_SELL, lotsForTransaction, Bid, 3, 0,
                               0, MorningWorkComment, MagicNumber, 0, Red);
  }
}