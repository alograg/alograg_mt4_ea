//+------------------------------------------------------------------+
//|                                        EA Studio Data Export.mq4 |
//|                                              Forex Software Ltd. |
//|                                               http://forexsb.com |
//+------------------------------------------------------------------+
#property copyright "Forex Software Ltd."
#property link      "http://forexsb.com"
#property version   "1.2"
#property strict

static input int Maximum_Bars = 20000; // Maximum count of bars
static input int Spread = 10; // Spread in points

// Commission in currency per lot. It is normally used by the ECN brokers.
// Example: 16 - it means 8 USD for the entry and 8 USD for the exit per round lot.
static input double Commission = 0;



ENUM_TIMEFRAMES periods[] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4, PERIOD_D1};
string comment = "";

void OnStart()
{
    RefreshRates();
    
    string symbol = _Symbol;

    for(int p = 0; p < ArraySize(periods); p++)
    {
        string data     = GetSymbolData(symbol, periods[p]);
        string fileName = symbol + PeriodToStr(periods[p]) + ".json";
        SaveFile(fileName, data);
    }
}

string GetSymbolData(string symbol, ENUM_TIMEFRAMES period)
{
    string name         = symbol;
    int    digits       = (int) SymbolInfoInteger(symbol, SYMBOL_DIGITS);
    int    maxBars      = MathMin(TerminalInfoInteger(TERMINAL_MAXBARS), Maximum_Bars);
    string server       = AccountInfoString(ACCOUNT_SERVER);
    string company      = AccountInfoString(ACCOUNT_COMPANY);
    string terminal     = TerminalName();
    string baseCurrency = StringSubstr(symbol, 0, 3);
    string priceIn      = StringSubstr(symbol, 3, 3);

    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    int bars = 0;
    if (period == PERIOD_D1)
    {
       datetime from = D'2007.01.01 00:00';
       datetime to   = TimeCurrent();
       bars = CopyRates(symbol, period, from, to, rates);
    }
    else
    {
       bars = CopyRates(symbol, period, 0, maxBars, rates);
    }

    int      multiplier = (int) MathPow(10, digits);
    datetime millennium = D'2000.01.01 00:00';

    if (bars < 300)
        return ("");

    string time   = "";
    string open   = "";
    string high   = "";
    string low    = "";
    string close  = "";
    string volume = "";

    for (int i = bars - 1; i >= 0; i--)
    {
        StringAdd(time,   IntegerToString((rates[i].time - millennium) / 60) + ",");
        StringAdd(open,   IntegerToString((int) MathRound(rates[i].open  * multiplier)) + ",");
        StringAdd(high,   IntegerToString((int) MathRound(rates[i].high  * multiplier)) + ",");
        StringAdd(low,    IntegerToString((int) MathRound(rates[i].low   * multiplier)) + ",");
        StringAdd(close,  IntegerToString((int) MathRound(rates[i].close * multiplier)) + ",");
        StringAdd(volume, IntegerToString(rates[i].tick_volume) + ",");
    }

    time   = StringSubstr(time,   0, StringLen(time)   - 1);
    open   = StringSubstr(open,   0, StringLen(open)   - 1);
    high   = StringSubstr(high,   0, StringLen(high)   - 1);
    low    = StringSubstr(low,    0, StringLen(low)    - 1);
    close  = StringSubstr(close,  0, StringLen(close)  - 1);
    volume = StringSubstr(volume, 0, StringLen(volume) - 1);

    string data =
        "\"time\":["   + time   + "]," +
        "\"open\":["   + open   + "]," +
        "\"high\":["   + high   + "]," +
        "\"low\":["    + low    + "]," +
        "\"close\":["  + close  + "]," +
        "\"volume\":[" + volume + "]";

    string meta =
        "\"terminal\":\""     + terminal            + "\"," +
        "\"company\":\""      + company             + "\"," +
        "\"server\":\""       + server              + "\"," +
        "\"symbol\":\""       + name                + "\"," +
        "\"period\":"         + PeriodToStr(period) + "," +
        "\"baseCurrency\":\"" + baseCurrency        + "\"," +
        "\"priceIn\":\""      + priceIn             + "\"," +
        "\"lotSize\":"        + IntegerToString((int) MarketInfo(symbol, MODE_LOTSIZE))    + "," +
        "\"stopLevel\":"      + IntegerToString((int) MarketInfo(symbol, MODE_STOPLEVEL))  + "," +
        "\"tickValue\":"      + DoubleToString(MarketInfo(symbol, MODE_TICKVALUE), digits) + "," +
        "\"minLot\":"         + DoubleToString(MarketInfo(symbol, MODE_MINLOT), 2)         + "," +
        "\"maxLot\":"         + DoubleToString(MarketInfo(symbol, MODE_MAXLOT), 2)         + "," +
        "\"lotStep\":"        + DoubleToString(MarketInfo(symbol, MODE_LOTSTEP), 2)        + "," +
        "\"serverTime\":"     + IntegerToString((TimeCurrent() - millennium) / 60)         + "," +
        "\"spread\":"         + IntegerToString(Spread)                                    + "," +
        "\"digits\":"         + IntegerToString(digits)                                    + "," +
        "\"bars\":"           + IntegerToString(bars)                                      + "," +
        "\"swapLong\":"       + DoubleToString(MarketInfo(symbol, MODE_SWAPLONG), 2)       + "," +
        "\"swapShort\":"      + DoubleToString(MarketInfo(symbol, MODE_SWAPSHORT), 2)      + "," +
        "\"commission\":"     + DoubleToString(Commission, 2);

    comment += symbol + PeriodToStr(period) + ", " + IntegerToString(bars) + " bars" + "\n";
    Comment(comment);

    return ("{" + meta + "," + data + "}");
}

void SaveFile(string fileName, string data)
{
    ResetLastError();
    int file_handle = FileOpen(fileName, FILE_WRITE|FILE_IS_TEXT);
    if (file_handle != INVALID_HANDLE)
    {
        FileWrite(file_handle, data);
        FileClose(file_handle);
    }    
}

string PeriodToStr(ENUM_TIMEFRAMES period)
{
    string text;
    switch(period)
    {
        case PERIOD_M1  : text = "1";    break;
        case PERIOD_M5  : text = "5";    break;
        case PERIOD_M15 : text = "15";   break;
        case PERIOD_M30 : text = "30";   break;
        case PERIOD_H1  : text = "60";   break;
        case PERIOD_H4  : text = "240";  break;
        case PERIOD_D1  : text = "1440"; break;
        default         : text = "";
    }
    return (text);
}
