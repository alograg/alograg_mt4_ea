//+------------------------------------------------------------------+
//|                                      SpielersHedge EA_v2.8.1.mq4 |
//|                                            © 2008.08.20 SwingMan |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "© 2008.08.20 SwingMan"
#property link      ""
//+------------------------------------------------------------------+
// v2.2 automatic orders, draw lines
// v2.3 nLevels to trade, infoWinLoss in valuta
// v2.4 2008.07.14 Add alerts, bugs..
// v2.5 2008.07.15 Three levels, sound alert, bugs...
// v2.6 2008.07.18 Four levels, write ratios, trading 4 levels, bugs...
// v2.7 2008.07.27 bug: many opens after the close
// v2.8 2008.07.29 bug: alerts for crossing 0 line, without orders
// v2.8.1 2008.08.20 font size as parameter
//+------------------------------------------------------------------+

//-- include librarys
#include <SpielersHedge_Library.mqh>


//------- TEST --------
//!!!
bool TestingOK = false;
//!!!

//+------------------------------------------------------------------+
//| External Variables                                               |
//+------------------------------------------------------------------+
extern string Symbols = "EURUSD,USDCHF,EURCHF";
extern string SymbolSuffix = "";
extern int MagicNumber = 0;
//extern bool BUY_forMinusRatios = true;
//extern bool StartTrade_Immediately  = false;
extern bool Autom_OpenOrders  = false;
extern bool Autom_CloseOrders = true;
extern int ShiftDays_ForReference = 1;
extern double DivergenceLimit1 = 0.25;
extern double DivergenceLimit2 = 0.50;
extern double DivergenceLimit3 = 0.75;
extern double DivergenceLimit4 = 1.00;
extern int TakeProfit_Pips = 0;
extern int StopLoss_Pips = 0;
extern double Lots = 0.10;
extern double LotsRatio = 0;
extern int Max_LevelsToTrade = 4;
extern bool Send_Alert = true;
extern bool Send_Mail = false;              //##
extern bool Play_Sound = true;
//-- Licence inputs
//extern datetime TestTime_until = D'2008.08.08 08:08';
extern string only_demo_accounts = "";
extern int shiftPosition_Divergence = 5;
extern int fontSize_Divergence = 35;
extern int fontSize_Text = 10;
//--------------------------------------------------------------------

bool BUY_forMinusRatios = true;

//---- variables
int TimeFrame = 0;
int    Trend_Direction   = 0;
bool   Set_MarketOrder = false;
double Entry_Price      = 0.0;
double Exit_Price = 0.0;
bool   Set_BreakEven = true;
double BreakEven_Points = 10;
bool   Set_TrailingStop = true;
bool   Set_StopAndReverseExit = true;
bool   Exit_AtClose = true;
double Factor_BreakEven;

//-- constants
double RiscFactor = 2;

//+------------------------------------------------------------------+
string sNameEA = "SpielersHedge EA_v2.81";
string sCommentEA = " SpielersHdg EAv2.81";
int    iMagic = 20080820, Magic;
string accCurrency;
string sObject = "SH_EA281_";
int iLabelCorner = 1;
int xx1 = 80;
int xx2 = 2;
int xx3 = 60;
int xx4 = 30;
int yy0 = 14, yy;
int yStep;

//+------------------------------------------------------------------+
//| Internal variables                                               |
//+------------------------------------------------------------------+
/*int    PricePerPip;
double DecimalCorrection;
int    DecimalPlaces;*/
//double MaxLots;

bool   OKToTrade = true; 
bool   BuyFlag, SellFlag, StartUp;
//bool   StopLossAdjust;

//int    ticket[6];
//int maxOpenOrders = 1;
#define Slippage_Entry 5
#define Slippage_Exit 10

datetime thisTime, oldTime;
string sComment, sSymbol, sWindow;
//-- System trading --------------------------------------------------
/*int TradeSignal;
int iDigits;
double dPoints, dOffsetEntry, Spread;
double dStopLevel;
double orderLots;

int ma_Shift = 1;
double dATR2;*/

//---- Entry
int iTradingLevel = 0;
int iWindow = 0;
/*
//double EntryPrice, EntryPriceBuy, EntryPriceSel;
double Stop1Buy,Targ1Buy;
double Stop1Sel,Targ1Sel;
double TrailingStop;
bool bEntryDirectionChanged, bEntryValueChanged, bTradingLevelChanged;
datetime EntryTime;*/

//---- Trading
int TradeDirection = 0;
//int ticket_BUYPosition, ticket_SELLPosition;
//bool TradeAlowed;

//-- variables NeutralHedge
//double dMainRangePrice, dSubRangePrice;
//string MainSymbol = "";
/*
int Offset_Ratio;
datetime Last_Time;
bool Correlation = true;
double dPoint;
int firstBar, lastBar;
datetime firstTime, lastTime;
double Close_Main, Close_Sub;
double HedgeRange, threshold;
bool Trade_EntryTimeOK;*/

//-- variables SpielersHedge
string Symbol1, Symbol2, Symbol3;
double dPoints1, dPoints2, dPoints3;
int Digits1, Digits2, Digits3;
double Spread1, Spread2, Spread3;
double lastClose1, lastClose2, lastClose3;
double Price1, Price2, Price3;
double Diff1, Diff2, Diff3;
double LevelValue[10], EntryLongValue[10], EntryShortValue[10];
int nOpenOrders1, nOpenOrders2;
double nLots1, nLots2;
double minLots;
int DigitsLot;
double newDivergenceLimit;
string Pair[30];
double EntryPrice1, EntryPrice2;
double WinLossPoints=0, WinLossCurrency = 0;
bool DrawThresholdLines = true;
bool AlertSended = false;
int iBuyForMinusRatio;
int thisDay, oldDay;
double FirstDivergenceLimit;
double CurrentRange;
datetime timeLastClose3;
int firstThresholdBar;

//-- constants
int alert_Entry = 0;
int alert_Exit = 1;
bool bAlert_Exit;

//+------------------------------------------------------------------+
//|   Check Licence
//+------------------------------------------------------------------+
bool Check_Licence()
{
   bool result = true;
   //-- default input for allowed!
   if (only_demo_accounts == "demo") return(true);
   
   //-- check licence
   
   /*if (Time[0] > TestTime_until) {
      Alert(sNameEA + ". Test time until: ", TimeToStr(TestTime_until));
      result = false;      
   }*/
   
   if (IsDemo() == false) {
      Alert(sNameEA + ". Only demo accounts allowed.");
      result = false;
   }
   return(result);
}

