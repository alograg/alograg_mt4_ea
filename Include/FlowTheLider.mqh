/*------------------------+
|        FlowTheLider.mqh |
| Copyright 2017, Alograg |
|  https://www.alograg.me |
+------------------------*/

#property copyright "Copyright 2017, Alograg"
#property link "https://www.alograg.me"
#property version propVersion
#property strict

#include "Utilities.mqh"
#include "OrderReliable_2011.01.07.mqh"

string FlowTheLiderComment = eaName + ": FlowTheLider";

bool hasSell = false;

void FlowTheLider() {
  if (!CheckNewBar())
    return;
  int ticket;
  // variables
  double lotsForTransaction = getLotSize();
  if (lotsForTransaction <= 0)
    return;
  double SignalCurrent = NormalizeDouble(
      iMACD(Symbol(), PERIOD_H4, 12, 26, 9, PRICE_TYPICAL, MODE_MAIN, 0),
      Digits);
  double SignalPrevious1 = NormalizeDouble(
      iMACD(Symbol(), PERIOD_H4, 12, 26, 9, PRICE_TYPICAL, MODE_MAIN, 1),
      Digits);
  double diffSignals = MathAbs(SignalCurrent - SignalPrevious1);
  if (MathAbs(SignalCurrent) > getSpread()) {
    if (diffSignals < getSpread() / 2 &&
        !canOrderAsk((SignalCurrent - SignalPrevious1) > 0 ? OP_BUY : OP_SELL, PERIOD_D1)){
      return;
    }
  }
  double SignalPrevious2 = NormalizeDouble(
      iMACD(Symbol(), PERIOD_H4, 12, 26, 9, PRICE_TYPICAL, MODE_MAIN, 2),
      Digits);
  double SignalPrevious3 = NormalizeDouble(
      iMACD(Symbol(), PERIOD_H4, 12, 26, 9, PRICE_TYPICAL, MODE_MAIN, 3),
      Digits);
  double SignalPrevious4 = NormalizeDouble(
      iMACD(Symbol(), PERIOD_H4, 12, 26, 9, PRICE_TYPICAL, MODE_MAIN, 4),
      Digits);
  double SignalPrevious5 = NormalizeDouble(
      iMACD(Symbol(), PERIOD_H4, 12, 26, 9, PRICE_TYPICAL, MODE_MAIN, 5),
      Digits);
  bool canBuy = SignalCurrent > SignalPrevious1 &&
                SignalPrevious1 > SignalPrevious2 &&
                SignalPrevious2 > SignalPrevious3 &&
                SignalPrevious3 > SignalPrevious4 &&
                SignalPrevious4 > SignalPrevious5 &&
                canOrder(OP_BUY);
  bool canSell = SignalCurrent > 0 &&
                 SignalCurrent < SignalPrevious1 &&
                 SignalPrevious1 < SignalPrevious2 &&
                 SignalPrevious2 < SignalPrevious3 &&
                 SignalPrevious3 < SignalPrevious4 &&
                 SignalPrevious4 < SignalPrevious5 &&
                 canOrder(OP_SELL);
  AddNotify("FlowTheLider: buy (" + canBuy + "), sell (" + canSell + ")");
  //--- check for long position (BUY) possibility
  if (canBuy) {
    ticket = OrderSendReliable(Symbol(), OP_BUY, lotsForTransaction, Ask, 3, 0,
                               0, FlowTheLiderComment, MagicNumber, 0, Green);
    hasSell = FALSE;
  }
  //--- check for short position (SELL) possibility
  if (canSell) {
    ticket = OrderSendReliable(Symbol(), OP_SELL, lotsForTransaction, Bid, 3, 0,
                               0, FlowTheLiderComment, MagicNumber, 0, Red);
    hasSell = TRUE;
  }
}