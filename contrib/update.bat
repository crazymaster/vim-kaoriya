@ECHO OFF

SET BASE_DIR=%~dp0
SET DATE_VER=%date:~-10,4%-%date:~-5,2%-%date:~-2,2%
SET LOG_FILE=%BASE_DIR%%DATE_VER%.log
SET INSTDIR_X32=%BASE_DIR%..\build\msvc\target\install-x32\
SET INSTDIR_X64=%BASE_DIR%..\build\msvc\target\install-x64\

CALL :GIT_UPDATE autofmt %BASE_DIR%autofmt
IF %ERRORLEVEL% NEQ 0 GOTO :FAILURE
CALL :GIT_UPDATE gettext %BASE_DIR%gettext :GETTEXT_HOOK
IF %ERRORLEVEL% NEQ 0 GOTO :FAILURE
CALL :GIT_UPDATE go-vim %BASE_DIR%go-vim
IF %ERRORLEVEL% NEQ 0 GOTO :FAILURE
CALL :GIT_UPDATE lang-ja %BASE_DIR%lang-ja
IF %ERRORLEVEL% NEQ 0 GOTO :FAILURE
CALL :GIT_UPDATE libiconv2 %BASE_DIR%libiconv2 :LIBICONV_HOOK
IF %ERRORLEVEL% NEQ 0 GOTO :FAILURE
CALL :GIT_UPDATE libXpm-win32 %BASE_DIR%libXpm-win32 :LIBXPM_HOOK
IF %ERRORLEVEL% NEQ 0 GOTO :FAILURE
CALL :GIT_UPDATE LuaJIT %BASE_DIR%luajit-2.0 :LUAJIT_HOOK
IF %ERRORLEVEL% NEQ 0 GOTO :FAILURE
CALL :GIT_UPDATE vimdoc-ja %BASE_DIR%vimdoc-ja
IF %ERRORLEVEL% NEQ 0 GOTO :FAILURE
CALL :GIT_UPDATE vimproc %BASE_DIR%vimproc :VIMPROC_HOOK
IF %ERRORLEVEL% NEQ 0 GOTO :FAILURE

CD %BASE_DIR%
GOTO :SUCCESS

REM ========================================================================
REM HOOKS

:GETTEXT_HOOK
CALL :DELETE_FILE %INSTDIR_X32%bin\intl.dll
CALL :DELETE_FILE %INSTDIR_X64%bin\intl.dll
EXIT /B 0

:LIBICONV_HOOK
CALL :DELETE_FILE %INSTDIR_X32%bin\iconv.dll
CALL :DELETE_FILE %INSTDIR_X64%bin\iconv.dll
EXIT /B 0

:LIBXPM_HOOK
CALL :DELETE_FILE %INSTDIR_X32%bin\libXpm.lib
CALL :DELETE_FILE %INSTDIR_X64%bin\libXpm.lib
EXIT /B 0

:LUAJIT_HOOK
CALL :DELETE_FILE %INSTDIR_X32%bin\lua51.dll
CALL :DELETE_FILE %INSTDIR_X64%bin\lua51.dll
EXIT /B 0

:VIMPROC_HOOK
CALL :DELETE_FILE %INSTDIR_X32%bin\vimproc_win32.dll
CALL :DELETE_FILE %INSTDIR_X64%bin\vimproc_win64.dll
EXIT /B 0

REM ========================================================================
REM SUB ROUTINES

:DELETE_FILE
DEL /F /Q "%1"
EXIT /B 0

:GIT_UPDATE
CD %2
git fetch -fp
IF %ERRORLEVEL% NEQ 0 GOTO :GIT_UPDATE_END
git diff --quiet ..@{u}
IF %ERRORLEVEL% EQU 0 GOTO :GIT_UPDATE_END
ECHO %1: found updates.
ECHO --------
git merge --ff --ff-only @{u}
ECHO --------
IF %ERRORLEVEL% NEQ 0 GOTO :GIT_UPDATE_END
git log -n 1 --date=short --format="%1 (%%ad %%h)" >> %LOG_FILE%
IF "%3" NEQ "" CALL %3
:GIT_UPDATE_END
EXIT /B %ERRORLEVEL%

:SUCCESS
ECHO ========
ECHO SUCCEEDED: %~nx0
PAUSE
EXIT /B 0

:FAILURE
ECHO ========
ECHO FAILED: %~nx0
PAUSE
EXIT /B %ERRORLEVEL%