//+------------------------------------------------------------------+
//| initialization
//+------------------------------------------------------------------+
int init()
{ 
   yStep = fontSize_Text + 2;
   OKToTrade = true;
   if (OKToTrade == false) return(-1);
   
   Print("OK # Initialisation ", sNameEA);
   
   if (ShiftDays_ForReference <= 0) ShiftDays_ForReference = 1;

   //-- MagicNumber
   if (MagicNumber == 0) Magic = iMagic; else Magic = MagicNumber;
   
   //-- buy or sell for minus ratio
   if (BUY_forMinusRatios == true) iBuyForMinusRatio = 1; else iBuyForMinusRatio = -1;
        
   //-- GetSymbols
   Get_PairListNames(Symbols, SymbolSuffix, Pair);
   Symbol1 = Pair[0];
   Symbol2 = Pair[1];
   Symbol3 = Pair[2];
   
   //-- Trading levels
   LevelValue[1] = DivergenceLimit1;
   LevelValue[2] = DivergenceLimit2;
   LevelValue[3] = DivergenceLimit3;
   LevelValue[4] = DivergenceLimit4;
   FirstDivergenceLimit = DivergenceLimit1;

   //.................................................................   
   sWindow = sNameEA + " (" + Get_sPeriod(TimeFrame)+") ";
   accCurrency = AccountCurrency();
   
   dPoints1 = MarketInfo(Symbol1, MODE_POINT);
   dPoints2 = MarketInfo(Symbol2, MODE_POINT);
   dPoints3 = MarketInfo(Symbol3, MODE_POINT);

   Digits1 = MarketInfo(Symbol1, MODE_DIGITS);
   Digits2 = MarketInfo(Symbol2, MODE_DIGITS);
   Digits3 = MarketInfo(Symbol3, MODE_DIGITS);
   
   Spread1  = MarketInfo(Symbol1, MODE_SPREAD) * dPoints1;
   Spread2  = MarketInfo(Symbol2, MODE_SPREAD) * dPoints2;
   Spread3  = MarketInfo(Symbol3, MODE_SPREAD) * dPoints3;


   //-- current day --------------------------
   oldDay = DayOfWeek();
   //-- last closes
   lastClose1 = iClose(Symbol1, PERIOD_D1, ShiftDays_ForReference);
   lastClose2 = iClose(Symbol2, PERIOD_D1, ShiftDays_ForReference);
   lastClose3 = iClose(Symbol3, PERIOD_D1, ShiftDays_ForReference);   
   
   IndicatorDigits(Digits);     
   DeleteOwnObjects(sObject);  
   
   //-- min lots
   minLots = MarketInfo(Symbol(),MODE_MINLOT);
   if (minLots == 0.01) DigitsLot = 2;  
   if (minLots == 0.1)  DigitsLot = 1;
   if (minLots == 1.0)  DigitsLot = 0;
   
//---- TEST ------------------------  
   if (TestingOK) Test_InfoWriting(); 
   else {
      timeLastClose3 = iTime(Symbol3, PERIOD_D1, ShiftDays_ForReference);
      Draw_ThresholdLines(sObject, iWindow, lastClose3, LevelValue, EntryLongValue, EntryShortValue, timeLastClose3);   
      Check_ActiveOrders(Symbol1, Symbol2, Magic);
      CalculateIndicators();

      Write_InfoIndicators(Symbol1, Symbol2, Symbol3);
      Write_WinLossTrading(Symbol1, Symbol2);   
      Write_CurrentRange();
      Show_Comment();
   }   

//-- Trade immediately
   //if (StartTrade_Immediately) Start_TradeImmediately();
   
   return(0);
}

//+------------------------------------------------------------------+
//| deinit
//+------------------------------------------------------------------+
int deinit()
{
   DeleteOwnObjects(sObject);
   Comment("");
   return(0);
}

//+------------------------------------------------------------------+
//| Main code                                                        |
//+------------------------------------------------------------------+
int start()
{
   //-- TEST ---
   if (TestingOK) return(0);
   if (OKToTrade==false) return(-1);
   
   bool bOpenOrders = Check_ActiveOrders(Symbol1, Symbol2, Magic);   

   //-- check new Day   
   thisDay = DayOfWeek();
   if (thisDay != oldDay) {
      if (nOpenOrders1 ==0 && nOpenOrders2 ==0) 
         ShiftDays_ForReference = 1; 
      else   
         ShiftDays_ForReference++;
      
      lastClose1 = iClose(Symbol1, PERIOD_D1, ShiftDays_ForReference);
      lastClose2 = iClose(Symbol2, PERIOD_D1, ShiftDays_ForReference);
      lastClose3 = iClose(Symbol3, PERIOD_D1, ShiftDays_ForReference);  
      oldDay = DayOfWeek();
   }
//while (IsConnected()) {
   //-- 1. calculate trend and indicators
   CalculateIndicators();        
   

   //--  2. Check Entry Condition
   if (nOpenOrders1 ==0 && nOpenOrders2 ==0) {
      BuyFlag = false; 
      SellFlag= false;
      StartUp = true;
      bAlert_Exit = false;
   }  else
      bAlert_Exit = true;
   
   Get_TradingLevel(); 
   
   //-- 3. Check Entry Condition

//-- TEST ----
/*Diff3 = -0.25;
TakeProfit_Pips = 5;
StopLoss_Pips = 3;*/
   
   Check_EntryCondition(Symbol1, Symbol2);
   
   //-- 4. Check Exit Condition
   Check_ExitCondition(Symbol1, Symbol2);

   //-- write infos
   Write_InfoIndicators(Symbol1, Symbol2, Symbol3);
   Write_WinLossTrading(Symbol1, Symbol2);   
   //if (DrawThresholdLines) 
   
   timeLastClose3 = iTime(Symbol3, PERIOD_D1, ShiftDays_ForReference);
   Draw_ThresholdLines(sObject, iWindow, lastClose3, LevelValue, EntryLongValue, EntryShortValue,timeLastClose3);
   //DrawThresholdLines = false;
   
   Write_CurrentRange();

   Show_Comment();
   //Sleep(200);
//}    
   return(0);
}
//####################################################################


//+------------------------------------------------------------------+
//    Calculate Indicators
//+------------------------------------------------------------------+
void CalculateIndicators()
{
   Price1 = iClose(Symbol1, Period(), 0); 
   Price2 = iClose(Symbol2, Period(), 0);
   Price3 = iClose(Symbol3, Period(), 0);
   
   if (lastClose1 != 0) Diff1 = 100.0 * (Price1 - lastClose1) / lastClose1;
   if (lastClose2 != 0) Diff2 = 100.0 * (Price2 - lastClose2) / lastClose2;
   if (lastClose3 != 0) Diff3 = 100.0 * (Price3 - lastClose3) / lastClose3;
    
   //-- LONG trade (Diff3 < 0)
   if (Diff3 < 0) {
      TradeDirection = 1 * iBuyForMinusRatio;
      //if (nOpenOrders1 == 0 && nOpenOrders2 == 0) TradeDirection = 1 * iBuyForMinusRatio;
      if (iTradingLevel == 0) // -0.25%
         newDivergenceLimit = -FirstDivergenceLimit;
   } else  
   //-- SHORT trade (Diff3 > 0)
   if (Diff3 > 0) {
      TradeDirection = -1 * iBuyForMinusRatio;
      //if (nOpenOrders1 == 0 && nOpenOrders2 == 0) TradeDirection = -1 * iBuyForMinusRatio;
      if (iTradingLevel == 0) // 0.25%
         newDivergenceLimit = FirstDivergenceLimit;   
   }   
   
   CurrentRange = Diff3;   
}



