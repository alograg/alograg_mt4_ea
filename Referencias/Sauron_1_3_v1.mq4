//+------------------------------------------------------------------+
//|                                                       Sauron.mq4 |
//|                                     Simplified open release: 1.3 |
//|                  Copyright © 2008, Giampiero.Raschetti©gmail.com |
//|                                                    skype: giaras |
//+------------------------------------------------------------------+
#property copyright "Copyright giaras©2008"
#property link "http://www.fxtrade.it"

//---- INPUT PARAMETERS

// Trailing Stop Engine
extern int MaxStopLoss = 105;
extern int MinTakeProfit = 12;

//---- MONEY MANAGEMENT MODULE
extern double lots = 1;

// TIME FILTER TIMING PARAMETERS
extern string F_Filer1 = "====== Filter 1 Time based filter =============";
bool UseHourTrade = true;
extern int FromHourTrade = 21; // start trading on this hour
int ToHourTrade = 18;          // end trading on this hour
extern bool UseTimeBasedStopLoss = false;
extern int TradeHoldingPeriod = 23; // Maximum holding period without profit

extern string C_Signal1 = "====== Signal 1 MA Direction =================";
extern int S1_MA_FAST = 1;

extern string C_Signal2 = "====== Signal 2 OSMA slope ===========";
extern int S2_OSMAFast = 1;
extern int S2_OSMASlow = 22;
extern double S2_OSMASignal = 9;

//---- GLOBAL VARIABLES
int MagicNumber = 666; // Use 3 different magic number for 3 different lot size
static int prevtime = 0;
int SignalCount;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init() {
  Print("Initiating... Account info:");
  Print("Date Time:", TimeToStr(TimeCurrent(), TIME_DATE | TIME_SECONDS));
  //----
  return (0);
}

//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit() {
  //----
  return (0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start() {
  double RefPrice;
  int i;
  int spread = 3;

  if (Time[0] == prevtime)
    return (0);
  prevtime = Time[0];

  ToHourTrade = FromHourTrade;
  // FOR TESTING PARPOUSE ONLY
  if (ToHourTrade < FromHourTrade)
    return (0);

  //----
  if (IsTradeAllowed()) {
    RefreshRates();
    spread = MarketInfo(Symbol(), MODE_SPREAD);
  } else {
    prevtime = Time[1];
    return (0);
  }
  int ticket = -1;

  SignalCount = Analyzer();
  TrailingStopEngine();
  // check for opened position
  int total = OrdersTotal();
  //----
  for (i = 0; i < total; i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
      break;
    bool OrderFound = false;
    // check for symbol & magic number
    if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
      OrderFound = true;
      int k = 0;
      while (k < TradeHoldingPeriod) // Count how many hours open
      {
        if (iTime(NULL, PERIOD_H1, k) > OrderOpenTime())
          k++;
        else
          break;
      }
      // long position is opened
      if (OrderType() == OP_BUY) {
        // check profit and set trailing stops

        if (UseTimeBasedStopLoss && k >= TradeHoldingPeriod &&
            OrderProfit() < 0) {
          if (SignalCount < 0)
            OrderClose(OrderTicket(), OrderLots(), Bid, 3,
                       Violet); // close position!!
          return (0);
        }
      } else // PROCESS SELL ORDER
      {
        // check profit and set trailing stops

        if (UseTimeBasedStopLoss && k >= TradeHoldingPeriod &&
            OrderProfit() < 0) {
          if (SignalCount > 0)
            OrderClose(OrderTicket(), OrderLots(), Ask, 3,
                       Violet); // close position!!
          return (0);
        }
      }

      // exit
      return (0);
    }
  }

  if (OrderFound)
    return (0);

  if (BlockTradingFilter1())
    return (0);

  if (SignalCount > 0) { // long
    ticket =
        OrderSend(Symbol(), OP_BUY, lots, Ask, 3, Ask - MaxStopLoss * Point,
                  Ask + MinTakeProfit * Point, "GR", MagicNumber, 0, Blue);
    //----
    if (ticket < 0) {
      Sleep(30000);
      prevtime = Time[1];
    }
  } else if (SignalCount < 0) { // short
    ticket =
        OrderSend(Symbol(), OP_SELL, lots, Bid, 3, Bid + MaxStopLoss * Point,
                  Bid - MinTakeProfit * Point, "GR", MagicNumber, 0, Red);
    if (ticket < 0) {
      Sleep(30000);
      prevtime = Time[1];
    }
  }
  //--- exit
  return (0);
}

//+------------------------------------------------------------------+
//| TRAILING STOP ENGINE MODULE
//+------------------------------------------------------------------+
int TrailingStopEngine() {
  //   MinTakeProfit=MaxStopLoss*2;
  return (0);
}

//+------------------------------------------------------------------+
//| Long Term Price Analyzer
//+------------------------------------------------------------------+
int Analyzer() {
  int signalCount = 0;
  signalCount += EntrySignal1();
  signalCount += EntrySignal2();
  return (signalCount);
}

//+------------------------------------------------------------------+
//| FILTER BLOCK MODULES
//+------------------------------------------------------------------+
bool BlockTradingFilter1() { // Original code Contributed by Wackena
  bool BlockTrade = false;   // trade by default
  if (UseHourTrade) {
    if (!(Hour() >= FromHourTrade && Hour() <= ToHourTrade && Minute() <= 3)) {
      //  Comment("Non-Trading Hours!");
      BlockTrade = true;
    }
  }
  return (BlockTrade);
}

//+------------------------------------------------------------------+
//| ENTRY SIGNALS BLOCK MODULES
//+------------------------------------------------------------------+
int EntrySignal1() { // Long term SMA trend detect
  int i, Signal;

  int LongTrend = 0;
  for (i = 0; i < 3; i++) {
    if (iMA(Symbol(), PERIOD_H4, S1_MA_FAST, 0, MODE_LWMA, PRICE_TYPICAL, i) >
        iMA(Symbol(), PERIOD_H4, S1_MA_FAST, 0, MODE_LWMA, PRICE_TYPICAL,
            i + 1))
      LongTrend++;
    else
      LongTrend--;
  }
  if (LongTrend < 0)
    Signal = -1;
  else
    Signal = 1;
  return (Signal);
}

int EntrySignal2() { // Daily MACD
  int Signal;

  if (iMACD(NULL, PERIOD_D1, S2_OSMAFast, S2_OSMASlow, S2_OSMASignal,
            PRICE_WEIGHTED, MODE_MAIN,
            0) > iMACD(NULL, PERIOD_D1, S2_OSMAFast, S2_OSMASlow, S2_OSMASignal,
                       PRICE_WEIGHTED, MODE_MAIN, 1))
    Signal = 1;
  else
    Signal = -1;
  return (Signal);
}
