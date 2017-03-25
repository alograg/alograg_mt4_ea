/*-----------------------------------------------------------------+
|                                                   WeekendGap.mqh |
|                                          Copyright 2017, Alograg |
|                                           https://www.alograg.me |
+-----------------------------------------------------------------*/

#property copyright "Copyright 2017, Alograg"
#property link "https://www.alograg.me"
#property version propVersion
#property strict

int totalOrders = 0;

double getCurrentPoint()
{
  double currentPoint = Point;
  if (Digits == 3 || Digits == 5)
    currentPoint = Point * 10;
  return currentPoint;
}

/*-----------------------------------------------------------------+
| Si es un nuevo dia para el simbolo actual                        |
+-----------------------------------------------------------------*/
bool isNewDay()
{
  string lastReportLabel = StringFormat("%i_%s_LastDay", AccountNumber(), Symbol());
  double lastReport = GlobalVariableGet(lastReportLabel);
  double toDay = TimeDayOfWeek(Time[0]);
  if (lastReport != toDay)
  {
    GlobalVariableSet(lastReportLabel, toDay);
    return true;
  }
  return false;
}

/*-----------------------------------------------------------------+
| Check Open Trades                                                |
|   opType:       Tipo de operacion                                |
|   MagicNumber: Numero magico para buscar                        |
+-----------------------------------------------------------------*/
int COT(int opType, int FilterMagicNumber)
{
  int count = 0, hasOrder;
  for (int cnt_COT = 0; cnt_COT < totalOrders; cnt_COT++)
  {
    hasOrder = OrderSelect(cnt_COT, SELECT_BY_POS, MODE_TRADES);
    if (OrderSymbol() == Symbol() && OrderMagicNumber() == FilterMagicNumber && opType == OrderType())
      count++;
  }
  return count;
}

/*-----------------------------------------------------------------+
| LotSize                                                          |
+-----------------------------------------------------------------*/
double getLotSize(double Risk = 2, double SL = 0)
{
  if(SL == 0)
    SL = MarketInfo(Symbol(), MODE_SPREAD) * Point;
  double MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);
  double MinLot = MarketInfo(Symbol(), MODE_MINLOT);
  double StopLoss = SL / Point / 10;
  double Size = Risk / 100 * AccountFreeMargin() / 10 / StopLoss;
  if (Size <= MinLot)
    Size = MinLot;
  if (Size >= MaxLot)
    Size = MaxLot;
  return (NormalizeDouble(Size, 2));
}

void TrailingOpenOrders(double TrailingStop = 1, int FilterMagicNumber = MagicNumber)
{
  if (TrailingStop <= 0)
    return;
  double MyPoint = getCurrentPoint(), profit;
  int currentOrder;
  TrailingStop += MarketInfo(Symbol(), MODE_STOPLEVEL);
  for (int cnt = 0; cnt < totalOrders; cnt++)
  {
    currentOrder = OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
    if (OrderSymbol() != Symbol() && !currentOrder && OrderMagicNumber() == FilterMagicNumber)
      continue;
    if (OrderType() <= OP_SELL)
    {
      profit = NormalizeDouble(OrderProfit() + OrderCommission() + OrderSwap() - 0.01, 2);
      if(profit < 0) continue;
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

bool isFornComment(string comment)
{
    if(comment == NULL)
        return true;
    return OrderComment() == comment;
}