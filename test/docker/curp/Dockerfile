FROM debian:stable

RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    ca-certificates \
    gcc && \
    echo "deb [trusted=yes] https://repository.rafex.app/debian stable main" > /etc/apt/sources.list.d/rafex.list && \
    apt-get update && \
    apt-get install -y curp-verifier curp-generator && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY test_local.c /app/main.c
RUN gcc /app/main.c -L/usr/lib -lcurp_verifier -lcurp_generator -o /app/test && \
    echo "📦 Ejecutando prueba de curp-generator + curp-verifier:" && /app/test

RUN ldd /usr/lib/libcurp_verifier.so && ldd /usr/lib/libcurp_generator.so

CMD ["/app/test"]