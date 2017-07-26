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
double getCandelSize(int period = PERIOD_H1, int shift = 1) {
  return NormalizeDouble(
      MathAbs(iHigh(Symbol(), period, shift) - iLow(Symbol(), period, shift)),
      Digits);
}
double getFlagSize(int period = PERIOD_H1, int shift = 1) {
  return NormalizeDouble(
      MathAbs(iOpen(Symbol(), period, shift) - iClose(Symbol(), period, shift)),
      Digits);
}
double getLowerShadowSize(int period = PERIOD_H1, int shift = 1) {
  double bodyDown =
      MathMin(iOpen(Symbol(), period, shift), iClose(Symbol(), period, shift));
  return NormalizeDouble(MathAbs(bodyDown - iLow(Symbol(), period, shift)),
                         Digits);
}
double getUpperShadowSize(int period = PERIOD_H1, int shift = 1) {
  double bodyUp =
      MathMin(iOpen(Symbol(), period, shift), iClose(Symbol(), period, shift));
  return NormalizeDouble(MathAbs(bodyUp - iHigh(Symbol(), period, shift)),
                         Digits);
}
