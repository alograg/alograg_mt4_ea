//+------------------------------------------------------------------+
//|                                            on-balance-volume.mq4 |
//|        ©2011 Best-metatrader-indicators.com. All rights reserved |
//|                        http://www.best-metatrader-indicators.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011 Best-metatrader-indicators.com."
#property link      "http://www.best-metatrader-indicators.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 DodgerBlue
//---- input parameters
extern int ExtOBVAppliedPrice=0;
//---- buffers
double ExtOBVBuffer[];
string Copyright="\xA9 WWW.BEST-METATRADER-INDICATORS.COM";  
string MPrefix="FI";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string sShortName;
//---- indicator buffer mapping
   SetIndexBuffer(0,ExtOBVBuffer);
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
//---- sets default precision format for indicators visualization
   IndicatorDigits(0);     
//---- name for DataWindow and indicator subwindow label
   sShortName="OBV";
   IndicatorShortName(sShortName);
   SetIndexLabel(0,sShortName);
//----
   DL("001", Copyright, 5, 20,Gold,"Arial",10,0); 
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ClearObjects(); 
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    i,nLimit,nCountedBars;
//---- bars count that does not changed after last indicator launch.
   nCountedBars=IndicatorCounted();
//---- last counted bar will be recounted
   if(nCountedBars>0) nCountedBars--;
   nLimit=Bars-nCountedBars-1;
//---- 
   for(i=nLimit; i>=0; i--)
     {
      if(i==Bars-1)
         ExtOBVBuffer[i]=Volume[i];
      else
        {
         double dCurrentPrice=GetAppliedPrice(ExtOBVAppliedPrice, i);
         double dPreviousPrice=GetAppliedPrice(ExtOBVAppliedPrice, i+1);
         if(dCurrentPrice==dPreviousPrice)
            ExtOBVBuffer[i]=ExtOBVBuffer[i+1];
         else
           {
            if(dCurrentPrice<dPreviousPrice)
               ExtOBVBuffer[i]=ExtOBVBuffer[i+1]-Volume[i];  
            else
               ExtOBVBuffer[i]=ExtOBVBuffer[i+1]+Volume[i]; 
           }
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| GetAppliedPrice function                                         |
//+------------------------------------------------------------------+
double GetAppliedPrice(int nAppliedPrice, int nIndex)
  {
   double dPrice;
//----
   switch(nAppliedPrice)
     {
      case 0:  dPrice=Close[nIndex];                                  break;
      case 1:  dPrice=Open[nIndex];                                   break;
      case 2:  dPrice=High[nIndex];                                   break;
      case 3:  dPrice=Low[nIndex];                                    break;
      case 4:  dPrice=(High[nIndex]+Low[nIndex])/2.0;                 break;
      case 5:  dPrice=(High[nIndex]+Low[nIndex]+Close[nIndex])/3.0;   break;
      case 6:  dPrice=(High[nIndex]+Low[nIndex]+2*Close[nIndex])/4.0; break;
      default: dPrice=0.0;
     }
//----
   return(dPrice);
  }
//+------------------------------------------------------------------+
//| DL function                                                      |
//+------------------------------------------------------------------+
 void DL(string label, string text, int x, int y, color clr, string FontName = "Arial",int FontSize = 12, int typeCorner = 1)
 
{
   string labelIndicator = MPrefix + label;   
   if (ObjectFind(labelIndicator) == -1)
   {
      ObjectCreate(labelIndicator, OBJ_LABEL, 0, 0, 0);
  }
   
   ObjectSet(labelIndicator, OBJPROP_CORNER, typeCorner);
   ObjectSet(labelIndicator, OBJPROP_XDISTANCE, x);
   ObjectSet(labelIndicator, OBJPROP_YDISTANCE, y);
   ObjectSetText(labelIndicator, text, FontSize, FontName, clr);
  
}  

//+------------------------------------------------------------------+
//| ClearObjects function                                            |
//+------------------------------------------------------------------+
void ClearObjects() 
{ 
  for(int i=0;i<ObjectsTotal();i++) 
  if(StringFind(ObjectName(i),MPrefix)==0) { ObjectDelete(ObjectName(i)); i--; } 
}
//+------------------------------------------------------------------+