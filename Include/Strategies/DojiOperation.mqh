/*------------------------+
|       DojiOperation.mqh |
| Copyright 2017, Alograg |
|  https://www.alograg.me |
+------------------------*/
// Propiedades
#property copyright "Copyright 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Constants
string DojiOperationComment = eaName + ": S-DojiOperation";
int DojiInThisDay = 0;
int DojiOperationOrderBuy = -1;
int DojiOperationOrderSell = -1;
// Parameters
extern double DojiOperationProfitStop = 1; // Profit per day
extern int dojisPerDay = 2;                // Dojis operations per day
void DojiOperation() {
  int period = PERIOD_M15;
  if (!isNewBar(period)) {
    if (DojiOperationOrderBuy)
      DojiOperationOrderBuy = OrderIsOpen(DojiOperationOrderBuy);
    if (DojiOperationOrderSell)
      DojiOperationOrderSell = OrderIsOpen(DojiOperationOrderSell);
    return;
  }
  if (!isNewBar(PERIOD_D1))
    DojiInThisDay = 0;
  // if (DojiInThisDay >= dojisPerDay || getDayProfit() >=
  // DojiOperationProfitStop)
  //    return;
  double lotSize = getLotSize();
  if (!lotSize)
    return;
  double haSoft1 = iCustom(NULL, period,
                           "Projects\\Alograg\\Indicators\\AlogragHeikenAshi",
                           Red, Blue, true, 4, 1),
         haSoft2 = iCustom(NULL, period,
                           "Projects\\Alograg\\Indicators\\AlogragHeikenAshi",
                           Red, Blue, true, 4, 2),
         haSoft3 = iCustom(NULL, period,
                           "Projects\\Alograg\\Indicators\\AlogragHeikenAshi",
                           Red, Blue, true, 4, 3),
         haHard1 = iCustom(NULL, period,
                           "Projects\\Alograg\\Indicators\\AlogragHeikenAshi",
                           Red, Blue, false, 4, 1),
         haHard2 = iCustom(NULL, period,
                           "Projects\\Alograg\\Indicators\\AlogragHeikenAshi",
                           Red, Blue, false, 4, 2),
         haHard3 = iCustom(NULL, period,
                           "Projects\\Alograg\\Indicators\\AlogragHeikenAshi",
                           Red, Blue, false, 4, 3);
  bool canOperate =
           haSoft1 == haHard1 && haSoft2 != haHard2 && haSoft3 == haHard3,
       isBuy = haHard3 > 0;
  if (!canOperate)
    return;
  if (!DojiOperationOrderBuy && isBuy) {
    DojiOperationOrderBuy =
        OrderSend(Symbol(), OP_BUY, 0.01, Ask, 0, 0, 0, DojiOperationComment,
                  MagicNumber, 0, Blue);
    DojiInThisDay++;
  }
  if (!DojiOperationOrderSell && !isBuy) {
    DojiOperationOrderSell =
        OrderSend(Symbol(), OP_SELL, 0.01, Bid, 0, 0, 0, DojiOperationComment,
                  MagicNumber, 0, Red);
    DojiInThisDay++;
  }
}
bool dogi(double o, double c) { return o == c; }
bool nearDoji(double o, double c, double h, double l) {
  return MathAbs(o - c) <= ((h - l) * 0.1);
}
/*
Candlestick Formula:
Doji
(O = C )
Doji Yesterday
(O1 = C1 )
Doji and Near Doji
(ABS(O – C ) <= ((H – L ) * 0.1))
Bullish Engulfing
((O1 > C1) AND (C > O) AND (C >= O1) AND (C1 >= O) AND ((C – O) > (O1 – C1)))
Bearish Engulfing
((C1 > O1) AND (O > C) AND (O >= C1) AND (O1 >= C) AND ((O – C) > (C1 – O1)))
Hammer
(((H-L)>3*(O-C)AND((C-L)/(.001+H-L)>0.6)AND((O-L)/(.001+H-L)>0.6)))
Hanging Man
(((H – L) > 4 * (O – C)) AND ((C – L) / (.001 + H – L) >= 0.75) AND ((O – L) /
(.001 + H – L) >= .075)))
Piercing Line
((C1 < O1) AND (((O1 + C1) / 2) < C) AND (O < C) AND (O < C1) AND (C < O1) AND
((C – O) / (.001 + (H – L)) > 0.6))
Dark Cloud
((C1 > O1) AND (((C1 + O1) / 2) > C) AND (O > C) AND (O > C1) AND (C > O1) AND
((O – C) / (.001 + (H – L)) > .6))
Bullish Harami
((O1 > C1) AND (C > O) AND (C <= O1) AND (C1 <= O) AND ((C – O) < (O1 – C1)))
Bearish Harami
((C1 > O1) AND (O > C) AND (O <= C1) AND (O1 <= C) AND ((O – C) < (C1 – O1)))
Morning Star
((O2>C2)AND((O2-C2)/(.001+H2-L2)>.6)AND(C2>O1)AND(O1>C1)AND((H1-L1)>(3*(C1-O1)))AND(C>O)AND(O>O1))
Evening Star
((C2 > O2) AND ((C2 – O2) / (.001 + H2 – L2) > .6) AND (C2 < O1) AND (C1 > O1)
AND ((H1 – L1) > (3 * (C1 – O1))) AND (O > C) AND (O < O1))
Bullish Kicker
(O1 > C1) AND (O >= O1) AND (C > O)
Bearish Kicker
(O1 < C1) AND (O <= O1) AND (C <= O)
Shooting Star
(((H – L) > 4 * (O – C)) AND ((H – C) / (.001 + H – L) >= 0.75) AND ((H – O) /
(.001 + H – L) >= 0.75)))
Inverted Hammer
(((H – L) > 3 * (O – C)) AND ((H – C) / (.001 + H – L) > 0.6) AND ((H – O) /
(.001 + H – L) > 0.6)))
J-Hook Pattern
((L1 = MINL4) OR (L2 = MINL4) OR (L3 = MINL4) ) AND
( (MAXC3 < MAXC4.3)) AND
( (H3 = MAXH15.4) OR (H4 = MAXH15.4) OR (H5 = MAXH15.4) OR (H6 = MAXH15.4) OR
(H7 = MAXH15.4) ) AND (((MAXH4.3 – MINL4) / (MAXH4.3 – MINL21.3) > .23) AND
((MAXH4.3 – MINL4) / (MAXH4.3 – MINL21.3) < .62) ) AND
((AVGH3.5) > (AVGH3.8 ) AND (AVGH3.8 ) > (AVGH3.13) AND (AVGH3.13) > (AVGH3.18
))
Belt Hold
C > O
AND L = MINL10
AND ((C – O) / (H – L)) > .5
AND ((C1 – L) / (H – L) > .6)
AND (H – L) > .2 * ((H5 – L5) + (H4 – L4) + (H3 – L3) + (H2 – L2) + (H1 – L1))
AND H > L1 AND C < H1
Belt Hold
(C > O) AND (H > L1) AND (L = MINL10) AND
((C – O) / (H – L) > .5) AND
(ABS(C1 – L) / (H – L) > .5) AND
( (H – L) > (((H – L + ABS(C1 – H) + ABS(C1 – L)) / 2 + (H1 – L1 + ABS(C2 – H1)
+ ABS(C2 – L1)) / 2 + (H2 – L2 + ABS(C3 – H2) + ABS(C3 – L2)) / 2 + (H3 – L3 +
ABS(C4 – H3) + ABS(C4 – L3)) / 2 + (H4 – L4 + ABS(C5 – H4) + ABS(C5 – L4)) / 2)
/ 5))
Three Outside Down Pattern
((C2>O2)AND(O1>C1)AND(O1>=C2)AND(O2>=C1)AND((O1-C1)>(C2-O2))AND(O>C) AND (C
Three Outside Up Pattern
((O2>C2)AND(C1>O1)AND(C1>=O2)AND(C2>=O1)AND((C1-O1)>(O2-C2))AND (C>O)AND (C>C1))
Three Inside Up Pattern
((O2>C2)AND(C1>O1)AND(C1<=O2)AND(C2<=O1)AND((C1-O1)<(O2-C2))AND(C>O)AND(C>C1)AND(O>O1))
Three Inside Down Pattern
((C2>O2)AND(O1>C1)AND(O1<=C2)AND(O2<=C1)AND
((O1-C1)<(C2-O2))AND(O>C)AND(C>C1)AND (O< P>
Three White Soldiers PCF
(C>O*1.01) AND(C1>O1*1.01) AND(C2>O2*1.01) AND(C>C1) AND
(C1>C2) AND(OO1) AND(O1O2) AND
(((H-C)/(H-L))<.2) AND(((H1-C1)/(H1-L1))<.2)AND(((H2-C2)/(H2-L2))<.2)
Three Black Crows PCF
(O > C * 1.01) AND (O1 > C1 * 1.01) AND (O2 > C2 *
1.01) AND (C < C1) AND (C1 < C2) AND (O > C1) AND (O < O1) AND
(O1 > C2) AND (O1 < O2) AND (((C – L) / (H – L)) < .2) AND
(((C1 – L1) / (H1 – L1)) < .2) AND (((C2 – L2) / (H2 – L2)) < .2)
*/