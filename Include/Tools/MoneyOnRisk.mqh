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
  int stopOut = AccountStopoutMode() ? 50 : AccountStopoutLevel();
  double MarginLevel =
      AccountMargin() > 0
          ? NormalizeDouble(AccountEquity() / AccountMargin() * 100, 2)
          : AccountEquity();
  return !(AccountMargin() <= AccountEquity() / 2 ||
           AccountMargin() <= AccountBalance() / 2 ||
           MarginLevel <= stopOut * 1.5);
}
