/*--------------------------+
|            TrailStops.mqh |
| Copyright © 2017, Alograg |
|    https://www.alograg.me |
+--------------------------*/
// Properties
#property copyright "Copyright © 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Parameter
extern int SpreadSize = 100; // Size of spread reference
extern int RiskSize = 40;    // Size of risk
// Constants
int SpreadSampleSize = 0;
double Spread[];
double depositMoney;
int sizeOfTheRisk = 40;
// Functions
bool moneyOnRisk() {
  int stopOut = AccountStopoutMode() ? 50 : AccountStopoutLevel();
  double MarginLevel =
      AccountMargin() > 0
          ? NormalizeDouble(AccountEquity() / AccountMargin() * 100, 2)
          : AccountEquity();
  return !(AccountMargin() <= AccountEquity() / 2 ||
           AccountMargin() <= AccountBalance() / 2 ||
           MarginLevel <= stopOut * 1.5);
}
double Deposits() {
  double total = 0;
  for (int i = 0; i < OrdersHistoryTotal(); i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
      if (OrderType() > 5) {
        total += OrderProfit();
      }
    }
  }
  return MathMax(total, 40);
}
double getLotSize() {
  return NormalizeDouble(
      moneyOnRisk() ? 0
                    : sizeOfTheRisk > 40
                          ? MathMax(AccountEquity() / (100 * sizeOfTheRisk), 0)
                          : 0.01,
      2);
}
double getSpread(double AddValue = 0) {
  double LastValue;
  static double ArrayTotal = 0;
  if (SpreadSampleSize == 0)
    SpreadSampleSize = SpreadSize;
  if ((AddValue == 0 && SpreadSampleSize <= 0) ||
      (AddValue == 0 && ArrayTotal == 0))
    return NormalizeDouble(Ask - Bid, Digits);
  if (AddValue == 0)
    return NormalizeDouble(ArrayTotal / ArraySize(Spread), Digits);
  ArrayTotal = ArrayTotal + AddValue;
  ArraySetAsSeries(Spread, true);
  if (ArraySize(Spread) == SpreadSampleSize) {
    LastValue = Spread[0];
    ArrayTotal = ArrayTotal - LastValue;
    ArraySetAsSeries(Spread, false);
    ArrayResize(Spread, ArraySize(Spread) - 1);
    ArraySetAsSeries(Spread, true);
    ArrayResize(Spread, ArraySize(Spread) + 1);
  } else
    ArrayResize(Spread, ArraySize(Spread) + 1);
  ArraySetAsSeries(Spread, false);
  Spread[0] = AddValue;
  return NormalizeDouble(ArrayTotal / ArraySize(Spread), Digits);
}
double getPeriodProfit(int period = PERIOD_D1, int shift = 0) {
  MqlDateTime startTime, endTime, orderTime;
  TimeToStruct(iTime(Symbol(), period, shift - 1), startTime);
  TimeToStruct(iTime(Symbol(), period, shift), endTime);
  double profit = 0;
  for (int position = OrdersHistoryTotal(); position >= 0; position--) {
    if (!OrderSelect(position, SELECT_BY_POS, MODE_HISTORY))
      continue;
    TimeToStruct(OrderCloseTime(), orderTime);
    bool grateThanStart =
        orderTime.year >= startTime.year && orderTime.mon >= startTime.mon &&
        orderTime.day >= startTime.day && orderTime.hour >= startTime.hour &&
        orderTime.min >= startTime.min;
    bool lowerThanStart =
        orderTime.year >= endTime.year && orderTime.mon >= endTime.mon &&
        orderTime.day >= endTime.day && orderTime.hour >= endTime.hour &&
        orderTime.min >= endTime.min;
    if (grateThanStart && lowerThanStart)
      continue;
    profit += OrderProfit() + OrderCommission() + OrderSwap();
  }
  return profit;
}
double getDayProfit(int shift = 0) {
  MqlDateTime dayTime, orderTime;
  TimeToStruct(iTime(Symbol(), PERIOD_M1, 0), dayTime);
  dayTime.day -= shift;
  double profit = 0;
  for (int position = OrdersHistoryTotal(); position >= 0; position--) {
    if (!OrderSelect(position, SELECT_BY_POS, MODE_HISTORY))
      continue;
    TimeToStruct(OrderCloseTime(), orderTime);
    if (orderTime.day_of_year != dayTime.day_of_year)
      continue;
    profit += OrderProfit() + OrderCommission() + OrderSwap();
  }
  return profit;
}
// Account Report
void SendAccountReport() {
  string balanceReport;
  depositMoney = Deposits();
  balanceReport = "Report " + eaName + " v." + propVersion;
  balanceReport +=
      StringFormat(" (%s, Spread %s)\n", strategiesActivate ? "On" : "Off",
                   breakInSpread ? "Auto" : "Manual");
  balanceReport +=
      StringFormat("\nBroker; %s (%s)\n", AccountInfoString(ACCOUNT_COMPANY),
                   AccountInfoString(ACCOUNT_CURRENCY));
  balanceReport += " Date " + TimeToString(Time[0]) + "\n";
  balanceReport += StringFormat("\nFlag = %G", getFlagSize(PERIOD_D1));
  balanceReport +=
      StringFormat("\nDeposit = %G (%s) %G", depositMoney,
                   moneyOnRisk() ? "Riesgo" : "Tranquilo", sizeOfTheRisk);
  balanceReport += StringFormat("\nB = %G", AccountBalance());
  balanceReport += StringFormat("|P = %G", AccountProfit());
  balanceReport += StringFormat("|E = %G", AccountEquity());
  balanceReport += StringFormat("\nM = %G", AccountMargin());
  balanceReport += StringFormat("|F = %G", AccountFreeMargin());
  balanceReport +=
      StringFormat("|L = %G", AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
  SendNotification(balanceReport);
}
// Simbol params
void SendSimbolParams() {
  string comm = "|                                           " + eaName +
                " v." + propVersion;
  comm += StringFormat(" (%s, Spread %s)\n", strategiesActivate ? "On" : "Off",
                       breakInSpread ? "Auto" : "Manual");
  comm += StringFormat(
      "\n|                                           Symbol: %s", Symbol());
  bool spreadfloat = SymbolInfoInteger(Symbol(), SYMBOL_SPREAD_FLOAT);
  comm += StringFormat("\n|                                           Spread "
                       "%s = %I64d points, %.5f",
                       spreadfloat ? "floating" : "fixed",
                       SymbolInfoInteger(Symbol(), SYMBOL_SPREAD),
                       NormalizeDouble(getSpread(), Digits));
  comm += StringFormat(
      "\n|                                           Stop level: %G",
      MarketInfo(Symbol(), MODE_STOPLEVEL));
  comm +=
      StringFormat("\n|                                           Stop Out: %G",
                   AccountStopoutMode() ? 50 : AccountStopoutLevel());
  comm += StringFormat(
      "\n|                                           Swap: byu %G sell %G",
      MarketInfo(Symbol(), MODE_SWAPLONG),
      MarketInfo(Symbol(), MODE_SWAPSHORT));
  comm += StringFormat(
      "\n|                                           Money: %G", depositMoney);
  comm += StringFormat(
      "\n|                                           Reference: %G",
      sizeOfTheRisk);
  comm +=
      StringFormat("\n|                                           Candel: %G",
                   getCandelSize(PERIOD_D1));
  comm +=
      StringFormat("\n|                                           Steps: %f",
                   NormalizeDouble((BreakEven / 3) / pareto, Digits));
  comm +=
      StringFormat("\n|                                           Lot Size: %f",
                   NormalizeDouble(getLotSize(), 2));
  Comment(comm);
}