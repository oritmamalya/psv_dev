echo off
rem -------------------- Check if PROJ directory exists -------------
rem ------ This is new branch
if [%1]==[] goto step4
if exist %1 goto step1
echo Project directory (%1) does not exist- batch will abort
exit /b

:step1
set PROJ_DIR=%1

rem -------------------- Check environment -------------
if [%VC10_ROOT%] neq [] goto step2
echo Please set environment variable VC10_ROOT - Root directory of Visual Studio 2010
echo Usually this directory is: C:\Program Files\Microsoft Visual Studio 10.0
exit /b

:step2
if [%SDK10_ROOT%] neq [] goto step3
echo Please set environment variable SDK10_ROOT - Root directory of Platform SDK 2008
echo Usually this directory is: C:\Program Files\Microsoft SDKs\Windows\v7.0A
exit /b

:step3
if [%JAVA_ROOT%] neq [] goto step4
echo Please set environment variable JAVA_ROOT - Root directory of JAVA SDK
exit /b

rem -------------------- Verify params ------------------------------
:step4
if [%2]==[debug]     goto do_debug
if [%2]==[release]   goto do_release
if [%2]==[debug64]   goto do_debug64
if [%2]==[release64] goto do_release64
if [%2]==[clean]     goto do_clean
echo Usage  : buildall proj_dir [debug, release, debug64, release64, clean]
echo Example: buildall d:\proj release
exit /b

rem -------------------- compile debug -------------
:do_debug
set RELEASE=
set WIN64=
set comp_dir=win32d
goto do_compile

rem -------------------- compile release -------------
:do_release
set RELEASE=1
set WIN64=
set comp_dir=win32r
goto do_compile

rem -------------------- compile debug64 -------------
:do_debug64
set RELEASE=
set WIN64=1
set comp_dir=win64d
goto do_compile

rem -------------------- compile release64 -------------
:do_release64
set RELEASE=1
set WIN64=1
set comp_dir=win64r
goto do_compile

rem -------------------- clean -------------
:do_clean
rmdir /s /q %proj_dir%\pkcs11\dev\arcksso\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\arcksso\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\arcksso\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\arcksso\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\rsa_prov\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\rsa_prov\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\rsa_prov\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\rsa_prov\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\arcard\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\arcard\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\arcard\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\arcard\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\simcard\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\simcard\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\simcard\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\simcard\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\jvcard\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\jvcard\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\jvcard\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\jvcard\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\readers\ctap\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\readers\ctap\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\readers\ctap\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\readers\ctap\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\readers\pcsc\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\readers\pcsc\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\readers\pcsc\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\readers\pcsc\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\readers\prop\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\readers\prop\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\readers\prop\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\readers\prop\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\readers\psaf\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\readers\psaf\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\readers\psaf\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\readers\psaf\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\x509lib\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\x509lib\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\x509lib\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\x509lib\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\pkcs107lib\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\pkcs107lib\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\pkcs107lib\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\pkcs107lib\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\obj_ids\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\obj_ids\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\obj_ids\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\obj_ids\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\asn1\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\asn1\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\asn1\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\asn1\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\sadaptor\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\sadaptor\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\sadaptor\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\sadaptor\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\x509dll\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\x509dll\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\x509dll\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\x509dll\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\pkcs107dll\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\pkcs107dll\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\pkcs107dll\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\pkcs107dll\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\pkcs12lib\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\pkcs12lib\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\pkcs12lib\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\pkcs12lib\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\pkcs12dll\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\pkcs12dll\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\pkcs12dll\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\pkcs12dll\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\samples\phl\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\samples\phl\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\samples\phl\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\samples\phl\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\samples\cryptosample\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\samples\cryptosample\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\samples\cryptosample\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\samples\cryptosample\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\samples\pkcs12\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\samples\pkcs12\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\samples\pkcs12\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\samples\pkcs12\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\cypkcs11\extended\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\cypkcs11\extended\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\cypkcs11\extended\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\cypkcs11\extended\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\cypkcs11\basic\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\cypkcs11\basic\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\cypkcs11\basic\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\cypkcs11\basic\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\argui\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\argui\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\argui\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\argui\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\argeniedll\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\argeniedll\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\argeniedll\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\argeniedll\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\argenie\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\argenie\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\argenie\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\argenie\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\arcsp\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\arcsp\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\arcsp\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\arcsp\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\arstore\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\arstore\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\arstore\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\arstore\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\arksp\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\arksp\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\arksp\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\arksp\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\arcltsrv\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\arcltsrv\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\arcltsrv\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\arcltsrv\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\ckitlic\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\ckitlic\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\ckitlic\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\ckitlic\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\ar_jpk11\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\ar_jpk11\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\ar_jpk11\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\ar_jpk11\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\arspe\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\arspe\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\arspe\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\arspe\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\arbiomoc\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\arbiomoc\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\arbiomoc\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\arbiomoc\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\arspegina\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\arspegina\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\arspegina\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\arspegina\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\arcardmod\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\arcardmod\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\arcardmod\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\arcardmod\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\arcredprov\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\arcredprov\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\arcredprov\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\arcredprov\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\arbiocli\win32d
rmdir /s /q %proj_dir%\pkcs11\dev\arbiocli\win32r
rmdir /s /q %proj_dir%\pkcs11\dev\arbiocli\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\arbiocli\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\extlibs\win64\bna\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\extlibs\win64\bna\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\extlibs\win64\dh\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\extlibs\win64\dh\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\extlibs\win64\dsa\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\extlibs\win64\dsa\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\extlibs\win64\prg\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\extlibs\win64\prg\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\extlibs\win64\rkg\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\extlibs\win64\rkg\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\extlibs\win64\rsa\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\extlibs\win64\rsa\win64r
rmdir /s /q %proj_dir%\pkcs11\dev\extlibs\win64\sha1\win64d
rmdir /s /q %proj_dir%\pkcs11\dev\extlibs\win64\sha1\win64r
goto finish

