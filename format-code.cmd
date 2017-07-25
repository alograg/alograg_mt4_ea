@echo off
for /f %%f in ('dir /s/b .\*.mq*') do C:\Users\Henry\.vscode\extensions\ms-vscode.cpptools-0.12.1\LLVM\bin\clang-format.exe -style=LLVM -i %%f
for /f %%f in ('dir /s/b .\*.TMP') do del