//####################################################################
//+------------------------------------------------------------------+
//    Check Entry Condition
//+------------------------------------------------------------------+
void Check_EntryCondition(string Symbol1, string Symbol2)
{
//-- TEST ----
//return;

   bool TradingOK = false;
   int iOrder1 = -1, iOrder2 = -1;
   double sign;
  
   if (iTradingLevel >= 4) return;
   
   if (TradeDirection == 1) 
        sign = -1; // LONG (Diff1 < 0)
   else sign =  1; // SHORT (Diff1 > 0)  
//Print ("1. iTradingLevel= ",iTradingLevel,  "  newDivergenceLimit= ",newDivergenceLimit,"  TradeDirection= ",TradeDirection,"  Diff3=",Diff3);
   
   //-- check limits .................................................
   //-- LONG trade (Diff3 < 0)
   if (TradeDirection == 1) {
      if (Autom_OpenOrders && 
          Max_LevelsToTrade > 1 &&
          iTradingLevel <= 4 && 
          nOpenOrders1 == 0) {
         Try_Start_TradeImmediately();
         /*TradingOK = true; // entry on level 1
         iOrder1 = OP_BUY;
         iOrder2 = OP_BUY;
         newDivergenceLimit = LevelValue[iTradingLevel + 1] * sign; // 0.20% -> 0.40% for Level2*/
      } 
      else
   
      if (Diff3 <= newDivergenceLimit) {
         if (iTradingLevel < Max_LevelsToTrade) iTradingLevel++; // Level1 -> Level2,  Level2 -> Level3, Level3 -> Level4
         Send_TradeAlert(OP_BUY, newDivergenceLimit, alert_Entry, "");
//Print("2. iTradingLevel=",iTradingLevel,"  newDivergenceLimit=",newDivergenceLimit,  " Max_LevelsToTrade=",Max_LevelsToTrade);
         //-- trading levels
         if (iTradingLevel == 1 && Max_LevelsToTrade > 1) {  
            TradingOK = true; // entry on level 1
            iOrder1 = OP_BUY;
            iOrder2 = OP_BUY;
            newDivergenceLimit = LevelValue[2] * sign; // 0.20% -> 0.40% for Level2
//Print("3. iTradingLevel=",iTradingLevel,"  newDivergenceLimit=",newDivergenceLimit,  "TradingOK=",TradingOK,"  iOrder1=",iOrder1);
         } else
         if (iTradingLevel == 2 && Max_LevelsToTrade > 2) {  
            TradingOK = true; // entry on level 2
            iOrder1 = OP_BUY;
            iOrder2 = OP_BUY;
            newDivergenceLimit = LevelValue[3] * sign; // 0.40% -> 0.60% for Level3
         } else
         if (iTradingLevel == 3 && Max_LevelsToTrade > 3) {  
            TradingOK = true; // entry on level 3
            iOrder1 = OP_BUY;
            iOrder2 = OP_BUY;
            newDivergenceLimit = LevelValue[4] * sign;
         }
      }
   }   

   //-- SHORT trade (Diff3 > 0)
   if (TradeDirection == -1) {
      if (Autom_OpenOrders && 
          Max_LevelsToTrade > 1 &&
          iTradingLevel <= 4 && 
          nOpenOrders1 == 0) {
         Try_Start_TradeImmediately(); 
         /*TradingOK = true; // entry on level 1
         iOrder1 = OP_SELL;
         iOrder2 = OP_SELL;
         newDivergenceLimit = LevelValue[iTradingLevel + 1] * sign; // 0.20% -> 0.40% for Level2*/
      } 
      else
      
      if (Diff3 >= newDivergenceLimit) {
         if (iTradingLevel < Max_LevelsToTrade) iTradingLevel++; // Level1 -> Level2,  Level2 -> Level3, Level3 -> Level4
         Send_TradeAlert(OP_SELL, newDivergenceLimit, alert_Entry, "");
                  
         if (iTradingLevel == 1 && Max_LevelsToTrade > 1) {
            TradingOK = true; // entry on level 1
            iOrder1 = OP_SELL;
            iOrder2 = OP_SELL;
            newDivergenceLimit = LevelValue[2] * sign; // 0.20% -> 0.40% for Level2
         } else
         if (iTradingLevel == 2 && Max_LevelsToTrade > 2) {
            TradingOK = true; // entry on level 2
            iTradingLevel++;
            iOrder1 = OP_SELL;
            iOrder2 = OP_SELL;
            newDivergenceLimit = LevelValue[3] * sign; // 0.40% -> 0.60% for Level3
//Print("2. iTradingLevel=",iTradingLevel,"  newDivergenceLimit=",newDivergenceLimit,  " Max_LevelsToTrade=",Max_LevelsToTrade,"  Diff3=",Diff3);
         } else
         if (iTradingLevel == 3 && Max_LevelsToTrade > 3) {
            TradingOK = true; // entry on level 3
            iTradingLevel++;
            iOrder1 = OP_SELL;
            iOrder2 = OP_SELL;
            newDivergenceLimit = LevelValue[4] * sign;
         }
      }
   }      
/*
   if (TradeDirection == -1) {
      if (Diff3 >= newDivergenceLimit) {
         if (iTradingLevel < Max_LevelsToTrade) iTradingLevel++; // Level1 -> Level2,  Level2 -> Level3, Level3 -> Level4
         Send_TradeAlert(OP_SELL, newDivergenceLimit, alert_Entry, "");
                  
         if (iTradingLevel == 1 && Max_LevelsToTrade > 1) {
            TradingOK = true; // entry on level 1
            iOrder1 = OP_SELL;
            iOrder2 = OP_SELL;
            newDivergenceLimit = LevelValue[2] * sign; // 0.20% -> 0.40% for Level2
         } else
         if (iTradingLevel == 2 && Max_LevelsToTrade > 2) {
            TradingOK = true; // entry on level 2
            iTradingLevel++;
            iOrder1 = OP_SELL;
            iOrder2 = OP_SELL;
            newDivergenceLimit = LevelValue[3] * sign; // 0.40% -> 0.60% for Level3
Print("2. iTradingLevel=",iTradingLevel,"  newDivergenceLimit=",newDivergenceLimit,  " Max_LevelsToTrade=",Max_LevelsToTrade,"  Diff3=",Diff3);
         } else
         if (iTradingLevel == 3 && Max_LevelsToTrade > 3) {
            TradingOK = true; // entry on level 3
            iTradingLevel++;
            iOrder1 = OP_SELL;
            iOrder2 = OP_SELL;
            newDivergenceLimit = LevelValue[4] * sign;
         }
      }
   }      
*/
   //-- automatically orders =========================================
   if (Autom_OpenOrders == false) return;
/*   
   //-- StartTrade_Immediately .......................................
   if (StartTrade_Immediately == true) {      
      if (TradingOK == false && nOpenOrders1 == 0 && nOpenOrders2 == 0) {
         //-- long
         if (TradeDirection == 1) {
            iOrder1 = OP_BUY;
            iOrder2 = OP_BUY;
            newDivergenceLimit = LevelValue[iTradingLevel + 1] * sign;         
            Send_TradeAlert(OP_BUY, Diff3, alert_Entry, "");
         } else
         //-- short
         if (TradeDirection == -1) {
            iOrder1 = OP_SELL;
            iOrder2 = OP_SELL;
            newDivergenceLimit = LevelValue[iTradingLevel + 1] * sign;
            Send_TradeAlert(OP_SELL, Diff3, alert_Entry, "");
         }
         TradingOK = true;
      }
      Sleep(500);
      Check_ActiveOrders(Symbol1, Symbol2, Magic);
      Show_Comment();      
   }
*/   
//Print("TradingOK=",TradingOK,"  iOrder1=",iOrder1);
   if (TradingOK == false) return;


   //if (nOpenOrders1 > 0 && nOpenOrders2 > 0) return;
   //if (BuyFlag == true || SellFlag == true) return;
   
   //-- set orders ...................................................   
   Get_OrderLots();
   //-- LONG trade
   if (TradeDirection == 1) {
      if (iOrder1 >= 0 && iOrder2 >= 0)
         Send_MarketOrderTwoPairs(Symbol1, iOrder1, nLots1,  Symbol2, iOrder2, nLots2);   
   }                            
   //-- SHORT trade
   if (TradeDirection == -1) {   
      if (iOrder1 >= 0 && iOrder2 >= 0)
         Send_MarketOrderTwoPairs(Symbol1, iOrder1, nLots1,  Symbol2, iOrder2, nLots2);   
   }                            
}


