//+------------------------------------------------------------------+
//| RHc_BLSH.mq4
//| Copyright © 2005-2006, Lifestatic/Zap, pip_seeker, pip_hunter, autofx
//| 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005-2006, Lifestatic/Zap, pip_seeker, pip_hunter, autofx"

/////////////////////////
// External Definitions;
/////////////////////////

extern double Lots              = 1.0;  // Number of lots to use for each trade; please keep at 1.0
extern double LotSize           = 1.0;  // Change this number to trade more than 1 nano lot.

extern int    SymbolPLFactor    = 100;  // This value times UseLots gives the SymbolPL dollar profit target 
extern int    GravyFactor       = 5000; // This value times UseLots gives GravyExit (gravy PL vs pair PL profit target)

extern int    Slippage          = 4;    // Slippage
extern int    PauseSeconds      = 0;    // Number of seconds to "sleep" before closing the next winning trade

                               
extern bool   StopAfterNoTrades = false;
                                        // Set to true to give yourself a chance to set Lots
                                        //   to a new value after existing grid closes.
                                        // Set back to false to allow a new grid to be built
                                        //   after adjusting Lots value.
                                      
extern bool   MM               = true;  // Leave StopAfterNoTrades false and set MM
                                        //   true to enable automatic lot size calculations 
                                        //   between grids.
                                        // MM == False means use Lots for actual lot size.
                                        // MM == True means use Money Management logic to calc actual lot size.
                               
extern double MinLots          = 0.01;  // Define minimum allowable lot size

extern int    MaxLots          =   50;  // Define maximum allowable lot size.

extern double LotFactor        =  3.0;

extern int    RockBottomEquity =  250;

extern int    MinEqForMinLots  = 2000;  // Define minimum balance required for trading smallest
                                        //   allowed lot size.

extern double Threshold        =   5.0; // Used for Bombshell mode
extern double ProfitTarget     =   4.0; // Used for Bombshell mode

////////////
// Variables
////////////

double UseLots, BLSHLots, SymbolPL, SymbolPLExit, GravyExit;
int    i;
int    NumBuys, NumSells, BuyNewLevel, SellNewLevel;
double HighestBuy, LowestBuy, HighestSell, LowestSell;
bool   CloseSwitch, CloseAll, WaitSwitch, ClockSwitch;
int    SetB, SetS, KeepBuys, KeepSells, BalGrid;
int    SkipMPA, EmaClock;
double PointValue, EmaMin, EmaValue, EMACounter, CurValue;
int    StopBal, StopBalS, StopBalB;
double FiveEMA_0, FiveEMA_1, TwentyEMA_0, TwentyEMA_1, HundredEMA_0, HundredEMA_1;
string GravyFlag;
int    valueGravyFlag;
string GravyProfit;
double valueGravyProfit;
string CurrBalance;
double valueCurrBalance;

double LastPrice, Anchor; // Used for Bombshell mode

//+------------------------------------------------------------------+
//|              Expert Initialization                               |
//+------------------------------------------------------------------+
int init()
{
  LastPrice = Bid;
  Anchor = (Ask+Bid)/2;
  return(0);
}

