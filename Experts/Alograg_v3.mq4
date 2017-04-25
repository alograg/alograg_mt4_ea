/*-------------------------+
|           Alograg v3.mq4 |
|  Copyright 2017, Alograg |
|   https://www.alograg.me |
+-------------------------*/
#define propVersion "3.16"
#define eaName "Alograg"
#define MagicNumber 17808159
// Propiedades
#property copyright "Copyright 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Incluciones
#include "..\Include\OrderReliable_2011.01.07.mqh"
#include "..\Include\Utilities.mqh"
#include "..\Include\TradeManager.mqh"
#include "..\Include\MorningWork.mqh"
#include "..\Include\FreeDayNigth.mqh"
#include "..\Include\WeekendGap.mqh"
// Externos
// extern int name = value; //Descipción
extern double firstBalance = 200.00;   // Monto inicial
extern double incrementPerWeek = 1.50; // Incremento de protección
// Constantes
double pareto = 0.8;
double toDayMoney = 0.0;
int tmp = -20;
/*----------------+
| Inicialización  |
+----------------*/
int OnInit() {
  // Monto para utilizar en transacciones
  GlobalVariableSet(eaName + "_block_profit", firstBalance * 0.2);
  // Inicializacion de variables
  initUtilsGlobals(true);
  // Registro de evento
  EventSetTimer(60);
  tmInit();
  SendSimbolParams();
  Print(eaName + " " + propVersion);
  return (INIT_SUCCEEDED);
}
/*--------+
| Cierre  |
+--------*/
void OnDeinit(const int reason) {
  EventKillTimer();
  // Reseteo del valor bloqueado
  GlobalVariableDel(eaName + "_block_profit");
}
/*-----------+
| Cada dato  |
+-----------*/
void OnTick() {
  doStrategies();
  doManagment();
  if (CheckNewBar()) {
    initUtilsGlobals();
    SendSimbolParams();
  }
  if (isNewDay())
    SendAccountReport();
}
/*-----------+
| Al minuto  |
+-----------*/
void OnTimer() { initUtilsGlobals(); }
/*-------------------------+
| Ejecuta las estrategias  |
+-------------------------*/
void doStrategies() {
  if (AccountFreeMargin() <
      MathMax(firstBalance / 2, AccountBalance() - firstBalance))
    return;
  MorningWork();
  FreeDayNigth();
  // WeekendGap();
}
/*----------------------------+
| Administra las operaciones  |
+----------------------------*/
void doManagment() { tmEvent(); }
