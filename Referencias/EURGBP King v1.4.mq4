#property copyright "Copyright © 2009, xux99"
#property link      "http://www.forex-tsd.com/expert-advisors-metatrader-4/13372-eurgbp-easy-profitable-ea.html"

extern string    Original_trade_settings="----------------------------------------------------------------------";
extern bool      OriginalTrade                               = true;
extern int       MagicNumber1                                = 111101;
extern string    Comment1                                    = "EURGBP King Original Trade";
extern double    StopLoss1                                   = 19;
extern double    TakeProfit1                                 = 5;
extern bool      HiddenSLandTP                               = true;
extern double    BreakEven1                                  = 0;
extern double    TrailingStop1                               = 0;
extern double    TrailingStep1                               = 0;
extern int       Slippage1                                   = 4;
extern double    LotMultiplier1                              = 1;
extern string    StartHour1                                  = "1700";
extern string    EndHour1                                    = "0700";
extern bool      CloseAllOrders                              = false;
extern string    CloseAllHour                                = "0800";
extern string    FridayNoTradeHour                           = "2400";
extern bool      ReentryAfterSL                              = true;
extern bool      OppositeDirectionAfterSL                    = false;
extern bool      ReentryAfterTP                              = true;
extern bool      OppositeDirectionAfterTP                    = false;

extern string    Additional_trade_settings="----------------------------------------------------------------------";
extern bool      AdditionalTrade                             = false;
extern int       MagicNumber2                                = 222202;
extern string    Comment2                                    = "EURGBP King Additional Trade";
extern bool      UsePendingOrder2                            = true;
extern double    Distance2                                   = 20;
extern double    StopLoss2                                   = 10;
extern double    TakeProfit2                                 = 14;
extern double    BreakEven2                                  = 0;
extern double    TrailingStop2                               = 0;
extern double    TrailingStep2                               = 0;
extern int       Slippage2                                   = 4;
extern double    LotMultiplier2                              = 2;
extern bool      DeleteAfterEndHour2                         = true;
extern bool      DeleteIfOriginalClosed                      = true;
extern string    StartHour2                                  = "1700";
extern string    EndHour2                                    = "0700";

extern string    Hedge_trade_settings="----------------------------------------------------------------------";
extern bool      HedgeTrade                                  = false;
extern int       MagicNumber3                                = 333303;
extern string    Comment3                                    = "EURGBP King Hedge Trade";
extern bool      UsePendingOrder3                            = true;
extern double    Distance3                                   = 14;
extern double    StopLoss3                                   = 15;
extern double    TakeProfit3                                 = 25;
extern double    BreakEven3                                  = 0;
extern double    TrailingStop3                               = 0;
extern double    TrailingStep3                               = 0;
extern int       Slippage3                                   = 4;
extern double    LotMultiplier3                              = 3;
extern string    StartHour3                                  = "1700";
extern string    EndHour3                                    = "0700";

extern string    Money_management_settings="----------------------------------------------------------------------";
extern double    Lots                                        = 0.1;
extern double    MaxLots                                     = 99;
extern bool      MoneyManagement                             = false;
extern bool      AllowMicro                                  = false;
extern double    LeveragePercent                             = 1.0;

extern string    RSI_settings="----------------------------------------------------------------------";
extern bool      ClosedBarSignal                             = false;
extern double    RSI_Period                                  = 14;
extern double    RSI_TF                                      = 5;
extern double    RSI_Buy                                     = 30;
extern double    RSI_Sell                                    = 70;
extern double    RSI_Buy_Reset                               = 40;
extern double    RSI_Sell_Reset                              = 60;

//+------------------------------------------------------------------+

bool EnableBuy[3],EnableSell[3],TradingTime[4],Trade[4];
double Slippage[4],OrderOpenPrice1,OTakeProfit[4],OStopLoss[4],TakeProfit[4],StopLoss[4],TrailingStop[4],TrailingStep[4],BreakEven[4],Distance[4],MinSL,RSI;
string Screen[9][9],AccountType,gvoop[4],gvoot[4];
int MagicNumber[4],OType[4],LongArrow[4],ShortArrow[4],OTicket[4],OOpenTime[4],StartHour[5],EndHour[6],ServerTime,mult,d,i1,i2,i3,i4,i8,i9,z,v;

//+------------------------------------------------------------------+

