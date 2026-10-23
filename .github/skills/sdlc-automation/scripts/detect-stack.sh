#!/usr/bin/env bash
# ==============================================================================
# Script: detect-stack.sh
# Propósito: Detectar automáticamente el stack tecnológico, gestor de paquetes,
#            comando de pruebas y linter del repositorio del proyecto.
# Salida: Pares clave-valor formateados para fácil consumo por scripts y agentes.
# ==============================================================================

set -euo pipefail

TARGET_DIR="${1:-.}"
cd "$TARGET_DIR"

STACK="unknown"
PACKAGE_MANAGER="none"
TEST_CMD="echo 'No test command detected'"
LINT_CMD="echo 'No lint command detected'"
BUILD_CMD="echo 'No build command detected'"
RUNTIME_VERSION=""

# ------------------------------------------------------------------------------
# 1. Detección de Node.js / TypeScript
# ------------------------------------------------------------------------------
if [ -f "package.json" ]; then
    STACK="nodejs"
    
    # Gestor de paquetes
    if [ -f "pnpm-lock.yaml" ]; then
        PACKAGE_MANAGER="pnpm"
    elif [ -f "yarn.lock" ]; then
        PACKAGE_MANAGER="yarn"
    elif [ -f "bun.lockb" ]; then
        PACKAGE_MANAGER="bun"
    else
        PACKAGE_MANAGER="npm"
    fi

    # Comandos de test
    if grep -q '"test"' package.json 2>/dev/null; then
        TEST_CMD="$PACKAGE_MANAGER test"
    elif [ -f "vitest.config.ts" ] || [ -f "vitest.config.js" ]; then
        TEST_CMD="npx vitest run"
    elif [ -f "jest.config.js" ] || [ -f "jest.config.ts" ]; then
        TEST_CMD="npx jest"
    fi

    # Comandos de lint
    if grep -q '"lint"' package.json 2>/dev/null; then
        LINT_CMD="$PACKAGE_MANAGER run lint"
    elif [ -f ".eslintrc" ] || [ -f ".eslintrc.json" ] || [ -f "eslint.config.js" ]; then
        LINT_CMD="npx eslint ."
    fi

    # Comando de build
    if grep -q '"build"' package.json 2>/dev/null; then
        BUILD_CMD="$PACKAGE_MANAGER run build"
    fi

    if command -v node >/dev/null 2>&1; then
        RUNTIME_VERSION=$(node -v 2>/dev/null || echo "")
    fi

# ------------------------------------------------------------------------------
# 2. Detección de Python
# ------------------------------------------------------------------------------
elif [ -f "pyproject.toml" ] || [ -f "requirements.txt" ] || [ -f "Pipfile" ] || [ -f "setup.py" ]; then
    STACK="python"

    if [ -f "poetry.lock" ]; then
        PACKAGE_MANAGER="poetry"
        TEST_CMD="poetry run pytest"
        LINT_CMD="poetry run ruff check . || poetry run flake8"
        BUILD_CMD="poetry build"
    elif [ -f "Pipfile" ]; then
        PACKAGE_MANAGER="pipenv"
        TEST_CMD="pipenv run pytest"
        LINT_CMD="pipenv run flake8"
    else
        PACKAGE_MANAGER="pip"
        if command -v pytest >/dev/null 2>&1 || grep -qi "pytest" pyproject.toml 2>/dev/null || grep -qi "pytest" requirements.txt 2>/dev/null; then
            TEST_CMD="pytest"
        else
            TEST_CMD="python -m unittest discover"
        fi
        LINT_CMD="ruff check . 2>/dev/null || flake8 2>/dev/null || true"
    fi

    if command -v python3 >/dev/null 2>&1; then
        RUNTIME_VERSION=$(python3 --version 2>/dev/null || echo "")
    elif command -v python >/dev/null 2>&1; then
        RUNTIME_VERSION=$(python --version 2>/dev/null || echo "")
    fi

# ------------------------------------------------------------------------------
# 3. Detección de .NET (C# / F#)
# ------------------------------------------------------------------------------
elif ls *.csproj >/dev/null 2>&1 || ls *.sln >/dev/null 2>&1 || [ -f "global.json" ]; then
    STACK="dotnet"
    PACKAGE_MANAGER="nuget/dotnet"
    TEST_CMD="dotnet test"
    LINT_CMD="dotnet format --verify-no-changes"
    BUILD_CMD="dotnet build"

    if command -v dotnet >/dev/null 2>&1; then
        RUNTIME_VERSION=$(dotnet --version 2>/dev/null || echo "")
    fi

# ------------------------------------------------------------------------------
# 4. Detección de Java (Maven / Gradle)
# ------------------------------------------------------------------------------
elif [ -f "pom.xml" ]; then
    STACK="java-maven"
    PACKAGE_MANAGER="maven"
    TEST_CMD="mvn test"
    LINT_CMD="mvn checkstyle:check"
    BUILD_CMD="mvn clean compile"
    if command -v java >/dev/null 2>&1; then
        RUNTIME_VERSION=$(java -version 2>&1 | head -n 1)
    fi

elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
    STACK="java-gradle"
    PACKAGE_MANAGER="gradle"
    if [ -f "./gradlew" ]; then
        TEST_CMD="./gradlew test"
        BUILD_CMD="./gradlew build"
    else
        TEST_CMD="gradle test"
        BUILD_CMD="gradle build"
    fi
    LINT_CMD="echo 'Check gradle lint tasks'"

# ------------------------------------------------------------------------------
# 5. Detección de Go
# ------------------------------------------------------------------------------
elif [ -f "go.mod" ]; then
    STACK="golang"
    PACKAGE_MANAGER="go modules"
    TEST_CMD="go test ./..."
    LINT_CMD="golangci-lint run 2>/dev/null || go vet ./..."
    BUILD_CMD="go build ./..."

    if command -v go >/dev/null 2>&1; then
        RUNTIME_VERSION=$(go version 2>/dev/null || echo "")
    fi

# ------------------------------------------------------------------------------
# 6. Detección de Rust
# ------------------------------------------------------------------------------
elif [ -f "Cargo.toml" ]; then
    STACK="rust"
    PACKAGE_MANAGER="cargo"
    TEST_CMD="cargo test"
    LINT_CMD="cargo clippy"
    BUILD_CMD="cargo build"

    if command -v rustc >/dev/null 2>&1; then
        RUNTIME_VERSION=$(rustc --version 2>/dev/null || echo "")
    fi
fi

# ------------------------------------------------------------------------------
# Emisión estructurada de resultados
# ------------------------------------------------------------------------------
cat <<EOF
STACK=$STACK
PACKAGE_MANAGER=$PACKAGE_MANAGER
TEST_CMD=$TEST_CMD
LINT_CMD=$LINT_CMD
BUILD_CMD=$BUILD_CMD
RUNTIME_VERSION=$RUNTIME_VERSION
EOF
