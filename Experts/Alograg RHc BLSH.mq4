//+------------------------------------------------------------------+
//|                                             Alograg RHc BLSH.mq4 |
//|                                          Copyright 2017, Alograg |
//|                                           https://www.alograg.me |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Alograg"
#property link      "https://www.alograg.me"
#property version   "1.00"
#property strict

/*
Para EURGBP se menor a dia, recomendado M30
*/

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

extern int MaxOrders           =   100;

////////////
// Variables
////////////

double UseLots, BLSHLots, SymbolPL, SymbolPLExit, GravyExit;
int    i;
int    NumBuys, NumSells, BuyNewLevel, SellNewLevel;
double HighestBuy, LowestBuy, HighestSell, LowestSell, canOpenNewOrder;
bool   CloseSwitch, CloseAll, WaitSwitch, ClockSwitch;
int    SetB, SetS, KeepBuys, KeepSells, BalGrid;
int    SkipMPA, EmaClock;
double PointValue, EmaMin, EmaValue, EMACounter, CurValue;
int    StopBal, StopBalS, StopBalB;
double FiveEMA_0, FiveEMA_1, TwentyEMA_0, TwentyEMA_1, HundredEMA_0, HundredEMA_1;
string GravyFlag;
double valueGravyFlag;
string GravyProfit;
double valueGravyProfit;
string CurrBalance;
double valueCurrBalance;
int totalOrders;
string takeProfitTotalLabel;
double takeProfitTotalValue;
double takeProfitTotalReach;

double LastPrice, Anchor; // Used for Bombshell mode

void InitGlobals() {
  // Specify a name for the global gravy flag variable.
  GravyFlag = StringFormat("%i_%s_%d_GravyFlag",AccountNumber(), Symbol(), Period());
  // Define the variable if it doesn't already exist.
  if (!GlobalVariableCheck(GravyFlag)) GlobalVariableSet(GravyFlag, 0);
  // Get a value.
  valueGravyFlag = GlobalVariableGet(GravyFlag);
  // Specify a name for the global variable that tracks gravy profit.
  GravyProfit = StringFormat("%i_%s_%d_GravyProfit",AccountNumber(), Symbol(), Period());
  // Define the variable if it doesn't already exist.
  if (!GlobalVariableCheck(GravyProfit)) GlobalVariableSet(GravyProfit, 0);
  // Get a value.
  valueGravyProfit = GlobalVariableGet(GravyProfit);
  // Specify a name for the global variable that tracks the current balance.
  CurrBalance = StringFormat("%i_%s_%d_CurrBalance",AccountNumber(), Symbol(), Period());
  // Define the variable if it doesn't already exist.
  if (!GlobalVariableCheck(CurrBalance)) GlobalVariableSet(CurrBalance, 0);
  // Get a value.
  valueCurrBalance = GlobalVariableGet(CurrBalance);
  // DateIncrment
  takeProfitTotalLabel = StringFormat("%i_%s_%d_ProfitTotal",AccountNumber(), Symbol(), Period());
  if (!GlobalVariableCheck(takeProfitTotalLabel)) {
    GlobalVariableSet(takeProfitTotalLabel, (int)Time[0]);
  }
  // Get a value.
  takeProfitTotalValue = GlobalVariableGet(takeProfitTotalLabel);
  int tmpTakeProfitTotalReach = (int)Time[0];
  takeProfitTotalReach = (tmpTakeProfitTotalReach - takeProfitTotalValue)/(3600*24);
  takeProfitTotalReach /= 10;
  takeProfitTotalReach++;
}

