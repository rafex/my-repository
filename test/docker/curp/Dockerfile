FROM debian:stable

WORKDIR /app

RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    ca-certificates \
    gcc && \
    curl -fsSL https://repository.rafex.app/pubkey.asc | gpg --dearmor -o /usr/share/keyrings/rafex.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/rafex.gpg] https://repository.rafex.app/debian stable main" > /etc/apt/sources.list.d/rafex.list && \
    apt-get update && \
    apt-get install -y curp-verifier curp-generator \
    && { dpkg -s curp-verifier && dpkg -L curp-verifier && dpkg -s curp-generator && dpkg -L curp-generator; } > /app/installed_files.txt \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY test_local.c /app/main.c
RUN gcc /app/main.c -L/usr/lib -lcurp_verifier -lcurp_generator -o /app/test && \
    echo "📦 Ejecutando prueba de curp-generator + curp-verifier:" && /app/test \
    && echo "📄 Archivos instalados por los paquetes:" && cat /app/installed_files.txt

RUN ldd /usr/lib/libcurp_verifier.so && ldd /usr/lib/libcurp_generator.so

CMD ["/app/test"]