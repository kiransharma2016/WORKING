combime two lines
awk 'NR%2{printf "%s ",$0;next;}1' file to be processed

