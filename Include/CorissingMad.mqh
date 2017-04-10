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
#include "CorissingMad.mqh"

bool currentBuys = 0;
bool currentSells = 0;

bool isToUp() {
  double currentClose = Close[0];
  double lastClose = Close[1];
  double preLastClose = Close[2];
  double redClose = iMA(Symbol(), PERIOD_M1, 10, 0, MODE_EMA, PRICE_LOW, 1);
  double yellowLowClose =
      iMA(Symbol(), PERIOD_M1, 10, 0, MODE_SMA, PRICE_LOW, 1);
  double greenOpen = iMA(Symbol(), PERIOD_M1, 10, 0, MODE_EMA, PRICE_HIGH, 0);
  double yellowHighOpen =
      iMA(Symbol(), PERIOD_M1, 10, 0, MODE_SMA, PRICE_HIGH, 0);
  bool fromDown = preLastClose < redClose && lastClose < redClose &&
                  preLastClose < yellowLowClose && lastClose < yellowLowClose;
  bool goUp = currentClose > greenOpen && currentClose > yellowHighOpen &&
              greenOpen > yellowHighOpen;
  double size = NormalizeDouble(Open[0] - Close[0], Digits - 1);
  bool doubleSize =
      size > 0 &&
      NormalizeDouble(MathAbs(Open[1] - Close[1]), Digits) * 2 < size;
  return (fromDown && goUp) || doubleSize;
}

bool isToDown() {
  double currentClose = Close[0];
  double lastClose = Close[1];
  double greenOpenLast =
      iMA(Symbol(), PERIOD_M15, 10, 0, MODE_EMA, PRICE_HIGH, 1);
  double yellowHighOpenLast =
      iMA(Symbol(), PERIOD_M15, 10, 0, MODE_SMA, PRICE_HIGH, 1);
  double greenOpen = iMA(Symbol(), PERIOD_M15, 10, 0, MODE_EMA, PRICE_HIGH, 0);
  double yellowHighOpen =
      iMA(Symbol(), PERIOD_M15, 10, 0, MODE_SMA, PRICE_HIGH, 0);
  double yellowLowClose =
      iMA(Symbol(), PERIOD_M15, 10, 0, MODE_EMA, PRICE_LOW, 0);
  bool upDown =
      greenOpenLast > greenOpen && yellowHighOpenLast > yellowHighOpen;
  bool goDown = currentClose > greenOpen && currentClose > yellowHighOpen;
  double size = NormalizeDouble(Open[0] - Close[0], Digits - 1);
  bool doubleSize =
      size < 0 &&
      NormalizeDouble(MathAbs(Open[1] - Close[1]), Digits) * 2 > size;
  return (upDown && goDown) || doubleSize;
}

double crossingOrder(int type, double price) {
  return OrderSendReliable(Symbol(), type, getLotSize(), price, 3, 0, 0,
                           eaName + ": Crossing." + IntegerToString(type),
                           MagicNumber, 0, Blue);
}

void exitBuys() {
  int hasClose, iClosed = 0;
  double profit, minCents = 0.05;
  int nowHour = TimeHour(Time[0]);
  bool isCurrentDown = isToDown();
  string comment = eaName + ": Crossing." + IntegerToString(OP_BUY);
  for (int i = 0; i < totalOrders; i++) {
    if (!OrderSelect(i, SELECT_BY_POS))
      continue;
    profit = NormalizeDouble(
        OrderProfit() + OrderCommission() + OrderSwap() - minCents, 2);
    if (OrderSymbol() == Symbol() && isFornComment(comment) && profit > 0 &&
        OrderType() == OP_BUY) {
      if (TimeHour(OrderOpenTime()) != nowHour || isCurrentDown) {
        hasClose =
            OrderCloseReliable(OrderTicket(), OrderLots(), Bid, 4, White);
        currentBuys--;
      }
    }
  }
}

void exitSell() {
  int hasClose, iClosed = 0;
  double profit, minCents = 0.07;
  int nowHour = TimeHour(Time[0]);
  bool isCurrentDown = isToDown();
  string comment = eaName + ": Crossing." + IntegerToString(OP_SELL);
  double yellowLowClose =
      iMA(Symbol(), PERIOD_M15, 10, 0, MODE_EMA, PRICE_LOW, 0);
  for (int i = 0; i < totalOrders; i++) {
    if (!OrderSelect(i, SELECT_BY_POS))
      continue;
    profit = NormalizeDouble(
        OrderProfit() + OrderCommission() + OrderSwap() - minCents, 2);
    if (OrderSymbol() == Symbol() && isFornComment(comment) && profit > 0 &&
        OrderType() == OP_SELL) {
      if (TimeHour(OrderOpenTime()) != nowHour || isCurrentDown) {
        hasClose =
            OrderCloseReliable(OrderTicket(), OrderLots(), Ask, 4, White);
        currentSells--;
      }
    }
  }
}

void Crossing() {
  if (isToUp() && currentBuys == 0) {
    crossingOrder(OP_BUY, Ask);
    currentBuys++;
  }
  if (isToDown() && currentSells == 0) {
    crossingOrder(OP_SELL, Bid);
    currentSells++;
  }
  exitBuys();
  exitSell();
}