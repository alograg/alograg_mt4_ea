/*------------------------+
|          Alograg v3.mq4 |
| Copyright 2017, Alograg |
|  https://www.alograg.me |
+------------------------*/
#define propVersion "3.51"
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
//#include "..\Include\WeekendGap.mqh"
#include "..\Include\FlowTheLider.mqh"
#include "..\Include\TwoWays.mqh"
#include "..\Include\CrossMover.mqh"
// Externos
// extern int name = value; //Descipción
extern double firstBalance = 200.00;   // Monto inicial
extern double incrementPerWeek = 1.50; // Incremento de protección
extern bool strategiesActivate = TRUE; // Estrategias Activadas
extern bool strategiesLimitBorderUp =
    FALSE; // Limita el borde superior de compra
extern bool strategiesLimitBorderDown =
    FALSE; // Limita el borde superior de compra
// Constantes
double pareto = 0.8;
double toDayMoney = 0.0;
int tmp = 1; //-20;
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
  if (tmp <= 0)
    tmp = OrderSendReliable(Symbol(), OP_SELL, 0.01, Bid, 3,
                            0.843 + (getSpread() * 5), 0, FlowTheLiderComment,
                            MagicNumber, 0, Green);
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
  if (!strategiesActivate)
    return;
  if (AccountFreeMargin() <
      MathMax(firstBalance / 2, AccountFreeMargin() - firstBalance))
    return;
  MorningWork();
  FreeDayNigth();
  FlowTheLider();
  TwoWays();
  CrossMover();
  // WeekendGap();
}
/*----------------------------+
| Administra las operaciones  |
+----------------------------*/
void doManagment() { tmEvent(); }