int init()
{
mult=(Digits==3 || Digits==5)*10+(Digits==2 || Digits==4);

MinSL=MarketInfo(Symbol(),MODE_STOPLEVEL)/mult;
if (!HiddenSLandTP && ((TakeProfit1<MinSL && TakeProfit1!=0 && OriginalTrade) || (TakeProfit2<MinSL && TakeProfit2!=0 && AdditionalTrade) || (TakeProfit3<MinSL && TakeProfit3!=0 && HedgeTrade) || (StopLoss1<MinSL && StopLoss1!=0 && OriginalTrade) || (StopLoss2<MinSL && StopLoss2!=0 && AdditionalTrade) || (StopLoss3<MinSL && StopLoss3!=0 && HedgeTrade) || (TrailingStop1<MinSL && TrailingStop1!=0 && OriginalTrade) || (TrailingStop2<MinSL && TrailingStop2!=0 && AdditionalTrade) || (TrailingStop3<MinSL && TrailingStop3!=0 && HedgeTrade) || (BreakEven1<MinSL && BreakEven1!=0 && OriginalTrade) || (BreakEven2<MinSL && BreakEven2!=0 && AdditionalTrade) || (BreakEven3<MinSL && BreakEven3!=0 && HedgeTrade)))
{MessageBox("The StopLoss, TakeProfit, TrailingStop and BreakEven should be at least "+DoubleToStr(MinSL,1)+" pips");}
if ((MathAbs(Distance2)<MinSL && AdditionalTrade && UsePendingOrder2) || (MathAbs(Distance3)<MinSL && HedgeTrade && UsePendingOrder3))
{MessageBox("The Distance should be at least "+DoubleToStr(MinSL,1)+" pips");}

MagicNumber[1]=MagicNumber1; MagicNumber[2]=MagicNumber2; MagicNumber[3]=MagicNumber3;
Slippage[1]=Slippage1*mult; Slippage[2]=Slippage2*mult; Slippage[3]=Slippage3*mult; 
TakeProfit[1]=NormalizeDouble(TakeProfit1*Point*mult,Digits);
TakeProfit[2]=NormalizeDouble(TakeProfit2*Point*mult,Digits);
TakeProfit[3]=NormalizeDouble(TakeProfit3*Point*mult,Digits);
StopLoss[1]=NormalizeDouble(StopLoss1*Point*mult,Digits);
StopLoss[2]=NormalizeDouble(StopLoss2*Point*mult,Digits);
StopLoss[3]=NormalizeDouble(StopLoss3*Point*mult,Digits);
Distance[2]=NormalizeDouble(Distance2*Point*mult,Digits);
Distance[3]=NormalizeDouble(Distance3*Point*mult,Digits);
BreakEven[1]=NormalizeDouble(BreakEven1*Point*mult,Digits);
BreakEven[2]=NormalizeDouble(BreakEven2*Point*mult,Digits);
BreakEven[3]=NormalizeDouble(BreakEven3*Point*mult,Digits);
TrailingStop[1]=NormalizeDouble(TrailingStop1*Point*mult,Digits);
TrailingStop[2]=NormalizeDouble(TrailingStop2*Point*mult,Digits);
TrailingStop[3]=NormalizeDouble(TrailingStop3*Point*mult,Digits);
TrailingStep[1]=NormalizeDouble(TrailingStep1*Point*mult,Digits);
TrailingStep[2]=NormalizeDouble(TrailingStep2*Point*mult,Digits);
TrailingStep[3]=NormalizeDouble(TrailingStep3*Point*mult,Digits);
LongArrow[1]=0x003300; LongArrow[2]=0x006600; LongArrow[3]=0x009900;
ShortArrow[1]=0x0000FF; ShortArrow[2]=0x1100FF; ShortArrow[3]=0x2200FF;
StartHour[1]=StrToInteger(StartHour1);
StartHour[2]=StrToInteger(StartHour2);
StartHour[3]=StrToInteger(StartHour3);
EndHour[1]=StrToInteger(EndHour1);
EndHour[2]=StrToInteger(EndHour2);
EndHour[3]=StrToInteger(EndHour3);
EndHour[4]=StrToInteger(CloseAllHour);
EndHour[5]=StrToInteger(FridayNoTradeHour);
Screen[0][1]="original"; Screen[0][2]="additional"; Screen[0][3]="hedge";
Screen[5][1]=StringConcatenate(StringSubstr(StartHour1,0,2),":",StringSubstr(StartHour1,2,2)," to ",StringSubstr(EndHour1,0,2),":",StringSubstr(EndHour1,2,2));
Screen[5][2]=StringConcatenate(StringSubstr(StartHour2,0,2),":",StringSubstr(StartHour2,2,2)," to ",StringSubstr(EndHour2,0,2),":",StringSubstr(EndHour2,2,2));
Screen[5][3]=StringConcatenate(StringSubstr(StartHour3,0,2),":",StringSubstr(StartHour3,2,2)," to ",StringSubstr(EndHour3,0,2),":",StringSubstr(EndHour3,2,2));
gvoop[1]=StringConcatenate(Symbol(),DoubleToStr(MagicNumber[1],0),"oop1");
gvoot[1]=StringConcatenate(Symbol(),DoubleToStr(MagicNumber[1],0),"oot1");
gvoot[2]=StringConcatenate(Symbol(),DoubleToStr(MagicNumber[2],0),"oot2");
gvoot[3]=StringConcatenate(Symbol(),DoubleToStr(MagicNumber[3],0),"oot3");

if (MarketInfo(Symbol(),MODE_LOTSIZE)==10000) {AccountType="Mini";}
if (MarketInfo(Symbol(),MODE_LOTSIZE)==100000) {AccountType="Standard";}
d=(MarketInfo(Symbol(),MODE_LOTSTEP)==0.01)*(1+AllowMicro*MoneyManagement+(!MoneyManagement))+(MarketInfo(Symbol(),MODE_LOTSTEP)==0.1);

return(0);
}

