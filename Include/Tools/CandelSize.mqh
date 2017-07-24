/*--------------------------+
|            CandelSize.mqh |
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
// Function
double getCandelSize(int period = PERIOD_H1) {
  return NormalizeDouble(
      MathAbs(iHigh(Symbol(), period, 1) - iLow(Symbol(), period, 1)), Digits);
}
