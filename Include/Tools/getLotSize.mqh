/*--------------------------+
|            getLotSize.mqh |
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
double getLotSize() {
  return moneyOnRisk() ? 0 : MathMax(AccountEquity() / 4000, 0);
}