rem -------------------- compile -------------
:do_compile
if [%WIN64%] neq [1] goto do_compile1
nmake -i %proj_dir%\pkcs11\dev\extlibs\win64\bna\bna.w32
nmake -i %proj_dir%\pkcs11\dev\extlibs\win64\dh\dh.w32
nmake -i %proj_dir%\pkcs11\dev\extlibs\win64\dsa\dsa.w32
nmake -i %proj_dir%\pkcs11\dev\extlibs\win64\prg\prg.w32
nmake -i %proj_dir%\pkcs11\dev\extlibs\win64\rkg\rkg.w32
nmake -i %proj_dir%\pkcs11\dev\extlibs\win64\rsa\rsa.w32
nmake -i %proj_dir%\pkcs11\dev\extlibs\win64\sha1\sha1.w32

:do_compile1
nmake -i %proj_dir%\pkcs11\dev\arcksso\arcksso.w32
nmake -i %proj_dir%\pkcs11\dev\rsa_prov\rsa_prov.w32
nmake -i %proj_dir%\pkcs11\dev\arcard\arcard.w32
nmake -i %proj_dir%\pkcs11\dev\simcard\simcard.w32
nmake -i %proj_dir%\pkcs11\dev\jvcard\jvcard.w32
nmake -i %proj_dir%\pkcs11\dev\readers\readers.w32
nmake -i %proj_dir%\pkcs11\dev\x509lib\x509lib.w32
nmake -i %proj_dir%\pkcs11\dev\pkcs107lib\pkcs107lib.w32
nmake -i %proj_dir%\pkcs11\dev\obj_ids\obj_ids.w32
nmake -i %proj_dir%\pkcs11\dev\asn1\asn1.w32
nmake -i %proj_dir%\pkcs11\dev\sadaptor\sadaptor.w32
nmake -i %proj_dir%\pkcs11\dev\x509dll\x509dll.w32
nmake -i %proj_dir%\pkcs11\dev\pkcs107dll\pkcs107dll.w32
nmake -i %proj_dir%\pkcs11\dev\pkcs12lib\pkcs12lib.w32
nmake -i %proj_dir%\pkcs11\dev\pkcs12dll\pkcs12dll.w32
nmake -i %proj_dir%\pkcs11\dev\samples\phl\phlmake.w32
nmake -i %proj_dir%\pkcs11\dev\samples\cryptosample\cryptosample.w32
nmake -i %proj_dir%\pkcs11\dev\samples\pkcs12\pkcs12util.w32
nmake -i %proj_dir%\pkcs11\dev\argui\argui.w32
nmake -i %proj_dir%\pkcs11\dev\argeniedll\argeniedll.w32
nmake -i %proj_dir%\pkcs11\dev\argenie\argenie.w32
nmake -i %proj_dir%\pkcs11\dev\arcsp\arcsp.w32
nmake -i %proj_dir%\pkcs11\dev\arstore\arstore.w32
nmake -i %proj_dir%\pkcs11\dev\arksp\arksp.w32
nmake -i %proj_dir%\pkcs11\dev\arcltsrv\arcltsrv.w32
nmake -i %proj_dir%\pkcs11\dev\ckitlic\ckitlic.w32
nmake -i %proj_dir%\pkcs11\dev\ar_jpk11\ar_jpk11.w32
nmake -i %proj_dir%\pkcs11\dev\arspe\arspe.w32
nmake -i %proj_dir%\pkcs11\dev\arbiomoc\arbiomoc.w32
nmake -i %proj_dir%\pkcs11\dev\arspegina\arspegina.w32
nmake -i %proj_dir%\pkcs11\dev\arcardmod\arcardmod.w32
nmake -i %proj_dir%\pkcs11\dev\arcredprov\arcredprov.w32
nmake -i %proj_dir%\pkcs11\dev\arbiocli\arbiocli.w32