//####################################################################
//+------------------------------------------------------------------+
//    Send Market Order TwoPairs
//+------------------------------------------------------------------+
void Send_MarketOrderTwoPairs(string Symbol1, int iOrder1, double nLots1,
                              string Symbol2, int iOrder2, double nLots2)
{
   //-- LONG trade ...................................................
   if (iOrder1 == OP_BUY) {
      string Comment1 = "buy " + Symbol1 + sCommentEA; //" SpielersHedgeV5";
      Set_MarketOrder(OP_BUY, Symbol1, nLots1, Comment1, Magic);
   } 
   if (iOrder2 == OP_BUY) {
      string Comment2 = "buy " + Symbol2 + sCommentEA; //" SpielersHedgeV5";
      Set_MarketOrder(OP_BUY, Symbol2, nLots2, Comment2, Magic);
   } 
   
   //-- SHORT trade ..................................................
   if (iOrder1 == OP_SELL) {
      Comment1 = "sell " + Symbol1 + sCommentEA; //" SpielersHedgeV5";
      Set_MarketOrder(OP_SELL, Symbol1, nLots1, Comment1, Magic);
   }
   if (iOrder2 == OP_SELL) {
      Comment2 = "sell " + Symbol2 + sCommentEA; //" SpielersHedgeV5";
      Set_MarketOrder(OP_SELL, Symbol2, nLots2, Comment2, Magic);
   }   
}

//+------------------------------------------------------------------+
//| Set Market Order
//+------------------------------------------------------------------+
void Set_MarketOrder(int iOrderType, string sSymbol, double nLots, string CommentOrder, int iMagicNumber)
{
   int ticket;
   double StopLoss=0.0, TakeProfit=0.0;
   double dBid = MarketInfo(sSymbol, MODE_BID);
   double dAsk = MarketInfo(sSymbol, MODE_ASK);

   //---- Long Order -------------------------------------------------
   if (iOrderType == OP_BUY) {
      ticket=OrderSend(sSymbol,OP_BUY,nLots,dAsk, Slippage_Entry,StopLoss,TakeProfit,CommentOrder,iMagicNumber,0,CLR_NONE);
      if (ticket == -1) Send_ErrorDescription(sSymbol,"buy");
      else {
         BuyFlag = true; 
         SellFlag= false;
      }
   }
   else
   
   //---- Short Order ------------------------------------------------
   if (iOrderType == OP_SELL) {
      ticket=OrderSend(sSymbol,OP_SELL,nLots,dBid, Slippage_Entry,StopLoss,TakeProfit,CommentOrder,iMagicNumber,0,CLR_NONE);
      if (ticket == -1) Send_ErrorDescription(sSymbol,"sell");
      else {
         BuyFlag = false; 
         SellFlag= true;
      }
   }   
   return;
}


//####################################################################
//+------------------------------------------------------------------+
//    Check Exit Condition, for ratio=0, Target and StopLoss
//+------------------------------------------------------------------+
void Check_ExitCondition(string Symbol1, string Symbol2)
{
//-- TEST ----
//return;

   if (Autom_CloseOrders == false) return;      
   bool CloseOrdersOK = false;
   string text = "";

   //-- check limits   
   //-- LONG trade   (Diff3 < 0)
   if (TradeDirection == 1) {
      if (Diff3 >= 0) {
         CloseOrdersOK = true;
         //string text = "  ratio = " + DoubleToStr(Diff3,2) + "%";
      }   
      if (TakeProfit_Pips > 0 && WinLossPoints >= TakeProfit_Pips) {
         CloseOrdersOK = true;
         //text = "  Take Profit at " + DoubleToStr(TakeProfit_Pips,0)+ " Pips";
      }   
      if (StopLoss_Pips > 0 && WinLossPoints   <= -StopLoss_Pips) {
         CloseOrdersOK = true;
         //text = "  Stop Loss at " + DoubleToStr(-StopLoss_Pips,0)+ " Pips";
      }   
   }   
//Diff3 = -0.10;
   //-- SHORT trade  (Diff3 > 0)
   if (TradeDirection == -1) {
      if (Diff3 <= 0) {
         CloseOrdersOK = true;
         //text = "  ratio = " + DoubleToStr(Diff3,2) + "%";
      }
      if (TakeProfit_Pips > 0 && WinLossPoints >= TakeProfit_Pips) {
         CloseOrdersOK = true;
         //text = "  Take Profit at " + DoubleToStr(TakeProfit_Pips,0)+ " Pips";
      }
      if (StopLoss_Pips > 0 && WinLossPoints   <= -StopLoss_Pips) {
         CloseOrdersOK = true;
         //text = "  Stop Loss at " + DoubleToStr(-StopLoss_Pips,0)+ " Pips";
      }
   }      

   if (CloseOrdersOK == false) return;
     
   //-- close orders
   if (nOpenOrders1 == 0 && nOpenOrders2 == 0) return;   
   
   //-- alert ........................................................  
   if (bAlert_Exit)
      Send_TradeAlert(-1, Diff3, alert_Exit, text);   
   
   //################################################
   //-- reset trading level and set ShiftDay at 1 !!!
   iTradingLevel = 0;
   ShiftDays_ForReference = 1;
   
   Close_ActiveOrders(Symbol1, Magic);
   Close_ActiveOrders(Symbol2, Magic);
}

