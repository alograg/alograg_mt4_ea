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
double OrderHiddenTP = 90;  // In Point, 5 Digit Broker
double OrderHiddenSL = 90;  // In Point, 5 Digit Broker
double OrderTS = 20;        // In Point, 5 Digit Broker
double OrderTSTrigger = 50; // In Point, 5 Digit Broker
bool BreakEven = TRUE;

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
  bool TradeFound, OrderFound = FALSE, FoundZero = FALSE, OrderCloseStatus;
  if (isNewDay() || AvereageCandle < 0) {
    AvereageCandle = NormalizeDouble(
        MathAbs(iOpen(Symbol(), PERIOD_D1, 1) - iClose(Symbol(), PERIOD_D1, 1)),
        Digits);
    OrderHiddenTP = round((AvereageCandle / getPipValue()) / 2);
    // PrintLog("Candel: " + AvereageCandle);
    // PrintLog("Pibs: " + OrderHiddenTP);
    OrderTSTrigger = OrderHiddenTP - 1;
    OrderTS = round(OrderHiddenTP * pareto);
    OrderHiddenSL =
        round(AvereageCandle / getPipValue()) + (getSpread() / getPipValue());
    OrderHiddenSL *= 50;
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
      // PrintLog(i + "/" + TotalNumberOfOrders + ">>"
      // + OrderSymbol() + ">>"
      // +
      //         OrderTicket() + ">>"
      // + TotalNumberOfOrders);
      FoundZero = FALSE;
      OrderFound = FALSE;
      for (j = TotalNumberOfOrders - 1; j >= 0; j--) {
        // PrintLog("After reset:" + j + ">>"
        // + OrderArray[j][0]);
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
      //         ">> TotalNumberOfOrders:" + (TotalNumberOfOrders - 1) + ">>"
      // + i);
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
        OrderArray[FoundZeroIdx][9] = 0;  // TS
        OrderArray[FoundZeroIdx][10] = 0; // TST
        OrderArray[FoundZeroIdx][11] = 0; // TP
        OrderArray[FoundZeroIdx][12] = 0; // SL
        OrderArray[FoundZeroIdx][13] = 0; // -
        FoundZero = FALSE;
      } else {
        // Found the Order
        OrderLongShort = OrderArray[OrderArrayIdx][2];
        // Print ("OrderLongShort: "+OrderLongShort);
        OrderExtrasPip = (OrderSwap() + OrderCommission()) / OrderLots() /
                         MarketInfo(Symbol(), MODE_TICKVALUE) *
                         MarketInfo(Symbol(), MODE_TICKSIZE);
        if (OrderLongShort == OP_BUY) {
          OrderProfitPip = (Bid - OrderArray[OrderArrayIdx][5]) / getPipValue();
          OrderProfitPip += OrderExtrasPip;
          OrderLossPip = (OrderArray[OrderArrayIdx][5] - Bid) / getPipValue();
          OrderLossPip += OrderExtrasPip;
          if (OrderArray[FoundZeroIdx][12] == 0) {
            OrderArray[FoundZeroIdx][12] = OrderHiddenSL;
          }
          if (OrderArray[OrderArrayIdx][11] == 0) {
            OrderArray[OrderArrayIdx][11] == OrderHiddenTP;
          }
          if (OrderArray[OrderArrayIdx][9] == 0 &&
              OrderProfitPip >= OrderTSTrigger) {
            OrderArray[OrderArrayIdx][9] = OrderTS;
            OrderArray[OrderArrayIdx][10] = round(OrderTSTrigger * 1.5);
            // PrintLog("Long Trailing Stop Activated at: " + (OrderOpenPrice()
            // - (OrderTS * getPipValue())));
          } else if (OrderArray[OrderArrayIdx][10] != 0 &&
                     OrderProfitPip >= OrderArray[OrderArrayIdx][10]) {
            OrderArray[OrderArrayIdx][9] = OrderArray[OrderArrayIdx][10];
            OrderArray[OrderArrayIdx][10] +=
                MathAbs(round(OrderArray[OrderArrayIdx][10] / 2));
            // PrintLog("Long Trailing Stop Activated at: " + (OrderOpenPrice()
            // - (OrderArray[OrderArrayIdx][10] * getPipValue())));
          }
          if (OrderArray[OrderArrayIdx][10] >= OrderArray[OrderArrayIdx][11]) {
            OrderArray[OrderArrayIdx][11] = OrderArray[OrderArrayIdx][10];
          }
          // PrintLog("Long: " + OrderTicket()
          //+ ">" + OrderHiddenTP
          //+ ">" + OrderProfitPip
          //+ ">" + OrderLossPip
          //+ ">" + OrderTSTrigger
          //+ ">" + OrderArray[OrderArrayIdx][9]
          //+ ">" + OrderArray[OrderArrayIdx][10]
          //+ ">" + OrderArray[OrderArrayIdx][11]
          //);
          // Long Order Processing
          if (OrderArray[OrderArrayIdx][9] != 0 &&
              OrderProfitPip < OrderArray[OrderArrayIdx][9]) {
            // PrintLog("Long:" + OrderTicket() + ". Trailing Stop Triggerred.
            // Order Closed at: " + Bid);
            OrderCloseStatus = OrderCloseReliable(OrderTicket(), OrderLots(),
                                                  Bid, slippage, DeepSkyBlue);
            if (OrderCloseStatus) {
              ResetOrderArray(OrderArrayIdx);
              PurgeElement(OrderArrayIdx);
              break;
            }
          } else if (OrderArray[OrderArrayIdx][11] != 0 &&
                     OrderProfitPip >= OrderArray[OrderArrayIdx][11]) {
            // PrintLog("Take Long Profit Now: " + OrderProfitPip);
            // Close and Set zero of the orderarray item
            OrderCloseStatus = OrderCloseReliable(OrderTicket(), OrderLots(),
                                                  Bid, slippage, Blue);
            if (OrderCloseStatus) {
              ResetOrderArray(OrderArrayIdx);
              PurgeElement(OrderArrayIdx);
              break;
            }
          }
          if (((BreakEven && MathAbs(TimeDayOfYear(OrderOpenTime()) -
                                     TimeDayOfYear(time0)) > 4 &&
                OrderProfitPip < 0) ||
               OrderLossPip >= OrderArray[FoundZeroIdx][12]) &&
              OrderArray[OrderArrayIdx][9] > 0) {
            OrderArray[OrderArrayIdx][9] =
                round(OrderProfitPip + OrderHiddenTP / 2);
            OrderArray[OrderArrayIdx][10] =
                round(OrderProfitPip + OrderHiddenTP / 3);
            Print(OrderProfitPip);
            Print(OrderLossPip);
            Print(OrderArray[OrderArrayIdx][9]);
            Print(OrderArray[OrderArrayIdx][10]);
            OrderArray[40][9];
          }
        }
        if (OrderLongShort == OP_SELL) {
          OrderProfitPip = (OrderArray[OrderArrayIdx][5] - Ask) / getPipValue();
          OrderProfitPip += (OrderExtrasPip;
          OrderLossPip = (Ask - OrderArray[OrderArrayIdx][5]) / getPipValue();
          OrderLossPip += OrderExtrasPip;
          if(OrderArray[FoundZeroIdx][12] == 0){
            OrderArray[FoundZeroIdx][12] = OrderHiddenSL;
          }
          if(OrderArray[OrderArrayIdx][11] == 0){
            OrderArray[OrderArrayIdx][11] == OrderHiddenTP;
          }
          if (OrderArray[OrderArrayIdx][9] == 0 &&
              OrderProfitPip >= OrderTSTrigger) {
            OrderArray[OrderArrayIdx][9] = OrderTS;
            OrderArray[OrderArrayIdx][10] = round(OrderTSTrigger * 1.5);
            //PrintLog("Short Trailing Stop Activated at: " + (OrderOpenPrice() - (OrderTS * getPipValue())));
          } else if(OrderArray[OrderArrayIdx][10]!=0 &&
              OrderProfitPip >= OrderArray[OrderArrayIdx][10]){
              OrderArray[OrderArrayIdx][9] = OrderArray[OrderArrayIdx][10];
              OrderArray[OrderArrayIdx][10] += MathAbs(round(OrderArray[OrderArrayIdx][10] /2));
            //PrintLog("Short Trailing Stop Activated at: " + (OrderOpenPrice() - (OrderArray[OrderArrayIdx][10] * getPipValue())));
          }
          if(OrderArray[OrderArrayIdx][10] >= OrderArray[OrderArrayIdx][11]){
            OrderArray[OrderArrayIdx][11] = OrderArray[OrderArrayIdx][10];
          }
          //PrintLog("Short: " + OrderTicket()
          //+ ">" + OrderHiddenTP
          //+ ">" + OrderProfitPip
          //+ ">" + OrderLossPip
          //+ ">" + OrderTSTrigger
          //+ ">" + OrderArray[OrderArrayIdx][9]
          //+ ">" + OrderArray[OrderArrayIdx][10]
          //+ ">" + OrderArray[OrderArrayIdx][11]
          //);
          // Short Order Processing
          if (OrderArray[OrderArrayIdx][9] != 0 && OrderProfitPip < OrderArray[OrderArrayIdx][9]) {
            //PrintLog("Short:" + OrderTicket() + ". Trailing Stop Triggerred. Order Closed at: " + Ask);
            // Close and Set zero of the orderarray item
            OrderCloseStatus = OrderCloseReliable(OrderTicket(), OrderLots(),
                                                  Ask, slippage, DarkOrange);
            if (OrderCloseStatus) {
              ResetOrderArray(OrderArrayIdx);
              PurgeElement(OrderArrayIdx);
              break;
            }
          } else if (OrderArray[OrderArrayIdx][11]!=0 && OrderProfitPip > OrderArray[OrderArrayIdx][11]) {
            //PrintLog("Take Short Profit Now: " + OrderProfitPip);
            // Close and Set zero of the orderarray item
            OrderCloseStatus = OrderCloseReliable(OrderTicket(), OrderLots(),
                                                  Ask, slippage, Red);
            if (OrderCloseStatus) {
              ResetOrderArray(OrderArrayIdx);
              PurgeElement(OrderArrayIdx);
              break;
            }
          }
          // TODO:: BreakEven SELL
          if((BreakEven
          && MathAbs(TimeDayOfYear(OrderOpenTime())-TimeDayOfYear(time0))>4
          && OrderProfitPip < 0))
          {
              OrderArray[OrderArrayIdx][9] = round(OrderProfitPip + OrderHiddenTP/2);
              OrderArray[OrderArrayIdx][10]= round(OrderProfitPip + OrderHiddenTP/3);
              Print(OrderProfitPip);
              Print(OrderLossPip);
              Print(OrderArray[OrderArrayIdx][9]);
              Print(OrderArray[OrderArrayIdx][10]);
              //OrderArray[40][9];
          }
        }
      }
      // PrintLog("==================================");
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