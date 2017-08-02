//+------------------------------------------------------------------+
//|                                                          tmp.mq4 |
//|                                          Copyright 2017, Alograg |
//|                                           https://www.alograg.me |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Alograg"
#property link "https://www.alograg.me"
#property version "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
  //--- indicator buffers mapping

  //---
  return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
  //---

  //--- return value of prev_calculated for next call
  return (rates_total);
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer() {
  //---
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam,
                  const string &sparam) {
  //---
}
//+------------------------------------------------------------------+
