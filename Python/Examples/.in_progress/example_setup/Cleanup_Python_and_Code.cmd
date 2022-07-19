start %USERPROFILE%
start %APPDATA%
start %LOCALAPPDATA%

rmdir /s %USERPROFILE%\.virtualenvs
rmdir /s %USERPROFILE%\.pylint.d
rmdir /s %APPDATA%\Python
rmdir /s %LOCALAPPDATA%\pip
rmdir /s %LOCALAPPDATA%\pypa
rmdir /s %LOCALAPPDATA%\pipenv
rmdir /s %LOCALAPPDATA%\Programs\Python
rmdir /s %USERPROFILE%\.vscode
rmdir /s %APPDATA%\Code

