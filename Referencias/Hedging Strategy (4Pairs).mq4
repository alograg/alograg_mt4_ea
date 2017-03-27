

//---- input parameters
extern double    Lot1=0.1;
extern double    Lot2=0.1;
extern double    Lot3=0.1;
extern double    Lot4=0.1;
extern double    Lot5=0.1;
extern double    Lot6=0.1;
extern string    Sym1="GBPUSD";
extern string    Sym2="USDCHF";
extern string    Sym3="EURJPY";
extern string    Sym4="GBPCHF";
extern string    Sym5="CHFJPY";
extern string    Sym6="EURCHF";
extern string    Operation1="buy";
extern string    Operation2="buy";
extern string    Operation3="buy";
extern string    Operation4="sell";
extern string    Operation5="sell";
extern string    Operation6="sell";
extern double    Commission1=0.0;
extern double    Commission2=0.0;
extern double    Commission3=0.0;
extern double    Commission4=0.0;
extern double    Commission5=0.0;
extern double    Commission6=0.0;
extern double    Profit=5;
extern bool      UseMM=false;
extern double    Delta=750;

int OP1=-1, OP2=-1, OP3=-1, OP4=-1, OP5=-1, OP6=-1;


double Ilo1=0, Ilo2=0, Ilo3=0, Ilo4=0, Ilo5=0, Ilo6=0;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//---- 
//init global variables
if (!GlobalVariableCheck("_CanClose")) {
GlobalVariableSet("_CanClose",0);
}      
//if (!GlobalVariableCheck("_CanSet")) {
//GlobalVariableSet("_CanSet",0);
//}      



//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
Ilo1=Lot1; Ilo2=Lot2; Ilo3=Lot3; Ilo4=Lot4; Ilo5=Lot5; Ilo6=Lot6;
if (UseMM) {
Ilo1=TradeLot(AccountBalance());
Ilo2=TradeLot(AccountBalance());
Ilo3=TradeLot(AccountBalance());
Ilo4=TradeLot(AccountBalance());
Ilo5=TradeLot(AccountBalance());
Ilo6=TradeLot(AccountBalance());
}


//---- 
double Commissions=0;


if (Operation1=="buy" || Operation1=="BUY") OP1=OP_BUY;
if (Operation2=="buy" || Operation2=="BUY") OP2=OP_BUY; 
if (Operation3=="buy" || Operation3=="BUY") OP3=OP_BUY;
if (Operation4=="buy" || Operation4=="BUY") OP4=OP_BUY;
if (Operation5=="buy" || Operation5=="BUY") OP5=OP_BUY;
if (Operation6=="buy" || Operation6=="BUY") OP6=OP_BUY;
if (Operation1=="sell" || Operation1=="SELL") OP1=OP_SELL; 
if (Operation2=="sell" || Operation2=="SELL") OP2=OP_SELL; 
if (Operation3=="sell" || Operation3=="SELL") OP3=OP_SELL; 
if (Operation4=="sell" || Operation4=="SELL") OP4=OP_SELL; 
if (Operation5=="sell" || Operation5=="SELL") OP5=OP_SELL;
if (Operation6=="sell" || Operation6=="SELL") OP6=OP_SELL;


if (OP1<0 || OP2<0 ||OP3<0 ||OP4<0 ||OP5<0 ||OP6<0) {
   Comment("Wrong operation selected, aborted...");
   return;
}


if (GlobalVariableGet("_CanClose")==1 && CntOrd(OP1,0,Sym1)==0 && CntOrd(OP2,0,Sym2)==0 && CntOrd(OP3,0,Sym3)==0 && CntOrd(OP4,0,Sym4)==0 && CntOrd(OP5,0,Sym5)==0 && CntOrd(OP6,0,Sym6)==0) {
   GlobalVariableSet("_CanClose",0);
}


if (GlobalVariableGet("_CanClose")==0) {
//Set intitial orders
SetOrders();
}



Comment("Balance=",AccountBalance(),"\n",Sym1," Lot=",Ilo1,"\n",Sym2," Lot=",Ilo2,"\n",Sym3," Lot=",Ilo3,"\n",Sym4," Lot=",Ilo4,"\n",Sym5," Lot=",Ilo5,"\n",Sym6," Lot=",Ilo6," \nFloating profit=",CalcProfit()," Expected profit=",Profit*Ilo1*10);
//Check for profit
Commissions=Commission1*Ilo1+Commission2*Ilo1+Commission3*Ilo1+Commission4*Ilo1+Commission5*Ilo1+Commission6*Ilo1;

if ( (CalcProfit()-Commissions) >= (Profit*Ilo1*10) ) {
GlobalVariableSet("_CanClose",1);
}    

CloseAll();


//----
   return(0);
  }
//+------------------------------------------------------------------+


