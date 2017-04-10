//+------------------------------------------------------------------+
//| RHc_BLSH.mq4
//| Copyright © 2005-2006, Lifestatic/Zap, pip_seeker, pip_hunter, autofx
//|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005-2006, Lifestatic/Zap, pip_seeker, pip_hunter, autofx"

/////////////////////////
// External Definitions഻

/////////////////////////

extern double Lots = 1਍††††਍††††਍††††਍††††.0഻
    // Number of lots to use for each trade഻
 please keep at 1਍††਍††਍††਍††.0
extern double LotSize = 1.0഻
 // Change this number to trade more than 1 nano lot਍††††਍††††਍††††਍††††.

extern int SymbolPLFactor = 100഻
 // This value times UseLots gives the SymbolPL dollar profit target
extern int GravyFactor = 5000഻
   // This value times UseLots gives GravyExit (gravy PL vs pair PL profit target)

extern int Slippage = 4഻
     // Slippage
extern int PauseSeconds = 0഻
 // Number of seconds to "sleep" before closing the next winning trade

extern bool StopAfterNoTrades = false഻

// Set to true to give yourself a chance to set Lots
//   to a new value after existing grid closes.
// Set back to false to allow a new grid to be built
//   after adjusting Lots value.

extern bool MM = true഻
 // Leave StopAfterNoTrades false and set MM
                       //   true to enable automatic lot size calculations
                       //   between grids.
                       // MM == False means use Lots for actual lot size.
                       // MM == True means use Money Management logic to calc actual lot size਍††††.

extern double MinLots = 0਍††††਍††††਍††††.01഻
 // Define minimum allowable lot size

extern int MaxLots = 50഻
 // Define maximum allowable lot size਍††††਍††††਍††††਍††††.

extern double LotFactor = 3.0഻


extern int RockBottomEquity = 250഻


extern int MinEqForMinLots = 2000഻
 // Define minimum balance required for trading smallest
                                   //   allowed lot size਍††††਍††††਍††††਍††††.

extern double Threshold = 5.0഻
    // Used for Bombshell mode
extern double ProfitTarget = 4਍††††਍††††਍††††਍††††.0഻
 // Used for Bombshell mode

////////////
// Variables
////////////

double UseLots, BLSHLots, SymbolPL, SymbolPLExit, GravyExit഻

int i഻

int NumBuys, NumSells, BuyNewLevel, SellNewLevel഻

double HighestBuy, LowestBuy, HighestSell, LowestSell഻

bool CloseSwitch, CloseAll, WaitSwitch, ClockSwitch഻

int SetB, SetS, KeepBuys, KeepSells, BalGrid഻

int SkipMPA, EmaClock഻

double PointValue, EmaMin, EmaValue, EMACounter, CurValue഻

int StopBal, StopBalS, StopBalB഻

double FiveEMA_0, FiveEMA_1, TwentyEMA_0, TwentyEMA_1, HundredEMA_0, HundredEMA_1഻

string GravyFlag഻

int valueGravyFlag഻

string GravyProfit഻

double valueGravyProfit഻

string CurrBalance഻

double valueCurrBalance഻


double LastPrice, Anchor഻
 // Used for Bombshell mode

//+------------------------------------------------------------------+
//|              Expert Initialization                               |
//+------------------------------------------------------------------+
int init()
ൻ  
  LastPrice = Bid഻  
  Anchor = (Ask + Bid) / 2഻  
  return (0)഻  
਍਍਍਍ൽ


