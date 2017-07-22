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
int morningOrderBuy = 0;
int morningOrderSell = 0;
void Morning() {
  Print(MorningComment);
  if (!isNewBar(PERIOD_D1)) {
    Print("NewBar: PERIOD_D1");
    morningOrderBuy = isOpenOrder(morningOrderBuy);
    morningOrderSell = isOpenOrder(morningOrderSell);
    return;
  }
  Print("Action:" + MorningComment);
  if (morningOrderBuy == 0)
    morningOrderBuy = OrderSendReliable(Symbol(), OP_BUY, 0.01, Ask, 0, 0, 0,
                                        MorningComment, MagicNumber, 0, Green);
  if (morningOrderSell == 0)
    morningOrderSell = OrderSendReliable(Symbol(), OP_SELL, 0.01, Bid, 0, 0, 0,
                                         MorningComment, MagicNumber, 0, Green);
}
