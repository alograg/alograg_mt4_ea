/*--------------------------+
|                 Tools.mqh |
| Copyright © 2018, Alograg |
|    https://www.alograg.me |
+--------------------------*/
// Properties
#property copyright "Copyright © 2018, " + eaName
#property link "https://www.alograg.me"
#property version propVersion
#property strict
// Parameters
extern bool sendReportErrors = TRUE; // Send Report Errors
// Definitions
template <typename E>
int EnumToArray(E dummy, int &values[], const int start = INT_MIN,
                const int stop = INT_MAX)
{
  string t = typename(E) + "::";
  int length = StringLen(t);
  ArrayResize(values, 0);
  int count = 0;
  for (int i = start; i < stop && !IsStopped(); i++)
  {
    E e = (E)i;
    if (StringCompare(StringSubstr(EnumToString(e), 0, length), t) != 0)
    {
      ArrayResize(values, count + 1);
      values[count++] = i;
    }
  }
  return count;
}
void ReportError(string from, int err)
{
  if (err != ERR_NO_ERROR && sendReportErrors)
    if (IsTradeAllowed())
      SendNotification("[" + from + "] Error: " + ErrorDescription(err));
  if (IsTesting())
  {
    Print("[" + from + "] Error: " + ErrorDescription(err));
    die[0];
  }
}
// Includes
//#include "External\TradersTech.mqh"
#include "Tools\AccountExtras.mqh"
#include "Tools\CandelSize.mqh"
#include "Tools\OrderExtras.mqh"
#include "Tools\isNewBar.mqh"
#include "Tools\TrailStops.mqh"
// Constantes
double pareto = 0.8;
// Constants
// Methods