//+------------------------------------------------------------------+

int deinit()
{return(0);}

//+------------------------------------------------------------------+

int start()
{

RSI=iRSI(NULL,RSI_TF,RSI_Period,PRICE_CLOSE,ClosedBarSignal);

//+------------------------------------------------------------------+
//|Money Management                                             |
//+------------------------------------------------------------------+

if(MoneyManagement)
{if (AccountType=="Standard")
{if (AllowMicro)
Lots=MathMax(0.01,NormalizeDouble(AccountEquity()*LeveragePercent/100000.0,2));
else Lots=MathMax(0.1,NormalizeDouble(AccountEquity()*LeveragePercent/100000.0,1));}
else if (AccountType=="Mini")
{if (AllowMicro)
Lots=MathMax(0.01,NormalizeDouble(AccountEquity()*LeveragePercent/10000.0,2));
else Lots=MathMax(0.1,NormalizeDouble(AccountEquity()*LeveragePercent/10000.0,1));}}
Lots=MathMin(Lots,MaxLots);

//+------------------------------------------------------------------+
//|Trading hours check                                               |
//+------------------------------------------------------------------+   

ServerTime=TimeHour(TimeCurrent())*100+TimeMinute(TimeCurrent());
i1=1; while(i1<=3)
{TradingTime[i1]=(StartHour[i1]<EndHour[i1] && ServerTime>=StartHour[i1] && ServerTime<EndHour[i1]);
TradingTime[i1]=(TradingTime[i1] || (StartHour[i1]>=EndHour[i1] && (ServerTime>=StartHour[i1] || ServerTime<EndHour[i1])));
TradingTime[i1]=(TradingTime[i1] && !(DayOfWeek()==5 && EndHour[5]<=ServerTime)); i1++;}
if (!TradingTime[1]) StartHour[4]=0;
if (TradingTime[1] && StartHour[4]==0) 
{StartHour[4]=StrToTime(StringConcatenate(StringSubstr(StartHour1,0,2),":",StringSubstr(StartHour1,2,2)));
if (StartHour[1]>EndHour[1] && ServerTime<StartHour[1] && DayOfWeek()>1) StartHour[4]-=86400;
if (StartHour[1]>EndHour[1] && ServerTime<StartHour[1] && DayOfWeek()==1) StartHour[4]-=259200;}

//+------------------------------------------------------------------+
//|Trailing stop loss                                                |
//+------------------------------------------------------------------+   

Trade[1]=false; Trade[2]=false; Trade[3]=false;
i9=OrdersTotal()-1; while(i9>=0)
{if (OrderSelect(i9,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol())
{i8=1; while(i8<=3)
{if (OrderMagicNumber()==MagicNumber[i8])       
{Trade[i8]=true; OType[i8]=OrderType(); OTicket[i8]=OrderTicket(); 
if (GlobalVariableGet(gvoop[i8])!=OrderOpenPrice()) GlobalVariableSet(gvoop[i8],OrderOpenPrice());
if (GlobalVariableGet(gvoot[i8])!=OrderOpenTime()) GlobalVariableSet(gvoot[i8],OrderOpenTime());
if (CloseAllOrders && ServerTime>=EndHour[4] && ((ServerTime<StartHour[i8] && StartHour[i8]>EndHour[4]) || StartHour[i8]<EndHour[4]) && OrderType()<2) OrderClose(OrderTicket(),OrderLots(),Bid*(OrderType()==OP_BUY)+Ask*(OrderType()==OP_SELL),Slippage[i8],LongArrow[i8]*(OrderType()==OP_BUY)+ShortArrow[i8]*(OrderType()==OP_SELL));

if (HiddenSLandTP && OrderType()<=1)  
{if (OTakeProfit[i8]==0 && TakeProfit[i8]>0) OTakeProfit[i8]=(OrderType()==0)*(OrderOpenPrice()+TakeProfit[i8])+(OrderType()==1)*(OrderOpenPrice()-TakeProfit[i8]);
if (OStopLoss[i8]==0 && StopLoss[i8]>0) OStopLoss[i8]=(OrderType()==0)*(OrderOpenPrice()-StopLoss[i8])+(OrderType()==1)*(OrderOpenPrice()+StopLoss[i8]);
if (OrderType()==0 && ((Bid>=OTakeProfit[i8] && OTakeProfit[i8]>0) || (Bid<=OStopLoss[i8] && OStopLoss[i8]>0))) {OrderClose(OrderTicket(),OrderLots(),Bid,Slippage[i8],LongArrow[i8]);}
if (OrderType()==1 && ((Ask<=OTakeProfit[i8] && OTakeProfit[i8]>0) || (Ask>=OStopLoss[i8] && OStopLoss[i8]>0))) {OrderClose(OrderTicket(),OrderLots(),Ask,Slippage[i8],ShortArrow[i8]);}}

if(BreakEven[i8]>0)
{if (OrderType()==OP_BUY && Bid-OrderOpenPrice()>=BreakEven[i8])      
{if (!HiddenSLandTP && OrderStopLoss()<OrderOpenPrice())
{OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,LongArrow[i8]);}
if (HiddenSLandTP && OStopLoss[i8]<OrderOpenPrice())
{OStopLoss[i8]=OrderOpenPrice();}}
if (OrderType()==OP_SELL && OrderOpenPrice()-Ask>=BreakEven[i8])
{if (!HiddenSLandTP && OrderStopLoss()>OrderOpenPrice())
{OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,ShortArrow[i8]);}
if (HiddenSLandTP && OStopLoss[i8]>OrderOpenPrice())
{OStopLoss[i8]=OrderOpenPrice();}}}

if(TrailingStop[i8]>0)
{if (OrderType()==OP_BUY && Bid-OrderOpenPrice()>=TrailingStop[i8])
{if (!HiddenSLandTP  && OrderStopLoss()<=Bid-TrailingStop[i8]-TrailingStep[i8])
{OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid-TrailingStop[i8],Digits),OrderTakeProfit(),0,LongArrow[i8]);}
if (HiddenSLandTP && OStopLoss[i8]<=Bid-TrailingStop[i8]-TrailingStep[i8])
{OStopLoss[i8]=NormalizeDouble(Bid-TrailingStop[i8],Digits);}}
if (OrderType()==OP_SELL && OrderOpenPrice()-Ask>=TrailingStop[i8])
{if (!HiddenSLandTP && (OrderStopLoss()>=Ask+TrailingStop[i8]+TrailingStep[i8] || OrderStopLoss()==0))
{OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask+TrailingStop[i8],Digits),OrderTakeProfit(),0,ShortArrow[i8]);}    
if (HiddenSLandTP && (OStopLoss[i8]>=Ask+TrailingStop[i8]+TrailingStep[i8] || OStopLoss[i8]==0))
{OStopLoss[i8]=NormalizeDouble(Ask+TrailingStop[i8],Digits);}}}
} i8++;}} i9--;}

