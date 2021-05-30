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


# 'greap a string with different part eg abcd(right|left)[1--3]end


  
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

  
