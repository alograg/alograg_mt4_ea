@echo off
for /f %%f in ('dir /s/b *.TMP') do del %%f
for /f %%f in ('dir /s/b *.mq*') do C:\Users\alogr\.vscode\extensions\ms-vscode.cpptools-0.15.0\LLVM\bin -style=LLVM -i %%f
for /f %%f in ('dir /s/b *.TMP') do del %%f
