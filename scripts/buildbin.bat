if [%2] neq [debug] echo off

rem -------------------- Verify params ------------------------------
if [%1] neq [] goto step1
echo Usage  : buildbin proj_dir 
echo Example: buildbin d:\proj
exit /b

rem -------------------- Check if PROJ directory exists -------------
:step1
if exist %1 goto step2
echo The source project directory (%1) does not exist- batch will abort
exit /b

rem -------------------- Verify that S:\ drive exists (BIN_DIR) -------------
:step2
if exist S:\ goto step3
echo S drive must be mapped to your BIN directory for the install sheild- batch will abort
exit /b

rem -------------------- Verify that S:\ drive is empty -------------
:step3
if exist S:\CRYPTOKIT goto bad_S
if exist S:\SADAPTOR goto bad_S
if exist S:\CAPI goto bad_S
if exist S:\Siemens goto bad_S
if exist S:\Resource goto bad_S
goto :step4
:bad_S
echo S drive must be empty- batch will abort
exit /b

:step4
set PROJ_DIR=%1
set BIN_DIR=S:\

rem -------------------- Confirmation ------------------------------
echo Press any key to start copying files from: %PROJ_DIR% to %BIN_DIR%
echo .
echo Drive S: is mapped to:
net use S:
echo Press CTRL-C to abort
pause

rem ------------------- Create directory structure -------------------------
md %BIN_DIR%\capi
md %BIN_DIR%\capi\win64
md %BIN_DIR%\capi\xp
md %BIN_DIR%\siemens
md %BIN_DIR%\resource
md %BIN_DIR%\sadaptor
md %BIN_DIR%\sadaptor\extended
md %BIN_DIR%\sadaptor\basic
md %BIN_DIR%\cryptokit
md %BIN_DIR%\cryptokit\cardmodule
md %BIN_DIR%\cryptokit\dll
md %BIN_DIR%\cryptokit\dll64
md %BIN_DIR%\cryptokit\doc
md %BIN_DIR%\cryptokit\include
md %BIN_DIR%\cryptokit\java
md %BIN_DIR%\cryptokit\lib
md %BIN_DIR%\cryptokit\lib64
md %BIN_DIR%\cryptokit\minikey4
md %BIN_DIR%\cryptokit\minikey5
md %BIN_DIR%\cryptokit\msm
md %BIN_DIR%\cryptokit\privatesafe
md %BIN_DIR%\cryptokit\samples
md %BIN_DIR%\cryptokit\samples\pkcs12
md %BIN_DIR%\cryptokit\samples\sample
md %BIN_DIR%\cryptokit\spe
md %BIN_DIR%\cryptokit\scfilter
md %BIN_DIR%\cryptokit\utilities
md %BIN_DIR%\cryptokit\utilities\htm

if exist %BIN_DIR% goto do_copy
echo %BIN_DIR% directory was not created - batch will abort
exit /b
if [%2]==[debug] pause

rem ------------------- Start copying files into bin -------------------------
:do_copy

rem ----------------- bin\capi ----------------------------------------------------
copy %PROJ_DIR%\pkcs11\dev\arcsp\win32r\arcsp.dll				%BIN_DIR%\capi\
copy %PROJ_DIR%\pkcs11\dev\arcsp\win64r\arcsp64.dll				%BIN_DIR%\capi\win64
copy %PROJ_DIR%\pkcs11\dev\arstore\win32r\arstore.dll				%BIN_DIR%\capi\
copy %PROJ_DIR%\pkcs11\dev\arstore\win64r\arstore64.dll				%BIN_DIR%\capi\win64
copy %PROJ_DIR%\pkcs11\dev\arksp\win32r\arksp.dll				%BIN_DIR%\capi\
copy %PROJ_DIR%\pkcs11\dev\arksp\win64r\arksp.dll				%BIN_DIR%\capi\win64
copy N:\PROJ\PKCS11\Suppliers\Microsoft\arcsp.dll				%BIN_DIR%\capi\xp
copy N:\PROJ\PKCS11\Suppliers\Microsoft\arcsp64.dll				%BIN_DIR%\capi\xp
if [%2]==[debug] pause

rem ----------------- bin\siemens ----------------------------------------------------
copy n:\proj\pkcs11\suppliers\Siemens\Files\*.*					%BIN_DIR%\siemens\
if [%2]==[debug] pause

