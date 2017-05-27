/*------------------------+
|          Alograg v3.mq4 |
| Copyright 2017, Alograg |
|  https://www.alograg.me |
+------------------------*/
#define propVersion "3.84"
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
#include "..\Include\TwoWays.mqh"
#include "..\Include\MorningWork.mqh"
#include "..\Include\FreeDayNigth.mqh"
//#include "..\Include\WeekendGap.mqh"
#include "..\Include\FlowTheLider.mqh"
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
int tmp = 30; //-20;
/*----------------+
| Inicialización  |
+----------------*/
int OnInit() {
  // Inicializacion de variables
  initUtilsGlobals(true);
  Print("Depositos: ", workingMoney);
  // Monto para utilizar en transacciones
  GlobalVariableSet(eaName + "_block_profit", workingMoney * 0.2);
  // Registro de evento
  EventSetTimer(60 * 60 * 6);
  tmInit();
  SendSimbolParams();
  Print(eaName + " " + propVersion);
  AddNotify(eaName + " " + propVersion);
  testOperation();
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
    SendNotification(fullNotification);
  }
  fullNotification = "";
}
/*----------+
| Al timer  |
+----------*/
void OnTimer() {
  SendAccountReport();
  if (false && !IsTradeAllowed()) {
    string Alarm = TerminalInfoString(TERMINAL_NAME) + "\n";
    Alarm += TerminalInfoString(TERMINAL_COMPANY) + "\n";
    Alarm += TerminalInfoString(TERMINAL_PATH) + "\n";
    Alarm += "AutoTrade off!!!";
    SendNotification(Alarm);
  }
}
/*-------------------------+
| Ejecuta las estrategias  |
+-------------------------*/
void doStrategies() {
  if (!strategiesActivate)
    return;
  //TwoWays();
  if (moneyOnRisk())
    return;
  MorningWork();
  FreeDayNigth();
  FlowTheLider();
  CrossMover();
  // WeekendGap();
}
/*----------------------------+
| Administra las operaciones  |
+----------------------------*/
void doManagment() { 
  tmEvent();
  // FlowTheEnemy
}

void testOperation() {
  if (tmp <= 20)
    tmp = OrderSendReliable(Symbol(), OP_BUY, 0.05, Ask, 3, 0, 0, MagicNumber,
                            MagicNumber, 0, Green);
}