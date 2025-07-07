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
        echo "Found $name $current_version but $min_version or newer is required."
        error=1
    fi

    echo "found $name $current_version (>= $min_version)"
}

echo "Checking dependencies..."

check "git" "2.0.0" "git --version | awk '{print \$3}'"
check "cc" "9.0.0" "cc --version | awk '/cc/ {print \$3}'" "C Compiler"
check "make" "3.8.1" "make --version | awk '/GNU Make/ {print \$3}'" "GNU Make"
check "tar"
check "flex"
check "bison"
check "perl"
#readline
#zlib
#icu
check "python3" "3.2" "python3 --version | awk '{print \$2}'"
check "kinit" #kerberos
check "openssl" "1.0.2" "openssl --version | awk '{print \$2}'"

if [[ "$error" -ne 0 ]]; then
    echo "Encountered errors while checking dependencies."
    exit 1
else
    echo "All requirements met."
fi
