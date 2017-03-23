//+------------------------------------------------------------------+
//|                                             Alograg RHc BLSH.mq4 |
//|                                          Copyright 2017, Alograg |
//|                                           https://www.alograg.me |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Alograg"
#property link "https://www.alograg.me"
#property version "1.00"
#property strict

//#include <SummaryReport.mqh>

/*
Para EURGBP se menor a dia, recomendado M30
*/

int MagicNumber = 641075158;

/////////////////////////
// External Definitions;
/////////////////////////

extern double Lots = 1.0;    // Number of lots to use for each trade; please keep at 1.0
extern double LotSize = 1.0; // Change this number to trade more than 1 nano lot.

extern int SymbolPLFactor = 100; // This value times UseLots gives the SymbolPL dollar profit target
extern int GravyFactor = 5000;   // This value times UseLots gives GravyExit (gravy PL vs pair PL profit target)

extern int Slippage = 4;     // Slippage
extern int PauseSeconds = 0; // Number of seconds to "sleep" before closing the next winning trade

extern bool StopAfterNoTrades = false;
// Set to true to give yourself a chance to set Lots
//   to a new value after existing grid closes.
// Set back to false to allow a new grid to be built
//   after adjusting Lots value.

extern bool MM = true; // Leave StopAfterNoTrades false and set MM
                       //   true to enable automatic lot size calculations
                       //   between grids.
                       // MM == False means use Lots for actual lot size.
                       // MM == True means use Money Management logic to calc actual lot size.

extern double MinLots = 0.03; // Define minimum allowable lot size

extern int MaxLots = 50; // Define maximum allowable lot size.

extern double LotFactor = 3.0;

extern int RockBottomEquity = 250;

extern int MinEqForMinLots = 2000; // Define minimum balance required for trading smallest
                                   //   allowed lot size.

extern double Threshold = 5.0;    // Used for Bombshell mode
extern double ProfitTarget = 4.0; // Used for Bombshell mode

extern int MaxOrders = 100;

//Gap
extern double GapRange = 5;
extern double SL_Factor = 2;
extern double TP_Factor = 1;
extern double MM_Risk = 2;

////////////
// Variables
////////////

double UseLots, BLSHLots, SymbolPL, SymbolPLExit, GravyExit;
int i, canOpenNewOrder;
int NumBuys, NumSells, BuyNewLevel, SellNewLevel;
double HighestBuy, LowestBuy, HighestSell, LowestSell;
bool CloseSwitch, CloseAll, WaitSwitch, ClockSwitch;
int SetB, SetS, KeepBuys, KeepSells, BalGrid;
int SkipMPA, EmaClock;
double PointValue, EmaMin, EmaValue, EMACounter, CurValue;
int StopBal, StopBalS, StopBalB;
double FiveEMA_0, FiveEMA_1, TwentyEMA_0, TwentyEMA_1, HundredEMA_0, HundredEMA_1;
string GravyFlag;
double valueGravyFlag;
string GravyProfit;
double valueGravyProfit;
string CurrBalance;
double valueCurrBalance;
int totalOrders;
string takeProfitTotalLabel, lastReportLabel;
double takeProfitTotalValue;
double takeProfitTotalReach;

double LastPrice, Anchor; // Used for Bombshell mode

double ExtInitialDeposit;

void InitGlobals()
{
  // Specify a name for the global gravy flag variable.
  GravyFlag = StringFormat("%i_%s_%d_GravyFlag", AccountNumber(), Symbol(), Period());
  // Define the variable if it doesn't already exist.
  if (!GlobalVariableCheck(GravyFlag))
    GlobalVariableSet(GravyFlag, 0);
  // Get a value.
  valueGravyFlag = GlobalVariableGet(GravyFlag);
  // Specify a name for the global variable that tracks gravy profit.
  GravyProfit = StringFormat("%i_%s_%d_GravyProfit", AccountNumber(), Symbol(), Period());
  // Define the variable if it doesn't already exist.
  if (!GlobalVariableCheck(GravyProfit))
    GlobalVariableSet(GravyProfit, 0);
  // Get a value.
  valueGravyProfit = GlobalVariableGet(GravyProfit);
  // Specify a name for the global variable that tracks the current balance.
  CurrBalance = StringFormat("%i_%s_%d_CurrBalance", AccountNumber(), Symbol(), Period());
  // Define the variable if it doesn't already exist.
  if (!GlobalVariableCheck(CurrBalance))
    GlobalVariableSet(CurrBalance, 0);
  // Get a value.
  valueCurrBalance = GlobalVariableGet(CurrBalance);
  // DateIncrment
  takeProfitTotalLabel = StringFormat("%i_%s_%d_ProfitTotal", AccountNumber(), Symbol(), Period());
  if (!GlobalVariableCheck(takeProfitTotalLabel))
  {
    GlobalVariableSet(takeProfitTotalLabel, (int)Time[0]);
  }
  // Get a value.
  takeProfitTotalValue = GlobalVariableGet(takeProfitTotalLabel);
  int tmpTakeProfitTotalReach = (int)Time[0];
  takeProfitTotalReach = (tmpTakeProfitTotalReach - takeProfitTotalValue) / (3600 * 24);
  takeProfitTotalReach /= 10;
  takeProfitTotalReach++;
}

