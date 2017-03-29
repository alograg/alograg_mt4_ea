/*-----------------------------------------------------------------+
|                                                   WeekendGap.mqh |
|                                          Copyright 2017, Alograg |
|                                           https://www.alograg.me |
+-----------------------------------------------------------------*/

#property copyright "Copyright 2017, Alograg"
#property link "https://www.alograg.me"
#property version propVersion
#property strict

int totalOrders = 0, yearDay;
datetime time0;
double currentPoint;
double pip;

void initUtilsGlobals()
{
  totalOrders = OrdersTotal();
  time0 = Time[0];
  pip = getPip();
  currentPoint = getCurrentPoint();
  yearDay = TimeDayOfYear(Time[0]);
}

double pipPrice(double price)
{
  return NormalizeDouble(getPip() / price, 2);
}

double getPip()
{
  if (pip >= 0)
    return pip;
  double pipDecimals = getCurrentPoint();
  return pipDecimals * SymbolInfoDouble(Symbol(), SYMBOL_TRADE_CONTRACT_SIZE);
}

double getCurrentPoint()
{
  if (currentPoint >= 0)
    return currentPoint;
  double returnPoint = Point;
  if (Digits == 3 || Digits == 5)
    returnPoint *= 10;
  return returnPoint;
}

/*-----------------------------------------------------------------+
| LotSize                                                          |
+-----------------------------------------------------------------*/
double getLotSize(double Risk = 2, double SL = 0)
{
  if (AccountFreeMargin() < AccountBalance() * 0.2)
    return 0.0;
  if (SL == 0)
    SL = (iATR(Symbol(), PERIOD_M1, 15, 1) * Risk) + (MarketInfo(Symbol(), MODE_SPREAD) * Point);
  else {
    SL *= (iATR(Symbol(), PERIOD_M1, 15, 1) * Risk) + (MarketInfo(Symbol(), MODE_SPREAD) * Point);
  }
  double MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);
  double MinLot = MarketInfo(Symbol(), MODE_MINLOT);
  double StopLoss = SL / Point / 10;
  double Size = Risk / 100 * (AccountFreeMargin() * 0.2) / 10 / StopLoss;
  if (Size <= MinLot)
    Size = MinLot;
  if (Size >= MaxLot)
    Size = MaxLot;
  return (NormalizeDouble(Size, 2));
}

bool CheckNewBar()
{
  if (Time[0] == time0)
    return false;
  time0 = Time[0];
  return true;
}

/*-----------------------------------------------------------------+
| Si es un nuevo dia para el simbolo actual                        |
+-----------------------------------------------------------------*/
bool isNewDay()
{

  if (TimeDayOfYear(Time[0]) == yearDay)
    return false;
  yearDay = TimeDayOfYear(Time[0]);
  return true;
}

bool isFornComment(string comment)
{
  if (comment == NULL)
    return true;
  return OrderComment() == comment;
}

/*-----------------------------------------------------------------+
| Count Open Trades                                                |
|   opType:       Tipo de operacion                                |
|   MagicNumber:  Numero magico para buscar                        |
|   commnet:      Comentarios de filtro (opcional)                 |
+-----------------------------------------------------------------*/
int COT(int opType, int FilterMagicNumber, string commnetFilter = NULL)
{
  int count = 0, hasOrder;
  for (int cnt_COT = 0; cnt_COT < totalOrders; cnt_COT++)
  {
    hasOrder = OrderSelect(cnt_COT, SELECT_BY_POS, MODE_TRADES);
    if (OrderSymbol() == Symbol() && OrderMagicNumber() == FilterMagicNumber && opType == OrderType() && isFornComment(commnetFilter))
      count++;
  }
  return count;
}

