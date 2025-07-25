@echo off
setlocal enabledelayedexpansion

:: Prompt for subnet
set /p SUBNET="Enter subnet to scan (e.g., 192.168.1.0/24): "

:: Define path to Nmap
set "NMAP_EXE=C:\Program Files (x86)\Nmap\nmap.exe"

:: Check Nmap exists
if not exist "!NMAP_EXE!" (
    echo Nmap not found at "!NMAP_EXE!".
    pause
    exit /b
)

:: Start discovery
echo Scanning !SUBNET! for live hosts...
"!NMAP_EXE!" -sn !SUBNET! -oG temp_results.txt >nul

:: Extract live IPs
echo Live hosts found:
> live_hosts.txt (
    for /f "tokens=2 delims= " %%A in ('findstr "Status: Up" temp_results.txt') do (
        echo %%A
    )
)

:: Display IPs
type live_hosts.txt

:: Clean up temporary file
del temp_results.txt

echo.
echo Starting aggressive scans on each host...
echo.

:: Clear previous summary
echo Open Port Summary: > scan_summary.txt

:: Loop through each IP and scan aggressively
for /f %%I in (live_hosts.txt) do (
    echo Scanning %%I ...
    "!NMAP_EXE!" -A %%I -oN scan_%%I.txt
    echo Scan complete for %%I. Saved to scan_%%I.txt

    echo Host: %%I >> scan_summary.txt
    findstr /R "^\d\+/tcp.*open" scan_%%I.txt >> scan_summary.txt
    echo ---------------------------- >> scan_summary.txt
    echo.
)

echo All scans complete.
echo Open ports summary saved to scan_summary.txt
pause