void InitVars() {
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
  bool hasOrder;
  for(i = 0; i < totalOrders; i++) {
    hasOrder = OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
    if (OrderSymbol() == Symbol()) {
      SymbolPL += OrderProfit();
      if (OrderType() == OP_BUY) {
        NumBuys++;
        if (OrderOpenPrice() < LowestBuy)   LowestBuy   = OrderOpenPrice();
        if (OrderOpenPrice() > HighestBuy)  HighestBuy  = OrderOpenPrice();
        if (OrderOpenPrice() == Ask)        BuyNewLevel = 1;
      }
      if (OrderType() == OP_SELL) {
        NumSells++;
        if (OrderOpenPrice() > HighestSell)  HighestSell  = OrderOpenPrice();
        if (OrderOpenPrice() < LowestSell)   LowestSell   = OrderOpenPrice();
        if (OrderOpenPrice() == Bid)         SellNewLevel = 1;
      }
    }
  }
}

void CloseAllOrders() {
  bool hasOrder;
  for(i = totalOrders -1; 0 <= 0; i--) {
    hasOrder = OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
    if (OrderSymbol() == Symbol()) {
      if (OrderType() == OP_BUY && OrderProfit() < 0) {
        Comment("In grid closure mode.  Closing a loser...");
        canOpenNewOrder = OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,White);
        }
        if (OrderType() == OP_SELL && OrderProfit() < 0) {
          Comment("In grid closure mode.  Closing a loser...");
          canOpenNewOrder = OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,White);
        }
      }
    }
  for(i = totalOrders -1; 0 <= 0; i--) {
    hasOrder = OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
    if (OrderSymbol() == Symbol()) {
      if (OrderType() == OP_BUY && OrderProfit() >= 0) {
        Sleep(PauseSeconds*1000);
        Comment("In grid closure mode.  Closing a winner...");
        canOpenNewOrder = OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,White);
      }
      if (OrderType() == OP_SELL && OrderProfit() >= 0) {
        Sleep(PauseSeconds*1000);
        Comment("In grid closure mode.  Closing a winner...");
        canOpenNewOrder = OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,White);
      }
    }
  }
}

////////////////////////////////////////////////////////////////////////////////////////////
// Close Profitable Orders Routine to avoid S.T.U.C.K.  [Stupid Trades Unite to Cause Khaos]
////////////////////////////////////////////////////////////////////////////////////////////
bool hasSTUCK() {
  bool hasOrder, orderClosed;
  for(i = 0; i < totalOrders; i++) {
    hasOrder = OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
    if (OrderSymbol() == Symbol()) {
      if ((!CloseAll || StopBal == 1) && (OrderProfit() >= PointValue)) {
        if (StopBalS == 1         &&
            OrderType() == OP_BUY &&
            LowestBuy <= Bid) {
          Comment("Taking RobinHood_c gravy pips...");
          orderClosed = OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Magenta);
          GlobalVariableSet(GravyFlag, 1);
          SetS = 1;
          return true;
        }
        if (StopBalB == 1          &&
            OrderType() == OP_SELL &&
            HighestSell >= Ask) {
          Comment("Taking RobinHood_c gravy pips...");
          orderClosed = OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Yellow);
          GlobalVariableSet(GravyFlag, 1);
          SetB = 1;
          return true;
        }
        if ((KeepBuys == 1 || KeepSells == 1 || BalGrid == 1) &&
             valueGravyProfit + SymbolPL < GravyExit)  {
          ///////////////////////////////
          // Enter S.T.U.C.K. Relief mode
          ///////////////////////////////
          if (KeepBuys == 1      &&
              NumBuys < NumSells &&
              OrderType() == OP_SELL)  {
            Comment("Taking RobinHood_c gravy pips...");
            orderClosed = OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Yellow);
            GlobalVariableSet(GravyFlag, 1);
            SetB = 1;
            return true;
          }
          if (KeepSells == 1     &&
              NumSells < NumBuys &&
              OrderType() == OP_BUY) {
            Comment("Taking RobinHood_c gravy pips...");
            orderClosed = OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Orange);
            GlobalVariableSet(GravyFlag, 1);
            SetS = 1;
            return true;
          }
          if (BalGrid  == 1 &&
              NumSells >= 2 &&
              NumBuys  >= 2) {
            if (NumSells-3 < NumBuys &&
                OrderType() == OP_BUY) {
              Comment("Taking RobinHood_c gravy pips...");
              orderClosed = OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Purple);
              GlobalVariableSet(GravyFlag, 1);
              SetS = 1;
              return true;
            }
            if (NumBuys-3 < NumSells &&
                OrderType() == OP_SELL) {
              Comment("Taking RobinHood_c gravy pips...");
              orderClosed = OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Purple);
              GlobalVariableSet(GravyFlag, 1);
              SetB = 1;
              return true;
            }
          }
        }
      }
    }
  }
  return false;
}

