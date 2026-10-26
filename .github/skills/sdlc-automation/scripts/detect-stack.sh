#!/usr/bin/env bash
# ==============================================================================
# Script: detect-stack.sh
# Purpose: Automatically detect project tech stack (Python or Java),
#          package manager, test runner, and linter (Unix/Linux/macOS).
# Output: Key-value pairs for easy consumption by scripts and agents.
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
# 1. Python Stack Detection
# ------------------------------------------------------------------------------
IS_PYTHON=0
if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ] || [ -f "Pipfile" ] || [ -f "setup.py" ]; then
    IS_PYTHON=1
fi

if [ "$IS_PYTHON" -eq 1 ]; then
    STACK="python"

    if [ -f "poetry.lock" ]; then
        PACKAGE_MANAGER="poetry"
        TEST_CMD="poetry run pytest"
        LINT_CMD="poetry run ruff check ."
        BUILD_CMD="poetry build"
    elif [ -f "Pipfile" ]; then
        PACKAGE_MANAGER="pipenv"
        TEST_CMD="pipenv run pytest"
        LINT_CMD="pipenv run flake8"
        BUILD_CMD="pipenv lock"
    else
        PACKAGE_MANAGER="pip"
        TEST_CMD="python -m unittest discover"
        if command -v pytest >/dev/null 2>&1; then
            TEST_CMD="pytest"
        elif [ -f "pyproject.toml" ] && grep -qi "pytest" pyproject.toml; then
            TEST_CMD="pytest"
        elif [ -f "requirements.txt" ] && grep -qi "pytest" requirements.txt; then
            TEST_CMD="pytest"
        fi

        LINT_CMD="flake8"
        if command -v ruff >/dev/null 2>&1; then
            LINT_CMD="ruff check ."
        fi
        BUILD_CMD="python -m build"
    fi

    if command -v python3 >/dev/null 2>&1; then
        RUNTIME_VERSION=$(python3 --version 2>&1 || true)
    elif command -v python >/dev/null 2>&1; then
        RUNTIME_VERSION=$(python --version 2>&1 || true)
    fi
fi

# ------------------------------------------------------------------------------
# 2. Java (Maven) Stack Detection
# ------------------------------------------------------------------------------
if [ -f "pom.xml" ]; then
    STACK="java-maven"
    PACKAGE_MANAGER="maven"
    TEST_CMD="mvn test"
    LINT_CMD="mvn checkstyle:check"
    BUILD_CMD="mvn clean compile"
    if command -v java >/dev/null 2>&1; then
        RUNTIME_VERSION=$(java -version 2>&1 | head -n 1 || true)
    fi
fi

# ------------------------------------------------------------------------------
# 3. Java (Gradle) Stack Detection
# ------------------------------------------------------------------------------
if [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
    STACK="java-gradle"
    PACKAGE_MANAGER="gradle"
    if [ -f "./gradlew" ]; then
        TEST_CMD="./gradlew test"
        BUILD_CMD="./gradlew build"
        LINT_CMD="./gradlew check"
    else
        TEST_CMD="gradle test"
        BUILD_CMD="gradle build"
        LINT_CMD="gradle check"
    fi
    if command -v java >/dev/null 2>&1; then
        RUNTIME_VERSION=$(java -version 2>&1 | head -n 1 || true)
    fi
fi

# ------------------------------------------------------------------------------
# Emit Results
# ------------------------------------------------------------------------------
cat <<EOF
STACK=$STACK
PACKAGE_MANAGER=$PACKAGE_MANAGER
TEST_CMD=$TEST_CMD
LINT_CMD=$LINT_CMD
BUILD_CMD=$BUILD_CMD
RUNTIME_VERSION=$RUNTIME_VERSION
EOF
