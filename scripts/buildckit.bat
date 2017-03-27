echo off

rem -------------------- Get CryptoKit version ------------------------------
SET /P MAIN_DIR=Enter the CryptoKit version number, for example 4.9.0:  

rem -------------------- get Major.Minor version  -------------
for /f "tokens=1,2,3 delims=." %%a in ("%MAIN_DIR%") do SET T1=%%a&SET T2=%%b&SET T3=%%c
SET PROJ_DIR=c:\proj%T1%%T2%%T3%

rem -------------------- Check if PROJ directory exists -------------
if exist %PROJ_DIR%\pkcs11 goto step1
echo The main project directory (%PROJ_DIR%\pkcs11) doesn't exist- batch will abort
pause
exit /b

rem -------------------- Open SourceSafe -------------
:step1
SET SS_DIR=\\fs\N\PROJ\PKCS11\Freezedversions\ver%T1%.%T2%\VSS_freezed%T1%%T2%
if [%T3%]==[0] SET SS_DIR=\\fs\N\PROJ\PKCS11\VSS_DB
SET GET_KEY=
SET /P GET_KEY=Press ENTER to open SourceSafe or 0 to skip:  
if [%GET_KEY%]==[0] goto step2
start "VSS" """C:\Program Files (x86)\Microsoft Visual SourceSafe\SSEXP.EXE""" -S%SS_DIR% -Ymoshe

rem -------------------- Open 5 command windows: clean, release, release64, signall, signdrv
:step2
SET GET_KEY=
SET /P GET_KEY=Press ENTER to run %PROJ_DIR%\pkcs11\buildall.bat %PROJ_DIR% clean or 0 to skip:  
if [%GET_KEY%]==[0] goto step3
start "clean" %PROJ_DIR%\pkcs11\buildall.bat %PROJ_DIR% clean

:step3
SET GET_KEY=
SET /P GET_KEY=Press ENTER to run %PROJ_DIR%\pkcs11\buildall.bat %PROJ_DIR% release or 0 to skip:  
if [%GET_KEY%]==[0] goto step4
start "release" %PROJ_DIR%\pkcs11\buildall.bat %PROJ_DIR% release

:step4
SET GET_KEY=
SET /P GET_KEY=Press ENTER to run %PROJ_DIR%\pkcs11\buildall.bat %PROJ_DIR% release64 or 0 to skip:  
if [%GET_KEY%]==[0] goto step5
start "release64" %PROJ_DIR%\pkcs11\buildall.bat %PROJ_DIR% release64

:step5
SET GET_KEY=
SET /P GET_KEY=Press ENTER to run %PROJ_DIR%\pkcs11\signall.bat %PROJ_DIR% or 0 to skip:  
if [%GET_KEY%]==[0] goto step6
start "signall" ""%PROJ_DIR%\pkcs11\signall.bat"" %PROJ_DIR%

:step6
SET GET_KEY=
SET /P GET_KEY=Press ENTER to run %PROJ_DIR%\pkcs11\signdrv.bat %PROJ_DIR% or 0 to skip:  
if [%GET_KEY%]==[0] goto step7
start "signdrv" %PROJ_DIR%\pkcs11\signdrv.bat %PROJ_DIR% 

rem -------------------- open S:\ -------------
:step7
SET GET_KEY=
SET /P GET_KEY=Press ENTER to open s:\ or 0 to skip:  
if [%GET_KEY%]==[0] goto step8
%SystemRoot%\explorer.exe s:\

rem ------------------- handle patch version
:step8
if [%T3%]==[0] goto step8.1
echo.
echo *** Make sure you placed the freezed bin of previous version in s:\
echo *** Make sure buildbin.bat is updated to copy only files from changed projects
echo *** Make sure you updated release notes (RELEASE.TXT)
echo.

rem ------------------- run buildbin
:step8.1
SET GET_KEY=
SET /P GET_KEY=Press ENTER to run %PROJ_DIR%\pkcs11\buildbin.bat %PROJ_DIR% or 0 to skip:  
if [%GET_KEY%]==[0] goto step9
start "buildbin" %PROJ_DIR%\pkcs11\buildbin.bat %PROJ_DIR% 

rem -------------------- open Freezed dir -------------
:step9
SET GET_KEY=
SET FREEZE_DIR=N:\PROJ\PKCS11\Freezedversions\ver%T1%.%T2%\%MAIN_DIR%
SET /P GET_KEY=Press ENTER to open %FREEZE_DIR% or 0 to skip:  
if [%GET_KEY%]==[0] goto step10
if exist %FREEZE_DIR% goto step9.1

SET GET_KEY=
SET /P GET_KEY=The directoty %FREEZE_DIR% doesn't exist, create? y/N:  
if [%GET_KEY%] neq [y] goto step9.2
mkdir %FREEZE_DIR%
goto step9.1

:step9.2
echo The directory (%FREEZE_DIR%) doesn't exist- skipping step
goto step10

:step9.1
%SystemRoot%\explorer.exe %FREEZE_DIR%

rem -----------open InstallShield, n:\tmp\moshe, signmsi and DIST -----------
:step10
SET GET_KEY=
SET /P GET_KEY=Press ENTER to open InstallShield or 0 to skip:  
if [%GET_KEY%]==[0] goto step11
start "installShield" """C:\Program Files (x86)\InstallShield\2012\System\isdev.exe""" %PROJ_DIR%\pkcs11\install\MSI\Cryptokit.ism

:step11
SET GET_KEY=
SET /P GET_KEY=Press ENTER to open n:\tmp\moshe or 0 to skip:  
if [%GET_KEY%]==[0] goto step12
%SystemRoot%\explorer.exe n:\tmp\moshe

:step12
SET GET_KEY=
SET /P GET_KEY=Press ENTER to run %PROJ_DIR%\pkcs11\signmsi or 0 to skip:  
if [%GET_KEY%]==[0] goto step13
start "signmsi" %PROJ_DIR%\pkcs11\signmsi

:step13
SET GET_KEY=
SET DIST_DIR=n:\proj\pkcs11\dist\Ver%T1%.%T2%\DIST%MAIN_DIR%
SET /P GET_KEY=Press ENTER to open %DIST_DIR% or 0 to skip: 
if [%GET_KEY%]==[0] goto step14
if exist %DIST_DIR% goto step13.1

SET GET_KEY=
SET /P GET_KEY=The directoty %DIST_DIR% doesn't exist, create? y/N:  
if [%GET_KEY%] neq [y] goto step13.2
mkdir %DIST_DIR%
goto step13.1

:step13.2
echo The directory (%DIST_DIR%) doesn't exist- - skipping step
goto step14

:step13.1
%SystemRoot%\explorer.exe %DIST_DIR%

:step14
SET GET_KEY=
SET PROJ_DIR=
SET FREEZE_DIR=
SET DIST_DIR=
SET T1=
SET T2=
SET T3=
pause
