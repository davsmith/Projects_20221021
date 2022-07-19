rem
rem FixACLs
rem
rem Used in resetting ACLs for files which have been locked by HomeGroup
rem
rem Usage:  FixACLs <files>
rem
rem Example:  FixACLs c:\LiveDog\*.*
rem
rem Updated 12/27/2011
rem

set TOOLPATH= %ProgramFiles(x86)%\Windows Resource Kits\Tools
echo Setting tool directory to %TOOLPATH%
PUSHD %TOOLPATH%
rem subinacl /subdirectories "%1" /setowner=%userdomain%\%username% /grant=everyone=F /cleandeletedsidsfrom=DAVSMITHC
subinacl /subdirectories "%1" /setowner=%userdomain%\%username% /grant=everyone=F
popd