set EXTENDED=1
nmake -i %proj_dir%\pkcs11\dev\cypkcs11\cypkcs11.w32
set EXTENDED=
set BASIC=1
nmake -i %proj_dir%\pkcs11\dev\cypkcs11\cypkcs11.w32
set BASIC=
goto do_check

:do_check
echo ------------ Now checking compilation results ----------------------
if [%WIN64%] neq [1] goto do_check1
if not exist %proj_dir%\pkcs11\dev\extlibs\win64\bna\%comp_dir%\bnawin64.lib echo Missing bnawin64.lib
if not exist %proj_dir%\pkcs11\dev\extlibs\win64\dh\%comp_dir%\dhwin64.lib echo Missing dhwin64.lib
if not exist %proj_dir%\pkcs11\dev\extlibs\win64\dsa\%comp_dir%\dsawin64.lib echo Missing dsawin64.lib
if not exist %proj_dir%\pkcs11\dev\extlibs\win64\prg\%comp_dir%\prgwin64.lib echo Missing prgwin64.lib
if not exist %proj_dir%\pkcs11\dev\extlibs\win64\rkg\%comp_dir%\rkgwin64.lib echo Missing rkgwin64.lib
if not exist %proj_dir%\pkcs11\dev\extlibs\win64\rsa\%comp_dir%\rsawin64.lib echo Missing rsawin64.lib
if not exist %proj_dir%\pkcs11\dev\extlibs\win64\sha1\%comp_dir%\shawin64.lib echo Missing shawin64.lib
if not exist %proj_dir%\pkcs11\dev\arcksso\%comp_dir%\arcksso64.dll echo Missing arcksso64.dll
if not exist %proj_dir%\pkcs11\dev\rsa_prov\%comp_dir%\rsa_w64.lib echo Missing rsa_w64.lib
if not exist %proj_dir%\pkcs11\dev\arcard\%comp_dir%\rcard64.lib echo Missing rcard64.lib
if not exist %proj_dir%\pkcs11\dev\simcard\%comp_dir%\Simcard64.lib echo Missing simcard64.lib
if not exist %proj_dir%\pkcs11\dev\jvcard\%comp_dir%\jvcard64.lib echo Missing jvcardd64.lib
if not exist %proj_dir%\pkcs11\dev\readers\ctap\%comp_dir%\umb_ctap64.lib echo Missing umb_ctap64.lib
if not exist %proj_dir%\pkcs11\dev\readers\pcsc\%comp_dir%\umb_pcsc64.lib echo Missing umb_pcsc64.lib
if not exist %proj_dir%\pkcs11\dev\readers\prop\%comp_dir%\umb_prop64.lib echo Missing umb_prop64.lib
if not exist %proj_dir%\pkcs11\dev\readers\psaf\%comp_dir%\umb_psaf64.lib echo Missing umb_psaf64.lib
if not exist %proj_dir%\pkcs11\dev\x509lib\%comp_dir%\x509lib64.lib echo Missing x509lib64.lib
if not exist %proj_dir%\pkcs11\dev\pkcs107lib\%comp_dir%\pkcslib64.lib echo Missing pkcslib64.lib
if not exist %proj_dir%\pkcs11\dev\obj_ids\%comp_dir%\obj_ids64.dll echo Missing obj_ids64.dll
if not exist %proj_dir%\pkcs11\dev\asn1\%comp_dir%\ar_asn1w64.lib echo Missing ar_asn1w64.lib
if not exist %proj_dir%\pkcs11\dev\sadaptor\%comp_dir%\sadaptor64.dll echo Missing sadaptor64.dll
if not exist %proj_dir%\pkcs11\dev\x509dll\%comp_dir%\ckx50932w64.dll echo Missing ckx50932w64.dll
if not exist %proj_dir%\pkcs11\dev\pkcs107dll\%comp_dir%\ck_pk107w64.dll echo Missing ck_pk107w64.dll
if not exist %proj_dir%\pkcs11\dev\pkcs12lib\%comp_dir%\pkcs12w64.lib echo Missing pkcs12w64.lib
if not exist %proj_dir%\pkcs11\dev\pkcs12dll\%comp_dir%\ckpkcs12w64.dll echo Missing ckpkcs12w64.dll
if not exist %proj_dir%\pkcs11\dev\samples\phl\%comp_dir%\phl64.exe echo Missing phl64.exe
if not exist %proj_dir%\pkcs11\dev\samples\cryptosample\%comp_dir%\cryptosample64.exe echo Missing cryptosample64.exe
if not exist %proj_dir%\pkcs11\dev\samples\pkcs12\%comp_dir%\pkcs12util64.exe echo Missing pkcs12util64.exe
if not exist %proj_dir%\pkcs11\dev\cypkcs11\extended\%comp_dir%\cypkcs11w64.dll echo Missing cypkcs11w64.dll
if not exist %proj_dir%\pkcs11\dev\cypkcs11\basic\%comp_dir%\cypkcs11w64.dll echo Missing cypkcs11w64.dll
if not exist %proj_dir%\pkcs11\dev\argui\%comp_dir%\argui64.dll echo Missing argui64.dll
if not exist %proj_dir%\pkcs11\dev\argeniedll\%comp_dir%\argenie64.dll echo Missing argenie64.dll
if not exist %proj_dir%\pkcs11\dev\argenie\%comp_dir%\argenie64.exe echo Missing argenie64.exe
if not exist %proj_dir%\pkcs11\dev\arcsp\%comp_dir%\arcsp64.dll echo Missing arcsp64.dll
if not exist %proj_dir%\pkcs11\dev\arstore\%comp_dir%\arstore64.dll echo Missing arstore64.dll
if not exist %proj_dir%\pkcs11\dev\arksp\%comp_dir%\arksp.dll echo Missing arksp.dll for 64 bit
if not exist %proj_dir%\pkcs11\dev\arcltsrv\%comp_dir%\arcltsrv64.exe echo Missing arcltsrv64.exe
if not exist %proj_dir%\pkcs11\dev\ckitlic\%comp_dir%\ckitlic64.lib echo Missing ckitlic64.lib
if not exist %proj_dir%\pkcs11\dev\ar_jpk11\%comp_dir%\ar_jpk11.dll echo Missing ar_jpk11.dll
if not exist %proj_dir%\pkcs11\dev\arspe\%comp_dir%\arspe64.dll echo Missing arspe64.dll
if not exist %proj_dir%\pkcs11\dev\arbiomoc\%comp_dir%\arbiomoc64.dll echo Missing arbiomoc64.dll
if not exist %proj_dir%\pkcs11\dev\arspegina\%comp_dir%\arspegina64.dll echo Missing arspegina64.dll
if not exist %proj_dir%\pkcs11\dev\arcardmod\%comp_dir%\arcardmod64.dll echo Missing arcardmod64.dll
if not exist %proj_dir%\pkcs11\dev\arcredprov\%comp_dir%\arcredprov64.dll echo Missing arcredprov64.dll
if not exist %proj_dir%\pkcs11\dev\arbiocli\%comp_dir%\arbiocli64.dll echo Missing arbiocli64.dll

