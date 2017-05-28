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
string YesComment = eaName + ": YES-TM";

double OrderArray[][14];
int TotalNumberOfOrders;
double AvereageCandle = -1;
double Tendence = 0;

void yesInit() {
  TotalNumberOfOrders = OrdersTotal();
  ArrayResize(OrderArray, TotalNumberOfOrders);
}
void yesReset() {
  ArrayResize(OrderArray, 0);
  yesInit();
}
void yesProcess() {
  int i, j, icnt, jcnt, t, OrderTickets, OrderArrayIdx, FoundZeroIdx,
      OrderLongShort;
  int TempNumberOfOrders, CountNumberOfOrders;
  int OrderProfitPip, OrderLossPip;
  bool TradeFound, OrderFound = FALSE, FoundZero = FALSE, OrderCloseStatus;
  OrderTS = round(getSpreadPoints() * 3 * riskByMoney());
  OrderTSTrigger = round(OrderTS * 1.25);
  if (isNewDay() || AvereageCandle < 0) {
    AvereageCandle = NormalizeDouble(MathAbs(iHigh(Symbol(), PERIOD_D1, 1) -
                                             iLow(Symbol(), PERIOD_D1, 1)),
                                     Digits) /
                     getPipValue();
    OrderHiddenTP = round(AvereageCandle);
    //    OrderHiddenTP = round(MathMin(MathMax(AvereageCandle,
    // getSpreadPoints()*3), getSpreadPoints()*5));
    OrderHiddenSL = OrderHiddenTP + getSpreadPoints();
    string log = "Candel: " + NormalizeDouble(AvereageCandle, 2) +
                 " Pibs/TP: " + OrderHiddenTP + " Spead: " + getSpreadPoints() +
                 " TS: " + OrderTSTrigger;
    Print(log);
    AddNotify(log);
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
  Tendence = TendanceSignal - TendanceSignalPrevious;
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
        if (OrderArray[FoundZeroIdx][7] != 0) {
          OrderArray[FoundZeroIdx][10] = MathAbs(OrderArray[FoundZeroIdx][5] -
                                                 OrderArray[FoundZeroIdx][7]) /
                                         getPipValue(); // TST
          OrderArray[FoundZeroIdx][9] =
              OrderArray[FoundZeroIdx][10] - getSpreadPoints(); // TS
          OrderArray[FoundZeroIdx][11] =
              OrderArray[FoundZeroIdx][10] + getSpreadPoints(); // TP
        }
        if (OrderArray[FoundZeroIdx][8] != 0) {
          OrderArray[FoundZeroIdx][12] = MathAbs(OrderArray[OrderArrayIdx][5] -
                                                 OrderArray[OrderArrayIdx][8]) /
                                         getPipValue(); // SL
        }
        FoundZero = FALSE;
      } else {
        // Found the Order
        OrderLongShort = OrderArray[OrderArrayIdx][2];
        // Print ("OrderLongShort: "+OrderLongShort);
        int OrderExtrasPip =
            round((OrderSwap() + OrderCommission()) / OrderLots() /
                  MarketInfo(Symbol(), MODE_TICKVALUE) *
                  MarketInfo(Symbol(), MODE_TICKSIZE));
        double OrderExtrasMoney = NormalizeDouble(
            (OrderSwap() + OrderCommission()) / OrderLots(), Digits);
        double closeIn;
        int openAs;
        if (OrderLongShort == OP_BUY) {
          OrderProfitPip = (Bid - OrderArray[OrderArrayIdx][5]) / getPipValue();
          OrderProfitPip += OrderExtrasPip;
          OrderLossPip = (OrderArray[OrderArrayIdx][5] - Bid) / getPipValue();
          OrderLossPip += OrderExtrasPip;
          closeIn = Bid;
          openAs = OP_SELL;
        }
        if (OrderLongShort == OP_SELL) {
          OrderProfitPip = (OrderArray[OrderArrayIdx][5] - Ask) / getPipValue();
          OrderProfitPip += OrderExtrasPip;
          OrderLossPip = (Ask - OrderArray[OrderArrayIdx][5]) / getPipValue();
          OrderLossPip += OrderExtrasPip;
          closeIn = Ask;
          openAs = OP_BUY;
        }
        if (OrderArray[FoundZeroIdx][12] == 0) {
          OrderArray[FoundZeroIdx][12] = OrderHiddenSL;
        }
        if (OrderArray[OrderArrayIdx][11] == 0) {
          OrderArray[OrderArrayIdx][11] == OrderHiddenTP;
        }
        if (OrderArray[OrderArrayIdx][9] == 0 &&
            OrderProfitPip >= OrderTSTrigger) {
          OrderArray[OrderArrayIdx][9] = OrderTS;
          OrderArray[OrderArrayIdx][10] += MathAbs(round(OrderTSTrigger * 1.5));
          Print(OrderTicket(), ": Trailing Stop Activated (1) at: ",
                (OrderOpenPrice() - (OrderTS * getPipValue())));
        } else if (OrderArray[OrderArrayIdx][10] != 0 &&
                   OrderProfitPip >= OrderArray[OrderArrayIdx][10]) {
          OrderArray[OrderArrayIdx][9] = OrderArray[OrderArrayIdx][10];
          OrderArray[OrderArrayIdx][10] +=
              MathAbs(round(OrderArray[OrderArrayIdx][10] / 2));
          Print(OrderTicket(), ": Trailing Stop Activated (2) at: ",
                (OrderOpenPrice() -
                 (OrderArray[OrderArrayIdx][10] * getPipValue())));
        }
        if (OrderArray[OrderArrayIdx][10] >= OrderArray[OrderArrayIdx][11]) {
          OrderArray[OrderArrayIdx][11] = OrderArray[OrderArrayIdx][10];
        }
        // PrintLog(OrderTicket()
        //+ ">" + OrderHiddenTP
        //+ ">" + OrderProfitPip
        //+ ">" + OrderLossPip
        //+ ">" + OrderTSTrigger
        //+ ">" + OrderArray[OrderArrayIdx][9]
        //+ ">" + OrderArray[OrderArrayIdx][10]
        //+ ">" + OrderArray[OrderArrayIdx][11]
        //);
        // Order Processing
        if ((OrderArray[OrderArrayIdx][9] != 0 &&
             OrderProfitPip < OrderArray[OrderArrayIdx][9]) ||
            (OrderArray[OrderArrayIdx][11] != 0 &&
             OrderProfitPip >= OrderArray[OrderArrayIdx][11])) {
          Print(OrderTicket(), ": Trailing Stop Triggerred. Order Closed at: ",
                closeIn);
          bool canClose =
              NormalizeDouble(OrderProfit() + OrderCommission() + OrderSwap(),
                              2) > 0;
          if (canClose)
            OrderCloseStatus = OrderCloseReliable(
                OrderTicket(), OrderLots(), closeIn, slippage, DeepSkyBlue);
          if (OrderCloseStatus) {
            ResetOrderArray(OrderArrayIdx);
            PurgeElement(OrderArrayIdx);
            CloseAllOldProfited();
            break;
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