int start()
{
  // Specify a name for the global gravy flag variable.
  GravyFlag = AccountNumber()+"_"+Symbol()+"_"+Period()+"_GravyFlag";
  
  // Define the variable if it doesn't already exist.
  if (!GlobalVariableCheck(GravyFlag)) { GlobalVariableSet(GravyFlag, 0); }

  // Get a value.
  valueGravyFlag= GlobalVariableGet(GravyFlag);


  // Specify a name for the global variable that tracks gravy profit.
  GravyProfit = AccountNumber()+"_"+Symbol()+"_"+Period()+"_GravyProfit";
  
  // Define the variable if it doesn't already exist.
  if (!GlobalVariableCheck(GravyProfit)) { GlobalVariableSet(GravyProfit, 0); }

  // Get a value.
  valueGravyProfit = GlobalVariableGet(GravyProfit);


  // Specify a name for the global variable that tracks the current balance.
  CurrBalance = AccountNumber()+"_"+Symbol()+"_"+Period()+"_CurrBalance";
  
  // Define the variable if it doesn't already exist.
  if (!GlobalVariableCheck(CurrBalance)) { GlobalVariableSet(CurrBalance, 0); }

  // Get a value.
  valueCurrBalance = GlobalVariableGet(CurrBalance);


  ///////////////////////////////////////////////////
  // If closing switch is true, close all open trades
  ///////////////////////////////////////////////////

  if (CloseAll)
  {
    for(i = OrdersTotal()-1; i >=0; i--)
    {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if (OrderSymbol() == Symbol())
      {
        if (OrderType() == OP_BUY && OrderProfit() < 0) 
        {
          Comment("In grid closure mode.  Closing a loser...");
	       OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,White);
        }    

        if (OrderType() == OP_SELL && OrderProfit() < 0)
        {
          Comment("In grid closure mode.  Closing a loser...");
          OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,White);
        }
      }
    }

    for(i = OrdersTotal()-1; i >=0; i--)
    {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if (OrderSymbol() == Symbol())
      {
        if (OrderType() == OP_BUY && OrderProfit() >= 0) 
        {
          Sleep(PauseSeconds*1000);
          Comment("In grid closure mode.  Closing a winner...");
	       OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,White);
        }    

        if (OrderType() == OP_SELL && OrderProfit() >= 0)
        {
          Sleep(PauseSeconds*1000);
          Comment("In grid closure mode.  Closing a winner...");
          OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,White);
        }
      }
    }
  }

  /////////////////////////////
  // Initialize Key Variables;
  /////////////////////////////

  if (Bid > LastPrice) LastPrice = Bid;
  if (Ask < LastPrice) LastPrice = Ask;
  
  NumBuys      =    0;
  NumSells     =    0;
  SymbolPL     =    0;
  LowestBuy    = 1000;
  HighestSell  =    0;
  HighestBuy   =    0;
  LowestSell   = 1000;
  BuyNewLevel  =    0;
  SellNewLevel =    0;

  for(i = 0; i < OrdersTotal(); i++)
  {
    OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

    if (OrderSymbol() == Symbol()) 
    {
      SymbolPL += OrderProfit();

      if (OrderType() == OP_BUY) 
      {
        NumBuys++;
        
        if (OrderOpenPrice() < LowestBuy)   LowestBuy   = OrderOpenPrice();
        if (OrderOpenPrice() > HighestBuy)  HighestBuy  = OrderOpenPrice();
        if (OrderOpenPrice() == Ask)        BuyNewLevel = 1;
      }

      if (OrderType() == OP_SELL)
      {
        NumSells++;

        if (OrderOpenPrice() > HighestSell)  HighestSell  = OrderOpenPrice();
        if (OrderOpenPrice() < LowestSell)   LowestSell   = OrderOpenPrice();
        if (OrderOpenPrice() == Bid)         SellNewLevel = 1;
      }
    }
  }

  for(i = 0; i < OrdersTotal(); i++)
  {
    OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

    if (OrderSymbol() == Symbol())
    {
      ////////////////////////////////////////////////////////////////////////////////////////////
      // Close Profitable Orders Routine to avoid S.T.U.C.K.  [Stupid Trades Unite to Cause Khaos]
      ////////////////////////////////////////////////////////////////////////////////////////////

      if ((!CloseAll || StopBal == 1) && (OrderProfit() >= PointValue))
      {
        if (StopBalS == 1         &&
            OrderType() == OP_BUY &&
            LowestBuy <= Bid)         
        {
          Comment("Taking RobinHood_c gravy pips...");
          OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Magenta);
          GlobalVariableSet(GravyFlag, 1);
          SetS = 1;
          return(0);
        }

        if (StopBalB == 1          &&
            OrderType() == OP_SELL &&
            HighestSell >= Ask)         
        {
          Comment("Taking RobinHood_c gravy pips...");
          OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Yellow);
          GlobalVariableSet(GravyFlag, 1);
          SetB = 1;
          return(0);
        }

        if ((KeepBuys == 1 || KeepSells == 1 || BalGrid == 1) &&
             valueGravyProfit + SymbolPL < GravyExit) 
        {
          ///////////////////////////////
          // Enter S.T.U.C.K. Relief mode
          ///////////////////////////////

          if (KeepBuys == 1      &&
              NumBuys < NumSells &&
              OrderType() == OP_SELL) 
          {
            Comment("Taking RobinHood_c gravy pips...");
            OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Yellow);
            GlobalVariableSet(GravyFlag, 1);
            SetB = 1;
            return(0);
          }

          if (KeepSells == 1     &&
              NumSells < NumBuys &&
              OrderType() == OP_BUY)
          {
            Comment("Taking RobinHood_c gravy pips...");
            OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Orange);
            GlobalVariableSet(GravyFlag, 1);
            SetS = 1;
            return(0);
          }

          if (BalGrid  == 1 &&
              NumSells >= 2 &&
              NumBuys  >= 2)
          {
            if (NumSells-3 < NumBuys &&
                OrderType() == OP_BUY)
            {
              Comment("Taking RobinHood_c gravy pips...");
              OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Purple);
              GlobalVariableSet(GravyFlag, 1);
              SetS = 1;
              return(0);
            }

            if (NumBuys-3 < NumSells &&
                OrderType() == OP_SELL)
            {
              Comment("Taking RobinHood_c gravy pips...");
              OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Purple);
              GlobalVariableSet(GravyFlag, 1);
              SetB = 1;
              return(0);
            }
          }
        }
      }
    }
  }

  ////////////////////////////////////////////////////////////////////
  // If no trades are open, give trader a chance to change Lots before
  // starting the next grid if StopAfterNoTrades is true, or initialize
  // the closure-related variables and calculate actual lot size to
  // use for trades in upcoming grid.
  ////////////////////////////////////////////////////////////////////

  if (NumBuys+NumSells == 0)
  {
    Comment("There are no trades open.");

    if (StopAfterNoTrades) return(0);

    SkipMPA     = 0;
    EMACounter  = 0;
    StopBal     = 0;
    StopBalB    = 0;
    StopBalS    = 0; 
    CloseAll    = 0;
    CloseSwitch = false;
    WaitSwitch  = false;
    ClockSwitch = false;
    SetS        = 0;
    SetB        = 0;
    valueGravyProfit = 0;
  }
  else
  if (NumBuys+NumSells > 0                &&
      AccountBalance() > valueCurrBalance &&
      valueGravyFlag  == 1)
  {
    valueGravyProfit = valueGravyProfit + (AccountBalance() - valueCurrBalance);
    GlobalVariableSet(GravyProfit, valueGravyProfit);
    GlobalVariableSet(CurrBalance, AccountBalance());
    GlobalVariableSet(GravyFlag, 0);
  }
  else
  if (valueGravyFlag == 0)
  {
    GlobalVariableSet(CurrBalance, AccountBalance());
  }
  
  SymbolPLExit = SymbolPLFactor*UseLots;
  GravyExit    = GravyFactor*UseLots;

  if (MM)
  {
    UseLots = MinLots*(AccountEquity()/MinEqForMinLots);
    UseLots = StrToDouble(DoubleToStr(UseLots, 2));
      
    if (UseLots < MinLots) UseLots = MinLots;
    if (UseLots > MaxLots) UseLots = MaxLots;
  }
  else UseLots = (Lots*LotSize)/100;

  BLSHLots = UseLots*LotFactor;
  if (BLSHLots > MaxLots) BLSHLots = MaxLots;
  BLSHLots = StrToDouble(DoubleToStr(BLSHLots, 2));

  ////////////////////////////
  // Print statistics to chart
  ////////////////////////////

  Comment("Symbol's total trades: ",NumBuys+NumSells,", Buy trades: ",NumBuys,", Sell trades: ",NumSells,
          "\nCurValue: ", CurValue,
          "\nGridSize: ",(HighestBuy-LowestSell)/Point," pips",
          "\nBalance: ",AccountBalance(),", Equity: ",AccountEquity(),", TotalProfit: ",AccountProfit(),
          "\nHighestBuy: ",HighestBuy,", LowestBuy: ",LowestBuy,
          "\nHighestSell: ",HighestSell,", LowestSell: ",LowestSell,
          "\nSymbol PL: ",SymbolPL,
          "\nPL Dollar Target: ",SymbolPLExit,
          "\nGravy Profit: ",valueGravyProfit,
          "\nGravy + SymbolPL: ",valueGravyProfit + SymbolPL,
          "\nGravy Dollar Target: ",GravyExit,
          "\nLastPrice: ",LastPrice,
          "\nAnchor: ",Anchor);

  /////////////////////////
  // Indicator Calculations
  /////////////////////////

  FiveEMA_0    = iMA(NULL,NULL,  5,0,MODE_EMA,PRICE_CLOSE,0);
  FiveEMA_1    = iMA(NULL,NULL,  5,0,MODE_EMA,PRICE_CLOSE,1);
  TwentyEMA_0  = iMA(NULL,NULL, 20,0,MODE_EMA,PRICE_CLOSE,0);
  TwentyEMA_1  = iMA(NULL,NULL, 20,0,MODE_EMA,PRICE_CLOSE,1);
  HundredEMA_0 = iMA(NULL,NULL,100,0,MODE_EMA,PRICE_CLOSE,0);
  HundredEMA_1 = iMA(NULL,NULL,100,0,MODE_EMA,PRICE_CLOSE,1);


  ///////////////////////////////////////////////
  // Go back to normal mode if conditions warrant
  ///////////////////////////////////////////////
    
  if ((StopBalB == 1 && FiveEMA_0 < HundredEMA_0) ||
      (StopBalS == 1 && FiveEMA_0 > HundredEMA_0))
  {
    SkipMPA     = 0;
    EMACounter  = 0;
    StopBal     = 0;
    StopBalB    = 0;
    StopBalS    = 0; 
    WaitSwitch  = false;
    ClockSwitch = false;

    if (FiveEMA_0 < HundredEMA_0) SetS = 1;
    if (FiveEMA_0 > HundredEMA_0) SetB = 1;
  }

  /////////////////////////////////////
  // Begin Market Positioning Arguments
  /////////////////////////////////////

  if (WaitSwitch && !ClockSwitch)
  {
    EmaClock    = Hour();
    EmaMin      = Minute();
    ClockSwitch = true;
  }

  if (Hour()-EmaClock >= 1 && Minute()-EmaMin >= 0)
  {
    WaitSwitch  = false;
    ClockSwitch = false;
  }
   
   
  if (CloseAll == 0 && SkipMPA == 0)
  {
    if (FiveEMA_0 > TwentyEMA_0 && FiveEMA_1 > TwentyEMA_1 && 
        FiveEMA_0 > HundredEMA_0 && FiveEMA_1 > HundredEMA_1)
    {
      KeepBuys   = 1; 
      KeepSells  = 0; 
      BalGrid    = 0;
      PointValue = UseLots*10;
    }
  
    if (FiveEMA_0 < TwentyEMA_0 && FiveEMA_1 < TwentyEMA_1 && 
        FiveEMA_0 < HundredEMA_0 && FiveEMA_1 < HundredEMA_1)
    {
      KeepSells  = 1;
      KeepBuys   = 0;
      BalGrid    = 0;
      PointValue = UseLots*10;
    }
  
    if (FiveEMA_0 < TwentyEMA_0 && FiveEMA_1 < TwentyEMA_1 && 
        FiveEMA_0 > HundredEMA_0 && FiveEMA_1 > HundredEMA_1) 
    {
      BalGrid    = 1; 
      KeepBuys   = 0; 
      KeepSells  = 0;
      PointValue = UseLots*7;
    }

    if (FiveEMA_1 >  HundredEMA_1               &&
        FiveEMA_1 < (HundredEMA_1 + (15*Point)) &&
       !WaitSwitch)                         
    { 
      WaitSwitch = true; 
      EmaValue   = FiveEMA_1;
      EMACounter++; 
    }

    if (WaitSwitch) 
    {
      if (EmaValue < CurValue) CurValue = EmaValue;
      else
      if (CurValue == 0)       CurValue = EmaValue;
    }

    if (FiveEMA_0 > (CurValue + (10*Point)) &&
        EMACounter >= 4)                     
    { 
      SkipMPA    = 1;
      StopBal    = 1;
      StopBalB   = 1;
      BalGrid    = 0;
      KeepSells  = 0;
      KeepBuys   = 0; 
      PointValue = 0;
    }
   
    if (FiveEMA_0 > TwentyEMA_0 && FiveEMA_1 > TwentyEMA_1 && 
        FiveEMA_0 < HundredEMA_0 && FiveEMA_1 < HundredEMA_1)
    {
      BalGrid    = 1; 
      KeepBuys   = 0; 
      KeepSells  = 0;
      PointValue = UseLots*7;
    }

    if (FiveEMA_1 <  HundredEMA_1                &&
        FiveEMA_1 > (HundredEMA_1 - (15*Point))  &&
       !WaitSwitch)                         
    {
      WaitSwitch = true; 
      EmaValue   = FiveEMA_1;
      EMACounter++;
    }

    if (WaitSwitch && EmaValue > CurValue) CurValue = EmaValue;

    if (FiveEMA_0 < (CurValue - (10*Point)) &&
        EMACounter >= 4)                     
    { 
      SkipMPA    = 1;
      StopBal    = 1;
      StopBalS   = 1;
      BalGrid    = 0;
      KeepSells  = 0;
      KeepBuys   = 0; 
      PointValue = 0;
    }
  } 

  ////////////////////////////////////////////////// 
  // If Profit is positive, close all open positions
  //////////////////////////////////////////////////

  if (!CloseSwitch                                       &&
     ((valueGravyProfit == 0 && SymbolPL > SymbolPLExit) ||
       valueGravyProfit + SymbolPL > GravyExit))
  {
    KeepBuys    = 0;
    KeepSells   = 0;
    BalGrid     = 0;
    SetB        = 0;
    SetS        = 0;
    CloseAll    = true; 
    CloseSwitch = true;
  }

  if (AccountEquity() < RockBottomEquity)  return(0);

  /////////////////////////////////////////////////
  // If closing switch set to 0, we want new orders
  /////////////////////////////////////////////////

  if (!CloseAll)
  {
    ////////////////////
    // Open First Trades
    ////////////////////

    if (NumBuys >= 0 || NumSells >= 0)
    {
      if (NumBuys == 0) 
      {
        Comment("Opening the first buy trade...");
        GlobalVariableSet(GravyProfit, 0);
        GlobalVariableSet(CurrBalance, AccountBalance());
        OrderSend(Symbol(),OP_BUY,UseLots,Ask,Slippage,0,0,"RHc_BLSH",0,0,Blue);
        return(0);
      }
 
      if (NumSells == 0) 
      {
        Comment("Opening the first sell trade...");
        OrderSend(Symbol(),OP_SELL,UseLots,Bid,Slippage,0,0,"RHc_BLSH",0,0,Red);
        return(0);
      }

      //////////////////////////////
      // Open additional grid trades
      //////////////////////////////

      if (SetB == 1         &&
          Ask > HighestSell &&
          BuyNewLevel == 0  &&
          SymbolPL < 0)     
      {
        Comment("Adding a RobinHood_c buy trade...");
        OrderSend(Symbol(),OP_BUY,UseLots,Ask,Slippage,0,0,"RHc_BLSH",0,0,Blue);
        SetB = 0;
        return(0);
      }

      if (SetS == 1         &&
          Bid < LowestBuy   &&
          SellNewLevel == 0 &&
          SymbolPL < 0)    
      {
        Comment("Adding a RobinHood_c sell trade...");
        OrderSend(Symbol(),OP_SELL,UseLots,Bid,Slippage,0,0,"RHc_BLSH",0,0,Red);
        SetS = 0; 
        return(0);
      }

      if (Ask > LowestBuy  &&
          BuyNewLevel == 0 &&
          SymbolPL < 0) 
      {
        Comment("Adding a RobinHood_c buy trade...");
        OrderSend(Symbol(),OP_BUY,UseLots,Ask,Slippage,0,0,"RHc_BLSH",0,0,Blue);
        return(0);
      }

      if (Bid < HighestSell &&
          SellNewLevel == 0  &&
          SymbolPL < 0)     
      {
        Comment("Adding a RobinHood_c sell trade...");
        OrderSend(Symbol(),OP_SELL,UseLots,Bid,Slippage,0,0,"RHc_BLSH",0,0,Red);
        return(0);
      }

      //+------------------------------------------------------------------+
      //|                      Manage Our Open Bombshell Buy Orders        |   
      //+------------------------------------------------------------------+  
      
      for(i = 0; i < OrdersTotal(); i++)
      {
        OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

        if (OrderLots()    > UseLots*2.0  &&
            OrderSymbol() == Symbol()     &&
            OrderType()   == OP_BUY       &&
            Bid - OrderOpenPrice() >= ProfitTarget*Point)
        {
          Comment("Taking Bombshell gravy pips...");
          OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,LightBlue);
          GlobalVariableSet(GravyFlag, 1);
          Print ("Errors Closing *in profit* BUY order = ",GetLastError());
          return(0);
        }
      }
      

      //+------------------------------------------------------------------+
      //|                      Manage Our Open Bombshell Sell Orders       |   
      //+------------------------------------------------------------------+  
      
      for(i = 0; i < OrdersTotal(); i++)
      {
        OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

        if (OrderLots()    > UseLots*2.0 &&
            OrderSymbol() == Symbol()    &&
            OrderType()   == OP_SELL     &&
            OrderOpenPrice() - Ask >= ProfitTarget*Point)
        {
          Comment("Taking Bombshell gravy pips...");
          OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,LightPink);
          GlobalVariableSet(GravyFlag, 1);
          Print ("Errors Closing *in profit* SELL order = ",GetLastError()); 
          return(0);
        }
      }  

      //+------------------------------------------------------------------+
      //|            Price Moving Up - Open Bombshell Short                |   
      //+------------------------------------------------------------------+  

      if (LastPrice >= Anchor + Threshold * Point) 
      {
        Anchor = LastPrice;
        
        if (Bid < LowestBuy)
        {
          Comment("Adding a Bombshell sell trade...");
          OrderSend(Symbol(),OP_SELL,BLSHLots,Bid,Slippage,0,0,"RHc_BLSH",0,0,Red);
          Print ("Errors opening SELL order = ",GetLastError()); 
          return(0); 
        }
      }

      //+------------------------------------------------------------------+
      //|            Price Moving Down - Open Bombshell Long               |   
      //+------------------------------------------------------------------+  
      
      if (LastPrice <= Anchor - Threshold * Point)
      { 
        Anchor = LastPrice; 

        if (Ask > HighestSell)
        {
          Comment("Adding a Bombshell buy trade...");
          OrderSend(Symbol(),OP_BUY,BLSHLots,Ask,Slippage,0,0,"RHc_BLSH",0,0,Blue);
          Print ("Errors opening BUY order = ",GetLastError()); 
          return(0);   
        } 
      } 
    }
  }
}

