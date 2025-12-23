#!/bin/bash
set -euo pipefail

# Build script for sandboxed PyPy3
# This script builds PyPy3 with sandbox mode enabled using the py3.6-sandbox-2 branch

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYPY_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SANDBOX_BRANCH="origin/branches/py3.6-sandbox-2"

echo "=== PyPy3 Sandbox Build Script ==="
echo "PyPy root: ${PYPY_ROOT}"
echo ""

# Check for pypy2.7
if ! command -v pypy2.7 &> /dev/null; then
    echo "ERROR: pypy2.7 not found in PATH"
    echo "Please ensure PyPy 2.7 is installed and accessible as 'pypy2.7'"
    exit 1
fi

echo "Using PyPy: $(which pypy2.7)"
pypy2.7 --version
echo ""

# Check for cffi
if ! pypy2.7 -c "import cffi" &> /dev/null; then
    echo "ERROR: cffi module not found for pypy2.7"
    echo "Install it with: pypy2.7 -m pip install cffi"
    exit 1
fi
echo "cffi module: OK"
echo ""

# Checkout sandbox branch
cd "${PYPY_ROOT}"

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "detached")
echo "Current branch: ${CURRENT_BRANCH}"

if [ "${CURRENT_BRANCH}" != "branches/py3.6-sandbox-2" ]; then
    # Verify the branch exists locally
    if ! git rev-parse --verify "${SANDBOX_BRANCH}" &>/dev/null; then
        echo "ERROR: Branch ${SANDBOX_BRANCH} not found"
        echo "Ensure you have fetched the branch before running this script"
        exit 1
    fi

    echo "Checking out ${SANDBOX_BRANCH}..."
    git checkout "${SANDBOX_BRANCH}"
else
    echo "Already on sandbox branch"
fi
echo ""

# Navigate to goal directory
cd "${PYPY_ROOT}/pypy/goal"
echo "Working directory: $(pwd)"
echo ""

# Start build
echo "=== Starting RPython Translation ==="
echo "This will take approximately 20-60 minutes depending on your hardware."
echo "Memory requirement: ~6GB RAM"
echo ""
echo "Command: pypy2.7 ../../rpython/bin/rpython -O2 --sandbox targetpypystandalone.py"
echo ""

# Run translation
pypy2.7 ../../rpython/bin/rpython -O2 --sandbox targetpypystandalone.py

echo ""
echo "=== Build Complete ==="
echo ""

# Find the built executable
EXECUTABLE=$(ls -1 pypy3*-c 2>/dev/null | head -1 || true)
if [ -n "${EXECUTABLE}" ]; then
    echo "Sandboxed executable created: ${PYPY_ROOT}/pypy/goal/${EXECUTABLE}"
    echo ""
    echo "To run the sandboxed interpreter, you need the sandboxlib tools:"
    echo "  https://foss.heptapod.net/pypy/sandboxlib"
else
    echo "WARNING: Could not find built executable"
    echo "Check the pypy/goal directory for pypy3*-c files"
fi
