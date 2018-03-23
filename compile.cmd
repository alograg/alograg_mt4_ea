@echo off
call format-code.cmd
call "C:\Program Files (x86)\MetaTrader 4 IC Markets\metaeditor.exe" /compile:"C:\Users\Henry\AppData\Roaming\MetaQuotes\Terminal\C000232C5F64AA0BDA95D52B828AF160\MQL4\Projects\Alograg\Experts\Alograg_v4.mq4"
call "C:\Program Files (x86)\MetaTrader 4 IC Markets\metaeditor.exe" /compile:"C:\Users\Henry\AppData\Roaming\MetaQuotes\Terminal\C000232C5F64AA0BDA95D52B828AF160\MQL4\Projects\Alograg\Experts\Alograg_v4.mq4" /log:.\compilation.log /s
type .\compilation.log
del .\compilation.log
