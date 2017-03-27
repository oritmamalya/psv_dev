echo off
rem -------------------- Verify params ------------------------------
if [%1] neq [] goto step1
echo Usage  : signdrv proj_dir
echo Example: signdrv d:\proj
exit /b

rem -------------------- Check if PROJ directory and required files exist -------------
:step1
if exist %1 goto step2
echo Project directory (%1) does not exist - batch will abort
exit /b

:step2
set PROJ_DIR=%1
set SIGN_CMD=n:\usr\moshe\Development\ARSign\sign

if exist %proj_dir%\pkcs11\dev\arcardmod\win32r\arcardmod.dll goto step3
echo File arcardmod.dll in project (%1) is missing - batch will abort
exit /b

:step3
if exist %proj_dir%\pkcs11\dev\arcardmod\win64r\arcardmod64.dll goto step4
echo File arcardmod64.dll in project (%1) is missing - batch will abort
exit /b

rem -------------------- Create and sign cat files of Minidriver -------------
:step4
cd %proj_dir%\pkcs11\dev\arcardmod\install
if exist %proj_dir%\pkcs11\dev\arcardmod\install\arcardmod.cat del %proj_dir%\pkcs11\dev\arcardmod\install\arcardmod.cat
if exist %proj_dir%\pkcs11\dev\arcardmod\install\arcardmodamd64.cat del %proj_dir%\pkcs11\dev\arcardmod\install\arcardmodamd64.cat
copy %proj_dir%\pkcs11\dev\arcardmod\win32r\arcardmod.dll 	.
copy %proj_dir%\pkcs11\dev\arcardmod\win64r\arcardmod64.dll 	.

call C:\WinDDK\6001.18001\bin\setenv.bat C:\WinDDK\6001.18001\ fre WLH
Inf2Cat /driver:%proj_dir%\pkcs11\dev\arcardmod\install /os:Vista_X86
Inf2Cat /driver:%proj_dir%\pkcs11\dev\arcardmod\install /os:Vista_X64

cd %proj_dir%\pkcs11\dev\arcardmod\install
n:\usr\moshe\Development\ARSign\SignTool sign /v /ac n:\usr\moshe\Development\ARSign\MSCV-VSClass3.cer /n Algorithmic /t http://timestamp.verisign.com/scripts/timestamp.dll arcardmod.cat
n:\usr\moshe\Development\ARSign\SignTool sign /v /ac n:\usr\moshe\Development\ARSign\MSCV-VSClass3.cer /n Algorithmic /t http://timestamp.verisign.com/scripts/timestamp.dll arcardmodamd64.cat
cd %proj_dir%\pkcs11