if (HiddenSLandTP)
{i1=1; while(i1<=3) {OStopLoss[i1]*=(Trade[i1]); OTakeProfit[i1]*=(Trade[i1]); i1++;}}
OrderOpenPrice1=GlobalVariableGet(gvoop[1]);
OOpenTime[1]=GlobalVariableGet(gvoot[1]); OOpenTime[2]=GlobalVariableGet(gvoot[2]); OOpenTime[3]=GlobalVariableGet(gvoot[3]);

//+------------------------------------------------------------------+
//|Original trade                                                    |
//+------------------------------------------------------------------+

EnableBuy[2]=false; EnableSell[2]=false;
if (TradingTime[1])
{i3=0; i1=0; i2=0; v=OrdersHistoryTotal()-1; while(v>=0)
{if (OrderSelect(v,SELECT_BY_POS,MODE_HISTORY))
{if (OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber[1] && OrderOpenTime()>=StartHour[4])  
{i1+=(OrderProfit()>0); i2+=(OrderProfit()<0); i3=OrderOpenTime();
if (i2+i1>0) break;}} v--;}

EnableBuy[2]=(i2==0 || ReentryAfterSL);
EnableBuy[2]=(EnableBuy[2] && (i2==0 || OrderType()==OP_SELL || !OppositeDirectionAfterSL));
EnableBuy[2]=(EnableBuy[2] && (i1==0 || ReentryAfterTP));
EnableBuy[2]=(EnableBuy[2] && (i1==0 || OrderType()==OP_SELL || !OppositeDirectionAfterTP));

EnableSell[2]=(i2==0 || ReentryAfterSL);
EnableSell[2]=(EnableSell[2] && (i2==0 || OrderType()==OP_BUY || !OppositeDirectionAfterSL));
EnableSell[2]=(EnableSell[2] && (i1==0 || ReentryAfterTP));
EnableSell[2]=(EnableSell[2] && (i1==0 || OrderType()==OP_BUY || !OppositeDirectionAfterTP));}


