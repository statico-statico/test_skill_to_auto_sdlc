@echo off
rem ==============================================================================
rem Script: detect-stack.bat
rem Propósito: Detectar automáticamente el stack tecnológico, gestor de paquetes,
rem            comando de pruebas y linter del repositorio del proyecto (Windows Batch).
rem Salida: Pares clave-valor formateados para fácil consumo por scripts y agentes.
rem ==============================================================================

setlocal EnableDelayedExpansion

set "TARGET_DIR=%~1"
if not "%TARGET_DIR%"=="" (
    cd /d "%TARGET_DIR%" 2>nul
)

set "STACK=unknown"
set "PACKAGE_MANAGER=none"
set "TEST_CMD=echo 'No test command detected'"
set "LINT_CMD=echo 'No lint command detected'"
set "BUILD_CMD=echo 'No build command detected'"
set "RUNTIME_VERSION="

rem ------------------------------------------------------------------------------
rem 1. Detección de Node.js / TypeScript
rem ------------------------------------------------------------------------------
if exist "package.json" (
    set "STACK=nodejs"

    if exist "pnpm-lock.yaml" (
        set "PACKAGE_MANAGER=pnpm"
    ) else if exist "yarn.lock" (
        set "PACKAGE_MANAGER=yarn"
    ) else if exist "bun.lockb" (
        set "PACKAGE_MANAGER=bun"
    ) else (
        set "PACKAGE_MANAGER=npm"
    )

    rem Verificar scripts en package.json
    findstr /c:"\"test\"" package.json >nul 2>&1
    if !errorlevel! equ 0 (
        set "TEST_CMD=!PACKAGE_MANAGER! test"
    ) else if exist "vitest.config.ts" (
        set "TEST_CMD=npx vitest run"
    ) else if exist "vitest.config.js" (
        set "TEST_CMD=npx vitest run"
    ) else if exist "jest.config.js" (
        set "TEST_CMD=npx jest"
    ) else if exist "jest.config.ts" (
        set "TEST_CMD=npx jest"
    )

    findstr /c:"\"lint\"" package.json >nul 2>&1
    if !errorlevel! equ 0 (
        set "LINT_CMD=!PACKAGE_MANAGER! run lint"
    ) else if exist ".eslintrc" (
        set "LINT_CMD=npx eslint ."
    ) else if exist ".eslintrc.json" (
        set "LINT_CMD=npx eslint ."
    ) else if exist "eslint.config.js" (
        set "LINT_CMD=npx eslint ."
    )

    findstr /c:"\"build\"" package.json >nul 2>&1
    if !errorlevel! equ 0 (
        set "BUILD_CMD=!PACKAGE_MANAGER! run build"
    )

    where node >nul 2>&1
    if !errorlevel! equ 0 (
        for /f "tokens=*" %%v in ('node -v 2^>nul') do set "RUNTIME_VERSION=%%v"
    )
    goto :EMIT_RESULT
)

rem ------------------------------------------------------------------------------
rem 2. Detección de Python
rem ------------------------------------------------------------------------------
set "IS_PYTHON=0"
if exist "pyproject.toml" set "IS_PYTHON=1"
if exist "requirements.txt" set "IS_PYTHON=1"
if exist "Pipfile" set "IS_PYTHON=1"
if exist "setup.py" set "IS_PYTHON=1"

if "%IS_PYTHON%"=="1" (
    set "STACK=python"

    if exist "poetry.lock" (
        set "PACKAGE_MANAGER=poetry"
        set "TEST_CMD=poetry run pytest"
        set "LINT_CMD=poetry run ruff check . || poetry run flake8"
        set "BUILD_CMD=poetry build"
    ) else if exist "Pipfile" (
        set "PACKAGE_MANAGER=pipenv"
        set "TEST_CMD=pipenv run pytest"
        set "LINT_CMD=pipenv run flake8"
    ) else (
        set "PACKAGE_MANAGER=pip"
        set "TEST_CMD=python -m unittest discover"
        where pytest >nul 2>&1
        if !errorlevel! equ 0 set "TEST_CMD=pytest"
        if exist "pyproject.toml" (
            findstr /i /c:"pytest" pyproject.toml >nul 2>&1
            if !errorlevel! equ 0 set "TEST_CMD=pytest"
        )
        if exist "requirements.txt" (
            findstr /i /c:"pytest" requirements.txt >nul 2>&1
            if !errorlevel! equ 0 set "TEST_CMD=pytest"
        )
        set "LINT_CMD=ruff check . 2>nul || flake8 2>nul || ver >nul"
    )

    where python >nul 2>&1
    if !errorlevel! equ 0 (
        for /f "tokens=*" %%v in ('python --version 2^>nul') do set "RUNTIME_VERSION=%%v"
    ) else (
        where python3 >nul 2>&1
        if !errorlevel! equ 0 (
            for /f "tokens=*" %%v in ('python3 --version 2^>nul') do set "RUNTIME_VERSION=%%v"
        )
    )
    goto :EMIT_RESULT
)

