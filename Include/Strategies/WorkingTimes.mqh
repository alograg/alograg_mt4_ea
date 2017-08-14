/*------------------------+
|       WorkingTime.mqh |
| Copyright 2017, Alograg |
|  https://www.alograg.me |
+------------------------*/
// Propiedades
#property copyright "Copyright 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Constants
string WorkingTimeComment = eaName + ": S-WorkingTime";
int WorkingTimeOrderBuy = -1;
int WorkingTimeOrderSell = -1;
// Parameters
void WorkingTime() {
  int period = PERIOD_M5;
  if (!isNewBar(period)) {
    if (WorkingTimeOrderBuy)
      WorkingTimeOrderBuy = OrderIsOpen(WorkingTimeOrderBuy);
    if (WorkingTimeOrderSell)
      WorkingTimeOrderSell = OrderIsOpen(WorkingTimeOrderSell);
    return;
  }
}