rem ----------------- bin\sadaptor ----------------------------------------------------
copy %PROJ_DIR%\pkcs11\dev\sadaptor\win32r\sadaptor.dll			%BIN_DIR%\sadaptor\
copy %PROJ_DIR%\pkcs11\dev\obj_ids\win32r\obj_ids.dll			%BIN_DIR%\sadaptor\
copy %PROJ_DIR%\pkcs11\dev\argui\win32r\argui.dll			%BIN_DIR%\sadaptor\
copy %PROJ_DIR%\pkcs11\dev\arcltsrv\win32r\arcltsrv.exe			%BIN_DIR%\sadaptor\
copy %PROJ_DIR%\pkcs11\dev\argeniedll\win32r\argenie.dll		%BIN_DIR%\sadaptor\
copy %PROJ_DIR%\pkcs11\dev\cypkcs11\extended\win32r\cypkcs11.dll	%BIN_DIR%\sadaptor\extended\
copy %PROJ_DIR%\pkcs11\dev\sadaptor\win64r\sadaptor64.dll		%BIN_DIR%\sadaptor\
copy %PROJ_DIR%\pkcs11\dev\obj_ids\win64r\obj_ids64.dll			%BIN_DIR%\sadaptor\
copy %PROJ_DIR%\pkcs11\dev\argui\win64r\argui64.dll			%BIN_DIR%\sadaptor\
copy %PROJ_DIR%\pkcs11\dev\argeniedll\win64r\argenie64.dll		%BIN_DIR%\sadaptor\
copy %PROJ_DIR%\pkcs11\dev\cypkcs11\extended\win64r\cypkcs11w64.dll	%BIN_DIR%\sadaptor\extended\
copy n:\proj\pkcs11\install\utils\support_files\token1.sft		%BIN_DIR%\sadaptor\extended
copy n:\proj\pkcs11\install\utils\support_files\anonymous.sft		%BIN_DIR%\sadaptor
copy %PROJ_DIR%\pkcs11\dev\cypkcs11\basic\win32r\cypkcs11.dll		%BIN_DIR%\sadaptor\basic\
copy %PROJ_DIR%\pkcs11\dev\cypkcs11\basic\win64r\cypkcs11w64.dll	%BIN_DIR%\sadaptor\basic\
if [%2]==[debug] pause

rem ----------------- bin\resource ----------------------------------------------------
copy %PROJ_DIR%\pkcs11\install\resource				%BIN_DIR%\resource\	
copy n:\proj\pkcs11\install\utils\support_files\ckitinst.dll	%BIN_DIR%\resource\
if [%2]==[debug] pause

rem ----------------- bin\cryptokit\dll -------------------------------------------------
copy %PROJ_DIR%\pkcs11\dev\pkcs107dll\win32r\ck_pk107.dll		%BIN_DIR%\cryptokit\dll\
copy %PROJ_DIR%\pkcs11\dev\arcksso\win32r\arcksso.dll			%BIN_DIR%\cryptokit\dll\
copy %PROJ_DIR%\pkcs11\dev\x509dll\win32r\ckx50932.dll			%BIN_DIR%\cryptokit\dll\
copy %PROJ_DIR%\pkcs11\dev\ar_jpk11\win32r\ar_jpk11.dll			%BIN_DIR%\cryptokit\dll\
copy %PROJ_DIR%\pkcs11\dev\pkcs12dll\win32r\ckpkcs12.dll		%BIN_DIR%\cryptokit\dll\
copy n:\proj\pkcs11\suppliers\Precise\Files\win32\bsapi.dll		%BIN_DIR%\cryptokit\dll\
copy n:\proj\pkcs11\suppliers\Precise\Files\win32\pb_flex_h.dll		%BIN_DIR%\cryptokit\dll\
if [%2]==[debug] pause

