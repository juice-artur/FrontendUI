@echo off
setlocal EnableDelayedExpansion

cd /d "%~dp0"

where git >nul 2>&1
if errorlevel 1 (
    echo [ERROR] git not found in PATH.
    exit /b 1
)

where clang-format >nul 2>&1
if errorlevel 1 (
    echo [ERROR] clang-format not found in PATH.
    exit /b 1
)

if not exist ".clang-format" (
    echo [ERROR] .clang-format not found in project root.
    exit /b 1
)

set "RAW=%TEMP%\fmt_user_raw.txt"
set "SORTED=%TEMP%\fmt_user_sorted.txt"

set "AUTHOR="
for /f "delims=" %%A in ('git config user.email 2^>nul') do set "AUTHOR=%%A"
if not defined AUTHOR for /f "delims=" %%A in ('git config user.name 2^>nul') do set "AUTHOR=%%A"

if defined AUTHOR (
    git log --author="%AUTHOR%" --diff-filter=A --name-only --pretty=format: > "%RAW%" 2>nul
) else (
    git log --diff-filter=A --name-only --pretty=format: > "%RAW%" 2>nul
)

git ls-files --others --exclude-standard >> "%RAW%" 2>nul

type nul > "%SORTED%"
set "COUNT=0"
set "FAILED=0"
set "SEEN= "

for /f "usebackq delims=" %%F in ("%RAW%") do (
    set "FILE=%%F"
    set "SKIP=1"
    if /i "!FILE:~-4!"==".cpp" set "SKIP=0"
    if /i "!FILE:~-4!"==".hpp" set "SKIP=0"
    if /i "!FILE:~-4!"==".cxx" set "SKIP=0"
    if /i "!FILE:~-4!"==".inl" set "SKIP=0"
    if /i "!FILE:~-4!"==".ipp" set "SKIP=0"
    if /i "!FILE:~-3!"==".cc" set "SKIP=0"
    if /i "!FILE:~-2!"==".h" set "SKIP=0"
    if /i "!FILE:~-2!"==".c" set "SKIP=0"

    if "!SKIP!"=="0" if exist "!FILE!" (
        echo !SEEN! | findstr /c:" [!FILE!] " >nul
        if errorlevel 1 (
            set "SEEN=!SEEN! [!FILE!] "
            clang-format -i "!FILE!"
            if not errorlevel 1 (
                set /a COUNT+=1
                echo Formatted: !FILE!
            ) else (
                set /a FAILED+=1
                echo [ERROR] Failed: !FILE!
            )
        )
    )
)

del "%RAW%" "%SORTED%" 2>nul

echo.
echo Done. Formatted %COUNT% file(s), %FAILED% error(s).
endlocal
exit /b %FAILED%