//+------------------------------------------------------------------+
//| Close active Orders
//+------------------------------------------------------------------+
void Close_ActiveOrders(string sSymbol, int iMagicNumber)
{
//-- TEST ----
//return;

   double dBid, dAsk;
   int nOrdersTotal = OrdersTotal();
   if (nOrdersTotal == 0) return;
   
   if (Autom_OpenOrders == true) int myMagicNumber = iMagicNumber; else myMagicNumber = 0;
   int nOpenOrders = Get_NumberOpenOrders(sSymbol, myMagicNumber);
   if (nOpenOrders == 0) return;      
  
   while (nOpenOrders != 0) {   
      nOrdersTotal = OrdersTotal();
      for (int iOrder=0; iOrder<nOrdersTotal; iOrder++) {
         if ( OrderSelect(iOrder, SELECT_BY_POS, MODE_TRADES) && 
            OrderSymbol()==sSymbol &&
            OrderMagicNumber() == myMagicNumber &&  // don't close other MagicNumbers!
            OrderCloseTime()==0) 
         {
            if ( (OrderType()==OP_BUY || OrderType()==OP_SELL) ) {
               dBid = MarketInfo(sSymbol, MODE_BID);
               dAsk = MarketInfo(sSymbol, MODE_ASK);
               if (OrderType()==OP_BUY) double price = dBid; else price = dAsk;
               bool closeOK = OrderClose(OrderTicket(), OrderLots(), price, Slippage_Exit, CLR_NONE);
               if (closeOK == false) Send_ErrorDescription(sSymbol, "");
            }   
         }
      }
      nOpenOrders = Get_NumberOpenOrders(sSymbol, myMagicNumber);
   }
  
   
/*      
   //-- 1. close automatic sended orders ==========================
   if (Autom_OpenOrders == true) {
      while (nOpenOrders != 0) {   
         nOrdersTotal = OrdersTotal();
         for (int iOrder=0; iOrder<nOrdersTotal; iOrder++) {
            if ( OrderSelect(iOrder, SELECT_BY_POS, MODE_TRADES) && 
               OrderSymbol()==sSymbol &&
               OrderMagicNumber() == myMagicNumber &&
               OrderCloseTime()==0) 
            {
               if ( (OrderType()==OP_BUY || OrderType()==OP_SELL) ) {
                  dBid = MarketInfo(sSymbol, MODE_BID);
                  dAsk = MarketInfo(sSymbol, MODE_ASK);
                  if (OrderType()==OP_BUY) double price = dBid; else price = dAsk;
                  bool closeOK = OrderClose(OrderTicket(), OrderLots(), price, Slippage_Exit, CLR_NONE);
                  if (closeOK == false) Send_ErrorDescription(sSymbol, "");
               }   
            }
         }
         nOpenOrders = Get_NumberOpenOrders(sSymbol, myMagicNumber);
      }
   } else
      
   //-- 2. close manual orders ====================================
   {
      while (nOpenOrders != 0) {   
         nOrdersTotal = OrdersTotal();   
         for (int iOrder=0; iOrder<nOrdersTotal; iOrder++) {
            if ( OrderSelect(iOrder, SELECT_BY_POS, MODE_TRADES) && 
               OrderSymbol()==sSymbol &&
               OrderCloseTime()==0) 
            {
               if ( (OrderType()==OP_BUY || OrderType()==OP_SELL) ) {
                  if (OrderType()==OP_BUY) price = dBid; else price = dAsk;
                  closeOK = OrderClose(OrderTicket(), OrderLots(), price, Slippage_Exit, CLR_NONE);
                  if (closeOK == false) Send_ErrorDescription(sSymbol, "");
               }   
            }
         }
         nOpenOrders = Get_NumberOpenOrders(sSymbol, myMagicNumber);
      }
   }
*/
   return;
}


//+------------------------------------------------------------------+
//    Get Number OpenOrders
//+------------------------------------------------------------------+
int Get_NumberOpenOrders(string sSymbol, int iMagicNumber)
{
   int total=OrdersTotal();   
   int nOpenOrders = 0;

   //-- MagicNumber > 0
   if (iMagicNumber > 0) {  
      for(int i=0; i<total; i++) {
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderCloseTime()==0 && OrderSymbol() == sSymbol && OrderMagicNumber() == iMagicNumber) {
               if (OrderType()==OP_BUY || OrderType()==OP_SELL) {
                  nOpenOrders++;
               }
            }
         }
      }
   } else
   //-- MagicNumber = 0   
   {
      for(i=0; i<total; i++) {
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderCloseTime()==0 && OrderSymbol() == sSymbol) {
               if (OrderType()==OP_BUY || OrderType()==OP_SELL) {
                  nOpenOrders++;
               }
            }
         }
      }   
   }
   return(nOpenOrders);
}

//####################################################################
//+------------------------------------------------------------------+
//    Check Active Orders
//+------------------------------------------------------------------+
bool Check_ActiveOrders(string Symbol1, string Symbol2, int& iMagicNumber)
{
   bool iReturn = false;
   
   nOpenOrders1 = 0;
   nOpenOrders2 = 0;

   int nOrdersTotal = OrdersTotal();
   if (nOrdersTotal > 0) {
      //-- Symbol1 ...................................................
      for(int iOrder=0; iOrder<nOrdersTotal; iOrder++) {
         //-- automatically open orders
         if (Autom_OpenOrders == true) {
            if (OrderSelect(iOrder, SELECT_BY_POS, MODE_TRADES) && 
               OrderSymbol() == Symbol1 && 
               OrderMagicNumber() == iMagicNumber &&
               OrderCloseTime() == 0) 
            {       
               EntryPrice1 = OrderOpenPrice();
               nLots1 = OrderLots();
               if (OrderType() == OP_BUY) {
                  nOpenOrders1++; 
                  //TradeDirection = 1;
                  iReturn=true;
                  BuyFlag = true; 
                  SellFlag= false;
               }
               if (OrderType() == OP_SELL) {
                  nOpenOrders1++; 
                  //TradeDirection = -1;
                  iReturn=true;
                  BuyFlag = false; 
                  SellFlag= true;
               }
            }
         } else
         //-- manual open orders
         {
            if ( OrderSelect(iOrder, SELECT_BY_POS, MODE_TRADES) && 
               OrderSymbol() == Symbol1 && 
               OrderCloseTime() == 0) 
            {       
               EntryPrice1 = OrderOpenPrice();
               nLots1 = OrderLots();
               if ( OrderType()==OP_BUY ) {
                  nOpenOrders1++; 
                  iReturn=true;
                  BuyFlag = true; 
                  SellFlag= false;
               }
               if ( OrderType()==OP_SELL) {
                  nOpenOrders1++; 
                  iReturn=true;
                  BuyFlag = false; 
                  SellFlag= true;
               }
            }
         }
      }
      
      //-- Symbol2 ...................................................
      for(iOrder=0; iOrder<nOrdersTotal; iOrder++) {
         //-- automatically open orders
         if (Autom_OpenOrders == true) {
            if (OrderSelect(iOrder, SELECT_BY_POS, MODE_TRADES) && 
               OrderSymbol()==Symbol2 && 
               OrderMagicNumber() == iMagicNumber &&
               OrderCloseTime()==0) 
            {  
               EntryPrice2 = OrderOpenPrice();
               nLots2 = OrderLots();
               if (OrderType() == OP_BUY) {
                  nOpenOrders2++; 
                  iReturn=true;
                  BuyFlag = true; 
                  SellFlag= false;
               }
               if (OrderType() == OP_SELL) {
                  nOpenOrders2++; 
                  iReturn=true;
                  BuyFlag = false; 
                  SellFlag= true;
               }
            }
         } else
         //-- manual open orders
         {
            if (OrderSelect(iOrder, SELECT_BY_POS, MODE_TRADES) && 
               OrderSymbol() == Symbol2 && 
               OrderCloseTime() == 0) 
            {  
               EntryPrice2 = OrderOpenPrice();
               nLots2 = OrderLots();
               if (OrderType() == OP_BUY) {
                  nOpenOrders2++; 
                  iReturn=true;
                  BuyFlag = true; 
                  SellFlag= false;
               }
               if (OrderType() == OP_SELL) {
                  nOpenOrders2++; 
                  iReturn=true;
                  BuyFlag = false; 
                  SellFlag= true;
               }
            }
         }
      }      
   }
   if (nOpenOrders1 == 0 && nOpenOrders2 == 0) StartUp = true;
//   Get_TradingLevel();

   return(iReturn);
}