if (!Trade[2] && !Trade[3])
{
if (RSI<RSI_Buy && EnableBuy[1])
{ 
EnableBuy[1] = false; EnableSell[1] = true;
if (OriginalTrade && TradingTime[1] && !Trade[1] && EnableBuy[2])
{
GlobalVariableSet(gvoot[2],0); GlobalVariableSet(gvoot[3],0);
OrderSend(Symbol(),OP_BUY,NormalizeDouble(Lots*LotMultiplier1,d),Ask,Slippage1,NormalizeDouble((Ask-StopLoss[1])*(StopLoss[1]>0 && !HiddenSLandTP),Digits), NormalizeDouble((Ask + TakeProfit[1])*(TakeProfit[1]>0 && !HiddenSLandTP),Digits),Comment1,MagicNumber[1],0,LongArrow[1]);}
if (!OriginalTrade || (OriginalTrade && !TradingTime[1] && !Trade[1] && TradingTime[2]))
{GlobalVariableSet(gvoot[2],0);
GlobalVariableSet(gvoot[3],0);
GlobalVariableSet(gvoop[1],Ask);
OrderOpenPrice1 = Ask;
GlobalVariableSet(gvoot[1],TimeCurrent());
OOpenTime[1] = TimeCurrent();}
}
if (RSI>RSI_Sell && EnableSell[1])
{ 
EnableBuy[1] = true; EnableSell[1] = false;
if (OriginalTrade && TradingTime[1] && !Trade[1] && EnableSell[2])
{GlobalVariableSet(gvoot[2],0); GlobalVariableSet(gvoot[3],0);
OrderSend(Symbol(),OP_SELL,NormalizeDouble(Lots*LotMultiplier1,d),Bid,Slippage1,NormalizeDouble((Bid+StopLoss[1])*(StopLoss[1]>0 && !HiddenSLandTP),Digits),NormalizeDouble((Bid - TakeProfit[1])*(TakeProfit[1]>0 && !HiddenSLandTP),Digits),Comment1,MagicNumber[1],0,ShortArrow[1]);}
if (!OriginalTrade || (OriginalTrade && !TradingTime[1] && !Trade[1] && TradingTime[2]))
{GlobalVariableSet(gvoot[2],0);
GlobalVariableSet(gvoot[3],0);
GlobalVariableSet(gvoop[1],Bid);
OrderOpenPrice1 = Bid;
GlobalVariableSet(gvoot[1],TimeCurrent());
OOpenTime[1] = TimeCurrent();}
}}

//+------------------------------------------------------------------+
//|Additional trade                                                  |
//+------------------------------------------------------------------+

