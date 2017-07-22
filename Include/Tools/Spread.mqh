/*--------------------------+
|                Spread.mqh |
| Copyright © 2017, Alograg |
|    https://www.alograg.me |
+--------------------------*/
// Properties
#property copyright "Copyright © 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Parameters
extern double SpreadSize = 100; // Size of spread reference
// Constants
int SpreadSampleSize = 0;
double Spread[];
// Function
double getSpread(double AddValue = 0) {
  double LastValue;
  static double ArrayTotal = 0;

  if (SpreadSampleSize == 0)
    SpreadSampleSize = SpreadSize;

  if (AddValue == 0 && SpreadSampleSize <= 0)
    return (Ask - Bid);
  if (AddValue == 0 && ArrayTotal == 0)
    return (Ask - Bid);
  if (AddValue == 0)
    return (ArrayTotal / ArraySize(Spread));

  ArrayTotal = ArrayTotal + AddValue;
  ArraySetAsSeries(Spread, true);
  if (ArraySize(Spread) == SpreadSampleSize) {
    LastValue = Spread[0];
    ArrayTotal = ArrayTotal - LastValue;
    ArraySetAsSeries(Spread, false);
    ArrayResize(Spread, ArraySize(Spread) - 1);
    ArraySetAsSeries(Spread, true);
    ArrayResize(Spread, ArraySize(Spread) + 1);
  } else
    ArrayResize(Spread, ArraySize(Spread) + 1);
  ArraySetAsSeries(Spread, false);
  Spread[0] = AddValue;
  return (NormalizeDouble(ArrayTotal / ArraySize(Spread), Digits));
}
