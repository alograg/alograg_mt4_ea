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
//#include "Strategies\DojiOperation.mqh"
//#include "Strategies\M5B3.mqh"
#include "Strategies\Midnight.mqh"
#include "Strategies\Morning.mqh"
// Parameters
extern bool doMorning = TRUE;  // Mornging Strategie Activate
extern bool doMidnight = TRUE; // Midnight Strategie Activate
// Constants
double strategiOperations = 0;
// Methods
void strategiesInit() {
  if (doMorning)
    strategiOperations += MorningOperations;
  if (doMidnight)
    strategiOperations += MidnightOperations;
}
void strategiesEvent() {
  if (doMorning)
    Morning();
  if (doMidnight)
    Midnight();
  // DojiOperation();
  // M5B3();
}