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
double getFlagSize(int period = PERIOD_H1) {
  return NormalizeDouble(
      MathAbs(iOpen(Symbol(), period, 1) - iClose(Symbol(), period, 1)),
      Digits);
}
double getLowerShadowSize(int period = PERIOD_H1) {
  double bodyDown =
      MathMin(iOpen(Symbol(), period, 1), iClose(Symbol(), period, 1));
  return NormalizeDouble(MathAbs(bodyDown - iLow(Symbol(), period, 1)), Digits);
}
double getUpperShadowSize(int period = PERIOD_H1) {
  double bodyUp =
      MathMin(iOpen(Symbol(), period, 1), iClose(Symbol(), period, 1));
  return NormalizeDouble(MathAbs(bodyUp - iHigh(Symbol(), period, 1)), Digits);
}
