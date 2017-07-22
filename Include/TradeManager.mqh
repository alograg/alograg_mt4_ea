/*--------------------------+
|          TradeManager.mqh |
| Copyright © 2017, Alograg |
|    https://www.alograg.me |
+--------------------------*/
// Properties
#property copyright "Copyright © 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Includes
//#include "TradeManager\Morning.mqh"
// Constantes
// Constants
// Methods
void tmInit() { BreakEven = breakInSpread ? getSpread() : manualBreakEven; }
void tmEvent() {}