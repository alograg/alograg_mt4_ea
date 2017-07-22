#!/bin/bash
# Formst MQL4 Files
find ./ -iname *.mq4 -o -iname *.mqh | xargs clang-format -i
