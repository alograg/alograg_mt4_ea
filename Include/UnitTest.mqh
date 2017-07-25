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
// Functions
void dieOn(int hour = 0, int minute = 0) {
  MqlDateTime currentTimeing;
  TimeToStruct(iTime(Symbol(), PERIOD_M1, 0), currentTimeing);
  if (currentTimeing.hour == hour && currentTimeing.min == minute)
    die[1];
}