@echo off
for /f %%f in ('dir /s/b *.TMP') do del %%f
for /f %%f in ('dir /s/b *.mq*') do C:\Users\Henry\.vscode\extensions\ms-vscode.cpptools-0.13.0\LLVM\bin\clang-format.exe -style=LLVM -i %%f
for /f %%f in ('dir /s/b *.TMP') do del %%f
