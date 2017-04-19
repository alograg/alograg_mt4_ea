/*------------------------+
|                 YES.mqh |
|   Yick Enhanced Stealth |
| Copyright 2017, Alograg |
|  https://www.alograg.me |
+------------------------*/
// Propiedades
#property copyright "Copyright 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Constantes
int NumberofRetry = 3;
double OrderHiddenTP = 90;    // In Point, 5 Digit Broker
double OrderHiddenSL = 90;    // In Point, 5 Digit Broker
double OrderTS1 = 20;         // In Point, 5 Digit Broker
double OrderTS1Trigger = 50;  // In Point, 5 Digit Broker
double OrderTS2 = 50;         // In Point, 5 Digit Broker
double OrderTS2Trigger = 100; // In Point, 5 Digit Broker
double OrderTS3 = 100;        // In Point, 5 Digit Broker
double OrderTS3Trigger = 200; // In Point, 5 Digit Broker
double OrderTS4 = 200;        // In Point, 5 Digit Broker
double OrderTS4Trigger = 400; // In Point, 5 Digit Broker
bool OrderTS5Jump = FALSE;
bool BreakEven = FALSE;
int BreakEvenTime = 604800; // Time Unit Seconds
double BreakEvenTP = 20;    // In Point, 5 Digit Broker

double OrderArray[][14];
int TotalNumberOfOrders;
double AvereageCandle = -1;

