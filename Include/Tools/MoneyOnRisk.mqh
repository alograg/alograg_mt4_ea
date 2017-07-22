/*--------------------------+
|            TrailStops.mqh |
| Copyright © 2017, Alograg |
|    https://www.alograg.me |
+--------------------------*/
// Properties
#property copyright "Copyright © 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Parameter
bool moneyOnRisk() {
  return !(AccountMargin() <= AccountEquity() / 2 ||
           AccountMargin() <= AccountBalance() / 2);
}
