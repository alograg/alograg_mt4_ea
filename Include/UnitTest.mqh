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
// Constants
int die[];
string TestComment = eaName + ": Manual test";
int manualOrder = 0;
// Functions
void dieOn(int hour = 0, int minute = 0) {
  MqlDateTime currentTimeing;
  TimeToStruct(iTime(Symbol(), PERIOD_M1, 0), currentTimeing);
  if (currentTimeing.hour == hour && currentTimeing.min == minute)
    die[1];
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