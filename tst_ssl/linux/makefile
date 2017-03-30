#=========================================================================
# A makefile for AR CryptoKit Linux/Unix version
# Compile pkcs_test test
#=========================================================================
os = linux

PROJROOT=/arl/n/proj/psv4/dev
CSVINCLUDE=$(PROJROOT)/common/include
ARKITINCLUDE=/arl/n/proj/arkit/dist/include
PKCS11INCLUDE=$(PROJROOT)/client/cs_pkcs/pkcs11inc

ARKIT=/arl/n/proj/arkit/dist
CSVLIB=../../../client/out/linux/
CSVLIBST=../../../client/lib/linux/
CKITLIB=$(ARKIT)/platfms/linux/extended


LIBRARY = -L$(PROJROOT)/client/lib/$(os) -lnsl -lcsv -lcsv1st 
ALLIBS  = -ldes -lhlmed -ldl -lkeymng -lpthread 
LIBS =  -L./ -L$(CKITLIB) -L$(CSVLIB) $(LIBRARY) $(ALLIBS) 

INCS = -I ../../../include -I $(CSVINCLUDE) -I $(ARKITINCLUDE) -I $(PKCS11INCLUDE) -I..

all:    tst_ssl
	echo Done

tst_ssl: tst_ssl.o 
	gcc -o tst_ssl tst_ssl.o $(LIBS)
	cp tst_ssl $(PROJROOT)/client/out/$(os)/

tst_ssl.o: ../tst_ssl.c
	gcc -DARCS_UNIX -DAR_PLATFORM=12 -DARCS_LINUX -c -g $(INCS) ../tst_ssl.c
