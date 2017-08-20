/*--------------------------+
|              UnitTest.mqh |
| Copyright © 2017, Alograg |
|    https://www.alograg.me |
+--------------------------*/
// Properties
#property copyright "Copyright © 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Parameter
extern double testDeposit = 782.28;    // Deposit for test
extern double testWithdrawal = -82.28; // Withdrawal for test
// Constants 348.07
int die[];
string TestComment = eaName + ": Manual test";
int manualOrder = 0;
bool canWithdrawal = false;
bool canDeposit = false;
// Functions
void dieOn(datetime dateTime) {
  MqlDateTime dayTime, inTime;
  TimeToStruct(iTime(Symbol(), PERIOD_M1, 0), dayTime);
  TimeToStruct(dateTime, inTime);
  if (dayTime.year == inTime.year && dayTime.mon == inTime.mon &&
      dayTime.day == inTime.day && dayTime.hour == inTime.hour &&
      dayTime.min == inTime.min)
    die[1];
}
void closeOrderOn(datetime dateTime, int ticket) {
  MqlDateTime dayTime, inTime;
  TimeToStruct(iTime(Symbol(), PERIOD_M1, 0), dayTime);
  TimeToStruct(dateTime, inTime);
  if (dayTime.year == inTime.year && dayTime.mon == inTime.mon &&
      dayTime.day == inTime.day && dayTime.hour == inTime.hour &&
      dayTime.min == inTime.min) {
    if (OrderSelect(ticket, SELECT_BY_TICKET)) {
      int mode = OrderType();
      double lostClose = NormalizeDouble(mode ? Ask : Bid, Digits);
      if (!OrderClose(ticket, OrderLots(), lostClose, 0, Yellow))
        ReportError("closeOrderOn", GetLastError());
    }
  }
}
void orderOn(datetime dateTime, double lotSize = 0, bool onlyOnece = true) {
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
    manualOrder =
        OrderSend(Symbol(), lotSize > 0 ? OP_BUY : OP_SELL,
                  NormalizeDouble(MathAbs(lotSize), 2), lotSize > 0 ? Bid : Ask,
                  0, 0, 0, TestComment, MagicNumber, 0, White);
  if (!onlyOnece)
    manualOrder = 0;
}
void addFounds(double amount, datetime dateTime = NULL) {
  if (dateTime) {
    MqlDateTime dayTime, inTime;
    TimeToStruct(iTime(Symbol(), PERIOD_M1, 0), dayTime);
    TimeToStruct(dateTime, inTime);
    if (!(dayTime.year == inTime.year && dayTime.mon == inTime.mon &&
          dayTime.day == inTime.day && dayTime.hour == inTime.hour &&
          dayTime.min == inTime.min)) {
      canDeposit = true;
      return;
    }
  } else {
    canDeposit = true;
  }
  if (canDeposit) {
    canDeposit = false;
    deposit += amount;
  }
}
void doWithdrawal(double amount, datetime dateTime = NULL) {
  if (dateTime) {
    MqlDateTime dayTime, inTime;
    TimeToStruct(iTime(Symbol(), PERIOD_M1, 0), dayTime);
    TimeToStruct(dateTime, inTime);
    if (!(dayTime.year == inTime.year && dayTime.mon == inTime.mon &&
          dayTime.day == inTime.day && dayTime.hour == inTime.hour &&
          dayTime.min == inTime.min)) {
      canWithdrawal = true;
      return;
    }
  } else {
    canDeposit = true;
  }
  if (canWithdrawal) {
    canWithdrawal = false;
    withdrawal -= amount;
  }
}
