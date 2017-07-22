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
#include "Strategies\Morning.mqh"
// Constantes
// Constants
// Methods
void strategiesInit() {}
void strategiesEvent() { Morning(); }