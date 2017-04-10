//+------------------------------------------------------------------+
//|                                                   Gap_Trader.mq4 |
//|                                            http://www.doshur.com |
//+------------------------------------------------------------------+
#property copyright "doshur"
#property link "http://www.doshur.com"
/*
El Expert Advisor Gap Trading coge los precios de cierre del Viernes y
de apertura del Lunes para generar señales. Dado que sólo trabaja con
esos valores, este experto genera muy pocas operaciones.

Este Expert Advisor está diseñado para identificar y operar con huecos
en el mercado, siempre y cuando se defina un número mínimo de pips para
ello. A pesar de que el parámetro por defecto es de 10 pips,
recomendaría en primer lugar cambiar ese valor a un mínimo de 15 pips,
ya que debe considerarse la horquilla también, algo que el Expert no
está considerando. Utiliza el ATR para definir el stop de pérdidas,
una elección bastante adecuada.

Sin embargo, los huecos no se producen muy a menudo, por lo que podría
ser sólo una estrategia de negociación secundaria, para obtener algunos
pips adicionales.

Hay algunas cosas sobre los huecos que el experto no puede tener en cuenta,
así que recuerde este consejo, si está dispuesto a utilizar esta EA:

Los huecos se producen por lo general en las aperturas del Domingo, o
durante la publicación de importantes datos fundamentales, provocando
una fuerte aceleración de los precios. Con respecto a las aperturas de
los Domingos, tenga en cuenta que si el mercado no cierra ese hueco en
las primeras 3 horas de negociación, las posibilidades de que se cierre
rápidamente se reducen mucho, y lo más probable es que nos salte el
stop de pérdidas con este experto. Cuando se trata de datos fundamentales,
los Majors tienden a cerrar el hueco rápidamente, por lo que requieren
menos atención por parte del trader.

No olvide que diferentes pares tienen diferentes comportamientos ante
los huecos: mientras que USD/CHF tiende a cerrarlos todos, el USD/CAD
tiende a ser el menos fiable cuando se trata de cerrar huecos;
se puede usar también con EUR/USD o AUD/USD, pero debemos evitar los
huecos en USD/CAD y GBP/USD.
*/
extern double GapRange = 10;
extern double SL_Factor = 2;
extern double TP_Factor = 1;
extern double MM_Risk = 2;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init() {
  //----

  //----
  return (0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit() {
  //----

  //----
  return (0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start() {
  //---- ONE TRADE PER BAR

  static bool ToTrade;

  if (NewBar() == true) {
    if (COT(1, 101187) == 0 && COT(2, 201187) == 0)
      ToTrade = true;
  }

  //---- GAP

  bool GAP;

  double CurrOpen = iOpen(NULL, 0, 0);
  double PrevClose = iClose(NULL, 0, 1);
  double Range = MathAbs(PrevClose - CurrOpen);

  if (Range >= GapRange * Point * 10)
    GAP = true;

  //---- TP / SL

  double ATR = iATR(NULL, 0, 13, 1);
  double Spread = MarketInfo(Symbol(), MODE_SPREAD) * Point;

  double TakeProfit = ATR * TP_Factor;
  double StopLoss = (ATR * SL_Factor) + Spread;

  //---- TRADE

  int Ticket;

  if (ToTrade == true && GAP == true) {
    if (CurrOpen < PrevClose) {
      Ticket = OrderSend(Symbol(), OP_BUY, LotSize(MM_Risk, StopLoss), Ask, 3,
                         Ask - StopLoss, Ask + TakeProfit, "Gap_Trader.B",
                         101187, 0, Blue);

      if (Ticket < 0) {
        Print("Error in OrderSend : ", GetLastError());
      } else {
        ToTrade = false;
      }
    }

    if (CurrOpen > PrevClose) {
      Ticket = OrderSend(Symbol(), OP_SELL, LotSize(MM_Risk, StopLoss), Bid, 3,
                         Bid + StopLoss, Bid - TakeProfit, "Gap_Trader.S",
                         201187, 0, Red);

      if (Ticket < 0) {
        Print("Error in OrderSend : ", GetLastError());
      } else {
        ToTrade = false;
      }
    }
  }

  //----
  return (0);
}
//+------------------------------------------------------------------+
//+ Check Open Trades                                                |
//+------------------------------------------------------------------+
int COT(int BS, int MN) {
  int Buys = 0, Sells = 0;

  for (int cnt_COT = 0; cnt_COT < OrdersTotal(); cnt_COT++) {
    OrderSelect(cnt_COT, SELECT_BY_POS, MODE_TRADES);

    if (OrderSymbol() == Symbol() && OrderMagicNumber() == MN &&
        OrderType() == OP_BUY)
      Buys++;
    if (OrderSymbol() == Symbol() && OrderMagicNumber() == MN &&
        OrderType() == OP_SELL)
      Sells++;
  }

  if (BS == 1)
    return (Buys);
  if (BS == 2)
    return (Sells);
}
//+------------------------------------------------------------------+
//| LotSize                                                          |
//+------------------------------------------------------------------+
double LotSize(double Risk, double SL) {
  double MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);
  double MinLot = MarketInfo(Symbol(), MODE_MINLOT);

  double StopLoss = SL / Point / 10;
  double Size = Risk / 100 * AccountBalance() / 10 / StopLoss;

  if (Size < MinLot)
    Size = MinLot;
  if (Size > MaxLot)
    Size = MaxLot;

  return (NormalizeDouble(Size, 2));
}
//+------------------------------------------------------------------+
//| New Bar                                                          |
//+------------------------------------------------------------------+
bool NewBar() {
  static datetime PrevBar;

  if (PrevBar < Time[0]) {
    PrevBar = Time[0];
    return (true);
  } else {
    return (false);
  }
}