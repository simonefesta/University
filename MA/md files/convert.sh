#!/bin/bash

pandoc Malware\ Analysis.md  -o "../Malware Analysis.pdf" --toc --variable geometry:"top=1.5cm, bottom=1.5cm, left=1.8cm, right=1.8cm"
cd ..
