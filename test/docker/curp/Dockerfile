FROM debian:stable

RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    ca-certificates \
    gcc && \
    echo "deb [trusted=yes] https://repository.rafex.app/debian stable main" > /etc/apt/sources.list.d/rafex.list && \
    apt-get update && \
    apt-get install -y curp-verifier && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY main.c /app/main.c
RUN gcc /app/main.c -L/usr/lib -lcurp_verifier -o /app/test && \
    echo "📦 Ejecutando prueba de curp-verifier:" && /app/test

RUN ldd /usr/lib/libcurp_verifier.so

CMD ["/app/test"]