echo off
set SIGN_CMD=sign

n:
cd \usr\moshe\Development\ARSign

rem -------------------- Sign CryptoKit msi packages -------------
start %SIGN_CMD% "n:\tmp\moshe\ARX CryptoKit Basic.msi"
start %SIGN_CMD% "n:\tmp\moshe\ARX CryptoKit Basic64.msi"
start %SIGN_CMD% "n:\tmp\moshe\ARX CryptoKit Extended.msi"
start %SIGN_CMD% "n:\tmp\moshe\ARX CryptoKit Extended64.msi"
start %SIGN_CMD% "n:\tmp\moshe\ARX CryptoKit Runtime.msi"
start %SIGN_CMD% "n:\tmp\moshe\ARX CryptoKit Runtime64.msi"