//+------------------------------------------------------------------+
//    Get Trading Level
//+------------------------------------------------------------------+
void Get_TradingLevel()
{
   double sign; 
   if (TradeDirection == 1) 
        sign = -1;
   else sign =  1;

   
   //-- check limits .................................................
   //-- LONG trade (Diff3 < 0)
   if (TradeDirection == 1) {
      if (Diff3 > LevelValue[1] * sign) {
         iTradingLevel = 0; 
         newDivergenceLimit = LevelValue[1] * sign;
      } else       
      if (Diff3 > LevelValue[2] * sign) {
         iTradingLevel = 1; 
         newDivergenceLimit = LevelValue[2] * sign;
      } else
      if (Diff3 > LevelValue[1] * sign) {
         iTradingLevel = 2; 
         newDivergenceLimit = LevelValue[3] * sign;
      } else {
         iTradingLevel = 3;
         newDivergenceLimit = EMPTY_VALUE * sign;
      }       
   } else 
   
   //-- SHORT trade (Diff3 > 0)
   if (TradeDirection == -1) {   
      if (Diff3 < LevelValue[1] * sign) {
        iTradingLevel = 0; 
        newDivergenceLimit = LevelValue[1] * sign;
      } else
      if (Diff3 < LevelValue[2] * sign) {
         iTradingLevel = 1; 
         newDivergenceLimit = LevelValue[2] * sign;
      } else
      if (Diff3 < LevelValue[1] * sign) {
         iTradingLevel = 2; 
         newDivergenceLimit = LevelValue[3] * sign;
      } else {      
         iTradingLevel = 3;
         newDivergenceLimit = EMPTY_VALUE * sign;
      }   
   }           

   //-- Trading levels
/*   LevelValue[1] = DivergenceLimit1;
   LevelValue[2] = DivergenceLimit2;
   LevelValue[3] = DivergenceLimit3;*/
}   

//####################################################################
//+------------------------------------------------------------------+
//    Write Info Indicators
//+------------------------------------------------------------------+
void Write_InfoIndicators(string Symbol1, string Symbol2, string Symbol3)
{
   if(nOpenOrders1==0 && nOpenOrders2==0) DeleteOwnObjects(sObject);
   
//-- TEST -----   
//Show_Comment();   

   yy = yy0;
   iLabelCorner = 1;
   color dColor = Orange;
   color dColorArrow;
   int iHeight = 10;
double Price11 = iClose(Symbol1, Period(), 0);   
double Price21 = iClose(Symbol2, Period(), 0);   
double Price31 = iClose(Symbol3, Period(), 0);   
   string sPrice1 = " (" + DoubleToStr(lastClose1,Digits1) + " / " + DoubleToStr(Price11,Digits1) + ")";
   string sPrice2 = " (" + DoubleToStr(lastClose2,Digits2) + " / " + DoubleToStr(Price21,Digits2) + ")";
   string sPrice3 = " (" + DoubleToStr(lastClose3,Digits3) + " / " + DoubleToStr(Price31,Digits3) + ")";
   string sText1 = Symbol1 + sPrice1 + "= " + DoubleToStr(Diff1,2) + "%"; 
   string sText2 = Symbol2 + sPrice2 + "= " + DoubleToStr(Diff2,2) + "%"; 
   string sText3 = Symbol3 + sPrice3 + "= " + DoubleToStr(Diff3,3) + "%"; 
   
   //-- Trade LONG
   if (Diff3 <0) {
      dColorArrow = Green;
      if (Diff3 < -FirstDivergenceLimit) {
         string sTrend = "LONG trade";
         int ArrowCode = 233;
      }  else {        
         sTrend = "wait on long at -" + DoubleToStr(FirstDivergenceLimit,2)+ "%";
         ArrowCode = 216;
      }
   } else   
   //-- Trade SHORT
   {
      dColorArrow = Red;
      if (Diff3 > FirstDivergenceLimit) {
         sTrend = "SHORT trade";
         ArrowCode = 234;
      } else {
         sTrend = "wait on short at " + DoubleToStr(FirstDivergenceLimit,2)+ "%";
         ArrowCode = 216;
      }    
   }
   //-- pair 1
   Write_Label(iWindow, iLabelCorner, sObject, sText3, "", fontSize_Text, dColor, xx2, xx2, yy); yy = yy + yStep+2;
   //-- trend
   dColor = Gold;
   Write_Label(iWindow, iLabelCorner, sObject, sTrend, "", fontSize_Text, dColor, xx2+25, xx2, yy);
   SetArrowObject(iWindow, iLabelCorner, sObject + "a", ArrowCode, 
                    iHeight, dColorArrow, xx2 + 7, yy);
   yy = yy + yStep+2;
   //-- 2 and 3 pair
   dColor = Orange;
   Write_Label(iWindow, iLabelCorner, sObject, sText1, "", fontSize_Text, dColor, xx2, xx2, yy); yy = yy + yStep;
   Write_Label(iWindow, iLabelCorner, sObject, sText2, "", fontSize_Text, dColor, xx2, xx2, yy); yy = yy + yStep;
}

