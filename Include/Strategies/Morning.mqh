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
    morningOrderBuy = OrderIsOpen(morningOrderBuy);
    morningOrderSell = OrderIsOpen(morningOrderSell);
    return;
  }
  if (morningOrderBuy <= 0)
    morningOrderBuy =
        OrderSendReliable(Symbol(), OP_BUY, getLotSize(), Ask, 0, 0, 0,
                          MorningComment, MagicNumber, 0, Blue);
  if (morningOrderSell <= 0)
    morningOrderSell =
        OrderSendReliable(Symbol(), OP_SELL, getLotSize(), Bid, 0, 0, 0,
                          MorningComment, MagicNumber, 0, Red);
}
