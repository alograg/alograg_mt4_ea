/*------------------------+
|          CrossMover.mqh |
| Copyright 2017, Alograg |
|  https://www.alograg.me |
+------------------------*/

#property copyright "Copyright 2017, Alograg"
#property link "https://www.alograg.me"
#property version propVersion
#property strict

string CrossMoverComment = eaName + ": CrossMover";
int cmSellOption, cmBuyOption;

void CrossMover() {
  if (!CheckNewBar())
    return;
  double lotsForTransaction = getLotSize();
  if (lotsForTransaction <= 0)
    return;
  double ma0 = iMA(Symbol(), shortWork, 5, 0, MODE_EMA, PRICE_TYPICAL, 0),
         ma5 = iMA(Symbol(), shortWork, 5, 0, MODE_EMA, PRICE_TYPICAL, 5),
         maH0 = iMA(Symbol(), shortWork, 10, 0, MODE_EMA, PRICE_HIGH, 0),
         maL0 = iMA(Symbol(), shortWork, 10, 0, MODE_EMA, PRICE_LOW, 0),
         maH5 = iMA(Symbol(), shortWork, 10, 0, MODE_EMA, PRICE_HIGH, 5),
         maL5 = iMA(Symbol(), shortWork, 10, 0, MODE_EMA, PRICE_LOW, 5);
  bool canBuy = ma0 > maH0 && ma5 < maL5,
       canSell = ma0 < maL0 && ma5 > maH5;
  if (canBuy)
    cmBuyOption =
        OrderSendReliable(Symbol(), OP_BUY, lotsForTransaction, Ask, 3, 0, 0,
                          CrossMoverComment, MagicNumber, 0, Green);
  if (canSell)
    cmSellOption =
        OrderSendReliable(Symbol(), OP_SELL, lotsForTransaction, Bid, 3, 0, 0,
                          CrossMoverComment, MagicNumber, 0, Red);
}