rem ----------------- bin\cryptokit\dll64 -------------------------------------------------
copy %PROJ_DIR%\pkcs11\dev\pkcs107dll\win64r\ck_pk107w64.dll		%BIN_DIR%\cryptokit\dll64\
copy %PROJ_DIR%\pkcs11\dev\arcksso\win64r\arcksso64.dll			%BIN_DIR%\cryptokit\dll64\
copy %PROJ_DIR%\pkcs11\dev\x509dll\win64r\ckx50932w64.dll		%BIN_DIR%\cryptokit\dll64\
copy %PROJ_DIR%\pkcs11\dev\pkcs12dll\win64r\ckpkcs12w64.dll		%BIN_DIR%\cryptokit\dll64\
copy %PROJ_DIR%\pkcs11\dev\ar_jpk11\win64r\ar_jpk11.dll			%BIN_DIR%\cryptokit\dll64\
copy n:\proj\pkcs11\suppliers\Precise\Files\win64\bsapi.dll		%BIN_DIR%\cryptokit\dll64\
copy n:\proj\pkcs11\suppliers\Precise\Files\win64\pb_flex_h.dll		%BIN_DIR%\cryptokit\dll64\
if [%2]==[debug] pause

rem ----------------- bin\cryptokit\doc -------------------------------------------------
copy n:\proj\pkcs11\doc\Ckit_390.pdf					%BIN_DIR%\cryptokit\doc\
copy n:\proj\pkcs11\doc\release.txt					%BIN_DIR%\cryptokit\doc\
if [%2]==[debug] pause

rem ----------------- bin\cryptokit\include --------------------------------------------
copy %PROJ_DIR%\pkcs11\include\*.h							%BIN_DIR%\cryptokit\include\
copy %PROJ_DIR%\pkcs11\dev\pkcs12dll\include\ckpkcs12.h		%BIN_DIR%\cryptokit\include\
if [%2]==[debug] pause

rem ----------------- bin\cryptokit\java ------------------------------------------------
copy n:\proj\pkcs11\install\utils\Java\*.*				%BIN_DIR%\cryptokit\java\
if [%2]==[debug] pause

rem ----------------- bin\cryptokit\lib -------------------------------------------------
copy %PROJ_DIR%\pkcs11\dev\sadaptor\win32r\sadaptor.lib				%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\sadaptor\win32r\sadaptor.map				%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\cypkcs11\extended\win32r\cypkcs11.lib		%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\cypkcs11\extended\win32r\cypkcs11.map		%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\pkcs107dll\win32r\ck_pk107.lib			%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\x509dll\win32r\ckx50932.lib				%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\pkcs12dll\win32r\ckpkcs12.lib			%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\arcard\win32r\rcard32.lib				%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\Simcard\win32r\Simcard32.lib				%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\jvcard\win32r\jvcard32.lib				%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\arcsp\win32r\arcsp.lib				%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\arksp\win32r\arksp.lib				%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\arspe\win32r\arspe.lib				%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\arspegina\win32r\arspegina.lib			%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\arbiomoc\win32r\arbiomoc.lib				%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\arstore\win32r\arstore.lib				%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\arcksso\win32r\arcksso.lib				%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\asn1\win32r\ar_asn1.lib				%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\argui\win32r\argui.lib				%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\argeniedll\win32r\argenie.lib			%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\ckitlic\win32r\ckitlic.lib				%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\obj_ids\win32r\obj_ids.lib				%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\obj_ids\win32r\obj_idslib.lib			%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\pkcs107lib\win32r\pkcslib.lib			%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\pkcs12lib\win32r\pkcs12.lib				%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\readers\ctap\win32r\umb_ctap.lib			%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\readers\pcsc\win32r\umb_pcsc.lib			%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\readers\prop\win32r\umb_prop.lib			%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\readers\psaf\win32r\umb_psaf.lib			%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\rsa_prov\win32r\rsa_w32.lib				%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\x509lib\win32r\x509lib.lib				%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\extlibs\dhwin32.lib					%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\extlibs\dsawin32.lib					%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\extlibs\shawin32.lib					%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\extlibs\rsawin32.lib					%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\extlibs\bnawin32.lib					%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\extlibs\prgwin32.lib					%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\extlibs\rdmwin32.lib					%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\extlibs\gdhwin32.lib					%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\extlibs\gdsawin32.lib				%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\extlibs\rkgwin32.lib					%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\extlibs\rstc.lib					%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\extlibs\frsa.lib					%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\extlibs\SAPI\lib\sapicrypt.lib			%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\extlibs\SAPI\lib\sapium.lib				%BIN_DIR%\cryptokit\lib\
copy %PROJ_DIR%\pkcs11\dev\extlibs\precise\win32\pb_flex_h.lib			%BIN_DIR%\cryptokit\lib\
if [%2]==[debug] pause

