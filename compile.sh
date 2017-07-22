#!/bin/bash
# Formst MQL4 Files
./format-code.sh
wine cmd < compile-linux.cmd
sleep 15
cat -v compilation.log | tr -d '^@'
rm compilation.log
#grep error
#tr -d "0" < compilation.log