if (AdditionalTrade && !Trade[2] && TradingTime[2] && OOpenTime[1] > OOpenTime[2])
{
if (!OriginalTrade) 
{
if (!UsePendingOrder2)
{
if (!EnableBuy[1] && OrderOpenPrice1 - Distance[2]  >= Ask)
{
OrderSend(Symbol(),OP_BUY,NormalizeDouble(Lots * LotMultiplier2,d),Ask,Slippage2,NormalizeDouble((Ask - StopLoss[2])*(StopLoss[2]>0 && !HiddenSLandTP),Digits), NormalizeDouble((Ask + TakeProfit[2])*(TakeProfit[2]>0 && !HiddenSLandTP),Digits),Comment2,MagicNumber[2],0,LongArrow[2]);
}
if (!EnableSell[1] && OrderOpenPrice1 + Distance[2]  <= Bid)
{
OrderSend(Symbol(),OP_SELL,NormalizeDouble(Lots*LotMultiplier2,d),Bid,Slippage2,NormalizeDouble((Bid + StopLoss[2])*(StopLoss[2]>0 && !HiddenSLandTP),Digits),NormalizeDouble((Bid - TakeProfit[2])*(TakeProfit[2]>0 && !HiddenSLandTP),Digits),Comment2,MagicNumber[2],0,ShortArrow[2]);
}
}
if (UsePendingOrder2)
{
if (!EnableBuy[1])
{
OrderSend(Symbol(),OP_BUYLIMIT,NormalizeDouble(Lots * LotMultiplier2,d),NormalizeDouble(OrderOpenPrice1 - Distance[2],Digits) ,0,NormalizeDouble((OrderOpenPrice1-Distance[2]-StopLoss[2])*(StopLoss[2]>0 && !HiddenSLandTP),Digits), NormalizeDouble((OrderOpenPrice1-Distance[2]+TakeProfit[2])*(TakeProfit[2]>0 && !HiddenSLandTP),Digits),Comment2,MagicNumber[2],0,LongArrow[2]);
}
if (!EnableSell[1])
{
OrderSend(Symbol(),OP_SELLLIMIT,NormalizeDouble(Lots * LotMultiplier2,d),NormalizeDouble(OrderOpenPrice1 + Distance[2],Digits) ,0,NormalizeDouble((OrderOpenPrice1 + Distance[2]+StopLoss[2])*(StopLoss[2]>0 && !HiddenSLandTP),Digits),NormalizeDouble((OrderOpenPrice1 + Distance[2]-TakeProfit[2])*(TakeProfit[2]>0 && !HiddenSLandTP),Digits),Comment2,MagicNumber[2],0,ShortArrow[2]);
}
}
}
if (Trade[1] || (OriginalTrade && !TradingTime[1] && !Trade[1]))
{
if (!UsePendingOrder2)
{
if (OType[1] == 0 && OrderOpenPrice1 - Distance[2]  >= Ask)
{
OrderSend(Symbol(),OP_BUY,NormalizeDouble(Lots * LotMultiplier2,d),Ask,Slippage2,NormalizeDouble((Ask - StopLoss[2])*(StopLoss[2]>0 && !HiddenSLandTP),Digits), NormalizeDouble((Ask + TakeProfit[2])*(TakeProfit[2]>0 && !HiddenSLandTP),Digits),Comment2,MagicNumber[2],0,LongArrow[2]);
}
if (OType[1] == 1 && OrderOpenPrice1 + Distance[2]  <= Bid)
{
OrderSend(Symbol(),OP_SELL,NormalizeDouble(Lots * LotMultiplier2,d),Bid,Slippage2,NormalizeDouble((Bid + StopLoss[2])*(StopLoss[2]>0 && !HiddenSLandTP),Digits),NormalizeDouble((Bid - TakeProfit[2])*(TakeProfit[2]>0 && !HiddenSLandTP),Digits),Comment2,MagicNumber[2],0,ShortArrow[2]);
}
}
if (UsePendingOrder2)
{
if (OType[1] == 0)
{
OrderSend(Symbol(),OP_BUYLIMIT,NormalizeDouble(Lots * LotMultiplier2,d),NormalizeDouble(OrderOpenPrice1 - Distance[2],Digits),0,NormalizeDouble((OrderOpenPrice1-Distance[2]-StopLoss[2])*(StopLoss[2]>0 && !HiddenSLandTP),Digits), NormalizeDouble((OrderOpenPrice1-Distance[2]+TakeProfit[2])*(TakeProfit[2]>0 && !HiddenSLandTP),Digits),Comment2,MagicNumber[2],0,LongArrow[2]);
}
if (OType[1] == 1)
{
OrderSend(Symbol(),OP_SELLLIMIT,NormalizeDouble(Lots * LotMultiplier2,d),NormalizeDouble(OrderOpenPrice1 + Distance[2],Digits) ,0,NormalizeDouble((OrderOpenPrice1 + Distance[2]+StopLoss[2])*(StopLoss[2]>0 && !HiddenSLandTP),Digits),NormalizeDouble((OrderOpenPrice1 + Distance[2]-TakeProfit[2])*(TakeProfit[2]>0 && !HiddenSLandTP),Digits),Comment2,MagicNumber[2],0,ShortArrow[2]);
}
}
}
}