void InitVars()
{
  /////////////////////////////
  // Initialize Key Variables;
  /////////////////////////////
  if (Bid > LastPrice)
    LastPrice = Bid;
  if (Ask < LastPrice)
    LastPrice = Ask;
  NumBuys = 0;
  NumSells = 0;
  SymbolPL = 0;
  LowestBuy = 1000;
  HighestSell = 0;
  HighestBuy = 0;
  LowestSell = 1000;
  BuyNewLevel = 0;
  SellNewLevel = 0;
  bool hasOrder;
  for (i = 0; i < totalOrders; i++)
  {
    hasOrder = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
    if (OrderSymbol() == Symbol())
    {
      SymbolPL += OrderProfit();
      if (OrderType() == OP_BUY)
      {
        NumBuys++;
        if (OrderOpenPrice() < LowestBuy)
          LowestBuy = OrderOpenPrice();
        if (OrderOpenPrice() > HighestBuy)
          HighestBuy = OrderOpenPrice();
        if (OrderOpenPrice() == Ask)
          BuyNewLevel = 1;
      }
      if (OrderType() == OP_SELL)
      {
        NumSells++;
        if (OrderOpenPrice() > HighestSell)
          HighestSell = OrderOpenPrice();
        if (OrderOpenPrice() < LowestSell)
          LowestSell = OrderOpenPrice();
        if (OrderOpenPrice() == Bid)
          SellNewLevel = 1;
      }
    }
  }
}

void CloseAllOrders()
{
  bool hasOrder;
  int orderClosed;
  double profit, closePrice;
  Print("Closs All Orders");
  for (i = totalOrders - 1; 0 <= 0; i--)
  {
    hasOrder = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
    if (OrderSymbol() == Symbol())
    {
      profit = OrderProfit();
      closePrice = OrderType() == OP_BUY ? Bid : Ask;
      if (OrderMagicNumber() != MagicNumber)
      {
        profit = OrderProfit() + OrderCommission() + OrderSwap();
        if (profit > 0)
        {
          orderClosed = OrderClose(OrderTicket(), OrderLots(), closePrice, Slippage, Green);
        }
        continue;
      }
      if (profit >= 0)
        Sleep(PauseSeconds * 1000);
      canOpenNewOrder = OrderClose(OrderTicket(), OrderLots(), closePrice, Slippage, Red);
    }
  }
}