double CalcProfit() {
//Calculating profit for opened positions
int cnt;
double _Profit;
_Profit=0;   

for(cnt=0; cnt<OrdersTotal(); cnt++)
{     
   OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
	if (OrderSymbol()==Sym1 || OrderSymbol()==Sym2 || OrderSymbol()==Sym3 || OrderSymbol()==Sym4 || OrderSymbol()==Sym5 || OrderSymbol()==Sym6) {
   _Profit=_Profit+OrderProfit(); 
   }   
}
return(_Profit);
}

void CloseAll() {
int _total=OrdersTotal(); // number of orders  
int _ordertype;// order type   
if (_total==0) {return;}
int _ticket; // ticket number
double _priceClose;// price to close orders;
//Closing all opened positions
if (GlobalVariableGet("_CanClose")==1) {

for(int _i=_total-1;_i>=0;_i--)
      {
      if (OrderSelect(_i,SELECT_BY_POS))
         {
         _ordertype=OrderType();
         _ticket=OrderTicket();
         switch(_ordertype)
            {
            case 0:
               // close buy                
               _priceClose=MarketInfo(OrderSymbol(),MODE_BID);
               Print("Close on ",_i," position order with ticket ¹",_ticket);
               OrderClose(_ticket,OrderLots(),_priceClose,0,Red);
               break;
            case 1:
               // close sell
               _priceClose=MarketInfo(OrderSymbol(),MODE_ASK);
               Print("Close on ",_i," position order with ticket ¹",_ticket);
               OrderClose(_ticket,OrderLots(),_priceClose,0,Red);
               break;
            default:
               // values from  1 to 5, deleting pending orders
               Print("Delete on ",_i," position order with ticket ¹",_ticket);
               OrderDelete(_ticket);  
               break;
            }    
         }
}


}
return;
}



void SetOrders() {
//Setting initial orders
double OpenPrice=0;

if(Volume[0]>1) return;

if (CntOrd(OP1,0,Sym1)==0) {
   if (OP1==OP_BUY) OpenPrice=MarketInfo(Sym1,MODE_ASK);
   if (OP1==OP_SELL) OpenPrice=MarketInfo(Sym1,MODE_BID);
   OrderSend(Sym1,OP1,Ilo1,OpenPrice,0,0,0,"HedgeTrader",0,0,Red);
   //return;
}

if (CntOrd(OP2,0,Sym2)==0) {
   if (OP2==OP_BUY) OpenPrice=MarketInfo(Sym2,MODE_ASK);
   if (OP2==OP_SELL) OpenPrice=MarketInfo(Sym2,MODE_BID);
   OrderSend(Sym2,OP2,Ilo2,OpenPrice,0,0,0,"HedgeTrader",0,0,Green);
   //return;
}

if (CntOrd(OP3,0,Sym3)==0) {
   if (OP3==OP_BUY) OpenPrice=MarketInfo(Sym3,MODE_ASK);
   if (OP3==OP_SELL) OpenPrice=MarketInfo(Sym3,MODE_BID);
   OrderSend(Sym3,OP3,Ilo3,OpenPrice,0,0,0,"HedgeTrader",0,0,Blue);
   //return;
}

if (CntOrd(OP4,0,Sym4)==0) {
   if (OP4==OP_BUY) OpenPrice=MarketInfo(Sym4,MODE_ASK);
   if (OP4==OP_SELL) OpenPrice=MarketInfo(Sym4,MODE_BID);
   OrderSend(Sym4,OP4,Ilo4,OpenPrice,0,0,0,"HedgeTrader",0,0,Yellow);
   //return;
}

if (CntOrd(OP5,0,Sym5)==0) {
   if (OP5==OP_BUY) OpenPrice=MarketInfo(Sym5,MODE_ASK);
   if (OP5==OP_SELL) OpenPrice=MarketInfo(Sym5,MODE_BID);
   OrderSend(Sym5,OP5,Ilo5,OpenPrice,0,0,0,"HedgeTrader",0,0,Brown);
   //return;
}

if (CntOrd(OP6,0,Sym6)==0) {
   if (OP6==OP_BUY) OpenPrice=MarketInfo(Sym6,MODE_ASK);
   if (OP6==OP_SELL) OpenPrice=MarketInfo(Sym6,MODE_BID);
   OrderSend(Sym6,OP6,Ilo6,OpenPrice,0,0,0,"HedgeTrader",0,0,Pink);
   //return;
}

}



int CntOrd(int Type, int Magic, string Symb) {
//return number of orders with specific parameters
int _CntOrd;
_CntOrd=0;
for(int i=0;i<OrdersTotal();i++)
{
   OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
  
   if (OrderSymbol()==Symb) {
      if ( (OrderType()==Type && (OrderMagicNumber()==Magic) || Magic==0)) _CntOrd++;
   }
}
return(_CntOrd);
}

double TradeLot(double MyBalance) {
double _Ilo=0;
//AccountEquity()
_Ilo=MathFloor(MyBalance/Delta)/10;
if (_Ilo<0.1) _Ilo=0.1;		
return (_Ilo);

}

