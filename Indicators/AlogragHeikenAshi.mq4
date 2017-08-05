/*--------------------------+
|     AlogragHeikenAshi.mqh |
| Copyright © 2017, Alograg |
|    https://www.alograg.me |
+--------------------------*/
// Properties
#property copyright "Copyright © 2017, Alograg"
#property link "https://www.alograg.me"
#property description "We recommend the following chart settings\n"
#property description "(press F8 or select menu 'Charts'->'Properties...'):"
#property description " - on 'Color' Tab select 'Black' for 'Line Graph'"
#property description " - on 'Common' Tab disable 'Chart on Foreground'"
#property description "   checkbox and select 'Line Chart' radiobutton"
#property version "1.01"
#property strict

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Red
#property indicator_color4 Blue
#property indicator_color5 Green
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3
#property indicator_width4 3
#property indicator_width5 5

// Parameter
input color bearColor = Red;  // Bear color
input color bullColor = Blue; // Bull color
input bool smooth = true;     // Smooth

// Buffers
double ExtLowHighBuffer[];
double ExtHighLowBuffer[];
double ExtOpenBuffer[];
double ExtCloseBuffer[];
double ExtTypeBuffer[];
// Constantes
// Constants
// Methods
/*-----------------------------------------+
| Custom indicator initialization function |
+-----------------------------------------*/
void OnInit(void) {
  IndicatorShortName("AlogragHeikenAshi");
  IndicatorDigits(Digits);
  //--- indicator lines
  SetIndexStyle(0, DRAW_HISTOGRAM, 0, indicator_width1, bearColor);
  SetIndexBuffer(0, ExtLowHighBuffer);
  SetIndexStyle(1, DRAW_HISTOGRAM, 0, indicator_width2, bullColor);
  SetIndexBuffer(1, ExtHighLowBuffer);
  SetIndexStyle(2, DRAW_HISTOGRAM, 0, indicator_width3, bearColor);
  SetIndexBuffer(2, ExtOpenBuffer);
  SetIndexStyle(3, DRAW_HISTOGRAM, 0, indicator_width4, bullColor);
  SetIndexBuffer(3, ExtCloseBuffer);
  SetIndexStyle(4, DRAW_ARROW, 0, 3, Green);
  SetIndexBuffer(4, ExtTypeBuffer);
  //---
  SetIndexLabel(0, "Low/High");
  SetIndexLabel(1, "High/Low");
  SetIndexLabel(2, "Open");
  SetIndexLabel(3, "Close");
  SetIndexLabel(4, "Type");
  //--- indicator buffers mapping
  SetIndexDrawBegin(0, 10);
  SetIndexDrawBegin(1, 10);
  SetIndexDrawBegin(2, 10);
  SetIndexDrawBegin(3, 10);
  SetIndexDrawBegin(4, 10);
  //--- initialization done
}
/*------------------------------------+
| Custom indicator iteration function |
+------------------------------------*/
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
  int i, pos;
  double haOpen, haHigh, haLow, haClose;
  //---
  if (rates_total <= 10)
    return (0);
  //--- counting from 0 to rates_total
  ArraySetAsSeries(ExtLowHighBuffer, false);
  ArraySetAsSeries(ExtHighLowBuffer, false);
  ArraySetAsSeries(ExtOpenBuffer, false);
  ArraySetAsSeries(ExtCloseBuffer, false);
  ArraySetAsSeries(ExtTypeBuffer, false);
  ArraySetAsSeries(open, false);
  ArraySetAsSeries(high, false);
  ArraySetAsSeries(low, false);
  ArraySetAsSeries(close, false);
  //--- preliminary calculation
  if (prev_calculated > 1)
    pos = prev_calculated - 1;
  else {
    //--- set first candle
    if (open[0] < close[0]) {
      ExtLowHighBuffer[0] = low[0];
      ExtHighLowBuffer[0] = high[0];
    } else {
      ExtLowHighBuffer[0] = high[0];
      ExtHighLowBuffer[0] = low[0];
    }
    ExtOpenBuffer[0] = open[0];
    ExtCloseBuffer[0] = close[0];
    ExtTypeBuffer[0] = open[0] <= close[0];
    //---
    pos = 1;
  }
  //--- main loop of calculations
  double maOpen, maClose, maLow, maHigh;
  for (i = pos; i < rates_total; i++) {
    if (smooth) {
      maOpen = NormalizeDouble((open[i] + open[i - 1]) / 2, Digits);
      maClose = NormalizeDouble((close[i] + close[i - 1]) / 2, Digits);
      maLow = NormalizeDouble((low[i] + low[i - 1]) / 2, Digits);
      maHigh = NormalizeDouble((high[i] + high[i - 1]) / 2, Digits);
    } else {
      maOpen = open[i];
      maClose = close[i];
      maLow = low[i];
      maHigh = high[i];
    }
    haOpen = (ExtOpenBuffer[i - 1] + ExtCloseBuffer[i - 1]) / 2;
    haClose = (maOpen + maHigh + maLow + maClose) / 4;
    haHigh = MathMax(maHigh, MathMax(haOpen, haClose));
    haLow = MathMin(maLow, MathMin(haOpen, haClose));
    if (haOpen < haClose) {
      ExtLowHighBuffer[i] = haLow;
      ExtHighLowBuffer[i] = haHigh;
    } else {
      ExtLowHighBuffer[i] = haHigh;
      ExtHighLowBuffer[i] = haLow;
    }
    ExtOpenBuffer[i] = haOpen;
    ExtCloseBuffer[i] = haClose;
    ExtTypeBuffer[i] = haOpen <= haClose;
  }
  //--- done
  return (rates_total);
}
//+------------------------------------------------------------------+