int start()
ൻ  
  // Specify a name for the global gravy flag variable.
  GravyFlag = AccountNumber() + "_" + Symbol() + "_" + Period() + "_GravyFlag"഻  

  // Define the variable if it doesn't already exist.
  if (!GlobalVariableCheck(GravyFlag))
  ൻ † 
    GlobalVariableSet(GravyFlag, 0)഻ † 
  ਍†਍†਍†਍†ൽ  

  // Get a value਍†††††਍†††††਍†††††਍†††††.
  valueGravyFlag = GlobalVariableGet(GravyFlag)഻  

  // Specify a name for the global variable that tracks gravy profit.
  GravyProfit = AccountNumber() + "_" + Symbol() + "_" + Period() + "_GravyProfit"഻  

  // Define the variable if it doesn't already exist.
  if (!GlobalVariableCheck(GravyProfit))
  ൻ † 
    GlobalVariableSet(GravyProfit, 0)഻ † 
  ਍†਍†਍†਍†ൽ  

  // Get a value਍†††††਍†††††਍†††††਍†††††.
  valueGravyProfit = GlobalVariableGet(GravyProfit)഻  

  // Specify a name for the global variable that tracks the current balance.
  CurrBalance = AccountNumber() + "_" + Symbol() + "_" + Period() + "_CurrBalance"഻  

  // Define the variable if it doesn't already exist.
  if (!GlobalVariableCheck(CurrBalance))
  ൻ † 
    GlobalVariableSet(CurrBalance, 0)഻ † 
  ਍†਍†਍†਍†ൽ  

  // Get a value਍†††††਍†††††਍†††††਍†††††.
  valueCurrBalance = GlobalVariableGet(CurrBalance)഻  

  ///////////////////////////////////////////////////
  // If closing switch is true, close all open trades
  ///////////////////////////////////////////////////

  if (CloseAll)
  ൻ † 
    for (i = OrdersTotal() - 1; i >= 0; i--)
    ൻ †† 
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES)഻ †† 

      if (OrderSymbol() == Symbol())
      ൻ ††† 
        if (OrderType() == OP_BUY && OrderProfit() < 0)
        ൻ †††† 
          Comment("In grid∠਍†††††††††††††††††††††††††"closure mode.∠਍†††††††††††††††††††††††††" Closing a∠਍†††††††††††††††††††††††††"loser...")഻ †††† 
          OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, White)഻ †††† 
        ਍††††਍††††਍††††਍††††ൽ ††† 

        if (OrderType() == OP_SELL && OrderProfit() < 0)
        ൻ †††† 
          Comment("In grid∠਍†††††††††††††††††††††††††"closure mode.∠਍†††††††††††††††††††††††††" Closing a∠਍†††††††††††††††††††††††††"loser...")഻ †††† 
          OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, White)഻ †††† 
        ਍††††਍††††਍††††਍††††ൽ ††† 
      ਍†††਍†††਍†††਍†††ൽ †† 
    ਍††਍††਍††਍††ൽ † 

    for (i = OrdersTotal() - 1; i >= 0; i--)
    ൻ †† 
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES)഻ †† 

      if (OrderSymbol() == Symbol())
      ൻ ††† 
        if (OrderType() == OP_BUY && OrderProfit() >= 0)
        ൻ †††† 
          Sleep(PauseSeconds * 1000)഻ †††† 
          Comment("In grid∠਍†††††††††††††††††††††††††"closure mode.∠਍†††††††††††††††††††††††††" Closing a∠਍†††††††††††††††††††††††††"winner...")഻ †††† 
          OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, White)഻ †††† 
        ਍††††਍††††਍††††਍††††ൽ ††† 

        if (OrderType() == OP_SELL && OrderProfit() >= 0)
        ൻ †††† 
          Sleep(PauseSeconds * 1000)഻ †††† 
          Comment("In grid∠਍†††††††††††††††††††††††††"closure mode.∠਍†††††††††††††††††††††††††" Closing a∠਍†††††††††††††††††††††††††"winner...")഻ †††† 
          OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, White)഻ †††† 
        ਍††††਍††††਍††††਍††††ൽ ††† 
      ਍†††਍†††਍†††਍†††ൽ †† 
    ਍††਍††਍††਍††ൽ † 
  ਍†਍†਍†਍†ൽ  

  /////////////////////////////
  // Initialize Key Variables഻  
  /////////////////////////////

  if (Bid > LastPrice)
    LastPrice = Bid഻  
  if (Ask < LastPrice)
    LastPrice = Ask഻  

  NumBuys = 0഻  
  NumSells = 0഻  
  SymbolPL = 0഻  
  LowestBuy = 1000഻  
  HighestSell = 0഻  
  HighestBuy = 0഻  
  LowestSell = 1000഻  
  BuyNewLevel = 0഻  
  SellNewLevel = 0഻  

  for (i = 0; i < OrdersTotal(); i++)
  ൻ † 
    OrderSelect(i, SELECT_BY_POS, MODE_TRADES)഻ † 

    if (OrderSymbol() == Symbol())
    ൻ †† 
      SymbolPL += OrderProfit()഻ †† 

      if (OrderType() == OP_BUY)
      ൻ ††† 
        NumBuys++഻ ††† 

        if (OrderOpenPrice() < LowestBuy)
          LowestBuy = OrderOpenPrice()഻ ††† 
        if (OrderOpenPrice() > HighestBuy)
          HighestBuy = OrderOpenPrice()഻ ††† 
        if (OrderOpenPrice() == Ask)
          BuyNewLevel = 1഻ ††† 
      ਍†††਍†††਍†††਍†††ൽ †† 

      if (OrderType() == OP_SELL)
      ൻ ††† 
        NumSells++഻ ††† 

        if (OrderOpenPrice() > HighestSell)
          HighestSell = OrderOpenPrice()഻ ††† 
        if (OrderOpenPrice() < LowestSell)
          LowestSell = OrderOpenPrice()഻ ††† 
        if (OrderOpenPrice() == Bid)
          SellNewLevel = 1഻ ††† 
      ਍†††਍†††਍†††਍†††ൽ †† 
    ਍††਍††਍††਍††ൽ † 
  ਍†਍†਍†਍†ൽ  

  for (i = 0; i < OrdersTotal(); i++)
  ൻ † 
    OrderSelect(i, SELECT_BY_POS, MODE_TRADES)഻ † 

    if (OrderSymbol() == Symbol())
    ൻ †† 
      ////////////////////////////////////////////////////////////////////////////////////////////
      // Close Profitable Orders Routine to avoid S.T.U.C.K.  [Stupid Trades Unite to Cause Khaos]
      ////////////////////////////////////////////////////////////////////////////////////////////

      if ((!CloseAll || StopBal == 1) && (OrderProfit() >= PointValue))
      ൻ ††† 
        if (StopBalS == 1 &&
            OrderType() == OP_BUY &&
            LowestBuy <= Bid)
        ൻ †††† 
          Comment("Taking∠਍†††††††††††††††††††††††††"RobinHood_c∠਍†††††††††††††††††††††††††"gravy∠਍†††††††††††††††††††††††††"pips...")഻ †††† 
          OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, Magenta)഻ †††† 
          GlobalVariableSet(GravyFlag, 1)഻ †††† 
          SetS = 1഻ †††† 
          return (0)഻ †††† 
        ਍††††਍††††਍††††਍††††ൽ ††† 

        if (StopBalB == 1 &&
            OrderType() == OP_SELL &&
            HighestSell >= Ask)
        ൻ †††† 
          Comment("Taking∠਍†††††††††††††††††††††††††"RobinHood_c∠਍†††††††††††††††††††††††††"gravy∠਍†††††††††††††††††††††††††"pips...")഻ †††† 
          OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, Yellow)഻ †††† 
          GlobalVariableSet(GravyFlag, 1)഻ †††† 
          SetB = 1഻ †††† 
          return (0)഻ †††† 
        ਍††††਍††††਍††††਍††††ൽ ††† 

        if ((KeepBuys == 1 || KeepSells == 1 || BalGrid == 1) &&
            valueGravyProfit + SymbolPL < GravyExit)
        ൻ †††† 
          ///////////////////////////////
          // Enter S.T.U.C.K. Relief mode
          ///////////////////////////////

          if (KeepBuys == 1 &&
              NumBuys < NumSells &&
              OrderType() == OP_SELL)
          ൻ ††††† 
            Comment("Taking∠਍††††††††††††††††††††††††††††"RobinHood_ഢ †††††††††††††††††††††††††††∠c gravy∠਍††††††††††††††††††††††††††††"pips...")഻ ††††† 
            OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, Yellow)഻ ††††† 
            GlobalVariableSet(GravyFlag, 1)഻ ††††† 
            SetB = 1഻ ††††† 
            return (0)഻ ††††† 
          ਍†††††਍†††††਍†††††਍†††††ൽ †††† 

          if (KeepSells == 1 &&
              NumSells < NumBuys &&
              OrderType() == OP_BUY)
          ൻ ††††† 
            Comment("Taking∠਍††††††††††††††††††††††††††††"RobinHood_ഢ †††††††††††††††††††††††††††∠c gravy∠਍††††††††††††††††††††††††††††"pips...")഻ ††††† 
            OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, Orange)഻ ††††† 
            GlobalVariableSet(GravyFlag, 1)഻ ††††† 
            SetS = 1഻ ††††† 
            return (0)഻ ††††† 
          ਍†††††਍†††††਍†††††਍†††††ൽ †††† 

          if (BalGrid == 1 &&
              NumSells >= 2 &&
              NumBuys >= 2)
          ൻ ††††† 
            if (NumSells - 3 < NumBuys &&
                OrderType() == OP_BUY)
            ൻ †††††† 
              Comment("Taking∠਍†††††††††††††††††††††††††††††††"RobinHoഢ ††††††††††††††††††††††††††††††∠od_c∠਍†††††††††††††††††††††††††††††††"gravy∠਍†††††††††††††††††††††††††††††††"pips..∮਍†††††††††††††††††††††††††††††††"")഻ †††††† 
              OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, Purple)഻ †††††† 
              GlobalVariableSet(GravyFlag, 1)഻ †††††† 
              SetS = 1഻ †††††† 
              return (0)഻ †††††† 
            ਍††††††਍††††††਍††††††਍††††††ൽ ††††† 

            if (NumBuys - 3 < NumSells &&
                OrderType() == OP_SELL)
            ൻ †††††† 
              Comment("Taking∠਍†††††††††††††††††††††††††††††††"RobinHoഢ ††††††††††††††††††††††††††††††∠od_c∠਍†††††††††††††††††††††††††††††††"gravy∠਍†††††††††††††††††††††††††††††††"pips..∮਍†††††††††††††††††††††††††††††††"")഻ †††††† 
              OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, Purple)഻ †††††† 
              GlobalVariableSet(GravyFlag, 1)഻ †††††† 
              SetB = 1഻ †††††† 
              return (0)഻ †††††† 
            ਍††††††਍††††††਍††††††਍††††††ൽ ††††† 
          ਍†††††਍†††††਍†††††਍†††††ൽ †††† 
        ਍††††਍††††਍††††਍††††ൽ ††† 
      ਍†††਍†††਍†††਍†††ൽ †† 
    ਍††਍††਍††਍††ൽ † 
  ਍†਍†਍†਍†ൽ  

  ////////////////////////////////////////////////////////////////////
  // If no trades are open, give trader a chance to change Lots before
  // starting the next grid if StopAfterNoTrades is true, or initialize
  // the closure-related variables and calculate actual lot size to
  // use for trades in upcoming grid.
  ////////////////////////////////////////////////////////////////////

  if (NumBuys + NumSells == 0)
  ൻ † 
    Comment("There are no trades∠਍††††††††††††††††"open.")഻ † 

    if (StopAfterNoTrades)
      return (0)഻ † 

    SkipMPA = 0഻ † 
    EMACounter = 0഻ † 
    StopBal = 0഻ † 
    StopBalB = 0഻ † 
    StopBalS = 0഻ † 
    CloseAll = 0഻ † 
    CloseSwitch = false഻ † 
    WaitSwitch = false഻ † 
    ClockSwitch = false഻ † 
    SetS = 0഻ † 
    SetB = 0഻ † 
    valueGravyProfit = 0഻ † 
  ਍†਍†਍†਍†ൽ  
  else if (NumBuys + NumSells > 0 &&
           AccountBalance() > valueCurrBalance &&
           valueGravyFlag == 1)
  ൻ † 
    valueGravyProfit = valueGravyProfit + (AccountBalance() - valueCurrBalance)഻ † 
    GlobalVariableSet(GravyProfit, valueGravyProfit)഻ † 
    GlobalVariableSet(CurrBalance, AccountBalance())഻ † 
    GlobalVariableSet(GravyFlag, 0)഻ † 
  ਍†਍†਍†਍†ൽ  
  else if (valueGravyFlag == 0)
  ൻ † 
    GlobalVariableSet(CurrBalance, AccountBalance())഻ † 
  ਍†਍†਍†਍†ൽ  

  SymbolPLExit = SymbolPLFactor * UseLots഻  
  GravyExit = GravyFactor * UseLots഻  

  if (MM)
  ൻ † 
    UseLots = MinLots * (AccountEquity() / MinEqForMinLots)഻ † 
    UseLots = StrToDouble(DoubleToStr(UseLots, 2))഻ † 

    if (UseLots < MinLots)
      UseLots = MinLots഻ † 
    if (UseLots > MaxLots)
      UseLots = MaxLots഻ † 
  ਍†਍†਍†਍†ൽ  
  else
    UseLots = (Lots * LotSize) / 100഻  

  BLSHLots = UseLots * LotFactor഻  
  if (BLSHLots > MaxLots)
    BLSHLots = MaxLots഻  
  BLSHLots = StrToDouble(DoubleToStr(BLSHLots, 2))഻  

  ////////////////////////////
  // Print statistics to chart
  ////////////////////////////

  Comment("Symbol's total trades: ", NumBuys + NumSells, ", Buy trades: ", NumBuys, ", Sell trades: ", NumSells,
          "\nCurValue: ", CurValue,
          "\nGridSize: ", (HighestBuy - LowestSell) / Point, " pips",
          "\nBalance: ", AccountBalance(), ", Equity: ", AccountEquity(), ", TotalProfit: ", AccountProfit(),
          "\nHighestBuy: ", HighestBuy, ", LowestBuy: ", LowestBuy,
          "\nHighestSell: ", HighestSell, ", LowestSell: ", LowestSell,
          "\nSymbol PL: ", SymbolPL,
          "\nPL Dollar Target: ", SymbolPLExit,
          "\nGravy Profit: ", valueGravyProfit,
          "\nGravy + SymbolPL: ", valueGravyProfit + SymbolPL,
          "\nGravy Dollar Target: ", GravyExit,
          "\nLastPrice: ", LastPrice,
          "\nAnchor: ", Anchor)഻  

  /////////////////////////
  // Indicator Calculations
  /////////////////////////

  FiveEMA_0 = iMA(NULL, NULL, 5, 0, MODE_EMA, PRICE_CLOSE, 0)഻  
  FiveEMA_1 = iMA(NULL, NULL, 5, 0, MODE_EMA, PRICE_CLOSE, 1)഻  
  TwentyEMA_0 = iMA(NULL, NULL, 20, 0, MODE_EMA, PRICE_CLOSE, 0)഻  
  TwentyEMA_1 = iMA(NULL, NULL, 20, 0, MODE_EMA, PRICE_CLOSE, 1)഻  
  HundredEMA_0 = iMA(NULL, NULL, 100, 0, MODE_EMA, PRICE_CLOSE, 0)഻  
  HundredEMA_1 = iMA(NULL, NULL, 100, 0, MODE_EMA, PRICE_CLOSE, 1)഻  

  ///////////////////////////////////////////////
  // Go back to normal mode if conditions warrant
  ///////////////////////////////////////////////

  if ((StopBalB == 1 && FiveEMA_0 < HundredEMA_0) ||
      (StopBalS == 1 && FiveEMA_0 > HundredEMA_0))
  ൻ † 
    SkipMPA = 0഻ † 
    EMACounter = 0഻ † 
    StopBal = 0഻ † 
    StopBalB = 0഻ † 
    StopBalS = 0഻ † 
    WaitSwitch = false഻ † 
    ClockSwitch = false഻ † 

    if (FiveEMA_0 < HundredEMA_0)
      SetS = 1഻ † 
    if (FiveEMA_0 > HundredEMA_0)
      SetB = 1഻ † 
  ਍†਍†਍†਍†ൽ  

  /////////////////////////////////////
  // Begin Market Positioning Arguments
  /////////////////////////////////////

  if (WaitSwitch && !ClockSwitch)
  ൻ † 
    EmaClock = Hour()഻ † 
    EmaMin = Minute()഻ † 
    ClockSwitch = true഻ † 
  ਍†਍†਍†਍†ൽ  

  if (Hour() - EmaClock >= 1 && Minute() - EmaMin >= 0)
  ൻ † 
    WaitSwitch = false഻ † 
    ClockSwitch = false഻ † 
  ਍†਍†਍†਍†ൽ  

  if (CloseAll == 0 && SkipMPA == 0)
  ൻ † 
    if (FiveEMA_0 > TwentyEMA_0 && FiveEMA_1 > TwentyEMA_1 &&
        FiveEMA_0 > HundredEMA_0 && FiveEMA_1 > HundredEMA_1)
    ൻ †† 
      KeepBuys = 1഻ †† 
      KeepSells = 0഻ †† 
      BalGrid = 0഻ †† 
      PointValue = UseLots * 10഻ †† 
    ਍††਍††਍††਍††ൽ † 

    if (FiveEMA_0 < TwentyEMA_0 && FiveEMA_1 < TwentyEMA_1 &&
        FiveEMA_0 < HundredEMA_0 && FiveEMA_1 < HundredEMA_1)
    ൻ †† 
      KeepSells = 1഻ †† 
      KeepBuys = 0഻ †† 
      BalGrid = 0഻ †† 
      PointValue = UseLots * 10഻ †† 
    ਍††਍††਍††਍††ൽ † 

    if (FiveEMA_0 < TwentyEMA_0 && FiveEMA_1 < TwentyEMA_1 &&
        FiveEMA_0 > HundredEMA_0 && FiveEMA_1 > HundredEMA_1)
    ൻ †† 
      BalGrid = 1഻ †† 
      KeepBuys = 0഻ †† 
      KeepSells = 0഻ †† 
      PointValue = UseLots * 7഻ †† 
    ਍††਍††਍††਍††ൽ † 

    if (FiveEMA_1 > HundredEMA_1 &&
        FiveEMA_1 < (HundredEMA_1 + (15 * Point)) &&
        !WaitSwitch)
    ൻ †† 
      WaitSwitch = true഻ †† 
      EmaValue = FiveEMA_1഻ †† 
      EMACounter++഻ †† 
    ਍††਍††਍††਍††ൽ † 

    if (WaitSwitch)
    ൻ †† 
      if (EmaValue < CurValue)
        CurValue = EmaValue഻ †† 
      else if (CurValue == 0)
        CurValue = EmaValue഻ †† 
    ਍††਍††਍††਍††ൽ † 

    if (FiveEMA_0 > (CurValue + (10 * Point)) &&
        EMACounter >= 4)
    ൻ †† 
      SkipMPA = 1഻ †† 
      StopBal = 1഻ †† 
      StopBalB = 1഻ †† 
      BalGrid = 0഻ †† 
      KeepSells = 0഻ †† 
      KeepBuys = 0഻ †† 
      PointValue = 0഻ †† 
    ਍††਍††਍††਍††ൽ † 

    if (FiveEMA_0 > TwentyEMA_0 && FiveEMA_1 > TwentyEMA_1 &&
        FiveEMA_0 < HundredEMA_0 && FiveEMA_1 < HundredEMA_1)
    ൻ †† 
      BalGrid = 1഻ †† 
      KeepBuys = 0഻ †† 
      KeepSells = 0഻ †† 
      PointValue = UseLots * 7഻ †† 
    ਍††਍††਍††਍††ൽ † 

    if (FiveEMA_1 < HundredEMA_1 &&
        FiveEMA_1 > (HundredEMA_1 - (15 * Point)) &&
        !WaitSwitch)
    ൻ †† 
      WaitSwitch = true഻ †† 
      EmaValue = FiveEMA_1഻ †† 
      EMACounter++഻ †† 
    ਍††਍††਍††਍††ൽ † 

    if (WaitSwitch && EmaValue > CurValue)
      CurValue = EmaValue഻ † 

    if (FiveEMA_0 < (CurValue - (10 * Point)) &&
        EMACounter >= 4)
    ൻ †† 
      SkipMPA = 1഻ †† 
      StopBal = 1഻ †† 
      StopBalS = 1഻ †† 
      BalGrid = 0഻ †† 
      KeepSells = 0഻ †† 
      KeepBuys = 0഻ †† 
      PointValue = 0഻ †† 
    ਍††਍††਍††਍††ൽ † 
  ਍†਍†਍†਍†ൽ  

  //////////////////////////////////////////////////
  // If Profit is positive, close all open positions
  //////////////////////////////////////////////////

  if (!CloseSwitch &&
      ((valueGravyProfit == 0 && SymbolPL > SymbolPLExit) ||
       valueGravyProfit + SymbolPL > GravyExit))
  ൻ † 
    KeepBuys = 0഻ † 
    KeepSells = 0഻ † 
    BalGrid = 0഻ † 
    SetB = 0഻ † 
    SetS = 0഻ † 
    CloseAll = true഻ † 
    CloseSwitch = true഻ † 
  ਍†਍†਍†਍†ൽ  

  if (AccountEquity() < RockBottomEquity)
    return (0)഻  

  /////////////////////////////////////////////////
  // If closing switch set to 0, we want new orders
  /////////////////////////////////////////////////

  if (!CloseAll)
  ൻ † 
    ////////////////////
    // Open First Trades
    ////////////////////

    if (NumBuys >= 0 || NumSells >= 0)
    ൻ †† 
      if (NumBuys == 0)
      ൻ ††† 
        Comment("Opening the∠਍††††††††††††††††††††††"first buy∠਍††††††††††††††††††††††"trade...")഻ ††† 
        GlobalVariableSet(GravyProfit, 0)഻ ††† 
        GlobalVariableSet(CurrBalance, AccountBalance())഻ ††† 
        OrderSend(Symbol(), OP_BUY, UseLots, Ask, Slippage, 0, 0, "RHc_BLSH", 0, 0, Blue)഻ ††† 
        return (0)഻ ††† 
      ਍†††਍†††਍†††਍†††ൽ †† 

      if (NumSells == 0)
      ൻ ††† 
        Comment("Opening the∠਍††††††††††††††††††††††"first sell∠਍††††††††††††††††††††††"trade...")഻ ††† 
        OrderSend(Symbol(), OP_SELL, UseLots, Bid, Slippage, 0, 0, "RHc_BLSH", 0, 0, Red)഻ ††† 
        return (0)഻ ††† 
      ਍†††਍†††਍†††਍†††ൽ †† 

      //////////////////////////////
      // Open additional grid trades
      //////////////////////////////

      if (SetB == 1 &&
          Ask > HighestSell &&
          BuyNewLevel == 0 &&
          SymbolPL < 0)
      ൻ ††† 
        Comment("Adding a∠਍††††††††††††††††††††††"RobinHood_c buy∠਍††††††††††††††††††††††"trade...")഻ ††† 
        OrderSend(Symbol(), OP_BUY, UseLots, Ask, Slippage, 0, 0, "RHc_BLSH", 0, 0, Blue)഻ ††† 
        SetB = 0഻ ††† 
        return (0)഻ ††† 
      ਍†††਍†††਍†††਍†††ൽ †† 

      if (SetS == 1 &&
          Bid < LowestBuy &&
          SellNewLevel == 0 &&
          SymbolPL < 0)
      ൻ ††† 
        Comment("Adding a∠਍††††††††††††††††††††††"RobinHood_c sell∠਍††††††††††††††††††††††"trade...")഻ ††† 
        OrderSend(Symbol(), OP_SELL, UseLots, Bid, Slippage, 0, 0, "RHc_BLSH", 0, 0, Red)഻ ††† 
        SetS = 0഻ ††† 
        return (0)഻ ††† 
      ਍†††਍†††਍†††਍†††ൽ †† 

      if (Ask > LowestBuy &&
          BuyNewLevel == 0 &&
          SymbolPL < 0)
      ൻ ††† 
        Comment("Adding a∠਍††††††††††††††††††††††"RobinHood_c buy∠਍††††††††††††††††††††††"trade...")഻ ††† 
        OrderSend(Symbol(), OP_BUY, UseLots, Ask, Slippage, 0, 0, "RHc_BLSH", 0, 0, Blue)഻ ††† 
        return (0)഻ ††† 
      ਍†††਍†††਍†††਍†††ൽ †† 

      if (Bid < HighestSell &&
          SellNewLevel == 0 &&
          SymbolPL < 0)
      ൻ ††† 
        Comment("Adding a∠਍††††††††††††††††††††††"RobinHood_c sell∠਍††††††††††††††††††††††"trade...")഻ ††† 
        OrderSend(Symbol(), OP_SELL, UseLots, Bid, Slippage, 0, 0, "RHc_BLSH", 0, 0, Red)഻ ††† 
        return (0)഻ ††† 
      ਍†††਍†††਍†††਍†††ൽ †† 

      //+------------------------------------------------------------------+
      //|                      Manage Our Open Bombshell Buy Orders        |
      //+------------------------------------------------------------------+

      for (i = 0; i < OrdersTotal(); i++)
      ൻ ††† 
        OrderSelect(i, SELECT_BY_POS, MODE_TRADES)഻ ††† 

        if (OrderLots() > UseLots * 2.0 &&
            OrderSymbol() == Symbol() &&
            OrderType() == OP_BUY &&
            Bid - OrderOpenPrice() >= ProfitTarget * Point)
        ൻ †††† 
          Comment("Taking∠਍†††††††††††††††††††††††††"Bombshell∠਍†††††††††††††††††††††††††"gravy∠਍†††††††††††††††††††††††††"pips...")഻ †††† 
          OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, LightBlue)഻ †††† 
          GlobalVariableSet(GravyFlag, 1)഻ †††† 
          Print("Errors Closing *in profit* BUY order = ", GetLastError())഻ †††† 
          return (0)഻ †††† 
        ਍††††਍††††਍††††਍††††ൽ ††† 
      ਍†††਍†††਍†††਍†††ൽ †† 

      //+------------------------------------------------------------------+
      //|                      Manage Our Open Bombshell Sell Orders       |
      //+------------------------------------------------------------------+

      for (i = 0; i < OrdersTotal(); i++)
      ൻ ††† 
        OrderSelect(i, SELECT_BY_POS, MODE_TRADES)഻ ††† 

        if (OrderLots() > UseLots * 2.0 &&
            OrderSymbol() == Symbol() &&
            OrderType() == OP_SELL &&
            OrderOpenPrice() - Ask >= ProfitTarget * Point)
        ൻ †††† 
          Comment("Taking∠਍†††††††††††††††††††††††††"Bombshell∠਍†††††††††††††††††††††††††"gravy∠਍†††††††††††††††††††††††††"pips...")഻ †††† 
          OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, LightPink)഻ †††† 
          GlobalVariableSet(GravyFlag, 1)഻ †††† 
          Print("Errors Closing *in profit* SELL order = ", GetLastError())഻ †††† 
          return (0)഻ †††† 
        ਍††††਍††††਍††††਍††††ൽ ††† 
      ਍†††਍†††਍†††਍†††ൽ †† 

      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+

      if (LastPrice >= Anchor + Threshold * Point)
      ൻ ††† 
        Anchor = LastPrice഻ ††† 

        if (Bid < LowestBuy)
        ൻ †††† 
          Comment("Adding a∠਍†††††††††††††††††††††††††"Bombshell∠਍†††††††††††††††††††††††††"sell∠਍†††††††††††††††††††††††††"trade...")഻ †††† 
          OrderSend(Symbol(), OP_SELL, BLSHLots, Bid, Slippage, 0, 0, "RHc_BLSH", 0, 0, Red)഻ †††† 
          Print("Errors opening SELL order = ", GetLastError())഻ †††† 
          return (0)഻ †††† 
        ਍††††਍††††਍††††਍††††ൽ ††† 
      ਍†††਍†††਍†††਍†††ൽ †† 

      //+------------------------------------------------------------------+
      //|            Price Moving Down - Open Bombshell Long               |
      //+------------------------------------------------------------------+

      if (LastPrice <= Anchor - Threshold * Point)
      ൻ ††† 
        Anchor = LastPrice഻ ††† 

        if (Ask > HighestSell)
        ൻ †††† 
          Comment("Adding a∠਍†††††††††††††††††††††††††"Bombshell buy∠਍†††††††††††††††††††††††††"trade...")഻ †††† 
          OrderSend(Symbol(), OP_BUY, BLSHLots, Ask, Slippage, 0, 0, "RHc_BLSH", 0, 0, Blue)഻ †††† 
          Print("Errors opening BUY order = ", GetLastError())഻ †††† 
          return (0)഻ †††† 
        ਍††††਍††††਍††††਍††††ൽ ††† 
      ਍†††਍†††਍†††਍†††ൽ †† 
    ਍††਍††਍††਍††ൽ † 
  ਍†਍†਍†਍†ൽ  
਍਍਍਍ൽ