goto finish

:do_check1
if not exist %proj_dir%\pkcs11\dev\arcksso\%comp_dir%\arcksso.dll echo Missing arcksso.dll
if not exist %proj_dir%\pkcs11\dev\rsa_prov\%comp_dir%\rsa_w32.lib echo Missing rsa_w32.lib
if not exist %proj_dir%\pkcs11\dev\ARCARD\%comp_dir%\rcard32.lib echo Missing rcard32.lib
if not exist %proj_dir%\pkcs11\dev\Simcard\%comp_dir%\simcard32.lib echo Missing simcard32.lib
if not exist %proj_dir%\pkcs11\dev\jvcard\%comp_dir%\jvcard32.lib echo Missing jvcard32.lib
if not exist %proj_dir%\pkcs11\dev\readers\ctap\%comp_dir%\umb_ctap.lib echo Missing umb_ctap.lib
if not exist %proj_dir%\pkcs11\dev\readers\pcsc\%comp_dir%\umb_pcsc.lib echo Missing umb_pcsc.lib
if not exist %proj_dir%\pkcs11\dev\readers\prop\%comp_dir%\umb_prop.lib echo Missing umb_prop.lib
if not exist %proj_dir%\pkcs11\dev\readers\psaf\%comp_dir%\umb_psaf.lib echo Missing umb_psaf.lib
if not exist %proj_dir%\pkcs11\dev\x509lib\%comp_dir%\x509lib.lib echo Missing x509lib.lib
if not exist %proj_dir%\pkcs11\dev\pkcs107lib\%comp_dir%\pkcslib.lib echo Missing pkcslib.lib
if not exist %proj_dir%\pkcs11\dev\obj_ids\%comp_dir%\obj_ids.dll echo Missing obj_ids.dll
if not exist %proj_dir%\pkcs11\dev\asn1\%comp_dir%\ar_asn1.lib echo Missing ar_asn1.lib
if not exist %proj_dir%\pkcs11\dev\sadaptor\%comp_dir%\sadaptor.dll echo Missing sadaptor.dll
if not exist %proj_dir%\pkcs11\dev\x509dll\%comp_dir%\ckx50932.dll echo Missing ckx50932.dll
if not exist %proj_dir%\pkcs11\dev\pkcs107dll\%comp_dir%\ck_pk107.dll echo Missing ck_pk107.dll
if not exist %proj_dir%\pkcs11\dev\pkcs12lib\%comp_dir%\pkcs12.lib echo Missing pkcs12.lib
if not exist %proj_dir%\pkcs11\dev\pkcs12dll\%comp_dir%\ckpkcs12.dll echo Missing ckpkcs12.dll
if not exist %proj_dir%\pkcs11\dev\samples\phl\%comp_dir%\phl.exe echo Missing phl.exe
if not exist %proj_dir%\pkcs11\dev\samples\cryptosample\%comp_dir%\cryptosample.exe echo Missing cryptosample.exe
if not exist %proj_dir%\pkcs11\dev\samples\pkcs12\%comp_dir%\pkcs12util.exe echo Missing pkcs12util.exe
if not exist %proj_dir%\pkcs11\dev\cypkcs11\extended\%comp_dir%\cypkcs11.dll echo Missing cypkcs11.dll
if not exist %proj_dir%\pkcs11\dev\cypkcs11\basic\%comp_dir%\cypkcs11.dll echo Missing cypkcs11.dll
if not exist %proj_dir%\pkcs11\dev\argui\%comp_dir%\argui.dll echo Missing argui.dll
if not exist %proj_dir%\pkcs11\dev\argeniedll\%comp_dir%\argenie.dll echo Missing argenie.dll
if not exist %proj_dir%\pkcs11\dev\argenie\%comp_dir%\argenie.exe echo Missing argenie.exe
if not exist %proj_dir%\pkcs11\dev\arcsp\%comp_dir%\arcsp.dll echo Missing arcsp.dll
if not exist %proj_dir%\pkcs11\dev\arstore\%comp_dir%\arstore.dll echo Missing arstore.dll
if not exist %proj_dir%\pkcs11\dev\arksp\%comp_dir%\arksp.dll echo Missing arksp.dll
if not exist %proj_dir%\pkcs11\dev\arcltsrv\%comp_dir%\arcltsrv.exe echo Missing arcltsrv.exe
if not exist %proj_dir%\pkcs11\dev\ckitlic\%comp_dir%\ckitlic.lib echo Missing ckitlic.lib
if not exist %proj_dir%\pkcs11\dev\ar_jpk11\%comp_dir%\ar_jpk11.dll echo Missing ar_jpk11.dll
if not exist %proj_dir%\pkcs11\dev\arspe\%comp_dir%\arspe.dll echo Missing arspe.dll
if not exist %proj_dir%\pkcs11\dev\arbiomoc\%comp_dir%\arbiomoc.dll echo Missing arbiomoc.dll
if not exist %proj_dir%\pkcs11\dev\arspegina\%comp_dir%\arspegina.dll echo Missing arspegina.dll
if not exist %proj_dir%\pkcs11\dev\arcardmod\%comp_dir%\arcardmod.dll echo Missing arcardmod.dll
if not exist %proj_dir%\pkcs11\dev\arcredprov\%comp_dir%\arcredprov.dll echo Missing arcredprov.dll
if not exist %proj_dir%\pkcs11\dev\arbiocli\%comp_dir%\arbiocli.dll echo Missing arbiocli.dll

:finish
set comp_dir=
set RELEASE=
set WIN64=
set PROJ_DIR=
