# Etapa 1: Compilación del binario Rust
FROM ubuntu:latest AS builder

ENV DEBIAN_FRONTEND=noninteractive

ARG ARCH=arm64

RUN apt-get update && apt-get install -y \
    curl \
    bash \
    build-essential \
    pkg-config \
    libssl-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instala Rust y herramientas necesarias
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN cargo install cbindgen

# Copia el código fuente
WORKDIR /build
COPY . .

RUN ls -la
# Compila el crate curp_verifier
RUN make all
RUN ls -la

# Etapa 2: Empaquetado del .deb
FROM ubuntu:latest as package

ENV DEBIAN_FRONTEND=noninteractive

ARG ARCH=arm64

RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    lintian \
    gzip \
    dpkg-dev \
    devscripts \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN make package-deb ARCH=$ARCH
RUN ls -la

# Copia solo lo necesario desde el builder
COPY --from=builder /build /app

# Define el directorio de trabajo
WORKDIR /app

# Ejecuta el empaquetado
#CMD ["make", "-C", "src/rust/curp_verifier", "package-deb", "ARCH=amd64"]
ENTRYPOINT [ "bash" ]