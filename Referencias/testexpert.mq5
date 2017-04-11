//+------------------------------------------------------------------+
//|                                                   TestExpert.mq5 |
//|                                  2009, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Constants                                                        |
//+------------------------------------------------------------------+
#define DAY 86400 // Number of seconds in a day
int days_in_month[12] = {31,28,31,30,31,30,31,31,30,31,30,31}; // number of days in a month

//+------------------------------------------------------------------+
//| Enumerations                                                     |
//+------------------------------------------------------------------+
enum lot_type
  {
   fixed,  // Fixed
   percent // Percentage of deposit
  };

enum   wdr_period
  {
   days      = -2, // Day
   weeks     = -1, // Week 
   months    =  1, // Month  
   quarters  =  3, // Quarter
   halfyears =  6, // Half a year    
   years     = 12  // Year    
  };

enum opt_value
{
   opt_total_wdr,      // Total amount of withdrawal
   opt_edd_with_wdr,   // Drawdown with consideration of withdrawal 
   opt_edd_without_wdr // Drawdown without consideration of withdrawal 
};  


//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input string     General        = "=== Main parameters ===";
input ushort     PERIOD         =     250; // Period of calculation
input ushort     STOP_LOSS      =      80; // Stop Loss level 
input ushort     TAKE_PROFIT    =      80; // Take Profit level
input ushort     INSIDE_LEVEL   =      40; // Level of returning inside the channel
input ushort     TRAILING_STOP  =      15; // Step of moving Stop Loss
input ushort     ORDER_STEP     =      10; // Step of moving of order
input ushort     SLIPPAGE       =       2; // Slippage
input double     LOT            =       5; // Lot size
input lot_type   LOT_TYPE       = percent; // Type of lot for trading
input bool       LOT_CORRECTION =   false; // Correction of the lot size
input bool       WRITE_LOG_FILE =   false; // Writing a log file
input ushort     MAGIC_NUMBER   =     867; // Unique number of the Expert Advisor
input opt_value  OPT_PARAM      = opt_total_wdr; // Optimization by the parameter

input string     WithDrawal     = "=== Parameters for WithDrawal ===";
input bool       WDR_ENABLE     =    true; // Allow withdrawal of assets
input wdr_period WDR_PERIOD     =   weeks; // Periodicity of withdrawals
input double     WDR_VALUE      =       1; // Amount of money to be withdrawn
input lot_type   WDR_TYPE       = percent; // Method of calculation of the withdrawal size

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
ulong stop_loss;          // Stop Loss
ulong take_profit;        // Take Profit
ulong inside_level;       // Value of returning of price inside the channel
ulong trailing_stop;      // Step of Trailing Stop
ulong order_step;         // Step of moving of order
ulong slippage;           // Slippage
double lot;               // Lot

bool buy_open    = false; // Flag of necessity of opening a buy position
bool sell_open   = false; // Flag of necessity of opening a sell position
double CalcHigh  = 0;     // level of resistance
double CalcLow   = 0;     // level of support
double High[], Low[];     // arrays of High and Low values

MqlTick tick;             // current quote
MqlTick first_tick;       // first quote 
MqlTradeRequest request;  // parameters of trade request
MqlTradeResult result;    // result of trade request

double order_open_price;  // price of order opening
double spread;            // spread value
ulong stop_level;         // minimum distance from price for setting stop loss/take profit
ulong order_type;         // order type
ulong order_ticket;       // order ticket 
datetime dt_debit;        // last time of withdrawing assets from the account
double wdr_summa;         // total amount of withdrawals from the account
double wdr_value;         // amount of withdrawal 
ushort wdr_count;         // number of withdrawal operations
bool wdr_ignore;          // calculation of report rates without consideration of withdrawal
double initial_deposit;   // initial deposit

int hReportFile;          // handle of the report file
int hLogFile;             // handle of the log file
uint days_delay;

//+------------------------------------------------------------------+
//| Variables for forming the report                                 |
//+------------------------------------------------------------------+
double SummaryProfit;     // total net profit
double GrossProfit;       // gross profit
double GrossLoss;         // Gross loss
double ProfitFactor;      // Profit factor
double RelEquityDrawdownPercent; // Relative drawdown of equity (%)
double MaxEquityDrawdown; // Maximum drawdown of equity