rem ----------------- bin\cryptokit\lib64 -------------------------------------------------
copy %PROJ_DIR%\pkcs11\dev\sadaptor\win64r\sadaptor64.lib			%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\sadaptor\win64r\sadaptor64.map			%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\cypkcs11\extended\win64r\cypkcs11w64.lib		%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\cypkcs11\extended\win64r\cypkcs11w64.map		%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\pkcs107dll\win64r\ck_pk107w64.lib			%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\x509dll\win64r\ckx50932w64.lib			%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\pkcs12dll\win64r\ckpkcs12w64.lib			%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\arcard\win64r\rcard64.lib				%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\simcard\win64r\simcard64.lib				%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\jvcard\win64r\jvcard64.lib				%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\arcsp\win64r\arcsp64.lib				%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\arksp\win64r\arksp.lib				%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\arspe\win64r\arspe64.lib				%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\arspegina\win64r\arspegina64.lib			%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\arbiomoc\win64r\arbiomoc64.lib			%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\arstore\win64r\arstore64.lib				%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\arcksso\win64r\arcksso64.lib				%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\asn1\win64r\ar_asn1w64.lib				%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\argui\win64r\argui64.lib				%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\argeniedll\win64r\argenie64.lib			%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\ckitlic\win64r\ckitlic64.lib				%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\obj_ids\win64r\obj_ids64.lib				%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\obj_ids\win64r\obj_idslib64.lib			%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\pkcs107lib\win64r\pkcslib64.lib			%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\pkcs12lib\win64r\pkcs12w64.lib			%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\readers\ctap\win64r\umb_ctap64.lib			%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\readers\pcsc\win64r\umb_pcsc64.lib			%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\readers\prop\win64r\umb_prop64.lib			%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\readers\psaf\win64r\umb_psaf64.lib			%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\rsa_prov\win64r\rsa_w64.lib				%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\x509lib\win64r\x509lib64.lib				%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\extlibs\win64\dh\win64R\dhwin64.lib			%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\extlibs\win64\dsa\win64R\dsawin64.lib		%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\extlibs\win64\sha1\win64R\shawin64.lib		%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\extlibs\win64\rsa\win64R\rsawin64.lib		%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\extlibs\win64\bna\win64R\bnawin64.lib		%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\extlibs\win64\prg\win64R\prgwin64.lib		%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\extlibs\win64\rkg\win64R\rkgwin64.lib 	        %BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\extlibs\frsa64.lib							%BIN_DIR%\cryptokit\lib64\
copy %PROJ_DIR%\pkcs11\dev\extlibs\precise\win64\pb_flex_h.lib			%BIN_DIR%\cryptokit\lib64\
if [%2]==[debug] pause

rem ----------------- bin\cryptokit\minikey4-------------------------------------------
copy n:\proj\pkcs11\suppliers\Eutron\MINIKEY4\UMB_EUT.DLL			%BIN_DIR%\cryptokit\minikey4\
copy n:\proj\pkcs11\suppliers\Eutron\MINIKEY4\Driver2000\WebId4.inf		%BIN_DIR%\cryptokit\minikey4\
copy n:\proj\pkcs11\suppliers\Eutron\MINIKEY4\Driver2000\WebId4.sys		%BIN_DIR%\cryptokit\minikey4\
if [%2]==[debug] pause

rem ----------------- bin\cryptokit\minikey5-------------------------------------------
xcopy n:\proj\pkcs11\suppliers\eutron\minikey5				%BIN_DIR%\cryptokit\minikey5\	/y/s/i
if [%2]==[debug] pause

rem ----------------- bin\cryptokit\msm -------------------------------------------
copy n:\proj\pkcs11\suppliers\aladdin\files\*.*				%BIN_DIR%\cryptokit\msm\
if [%2]==[debug] pause

