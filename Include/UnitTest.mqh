/*--------------------------+
|              UnitTest.mqh |
| Copyright © 2018, Alograg |
|    https://www.alograg.me |
+--------------------------*/
// Properties
#property copyright "Copyright © 2018, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Parameter
extern double testDeposit = 100;  // Deposit for test
extern double testWithdrawal = 0; // Withdrawal for test
// Constants
int die[];
string TestComment = eaName + ": Manual test";
int manualOrder = 0;
bool canWithdrawal = false;
bool canDeposit = false;
// Functions
void dieOn(datetime dateTime)
{
  MqlDateTime dayTime, inTime;
  TimeToStruct(iTime(Symbol(), PERIOD_M1, 0), dayTime);
  TimeToStruct(dateTime, inTime);
  if (dayTime.year == inTime.year && dayTime.mon == inTime.mon &&
      dayTime.day == inTime.day && dayTime.hour == inTime.hour &&
      dayTime.min == inTime.min)
    die[1];
}
void closeOrderOn(datetime dateTime, int ticket)
{
  MqlDateTime dayTime, inTime;
  TimeToStruct(iTime(Symbol(), PERIOD_M1, 0), dayTime);
  TimeToStruct(dateTime, inTime);
  if (dayTime.year == inTime.year && dayTime.mon == inTime.mon &&
      dayTime.day == inTime.day && dayTime.hour == inTime.hour &&
      dayTime.min == inTime.min)
  {
    if (OrderSelect(ticket, SELECT_BY_TICKET))
    {
      int mode = OrderType();
      double lostClose = NormalizeDouble(mode ? Ask : Bid, Digits);
      if (!OrderClose(ticket, OrderLots(), lostClose, 0, Yellow))
        ReportError("closeOrderOn", GetLastError());
    }
  }
}
void orderOn(datetime dateTime, double lotSize = 0, bool onlyOnece = true)
{
  if (manualOrder)
    manualOrder = OrderIsOpen(manualOrder);
  if (manualOrder)
    return;
  MqlDateTime dayTime, inTime;
  TimeToStruct(iTime(Symbol(), PERIOD_M1, 0), dayTime);
  TimeToStruct(dateTime, inTime);
  if (dayTime.year == inTime.year && dayTime.mon == inTime.mon &&
      dayTime.day == inTime.day && dayTime.hour == inTime.hour &&
      dayTime.min == inTime.min)
  {
    RefreshRates();
    manualOrder = OrderSend(
        Symbol(), lotSize > 0 ? OP_BUY : OP_SELL,
        NormalizeDouble(MathAbs(lotSize), 2), lotSize > 0 ? Ask : Bid, 0,
        (lotSize > 0 ? Bid : Ask) +
            NormalizeDouble(100 * (lotSize < 0 ? 3 : -3) * Point, Digits),
        (lotSize > 0 ? Ask : Bid) +
            NormalizeDouble(300 * (lotSize > 0 ? 3 : -3) * Point, Digits),
        TestComment, 0, 0, White);
    // die[0];
  }
  if (!onlyOnece)
    manualOrder = 0;
}
