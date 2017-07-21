@echo off
call "C:\Program Files (x86)\Trade Tech MT4 Client Terminal\metaeditor.exe" /compile:"C:\Users\Henry\AppData\Roaming\MetaQuotes\Terminal\C000232C5F64AA0BDA95D52B828AF160\MQL4\Projects\Alograg\Experts\Alograg_v3.mq4"
call "C:\Program Files (x86)\Trade Tech MT4 Client Terminal\metaeditor.exe" /compile:"C:\Users\Henry\AppData\Roaming\MetaQuotes\Terminal\C000232C5F64AA0BDA95D52B828AF160\MQL4\Projects\Alograg\Experts\Alograg_v3.mq4" /log:.\compilation.log /s
type .\compilation.log
