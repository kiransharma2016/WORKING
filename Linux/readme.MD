combile two files
paste -d'\n' <frst file > <second file>  > output_file 

take tcp dump of container 


CID=container id ( will update later)
run this 

server 
tcpdump


make ip as ifconfig
alias ifconfig="ip -c a | sed -e 's/\// \//g'"



ssh to execute command that need sudo and passwrod 

----------openssl list cert
openssl -in file -issuers -subject -dates -noout 
  
Regex
https://unix.stackexchange.com/questions/163726/limit-grep-context-to-n-characters-on-line
  
file: sharma,kiran\
  neupane,mina\
  named: file\
sed -r 's/([a-zA-Z]+)\,([a-zA-Z]+)/\2 \1/g' file\
kiran sharma\
mina neupane


 Formatting clock
  [root@centos regex]# cat file2 \
7:32 \
1:22 

[root@centos regex]# sed -r 's/([0-9]{1,2}):([0-9]{2})/\1 min \2 sec/g' file2 \
7 min 32 sec \
1 min 22 sec

One more 
  
echo "123-456-7890" | sed -r 's/[0-9]{3}\-[0-9]{3}\-([0-9]{4})/###-### \1 /g'
###-### 7890

slight different format\
echo "(123)-456-7890" | sed  -r 's/\([0-9]{3}\)\-[0-9]{3}\-([0-9]{4})/###-### \1 /g'
###-### 7890
 
extract zipcode from state and zip 
echo "NY 20102" |sed -r 's/([A-Z]+)\s+([0-9]{5})/\2/g'
  
Listing only directory 
  
  
  ls -l |grep '^d'
  
