#!/usr/bin/env bash

error=0

# Compare version strings (e.g., 17.0.9 >= 17.0.0)
# returns 0 if $1 >= $2
version_ge() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

# Check if program is installed and meets the version requirement
check() {
    local exe="$1"
    local name="${4:-$exe}"
    if ! command -v "$exe" &> /dev/null; then
        echo "ERROR: $name not found."
        error=1
    else
        if [ -z ${2+x} ]; then
            echo "found $name"
        else
            check_version "$1" "$2" "$3" "$name"
        fi
    fi
}

# Check version
check_version() {
    local exe="$1"
    local min_version="${2:-1}"
    local installed_version="${3:-1}"
    local name="${4:-$exe}"


    local current_version
    current_version=$(eval "$installed_version")

    if ! version_ge "$current_version" "$min_version"; then
        echo "ERROR: found $name $current_version but $min_version or newer is required."
        error=1
    else
        echo "found $name $current_version (>= $min_version)"
    fi
}

echo "Checking dependencies..."

# Git
check "git" "2.0.0" "git --version | awk '{print \$3}'"

# Java
check "java" "17.0.0" "java -version 2>&1 | awk -F '\"' '/version/ {print \$2}'" "Java"

# Maven
check "mvn" "3.8.0" "mvn --version | awk '/Apache Maven/ {print \$3}'" "Maven"

# Postgres
check "postgres" "9.0" "postgres --version | awk '{ match(\$3, /^[0-9]+(\.[0-9]+)?/, v); print v[0] }'" "PostgreSQL"

# xmlstarlet
check "xmlstarlet"

if [[ "$error" -ne 0 ]]; then
    echo "Encountered errors while checking dependencies."
    exit 1
else
    echo "All requirements met."
fi
