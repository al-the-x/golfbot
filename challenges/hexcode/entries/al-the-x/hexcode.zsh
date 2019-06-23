RANDOM+=1 printf '#%s\n' $(repeat 3 {printf %02X $[RANDOM%256]})
