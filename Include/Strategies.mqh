/*--------------------------+
|            Strategies.mqh |
| Copyright © 2017, Alograg |
|    https://www.alograg.me |
+--------------------------*/
// Properties
#property copyright "Copyright © 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Includes
#include "Strategies\DojiOperation.mqh"
#include "Strategies\M5B3.mqh"
#include "Strategies\Midnight.mqh"
#include "Strategies\Morning.mqh"
// Constantes
// Constants
// Methods
void strategiesInit() {}
void strategiesEvent() {
  Morning();
  Midnight();
  // DojiOperation();
  // M5B3();
}