if (Trade[2] && (OType[2] == 2 || OType[2] == 3))
{
if (!OriginalTrade || (OriginalTrade && !TradingTime[1] && !Trade[1]))
{ 
if ((OType[2] == 2  && EnableBuy[1]) || (OType[2] == 3  && EnableSell[1]))
{
OrderDelete(OTicket[2]);}
}
if (OriginalTrade && !Trade[1] && TradingTime[1]) 
{
if (DeleteIfOriginalClosed)
{
OrderDelete(OTicket[2]);
}
if (!DeleteIfOriginalClosed && (OType[2] == 2  && EnableBuy[1]) || (OType[2] == 3  && EnableSell[1]))
{
OrderDelete(OTicket[2]);
}
}
if (DeleteAfterEndHour2  && !TradingTime[2])
{
OrderDelete(OTicket[2]);
}
}

//+------------------------------------------------------------------+
//|Hedge trade                                                       |
//+------------------------------------------------------------------+

if (HedgeTrade && !Trade[3] && TradingTime[3] && OOpenTime[1] > OOpenTime[3])
{
if (Trade[2] && !Trade[1])
{
if (!UsePendingOrder3)
{
if (OType[2] == 0 && OrderOpenPrice1 - Distance[3]  >= Bid)
{
OrderSend(Symbol(),OP_SELL,NormalizeDouble(Lots * LotMultiplier3,d),Bid,Slippage3,NormalizeDouble((Bid + StopLoss[3])*(StopLoss[3]>0 && !HiddenSLandTP),Digits),NormalizeDouble((Bid - TakeProfit[3])*(TakeProfit[3]>0 && !HiddenSLandTP),Digits),Comment3,MagicNumber[3],0,ShortArrow[3]);
}
if (OType[2] == 1 && OrderOpenPrice1 + Distance[3]  <= Ask)
{
OrderSend(Symbol(),OP_BUY,NormalizeDouble(Lots * LotMultiplier3,d),Ask,Slippage3,NormalizeDouble((Ask - StopLoss[3])*(StopLoss[3]>0 && !HiddenSLandTP),Digits), NormalizeDouble((Ask + TakeProfit[3])*(TakeProfit[3]>0 && !HiddenSLandTP),Digits),Comment3,MagicNumber[3],0,LongArrow[3]);
}
}
if (UsePendingOrder3)
{
if (OType[2] == 0 || OType[2] == 2)
{
OrderSend(Symbol(),OP_SELLSTOP,NormalizeDouble(Lots * LotMultiplier3,d),NormalizeDouble(OrderOpenPrice1-Distance[3],Digits) ,0,NormalizeDouble((OrderOpenPrice1-Distance[3] + StopLoss[3])*(StopLoss[3]>0 && !HiddenSLandTP),Digits),NormalizeDouble((OrderOpenPrice1-Distance[3] - TakeProfit[3])*(TakeProfit[3]>0 && !HiddenSLandTP),Digits),Comment3,MagicNumber[3],0,ShortArrow[3]);
}
if (OType[2] == 1 || OType[2] == 3)
{
OrderSend(Symbol(),OP_BUYSTOP,NormalizeDouble(Lots * LotMultiplier3,d),NormalizeDouble(OrderOpenPrice1+Distance[3],Digits) ,0,NormalizeDouble((OrderOpenPrice1+Distance[3] - StopLoss[3])*(StopLoss[3]>0 && !HiddenSLandTP),Digits), NormalizeDouble((OrderOpenPrice1+Distance[3] + TakeProfit[3])*(TakeProfit[3]>0 && !HiddenSLandTP),Digits),Comment3,MagicNumber[3],0,LongArrow[3]);
}
}
}
if (Trade[1])
{
if (!UsePendingOrder3)
{
if (OType[1] == 0 && OrderOpenPrice1 - Distance[3]  >= Bid)
{
OrderSend(Symbol(),OP_SELL,NormalizeDouble(Lots * LotMultiplier3,d),Bid,Slippage3,NormalizeDouble((Bid + StopLoss[3])*(StopLoss[3]>0 && !HiddenSLandTP),Digits),NormalizeDouble((Bid - TakeProfit[3])*(TakeProfit[3]>0 && !HiddenSLandTP),Digits),Comment3,MagicNumber[3],0,ShortArrow[3]);
}
if (OType[1] == 1 && OrderOpenPrice1 + Distance[3]  <= Ask)
{
OrderSend(Symbol(),OP_BUY,NormalizeDouble(Lots * LotMultiplier3,d),Ask,Slippage3,NormalizeDouble((Ask - StopLoss[3])*(StopLoss[3]>0 && !HiddenSLandTP),Digits), NormalizeDouble((Ask + TakeProfit[3])*(TakeProfit[3]>0 && !HiddenSLandTP),Digits),Comment3,MagicNumber[3],0,LongArrow[3]);
}
}
if (UsePendingOrder3)
{
if (OType[1] == 0)
{
OrderSend(Symbol(),OP_SELLSTOP,NormalizeDouble(Lots * LotMultiplier3,d),NormalizeDouble(OrderOpenPrice1-Distance[3],Digits) ,0,NormalizeDouble((OrderOpenPrice1-Distance[3] + StopLoss[3])*(StopLoss[3]>0 && !HiddenSLandTP),Digits),NormalizeDouble((OrderOpenPrice1-Distance[3] - TakeProfit[3])*(TakeProfit[3]>0 && !HiddenSLandTP),Digits),Comment3,MagicNumber[3],0,ShortArrow[3]);
}
if (OType[1] == 1)
{
OrderSend(Symbol(),OP_BUYSTOP,NormalizeDouble(Lots * LotMultiplier3,d),NormalizeDouble(OrderOpenPrice1+Distance[3],Digits) ,0,NormalizeDouble((OrderOpenPrice1+Distance[3] - StopLoss[3])*(StopLoss[3]>0 && !HiddenSLandTP),Digits), NormalizeDouble((OrderOpenPrice1+Distance[3] + TakeProfit[3])*(TakeProfit[3]>0 && !HiddenSLandTP),Digits),Comment3,MagicNumber[3],0,LongArrow[3]);
}
}
}
}