void TrailingOpenOrders(double TrailingStop = 10, int FilterMagicNumber = MagicNumber, string commnetFilter = NULL)
{
  if (TrailingStop <= 0)
    return;
  double MyPoint = getCurrentPoint(), profit;
  int currentOrder;
  TrailingStop += MarketInfo(Symbol(), MODE_STOPLEVEL);
  for (int cnt = 0; cnt < totalOrders; cnt++)
  {
    currentOrder = OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
    if (OrderSymbol() != Symbol() && !currentOrder && OrderMagicNumber() == FilterMagicNumber && isFornComment(commnetFilter))
      continue;
    if (OrderType() <= OP_SELL)
    {
      profit = NormalizeDouble(OrderProfit() + OrderCommission() + OrderSwap(), 2);
      if (profit < 0.01)
        continue;
      if (OrderType() == OP_BUY)
      {
        if (Bid - OrderOpenPrice() > MyPoint * TrailingStop && OrderStopLoss() < Bid - MyPoint * TrailingStop)
        {
          currentOrder = OrderModifyReliable(OrderTicket(), OrderOpenPrice(), Bid - TrailingStop * MyPoint, OrderTakeProfit(), 0, Yellow);
          continue;
        }
      }
      else
      {
        if ((OrderOpenPrice() - Ask) > (MyPoint * TrailingStop) && ((OrderStopLoss() > (Ask + MyPoint * TrailingStop)) || (OrderStopLoss() == 0)))
        {
          currentOrder = OrderModifyReliable(OrderTicket(), OrderOpenPrice(), Ask + MyPoint * TrailingStop, OrderTakeProfit(), 0, Yellow);
          continue;
        }
      }
    }
  }
}

void SendReport()
{
  string subject, accountReport, balanceReport;
  subject = "MT4 Report " + TimeToString(TimeCurrent());
  accountReport = "";
  accountReport += StringFormat("Broker; %s", AccountInfoString(ACCOUNT_COMPANY));
  accountReport += "\n";
  accountReport += StringFormat("Deposit currency; %s", AccountInfoString(ACCOUNT_CURRENCY));
  accountReport += "\n";
  accountReport += StringFormat("Client name; %s ", AccountInfoString(ACCOUNT_NAME));
  accountReport += "\n";
  accountReport += StringFormat("Server; %s", AccountInfoString(ACCOUNT_SERVER));
  accountReport += "\n";
  accountReport += StringFormat("LOGIN =  %d", AccountInfoInteger(ACCOUNT_LOGIN));
  accountReport += "\n";
  accountReport += StringFormat("LEVERAGE =  %d", AccountInfoInteger(ACCOUNT_LEVERAGE));
  accountReport += "\n";
  bool thisAccountTradeAllowed = AccountInfoInteger(ACCOUNT_TRADE_ALLOWED);
  bool EATradeAllowed = AccountInfoInteger(ACCOUNT_TRADE_EXPERT);
  ENUM_ACCOUNT_TRADE_MODE tradeMode = (ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
  ENUM_ACCOUNT_STOPOUT_MODE stopOutMode = (ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);
  //--- Inform about the possibility to perform a trade operation
  accountReport += "Trade is ";
  accountReport += thisAccountTradeAllowed ? "permitted" : "prohibited";
  accountReport += ". ";
  //--- Find out if it is possible to trade on this account by Expert Advisors
  accountReport += "Expert Advisors ";
  accountReport += EATradeAllowed ? "permitted" : "prohibited";
  accountReport += ". Is a ";
  //--- Find out the account type
  switch (tradeMode)
  {
  case (ACCOUNT_TRADE_MODE_DEMO):
    accountReport += "demo";
    break;
  case (ACCOUNT_TRADE_MODE_CONTEST):
    accountReport += "competition";
    break;
  default:
    accountReport += "real";
  }
  accountReport += " account. The StopOut level is ";
  //--- Find out the StopOut level setting mode
  switch (stopOutMode)
  {
  case (ACCOUNT_STOPOUT_MODE_PERCENT):
    accountReport += "percentage";
    break;
  default:
    accountReport += "monetary";
  }
  accountReport += ".\n";
  balanceReport += "Date " + TimeToString(Time[0]) + "\n";
  balanceReport += StringFormat("BALANCE        = %G", AccountInfoDouble(ACCOUNT_BALANCE));
  balanceReport += "\n";
  balanceReport += StringFormat("PROFIT         = %G", AccountInfoDouble(ACCOUNT_PROFIT));
  balanceReport += "\n";
  balanceReport += StringFormat("EQUITY         = %G", AccountInfoDouble(ACCOUNT_EQUITY));
  balanceReport += "\n";
  balanceReport += StringFormat("MARGIN         = %G", AccountInfoDouble(ACCOUNT_MARGIN));
  balanceReport += "\n";
  balanceReport += StringFormat("MARGIN FREE    = %G", AccountInfoDouble(ACCOUNT_FREEMARGIN));
  balanceReport += "\n";
  balanceReport += StringFormat("MARGIN LEVEL   = %G", AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
  balanceReport += "\n";
  SendMail(subject, accountReport + balanceReport);
  SendNotification(balanceReport);
}
