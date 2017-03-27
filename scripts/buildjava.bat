echo off
rem -------------------- Verify params ------------------------------
if [%2] neq [] goto step1
echo Usage  : buildjava proj_dir version
echo Example: buildjava d:\proj "4,3,0,1"
echo Note   : Version number must have the form "Major,Minor,MinorMinor,1"
exit /b

rem -------------------- Check environment -------------
:step1
if exist "%JAVA_ROOT%\bin\javac.exe" goto step2
echo Please set environment variable JAVA_ROOT - Root dir of JAVA (d:\progra~1\j2sdk1.4.1_01)
exit /b

rem -------------------- Check if PROJ directory exists -------------
:step2
if exist %1 goto step3
echo Project directory (%1) does not exist- batch will abort
exit /b

rem -------------------- Check if dev\java directory exists -------------
:step3
set proj_dir=%1\pkcs11\dev
if exist %proj_dir%\java goto step4
echo Java directory (%proj_dir%\java) does not exist- batch will abort
exit /b

rem -------------------- Check if dev\jca directory exists -------------
:step4
if exist %proj_dir%\jca goto start
echo JCA directory (%proj_dir%\jca) does not exist- batch will abort
exit /b

rem -------------------- Clean ----------------------
:start
echo Deleting files ...
del %proj_dir%\java\COM\arx\jpkcs11\*.class /s/q 
del %proj_dir%\java\dist\*.* /s/q 
del %proj_dir%\java\doc\*.* /s/q 
rmdir %proj_dir%\java\doc\COM /s/q 
del %proj_dir%\jca\COM\arx\jca\*.class /s/q 
del %proj_dir%\jca\dist\*.* /s/q 
mkdir %proj_dir%\java\dist
mkdir %proj_dir%\jca\dist
if [%3]==[debug] pause

rem -------------------- Compile ckit.jar ----------------------
echo Compiling ckit.jar ...
cd %proj_dir%\java
attrib -r *.* /s
%JAVA_ROOT%\bin\javac -classpath . -deprecation -g:none -O COM\arx\jpkcs11\*.java
%JAVA_ROOT%\bin\javac -classpath . -deprecation -g:none -O COM\arx\jpkcs11\Native\*.java
%JAVA_ROOT%\bin\jar -cvf %proj_dir%\java\dist\ckit.jar COM\arx\jpkcs11\*.class COM\arx\jpkcs11\Native\*.class
%proj_dir%\java\utils\dubuild %proj_dir%\java\dist\ckit.cab . /D "CryptoKit" /I *AR_*.class /S COM.arx.jpkcs11 /V %2
if [%3]==[debug] pause

rem -------------------- Make Doc for ckit.jat ----------------------
echo Creating Ckit Doc ...
cd %proj_dir%\java
%JAVA_ROOT%\bin\javadoc -d DOC -use -package COM.arx.jpkcs11 COM.arx.jpkcs11.Native
cd doc
%proj_dir%\java\utils\zip -v -r %proj_dir%\java\dist\CKIT-JPKCS11-DOC.zip .
if [%3]==[debug] pause

rem -------------------- Compile arjca.jar ----------------------
echo Compiling arjca.jar ...
cd %proj_dir%\jca
attrib -r *.* /s
%JAVA_ROOT%\bin\javac -classpath ..\java -deprecation -g:none -O src\COM\arx\jca\*.java -d %proj_dir%\jca 
%JAVA_ROOT%\bin\jar -cvf %proj_dir%\jca\dist\arjca.jar COM\arx\jca\*.class
%proj_dir%\java\utils\dubuild %proj_dir%\jca\dist\arjca.cab . /D "ARJCA" /I *ARJCA*.class /S COM.arx.jca /V %2
if [%3]==[debug] pause

rem -------------------- Sign arjca.jar ----------------------
%JAVA_ROOT%\bin\jarsigner -keystore ".keystore" -storepass 12345678 -keypass 12345678 %proj_dir%\jca\dist\arjca.jar "algorithmic research ltd.'s jce code signing ca id" 
%JAVA_ROOT%\bin\jarsigner -verify -keystore ".keystore" -storepass 12345678 -keypass 12345678 %proj_dir%\jca\dist\arjca.jar "algorithmic research ltd.'s jce code signing ca id" 
if [%3]==[debug] pause

rem -------------------- Sign CAB Files ----------------------
n:
cd N:\USR\MOSHE\Development\ARSign
start signjava %proj_dir%\java\dist\ckit.cab
start signjava %proj_dir%\jca\dist\arjca.cab
if [%3]==[debug] pause

cd %1\pkcs11