rem ------------------------------------------------------------------------------
rem 3. Detección de .NET (C# / F#)
rem ------------------------------------------------------------------------------
set "IS_DOTNET=0"
if exist "*.csproj" set "IS_DOTNET=1"
if exist "*.sln" set "IS_DOTNET=1"
if exist "global.json" set "IS_DOTNET=1"

if "%IS_DOTNET%"=="1" (
    set "STACK=dotnet"
    set "PACKAGE_MANAGER=nuget/dotnet"
    set "TEST_CMD=dotnet test"
    set "LINT_CMD=dotnet format --verify-no-changes"
    set "BUILD_CMD=dotnet build"

    where dotnet >nul 2>&1
    if !errorlevel! equ 0 (
        for /f "tokens=*" %%v in ('dotnet --version 2^>nul') do set "RUNTIME_VERSION=%%v"
    )
    goto :EMIT_RESULT
)

rem ------------------------------------------------------------------------------
rem 4. Detección de Java (Maven / Gradle)
rem ------------------------------------------------------------------------------
if exist "pom.xml" (
    set "STACK=java-maven"
    set "PACKAGE_MANAGER=maven"
    set "TEST_CMD=mvn test"
    set "LINT_CMD=mvn checkstyle:check"
    set "BUILD_CMD=mvn clean compile"
    where java >nul 2>&1
    if !errorlevel! equ 0 (
        for /f "tokens=*" %%v in ('java -version 2^>^&1') do (
            if not defined RUNTIME_VERSION set "RUNTIME_VERSION=%%v"
        )
    )
    goto :EMIT_RESULT
)

if exist "build.gradle" set "IS_GRADLE=1"
if exist "build.gradle.kts" set "IS_GRADLE=1"
if "%IS_GRADLE%"=="1" (
    set "STACK=java-gradle"
    set "PACKAGE_MANAGER=gradle"
    if exist "gradlew.bat" (
        set "TEST_CMD=gradlew.bat test"
        set "BUILD_CMD=gradlew.bat build"
    ) else (
        set "TEST_CMD=gradle test"
        set "BUILD_CMD=gradle build"
    )
    set "LINT_CMD=echo 'Check gradle lint tasks'"
    goto :EMIT_RESULT
)

rem ------------------------------------------------------------------------------
rem 5. Detección de Go
rem ------------------------------------------------------------------------------
if exist "go.mod" (
    set "STACK=golang"
    set "PACKAGE_MANAGER=go modules"
    set "TEST_CMD=go test ./..."
    set "LINT_CMD=golangci-lint run 2>nul || go vet ./..."
    set "BUILD_CMD=go build ./..."

    where go >nul 2>&1
    if !errorlevel! equ 0 (
        for /f "tokens=*" %%v in ('go version 2^>nul') do set "RUNTIME_VERSION=%%v"
    )
    goto :EMIT_RESULT
)

rem ------------------------------------------------------------------------------
rem 6. Detección de Rust
rem ------------------------------------------------------------------------------
if exist "Cargo.toml" (
    set "STACK=rust"
    set "PACKAGE_MANAGER=cargo"
    set "TEST_CMD=cargo test"
    set "LINT_CMD=cargo clippy"
    set "BUILD_CMD=cargo build"

    where rustc >nul 2>&1
    if !errorlevel! equ 0 (
        for /f "tokens=*" %%v in ('rustc --version 2^>nul') do set "RUNTIME_VERSION=%%v"
    )
    goto :EMIT_RESULT
)

:EMIT_RESULT
echo STACK=%STACK%
echo PACKAGE_MANAGER=%PACKAGE_MANAGER%
echo TEST_CMD=%TEST_CMD%
echo LINT_CMD=%LINT_CMD%
echo BUILD_CMD=%BUILD_CMD%
echo RUNTIME_VERSION=%RUNTIME_VERSION%

endlocal
exit /b 0
