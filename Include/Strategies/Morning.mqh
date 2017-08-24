/*------------------------+
|             Morning.mqh |
| Copyright 2017, Alograg |
|  https://www.alograg.me |
+------------------------*/
// Propiedades
#property copyright "Copyright 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Constants
string MorningComment = eaName + ": S-Morning";
int morningOrderBuy = -1;
int morningOrderSell = -1;
void Morning() {
  if (!isNewBar(PERIOD_D1)) {
    if (morningOrderBuy > 0)
      morningOrderBuy = OrderIsOpen(morningOrderBuy);
    if (morningOrderSell > 0)
      morningOrderSell = OrderIsOpen(morningOrderSell);
    return;
  }
  if (Hour() != 0 && Minute() != 0) {
    if (IsTradeAllowed())
      SendNotification("Not time to morning work");

    return;
  }
  // TODO: evitar gaps
  double lotSize = getLotSize();
  if (lotSize <= 0)
    return;
  while (morningOrderBuy <= 0 || morningOrderSell <= 0) {
    if (morningOrderBuy <= 0)
      morningOrderBuy = OrderSend(Symbol(), OP_BUY, lotSize, Ask, 0, 0, 0,
                                  MorningComment, MagicNumber, 0, Blue);
    if (morningOrderSell <= 0)
      morningOrderSell = OrderSend(Symbol(), OP_SELL, lotSize, Bid, 0, 0, 0,
                                   MorningComment, MagicNumber, 0, Red);
    if (AccountFreeMargin() < 40)
      break;
    Sleep(500);
  }
  if (morningOrderBuy <= 0)
    ReportError("morningOrderBuy", GetLastError());
  if (morningOrderSell <= 0)
    ReportError("morningOrderSell", GetLastError());
  if (IsTradeAllowed())
    SendNotification("morningOrderBuy: " + (string)morningOrderBuy +
                     ", morningOrderSell: " + (string)morningOrderSell);
}
