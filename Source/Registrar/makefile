
all: testrsa

testrsa: testrsa.c
	gcc -o testrsa testrsa.c -lcrypto

keys: privkey pubkey


privkey:
	openssl genrsa -out $@
	chmod 400 $@

pubkey: privkey
	openssl rsa -pubout -in $< -out $@

clean:
	rm -f *.log *.exe *.ilk *.dll