goto configGit
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
cinst poshgit 
cinst notepadplusplus
cinst kdiff3
cinst fiddler4
cinst git-credential-winstore
rem cinst visualstudio2013ultimate  -InstallArguments "/Features:'WebTools Win8SDK WindowsPhone80' /ProductKey:9FJCR-X7BKD-G84RY-QYH4P-VYYB7"
rem cinst vs2013.4
rem cinst fritzing
rem cinst inkscape

:configGit
git config --global core.editor "'c:\program files (x86)\Notepad++\notepad++.exe' -multiInst -notabbar -nosession -noPlugin"
git config --global diff.tool kdiff3
git config --global difftool.kdiff3.path "c:\program files\kdiff3\kdiff3.exe"
git config --global difftool.prompt false
git config --global user.name "Dave Smith
git config --global user.email source@seattlesmiths.com

git clone https://davsmith.visualstudio.com/DefaultCollection/_git/Tools c:\repos\tools
git clone https://davsmith.visualstudio.com/DefaultCollection/_git/Projects c:\repos\Projects
git clone https://davsmith.visualstudio.com/DefaultCollection/_git/WhereWasI c:\repos\WhereWasI
git clone https://davsmith.visualstudio.com/DefaultCollection/_git/Experiment c:\repos\Experiment


rem start "\\products\public\PRODUCTS\Applications\User\Office_2013\English\MSI\32-Bit\Office_Professional_2013\"
rem powershell add-computer -DomainName Redmond -NewName DavSmithxx -Credential redmond\davsmith
rem net localgroup administrators redmond\davsmith /add
rem restart-computer

rem http://osg/sites/jumpstart/_layouts/15/start.aspx#/SitePages/Home.aspx

rem mkdir c:\nt
rem pushd c:\nt
rem \\glacier\sdk\sdk enlist th FBL_MARKETPLACE enduser

rem Command line: %windir%\system32\cmd.exe /k c:\nt\tools\razzle.cmd
rem Start in: c:\nt