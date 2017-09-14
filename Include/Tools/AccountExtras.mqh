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
#define INVESTMENT_TOTAL 0
#define INVESTMENT_DEPOSIT 1
#define INVESTMENT_WITHDRAWAL 2
int SpreadSampleSize = 0;
double Spread[];
double investment = 0, deposit = 0, withdrawal = 0;
int sizeOfTheRisk = 40;
// Functions
double AccountInvestment(int type = INVESTMENT_TOTAL) {
  if (IsTesting()) {
    deposit = 0 == deposit ? testDeposit : deposit;
    withdrawal = 0 == withdrawal ? testWithdrawal : withdrawal;
    investment = deposit + withdrawal;
  } else if (isNewBar(PERIOD_D1)) {
    investment = 0;
    deposit = 0;
    withdrawal = 0;
    for (int i = 0; i < OrdersHistoryTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
        if (OrderType() > 5) {
          double amount = OrderProfit();
          investment += amount;
          if (amount > 0) {
            deposit += amount;
          } else {
            withdrawal += amount;
          }
        }
      }
    }
  }
  return type ? (type == INVESTMENT_DEPOSIT ? deposit : withdrawal)
              : investment;
}
int AccountMoneyToInvestment() { return (int)(AccountFreeMargin() * 0.3); }
bool moneyOnRisk() {
  int stopOut = AccountStopoutMode() ? 50 : AccountStopoutLevel();
  double MarginLevel = NormalizeDouble(
      (AccountEquity() /
       (AccountFreeMargin() > 0 ? AccountFreeMargin() : stopOut)) *
          100,
      2);
  return !(AccountFreeMargin() >= AccountEquity() / 2 ||
           AccountFreeMargin() >= AccountBalance() / 2 ||
           MarginLevel <= stopOut * 1.5);
}
double AccountMaxLostMoney() { return AccountEquity() * 0.02; }
int AccountMaxLostPips() {
  return (int)(AccountMaxLostMoney() / SymbolPipValue());
}
double SymbolPipValue() {
  double tradeSize = (symbolLoteSize / accountLeverage) * Point,
         exchange = (Ask + Bid) / 2;
  return NormalizeDouble((tradeSize) / exchange, Digits);
}
double getLotSize() {
  double lotSize = 0;
  if (moneyOnRisk())
    return lotSize;
  lotSize = (double)AccountMoneyToInvestment() /
            ((symbolLoteSize / accountLeverage) * 0.01);
  lotSize *= 0.01;
  lotSize = MathMax(lotSize, 0.01);
  lotSize = MathMin(maLots, lotSize);
  return NormalizeDouble(lotSize, 2);
}
double AccountOpenPositions(int mode = -1) {
  double openBuyLots = 0, openSellLots = 0;
  for (int iPos = OrdersTotal() - 1; iPos >= 0; iPos--)
    if (OrderSelect(iPos, SELECT_BY_POS) && OrderSymbol() == Symbol()) {
      if (OrderType() == OP_BUY)
        openBuyLots += OrderLots();
      else
        openSellLots += OrderLots();
    }
  return mode == OP_BUY
             ? openBuyLots
             : mode == OP_SELL ? openSellLots : openBuyLots - openSellLots;
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
        orderTime.year <= endTime.year && orderTime.mon <= endTime.mon &&
        orderTime.day <= endTime.day && orderTime.hour <= endTime.hour &&
        orderTime.min <= endTime.min;
    if (grateThanStart && lowerThanStart)
      continue;
    profit += OrderProfit() + OrderCommission() + OrderSwap();
  }
  return profit;
}
double getDayProfit(int shift = 0) {
  MqlDateTime dayTime, orderTime;
  TimeToStruct(iTime(Symbol(), PERIOD_D1, shift), dayTime);
  Print("Dia: ", dayTime.year, "-", dayTime.day_of_year);
  double profit = 0;
  for (int position = OrdersHistoryTotal(); position >= 0; position--) {
    if (!OrderSelect(position, SELECT_BY_POS, MODE_HISTORY))
      continue;
    TimeToStruct(OrderCloseTime(), orderTime);
    if (orderTime.day_of_year == dayTime.day_of_year &&
        orderTime.year == dayTime.year)
      profit += OrderProfit() + OrderCommission() + OrderSwap();
  }
  return profit;
}
// Account Report
void SendAccountReport() {
  if (!IsTradeAllowed())
    return;
  string balanceReport;
  balanceReport = "Report " + eaName + " v." + propVersion;
  balanceReport +=
      StringFormat(" (%s, Spread %s)", strategiesActivate ? "On" : "Off",
                   breakInSpread ? "Auto" : "Manual");
  balanceReport +=
      StringFormat("\nBroker; %s (%s)", AccountInfoString(ACCOUNT_COMPANY),
                   AccountInfoString(ACCOUNT_CURRENCY));
  balanceReport += "\nDate " + TimeToString(Time[0]);
  balanceReport += StringFormat("|Profit: %G ", getDayProfit(1));
  balanceReport += StringFormat("\nFlag: %G %s", getFlagSize(PERIOD_D1) * Point,
                                isBlackCandel(PERIOD_D1) ? "!" : "¡");
  balanceReport += StringFormat("\nDeposit: %.2f (%s)", AccountInvestment(),
                                moneyOnRisk() ? "Riesgo" : "Tranquilo");
  balanceReport += StringFormat("|MaxLost: %.2f (%G)", AccountMaxLostMoney(),
                                AccountMaxLostPips());
  balanceReport += StringFormat("\nB: %G", AccountBalance());
  balanceReport += StringFormat("|P: %G", AccountProfit());
  balanceReport += StringFormat("|E: %G", AccountEquity());
  balanceReport += StringFormat("\nM: %G", AccountMargin());
  balanceReport += StringFormat("|F: %G", AccountFreeMargin());
  balanceReport +=
      StringFormat("|L = %G", AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
  if (IsTradeAllowed())
    SendNotification(balanceReport);
}
// Simbol params
void SendSimbolParams() {
  string startLine = "\n|                                           ";
  string comm = "|                                           " + eaName +
                " v." + propVersion;
  comm += StringFormat(" (%s, Spread %s)\n", strategiesActivate ? "On" : "Off",
                       breakInSpread ? "Auto" : "Manual");
  comm += StringFormat(startLine + "Symbol: %s", Symbol());
  // comm += StringFormat(startLine + "Leverage: %G", accountLeverage);
  // comm += StringFormat(startLine + "Day Profit: %G", getDayProfit(1));
  // comm += StringFormat(startLine + "Contract size: %G",
  //                      symbolLoteSize);
  // comm += StringFormat(
  //     startLine + "MicroTrade (0.01): %G",
  //     (symbolLoteSize / accountLeverage) * 0.01);
  bool spreadfloat = SymbolInfoInteger(Symbol(), SYMBOL_SPREAD_FLOAT);
  comm += StringFormat(startLine + "Spread "
                                   "%s = %I64d points, %.5f",
                       spreadfloat ? "floating" : "fixed",
                       SymbolInfoInteger(Symbol(), SYMBOL_SPREAD),
                       NormalizeDouble(getSpread(), Digits));
  comm += StringFormat(startLine + "Stop level: %G",
                       MarketInfo(Symbol(), MODE_STOPLEVEL));
  comm += StringFormat(startLine + "Stop Out: %G",
                       AccountStopoutMode() ? 50 : AccountStopoutLevel());
  comm += StringFormat(startLine + "Swap: buy %G sell %G",
                       MarketInfo(Symbol(), MODE_SWAPLONG),
                       MarketInfo(Symbol(), MODE_SWAPSHORT));
  comm += StringFormat(startLine + "Money: %.2f", AccountInvestment());
  comm += StringFormat(startLine + "MaxLost: %.2f (%G)", AccountMaxLostMoney(),
                       AccountMaxLostPips());
  comm += StringFormat(startLine + "Reference: %G", sizeOfTheRisk);
  comm += StringFormat(startLine + "Candel: %G", getCandelSize(PERIOD_D1));
  comm += StringFormat(startLine + "Pip Value: %G", SymbolPipValue());
  comm += StringFormat(startLine + "Steps: %f",
                       NormalizeDouble((BreakEven / 3) / pareto, Digits));
  comm += StringFormat(startLine + "Lot Size: %.2f",
                       NormalizeDouble(getLotSize(), 2));
  Comment(comm);
}