if (Trade[3] && UsePendingOrder3 && !Trade[2] && !Trade[1] && (OType[3]==4 || OType[3]==5))
{
OrderDelete(OTicket[3]);
}
 
//+------------------------------------------------------------------+
//|RSI check and Comment                                             |
//+------------------------------------------------------------------+

if (RSI<RSI_Sell_Reset && RSI>RSI_Buy_Reset)
{EnableSell[1] = true; EnableBuy[1] = true;}

i1=1; while(i1<=3) 
{Screen[0][0]="";
if (TradingTime[i1]) {Screen[0][0]=StringConcatenate("\nTrading of ",Screen[0][i1]," trade is now enabled\n");}
else {Screen[0][0]=StringConcatenate("\nTrading of ",Screen[0][i1]," trade is now disabled\n");}
if (HiddenSLandTP && Trade[i1])
{if (OTakeProfit[i1]>0) Screen[0][0]=StringConcatenate(Screen[0][0],"The hidden take profit of ",Screen[0][i1]," trade is ",OTakeProfit[i1],"\n");
if (OStopLoss[i1]>0) Screen[0][0]=StringConcatenate(Screen[0][0],"The hidden stop loss of ",Screen[0][i1]," trade is ",OStopLoss[i1],"\n");}
Screen[1][i1]=StringConcatenate("\nTrading hours of ",Screen[0][i1]," trade ",Screen[5][i1],Screen[0][0]);
i1++;}

if (!OriginalTrade) Screen[1][1]="";
if (!AdditionalTrade) Screen[1][2]="";
if (!HedgeTrade) Screen[1][3]="";

Screen[1][4]=StringConcatenate("\nServer time ",StringSubstr(DoubleToStr(ServerTime+10000,0),1,2),":",StringSubstr(DoubleToStr(ServerTime+10000,0),3,2),"\nRSI ",NormalizeDouble(RSI,1),"\n");

Comment(Screen[1][4],Screen[1][1],Screen[1][2],Screen[1][3]);
}