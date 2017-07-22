/*--------------------------+
|                 Tools.mqh |
| Copyright © 2017, Alograg |
|    https://www.alograg.me |
+--------------------------*/
// Properties
#property copyright "Copyright © 2017, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Includes
#include "Tools\isNewBar.mqh"
#include "Tools\Spread.mqh"
#include "Tools\isOpenOrder.mqh"
#include "Tools\MoneyOnRisk.mqh"
#include "Tools\TrailStops.mqh"
#include "External\TradersTech.mqh"
// Constantes
double pareto = 0.8;
// Constants
// Methods
// Definitions
template <typename E>
int EnumToArray(E dummy, int &values[], const int start = INT_MIN,
                const int stop = INT_MAX) {
  string t = typename(E) + "::";
  int length = StringLen(t);

  ArrayResize(values, 0);
  int count = 0;

  for (int i = start; i < stop && !IsStopped(); i++) {
    E e = (E)i;
    if (StringCompare(StringSubstr(EnumToString(e), 0, length), t) != 0) {
      ArrayResize(values, count + 1);
      values[count++] = i;
    }
  }
  return count;
}