//+------------------------------------------------------------------+
int OnInit()
//+------------------------------------------------------------------+
 {
   //--- Validation of input parameters
   if((LOT_TYPE == percent)&&(LOT > 100))
    {
      Print("Specify a correct value of lot: ",LOT,". Range: 0 - 100 %");
      return(-1);
    }

   if(WDR_ENABLE && (WDR_TYPE==percent) && (WDR_VALUE>100))
     {
      Print("Specify a correct amount of assets to be withdrawn: ",WDR_VALUE,". Range: 0 - 100 %");
      return(-1);
     }
   
   //---
   stop_loss      = STOP_LOSS;
   take_profit    = TAKE_PROFIT;
   inside_level   = INSIDE_LEVEL;
   trailing_stop  = TRAILING_STOP;
   slippage       = SLIPPAGE;
   order_step     = ORDER_STEP;

   //--- Если цена состоит из 3-x / 5-и цифр
   if((_Digits==3)||(_Digits==5))
     {
      stop_loss      = stop_loss     * 10;
      take_profit    = take_profit   * 10;
      inside_level   = inside_level  * 10;
      trailing_stop  = trailing_stop * 10;
      slippage       = slippage      * 10;
      order_step     = order_step    * 10;
     }

   //--- Initialization of variables
  
   wdr_summa = 0;
   wdr_count = 0;
   wdr_value = 0;
   initial_deposit = AccountInfoDouble(ACCOUNT_BALANCE);
   
   SymbolInfoTick(_Symbol, first_tick);
   dt_debit = first_tick.time;
   days_delay = Calc_Delay();
   
   wdr_ignore = false;
   if (OPT_PARAM == opt_edd_without_wdr) wdr_ignore = true;

   //--- Initialization of variables for the report
   SummaryProfit = 0;
   GrossProfit   = 0;
   GrossLoss     = 0;
   ProfitFactor  = 0;
   RelEquityDrawdownPercent = 0;
   MaxEquityDrawdown = 0;

   if(WRITE_LOG_FILE)
    {
      //--- Opening a file for writing the log
      if(!OpenLogFile("log.txt"))
       {   
         Print("Failed to create log.txt");
         return(-1);
       }
    }
   return(0);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
//+------------------------------------------------------------------+
  {
      if(WRITE_LOG_FILE) CloseLogFile();
  }

//+------------------------------------------------------------------+
void OnTick()
//+------------------------------------------------------------------+
  {
   //--- Recalculation of parameters at every tick
   if(SymbolInfoTick(_Symbol, tick)) 
     {
      CalcHigh = 0;
      CalcLow  = 0;

      //--- Checking the presence of price data for the M5 timeframe
      if(Bars(_Symbol, PERIOD_M5) < PERIOD)
        {
         printf("Not enough price data for trading");
         return;
        }

      else//--- Getting arrays of High and Low
      if((CopyHigh(_Symbol, PERIOD_M5, 0, PERIOD, High) == PERIOD)&&(CopyLow(_Symbol, PERIOD_M5, 0, PERIOD, Low) == PERIOD))
       {
         CalcHigh = High[0];
         CalcLow  = Low[0];

         //--- Determining maximum and minimum
         for(int j=1; j < PERIOD; j++)
          {
            if(CalcHigh < High[j]) CalcHigh = High[j];
            if(CalcLow  >  Low[j]) CalcLow  = Low[j];
          }
       }

      //--- Exit if CalcHigh and CalcLow are not calculated
      if(CalcHigh < 0.01 || CalcLow < 0.01) return;

      //--- Updating parameters
      stop_level = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
      spread = tick.ask - tick.bid;
      if(order_step < stop_level) order_step = stop_level;

      //--- Withdrawing assets and calculating drawdowns of equity
      if(TimeOfWithDrawal())
         CalcEquityDrawdown(initial_deposit, true);
      else 
         CalcEquityDrawdown(initial_deposit, false);
      
      //--- Conditions of returning inside the channel
      if(tick.bid <= (CalcHigh - inside_level * _Point)) buy_open  = true;
      if(tick.bid >= (CalcLow  + inside_level * _Point)) sell_open = true;

      //--- Processing of open orders
      WorkWithPositions();

      //--- Processing of pending orders
      WorkWithPendidngOrders();

      //--- Placing a new pending order for buying
      if(buy_open) OpenOrderBuyStop();

      //--- Placing a new pending order for selling
      if(sell_open) OpenOrderSellStop();

     }
   else Print("Failed to get SymbolInfoTick() information, error number=", GetLastError());

  }
  
//--- Placing pending order for buying
//+------------------------------------------------------------------+
void OpenOrderBuyStop(void)
//+------------------------------------------------------------------+
  {
   lot = Calculate_Lot(LOT, LOT_TYPE, ORDER_TYPE_BUY); //Don't specify ORDER_TYPE_BUY_STOP. This constant is not processed in OrderCalcMargin!

   request.price = NormalizeDouble(CalcHigh - order_step * _Point + spread, _Digits);

   //--- If the calculated value of price of order opening is too close to the market price, then correct the price of opening the order
   if(tick.ask + stop_level * _Point > request.price) request.price = tick.ask + stop_level * _Point;
  
   //--- Calculation of Stop Loss
   if(stop_loss == 0) request.sl = 0;
   else request.sl = NormalizeDouble(request.price - MathMax(stop_loss, stop_level) * _Point - spread, _Digits);
   
   //--- Calculation of Take Profit
   if(take_profit == 0) request.tp = 0;
   else request.tp = NormalizeDouble(request.price + MathMax(take_profit, stop_level) * _Point - spread, _Digits);

   request.action       = TRADE_ACTION_PENDING;
   request.symbol       = _Symbol;
   request.volume       = lot;
   request.deviation    = slippage;
   request.type         = ORDER_TYPE_BUY_STOP;
   request.type_filling = ORDER_FILLING_FOK;
   request.type_time    = ORDER_TIME_GTC;
   request.comment      = IntegerToString(MAGIC_NUMBER);
   request.magic        = MAGIC_NUMBER;

   OrderSend(request, result);
   if((result.retcode == 10009)||(result.retcode == 10008))
     {
      buy_open = false;
      WriteLogFile("Открыт ордер BuyStop #" + IntegerToString(result.order));
     }
   else
     {
      printf("Request for placing the BuyStop order is executed. Error code: %d", result.retcode);
      WriteLogFile("ERROR of opening BuyStop order, error code:" + IntegerToString(result.retcode));
     }
  }
  
//--- Placing pending order for selling
//+------------------------------------------------------------------+
void OpenOrderSellStop(void)
//+------------------------------------------------------------------+
  {
   lot = Calculate_Lot(LOT,LOT_TYPE, ORDER_TYPE_SELL); //Не указывайте ORDER_TYPE_SELL_STOP. This constant is not processed in OrderCalcMargin!

   request.price = NormalizeDouble(CalcLow + order_step * _Point, _Digits);
   //--- If the calculated value of price of order opening is too close to the market price, then correct the price of opening the order
   if(tick.bid - stop_level * _Point < request.price) request.price = tick.bid - stop_level * _Point;
   
   //--- Calculation of Stop Loss
   if(stop_loss == 0) request.sl = 0;
   else request.sl = NormalizeDouble(request.price + MathMax(stop_loss * _Point, stop_level * _Point) + spread, _Digits);
   
   //--- Calculation of Take Profit
   if(take_profit == 0) request.tp = 0;
   else request.tp = NormalizeDouble(request.price - MathMax(take_profit * _Point, stop_level * _Point) + spread, _Digits);

   request.action       = TRADE_ACTION_PENDING;
   request.symbol       = _Symbol;
   request.volume       = lot;
   request.deviation    = slippage;
   request.type         = ORDER_TYPE_SELL_STOP;
   request.type_filling = ORDER_FILLING_FOK;
   request.type_time    = ORDER_TIME_GTC;
   request.comment      = IntegerToString(MAGIC_NUMBER);
   request.magic        = MAGIC_NUMBER;

   OrderSend(request, result);

   if((result.retcode == 10009)||(result.retcode == 10008)) //request is executed
     {
      sell_open = false;
      WriteLogFile("SellStop order has been opened #" + IntegerToString(result.order));
     }
   else
     {
      printf("REquest for placing the Sell order is not executed, error code:", GetLastError());
      WriteLogFile("ERROR of opening the SellStop order#" + IntegerToString(result.order));
     }
  }
//--- Working with positions
//+------------------------------------------------------------------+
void WorkWithPositions(void)
//+------------------------------------------------------------------+
  {
   for(int pos = 0; pos < PositionsTotal(); pos++)
     {
      if(PositionSelect(PositionGetSymbol(pos)))
        {
         
         if((PositionGetInteger(POSITION_MAGIC) != MAGIC_NUMBER)||(PositionGetString(POSITION_SYMBOL) != _Symbol)) continue;

         order_open_price = PositionGetDouble(POSITION_PRICE_OPEN);
         order_type       = PositionGetInteger(POSITION_TYPE);
         request.order    = PositionGetInteger(POSITION_IDENTIFIER);

         if(order_type == POSITION_TYPE_BUY)
           {
            buy_open = false;
            
            //--- Close the order if the price reaches stop loss/take profit
            if(( NormalizeDouble(order_open_price - tick.ask, _Digits) >= stop_loss   * _Point)||
               ( NormalizeDouble(tick.ask - order_open_price, _Digits) >= take_profit * _Point))
              {
               request.action = TRADE_ACTION_DEAL;
               request.symbol = _Symbol;
               request.volume = PositionGetDouble(POSITION_VOLUME);
               request.price  = tick.bid;
               request.sl     = 0;
               request.tp     = 0;
               request.deviation = slippage;
               request.type   = ORDER_TYPE_SELL;
               request.type_filling = ORDER_FILLING_FOK;

               OrderSend(request, result);
               if((result.retcode == 10009)||(result.retcode == 10008)) //request is executed
                  WriteLogFile("Closed the Buy order #" + IntegerToString(request.order));
               else
                  WriteLogFile("ERROR of closing the Buy order #" + IntegerToString(request.order));
               continue;
              }

            // Trailing Stop
            if((stop_loss == 0)||(trailing_stop == 0))continue; // condition when the trailing stop doesn't work

            
            double sl = PositionGetDouble(POSITION_SL);
            if(tick.bid > sl + (stop_loss + trailing_stop) * _Point)
              {
               request.action = TRADE_ACTION_SLTP;
               request.symbol = _Symbol;
               request.sl     = sl + trailing_stop * _Point;
               request.tp     = PositionGetDouble(POSITION_TP);
               request.deviation = slippage;

               OrderSend(request, result);
               if((result.retcode == 10009)||(result.retcode == 10008)) //request is executed
                  WriteLogFile("Moving Stop Loss of the Buy order #" + IntegerToString(request.order));
               else
                  WriteLogFile("ERROR of moving Stop Loss of the Buy order #" + IntegerToString(request.order));
              }
           }// end POSITION_TYPE_BUY    

         else if(order_type == POSITION_TYPE_SELL)
           {
            sell_open = false;
            
            //--- Close the order if the price reaches stop loss/take profit
            if(( NormalizeDouble(order_open_price - tick.bid, _Digits) >= take_profit * _Point)||
               ( NormalizeDouble(tick.bid - order_open_price, _Digits) >= stop_loss   * _Point))
              {
               request.action    = TRADE_ACTION_DEAL;
               request.symbol    = _Symbol;
               request.volume    = PositionGetDouble(POSITION_VOLUME);
               request.price     = tick.ask;
               request.sl        = 0;
               request.tp        = 0;
               request.deviation = slippage;
               request.type      = ORDER_TYPE_BUY;
               request.type_filling = ORDER_FILLING_FOK;

               OrderSend(request, result);
               if((result.retcode == 10009)||(result.retcode == 10008)) //request is executed
                  WriteLogFile("Closed the Sell order #" + IntegerToString(request.order));
               else
                  WriteLogFile("ERROR of closing the Sell order#" + IntegerToString(request.order));
               continue;
              }

            //--- Trailing Stop
            if((stop_loss == 0)||(trailing_stop == 0)) continue;

            double sl = PositionGetDouble(POSITION_SL);
            if(tick.ask < sl - (stop_loss + trailing_stop) * _Point)
              {
               request.action = TRADE_ACTION_SLTP;
               request.symbol = _Symbol;
               request.sl     = sl - trailing_stop * _Point;
               request.tp     = PositionGetDouble(POSITION_TP);
               request.deviation = slippage;

               OrderSend(request, result);
               if((result.retcode == 10009)||(result.retcode == 10008)) //request is executed
                  WriteLogFile("Movin Stop Loss of Sell #"+IntegerToString(request.order));
               else
                  WriteLogFile("ERROR of moving Stop Loss of the Sell order#"+IntegerToString(request.order));
              }

           }// end POSITION_TYPE_SELL

        }// end if select                

     }// end for
  }

//--- Working with pending orders
//+------------------------------------------------------------------+
void WorkWithPendidngOrders(void)
//+------------------------------------------------------------------+
  {
   //--- Processing of pending orders
   for(int pos=0; pos < OrdersTotal(); pos++)
     {
      order_ticket = OrderGetTicket(pos);

      if(OrderSelect(order_ticket))
        {

         if((OrderGetInteger(ORDER_MAGIC) != MAGIC_NUMBER)||(OrderGetString(ORDER_SYMBOL) != _Symbol)) continue;

         order_type = OrderGetInteger(ORDER_TYPE);
         order_open_price = OrderGetDouble(ORDER_PRICE_OPEN);

         if(order_type == ORDER_TYPE_BUY_STOP)
           {
            buy_open = false;
            //--- Conditions of moving the pending order
            if(( NormalizeDouble(CalcHigh - order_step * _Point + spread, _Digits) < NormalizeDouble(order_open_price - order_step * _Point + spread, _Digits)) && 
               ( NormalizeDouble(CalcHigh - order_step * _Point + spread, _Digits) > tick.ask + stop_level * _Point))
              {

               request.price = NormalizeDouble(CalcHigh - order_step * _Point + spread, _Digits);

               if(stop_loss == 0) request.sl = 0;
               else request.sl = NormalizeDouble(CalcHigh - order_step * _Point - MathMax(stop_loss, stop_level) * _Point, _Digits);

               if(take_profit == 0) request.tp = 0;
               else request.tp = NormalizeDouble(CalcHigh - order_step * _Point + MathMax(take_profit, stop_level) * _Point, _Digits);

               request.action     = TRADE_ACTION_MODIFY;
               request.order      = order_ticket;
               request.type_time  = ORDER_TIME_GTC;
               request.expiration = 0;

               OrderSend(request, result);
               if((result.retcode == 10009)||(result.retcode == 10008))

                  WriteLogFile("Modified the BuyStop order#" + IntegerToString(result.order) +
                               StringFormat(" CalcLow=%1.5f order_step=%1.5f order_open_price=%1.5f bid=%1.5f stop_level=%1.5f",
                               CalcLow, order_step * _Point, order_open_price, tick.bid, stop_level * _Point));

               else
                  WriteLogFile("ERROR of modifying the BuyStop order#" + IntegerToString(result.order) +
                               StringFormat(" CalcLow=%1.5f order_step=%1.5f order_open_price=%1.5f bid=%1.5f stop_level=%1.5f err=%d",
                               CalcLow, order_step * _Point, order_open_price, tick.bid, stop_level * _Point, result.retcode));

              }
           }//end ORDER_TYPE_BUY_STOP  

         else if(order_type == ORDER_TYPE_SELL_STOP)
           {
            sell_open = false;
            
            //--- Conditions of moving the pending order
            if(( NormalizeDouble(CalcLow + order_step * _Point, _Digits) > order_open_price + order_step * _Point)&& 
               ( NormalizeDouble(CalcLow + order_step * _Point, _Digits) < tick.bid - stop_level * _Point))
              {
               request.price = NormalizeDouble(CalcLow + order_step * _Point, _Digits);

               if(stop_loss == 0) request.sl = 0;
               else request.sl = NormalizeDouble(request.price + MathMax(stop_loss * _Point, stop_level * _Point) + spread, _Digits);

               if(take_profit == 0) request.tp = 0;
               else request.tp = NormalizeDouble(request.price - MathMax(take_profit * _Point, stop_level * _Point) + spread, _Digits);

               request.action    = TRADE_ACTION_MODIFY;
               request.order     = order_ticket;
               request.type_time = ORDER_TIME_GTC;

               OrderSend(request, result);

               if((result.retcode == 10009)||(result.retcode == 10008))

                  WriteLogFile("Modified the SellStop order#"+IntegerToString(result.order) +
                               StringFormat(" CalcLow=%1.5f order_step=%1.5f order_open_price=%1.5f bid=%1.5f stop_level=%1.5f",
                               CalcLow, order_step * _Point, order_open_price, tick.bid, stop_level * _Point));
               else

                  WriteLogFile("ERROR of modifying the SellStop order#" + IntegerToString(result.order) +
                               StringFormat(" CalcLow=%1.5f order_step=%1.5f order_open_price=%1.5f bid=%1.5f stop_level=%1.5f",
                               CalcLow, order_step * _Point, order_open_price, tick.bid, stop_level * _Point));
              }

           }//end ORDER_TYPE_SELL_STOP   

        }// end order_ticket

     }// end for
  }

//--- Calculation of lot
//+------------------------------------------------------------------+
double Calculate_Lot(double lot,int type,ENUM_ORDER_TYPE direction)
//+------------------------------------------------------------------+
  {
   double acc_free_margin = AccountInfoDouble(ACCOUNT_FREEMARGIN);
   double calc_margin;
   double price;

   if(direction == ORDER_TYPE_BUY)  price = tick.ask;
   if(direction == ORDER_TYPE_SELL) price = tick.bid;

   switch(type)
     {
      case fixed:
        {
         if(LOT_CORRECTION)// Correction of the lot size
           {
            OrderCalcMargin(direction, _Symbol, lot, price, calc_margin);
            //--- correction of the lot size to 90% of free margin
            if(acc_free_margin < calc_margin)
              {
               lot = lot * acc_free_margin * 0.9 / calc_margin;
               printf("Corrected the lot value %f",lot);
              }
           }
         break;
        }

      case percent:
        {
         //--- amount of free margin for opening a position
         OrderCalcMargin(direction, _Symbol, 1, price,calc_margin);
         lot = acc_free_margin * 0.01 * LOT / calc_margin;
         break;
        }
     }// end switch

   return(NormalizeLot(lot));
  }

//--- normalization of lot size
//+------------------------------------------------------------------+
double NormalizeLot(double lot)
//+------------------------------------------------------------------+
  {
   double lot_min  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double lot_max  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lot_step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   int norm;

   if( lot <= lot_min ) lot = lot_min;               // check of minimal lot
   else if( lot >= lot_max ) lot = lot_max;          // check of maximal lot
   else(lot = MathFloor(lot / lot_step) * lot_step); // truncation to the closest smallest value

   norm = (int)NormalizeDouble(MathCeil(MathLog10( 1 / lot_step)), 0); //coefficient for NormalizeDouble
   return (NormalizeDouble(lot, norm));               // normalization of volume
  }

//--- Function for withdrawing assets from the account
//+------------------------------------------------------------------+
bool TimeOfWithDrawal()
//+------------------------------------------------------------------+
  {
   if(!WDR_ENABLE) return(false); // exit if withdrawal is prohibited
   
   if( tick.time > dt_debit + days_delay * DAY) // periodic withdrawals of the specified size
     {
      dt_debit = dt_debit + days_delay * DAY;
      days_delay = Calc_Delay();// Updating the value of period - number of days between withdrawals
      
      if(WDR_TYPE == fixed) wdr_value = WDR_VALUE;
      else wdr_value = AccountInfoDouble(ACCOUNT_BALANCE) * 0.01 * WDR_VALUE;

      if(TesterWithdrawal(wdr_value))
        {
         wdr_count++;
         wdr_summa = wdr_summa + wdr_value;
         return(true);
        }
     }
   return(false);
  }

//+------------------------------------------------------------------+
uint Calc_Delay()
//+------------------------------------------------------------------+
{
   int month;
   int delay;
   MqlDateTime mqldt_debit;
   
   TimeToStruct(dt_debit, mqldt_debit);// conversion of the last time to a structure

   //--- Calculation of period between withdrawals in days
   switch(WDR_PERIOD)
   {
      case  days: delay = 1; break;
      case weeks: delay = 7; break;
   
      case months:
      case quarters:
      case halfyears:
      case years:             
            
            delay = 0;   
            for(int i= -1; i<WDR_PERIOD-1; i++)
            {
               month = mqldt_debit.mon + i;
               if (month > 11) month = month - 12;
               delay = delay + days_in_month[month];
            }
            break;
   }// end switch
   return(delay);
}
  

//--- Opening log file 
//+------------------------------------------------------------------+
bool OpenLogFile(string file_name)
//+------------------------------------------------------------------+
  {
   ResetLastError();
   hLogFile = FileOpen(file_name, FILE_WRITE|FILE_TXT|FILE_ANSI);
   return(hLogFile != INVALID_HANDLE);
  }

//--- Writing to log file 
//+------------------------------------------------------------------+
void WriteLogFile(string text)
//+------------------------------------------------------------------+
  {
   if(WRITE_LOG_FILE) FileWrite(hLogFile, TimeToString(tick.time, TIME_DATE|TIME_SECONDS), " - ", text);
  }

//--- Closing log file
//+------------------------------------------------------------------+
void CloseLogFile()
//+------------------------------------------------------------------+
  {
   FileClose(hLogFile);
  }

//--- Displaying information about testing
//+------------------------------------------------------------------+
double OnTester(void)
//+------------------------------------------------------------------+
  {
   //--- Calculation of parameters for the report
   CalculateSummary(initial_deposit);
   CalcEquityDrawdown(initial_deposit, true);
   //--- Creation of the report
   GenerateReportFile("report.txt");
   
   //--- Returned value it the optimization criterion
   if (OPT_PARAM == opt_total_wdr) return(wdr_summa);
   else return(RelEquityDrawdownPercent);
  }

//--- Calculation of parameters for the report
//+------------------------------------------------------------------+
void CalculateSummary(double initial_deposit)
//+------------------------------------------------------------------+
  {
   double drawdownpercent, drawdown;
   double maxpeak = initial_deposit, 
          minpeak = initial_deposit, 
          balance = initial_deposit;
          
   double profit = 0.0;
   
   //--- Select the entire history
   HistorySelect(0, TimeCurrent());
   int trades_total = HistoryDealsTotal();

   //--- search all deals in the history
   for(int i=0; i < trades_total; i++)
     {
      long ticket = HistoryDealGetTicket(i);
      long type   = HistoryDealGetInteger(ticket, DEAL_TYPE);

      //--- Initial deposit is not considered
      if((i == 0)&&(type == DEAL_TYPE_BALANCE)) continue;

      //--- Calculation of profit
      profit  = HistoryDealGetDouble(ticket, DEAL_PROFIT) + HistoryDealGetDouble(ticket, DEAL_COMMISSION) + HistoryDealGetDouble(ticket, DEAL_SWAP);
      balance += profit;

      if(minpeak > balance) minpeak = balance;

      //---
      if((!wdr_ignore)&&(type != DEAL_TYPE_BUY)&&(type != DEAL_TYPE_SELL)) continue;

      //---
      if(profit < 0) GrossLoss   += profit;
      else           GrossProfit += profit;
      SummaryProfit += profit;
     }

   if(GrossLoss < 0.0) GrossLoss *= -1.0;
   //--- Profitability
   if(GrossLoss > 0.0) ProfitFactor = GrossProfit / GrossLoss;
  }

//--- Расчет просадок по средствам
//+------------------------------------------------------------------+
void CalcEquityDrawdown(double initial_deposit, // initial deposit 
                        bool finally)           // flag of calculation that registers extremums
//+------------------------------------------------------------------+
  {
   double drawdownpercent;
   double drawdown;
   double equity;
   static double maxpeak = 0.0, minpeak = 0.0;
   

   //--- excluding the withdrawals of profit for the calculation of drawdowns
   if(wdr_ignore) equity = AccountInfoDouble(ACCOUNT_EQUITY) + wdr_summa;
   else equity = AccountInfoDouble(ACCOUNT_EQUITY);

   if(maxpeak == 0.0) maxpeak = equity;
   if(minpeak == 0.0) minpeak = equity;

   //--- check of extremum condition
   if((maxpeak < equity)||(finally))
    {
      //--- calculation of drawdowns
      drawdown = maxpeak - minpeak;
      drawdownpercent = drawdown / maxpeak * 100.0;

      //--- Saving maximum values of drawdowns
      if(MaxEquityDrawdown < drawdown) MaxEquityDrawdown = drawdown;
      if(RelEquityDrawdownPercent < drawdownpercent) RelEquityDrawdownPercent = drawdownpercent;
    
      //--- nulling values of extremums
      maxpeak = equity;
      minpeak = equity;
    }

   if(minpeak > equity) minpeak = equity;
 }

//--- Forming the report  
//+------------------------------------------------------------------+
void GenerateReportFile(string filename)
//+------------------------------------------------------------------+
  {
   string str, msg;

   ResetLastError();
   hReportFile = FileOpen(filename, FILE_READ|FILE_WRITE|FILE_TXT|FILE_ANSI);
   if(hReportFile != INVALID_HANDLE)
     {

      StringInit(str,65,'-'); // separator

      WriteToReportFile(str);
      WriteToReportFile("| Period if testing: " + TimeToString(first_tick.time, TIME_DATE) + " - " +
                        TimeToString(tick.time,TIME_DATE) + "\t\t\t|");
      WriteToReportFile(str);

      //----
      WriteToReportFile("| Initial deposit \t\t\t"+DoubleToString(initial_deposit, 2));
      WriteToReportFile("| Total net profit    \t\t\t"+DoubleToString(SummaryProfit, 2));
      WriteToReportFile("| Gross profit     \t\t\t"+DoubleToString(GrossProfit, 2));
      WriteToReportFile("| Gross loss      \t\t\t"+DoubleToString(-GrossLoss, 2));
      if(GrossLoss > 0.0)
         WriteToReportFile("| Profitability       \t\t\t"+DoubleToString(ProfitFactor,2));
      WriteToReportFile("| Relative drawdown of equity \t"+
                        StringFormat("%1.2f%% (%1.2f)", RelEquityDrawdownPercent, MaxEquityDrawdown));

      if(WDR_ENABLE)
        {
         StringInit(msg, 10, 0);
         switch(WDR_PERIOD)
           {
            case days:     msg = "day";    break;
            case weeks:    msg = "week";  break;
            case months:   msg = "month";   break;
            case quarters: msg = "quarter"; break;
            case years:    msg = "year";     break;
           }

         WriteToReportFile(str);
         WriteToReportFile("| Periodicity of outputting       \t\t" + msg);

         if(WDR_TYPE == fixed) msg = DoubleToString(WDR_VALUE, 2);
         else msg = DoubleToString(WDR_VALUE, 1) + " % from deposit " + DoubleToString(initial_deposit, 2);

         WriteToReportFile("| Amount of withdrawn assets     \t\t" + msg);
         WriteToReportFile("| Number of withdrawal operations \t\t" + IntegerToString(wdr_count));
         WriteToReportFile("| Withdrawn from the account          \t\t" + DoubleToString(wdr_summa, 2));
        }

      WriteToReportFile(str);
      WriteToReportFile(" ");

      FileClose(hReportFile);
     }
  }

//--- Writing line to the report file
//+------------------------------------------------------------------+
void WriteToReportFile(string text)
//+------------------------------------------------------------------+
  {
   FileSeek(hReportFile, 0, SEEK_END);
   FileWrite(hReportFile, text);
  }
