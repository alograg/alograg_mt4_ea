/*------------------------+
|           Utilities.mqh |
| Copyright 2017, Alograg |
|  https://www.alograg.me |
+------------------------*/
// Propiedades
#property copyright "Copyright 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Constantes
int totalOrders = 0, yearDay, Spread;
datetime time0;
double pip = -1, slippage = -1, maxLost = 0.0, workingMoney = 0.0,
       blocked = 0.0, unBlocked = 0.0;
// Inicializa las variables globales
void initUtilsGlobals(bool isNew = false) {
  if (isNew) {
    pip = getPipValue();
    slippage = getSlippage();
  }
  totalOrders = OrdersTotal();
  time0 = iTime(Symbol(), PERIOD_M15, 0);
  yearDay = TimeDayOfYear(time0);
  maxLost = getMaxLost();
  Spread = MarketInfo(Symbol(), MODE_SPREAD);
  workingMoney = GlobalVariableGet(eaName + "_block_profit");
}
// Market Pip value calculation
double getPipValue() {
  if (pip > 0)
    return pip;
  pip = Point;
  if (Digits == 3 || Digits == 5)
    pip *= 10;
  return pip;
}
// Calculate Slippage Value
int getSlippage() {
  if (slippage > 0)
    return slippage;
  slippage = 3;
  return slippage;
}
double getSpread() { return Ask - Bid; }
// Maxima perdida permitida
double getMaxLost() {
  if (maxLost < 0)
    return maxLost;
  return MathMax(firstBalance * -0.25, -5);
}
// Incremento semanal
double getWeekProfit() {
  int daysPassed =
          TimeDayOfYear(GlobalVariableTime(eaName + "_block_profit")) - yearDay,
      weeksPassed = daysPassed / 7;
  return incrementPerWeek * weeksPassed / 100;
}
// Dinero bloqueado
double getBlockMoney() {
  double evaluated = GlobalVariableGet(eaName + "_block_profit");
  evaluated *= 1 + getWeekProfit();
  return evaluated;
}
// Dinero libre
double getUnBlocked() {
  blocked = AccountEquity();
  double millards = MathFloor(blocked / firstBalance) - 1;
  if (millards >= 1) {
    blocked -= firstBalance * millards;
  }
  blocked -= getBlockMoney();
  blocked /= 3;
  unBlocked = AccountFreeMargin() - blocked;
  return NormalizeDouble(unBlocked / 5, 2);
}
// Tamaño del lote según dispocición
double getLotSize(double Risk = 2, double SL = 0) {
  if (AccountFreeMargin() < AccountBalance() * 0.2)
    return 0.0;
  double lastWithDrawal = 0.0;
  if (SL == 0)
    SL = (iATR(Symbol(), PERIOD_M1, 15, 1) * Risk) + (Spread * Point);
  else
    SL *= (iATR(Symbol(), PERIOD_M1, 15, 1) * Risk) + (Spread * Point);
  double MaxLot = 1.5;
  double MinLot = MarketInfo(Symbol(), MODE_MINLOT);
  double StopLoss = SL / Point / 10;
  double Size = Risk / 100 * getUnBlocked() / 10 / StopLoss;
  if (Size <= MinLot)
    Size = MinLot;
  if (Size >= MaxLot)
    Size = MaxLot;
  return (NormalizeDouble(Size, 2));
}
// Nueva barra
bool CheckNewBar() { return iTime(Symbol(), PERIOD_M15, 0) != time0; }
// Nuevo dia
bool isNewDay() { return TimeDayOfYear(Time[0]) != yearDay; }
// Si el comentario es el mismo
bool isFornComment(string comment, string orderComment) {
  if (comment == NULL)
    return true;
  return orderComment == comment;
}
/*--------------------------------------------------+
| Count Open Trades                                 |
|   opType:       Tipo de operacion                 |
|   MagicNumber:  Numero magico para buscar         |
|   commnet:      Comentarios de filtro (opcional)  |
+--------------------------------------------------*/
int COT(int opType, int FilterMagicNumber, string commnetFilter = NULL) {
  int count = 0, hasOrder;
  for (int cnt_COT = 0; cnt_COT < totalOrders; cnt_COT++) {
    hasOrder = OrderSelect(cnt_COT, SELECT_BY_POS, MODE_TRADES);
    if (OrderSymbol() == Symbol() && OrderMagicNumber() == FilterMagicNumber &&
        opType == OrderType() && isFornComment(commnetFilter, OrderComment()))
      count++;
  }
  return count;
}
// Account Report
void SendAccountReport() {
  string subject, accountReport, balanceReport;
  subject = "MT4 Report " + TimeToString(TimeCurrent());
  accountReport = "";
  accountReport +=
      StringFormat("Broker; %s", AccountInfoString(ACCOUNT_COMPANY));
  accountReport += "\n";
  accountReport +=
      StringFormat("Deposit currency; %s", AccountInfoString(ACCOUNT_CURRENCY));
  accountReport += "\n";
  accountReport +=
      StringFormat("Client name; %s ", AccountInfoString(ACCOUNT_NAME));
  accountReport += "\n";
  accountReport +=
      StringFormat("Server; %s", AccountInfoString(ACCOUNT_SERVER));
  accountReport += "\n";
  accountReport +=
      StringFormat("LOGIN =  %d", AccountInfoInteger(ACCOUNT_LOGIN));
  accountReport += "\n";
  accountReport +=
      StringFormat("LEVERAGE =  %d", AccountInfoInteger(ACCOUNT_LEVERAGE));
  accountReport += "\n";
  bool thisAccountTradeAllowed = AccountInfoInteger(ACCOUNT_TRADE_ALLOWED);
  bool EATradeAllowed = AccountInfoInteger(ACCOUNT_TRADE_EXPERT);
  ENUM_ACCOUNT_TRADE_MODE tradeMode =
      (ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
  ENUM_ACCOUNT_STOPOUT_MODE stopOutMode =
      (ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);
  //--- Inform about the possibility to perform a trade operation
  accountReport += "Trade is ";
  accountReport += thisAccountTradeAllowed ? "permitted" : "prohibited";
  accountReport += ". ";
  //--- Find out if it is possible to trade on this account by Expert Advisors
  accountReport += "Expert Advisors ";
  accountReport += EATradeAllowed ? "permitted" : "prohibited";
  accountReport += ". Is a ";
  //--- Find out the account type
  switch (tradeMode) {
  case(ACCOUNT_TRADE_MODE_DEMO) :
    accountReport += "demo";
    break;
  case(ACCOUNT_TRADE_MODE_CONTEST) :
    accountReport += "competition";
    break;
  default:
    accountReport += "real";
  }
  accountReport += " account. The StopOut level is ";
  //--- Find out the StopOut level setting mode
  switch (stopOutMode) {
  case(ACCOUNT_STOPOUT_MODE_PERCENT) :
    accountReport += "percentage";
    break;
  default:
    accountReport += "monetary";
  }
  accountReport += ".\n";
  balanceReport += "Date " + TimeToString(Time[0]) + "\n";
  balanceReport +=
      StringFormat("BALANCE        = %G", AccountInfoDouble(ACCOUNT_BALANCE));
  balanceReport += "\n";
  balanceReport +=
      StringFormat("PROFIT         = %G", AccountInfoDouble(ACCOUNT_PROFIT));
  balanceReport += "\n";
  balanceReport +=
      StringFormat("EQUITY         = %G", AccountInfoDouble(ACCOUNT_EQUITY));
  balanceReport += "\n";
  balanceReport +=
      StringFormat("MARGIN         = %G", AccountInfoDouble(ACCOUNT_MARGIN));
  balanceReport += "\n";
  balanceReport += StringFormat("MARGIN FREE    = %G",
                                AccountInfoDouble(ACCOUNT_FREEMARGIN));
  balanceReport += "\n";
  balanceReport += StringFormat("MARGIN LEVEL   = %G",
                                AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
  balanceReport += "\n";
  SendMail(subject, accountReport + balanceReport);
  SendNotification(balanceReport);
}
// Simbol params
void SendSimbolParams() {
  string comm = StringFormat("Symbol: %G", Symbol());
  comm = StringFormat("\nSpread value in points: %G", Spread);
  comm = StringFormat("\nStop level in points: %G",
                      MarketInfo(Symbol(), MODE_STOPLEVEL));
  comm = StringFormat("\nTick size in points: %G",
                      MarketInfo(Symbol(), MODE_TICKSIZE));
  comm = StringFormat("\nSwap of the buy order: %G",
                      MarketInfo(Symbol(), MODE_SWAPLONG));
  comm = StringFormat("\nSwap of the sell order: %G",
                      MarketInfo(Symbol(), MODE_SWAPSHORT));
  comm = StringFormat("\nSwap calculation method: %G",
                      MarketInfo(Symbol(), MODE_SWAPTYPE));
  comm = StringFormat("\nProfit calculation mode: %G",
                      MarketInfo(Symbol(), MODE_PROFITCALCMODE));
  comm = StringFormat("\nMargin calculation mode: %G",
                      MarketInfo(Symbol(), MODE_MARGINCALCMODE));
  comm = StringFormat("\nInitial margin requirements for 1 lot: %G",
                      MarketInfo(Symbol(), MODE_MARGININIT));
  comm =
      StringFormat("\nMargin to maintain open orders calculated for 1 lot: %G",
                   MarketInfo(Symbol(), MODE_MARGINMAINTENANCE));
  comm = StringFormat("\nHedged margin calculated for 1 lot: %G",
                      MarketInfo(Symbol(), MODE_MARGINHEDGED));
  comm = StringFormat("\nFree margin required to open 1 lot for buying: %G",
                      MarketInfo(Symbol(), MODE_MARGINREQUIRED));
  comm = StringFormat("\nOrder freeze level in points: %G",
                      MarketInfo(Symbol(), MODE_FREEZELEVEL));
  comm = StringFormat("\nAllowed using OrderCloseBy(): %G",
                      MarketInfo(Symbol(), MODE_CLOSEBY_ALLOWED));
  bool spreadfloat = SymbolInfoInteger(Symbol(), SYMBOL_SPREAD_FLOAT);
  comm = StringFormat("Spread %s = %I64d points\r\n",
                      spreadfloat ? "floating" : "fixed",
                      SymbolInfoInteger(Symbol(), SYMBOL_SPREAD));
  double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
  double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
  double spread = getSpread();
  int spread_points =
      (int)MathRound(spread / SymbolInfoDouble(Symbol(), SYMBOL_POINT));
  comm = comm + "Calculated spread = " + (string)spread_points + " points";
  Comment(comm);
}
void PrintLog(string txt) {
  if (IsTesting())
    Print(txt);
}
int OrderSendHidden(string symbol, int cmd, double volume, double price,
                    int slippage, double stoploss, double takeprofit,
                    string comment, int magic, datetime expiration = 0,
                    color arrow_color = CLR_NONE) {
  int orderNumber =
      OrderSendReliable(symbol, cmd, volume, price, slippage, 0, 0, comment,
                        magic, expiration, arrow_color);
  if (!orderNumber)
    return orderNumber;

  return orderNumber;
}