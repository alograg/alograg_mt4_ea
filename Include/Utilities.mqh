/*------------------------+
|          WeekendGap.mqh |
| Copyright 2017, Alograg |
|  https://www.alograg.me |
+------------------------*/
// Propiedades
#property copyright "Copyright 2017, Alograg"
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Constantes
int totalOrders = 0, yearDay;
datetime time0;
double currentPoint = -1, pip = -1, maxLost = 0.0, workingMoney = 0.0, blocked = 0.0;
// Inicializa las variables globales
void initUtilsGlobals(bool isNew = false) {
  if (isNew) {
    pip = getPip();
    currentPoint = getCurrentPoint();
  }
  totalOrders = OrdersTotal();
  time0 = Time[0];
  yearDay = TimeDayOfYear(time0);
  pip = getPip();
  currentPoint = getCurrentPoint();
  maxLost = getMaxLost();
  workingMoney = GlobalVariableGet(eaName + "_block_profit");
}
// Maxima perdida permitida
double getMaxLost() {
  if (maxLost < 0)
    return maxLost;
  return MathMax(firstBalance * -0.25, -5);
}
// Obten los pips actuales
double getPip() {
  if (pip >= 0)
    return pip;
  double pipDecimals = getCurrentPoint();
  return pipDecimals * SymbolInfoDouble(Symbol(), SYMBOL_TRADE_CONTRACT_SIZE);
}
// Obten el punto actual
double getCurrentPoint() {
  if (currentPoint >= 0)
    return currentPoint;
  double returnPoint = Point;
  if (Digits == 3 || Digits == 5)
    returnPoint *= 10;
  return returnPoint;
}
// Incremento semanal
double getWeekProfit() {
  int daysPassed = TimeDayOfYear(GlobalVariableTime(eaName + "_block_profit")) - yearDay,
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
    SL = (iATR(Symbol(), PERIOD_M1, 15, 1) * Risk) +
         (MarketInfo(Symbol(), MODE_SPREAD) * Point);
  else
    SL *= (iATR(Symbol(), PERIOD_M1, 15, 1) * Risk) +
          (MarketInfo(Symbol(), MODE_SPREAD) * Point);
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
bool CheckNewBar() { return Time[0] != time0; }
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
// Report
void SendReport() {
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
// Operation params
void simbolParams() {
}
