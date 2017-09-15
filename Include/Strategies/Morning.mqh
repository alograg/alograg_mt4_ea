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
double MorningOperations = 2;
int morningOrderBuy = -1;
int morningOrderSell = -1;
void Morning() {
  bool timeToOperate = Hour() == 0 && Minute() == 1;
  if (!timeToOperate) {
    if (morningOrderBuy > 0)
      morningOrderBuy = OrderIsOpen(morningOrderBuy);
    if (morningOrderSell > 0)
      morningOrderSell = OrderIsOpen(morningOrderSell);
    bool probablyLoseBuy =
        morningOrderBuy > 0 && morningOrderSell <= 0 && Hour() == 12;
    bool probablyLoseSell =
        morningOrderSell > 0 && morningOrderBuy <= 0 && Hour() == 12;
    int age;
    if (probablyLoseBuy) {
      if (!OrderModify(morningOrderBuy, OrderOpenPrice(), OrderStopLoss(),
                       NormalizeDouble(
                           OrderOpenPrice() +
                               ((breakInSpread ? getSpread() : BreakEven) / 3),
                           Digits),
                       0, Yellow) &&
          GetLastError() > 1 && TRUE)
        ReportError("ProbablyLoseBuySetProfit", GetLastError());
    }
    if (probablyLoseSell) {
      if (!OrderModify(morningOrderSell, OrderOpenPrice(), OrderStopLoss(),
                       NormalizeDouble(
                           OrderOpenPrice() -
                               ((breakInSpread ? getSpread() : BreakEven) / 3),
                           Digits),
                       0, Yellow) &&
          GetLastError() > 1 && TRUE)
        ReportError("ProbablyLoseSellSetProfit", GetLastError());
    }
    return;
  }
  // TODO: evitar gaps
  double lotSize = getLotSize();
  if (lotSize <= 0)
    return;
  bool cantBuy = AccountFreeMarginCheck(Symbol(), OP_BUY, lotSize) <= 0 ||
                 GetLastError() == 134,
       cantSell = AccountFreeMarginCheck(Symbol(), OP_SELL, lotSize) <= 0 ||
                  GetLastError() == 134;
  if (cantBuy || cantSell)
    return;
  while (morningOrderBuy <= 0 || morningOrderSell <= 0) {
    if (morningOrderBuy <= 0)
      morningOrderBuy = OrderSend(Symbol(), OP_BUY, lotSize, Ask, 0, 0,
                                  AurealTakeProfits(OP_BUY, lotSize),
                                  MorningComment, MagicNumber, 0, Blue);
    if (morningOrderSell <= 0)
      morningOrderSell = OrderSend(Symbol(), OP_SELL, lotSize, Bid, 0, 0,
                                   AurealTakeProfits(OP_SELL, lotSize),
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
