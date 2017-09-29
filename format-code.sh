#!/bin/bash
# Formst MQL4 Files
find ./ -iname *.mq4 -o -iname *.mqh | xargs ~/.vscode/extensions/ms-vscode.cpptools-0.13.0/LLVM/bin/clang-format -i