rem ----------------- bin\cryptokit\cardmodule -------------------------------------------
copy %PROJ_DIR%\pkcs11\dev\arcardmod\win32r\arcardmod.dll		%BIN_DIR%\cryptokit\cardmodule\
copy %PROJ_DIR%\pkcs11\dev\arcardmod\win64r\arcardmod64.dll		%BIN_DIR%\cryptokit\cardmodule\
copy %PROJ_DIR%\pkcs11\dev\arcardmod\install\arcardmod.inf		%BIN_DIR%\cryptokit\cardmodule\
copy %PROJ_DIR%\pkcs11\dev\arcardmod\install\arcardmod.cat		%BIN_DIR%\cryptokit\cardmodule\
copy %PROJ_DIR%\pkcs11\dev\arcardmod\install\arcardmodamd64.cat		%BIN_DIR%\cryptokit\cardmodule\
copy %PROJ_DIR%\pkcs11\dev\arcredprov\win32r\arcredprov.dll		%BIN_DIR%\cryptokit\cardmodule\
copy %PROJ_DIR%\pkcs11\dev\arcredprov\win64r\arcredprov64.dll		%BIN_DIR%\cryptokit\cardmodule\

if [%2]==[debug] pause

rem ----------------- bin\cryptokit\privatesafe ---------------------------------------
xcopy n:\proj\safe\dev\pc\drv\drv_pcsc\install\*.*					%BIN_DIR%\cryptokit\privatesafe		/y/s/i
if [%2]==[debug] pause

rem ----------------- bin\cryptokit\samples -------------------------------------------
xcopy %PROJ_DIR%\pkcs11\dev\samples\phl\*.w32						%BIN_DIR%\cryptokit\samples\phl			/y/s/i
xcopy %PROJ_DIR%\pkcs11\dev\samples\phl\*.c						%BIN_DIR%\cryptokit\samples\phl			/y/s/i
xcopy %PROJ_DIR%\pkcs11\dev\samples\phl\*.h						%BIN_DIR%\cryptokit\samples\phl			/y/s/i
xcopy %PROJ_DIR%\pkcs11\dev\samples\phl\*.rc						%BIN_DIR%\cryptokit\samples\phl			/y/s/i
copy %PROJ_DIR%\pkcs11\dev\samples\phl\win32r\phl.exe					%BIN_DIR%\cryptokit\samples\phl
copy %PROJ_DIR%\pkcs11\dev\samples\phl\win64r\phl64.exe					%BIN_DIR%\cryptokit\samples\phl
xcopy %PROJ_DIR%\pkcs11\dev\samples\pkcs107\*.w32					%BIN_DIR%\cryptokit\samples\pkcs107		/y/s/i
xcopy %PROJ_DIR%\pkcs11\dev\samples\pkcs107\*.c						%BIN_DIR%\cryptokit\samples\pkcs107		/y/s/i
xcopy %PROJ_DIR%\pkcs11\dev\samples\pkcs107\*.txt					%BIN_DIR%\cryptokit\samples\pkcs107		/y/s/i
xcopy %PROJ_DIR%\pkcs11\dev\samples\pkcs11\*.w32					%BIN_DIR%\cryptokit\samples\pkcs11		/y/s/i
xcopy %PROJ_DIR%\pkcs11\dev\samples\pkcs11\*.c						%BIN_DIR%\cryptokit\samples\pkcs11		/y/s/i
xcopy %PROJ_DIR%\pkcs11\dev\samples\pkcs11\*.cpp					%BIN_DIR%\cryptokit\samples\pkcs11		/y/s/i
xcopy %PROJ_DIR%\pkcs11\dev\samples\pkcs11\*.txt					%BIN_DIR%\cryptokit\samples\pkcs11		/y/s/i
copy %PROJ_DIR%\pkcs11\dev\samples\pkcs12\src\pkcs12util.c				%BIN_DIR%\cryptokit\samples\pkcs12\
xcopy %PROJ_DIR%\pkcs11\dev\samples\cryptosample\*.w32					%BIN_DIR%\cryptokit\samples\sample\		/y/s/i
xcopy %PROJ_DIR%\pkcs11\dev\samples\cryptosample\*.h					%BIN_DIR%\cryptokit\samples\sample\		/y/s/i
xcopy %PROJ_DIR%\pkcs11\dev\samples\cryptosample\*.bmp					%BIN_DIR%\cryptokit\samples\sample\		/y/s/i
xcopy %PROJ_DIR%\pkcs11\dev\samples\cryptosample\*.ico					%BIN_DIR%\cryptokit\samples\sample\		/y/s/i
xcopy %PROJ_DIR%\pkcs11\dev\samples\cryptosample\*.cpp					%BIN_DIR%\cryptokit\samples\sample\		/y/s/i
xcopy %PROJ_DIR%\pkcs11\dev\samples\cryptosample\*.rc					%BIN_DIR%\cryptokit\samples\sample\		/y/s/i
copy %PROJ_DIR%\pkcs11\dev\samples\cryptosample\win32r\cryptoSample.exe 		%BIN_DIR%\cryptokit\samples\sample
copy %PROJ_DIR%\pkcs11\dev\samples\cryptosample\win64r\cryptoSample64.exe 		%BIN_DIR%\cryptokit\samples\sample
xcopy %PROJ_DIR%\pkcs11\dev\samples\x509\*.w32						%BIN_DIR%\cryptokit\samples\x509		/y/s/i
xcopy %PROJ_DIR%\pkcs11\dev\samples\x509\*.txt						%BIN_DIR%\cryptokit\samples\x509		/y/s/i
xcopy %PROJ_DIR%\pkcs11\dev\samples\x509\certs\*.ber					%BIN_DIR%\cryptokit\samples\x509\certs	/y/s/i
xcopy %PROJ_DIR%\pkcs11\dev\samples\x509\*.c						%BIN_DIR%\cryptokit\samples\x509		/y/s/i
xcopy %PROJ_DIR%\pkcs11\dev\samples\x509\*.h						%BIN_DIR%\cryptokit\samples\x509		/y/s/i
xcopy %PROJ_DIR%\pkcs11\dev\samples\x509\*.ico						%BIN_DIR%\cryptokit\samples\x509		/y/s/i
xcopy %PROJ_DIR%\pkcs11\dev\samples\x509\*.rc						%BIN_DIR%\cryptokit\samples\x509		/y/s/i
if [%2]==[debug] pause

