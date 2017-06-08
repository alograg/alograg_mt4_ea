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

int enemyTicket, cleanEnemyOptions;

void FlowTheEnemy() {
  if (!strategiesActivate)
    return;
  if (enemyTicket) {
    cleanEnemyOptions = 0;
    int currentOrder = OrderSelect(enemyTicket, SELECT_BY_TICKET);
    int optionTime = OrderCloseTime();
    if (!optionTime) {
      enemyTicket = 0;
      return;
    }
  }
  if (!CheckNewBar())
    return;
  int countLidersBuy = COT(OP_BUY, MagicNumber, FlowTheLiderComment),
      countLidersSell = COT(OP_SELL, MagicNumber, FlowTheLiderComment);
  if (countLidersBuy + countLidersSell < 1)
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
  double SignalPrevious6 = NormalizeDouble(
      iMACD(Symbol(), PERIOD_H4, 12, 26, 9, PRICE_TYPICAL, MODE_MAIN, 6),
      Digits);
  double SignalPrevious7 = NormalizeDouble(
      iMACD(Symbol(), PERIOD_H4, 12, 26, 9, PRICE_TYPICAL, MODE_MAIN, 7),
      Digits);
  bool canBuy =
      SignalCurrent < SignalPrevious1 && SignalPrevious1 < SignalPrevious2 &&
      SignalPrevious2 > SignalPrevious3 && SignalPrevious3 > SignalPrevious4 &&
      SignalPrevious4 > SignalPrevious5 && SignalPrevious5 > SignalPrevious6 &&
      SignalPrevious6 > SignalPrevious7;
  bool canSell =
      SignalCurrent > 0 && SignalCurrent > SignalPrevious1 &&
      SignalPrevious1 > SignalPrevious2 && SignalPrevious2 < SignalPrevious3 &&
      SignalPrevious3 < SignalPrevious4 && SignalPrevious4 < SignalPrevious5 &&
      SignalPrevious5 < SignalPrevious6 && SignalPrevious6 < SignalPrevious7;
  if (!canBuy && !canSell)
    return;
  int sourceTicket, hasOrder, searchIn = OrdersTotal(), closeCount = 0;
  double enemyLots = 0;
  for (int cnt_COT = 0; cnt_COT < searchIn; cnt_COT++) {
    if (!OrderSelect(cnt_COT, SELECT_BY_POS, MODE_TRADES))
      continue;
    sourceTicket = OrderTicket();
    if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber &&
        isFornComment(FlowTheLiderComment, OrderComment())) {
      enemyTicket = 0;
      closeCount++;
      if (OrderType() == OP_BUY) {
        enemyLots += OrderLots();
      } else if (OrderType() == OP_SELL) {
        enemyLots -= OrderLots();
      }
    }
  }
  //Print("Enemy lots: ", searchIn, "->", closeCount, "->", enemyLots);
  if(enemyLots != 0){
      enemyTicket = OrderSendReliable(Symbol(),
                                      enemyLots < 0 ? OP_BUY : OP_SELL,
                                      MathAbs(enemyLots), enemyLots < 0 ? Bid :  Ask,
                                      3, 0, 0,
                                      FlowTheEnemyComment, MagicNumber, 0, Yellow);
  }
}
