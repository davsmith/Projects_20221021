@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
cinst poshgit
cinst visualstudio2013professional -InstallArguments "/Features:'Win8SDK WindowsPhone80 SilverLight Developer Kit' /ProductKey:XDM3T-W3T3V-MGJWK-8BFVD-GVPKY"
cinst vs2013.4