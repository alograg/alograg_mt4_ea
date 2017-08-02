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
datetime LAST_PERIOD_M1, LAST_PERIOD_M5, LAST_PERIOD_M15, LAST_PERIOD_M30,
    LAST_PERIOD_H1, LAST_PERIOD_H4, LAST_PERIOD_D1, LAST_PERIOD_W1,
    LAST_PERIOD_MN1;
// Function
bool isNewBar(int period = 0) {
  if (period == 0) {
    setLatsPeriods(countPeriods == 0);
    return true;
  }
  if (!countPeriods) {
    ENUM_TIMEFRAMES periodList;
    countPeriods = EnumToArray(periodList, allPeriods, PERIOD_M1, PERIOD_D1);
  }
  datetime lastPeriod;
  switch (period) {
  case PERIOD_M1:
    lastPeriod = LAST_PERIOD_M1;
    break;
  case PERIOD_M5:
    lastPeriod = LAST_PERIOD_M5;
    break;
  case PERIOD_M15:
    lastPeriod = LAST_PERIOD_M15;
    break;
  case PERIOD_M30:
    lastPeriod = LAST_PERIOD_M30;
    break;
  case PERIOD_H1:
    lastPeriod = LAST_PERIOD_H1;
    break;
  case PERIOD_H4:
    lastPeriod = LAST_PERIOD_H4;
    break;
  case PERIOD_D1:
    lastPeriod = LAST_PERIOD_D1;
    break;
  case PERIOD_W1:
    lastPeriod = LAST_PERIOD_W1;
    break;
  case PERIOD_MN1:
    lastPeriod = LAST_PERIOD_MN1;
    break;
  default:
    return true;
  }

  return lastPeriod != iTime(Symbol(), period, 0);
}
void setLatsPeriods(int period = 0) {
  LAST_PERIOD_M1 = iTime(Symbol(), PERIOD_M1, period);
  LAST_PERIOD_M5 = iTime(Symbol(), PERIOD_M5, period);
  LAST_PERIOD_M15 = iTime(Symbol(), PERIOD_M15, period);
  LAST_PERIOD_M30 = iTime(Symbol(), PERIOD_M30, period);
  LAST_PERIOD_H1 = iTime(Symbol(), PERIOD_H1, period);
  LAST_PERIOD_H4 = iTime(Symbol(), PERIOD_H4, period);
  LAST_PERIOD_D1 = iTime(Symbol(), PERIOD_D1, period);
  LAST_PERIOD_W1 = iTime(Symbol(), PERIOD_W1, period);
  LAST_PERIOD_MN1 = iTime(Symbol(), PERIOD_MN1, period);
}
