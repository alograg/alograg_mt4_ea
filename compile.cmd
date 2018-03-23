@echo off
REM call format-code.cmd
call "C:\Program Files (x86)\MetaTrader 4 IC Markets\metaeditor.exe" /compile:"C:\Users\alogr\AppData\Roaming\MetaQuotes\Terminal\1DAFD9A7C67DC84FE37EAA1FC1E5CF75\MQL4\Projects\alograg_mt4_ea\Experts\Alograg_v5.mq4"
call "C:\Program Files (x86)\MetaTrader 4 IC Markets\metaeditor.exe" /compile:"C:\Users\alogr\AppData\Roaming\MetaQuotes\Terminal\1DAFD9A7C67DC84FE37EAA1FC1E5CF75\MQL4\Projects\alograg_mt4_ea\Experts\Alograg_v5.mq4" /log:.\compilation.log /s
type .\compilation.log
del .\compilation.log