void yesInit() {
  TotalNumberOfOrders = OrdersTotal();
  ArrayResize(OrderArray, TotalNumberOfOrders);
}
void yesProcess() {
  int i, j, icnt, jcnt, t, OrderTickets, OrderArrayIdx, FoundZeroIdx,
      OrderLongShort;
  int TempNumberOfOrders, CountNumberOfOrders;
  int OrderProfitPip, OrderLossPip;
  double ask, bid, point;
  bool TradeFound, OrderFound = FALSE, FoundZero = FALSE, OrderCloseStatus;
  if (isNewDay() || AvereageCandle < 0) {
    AvereageCandle = NormalizeDouble(
        MathAbs(iOpen(Symbol(), PERIOD_D1, 1) - iClose(Symbol(), PERIOD_D1, 1)),
        Digits);
    PrintLog("Candel: " + AvereageCandle);
    OrderHiddenTP = round((AvereageCandle / getPipValue()) * 10);
    PrintLog("Pibs: " + OrderHiddenTP);
    OrderHiddenSL =
        round(AvereageCandle / getPipValue()) + (getSpread() / getPipValue());
    OrderHiddenSL *= 50;
    OrderTS3 = OrderHiddenTP / pareto;
    OrderTS2Trigger = OrderTS3;
    OrderTS2 = OrderTS2Trigger / 2;
    OrderTS1Trigger = OrderTS2;
    OrderTS1 = (OrderTS1Trigger / 5) * 2;
    OrderTS3Trigger = OrderTS3 * 2;
    OrderTS4 = OrderTS3Trigger;
    OrderTS4Trigger = OrderTS4 * 2;
    // PrintLog("Pips Yesterday: " + AvereageCandle / getPipValue());
  }
  if (TotalNumberOfOrders < OrdersTotal()) {
    TotalNumberOfOrders = OrdersTotal();
    ArrayResize(OrderArray, TotalNumberOfOrders);
    // PrintLog("OrderArray Size Increased to: " + TotalNumberOfOrders);
  }
  if (TotalNumberOfOrders > OrdersTotal()) {
    // Eliminate Manually Closed Trade, Other EA/Script Closed trade or Trade
    // that hits MT4 System TP/SL
    TempNumberOfOrders = OrdersTotal();
    CountNumberOfOrders = TempNumberOfOrders;
    for (icnt = TotalNumberOfOrders - 1; icnt >= 0; icnt--) {
      TradeFound = FALSE;
      for (jcnt = TempNumberOfOrders - 1; jcnt >= 0; jcnt--) {
        if (OrderSelect(jcnt, SELECT_BY_POS, MODE_TRADES)) {
          if (OrderArray[icnt][0] == OrderTicket()) {
            TradeFound = TRUE;
            break;
          }
        }
      }
      if (!TradeFound) {
        // PrintLog("Closed:" + OrderArray[icnt][0]);
        ResetOrderArray(icnt);
        PurgeElement(icnt);
        CountNumberOfOrders = TotalNumberOfOrders - 1;
        ArrayResize(OrderArray, CountNumberOfOrders);
        if (CountNumberOfOrders == TempNumberOfOrders)
          break;
      }
    }
    TotalNumberOfOrders = CountNumberOfOrders;
    // PrintLog("OrderArray Size Decreased to: " + TotalNumberOfOrders);
  }
  for (i = TotalNumberOfOrders - 1; i >= 0; i--) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if (OrderSymbol() != Symbol())
        continue;
      // PrintLog(i + "/" + TotalNumberOfOrders + ">>" + OrderSymbol() + ">>" +
      //         OrderTicket() + ">>" + TotalNumberOfOrders);
      FoundZero = FALSE;
      OrderFound = FALSE;
      for (j = TotalNumberOfOrders - 1; j >= 0; j--) {
        // PrintLog("After reset:" + j + ">>" + OrderArray[j][0]);
        if (OrderArray[j][0] == OrderTicket()) {
          OrderFound = TRUE;
          OrderArrayIdx = j;
          break;
        }
        if ((OrderArray[j][0] == 0) && (!FoundZero) && (!OrderFound)) {
          FoundZero = TRUE;
          FoundZeroIdx = j;
        }
      }
      // PrintLog("OrderFound:" + OrderFound + ">> FoundZero:" + FoundZero +
      //         ">> TotalNumberOfOrders:" + (TotalNumberOfOrders - 1) + ">>" +
      //         i);
      if (!OrderFound && FoundZero) {
        OrderArray[FoundZeroIdx][0] = OrderTicket();
        OrderArray[FoundZeroIdx][1] = OrderMagicNumber();
        OrderArray[FoundZeroIdx][2] = OrderType();
        OrderArray[FoundZeroIdx][3] = OrderLots();
        OrderArray[FoundZeroIdx][4] = OrderOpenTime();
        OrderArray[FoundZeroIdx][5] = OrderOpenPrice();
        OrderArray[FoundZeroIdx][6] = OrderCommission();
        OrderArray[FoundZeroIdx][7] = OrderTakeProfit();
        OrderArray[FoundZeroIdx][8] = OrderStopLoss();
        OrderArray[FoundZeroIdx][9] = 0;  // TS1
        OrderArray[FoundZeroIdx][10] = 0; // TS2
        OrderArray[FoundZeroIdx][11] = 0; // TS3
        OrderArray[FoundZeroIdx][12] = 0; // TS4
        OrderArray[FoundZeroIdx][13] = 0; // TS5
        FoundZero = FALSE;
      } else {
        // Found the Order
        OrderLongShort = OrderArray[OrderArrayIdx][2];
        // Print ("OrderLongShort: "+OrderLongShort);
        bid = MarketInfo(OrderSymbol(), MODE_BID);
        ask = MarketInfo(OrderSymbol(), MODE_ASK);
        point = MarketInfo(OrderSymbol(), MODE_POINT);
        if (OrderLongShort == OP_BUY) {
          OrderProfitPip = (bid - OrderArray[OrderArrayIdx][5]) / point;
          OrderProfitPip += (OrderSwap() + OrderCommission()) / OrderLots() /
                            MarketInfo(Symbol(), MODE_TICKVALUE) *
                            MarketInfo(Symbol(), MODE_TICKSIZE);
          OrderLossPip = (OrderArray[OrderArrayIdx][5] - bid) / point;
          // Print
          // (OrderSymbol()+">>"+OrderArray[OrderArrayIdx][0]+">>"+OrderArray[OrderArrayIdx][8]+">>"+bid+">>"+ask+">>"+OrderLossPip+">>"+OrderHiddenSL);
          // Print ("Trailing1L:
          // "+OrderTicket()+">>"+OrderProfitPip+">>"+OrderTS1Trigger+">>"+OrderArray[OrderArrayIdx][9]);
          if ((OrderArray[OrderArrayIdx][9] == 0) &&
              (OrderProfitPip > OrderTS1Trigger)) {
            // PrintLog("Long Trailing Stop1 Activated at: " +
            //         (OrderOpenPrice() + (OrderTS1 * point)));
            OrderArray[OrderArrayIdx][9] =
                (OrderOpenPrice() + (OrderTS1 * point));
          }
          // Print ("Trailing2L:
          // "+OrderTicket()+">>"+OrderProfitPip+">>"+OrderTS2Trigger+">>"+OrderArray[OrderArrayIdx][10]);
          if ((OrderArray[OrderArrayIdx][9] != 0) &&
              (OrderArray[OrderArrayIdx][10] == 0) &&
              (OrderProfitPip > OrderTS2Trigger)) {
            // PrintLog("Long Trailing Stop2 Activated at: " +
            //         (OrderOpenPrice() + (OrderTS2 * point)));
            OrderArray[OrderArrayIdx][10] =
                (OrderOpenPrice() + (OrderTS2 * point));
          }
          // Print ("Trailing3L:
          // "+OrderTicket()+">>"+OrderProfitPip+">>"+OrderTS3Trigger+">>"+OrderArray[OrderArrayIdx][11]);
          if ((OrderArray[OrderArrayIdx][9] != 0) &&
              (OrderArray[OrderArrayIdx][10] != 0) &&
              (OrderArray[OrderArrayIdx][11] == 0) &&
              (OrderProfitPip > OrderTS3Trigger)) {
            // PrintLog("Long Trailing Stop3 Activated at: " +
            //         (OrderOpenPrice() + (OrderTS3 * point)));
            OrderArray[OrderArrayIdx][11] =
                (OrderOpenPrice() + (OrderTS3 * point));
          }
          // First time TS4
          // Print ("Trailing4L:
          // "+OrderTicket()+">>"+OrderProfitPip+">>"+OrderTS4Trigger+">>"+OrderArray[OrderArrayIdx][12]);
          if ((OrderArray[OrderArrayIdx][9] != 0) &&
              (OrderArray[OrderArrayIdx][10] != 0) &&
              (OrderArray[OrderArrayIdx][11] != 0) &&
              (OrderArray[OrderArrayIdx][12] == 0) &&
              (OrderProfitPip > OrderTS4Trigger)) {
            // PrintLog("Long Trailing Stop4 Activated at: " +
            //         (OrderOpenPrice() + (OrderTS4 * point)));
            OrderArray[OrderArrayIdx][12] =
                (OrderOpenPrice() + (OrderTS4 * point));
            OrderArray[OrderArrayIdx][13] =
                (OrderOpenPrice() + (OrderTS4 * point));
          }
          // TS5 - Price Trailing
          // Print ("Trailing5L:
          // "+OrderTicket()+">>"+OrderProfitPip+">>"+OrderTS4Trigger+">>"+OrderArray[OrderArrayIdx][13]);
          if ((OrderArray[OrderArrayIdx][9] != 0) &&
              (OrderArray[OrderArrayIdx][10] != 0) &&
              (OrderArray[OrderArrayIdx][11] != 0) &&
              (OrderArray[OrderArrayIdx][12] != 0) &&
              ((bid + (OrderTS4 * point)) > OrderArray[OrderArrayIdx][13]) &&
              !OrderTS5Jump) {
            // PrintLog("Long Trigger Trailing Stop5 Activated at: " +
            //         (OrderArray[OrderArrayIdx][13] + (OrderTS4 * point)));
            OrderArray[OrderArrayIdx][13] = (bid - (OrderTS4 * point));
          }
          // TS5 - Jump Trailing
          // Print ("Trailing5LJ:
          // "+OrderTicket()+">>"+OrderProfitPip+">>"+OrderTS4Trigger+">>"+OrderArray[OrderArrayIdx][13]);
          if ((OrderArray[OrderArrayIdx][9] != 0) &&
              (OrderArray[OrderArrayIdx][10] != 0) &&
              (OrderArray[OrderArrayIdx][11] != 0) &&
              (OrderArray[OrderArrayIdx][12] != 0) &&
              ((bid + (2 * OrderTS4 * point)) >
               OrderArray[OrderArrayIdx][13]) &&
              OrderTS5Jump) {
            // PrintLog("Long Trigger Trailing Stop5 Activated at: " +
            //         (OrderArray[OrderArrayIdx][13] + (OrderTS4 * point)));
            OrderArray[OrderArrayIdx][13] =
                (OrderArray[OrderArrayIdx][13] + (OrderTS4 * point));
          }
          // Long Order Processing
          if (((OrderArray[OrderArrayIdx][9] != 0) &&
               (bid < OrderArray[OrderArrayIdx][9])) ||
              ((OrderArray[OrderArrayIdx][10] != 0) &&
               (bid < OrderArray[OrderArrayIdx][10])) ||
              ((OrderArray[OrderArrayIdx][11] != 0) &&
               (bid < OrderArray[OrderArrayIdx][11])) ||
              ((OrderArray[OrderArrayIdx][12] != 0) &&
               (bid < OrderArray[OrderArrayIdx][12])) ||
              ((OrderArray[OrderArrayIdx][13] != 0) &&
               (bid < OrderArray[OrderArrayIdx][13]))) {
            // PrintLog("Long:" + OrderTicket() +
            //         ". Trailing Stop Triggerred. Order Closed at: " + bid);
            // Close and Set zero of the orderarray item
            OrderCloseStatus = OrderCloseReliable(OrderTicket(), OrderLots(),
                                                  bid, slippage, DeepSkyBlue);
            if (OrderCloseStatus) {
              ResetOrderArray(OrderArrayIdx);
              PurgeElement(OrderArrayIdx);
              break;
            }
          } else if (OrderProfitPip >= OrderHiddenTP) {
            // PrintLog("Take Long Profit Now: " + OrderProfitPip);
            // Close and Set zero of the orderarray item
            OrderCloseStatus = OrderCloseReliable(OrderTicket(), OrderLots(),
                                                  bid, slippage, Blue);
            if (OrderCloseStatus) {
              ResetOrderArray(OrderArrayIdx);
              PurgeElement(OrderArrayIdx);
              break;
            }
          }
          if (OrderLossPip >= OrderHiddenSL) {
            // PrintLog("Stop Long Loss Now: " + OrderLossPip);
            // Close and Set zero of the orderarray item
            OrderCloseStatus = OrderCloseReliable(OrderTicket(), OrderLots(),
                                                  bid, slippage, DeepSkyBlue);
            if (OrderCloseStatus) {
              ResetOrderArray(OrderArrayIdx);
              PurgeElement(OrderArrayIdx);
              break;
            }
          }
          if (BreakEven && (TimeCurrent() >
                            (OrderArray[OrderArrayIdx][4] + BreakEvenTime)) &&
              (bid > (OrderArray[OrderArrayIdx][5] + (OrderTS4 * point)))) {
            // PrintLog("LongBE:" + OrderTicket() +
            //         ". Breakeven Triggerred. Order Closed at: " + bid);
            // Close and Set zero of the orderarray item
            OrderCloseStatus = OrderCloseReliable(OrderTicket(), OrderLots(),
                                                  bid, slippage, Navy);
            if (OrderCloseStatus) {
              ResetOrderArray(OrderArrayIdx);
              PurgeElement(OrderArrayIdx);
              break;
            }
          }
        }
        if (OrderLongShort == OP_SELL) {
          OrderProfitPip = (OrderArray[OrderArrayIdx][5] - ask) / point;
          OrderProfitPip += (OrderSwap() + OrderCommission()) / OrderLots() /
                            MarketInfo(Symbol(), MODE_TICKVALUE) *
                            MarketInfo(Symbol(), MODE_TICKSIZE);
          OrderLossPip = (ask - OrderArray[OrderArrayIdx][5]) / point;
           PrintLog(OrderSymbol() + ">>" + OrderArray[OrderArrayIdx][0] + ">>" + OrderArray[OrderArrayIdx][8] + ">>" + bid + ">>" + ask + ">>" + OrderLossPip + ">>" + OrderHiddenSL);
          PrintLog("Trailing1S: "+OrderTicket()+">>"+OrderProfitPip+">>"+OrderTS1Trigger+">>"+OrderArray[OrderArrayIdx][9]);
          if ((OrderArray[OrderArrayIdx][9] == 0) &&
              (OrderProfitPip > OrderTS1Trigger)) {
             PrintLog("Short Trailing Stop1 Activated at: " + (OrderOpenPrice() - (OrderTS1 * point)));
            OrderArray[OrderArrayIdx][9] =
                (OrderOpenPrice() - (OrderTS1 * point));
          }
           PrintLog("Trailing2S: "+OrderTicket()+">>"+OrderProfitPip+">>"+OrderTS2Trigger+">>"+OrderArray[OrderArrayIdx][10]);
          if ((OrderArray[OrderArrayIdx][9] != 0) &&
              (OrderArray[OrderArrayIdx][10] == 0) &&
              (OrderProfitPip > OrderTS2Trigger)) {
            PrintLog("Short Trailing Stop2 Activated at: " + (OrderOpenPrice() - (OrderTS2 * point)));
            OrderArray[OrderArrayIdx][10] =
                (OrderOpenPrice() - (OrderTS2 * point));
          }
          PrintLog("Trailing3S: "+OrderTicket()+">>"+OrderProfitPip+">>"+OrderTS3Trigger+">>"+OrderArray[OrderArrayIdx][11]);
          if ((OrderArray[OrderArrayIdx][9] != 0) &&
              (OrderArray[OrderArrayIdx][10] != 0) &&
              (OrderArray[OrderArrayIdx][11] == 0) &&
              (OrderProfitPip > OrderTS3Trigger)) {
            PrintLog("Short Trailing Stop3 Activated at: " + (OrderOpenPrice() - (OrderTS3 * point)));
            OrderArray[OrderArrayIdx][11] =
                (OrderOpenPrice() - (OrderTS3 * point));
          }
          // First time TS4
          PrintLog("Trailing4S: "+OrderTicket()+">>"+OrderProfitPip+">>"+OrderTS4Trigger+">>"+OrderArray[OrderArrayIdx][12]);
          if ((OrderArray[OrderArrayIdx][9] != 0) &&
              (OrderArray[OrderArrayIdx][10] != 0) &&
              (OrderArray[OrderArrayIdx][11] != 0) &&
              (OrderArray[OrderArrayIdx][12] == 0) &&
              (OrderProfitPip > OrderTS4Trigger)) {
            PrintLog("Short Trailing Stop4 Activated at: " +(OrderOpenPrice() - (OrderTS4 * point)));
            OrderArray[OrderArrayIdx][12] =
                (OrderOpenPrice() - (OrderTS4 * point));
            OrderArray[OrderArrayIdx][13] =
                (OrderOpenPrice() - (OrderTS4 * point));
          }
          // TS5 - Price Trailing
          PrintLog("Trailing5S: "+OrderTicket()+">>"+OrderProfitPip+">>"+OrderTS4Trigger+">>"+OrderArray[OrderArrayIdx][13]);
          if ((OrderArray[OrderArrayIdx][9] != 0) &&
              (OrderArray[OrderArrayIdx][10] != 0) &&
              (OrderArray[OrderArrayIdx][11] != 0) &&
              (OrderArray[OrderArrayIdx][12] != 0) &&
              ((ask - (OrderTS4 * point)) < OrderArray[OrderArrayIdx][13]) &&
              !OrderTS5Jump) {
            PrintLog("Short Trigger Trailing Stop5 Activated at: " + (OrderArray[OrderArrayIdx][13] - (OrderTS4 * point)));
            OrderArray[OrderArrayIdx][13] = (ask + (OrderTS4 * point));
          }
          // TS5 - Jump Trailing
          PrintLog("Trailing5JS: "+OrderTicket()+">>"+OrderProfitPip+">>"+OrderTS4Trigger+">>"+OrderArray[OrderArrayIdx][13]);
          if ((OrderArray[OrderArrayIdx][9] != 0) &&
              (OrderArray[OrderArrayIdx][10] != 0) &&
              (OrderArray[OrderArrayIdx][11] != 0) &&
              (OrderArray[OrderArrayIdx][12] != 0) &&
              ((ask - (2 * OrderTS4 * point)) <
               OrderArray[OrderArrayIdx][13]) &&
              OrderTS5Jump) {
            PrintLog("Short Trigger Trailing Stop5 Activated at: " + (OrderArray[OrderArrayIdx][13] - (OrderTS4 * point)));
            OrderArray[OrderArrayIdx][13] =
                (OrderArray[OrderArrayIdx][13] - (OrderTS4 * point));
          }
          // Short Order Processing
          if (((OrderArray[OrderArrayIdx][9] != 0) &&
               (ask > OrderArray[OrderArrayIdx][9])) ||
              ((OrderArray[OrderArrayIdx][10] != 0) &&
               (ask > OrderArray[OrderArrayIdx][10])) ||
              ((OrderArray[OrderArrayIdx][11] != 0) &&
               (ask > OrderArray[OrderArrayIdx][11])) ||
              ((OrderArray[OrderArrayIdx][12] != 0) &&
               (ask > OrderArray[OrderArrayIdx][12])) ||
              ((OrderArray[OrderArrayIdx][13] != 0) &&
               (ask > OrderArray[OrderArrayIdx][13]))) {
             PrintLog("Short:" + OrderTicket() + ". Trailing Stop Triggerred. Order Closed at: " + ask);
            // Close and Set zero of the orderarray item
            OrderCloseStatus = OrderCloseReliable(OrderTicket(), OrderLots(),
                                                  ask, slippage, DarkOrange);
            if (OrderCloseStatus) {
              ResetOrderArray(OrderArrayIdx);
              PurgeElement(OrderArrayIdx);
              break;
            }
          } else if (OrderProfitPip >= OrderHiddenTP) {
            PrintLog("Take Short Profit Now: " + OrderProfitPip);
            // Close and Set zero of the orderarray item
            OrderCloseStatus = OrderCloseReliable(OrderTicket(), OrderLots(),
                                                  ask, slippage, Red);
            if (OrderCloseStatus) {
              ResetOrderArray(OrderArrayIdx);
              PurgeElement(OrderArrayIdx);
              break;
            }
          }
          if (OrderLossPip >= OrderHiddenSL) {
            // PrintLog("Stop Short Loss Now: " + OrderLossPip);
            // Close and Set zero of the orderarray item
            OrderCloseStatus = OrderCloseReliable(OrderTicket(), OrderLots(),
                                                  ask, slippage, DarkOrange);
            if (OrderCloseStatus) {
              ResetOrderArray(OrderArrayIdx);
              PurgeElement(OrderArrayIdx);
              break;
            }
          }
          if (BreakEven && (TimeCurrent() >
                            (OrderArray[OrderArrayIdx][4] + BreakEvenTime)) &&
              (ask < (OrderArray[OrderArrayIdx][5] + (OrderTS4 * point)))) {
            // PrintLog("LongBE:" + OrderTicket() +
            //         ". Breakeven Triggerred. Order Closed at: " + ask);
            // Close and Set zero of the orderarray item
            OrderCloseStatus = OrderCloseReliable(OrderTicket(), OrderLots(),
                                                  ask, slippage, Maroon);
            if (OrderCloseStatus) {
              ResetOrderArray(OrderArrayIdx);
              PurgeElement(OrderArrayIdx);
              break;
            }
          }
        }
      }
      PrintLog("==================================");
    } // Order Select
  }   // For Loop
  TotalNumberOfOrders = OrdersTotal();
}
void ResetOrderArray(int idx) {
  // Print ("Set0: "+OrderArray[idx][0]);
  for (int k = 0; k < 15; k++) {
    OrderArray[idx][0] = 0;
  }
}

void PurgeElement(int pidx) {
  int asize = (ArraySize(OrderArray) / 14);
  int x = asize - 1, y, z;
  double temparr[][14];
  // PrintLog("ASize before purging: " + asize);
  if (OrderArray[pidx][0] == 0) {
    ArrayResize(temparr, x);
    for (y = 0; y < pidx; y++) {
      for (z = 0; z < 14; z++) { // Change to 14
        temparr[y][z] = OrderArray[y][z];
      }
    }
    for (y = pidx + 1; y < asize; y++) {
      for (z = 0; z < 14; z++) { // Change to 14
        temparr[(y - 1)][z] = OrderArray[y][z];
      }
    }
    ArrayResize(OrderArray, x);
    for (y = 0; y < x; y++) {
      for (z = 0; z < 14; z++) { // Change to 14
        OrderArray[y][z] = temparr[y][z];
      }
    }
  }
}