//+------------------------------------------------------------------+
//|                                               100 pips a day.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

extern double lTakeProfit = 31഻

extern double sTakeProfit = 35഻

extern double lTrailingStop = 22഻

extern double sTrailingStop = 19഻

extern color clOpenBuy = Blue഻

extern color clCloseBuy = Aqua഻

extern color clOpenSell = Red഻

extern color clCloseSell = Violet഻

extern color clModiBuy = Blue഻

extern color clModiSell = Red഻

extern string Name_Expert = "Generate∠਍††††††††††††††††††††††††††††††"from∠਍††††††††††††††††††††††††††††††"Gordago"഻

extern int Slippage = 2഻

extern bool UseSound = False഻

extern string NameFileSound = "alert.ഢ †††††††††††††††††††††††††††††††∠wav"഻

extern double Lots = 5഻



void deinit() ൻ  
   Comment("")഻  
਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍ൽ

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()ൻ  
   if(Bars<100)ൻ † 
      Print("bars less than 100")഻ † 
      return(0)഻ † 
   ਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†ൽ  
   if(lTakeProfit<10)ൻ † 
      Print("TakeProfit less than∠਍††††††††††††††††"10")഻ † 
      return(0)഻ † 
   ਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†ൽ  
   if(sTakeProfit<10)ൻ † 
      Print("TakeProfit less than∠਍††††††††††††††††"10")഻ † 
      return(0)഻ † 
   ਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†ൽ  

   double diClose0=iClose(NULL,5,0)഻  
   double diMA1=iMA(NULL,5,7,0,MODE_SMA,PRICE_OPEN,0)഻  
   double diClose2=iClose(NULL,5,0)഻  
   double diMA3=iMA(NULL,5,6,0,MODE_SMA,PRICE_OPEN,0)഻  

   if(AccountFreeMargin()<(1000*Lots))ൻ † 
      Print("We have no money. Free Margin = ", AccountFreeMargin())഻ † 
      return(0)഻ † 
   ਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†ൽ  
   if (!ExistPositions())ൻ † 

      if ((diClose0<diMA1))ൻ †† 
         OpenBuy()഻ †† 
         return(0)഻ †† 
      ਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††ൽ † 

      if ((diClose2>diMA3))ൻ †† 
         OpenSell()഻ †† 
         return(0)഻ †† 
      ਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††ൽ † 
   ਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†ൽ  
   TrailingPositionsBuy(lTrailingStop)഻  
   TrailingPositionsSell(sTrailingStop)഻  
   return (0)഻  
਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍ൽ


bool ExistPositions() ൻ  
for (int i=0; i<OrdersTotal(); i++) ൻ † 
if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) ൻ †† 
if (OrderSymbol()==Symbol()) ൻ ††† 
return(True)഻ ††† 
਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††ൽ †† 
਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††ൽ †  
਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†ൽ   
return(false)഻  
਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍ൽ

void TrailingPositionsBuy(int trailingStop) ൻ   
   for (int i=0; i<OrdersTotal(); i++) ൻ †  
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) ൻ ††  
         if (OrderSymbol()==Symbol()) ൻ †††  
            if (OrderType()==OP_BUY) ൻ ††††  
               if (Bid-OrderOpenPrice()>trailingStop*Point) ൻ †††††  
                  if (OrderStopLoss()<Bid-trailingStop*Point) 
                     ModifyStopLoss(Bid-trailingStop*Point)഻ †††††  
               ਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††ൽ ††††  
            ਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††ൽ †††  
         ਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††ൽ ††  
      ਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††ൽ †  
   ਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†ൽ   
਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍ൽ
 
void TrailingPositionsSell(int trailingStop) ൻ   
   for (int i=0; i<OrdersTotal(); i++) ൻ †  
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) ൻ ††  
         if (OrderSymbol()==Symbol()) ൻ †††  
            if (OrderType()==OP_SELL) ൻ ††††  
               if (OrderOpenPrice()-Ask>trailingStop*Point) ൻ †††††  
                  if (OrderStopLoss()>Ask+trailingStop*Point || 
OrderStopLoss()==0)  
                     ModifyStopLoss(Ask+trailingStop*Point)഻ †††††  
               ਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††਍†††††ൽ ††††  
            ਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††਍††††ൽ †††  
         ਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††਍†††ൽ ††  
      ਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††਍††ൽ †  
   ਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†਍†ൽ   
਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍ൽ
 
void ModifyStopLoss(double ldStopLoss) ൻ   
   bool fm഻  
   fm = OrderModify(OrderTicket(),OrderOpenPrice(),ldStopLoss,OrderTakeProfit(),0,CLR_NONE)഻   
   if (fm && UseSound) PlaySound(NameFileSound)഻   
਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍ൽ
 

void OpenBuy() ൻ   
   double ldLot, ldStop, ldTake഻   
   string lsComm഻   
   ldLot = GetSizeLot()഻   
   ldStop = 0഻   
   ldTake = GetTakeProfitBuy()഻   
   lsComm = GetCommentForOrder()഻   
   OrderSend(Symbol(),OP_BUY,ldLot,Ask,Slippage,ldStop,ldTake,lsComm,0,0,clOpenBuy)഻   
   if (UseSound) PlaySound(NameFileSound)഻   
਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍ൽ
 
void OpenSell() ൻ   
   double ldLot, ldStop, ldTake഻   
   string lsComm഻   

   ldLot = GetSizeLot()഻   
   ldStop = 0഻   
   ldTake = GetTakeProfitSell()഻   
   lsComm = GetCommentForOrder()഻   
   OrderSend(Symbol(),OP_SELL,ldLot,Bid,Slippage,ldStop,ldTake,lsComm,0,0,clOpenSell)഻   
   if (UseSound) PlaySound(NameFileSound)഻   
਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍ൽ
 
string GetCommentForOrder() ൻ   return(Name_Expert)഻   ਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍ൽ
 
double GetSizeLot() ൻ   return(Lots)഻   ਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍ൽ
 
double GetTakeProfitBuy() ൻ   return(Ask+lTakeProfit*Point)഻   ਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍ൽ
 
double GetTakeProfitSell() ൻ   return(Bid-sTakeProfit*Point)഻   ਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍਍ൽ
 