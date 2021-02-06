getting md5 of rsa key( private key) and crt public key 
# openssl rsa -noout -modulus -in server.key | openssl md5
# openssl x509 -noout -modulus -in server.crt | openssl md5


Also, 

openssl x509 -in file -subject -issuer -noout