////////////////////////////
// Print statistics to chart
////////////////////////////
void SetChartInfo() {
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
}

/////////////////////////
// Indicator Calculations
/////////////////////////
void IndicatorCalculations() {
  FiveEMA_0    = iMA(NULL,NULL,  5,0,MODE_EMA,PRICE_CLOSE,0);
  FiveEMA_1    = iMA(NULL,NULL,  5,0,MODE_EMA,PRICE_CLOSE,1);
  TwentyEMA_0  = iMA(NULL,NULL, 20,0,MODE_EMA,PRICE_CLOSE,0);
  TwentyEMA_1  = iMA(NULL,NULL, 20,0,MODE_EMA,PRICE_CLOSE,1);
  HundredEMA_0 = iMA(NULL,NULL,100,0,MODE_EMA,PRICE_CLOSE,0);
  HundredEMA_1 = iMA(NULL,NULL,100,0,MODE_EMA,PRICE_CLOSE,1);
}

///////////////////////////////////////////////
// Go back to normal mode if conditions warrant
///////////////////////////////////////////////
void ResturnToNormal() {
  if ((StopBalB == 1 && FiveEMA_0 < HundredEMA_0) ||
      (StopBalS == 1 && FiveEMA_0 > HundredEMA_0)) {
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
}

/////////////////////////////////////
// Begin Market Positioning Arguments
/////////////////////////////////////
void BeginMarketPositionArguments() {
  if (WaitSwitch && !ClockSwitch) {
    EmaClock    = Hour();
    EmaMin      = Minute();
    ClockSwitch = true;
  }

  if (Hour()-EmaClock >= 1 && Minute()-EmaMin >= 0) {
    WaitSwitch  = false;
    ClockSwitch = false;
  }
   
   
  if (CloseAll == 0 && SkipMPA == 0) {
    if (FiveEMA_0 > TwentyEMA_0 && FiveEMA_1 > TwentyEMA_1 && 
        FiveEMA_0 > HundredEMA_0 && FiveEMA_1 > HundredEMA_1) {
      KeepBuys   = 1; 
      KeepSells  = 0; 
      BalGrid    = 0;
      PointValue = UseLots*10;
    }
  
    if (FiveEMA_0 < TwentyEMA_0 && FiveEMA_1 < TwentyEMA_1 && 
        FiveEMA_0 < HundredEMA_0 && FiveEMA_1 < HundredEMA_1) {
      KeepSells  = 1;
      KeepBuys   = 0;
      BalGrid    = 0;
      PointValue = UseLots*10;
    }
  
    if (FiveEMA_0 < TwentyEMA_0 && FiveEMA_1 < TwentyEMA_1 && 
        FiveEMA_0 > HundredEMA_0 && FiveEMA_1 > HundredEMA_1)  {
      BalGrid    = 1; 
      KeepBuys   = 0; 
      KeepSells  = 0;
      PointValue = UseLots*7;
    }

    if (FiveEMA_1 >  HundredEMA_1               &&
        FiveEMA_1 < (HundredEMA_1 + (15*Point)) &&
       !WaitSwitch)                          { 
      WaitSwitch = true; 
      EmaValue   = FiveEMA_1;
      EMACounter++; 
    }

    if (WaitSwitch)  {
      if (EmaValue < CurValue) CurValue = EmaValue;
      else
      if (CurValue == 0)       CurValue = EmaValue;
    }

    if (FiveEMA_0 > (CurValue + (10*Point)) &&
        EMACounter >= 4)                      { 
      SkipMPA    = 1;
      StopBal    = 1;
      StopBalB   = 1;
      BalGrid    = 0;
      KeepSells  = 0;
      KeepBuys   = 0; 
      PointValue = 0;
    }
   
    if (FiveEMA_0 > TwentyEMA_0 && FiveEMA_1 > TwentyEMA_1 && 
        FiveEMA_0 < HundredEMA_0 && FiveEMA_1 < HundredEMA_1) {
      BalGrid    = 1; 
      KeepBuys   = 0; 
      KeepSells  = 0;
      PointValue = UseLots*7;
    }

    if (FiveEMA_1 <  HundredEMA_1                &&
        FiveEMA_1 > (HundredEMA_1 - (15*Point))  &&
       !WaitSwitch)                          {
      WaitSwitch = true; 
      EmaValue   = FiveEMA_1;
      EMACounter++;
    }

    if (WaitSwitch && EmaValue > CurValue) CurValue = EmaValue;

    if (FiveEMA_0 < (CurValue - (10*Point)) &&
        EMACounter >= 4)                      { 
      SkipMPA    = 1;
      StopBal    = 1;
      StopBalS   = 1;
      BalGrid    = 0;
      KeepSells  = 0;
      KeepBuys   = 0; 
      PointValue = 0;
    }
  } 
}

////////////////////////////////////////////////// 
// If Profit is positive, close all open positions
//////////////////////////////////////////////////
void EvaluatinIfProfitIsPositive() {
  if (!CloseSwitch                                       &&
     ((valueGravyProfit == 0 && SymbolPL > SymbolPLExit) ||
       valueGravyProfit + SymbolPL > GravyExit)) {
    KeepBuys    = 0;
    KeepSells   = 0;
    BalGrid     = 0;
    SetB        = 0;
    SetS        = 0;
    CloseAll    = true; 
    CloseSwitch = true;
  }
}


void SendReport() {
  string subject, report;
  bool canSend = Hour()==23 && Minute()==00;
  if (!canSend) return;
  subject = "MT4 Report " + TimeToString(TimeCurrent());
  report = "Report";
  report += StringFormat("The name of the broker; %s", AccountInfoString(ACCOUNT_COMPANY));
  report += "\n";
  report += StringFormat("Deposit currency; %s", AccountInfoString(ACCOUNT_CURRENCY));
  report += "\n";
  report += StringFormat("Client name; %s ", AccountInfoString(ACCOUNT_NAME));
  report += "\n";
  report += StringFormat("The name of the trade server; %s", AccountInfoString(ACCOUNT_SERVER));
  report += "\n";
  report += StringFormat("LOGIN =  %d", AccountInfoInteger(ACCOUNT_LOGIN));
  report += "\n";
  report += StringFormat("LEVERAGE =  %d", AccountInfoInteger(ACCOUNT_LEVERAGE));
  report += "\n";
  bool thisAccountTradeAllowed = AccountInfoInteger(ACCOUNT_TRADE_ALLOWED);
  bool EATradeAllowed = AccountInfoInteger(ACCOUNT_TRADE_EXPERT);
  ENUM_ACCOUNT_TRADE_MODE tradeMode = (ENUM_ACCOUNT_TRADE_MODE) AccountInfoInteger(ACCOUNT_TRADE_MODE);
  ENUM_ACCOUNT_STOPOUT_MODE stopOutMode=(ENUM_ACCOUNT_STOPOUT_MODE) AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);
  //--- Inform about the possibility to perform a trade operation 
  report += "Trade for this account is ";
  report += thisAccountTradeAllowed ? "permitted" : "prohibited";
  report += "\n";
  //--- Find out if it is possible to trade on this account by Expert Advisors 
  report += "Trade by Expert Advisors is ";
  report += EATradeAllowed ? "permitted" : "prohibited";
  report += "\n";
  //--- Find out the account type 
  switch(tradeMode) {
    case(ACCOUNT_TRADE_MODE_DEMO):
      report += "This is a demo account";
      break; 
    case(ACCOUNT_TRADE_MODE_CONTEST):
      report += "This is a competition account";
      break;
    default:
      report += "This is a real account!"; 
  }
  report += "\n";
  //--- Find out the StopOut level setting mode 
  switch(stopOutMode) {
    case(ACCOUNT_STOPOUT_MODE_PERCENT):
      report += "The StopOut level is specified percentage";
      break;
    default:
      report += "The StopOut level is specified in monetary terms";
  }
  report += "\n";
  report += StringFormat("BALANCE        = %G", AccountInfoDouble(ACCOUNT_BALANCE)); 
  report += "\n";
  report += StringFormat("CREDIT         = %G", AccountInfoDouble(ACCOUNT_CREDIT)); 
  report += "\n";
  report += StringFormat("PROFIT         = %G", AccountInfoDouble(ACCOUNT_PROFIT)); 
  report += "\n";
  report += StringFormat("EQUITY         = %G", AccountInfoDouble(ACCOUNT_EQUITY)); 
  report += "\n";
  report += StringFormat("MARGIN         = %G", AccountInfoDouble(ACCOUNT_MARGIN)); 
  report += "\n";
  report += StringFormat("MARGIN FREE    = %G", AccountInfoDouble(ACCOUNT_FREEMARGIN)); 
  report += "\n";
  report += StringFormat("MARGIN LEVEL   = %G", AccountInfoDouble(ACCOUNT_MARGIN_LEVEL)); 
  report += "\n";
  report += StringFormat("MARGIN SO CALL = %G", AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL)); 
  report += "\n";
  report += StringFormat("MARGIN SO SO   = %G", AccountInfoDouble(ACCOUNT_MARGIN_SO_SO));
  report += "\nAttm, EA";
  SendMail(subject, report);
}
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
  LastPrice = Bid;
  Anchor = (Ask+Bid)/2;
  canOpenNewOrder = true;
  takeProfitTotalLabel = StringFormat("%i_%s_%d_ProfitTotal",AccountNumber(), Symbol(), Period());
  GlobalVariableSet(takeProfitTotalLabel, (int)TimeCurrent());
  StringFormat("Inicio: ",(int)TimeCurrent());
  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
  totalOrders = OrdersTotal();
  InitGlobals();
  ///////////////////////////////////////////////////
  // If closing switch is true, close all open trades
  ///////////////////////////////////////////////////
  if (CloseAll) {
    CloseAllOrders();
  }
  InitVars();
  if(hasSTUCK()){
    return;
  }
  ////////////////////////////////////////////////////////////////////
  // If no trades are open, give trader a chance to change Lots before
  // starting the next grid if StopAfterNoTrades is true, or initialize
  // the closure-related variables and calculate actual lot size to
  // use for trades in upcoming grid.
  ////////////////////////////////////////////////////////////////////
  if (NumBuys+NumSells == 0) {
    Comment("There are no trades open.");
    if (StopAfterNoTrades) return;
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
  } else
    if (NumBuys+NumSells > 0         &&
      AccountBalance() > valueCurrBalance &&
      valueGravyFlag  == 1) {
    valueGravyProfit = valueGravyProfit + (AccountBalance() - valueCurrBalance);
    GlobalVariableSet(GravyProfit, valueGravyProfit);
    GlobalVariableSet(CurrBalance, AccountBalance());
    GlobalVariableSet(GravyFlag, 0);
  } else
    if (valueGravyFlag == 0) GlobalVariableSet(CurrBalance, AccountBalance());
  SymbolPLExit = SymbolPLFactor*UseLots;
  GravyExit    = GravyFactor*UseLots;
  if (MM) {
    UseLots = MinLots*(AccountEquity()/MinEqForMinLots);
    UseLots = StrToDouble(DoubleToStr(UseLots, 2));
    if (UseLots < MinLots) UseLots = MinLots;
    if (UseLots > MaxLots) UseLots = MaxLots;
  } else UseLots = (Lots*LotSize)/100;
  BLSHLots = UseLots*LotFactor;
  if (BLSHLots > MaxLots) BLSHLots = MaxLots;
  BLSHLots = StrToDouble(DoubleToStr(BLSHLots, 2));
  SetChartInfo();
  IndicatorCalculations();
  ResturnToNormal();
  BeginMarketPositionArguments();
  EvaluatinIfProfitIsPositive();
  if (AccountEquity() < (RockBottomEquity / takeProfitTotalReach))  return;
  /////////////////////////////////////////////////
  // If closing switch set to 0, we want new orders
  /////////////////////////////////////////////////
  if (!CloseAll) {
    ////////////////////
    // Open First Trades
    ////////////////////
    if (NumBuys >= 0 || NumSells >= 0) {
      bool hasOrder;
      if (NumBuys == 0 && canOpenNewOrder) {
        Comment("Opening the first buy trade...");
        GlobalVariableSet(GravyProfit, 0);
        GlobalVariableSet(CurrBalance, AccountBalance());
        canOpenNewOrder = OrderSend(Symbol(),OP_BUY,UseLots,Ask,Slippage,0,0,"RHc_BLSH",0,0,Blue);
        if(!canOpenNewOrder) Print("Max opening orders reach");
        ResetLastError();
        return;
      }
      if (NumSells == 0 && canOpenNewOrder) {
        Comment("Opening the first sell trade...");
        canOpenNewOrder = OrderSend(Symbol(),OP_SELL,UseLots,Bid,Slippage,0,0,"RHc_BLSH",0,0,Red);
        if(!canOpenNewOrder) Print("Max opening orders reach");
        ResetLastError();
        return;
      }
      //////////////////////////////
      // Open additional grid trades
      //////////////////////////////
      if (SetB == 1         &&
          Ask > HighestSell &&
          BuyNewLevel == 0  &&
          SymbolPL < 0      &&
          canOpenNewOrder) {
        Comment("Adding a RobinHood_c buy trade...");
        if(NumBuys/MaxOrders < 0.75 )
          canOpenNewOrder = OrderSend(Symbol(),OP_BUY,UseLots,Ask,Slippage,0,0,"RHc_BLSH",0,0,Blue);
        if(!canOpenNewOrder) Print("Max opening orders reach");
        ResetLastError();
        SetB = 0;
        return;
      }
      if (SetS == 1         &&
          Bid < LowestBuy   &&
          SellNewLevel == 0 &&
          SymbolPL < 0      &&
          canOpenNewOrder) {
        Comment("Adding a RobinHood_c sell trade...");
        if(NumSells/MaxOrders < 0.75 )
          canOpenNewOrder = OrderSend(Symbol(),OP_SELL,UseLots,Bid,Slippage,0,0,"RHc_BLSH",0,0,Red);
        if(!canOpenNewOrder) Print("Max opening orders reach");
        ResetLastError();
        SetS = 0; 
        return;
      }
      if (Ask > LowestBuy  &&
          BuyNewLevel == 0 &&
          SymbolPL < 0     &&
          canOpenNewOrder) {
        Comment("Adding a RobinHood_c buy trade...");
        if(NumBuys/MaxOrders < 0.75 )
          canOpenNewOrder = OrderSend(Symbol(),OP_BUY,UseLots,Ask,Slippage,0,0,"RHc_BLSH",0,0,Blue);
        if(!canOpenNewOrder) Print("Max opening orders reach");
        ResetLastError();
        return;
      }
      if (Bid < HighestSell  &&
          SellNewLevel == 0  &&
          SymbolPL < 0       &&
          canOpenNewOrder) {
        Comment("Adding a RobinHood_c sell trade...");
        if(NumSells/MaxOrders < 0.75 )
          canOpenNewOrder = OrderSend(Symbol(),OP_SELL,UseLots,Bid,Slippage,0,0,"RHc_BLSH",0,0,Red);
        if(!canOpenNewOrder) Print("Max opening orders reach");
        ResetLastError();
        return;
      }
      //+------------------------------------------------------------------+
      //|                      Manage Our Open Bombshell Buy Orders        |   
      //+------------------------------------------------------------------+  
      for(i = 0; i < totalOrders; i++) {
        hasOrder = OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
        if (OrderLots()    > UseLots*2.0  &&
            OrderSymbol() == Symbol()     &&
            OrderType()   == OP_BUY       &&
            Bid - OrderOpenPrice() >= ProfitTarget*Point) {
          Comment("Taking Bombshell gravy pips...");
          canOpenNewOrder = OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,LightBlue);
          GlobalVariableSet(GravyFlag, 1);
          Print ("Errors Closing *in profit* BUY order = ",GetLastError());
          return;
        }
      }
      //+------------------------------------------------------------------+
      //|                      Manage Our Open Bombshell Sell Orders       |   
      //+------------------------------------------------------------------+  
      for(i = 0; i < OrdersTotal(); i++) {
        hasOrder = OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
        if (OrderLots()    > UseLots*2.0 &&
            OrderSymbol() == Symbol()    &&
            OrderType()   == OP_SELL     &&
            OrderOpenPrice() - Ask >= ProfitTarget*Point) {
          Comment("Taking Bombshell gravy pips...");
          canOpenNewOrder = OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,LightPink);
          GlobalVariableSet(GravyFlag, 1);
          Print ("Errors Closing *in profit* SELL order = ",GetLastError()); 
          return;
        }
      }
      //+------------------------------------------------------------------+
      //|            Price Moving Up - Open Bombshell Short                |   
      //+------------------------------------------------------------------+  
      if (LastPrice >= Anchor + Threshold * Point)  {
        Anchor = LastPrice;
        if (Bid < LowestBuy) {
          Comment("Adding a Bombshell sell trade...");
          if(NumSells/MaxOrders < 0.75 )
            canOpenNewOrder = OrderSend(Symbol(),OP_SELL,BLSHLots,Bid,Slippage,0,0,"RHc_BLSH",0,0,Red);
          if(!canOpenNewOrder) Print("Max opening orders reach");
          ResetLastError();
          Print ("Errors opening SELL order = ",GetLastError()); 
          return; 
        }
      }
      //+------------------------------------------------------------------+
      //|            Price Moving Down - Open Bombshell Long               |   
      //+------------------------------------------------------------------+  
      if (LastPrice <= Anchor - Threshold * Point) { 
        Anchor = LastPrice; 
        if (Ask > HighestSell) {
          Comment("Adding a Bombshell buy trade...");
          if(NumBuys/MaxOrders < 0.75 )
            canOpenNewOrder = OrderSend(Symbol(),OP_BUY,BLSHLots,Ask,Slippage,0,0,"RHc_BLSH",0,0,Blue);
          if(!canOpenNewOrder) Print("Max opening orders reach");
          ResetLastError();
          Print ("Errors opening BUY order = ",GetLastError()); 
          return;
        }
      }
    }
  }
  SendReport();
}

//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester() {
  double ret=Ask;
  takeProfitTotalLabel = StringFormat("%i_%s_%d_ProfitTotal",AccountNumber(), Symbol(), Period());
  GlobalVariableDel(takeProfitTotalLabel);
  return(ret);
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {
  }
//+------------------------------------------------------------------+