rem ----------------- bin\cryptokit\scfilter----------------------------------------
copy n:\proj\pkcs11\install\utils\support_files\ArScFilter.sys				%BIN_DIR%\cryptokit\scfilter
if [%2]==[debug] pause

rem ----------------- bin\cryptokit\utilities ---------------------------------------------
copy %PROJ_DIR%\pkcs11\dev\samples\pkcs12\win32r\pkcs12util.exe			%BIN_DIR%\cryptokit\utilities\
copy %PROJ_DIR%\pkcs11\dev\argenie\win32r\argenie.exe				%BIN_DIR%\cryptokit\utilities\
copy %PROJ_DIR%\pkcs11\dev\samples\pkcs12\win64r\pkcs12util64.exe		%BIN_DIR%\cryptokit\utilities\
copy %PROJ_DIR%\pkcs11\dev\argenie\win64r\argenie64.exe				%BIN_DIR%\cryptokit\utilities\

copy %PROJ_DIR%\pkcs11\dev\argenie\htm\*.*					%BIN_DIR%\cryptokit\utilities\htm\
copy n:\proj\pkcs11\install\utils\support_files\dlmload.exe			%BIN_DIR%\cryptokit\utilities\
copy n:\proj\pkcs11\install\utils\support_files\CkitUninst.exe			%BIN_DIR%\cryptokit\utilities\
if [%2]==[debug] pause

rem ----------------- bin\cryptokit\spe ---------------------------------------------
copy %PROJ_DIR%\pkcs11\dev\arspe\win32r\arspe.dll			%BIN_DIR%\cryptokit\spe\
copy %PROJ_DIR%\pkcs11\dev\arspegina\win32r\arspegina.dll		%BIN_DIR%\cryptokit\spe\
copy %PROJ_DIR%\pkcs11\dev\arbiomoc\win32r\arbiomoc.dll			%BIN_DIR%\cryptokit\spe\
copy %PROJ_DIR%\pkcs11\dev\arbiocli\win32r\arbiocli.dll			%BIN_DIR%\cryptokit\spe\
copy %PROJ_DIR%\pkcs11\dev\arspe\win64r\arspe64.dll			%BIN_DIR%\cryptokit\spe\
copy %PROJ_DIR%\pkcs11\dev\arspegina\win64r\arspegina64.dll		%BIN_DIR%\cryptokit\spe\
copy %PROJ_DIR%\pkcs11\dev\arbiomoc\win64r\arbiomoc64.dll		%BIN_DIR%\cryptokit\spe\
copy %PROJ_DIR%\pkcs11\dev\arbiocli\win64r\arbiocli64.dll		%BIN_DIR%\cryptokit\spe\
if [%2]==[debug] pause