//+------------------------------------------------------------------+
//    Draw Threshold Lines
//+------------------------------------------------------------------+
void Write_WinLossTrading(string Symbol1, string Symbol2)
{
   if(nOpenOrders1==0 && nOpenOrders2==0) return;
   double dBid1 = MarketInfo(Symbol1, MODE_BID);
   double dAsk1 = MarketInfo(Symbol1, MODE_ASK);
   double dBid2 = MarketInfo(Symbol2, MODE_BID);
   double dAsk2 = MarketInfo(Symbol2, MODE_ASK);
   
//---- TEST -----   
//dBid1 = 1.5651;   
//dBid2 = 1.0323;
   
   double dTicksValue1 = MarketInfo(Symbol1, MODE_TICKVALUE);
   double dTicksValue2 = MarketInfo(Symbol2, MODE_TICKVALUE);
   double dTicksSize1 = MarketInfo(Symbol1, MODE_TICKSIZE);
   double dTicksSize2 = MarketInfo(Symbol2, MODE_TICKSIZE);
   double dPoint1 = MarketInfo(Symbol1, MODE_POINT);
   double dPoint2 = MarketInfo(Symbol2, MODE_POINT);
   double dLotSize1 = MarketInfo(Symbol1, MODE_LOTSIZE);
   double dLotSize2 = MarketInfo(Symbol2, MODE_LOTSIZE);   
   string sCurrency = AccountCurrency();

   iLabelCorner = 1;   
   double dWin1, dWin2, dWinPoints1, dWinPoints2, dWinPoints2Corrected,
          dWinCurrency1, dWinCurrency2, dExitPrice1, dExitPrice2;
   color dColor = Orange;
   WinLossPoints = 0;
   
   if (TradeDirection == 1) {
      dWin1 = dBid1 - EntryPrice1;
      dWin2 = dBid2 - EntryPrice2;
      dExitPrice1 = dBid1;
      dExitPrice2 = dBid2;
   } else
   if (TradeDirection == -1) {
      dWin1 = EntryPrice1 - dAsk1;
      dWin2 = EntryPrice2 - dAsk2;
      dExitPrice1 = dAsk1;
      dExitPrice2 = dAsk2;
   }
   
   //-- Trade info
   string sLotsInfo = "Lots: " + DoubleToStr(nLots1,2) + " and " + DoubleToStr(nLots2,2);
   string sPrice1 = Symbol1 + " (" + DoubleToStr(EntryPrice1,Digits1) + " / " + DoubleToStr(dExitPrice1,Digits1) + ")= ";
   string sPrice2 = Symbol2 + " (" + DoubleToStr(EntryPrice2,Digits2) + " / " + DoubleToStr(dExitPrice2,Digits2) + ")= ";

   //-- win/loss in currency
   if (dTicksSize1 != 0) dWinCurrency1 =  dWin1 * dTicksValue1 * nLots1 / dTicksSize1;
   if (dTicksSize2 != 0) dWinCurrency2 = dWin2 * dTicksValue2 * nLots2 / dTicksSize2;
   //-- or:
   //dWinCurrency1 = dWin1 * dTicksValue1 * nLots1 / dPoint1;
   //dWinCurrency2 = dWin2 * dTicksValue2 * nLots2 / dPoint2;   
   //dWinCurrency1 = dWin1 * dTicksValue1 * nLots1 * dLotSize1 * dTicksSize1;
   //dWinCurrency2 = dWin2 * dTicksValue2 * nLots2 * dLotSize2 * dTicksSize2;   

   WinLossCurrency = dWinCurrency1 + dWinCurrency2;
   
/*Print("dTicksValue1= ",dTicksValue1,"  dTicksValue2=",dTicksValue2);      
Print("nLots1= ",nLots1,"  nLots2=",nLots2);   
Print("dWin1= ",dWin1,"  dWin2=",dWin2);      
Print("ddWinCurrency1= ",dWinCurrency1,"  ddWinCurrency2=",dWinCurrency2);*/
   
   //-- win/loss in points
   if (nLots1 != 0) double FactorLots = nLots2 / nLots1;
   if (dPoints1 != 0) dWinPoints1 = dWin1 / dPoints1;
   if (dPoints2 != 0) dWinPoints2 = dWin2 / dPoints2; //-- attention here !
   dWinPoints2Corrected = dWinPoints2 * FactorLots;
   WinLossPoints = dWinPoints1 + dWinPoints2Corrected;   
   
   //-- trading results
   string sWinPoints1 = sPrice1 + DoubleToStr(dWinPoints1,0);
   string sWinPoints2 = sPrice2 + DoubleToStr(dWinPoints2,0);
   string sWinCorrected = "( " + DoubleToStr(dWinPoints2,0) + " x " + DoubleToStr(FactorLots,2) +
                          " = " + DoubleToStr(dWinPoints2Corrected,0) + " )";   
   string sWinCurrency1 = "wl " + Symbol1 + ": " + DoubleToStr(dWinCurrency1,2);
   string sWinCurrency2 = "wl " + Symbol2 + ": " + DoubleToStr(dWinCurrency2,2);   
   string sWinLossPoints = "sumWinLoss: " + DoubleToStr(WinLossPoints,0);
   string sWinLossCurrency = "sumWinLoss: " + DoubleToStr(WinLossCurrency,2);
   
   //-- write results   
   //======================================================
   yy = yy + yStep;
   Write_Label(iWindow, iLabelCorner, sObject, sLotsInfo, "", fontSize_Text, dColor, xx2, xx2, yy); yy = yy + yStep;
   Write_Label(iWindow, iLabelCorner, sObject, "--TRADE / Pips--  ", "", fontSize_Text, dColor, xx2, xx2, yy); yy = yy + yStep;
   Write_Label(iWindow, iLabelCorner, sObject, sWinPoints1, "", fontSize_Text, dColor, xx2, xx2, yy); yy = yy + yStep;
   Write_Label(iWindow, iLabelCorner, sObject, sWinPoints2, "", fontSize_Text, dColor, xx2, xx2, yy); yy = yy + yStep;
   Write_Label(iWindow, iLabelCorner, sObject, sWinCorrected, "", fontSize_Text, dColor, xx2, xx2, yy); yy = yy + yStep;
   Write_Label(iWindow, iLabelCorner, sObject, sWinLossPoints, "", fontSize_Text, dColor, xx2, xx2, yy); yy = yy + yStep;
   
   Write_Label(iWindow, iLabelCorner, sObject, "--"+sCurrency+"--       ", "", fontSize_Text, dColor, xx2, xx2, yy); yy = yy + yStep;   
   Write_Label(iWindow, iLabelCorner, sObject, sWinCurrency1, "", fontSize_Text, dColor, xx2, xx2, yy); yy = yy + yStep;
   Write_Label(iWindow, iLabelCorner, sObject, sWinCurrency2, "", fontSize_Text, dColor, xx2, xx2, yy); yy = yy + yStep;   
   Write_Label(iWindow, iLabelCorner, sObject, sWinLossCurrency, "", fontSize_Text, dColor, xx2, xx2, yy); yy = yy + yStep;
}


//+------------------------------------------------------------------+
//    Get Order Lots
//+------------------------------------------------------------------+
void Get_OrderLots()
{  
   //-- calculated lots
   if (LotsRatio == 0) {
      nLots1 = Lots;
      if (Price2 != 0) LotsRatio = Price1 / Price2;
      nLots2 = nLots1 * LotsRatio;
      nLots2 = NormalizeDouble(nLots2,DigitsLot);
   } else 
   //-- default lots
   {
      nLots1 = Lots;
      nLots2 = nLots1 * LotsRatio;
      nLots2 = NormalizeDouble(nLots2,DigitsLot);
   }
/*
   orderLots = 0.01;
   return;

   double minLots   = MarketInfo(Symbol(), MODE_MINLOT);
   double TickValue = MarketInfo(Symbol(), MODE_TICKVALUE); // std Account
   
   double TickValueAccount  = TickValue * minLots;   
   double TickSize  = MarketInfo(Symbol(), MODE_TICKSIZE);
      
   double Balance   = AccountBalance();
   double RiscTitle = (Balance / nTitles) * (RiscFactor/100);
   double dATR = iATR(Symbol(),Period(),Period_ATR,1);
   double dATRPoints = dATR / TickSize;
   double RiscATR   = dATRPoints * TickValueAccount;
   
   double nLots = RiscTitle / (ATRFactor*RiscATR);
   nLots = 0.1 * nLots  / maxOpenOrders;
   
   if (minLots == 1.0)  orderLots = NormalizeDouble(nLots,0);
   if (minLots == 0.10) orderLots = NormalizeDouble(nLots,1);
   if (minLots == 0.01) orderLots = NormalizeDouble(nLots,2);
   return;*/
}


//+------------------------------------------------------------------+
//    Send Trade Alert
//+------------------------------------------------------------------+
void Send_TradeAlert(int iOrder1, double dRatio, int alertType, string text)
{
   string alert_text;

   string subject = sNameEA; //"(SpielersHedge_EAv6)";
   string sRatio = DoubleToStr(dRatio,3) + "%";
   
   //-- Entry orders
   if (alertType == alert_Entry) {
      if (iOrder1 == OP_BUY) string sOrder ="buy  "; else sOrder = "sell  ";
      alert_text = sOrder + Symbol1 + " and " + Symbol2 +
                   "  ratio: " + sRatio;
   } else 
   //-- Exit orders
   {
      sOrder = "close  ";
      alert_text = sOrder + Symbol1 + " and " + Symbol2 +
                   "  ratio: " + sRatio;
   }       
   alert_text = alert_text + "  " + text;
   
   //-- alert
   if (Send_Alert) {     
      Alert(alert_text + "  " + subject);
      AlertSended = false;
   }
   
   //-- eMail   
   if (Send_Mail) {
      SendMail(subject, alert_text);
   }

   //-- PlaySound  
   if (Play_Sound) {
      PlaySound("alert2.wav"); Sleep(1000);
      PlaySound("news.wav"); Sleep(1000);
      PlaySound("expert.wav");  Sleep(1000);
      PlaySound("hb.wav");  Sleep(1000);
      PlaySound("email.wav");  Sleep(3000);
      PlaySound("hb.wav");  Sleep(1000);      
      PlaySound("alert.wav");  Sleep(1000);
   }
}

