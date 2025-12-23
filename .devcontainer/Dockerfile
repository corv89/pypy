FROM debian:bookworm

# Install build dependencies for PyPy
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    make \
    pkg-config \
    libffi-dev \
    zlib1g-dev \
    libbz2-dev \
    libsqlite3-dev \
    libncurses-dev \
    libncursesw5-dev \
    libexpat1-dev \
    libssl-dev \
    libgdbm-dev \
    liblzma-dev \
    tk-dev \
    libgc-dev \
    git \
    curl \
    wget \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and install PyPy 2.7 for faster translation
# Supports both x86_64 (linux64) and ARM64 (aarch64)
ENV PYPY_VERSION=7.3.20
RUN cd /opt && \
    ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        PYPY_ARCH="linux64"; \
        PYPY_SHA256="aa3bb92dbb529fa2d4920895b16d67a810b0c709207857d56cfe4a6e3b41e02a"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        PYPY_ARCH="aarch64"; \
        PYPY_SHA256="f22a1be607deeaa4f9be6bc63aae09fe4fb5b990d6a23aa4e7c5960dc5d93c96"; \
    else \
        echo "Unsupported architecture: $ARCH"; exit 1; \
    fi && \
    wget -q https://downloads.python.org/pypy/pypy2.7-v${PYPY_VERSION}-${PYPY_ARCH}.tar.bz2 && \
    echo "${PYPY_SHA256}  pypy2.7-v${PYPY_VERSION}-${PYPY_ARCH}.tar.bz2" | sha256sum -c - && \
    tar xf pypy2.7-v${PYPY_VERSION}-${PYPY_ARCH}.tar.bz2 && \
    rm pypy2.7-v${PYPY_VERSION}-${PYPY_ARCH}.tar.bz2 && \
    ln -s /opt/pypy2.7-v${PYPY_VERSION}-${PYPY_ARCH}/bin/pypy /usr/local/bin/pypy2.7

# Install cffi for PyPy (required for rpython translation)
RUN pypy2.7 -m ensurepip && \
    pypy2.7 -m pip install --upgrade pip && \
    pypy2.7 -m pip install cffi

# Set working directory
WORKDIR /workspace

# Verify installation
RUN pypy2.7 --version && pypy2.7 -c "import cffi; print('cffi version:', cffi.__version__)"
