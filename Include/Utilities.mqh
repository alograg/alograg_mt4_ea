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
int allPeriods[];
int shortWork = 0, longWork = PERIOD_D1;
int totalOrders = 0, yearDay, countPeriods = 0;
int SpreadSampleSize = 100;
datetime time0;
bool canNotifyNow = false;
double pip = -1, slippage = -1, maxLost = 0.0, workingMoney = 0.0,
       blocked = 0.0, unBlocked = 0.0;
double Spread[];
string fullNotification = "";
// Inicializa las variables globales
void initUtilsGlobals(bool isNew = false) {
  if (isNew) {
    pip = getPipValue();
    slippage = getSlippage();
    calculateBetterTransactionTime();
  }
  getSpread(Ask-Bid);
  totalOrders = OrdersTotal();
  time0 = iTime(Symbol(), PERIOD_M15, 0);
  yearDay = TimeDayOfYear(time0);
  maxLost = getMaxLost();
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
double getSpread(double AddValue=0) {
  double LastValue;
   static double ArrayTotal=0;
   
   if (AddValue == 0 && SpreadSampleSize <= 0) return(Ask-Bid);
   if (AddValue == 0 && ArrayTotal == 0) return(Ask-Bid);
   if (AddValue == 0 ) return(ArrayTotal/ArraySize(Spread));
   
   ArrayTotal = ArrayTotal + AddValue;
   ArraySetAsSeries(Spread, true); 
   if (ArraySize(Spread) == SpreadSampleSize)
      {
      LastValue = Spread[0];
      ArrayTotal = ArrayTotal - LastValue;
      ArraySetAsSeries(Spread, false);
      ArrayResize(Spread, ArraySize(Spread)-1 );
      ArraySetAsSeries(Spread, true);
      ArrayResize(Spread, ArraySize(Spread)+1 ); 
      }
   else ArrayResize(Spread, ArraySize(Spread)+1 ); 
   //Print("ArraySize = ",ArraySize(lSpread)," AddedNo. = ",AddValue);
   ArraySetAsSeries(Spread, false);
   Spread[0] = AddValue;
   return(NormalizeDouble(ArrayTotal/ArraySize(Spread), Digits));
}
int getSpreadPoints() {
  return MathRound(getSpread() / SymbolInfoDouble(Symbol(), SYMBOL_POINT));
}
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
double getLotSize(double Risk = 2) {
  if (AccountFreeMargin() < AccountBalance() * 0.2)
    return 0.0;
  double MaxLot = 1.5;
  double MinLot = 0.01;
  double Size = AccountFreeMargin() / (10000 * Risk);
  if (Size < MinLot)
    Size = MinLot;
  if (Size > MaxLot)
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
  balanceReport = "Report "+eaName+" v." + propVersion + "\n";
  balanceReport +=
      StringFormat("\nBroker; %s \n", AccountInfoString(ACCOUNT_COMPANY));
  balanceReport += AccountInfoString(ACCOUNT_CURRENCY);
  balanceReport += " Date " + TimeToString(Time[0]) + "\n";
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
  //SendMail(subject, accountReport + balanceReport);
  SendNotification(balanceReport);
}
// Simbol params
void SendSimbolParams() {
  string comm = eaName + " v." + propVersion;
  comm += StringFormat("\nSymbol: %s", Symbol());
  comm += StringFormat("\nSpread value in points: %G", getSpreadPoints());
  comm += StringFormat("\nStop level in points: %G",
                       MarketInfo(Symbol(), MODE_STOPLEVEL));
  comm += StringFormat("\nSwap of the buy order: %G",
                       MarketInfo(Symbol(), MODE_SWAPLONG));
  comm += StringFormat("\nSwap of the sell order: %G",
                       MarketInfo(Symbol(), MODE_SWAPSHORT));
  comm += StringFormat("\nAllowed using OrderCloseBy(): %G",
                       MarketInfo(Symbol(), MODE_CLOSEBY_ALLOWED));
  bool spreadfloat = SymbolInfoInteger(Symbol(), SYMBOL_SPREAD_FLOAT);
  comm += StringFormat("\nSpread %s = %I64d points",
                       spreadfloat ? "floating" : "fixed",
                       SymbolInfoInteger(Symbol(), SYMBOL_SPREAD));
  double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
  double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
  comm += "\nCalculated spread = " + getSpreadPoints() + " points";
  comm += "\nPeriod: work=" + EnumToString((ENUM_TIMEFRAMES)shortWork) +
          ", monitor=" + EnumToString((ENUM_TIMEFRAMES)longWork);
  comm += "\nTS:" + OrderTS;
  comm += "\nTST:" + OrderTSTrigger;
  comm += "\nTP:" + OrderHiddenTP;
  comm += "\nSL:" + OrderHiddenSL;
  Comment(comm);
}
void PrintLog(string txt) {
  if (IsTesting())
    Print(txt);
}
void AddNotify(string txt) {
  fullNotification += TimeCurrent() + " - " + txt + "\n";
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

template <typename E>
int EnumToArray(E dummy, int &values[], const int start = INT_MIN,
                const int stop = INT_MAX) {
  string t = typename(E) + "::";
  int length = StringLen(t);

  ArrayResize(values, 0);
  int count = 0;

  for (int i = start; i < stop && !IsStopped(); i++) {
    E e = (E)i;
    if (StringCompare(StringSubstr(EnumToString(e), 0, length), t) != 0) {
      ArrayResize(values, count + 1);
      values[count++] = i;
    }
  }
  return count;
}

void calculateBetterTransactionTime() {
  if (!countPeriods) {
    ENUM_TIMEFRAMES periodList;
    countPeriods = EnumToArray(periodList, allPeriods, PERIOD_M1, longWork);
  }
  PrintLog("Spread: " + getSpreadPoints());
  PrintLog("Count Periods: " + countPeriods);
  int EvaluatePeriods = 10, diferencePoints = 0,
      actionValue = getSpreadPoints() * pareto;
  double higthMa, lowMa, toPoints = MarketInfo(Symbol(), MODE_TICKVALUE) *
                                    MarketInfo(Symbol(), MODE_TICKSIZE);
  for (int i = 0; i < countPeriods; i++) {
    // Print("Period ", i, " ", EnumToString((ENUM_TIMEFRAMES)allPeriods[i]),
    // "=",
    //      allPeriods[i]);
    higthMa = iMA(Symbol(), allPeriods[i], EvaluatePeriods, 0, MODE_EMA,
                  PRICE_HIGH, 0);
    lowMa = iMA(Symbol(), allPeriods[i], EvaluatePeriods, 0, MODE_EMA,
                PRICE_LOW, 0);
    diferencePoints = (higthMa - lowMa) / toPoints;
    if (!diferencePoints)
      continue;
    // PrintLog(actionValue + "->" + actionValue/pareto + "->" + diferencePoints
    // + "->" + EnumToString((ENUM_TIMEFRAMES)allPeriods[i]));
    if (!shortWork && diferencePoints >= actionValue) {
      shortWork = allPeriods[i];
      continue;
    }
    if (diferencePoints >= (getSpreadPoints() / pareto)) {
      longWork = allPeriods[i];
      break;
    }
  }
  Print("Period: work=", EnumToString((ENUM_TIMEFRAMES)shortWork), ", monitor=",
        EnumToString((ENUM_TIMEFRAMES)longWork));
}

bool canOrder(int type) {
  double margin = 0, useValue = 0, useReference;
  if (strategiesLimitBorderUp || strategiesLimitBorderDown) {
    if (strategiesLimitBorderUp && type == OP_BUY) {
      useReference = iHigh(Symbol(), PERIOD_D1, 1);
      useValue = Bid;
    }
    if (strategiesLimitBorderDown && type == OP_SELL) {
      useReference = iLow(Symbol(), PERIOD_D1, 1);
      useValue = Ask;
    }
    if (useValue) {
      margin = NormalizeDouble(MathAbs(useReference - useValue), Digits) /
               getPipValue();
      return margin > (getSpreadPoints() * 3);
    }
  }
  return true;
}
bool canOrderAsk(int type, int period) {
  double margin = 0, useValue = 0, useReference;
  if (type == OP_BUY) {
    useReference = iHigh(Symbol(), period, 1);
    useValue = Bid;
  }
  if (type == OP_SELL) {
    useReference = iLow(Symbol(), period, 1);
    useValue = Ask;
  }
  if (useValue) {
    margin = NormalizeDouble(MathAbs(useReference - useValue), Digits) /
              getPipValue();
    return margin > (getSpreadPoints() * 2);
  }
  return false;
}
//-------- Debit/Credit total -------------------
double Deposits() 
{ 
   double total=0; 
   for (int i=0; i<OrdersHistoryTotal(); i++) 
      { 
         if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) 
            {
               if(OrderType()>5)
                  {
                     total+=OrderProfit(); 
                           
                  }
            }     
      }  
   return(total); 
}