//+------------------------------------------------------------------+
//    Test Info Writing
//+------------------------------------------------------------------+
void Test_InfoWriting()
{
   
   nOpenOrders1 = 1;
   nOpenOrders2 = 1;
   nLots1 = 1;
   nLots2 = 1.6;
        
   //-- test inputs
   TradeDirection = -1;
   EntryPrice1 = 1.5685;
   EntryPrice2 = 1.0273;
   
   Diff3 = 0.63;
   iTradingLevel = 2;
   
   
   //-- threshold lines
   timeLastClose3 = iTime(Symbol3, PERIOD_D1, ShiftDays_ForReference);
   Draw_ThresholdLines(sObject, iWindow, lastClose3, LevelValue, EntryLongValue, EntryShortValue, timeLastClose3);      
   
   CalculateIndicators();
   
   //-- write infos   
   Write_InfoIndicators(Symbol1, Symbol2, Symbol3);
   Write_WinLossTrading(Symbol1, Symbol2);
   Write_CurrentRange();
   
   //-- comment
   Show_Comment();
}


//+------------------------------------------------------------------+
//    Show Comment
//+------------------------------------------------------------------+
void Show_Comment()
{
   string st;
   string sShiftDays = "ShiftDays=" + ShiftDays_ForReference +"\n";
   string sLevels = "Levels: " + DoubleToStr(LevelValue[1],2)+"%";
   if (LevelValue[2] > 0) 
      sLevels = sLevels + ", " + DoubleToStr(LevelValue[2],2)+"%";
   if (LevelValue[3] > 0) 
      sLevels = sLevels + ", " + DoubleToStr(LevelValue[3],2)+"%";
   if (LevelValue[4] > 0) 
      sLevels = sLevels + ", " + DoubleToStr(LevelValue[4],2)+"%";
   sLevels = sLevels + "\n";
   if (TradeDirection == 1) string sTradeDirection=" long"; else sTradeDirection = " short";
   //-- lots ratio
   double dLotsRatio = iClose(Symbol1, Period(), 0) / iClose(Symbol2, Period(), 0);
   dLotsRatio = NormalizeDouble(dLotsRatio,DigitsLot);
   string sLotsRatio = DoubleToStr(dLotsRatio,2);
   
   //-- trading level   
   string sTradingLevel = "TradingLevel=" + iTradingLevel;
   if (Diff3> 0 ) sTradingLevel = sTradingLevel + " at +" + DoubleToStr(Diff3,3) + "%"; 
   else           sTradingLevel = sTradingLevel + " at " + DoubleToStr(Diff3,3) + "%";
   
   //---- next Entry   
   //-- long
   if (TradeDirection == 1) {
      if (iTradingLevel < 4) {
         string sNextEntry = "nextLongEntry: " + DoubleToStr(EntryLongValue[iTradingLevel+1], Digits); 
         sNextEntry = sNextEntry + " at " + DoubleToStr(-LevelValue[iTradingLevel+1],2)+"%";
      } else sNextEntry = "nextLongEntry: none";
   } else {
   //-- short   
   if (TradeDirection == -1)
      if (iTradingLevel < 4) {
         sNextEntry = "nextShortEntry: " + DoubleToStr(EntryShortValue[iTradingLevel+1], Digits);
         sNextEntry = sNextEntry + " at +" + DoubleToStr(LevelValue[iTradingLevel+1],2)+"%";
      } else sNextEntry = "nextShortEntry: none";
   }         
   
   //-- write text
   st = TimeToStr(TimeCurrent()) +"\n";
   st = st + sShiftDays;
   st = st + sLevels;
   st = st + "nOpenOrders1=" + nOpenOrders1 +"\n";
   st = st + "nOpenOrders2=" + nOpenOrders2 +"\n";
   st = st + sTradingLevel +"\n";
   st = st + "TradeDirection=" + sTradeDirection +"\n";
   st = st + sNextEntry +"\n";
   st = st + "LotsRatio=" + sLotsRatio +"\n";
   
   Comment(st);
}   


//+------------------------------------------------------------------+
//    Write Current Range
//+------------------------------------------------------------------+
void Write_CurrentRange()
{
   int iTextCorner = 0;
   double fontFactor = 1.0;
   if (CurrentRange > 0) 
      color TextColor = Red ; else    // short trade
            TextColor = DeepSkyBlue;  // long trade
   //-- x position
   datetime xx = iTime(Symbol(),Period(),shiftPosition_Divergence);
   //-- y position
   if (CurrentRange>0) {
      string sign = "+";
   } else {
      sign = "";
   }   
   
   double yy = iClose(Symbol(),Period(),0);
   string text = "                " + sign + DoubleToStr(CurrentRange,3)+ "%";
   Write_Text(sObject+"Range", text, iWindow, iTextCorner, xx, yy, fontSize_Divergence, TextColor);
}   



//####################################################################
//+------------------------------------------------------------------+
//    Start Trade Immediately
//+------------------------------------------------------------------+
void Try_Start_TradeImmediately()
{ 
   CalculateIndicators();
   Get_TradingLevel();
   Check_ActiveOrders(Symbol1, Symbol2, Magic);
   
   int iOrder1 = -1, iOrder2 = -1;
   double sign;
   bool TradingOK = false;
 
   if (iTradingLevel >= 4) return;
   if (iTradingLevel == 0) return;
   
   if (TradeDirection == 1) 
        sign = -1; // LONG (Diff1 < 0)
   else sign =  1; // SHORT (Diff1 > 0)  
 
   if (nOpenOrders1 == 0 && nOpenOrders2 == 0) {
      //-- long
      if (TradeDirection == 1) {
         iOrder1 = OP_BUY;
         iOrder2 = OP_BUY;
         newDivergenceLimit = LevelValue[iTradingLevel + 1] * sign;         
         Send_TradeAlert(OP_BUY, Diff3, alert_Entry, "");
      } else
      //-- short
      if (TradeDirection == -1) {
         iOrder1 = OP_SELL;
         iOrder2 = OP_SELL;
         newDivergenceLimit = LevelValue[iTradingLevel + 1] * sign;
         Send_TradeAlert(OP_SELL, Diff3, alert_Entry, "");
      }
      TradingOK = true;
   } else
      return;

   if (TradingOK == false) return;
   
   //-- set orders ...................................................   
   Get_OrderLots();
   //-- LONG trade
   if (TradeDirection == 1) {
      if (iOrder1 >= 0 && iOrder2 >= 0)
         Send_MarketOrderTwoPairs(Symbol1, iOrder1, nLots1,  Symbol2, iOrder2, nLots2);   
   }                            
   //-- SHORT trade
   if (TradeDirection == -1) {   
      if (iOrder1 >= 0 && iOrder2 >= 0)
         Send_MarketOrderTwoPairs(Symbol1, iOrder1, nLots1,  Symbol2, iOrder2, nLots2);   
   }   
      
   Sleep(500);
   Check_ActiveOrders(Symbol1, Symbol2, Magic);

//-- write infos
   Write_InfoIndicators(Symbol1, Symbol2, Symbol3);
   Write_WinLossTrading(Symbol1, Symbol2);   
   
   timeLastClose3 = iTime(Symbol3, PERIOD_D1, ShiftDays_ForReference);
   Draw_ThresholdLines(sObject, iWindow, lastClose3, LevelValue, EntryLongValue, EntryShortValue,timeLastClose3);
  
   Write_CurrentRange();
   
   Show_Comment();      
}