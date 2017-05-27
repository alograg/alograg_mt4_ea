/*------------------------+
|        FlowTheEnemy.mqh |
| Copyright 2017, Alograg |
|  https://www.alograg.me |
+------------------------*/

#property copyright "Copyright 2017, Alograg"
#property link "https://www.alograg.me"
#property version propVersion
#property strict

string FlowTheEnemyComment = eaName + ": FlowTheEnemy";

double arrayOut[];

void FlowTheEnemy() {
  if (!CheckNewBar())
    return;
  double SignalCurrent = NormalizeDouble(
      iMACD(Symbol(), PERIOD_H4, 12, 26, 9, PRICE_TYPICAL, MODE_MAIN, 0),
      Digits);
  double SignalPrevious1 = NormalizeDouble(
      iMACD(Symbol(), PERIOD_H4, 12, 26, 9, PRICE_TYPICAL, MODE_MAIN, 1),
      Digits);
  double SignalPrevious2 = NormalizeDouble(
      iMACD(Symbol(), PERIOD_H4, 12, 26, 9, PRICE_TYPICAL, MODE_MAIN, 2),
      Digits);
  double SignalPrevious3 = NormalizeDouble(
      iMACD(Symbol(), PERIOD_H4, 12, 26, 9, PRICE_TYPICAL, MODE_MAIN, 3),
      Digits);
  double SignalPrevious4 = NormalizeDouble(
      iMACD(Symbol(), PERIOD_H4, 12, 26, 9, PRICE_TYPICAL, MODE_MAIN, 4),
      Digits);
  double SignalPrevious5 = NormalizeDouble(
      iMACD(Symbol(), PERIOD_H4, 12, 26, 9, PRICE_TYPICAL, MODE_MAIN, 5),
      Digits);
  bool canBuy = SignalCurrent < SignalPrevious1 &&
                SignalPrevious1 < SignalPrevious2 &&
                SignalPrevious2 > SignalPrevious3 &&
                SignalPrevious3 > SignalPrevious4 &&
                SignalPrevious4 > SignalPrevious5
                ;
  bool canSell = SignalCurrent > SignalPrevious1 &&
                 SignalPrevious1 > SignalPrevious2 &&
                 SignalPrevious2 < SignalPrevious3 &&
                 SignalPrevious3 < SignalPrevious4 &&
                 SignalPrevious4 < SignalPrevious5
                 ;
  if(!canBuy && !canSell)
    return;
  int sourceTicket, enemyTicket, hasOrder,
      searchIn = OrdersTotal(),
      closeCount = 0;
      ;
  for (int cnt_COT = 0; cnt_COT < searchIn; cnt_COT++) {
    if(!OrderSelect(cnt_COT, SELECT_BY_POS, MODE_TRADES)) continue;
    sourceTicket = OrderTicket();
    if (OrderSymbol() == Symbol() 
        && OrderMagicNumber() == MagicNumber 
        && isFornComment(FlowTheLiderComment, OrderComment())){
          enemyTicket=0;
          closeCount++;
          if (OrderType() == OP_BUY) {
              enemyTicket = OrderSendReliable(Symbol(), OP_SELL, OrderLots(), Ask, 3, 0, 0, FlowTheEnemyComment, MagicNumber, 0, Yellow);
          } else if(OrderType() == OP_SELL) {
              enemyTicket = OrderSendReliable(Symbol(), OP_BUY, OrderLots(), Bid, 3, 0, 0, FlowTheEnemyComment, MagicNumber, 0, Yellow);
          }
          if(enemyTicket){
            Print("Close ", sourceTicket , " with ", enemyTicket);
            //hasOrder = OrderCloseBy(sourceTicket, enemyTicket, Yellow);
          }
        }
  }
  if(closeCount > 0) {
    Print(FlowTheEnemyComment, ": ", closeCount);
    yesReset();
  }
}
