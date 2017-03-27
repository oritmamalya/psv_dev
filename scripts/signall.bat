echo off
rem -------------------- Verify params ------------------------------
if [%1] neq [] goto step1
echo Usage  : signall proj_dir
echo Example: signall d:\proj
exit /b

rem -------------------- Check if PROJ directory exists -------------
:step1
if exist %1 goto step2
echo Project directory (%1) does not exist - batch will abort
exit /b

:step2
set PROJ_DIR=%1
set SIGN_CMD=sign
set SIGNX_CMD=signx
n:
cd \usr\moshe\Development\ARSign

rem -------------------- Sign Release -------------
start %SIGN_CMD% %proj_dir%\pkcs11\dev\ar_jpk11\win32r\ar_jpk11.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\arcksso\win32r\arcksso.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\arcltsrv\win32r\arcltsrv.exe
start %SIGN_CMD% %proj_dir%\pkcs11\dev\argenie\win32r\argenie.exe
start %SIGN_CMD% %proj_dir%\pkcs11\dev\argeniedll\win32r\argenie.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\arstore\win32r\arstore.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\obj_ids\win32r\obj_ids.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\pkcs107dll\win32r\ck_pk107.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\pkcs12dll\win32r\ckpkcs12.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\sadaptor\win32r\sadaptor.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\samples\cryptosample\win32r\cryptosample.exe
start %SIGN_CMD% %proj_dir%\pkcs11\dev\samples\phl\win32r\phl.exe
start %SIGN_CMD% %proj_dir%\pkcs11\dev\samples\pkcs12\win32r\pkcs12util.exe
start %SIGN_CMD% %proj_dir%\pkcs11\dev\x509dll\win32r\ckx50932.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\cypkcs11\extended\win32r\cypkcs11.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\cypkcs11\basic\win32r\cypkcs11.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\arspe\win32r\arspe.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\arspegina\win32r\arspegina.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\arbiomoc\win32r\arbiomoc.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\arcardmod\win32r\arcardmod.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\arksp\win32r\arksp.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\arcredprov\win32r\arcredprov.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\arbiocli\win32r\arbiocli.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\argui\win32R\argui.dll
start %SIGNX_CMD% %proj_dir%\pkcs11\dev\arcsp\Win32R\arcsp.dll

rem -------------------- Sign Release64 -------------
start %SIGN_CMD% %proj_dir%\pkcs11\dev\ar_jpk11\win64r\ar_jpk11.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\arcksso\win64r\arcksso64.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\argenie\win64r\argenie64.exe
start %SIGN_CMD% %proj_dir%\pkcs11\dev\argeniedll\win64r\argenie64.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\arstore\win64r\arstore64.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\obj_ids\win64r\obj_ids64.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\pkcs107dll\win64r\ck_pk107w64.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\pkcs12dll\win64r\ckpkcs12w64.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\sadaptor\win64r\sadaptor64.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\samples\cryptosample\win64r\cryptosample64.exe
start %SIGN_CMD% %proj_dir%\pkcs11\dev\samples\phl\win64r\phl64.exe
start %SIGN_CMD% %proj_dir%\pkcs11\dev\samples\pkcs12\win64r\pkcs12util64.exe
start %SIGN_CMD% %proj_dir%\pkcs11\dev\x509dll\win64r\ckx50932w64.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\cypkcs11\extended\win64r\cypkcs11w64.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\cypkcs11\basic\win64r\cypkcs11w64.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\arspe\win64r\arspe64.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\arspegina\win64r\arspegina64.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\arbiomoc\win64r\arbiomoc64.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\arcardmod\win64r\arcardmod64.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\arksp\win64r\arksp.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\arcredprov\win64r\arcredprov64.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\arbiocli\win64r\arbiocli64.dll
start %SIGN_CMD% %proj_dir%\pkcs11\dev\argui\win64R\argui64.dll
start %SIGNX_CMD% %proj_dir%\pkcs11\dev\arcsp\Win64R\arcsp64.dll

c:


