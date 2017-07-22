/*--------------------------+
|              isNewBar.mqh |
| Copyright © 2017, Alograg |
|    https://www.alograg.me |
+--------------------------*/
// Properties
#property copyright "Copyright © 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Parameters
// Constants
int allPeriods[];
int periodsLastBars[];
int countPeriods = 0;
// Function
bool isNewBar(int period = 0) {
  if (!countPeriods) {
    ENUM_TIMEFRAMES periodList;
    countPeriods = EnumToArray(periodList, allPeriods, PERIOD_M1, PERIOD_D1);
    EnumToArray(periodList, periodsLastBars, PERIOD_M1, PERIOD_D1);
  }
  if (period == 0) {
    for (int i = 0; i < countPeriods; i++) {
      periodsLastBars[i] = iTime(Symbol(), allPeriods[i], 0);
    }
    return true;
  }
  for (int i = 0; i < countPeriods; i++) {
    if (allPeriods[i] == period) {
      Print("Evalua " + period + "=" +
            (periodsLastBars[i] != iTime(Symbol(), period, 0)));
      return periodsLastBars[i] != iTime(Symbol(), period, 0);
    }
  }
  return periodsLastBars[0] != iTime(Symbol(), PERIOD_M1, 0);
}