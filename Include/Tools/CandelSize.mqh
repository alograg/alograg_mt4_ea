/*--------------------------+
|            CandelSize.mqh |
| Copyright © 2018, Alograg |
|    https://www.alograg.me |
+--------------------------*/
// Properties
#property copyright "Copyright © 2018, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Parameters
// Constants
// Function
double getCandelSize(string sym = null, int period = PERIOD_H1, int shift = 1)
{
  sym = sym ?: Symbol();
  return NormalizeDouble(
      MathAbs(iHigh(sym, period, shift) - iLow(sym, period, shift)),
      Digits);
}
double getFlagSize(string sym = null, int period = PERIOD_H1, int shift = 1)
{
  sym = sym ?: Symbol();
  return NormalizeDouble(
      MathAbs(iOpen(sym, period, shift) - iClose(sym, period, shift)),
      Digits);
}
double getLowerShadowSize(string sym = null, int period = PERIOD_H1, int shift = 1)
{
  sym = sym ?: Symbol();
  double bodyDown =
      MathMin(iOpen(sym, period, shift), iClose(sym, period, shift));
  return NormalizeDouble(MathAbs(bodyDown - iLow(sym, period, shift)),
                         Digits);
}
double getUpperShadowSize(string sym = null, int period = PERIOD_H1, int shift = 1)
{
  sym = sym ?: Symbol();
  double bodyUp =
      MathMin(iOpen(sym, period, shift), iClose(sym, period, shift));
  return NormalizeDouble(MathAbs(bodyUp - iHigh(sym, period, shift)),
                         Digits);
}
bool isBlackCandel(string sym = null, int period = PERIOD_H1, int shift = 1)
{
  sym = sym ?: Symbol();
  return iOpen(sym, period, shift) > iClose(sym, period, shift);
}
bool isWhiteCandel(string sym = null, int period = PERIOD_H1, int shift = 1)
{
  sym = sym ?: Symbol();
  return iOpen(sym, period, shift) < iClose(sym, period, shift);
}
