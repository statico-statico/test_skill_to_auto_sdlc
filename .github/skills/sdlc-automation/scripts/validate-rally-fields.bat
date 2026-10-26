@echo off
rem ==============================================================================
rem Script: validate-rally-fields.bat
rem Purpose: Validate the integrity of fields extracted from Rally WSAPI and
rem          enforce state machine rules before processing (Windows Batch).
rem Exit codes:
rem   0 - Validation successful (Ready for processing)
rem   1 - Error: Missing or malformed required fields
rem   2 - Critical error: Artifact in 'Accepted' state (Immutable, abort)
rem   3 - Warning: Artifact in 'Completed' state (Requires human confirmation)
rem ==============================================================================

setlocal EnableDelayedExpansion

set "INPUT_FILE=%~1"

if "%INPUT_FILE%"=="" (
    echo ERROR: A JSON file parameter is required. >&2
    echo Usage: %~nx0 ^<rally-payload.json^> >&2
    exit /b 1
)

if not exist "%INPUT_FILE%" (
    echo ERROR: File '%INPUT_FILE%' does not exist. >&2
    exit /b 1
)

echo ==^> Validating Rally artifact...

rem Extract key fields in a single fast PowerShell invocation
for /f "usebackq tokens=1,2* delims=|" %%A in (`powershell -NoProfile -Command "$c = Get-Content -Raw -Path '%INPUT_FILE%' | ConvertFrom-Json; Write-Output ($c.FormattedID + '|' + $c.ScheduleState + '|' + $c.Name)" 2^>nul`) do (
    set "FORMATTED_ID=%%A"
    set "SCHEDULE_STATE=%%B"
    set "NAME=%%C"
)

rem 1. Validate FormattedID presence and format
if "%FORMATTED_ID%"=="" (
    echo [ERROR]: 'FormattedID' is required and was not found. >&2
    exit /b 1
)

for /f "tokens=*" %%m in ('powershell -NoProfile -Command "if ('%FORMATTED_ID%' -match '^(US|DE)[0-9]+$') { 'VALID' } else { 'INVALID' }"') do (
    if "%%m"=="INVALID" (
        echo [WARNING]: 'FormattedID' ^(%FORMATTED_ID%^) does not match standard pattern ^(US12345 or DE12345^). >&2
    )
)

rem 2. Validate Name / Title presence
if "%NAME%"=="" (
    echo [ERROR]: 'Name' field is empty. >&2
    exit /b 1
)

rem 3. Validate ScheduleState
if "%SCHEDULE_STATE%"=="" (
    echo [WARNING]: 'ScheduleState' not defined. Defaulting to 'Defined'. >&2
    set "SCHEDULE_STATE=Defined"
)

echo     - FormattedID:    %FORMATTED_ID%
echo     - Name:           %NAME%
echo     - ScheduleState:  %SCHEDULE_STATE%

if /i "%SCHEDULE_STATE%"=="Accepted" (
    echo [CRITICAL ERROR] [Code 2]: Artifact %FORMATTED_ID% is already in 'Accepted' state. >&2
    echo     Accepted stories are immutable per compliance and audit policies. >&2
    echo     ABORTING process. >&2
    exit /b 2
)

if /i "%SCHEDULE_STATE%"=="Completed" (
    echo [WARNING] [Code 3]: Artifact %FORMATTED_ID% is already marked as 'Completed'. >&2
    echo     Explicit human confirmation is required to re-process. >&2
    exit /b 3
)

if /i "%SCHEDULE_STATE%"=="Defined" (
    echo [OK]: Artifact ready. Transitioning 'Defined' -^> 'In-Progress'.
    exit /b 0
)

if /i "%SCHEDULE_STATE%"=="In-Progress" (
    echo [OK]: Artifact already 'In-Progress'. Continuing development.
    exit /b 0
)

echo [WARNING]: State '%SCHEDULE_STATE%' is non-standard but processable.
exit /b 0
