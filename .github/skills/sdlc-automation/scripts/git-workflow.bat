@echo off
rem ==============================================================================
rem Script: git-workflow.bat
rem Purpose: Automate Git and GitLab CLI workflow on Windows:
rem          Branch creation, conventional commit, remote push, and Draft MR generation.
rem Parameters:
rem   %1 - Rally FormattedID (e.g. US10293)
rem   %2 - Requirement title (e.g. "Implement Session Timeout Warning")
rem   %3 - Target branch (optional, default: main)
rem   %4 - MR description file (optional, default: .docs\report.md)
rem ==============================================================================

setlocal EnableDelayedExpansion

set "FORMATTED_ID=%~1"
set "TITLE=%~2"
set "TARGET_BRANCH=%~3"
if "%TARGET_BRANCH%"=="" set "TARGET_BRANCH=main"
set "DESC_FILE=%~4"
if "%DESC_FILE%"=="" set "DESC_FILE=.docs\report.md"

if "%FORMATTED_ID%"=="" (
    echo ERROR: Missing required parameters. >&2
    echo Usage: %~nx0 ^<FormattedID^> ^<Title^> [TargetBranch] [DescriptionFile] >&2
    exit /b 1
)

if "%TITLE%"=="" (
    echo ERROR: Missing required parameters. >&2
    echo Usage: %~nx0 ^<FormattedID^> ^<Title^> [TargetBranch] [DescriptionFile] >&2
    exit /b 1
)

rem 1. Validate that git is initialized
git rev-parse --is-inside-work-tree >nul 2>&1
if !errorlevel! neq 0 (
    echo ERROR: Current directory is not a valid Git repository. >&2
    exit /b 1
)

rem 2. Validate description file
if not exist "%DESC_FILE%" (
    if exist ".docs\mr-description.md" (
        set "DESC_FILE=.docs\mr-description.md"
    ) else (
        echo WARNING: Description file %DESC_FILE% not found. Creating fallback description. >&2
        if not exist ".docs" mkdir ".docs"
        (
            echo # feat^(%FORMATTED_ID%^): %TITLE%
            echo.
            echo SDLC automation completed by Agent.
            echo Rally ID: %FORMATTED_ID%
        ) > ".docs\temp-mr-desc.md"
        set "DESC_FILE=.docs\temp-mr-desc.md"
    )
)

rem 3. Generate sanitized branch slug
for /f "usebackq delims=" %%s in (`powershell -NoProfile -Command "$t = [regex]::Replace('%TITLE%'.ToLower(), '[^a-z0-9]+', '-').Trim('-'); if ($t.Length -gt 40) { $t = $t.Substring(0, 40) }; $t"`) do (
    set "CLEAN_TITLE=%%s"
)
if "%CLEAN_TITLE%"=="" set "CLEAN_TITLE=update"
set "BRANCH_NAME=feature/%FORMATTED_ID%-%CLEAN_TITLE%"

echo ==^> Creating working branch: %BRANCH_NAME%
git checkout -B "%BRANCH_NAME%"

rem 4. Stage and create conventional commit
echo ==^> Staging local changes...
git add .

git diff-index --quiet HEAD -- 2>nul
if !errorlevel! equ 0 (
    echo NOTICE: No local changes detected to commit.
) else (
    (
        echo feat^(%FORMATTED_ID%^): %TITLE%
        echo.
        echo - Implements approved requirements for Rally %FORMATTED_ID%
        echo - Specifications: .docs/requirements.md
        echo - Technical design: .docs/design.md
        echo - Bidirectional Rally-GitLab traceability
        echo.
        echo Rally-Issue: %FORMATTED_ID%
    ) > "%TEMP%\sdlc_commit_msg.txt"

    git commit -F "%TEMP%\sdlc_commit_msg.txt"
    del "%TEMP%\sdlc_commit_msg.txt" 2>nul
    echo ==^> Conventional commit created successfully.
)

rem 5. Push branch to remote origin
echo ==^> Pushing branch upstream...
git remote | findstr /c:"origin" >nul 2>&1
if !errorlevel! equ 0 (
    git push -u origin HEAD
) else (
    echo NOTICE: No 'origin' remote found. Skipping 'git push'. >&2
)

rem 6. Create Merge Request via GitLab CLI
echo ==^> Creating Draft Merge Request via glab CLI...
where glab >nul 2>&1
if !errorlevel! equ 0 (
    set "GLAB_OUT_FILE=%TEMP%\glab_mr_out_%RANDOM%.txt"
    glab mr create --title "feat(%FORMATTED_ID%): %TITLE%" --description-file "%DESC_FILE%" --target-branch "%TARGET_BRANCH%" --source-branch "%BRANCH_NAME%" --draft --assignee @me --label "bot-generated,%FORMATTED_ID%" --yes > "!GLAB_OUT_FILE!" 2>&1
    type "!GLAB_OUT_FILE!"

    for /f "usebackq tokens=1,2" %%A in (`powershell -NoProfile -Command "$content = Get-Content '!GLAB_OUT_FILE!' -Raw; if ($content -match 'https?://[^\s]+/merge_requests/(\d+)') { Write-Output ($matches[0] + ' ' + $matches[1]) }"`) do (
        set "MR_URL=%%A"
        set "MR_IID=%%B"
    )
    del "!GLAB_OUT_FILE!" 2>nul

    if defined MR_IID (
        echo ==^> Adding automated validation note to MR #!MR_IID!...
        (
            echo ## 🤖 Automated Validation Report
            echo - **Rally Story:** %FORMATTED_ID%
            echo - **Documentation:** `.docs/requirements.md` and `.docs/design.md`
            echo - **Post-Task Report:** `.docs/report.md`
            echo.
            echo Merge Request created in **Draft** mode awaiting human review.
        ) > "%TEMP%\mr_note_tmp.md"
        glab mr note create "!MR_IID!" --file "%TEMP%\mr_note_tmp.md" >nul 2>&1
        del "%TEMP%\mr_note_tmp.md" 2>nul
    )

    echo.
    echo ================================================================================
    echo GIT WORKFLOW RESULT:
    echo BRANCH_NAME=%BRANCH_NAME%
    if defined MR_URL (
        echo MR_URL=!MR_URL!
    ) else (
        echo MR_URL=Not available / Pending verification
    )
    if defined MR_IID (
        echo MR_IID=!MR_IID!
    ) else (
        echo MR_IID=N/A
    )
    echo ================================================================================
) else (
    echo WARNING: 'glab' binary is not installed in the environment. >&2
    echo Branch '%BRANCH_NAME%' was created locally. >&2
)

endlocal
exit /b 0