////////////////////////////////////////////////////////////////////////////////////////////
// Close Profitable Orders Routine to avoid S.T.U.C.K.  [Stupid Trades Unite to Cause Khaos]
////////////////////////////////////////////////////////////////////////////////////////////
bool hasSTUCK()
{
  bool hasOrder, orderClosed;
  double profit, closePrice;
  for (i = 0; i < totalOrders; i++)
  {
    hasOrder = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
    if (OrderSymbol() == Symbol())
    {
      closePrice = OrderType() == OP_BUY ? Bid : Ask;
      if (OrderMagicNumber() != MagicNumber)
      {
        profit = OrderProfit() + OrderCommission() + OrderSwap();
        if (profit > 0)
        {
          orderClosed = OrderClose(OrderTicket(), OrderLots(), closePrice, Slippage, Green);
        }
        continue;
      }
      if ((!CloseAll || StopBal == 1) && (OrderProfit() >= PointValue))
      {
        if (StopBalS == 1 &&
            OrderType() == OP_BUY &&
            LowestBuy <= Bid)
        {
          //Comment("Taking RobinHood_c gravy pips...");
          orderClosed = OrderClose(OrderTicket(), OrderLots(), closePrice, Slippage, Magenta);
          GlobalVariableSet(GravyFlag, 1);
          SetS = 1;
          return true;
        }
        if (StopBalB == 1 &&
            OrderType() == OP_SELL &&
            HighestSell >= Ask)
        {
          //Comment("Taking RobinHood_c gravy pips...");
          orderClosed = OrderClose(OrderTicket(), OrderLots(), closePrice, Slippage, Yellow);
          GlobalVariableSet(GravyFlag, 1);
          SetB = 1;
          return true;
        }
        if ((KeepBuys == 1 || KeepSells == 1 || BalGrid == 1) &&
            valueGravyProfit + SymbolPL < GravyExit)
        {
          ///////////////////////////////
          // Enter S.T.U.C.K. Relief mode
          ///////////////////////////////
          if (KeepBuys == 1 &&
              NumBuys < NumSells &&
              OrderType() == OP_SELL)
          {
            //Comment("Taking RobinHood_c gravy pips...");
            orderClosed = OrderClose(OrderTicket(), OrderLots(), closePrice, Slippage, Yellow);
            GlobalVariableSet(GravyFlag, 1);
            SetB = 1;
            return true;
          }
          if (KeepSells == 1 &&
              NumSells < NumBuys &&
              OrderType() == OP_BUY)
          {
            //Comment("Taking RobinHood_c gravy pips...");
            orderClosed = OrderClose(OrderTicket(), OrderLots(), closePrice, Slippage, Orange);
            GlobalVariableSet(GravyFlag, 1);
            SetS = 1;
            return true;
          }
          if (BalGrid == 1 &&
              NumSells >= 2 &&
              NumBuys >= 2)
          {
            if (NumSells - 3 < NumBuys &&
                OrderType() == OP_BUY)
            {
              //Comment("Taking RobinHood_c gravy pips...");
              orderClosed = OrderClose(OrderTicket(), OrderLots(), closePrice, Slippage, Purple);
              GlobalVariableSet(GravyFlag, 1);
              SetS = 1;
              return true;
            }
            if (NumBuys - 3 < NumSells &&
                OrderType() == OP_SELL)
            {
              //Comment("Taking RobinHood_c gravy pips...");
              orderClosed = OrderClose(OrderTicket(), OrderLots(), closePrice, Slippage, Purple);
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
void SetChartInfo()
{
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
          "\nAnchor: ", Anchor);
}

/////////////////////////
// Indicator Calculations
/////////////////////////
void IndicatorCalculations()
{
  FiveEMA_0 = iMA(NULL, NULL, 5, 0, MODE_EMA, PRICE_CLOSE, 0);
  FiveEMA_1 = iMA(NULL, NULL, 5, 0, MODE_EMA, PRICE_CLOSE, 1);
  TwentyEMA_0 = iMA(NULL, NULL, 20, 0, MODE_EMA, PRICE_CLOSE, 0);
  TwentyEMA_1 = iMA(NULL, NULL, 20, 0, MODE_EMA, PRICE_CLOSE, 1);
  HundredEMA_0 = iMA(NULL, NULL, 100, 0, MODE_EMA, PRICE_CLOSE, 0);
  HundredEMA_1 = iMA(NULL, NULL, 100, 0, MODE_EMA, PRICE_CLOSE, 1);
}

///////////////////////////////////////////////
// Go back to normal mode if conditions warrant
///////////////////////////////////////////////
void ResturnToNormal()
{
  if ((StopBalB == 1 && FiveEMA_0 < HundredEMA_0) ||
      (StopBalS == 1 && FiveEMA_0 > HundredEMA_0))
  {
    SkipMPA = 0;
    EMACounter = 0;
    StopBal = 0;
    StopBalB = 0;
    StopBalS = 0;
    WaitSwitch = false;
    ClockSwitch = false;
    if (FiveEMA_0 < HundredEMA_0)
      SetS = 1;
    if (FiveEMA_0 > HundredEMA_0)
      SetB = 1;
  }
}

/////////////////////////////////////
// Begin Market Positioning Arguments
/////////////////////////////////////
void BeginMarketPositionArguments()
{
  if (WaitSwitch && !ClockSwitch)
  {
    EmaClock = Hour();
    EmaMin = Minute();
    ClockSwitch = true;
  }

  if (Hour() - EmaClock >= 1 && Minute() - EmaMin >= 0)
  {
    WaitSwitch = false;
    ClockSwitch = false;
  }

  if (!CloseAll && SkipMPA == 0)
  {
    if (FiveEMA_0 > TwentyEMA_0 && FiveEMA_1 > TwentyEMA_1 &&
        FiveEMA_0 > HundredEMA_0 && FiveEMA_1 > HundredEMA_1)
    {
      KeepBuys = 1;
      KeepSells = 0;
      BalGrid = 0;
      PointValue = UseLots * 10;
    }

    if (FiveEMA_0 < TwentyEMA_0 && FiveEMA_1 < TwentyEMA_1 &&
        FiveEMA_0 < HundredEMA_0 && FiveEMA_1 < HundredEMA_1)
    {
      KeepSells = 1;
      KeepBuys = 0;
      BalGrid = 0;
      PointValue = UseLots * 10;
    }

    if (FiveEMA_0 < TwentyEMA_0 && FiveEMA_1 < TwentyEMA_1 &&
        FiveEMA_0 > HundredEMA_0 && FiveEMA_1 > HundredEMA_1)
    {
      BalGrid = 1;
      KeepBuys = 0;
      KeepSells = 0;
      PointValue = UseLots * 7;
    }

    if (FiveEMA_1 > HundredEMA_1 &&
        FiveEMA_1 < (HundredEMA_1 + (15 * Point)) &&
        !WaitSwitch)
    {
      WaitSwitch = true;
      EmaValue = FiveEMA_1;
      EMACounter++;
    }

    if (WaitSwitch)
    {
      if (EmaValue < CurValue)
        CurValue = EmaValue;
      else if (CurValue == 0)
        CurValue = EmaValue;
    }

    if (FiveEMA_0 > (CurValue + (10 * Point)) &&
        EMACounter >= 4)
    {
      SkipMPA = 1;
      StopBal = 1;
      StopBalB = 1;
      BalGrid = 0;
      KeepSells = 0;
      KeepBuys = 0;
      PointValue = 0;
    }

    if (FiveEMA_0 > TwentyEMA_0 && FiveEMA_1 > TwentyEMA_1 &&
        FiveEMA_0 < HundredEMA_0 && FiveEMA_1 < HundredEMA_1)
    {
      BalGrid = 1;
      KeepBuys = 0;
      KeepSells = 0;
      PointValue = UseLots * 7;
    }

    if (FiveEMA_1 < HundredEMA_1 &&
        FiveEMA_1 > (HundredEMA_1 - (15 * Point)) &&
        !WaitSwitch)
    {
      WaitSwitch = true;
      EmaValue = FiveEMA_1;
      EMACounter++;
    }

    if (WaitSwitch && EmaValue > CurValue)
      CurValue = EmaValue;

    if (FiveEMA_0 < (CurValue - (10 * Point)) &&
        EMACounter >= 4)
    {
      SkipMPA = 1;
      StopBal = 1;
      StopBalS = 1;
      BalGrid = 0;
      KeepSells = 0;
      KeepBuys = 0;
      PointValue = 0;
    }
  }
}

//////////////////////////////////////////////////
// If Profit is positive, close all open positions
//////////////////////////////////////////////////
void EvaluatinIfProfitIsPositive()
{
  if (!CloseSwitch &&
      ((valueGravyProfit == 0 && SymbolPL > SymbolPLExit) ||
       valueGravyProfit + SymbolPL > GravyExit))
  {
    KeepBuys = 0;
    KeepSells = 0;
    BalGrid = 0;
    SetB = 0;
    SetS = 0;
    CloseAll = true;
    CloseSwitch = true;
  }
}

void SendReport()
{
  string subject, accountReport, balanceReport;
  subject = "MT4 Report " + TimeToString(TimeCurrent());
  accountReport = "";
  accountReport += StringFormat("Broker; %s", AccountInfoString(ACCOUNT_COMPANY));
  accountReport += "\n";
  accountReport += StringFormat("Deposit currency; %s", AccountInfoString(ACCOUNT_CURRENCY));
  accountReport += "\n";
  accountReport += StringFormat("Client name; %s ", AccountInfoString(ACCOUNT_NAME));
  accountReport += "\n";
  accountReport += StringFormat("Server; %s", AccountInfoString(ACCOUNT_SERVER));
  accountReport += "\n";
  accountReport += StringFormat("LOGIN =  %d", AccountInfoInteger(ACCOUNT_LOGIN));
  accountReport += "\n";
  accountReport += StringFormat("LEVERAGE =  %d", AccountInfoInteger(ACCOUNT_LEVERAGE));
  accountReport += "\n";
  bool thisAccountTradeAllowed = AccountInfoInteger(ACCOUNT_TRADE_ALLOWED);
  bool EATradeAllowed = AccountInfoInteger(ACCOUNT_TRADE_EXPERT);
  ENUM_ACCOUNT_TRADE_MODE tradeMode = (ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
  ENUM_ACCOUNT_STOPOUT_MODE stopOutMode = (ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);
  //--- Inform about the possibility to perform a trade operation
  accountReport += "Trade is ";
  accountReport += thisAccountTradeAllowed ? "permitted" : "prohibited";
  accountReport += ". ";
  //--- Find out if it is possible to trade on this account by Expert Advisors
  accountReport += "Expert Advisors ";
  accountReport += EATradeAllowed ? "permitted" : "prohibited";
  accountReport += ". Is a ";
  //--- Find out the account type
  switch (tradeMode)
  {
  case (ACCOUNT_TRADE_MODE_DEMO):
    accountReport += "demo";
    break;
  case (ACCOUNT_TRADE_MODE_CONTEST):
    accountReport += "competition";
    break;
  default:
    accountReport += "real";
  }
  accountReport += " account. The StopOut level is ";
  //--- Find out the StopOut level setting mode
  switch (stopOutMode)
  {
  case (ACCOUNT_STOPOUT_MODE_PERCENT):
    accountReport += "percentage";
    break;
  default:
    accountReport += "monetary";
  }
  accountReport += ".\n";
  balanceReport += StringFormat("BALANCE        = %G", AccountInfoDouble(ACCOUNT_BALANCE));
  balanceReport += "\n";
  balanceReport += StringFormat("CREDIT         = %G", AccountInfoDouble(ACCOUNT_CREDIT));
  balanceReport += "\n";
  balanceReport += StringFormat("PROFIT         = %G", AccountInfoDouble(ACCOUNT_PROFIT));
  balanceReport += "\n";
  balanceReport += StringFormat("EQUITY         = %G", AccountInfoDouble(ACCOUNT_EQUITY));
  balanceReport += "\n";
  balanceReport += StringFormat("MARGIN         = %G", AccountInfoDouble(ACCOUNT_MARGIN));
  balanceReport += "\n";
  balanceReport += StringFormat("MARGIN FREE    = %G", AccountInfoDouble(ACCOUNT_FREEMARGIN));
  balanceReport += "\n";
  balanceReport += StringFormat("MARGIN LEVEL   = %G", AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
  balanceReport += "\n";
  balanceReport += StringFormat("MARGIN SO CALL = %G", AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL));
  balanceReport += "\n";
  balanceReport += StringFormat("MARGIN SO SO   = %G", AccountInfoDouble(ACCOUNT_MARGIN_SO_SO));
  SendMail(subject, accountReport + balanceReport);
  SendNotification(balanceReport);
}

//+------------------------------------------------------------------+
//+ Check Open Trades                                                |
//+------------------------------------------------------------------+
int COT(int opType, int MN)
{
  int count = 0, hasOrder;
  for (int cnt_COT = 0; cnt_COT < totalOrders; cnt_COT++)
  {
    hasOrder = OrderSelect(cnt_COT, SELECT_BY_POS, MODE_TRADES);
    if (OrderSymbol() == Symbol() && OrderMagicNumber() == MN && opType == OrderType())
    {
      count++;
    }
  }
  return count;
}

//+------------------------------------------------------------------+
//| LotSize                                                          |
//+------------------------------------------------------------------+
double LotSize(double Risk, double SL)
{
  double MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);
  double MinLot = MarketInfo(Symbol(), MODE_MINLOT);
  double StopLoss = SL / Point / 10;
  double Size = Risk / 100 * AccountBalance() / 10 / StopLoss;
  if (Size <= MinLot)
    Size = MinLot;
  if (Size >= MaxLot)
    Size = MaxLot;
  return (NormalizeDouble(Size, 2));
}

//+------------------------------------------------------------------+
//| New Bar                                                          |
//+------------------------------------------------------------------+
bool NewDayBar()
{
  lastReportLabel = StringFormat("%i_%s_%d_LastReport", AccountNumber(), Symbol(), Period());
  double lastReport = GlobalVariableGet(lastReportLabel);
  double toDay = TimeDayOfWeek(Time[0]);
  if (lastReport != toDay)
  {
    GlobalVariableSet(lastReportLabel, toDay);
    return true;
  }
  return false;
}

void TryGap()
{
  if (!NewDayBar())
  {
    return;
  }
  if (!IsTesting())
    SendReport();
  double MyPoint = Digits == 3 || Digits == 5 ? Point * 10 : Point;
  int MagicSell = 760384;
  int MagicBuy = 760367;
  static bool ToTrade = COT(OP_BUY, 760367) == 0 && COT(OP_SELL, 760384) == 0;
  double CurrOpen = iOpen(Symbol(), PERIOD_D1, 0);
  double PrevClose = iClose(Symbol(), PERIOD_D1, 1);
  double Range = NormalizeDouble(MathAbs(PrevClose - CurrOpen), Digits);
  bool GAP = Range >= GapRange * MyPoint;
  //Print(ToTrade);
  //Print(GAP);
  //Print(Range);
  //Print(GapRange * MyPoint);
  //---- TP / SL
  double ATR = iATR(Symbol(), PERIOD_D1, 13, 1);
  double Spread = MarketInfo(Symbol(), MODE_SPREAD) * Point;
  double TakeProfit = ATR * TP_Factor;
  double StopLoss = (ATR * SL_Factor) + Spread;
  double RealStopLoos = LotSize(MM_Risk, StopLoss);
  //---- TRADE
  int Ticket;
  if (ToTrade == true && GAP == true)
  {
    //Print("Gap");
    if (CurrOpen < PrevClose)
    {
      Ticket = OrderSend(Symbol(), OP_BUY, LotSize(MM_Risk, StopLoss), Ask, 3, Ask - StopLoss, Ask + TakeProfit, "Gap.B", MagicBuy, 0, Blue);
      //if(Ticket < 0) Print("Error in GAP OrderSend : ", GetLastError());
      ToTrade = false;
    }
    if (CurrOpen > PrevClose)
    {
      Ticket = OrderSend(Symbol(), OP_SELL, LotSize(MM_Risk, StopLoss), Bid, 3, Bid + StopLoss, Bid - TakeProfit, "Gap.S", MagicSell, 0, Red);
      //if(Ticket < 0) Print("Error in GAP OrderSend : ", GetLastError());
      ToTrade = false;
    }
  }
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
  LastPrice = Bid;
  Anchor = (Ask + Bid) / 2;
  canOpenNewOrder = true;
  takeProfitTotalLabel = StringFormat("%i_%s_%d_ProfitTotal", AccountNumber(), Symbol(), Period());
  GlobalVariableSet(takeProfitTotalLabel, (int)TimeCurrent());
  lastReportLabel = StringFormat("%i_%s_%d_LastReport", AccountNumber(), Symbol(), Period());
  GlobalVariableSet(lastReportLabel, TimeDayOfWeek(Time[0]));
  //StringFormat("Inicio: %d",(int)TimeCurrent());
  ExtInitialDeposit = AccountBalance();
  return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
/*
Opcion 1; Sin Gap, con 0.75 ordenes
Opcion 2; Sin Gap, con 0.5 ordenes
Opcion 3; Con Gap, con 0.75 ordenes
Opcion 4; Con Gap, con 0.75 ordenes
*/
bool useGap = true;
double maxOrders = 0.75;
void OnTick()
{
  totalOrders = OrdersTotal();
  if (useGap)
    TryGap();
  RHcBLSH();
  return;
}

void RHcBLSH()
{
  InitGlobals();
  ///////////////////////////////////////////////////
  // If closing switch is true, close all open trades
  ///////////////////////////////////////////////////
  if (CloseAll)
  {
    CloseAllOrders();
  }
  InitVars();
  if (hasSTUCK())
  {
    return;
  }
  ////////////////////////////////////////////////////////////////////
  // If no trades are open, give trader a chance to change Lots before
  // starting the next grid if StopAfterNoTrades is true, or initialize
  // the closure-related variables and calculate actual lot size to
  // use for trades in upcoming grid.
  ////////////////////////////////////////////////////////////////////
  if (NumBuys + NumSells == 0)
  {
    //Comment("There are no trades open.");
    if (StopAfterNoTrades)
      return;
    SkipMPA = 0;
    EMACounter = 0;
    StopBal = 0;
    StopBalB = 0;
    StopBalS = 0;
    CloseAll = false;
    CloseSwitch = false;
    WaitSwitch = false;
    ClockSwitch = false;
    SetS = 0;
    SetB = 0;
    valueGravyProfit = 0;
  }
  else if (NumBuys + NumSells > 0 &&
           AccountBalance() > valueCurrBalance &&
           valueGravyFlag == 1)
  {
    valueGravyProfit = valueGravyProfit + (AccountBalance() - valueCurrBalance);
    GlobalVariableSet(GravyProfit, valueGravyProfit);
    GlobalVariableSet(CurrBalance, AccountBalance());
    GlobalVariableSet(GravyFlag, 0);
  }
  else if (valueGravyFlag == 0)
    GlobalVariableSet(CurrBalance, AccountBalance());
  SymbolPLExit = SymbolPLFactor * UseLots;
  GravyExit = GravyFactor * UseLots;
  if (MM)
  {
    UseLots = MinLots * (AccountEquity() / MinEqForMinLots);
    UseLots = StrToDouble(DoubleToStr(UseLots, 2));
    if (UseLots < MinLots)
      UseLots = MinLots;
    if (UseLots > MaxLots)
      UseLots = MaxLots;
  }
  else
    UseLots = (Lots * LotSize) / 100;
  BLSHLots = UseLots * LotFactor;
  if (BLSHLots > MaxLots)
    BLSHLots = MaxLots;
  BLSHLots = StrToDouble(DoubleToStr(BLSHLots, 2));
  SetChartInfo();
  IndicatorCalculations();
  ResturnToNormal();
  BeginMarketPositionArguments();
  EvaluatinIfProfitIsPositive();
  if (AccountEquity() < (RockBottomEquity / takeProfitTotalReach))
    return;
  /////////////////////////////////////////////////
  // If closing switch set to 0, we want new orders
  /////////////////////////////////////////////////
  if (!CloseAll)
  {
    string comment = "Alograg " + IntegerToString(MagicNumber);
    ////////////////////
    // Open First Trades
    ////////////////////
    if (NumBuys >= 0 || NumSells >= 0)
    {
      bool hasOrder, orderClosed;
      if (NumBuys == 0 && canOpenNewOrder)
      {
        //Comment("Opening the first buy trade...");
        GlobalVariableSet(GravyProfit, 0);
        GlobalVariableSet(CurrBalance, AccountBalance());
        canOpenNewOrder = OrderSend(Symbol(), OP_BUY, UseLots, Ask, Slippage, 0, 0, comment, MagicNumber, 0, Blue);
        //if(!canOpenNewOrder) Print("Max opening orders reach");
        ResetLastError();
        return;
      }
      if (NumSells == 0 && canOpenNewOrder)
      {
        //Comment("Opening the first sell trade...");
        canOpenNewOrder = OrderSend(Symbol(), OP_SELL, UseLots, Bid, Slippage, 0, 0, comment, MagicNumber, 0, Red);
        //if(!canOpenNewOrder) Print("Max opening orders reach");
        ResetLastError();
        return;
      }
      int OpenBuys = NumBuys / (MaxOrders + 1) < maxOrders;
      int OpenSells = NumSells / (MaxOrders + 1) < maxOrders;
      //////////////////////////////
      // Open additional grid trades
      //////////////////////////////
      if (SetB == 1 &&
          Ask > HighestSell &&
          BuyNewLevel == 0 &&
          SymbolPL < 0 &&
          canOpenNewOrder)
      {
        //Comment("Adding a RobinHood_c buy trade...");
        if (OpenBuys)
          canOpenNewOrder = OrderSend(Symbol(), OP_BUY, UseLots, Ask, Slippage, 0, 0, comment, MagicNumber, 0, Blue);
        //if(!canOpenNewOrder) Print("Max opening orders reach");
        ResetLastError();
        SetB = 0;
        return;
      }
      if (SetS == 1 &&
          Bid < LowestBuy &&
          SellNewLevel == 0 &&
          SymbolPL < 0 &&
          canOpenNewOrder)
      {
        //Comment("Adding a RobinHood_c sell trade...");
        if (OpenSells)
          canOpenNewOrder = OrderSend(Symbol(), OP_SELL, UseLots, Bid, Slippage, 0, 0, comment, MagicNumber, 0, Red);
        //if(!canOpenNewOrder) Print("Max opening orders reach");
        ResetLastError();
        SetS = 0;
        return;
      }
      if (Ask > LowestBuy &&
          BuyNewLevel == 0 &&
          SymbolPL < 0 &&
          canOpenNewOrder)
      {
        //Comment("Adding a RobinHood_c buy trade...");
        if (OpenBuys)
          canOpenNewOrder = OrderSend(Symbol(), OP_BUY, UseLots, Ask, Slippage, 0, 0, comment, MagicNumber, 0, Blue);
        //if(!canOpenNewOrder) Print("Max opening orders reach");
        ResetLastError();
        return;
      }
      if (Bid < HighestSell &&
          SellNewLevel == 0 &&
          SymbolPL < 0 &&
          canOpenNewOrder)
      {
        //Comment("Adding a RobinHood_c sell trade...");
        if (OpenSells)
          canOpenNewOrder = OrderSend(Symbol(), OP_SELL, UseLots, Bid, Slippage, 0, 0, comment, MagicNumber, 0, Red);
        //if(!canOpenNewOrder) Print("Max opening orders reach");
        ResetLastError();
        return;
      }
      //+------------------------------------------------------------------+
      //|                      Manage Our Open Bombshell Buy Orders        |
      //+------------------------------------------------------------------+
      double profit, closePrice;
      for (i = 0; i < totalOrders; i++)
      {
        hasOrder = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        closePrice = OrderType() == OP_BUY ? Bid : Ask;
        if (OrderMagicNumber() != MagicNumber)
        {
          profit = OrderProfit() + OrderCommission() + OrderSwap();
          if (profit > 0)
          {
            orderClosed = OrderClose(OrderTicket(), OrderLots(), closePrice, Slippage, Green);
          }
          continue;
        }
        if (OrderLots() > UseLots * 2.0 &&
            OrderSymbol() == Symbol() &&
            OrderType() == OP_BUY &&
            Bid - OrderOpenPrice() >= ProfitTarget * Point)
        {
          //Comment("Taking Bombshell gravy pips...");
          canOpenNewOrder = OrderClose(OrderTicket(), OrderLots(), closePrice, Slippage, LightBlue);
          GlobalVariableSet(GravyFlag, 1);
          //Print ("Errors Closing *in profit* BUY order = ",GetLastError());
          break;
        }
      }
      //+------------------------------------------------------------------+
      //|                      Manage Our Open Bombshell Sell Orders       |
      //+------------------------------------------------------------------+
      for (i = 0; i < OrdersTotal(); i++)
      {
        hasOrder = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        closePrice = OrderType() == OP_BUY ? Bid : Ask;
        if (OrderMagicNumber() != MagicNumber)
        {
          profit = OrderProfit() + OrderCommission() + OrderSwap();
          if (profit > 0)
          {
            orderClosed = OrderClose(OrderTicket(), OrderLots(), closePrice, Slippage, Green);
          }
          continue;
        }
        if (OrderLots() > UseLots * 2.0 &&
            OrderSymbol() == Symbol() &&
            OrderType() == OP_SELL &&
            OrderOpenPrice() - Ask >= ProfitTarget * Point)
        {
          //Comment("Taking Bombshell gravy pips...");
          canOpenNewOrder = OrderClose(OrderTicket(), OrderLots(), closePrice, Slippage, LightPink);
          GlobalVariableSet(GravyFlag, 1);
          //Print ("Errors Closing *in profit* SELL order = ",GetLastError());
          break;
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
          //Comment("Adding a Bombshell sell trade...");
          if (OpenSells)
            canOpenNewOrder = OrderSend(Symbol(), OP_SELL, BLSHLots, Bid, Slippage, 0, 0, comment, MagicNumber, 0, Red);
          //if(!canOpenNewOrder) Print("Max opening orders reach");
          ResetLastError();
          //Print ("Errors opening SELL order = ",GetLastError());
          return;
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
          //Comment("Adding a Bombshell buy trade...");
          if (OpenBuys)
            canOpenNewOrder = OrderSend(Symbol(), OP_BUY, BLSHLots, Ask, Slippage, 0, 0, comment, MagicNumber, 0, Blue);
          //if(!canOpenNewOrder) Print("Max opening orders reach");
          ResetLastError();
          //Print ("Errors opening BUY order = ",GetLastError());
          return;
        }
      }
    }
  }
}

//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
{
  double ret = Ask;
  takeProfitTotalLabel = StringFormat("%i_%s_%d_ProfitTotal", AccountNumber(), Symbol(), Period());
  lastReportLabel = StringFormat("%i_%s_%d_LastReport", AccountNumber(), Symbol(), Period());
  GlobalVariableDel(takeProfitTotalLabel);
  GlobalVariableDel(lastReportLabel);
  return (ret);
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
}
//+------------------------------------------------------------------+
